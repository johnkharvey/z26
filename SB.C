/*
** sb.c -- Sound Blaster driver code for z26
**
** based on dmav.c by Tom Bouril, (c) 1993-1996 Creative Technologies Ltd.  (October 1994)
**
** Jan  7, 1998 -- Added shortened interrupt handler for 8-bit DMA only.
** (0.88)
**                 This was partly needed because old SoundBlasters don't have 
**                 a mixer register.  And partly to make it faster.
**
** Jan 11, 1998 -- Changed samples per second programming method for 8-bit sound
** (0.89)          on 16-bit cards to use old-fashioned time constant so we can use a 
**                 frequency of 31400 and get the same pitch as on an old 8-bit card.
**
**                 Setting frequency to 31500 would also have worked but 31400 is
**                 the "magic" number.
**
** Feb 22, 1998 -- Simplify code.  Bail out of ResetDSP, DSPRead, DSPWrite if timeout.
** (0.93)
*/


#ifndef NULL
#define NULL 0
#endif

#define AUTO_INIT                  1
#define BITS_PER_SAMPLE_8     0x0400
#define BITS_PER_SAMPLE_16    0x0800
#define COMMAND_PAUSE           0x01
#define COMMAND_PLAY            0x02
#define COMMAND_QUIT            0x04
#define DMA8_FF_REG           0x000C
#define DMA8_MASK_REG         0x000A
#define DMA8_MODE_REG         0x000B
#define DMA16_FF_REG          0x00D8
#define DMA16_MASK_REG        0x00D4
#define DMA16_MODE_REG        0x00D6
#define DSP_DATA_AVAIL        0x000E
#define DSP_GET_VERSION       0x00E1
#define DSP_READ_PORT         0x000A
#define DSP_READY             0x00AA
#define DSP_RESET_PORT        0x0006
#define DSP_WRITE_PORT        0x000C
#define END_OF_INTERRUPT      0x0020
#define FAIL                       0
#define FALSE                      0
#define FILE_NOT_DONE_PLAYING 0x8000
#define INVALID_BLOCK_TYPE    0x4000
#define INVALID_FILE_FORMAT        1
#define PIC0_COMMAND_REG        0x20
#define PIC1_COMMAND_REG        0xA0
#define PIC0_MASK_REG           0x21
#define PIC1_MASK_REG           0xA1
#define REMEMBER_VOLUME            1
#define RESTORE_VOLUME             2
#define KILL_VOLUME                3
#define SB2_LO                     1
#define SB2_HI                     2
#define SBPRO                      3
#define SB16                       4
#define SINGLE_CYCLE               2
#define SUCCESS                    1
#define TRUE                  !FALSE
#define UNUSED                     0

#define VOC_FILE                   2
#define WAVE_FILE                  3


/*
** Properties of SoundBlaster installed in system
*/

short int gBaseIOPort,
	  gDMAChan8Bit,
	  gDMAChan16Bit,
	  gDSPVersion,
	  gIRQNumber,
	  gMIDIPort;


/*
** Properties of sound being played
*/

unsigned char      gBitsPerSample, /* 8 or 16 */
		   gChannels;      /* MONO = 1, STEREO = 2 */
unsigned short int gSoundFormat,   /* Determines BitsPerSample in old .VOC */
		   gTimeConstant;  /* Old .VOC version of SampPerSec */
signed long int	   gSampPerSec;


typedef unsigned long int DWORD;


/*
** global variables
*/

unsigned short int gDMABufNowPlaying,
		   gDMABufSize,
		   gHighSpeed,
		   gIRQMaskSave0,
		   gIRQMaskSave1;

signed long int gBytesLeftToPlay;

unsigned char     *DMABuf;
unsigned long int  DMABufPhysAddr;

void interrupt (*gOldISRFuncPtr)(void);




/*
** SoundBlaster functions
*/

char GetBlastEnv(void),
     ResetDSP(void);

short int DSPRead(void);

unsigned long int AllocateDMABuffer(unsigned char **, unsigned short int *),
		  OnSamePage(unsigned char *, unsigned short int);

void interrupt DmaISR(void);
void ContinueDMA(void),
     DSPWrite(short int),
     PauseDMA(void),
     ProgramDMA(unsigned long int, unsigned short int),
     ProgramDSP(unsigned short int),
     RestoreOldISR(void),
     ManageVolume(char),
     SetDmaISR(void);


/*
** FUNCTION: ProgramDMA()
**
** DESCRIPTION:  This function programs the DMA chip to use a single
**               8-bit or 16-bit DMA channel (specified by the BLASTER
**               environment string) for audio transfer.  It also programs
**               the size of the DMA transfer and the DMA buffer address
**               used for the audio transfer.
*/

void ProgramDMA(unsigned long int DMABufPhysAddr, unsigned short int Count)
{
  short int Command,
	    DMAAddr,
	    DMACount,
	    DMAPage,
	    Offset,
	    Page,
	    Temp;

  Page   = (short int) (DMABufPhysAddr >> 16);
  Offset = (short int) (DMABufPhysAddr & 0xFFFF);

  switch(gDMAChan8Bit)
  {
    case 0:
	DMAAddr  = 0x0000;
	DMACount = 0x0001;
	DMAPage  = 0x0087;
    break;

    case 1:
	DMAAddr  = 0x0002;
	DMACount = 0x0003;
	DMAPage  = 0x0083;
    break;

    case 3:
	DMAAddr  = 0x0006;
	DMACount = 0x0007;
	DMAPage  = 0x0082;
    break;
  }

  outp(DMA8_MASK_REG, gDMAChan8Bit | 4);    /* Disable DMA */
  outp(DMA8_FF_REG, 0x0000);                /* Clear F-F */
  outp(DMA8_MODE_REG, gDMAChan8Bit | 0x58); /* 8-bit AI */
  outp(DMACount, ((Count - 1) & 0xFF));     /* LO byte */
  outp(DMACount, ((Count - 1) >> 8));       /* HI byte */

  /* Program the starting address of the DMA buffer. */

  outp(DMAPage, Page);             /* Page number of DMA buffer. */
  outp(DMAAddr, Offset & 0x00FF);  /* LO byte offset address of DMA buffer. */
  outp(DMAAddr, (Offset >> 8));    /* HI byte offset address of DMA buffer. */

  outp(DMA8_MASK_REG,  gDMAChan8Bit); /* reenable 8-bit DMA */
}


/*
** FUNCTION: ProgramDSP()
**
** DESCRIPTION: This function programs the DSP chip on the Sound Blaster
**              card.  The card type is identified by the DSP version
**              number.  Each type of Sound Blaster card is programmed
**              differently unless an 8-bit ADPCM file is played.  In that
**              case, all SB cards are programmed identically.
*/

void ProgramDSP(unsigned short int Count)
{
  short int     Command;

  if (gHighSpeed) return; /* Once in high-speed mode, DSP can only be reset! */

  /* Make sure Count is >= 2, so when the DSP is programmed for a block */
  /* tranfer, Count doesn't wrap around to a large number when 1 is */
  /* subtracted from it. */

  if (Count <= 1)
    Count = 2;

  DSPWrite(0x0040);			/* Program Time Constant */
  DSPWrite(gTimeConstant);

  /*--- DETERMINE SOUND BLASTER CARD TYPE ----------------------------*/

  if (gDSPVersion >= 0x0400)		/*** DSP version >= 4.00 (SB16) ***/
  {
    DSPWrite(0x00C4);			/* Auto-init */
    DSPWrite(0x0000);			/* Mono, unsigned PCM data */
    DSPWrite((Count - 1) & 0xFF);	/* LO byte */
    DSPWrite((Count - 1) >> 8);		/* HI byte */
    return;				/* RETURN! */
  }
  else if (gDSPVersion >= 0x0300)	/*** DSP version = 3.xx (SB-PRO) ***/
  {
    /* Set SBPRO mixer register default to MONO, Output filter to OFF. */

    outp(gBaseIOPort + 4, 0x000E);	/* Select mixer reg. 0x0E. */
    outp(gBaseIOPort + 5, 0x0000);	/* MONO, Output filter off. */

    DSPWrite(0x00A0);			/* Default to MONO. */
  }
  
  if (gDSPVersion >= 0x0201)		/*** 2.01 <= DSP version < 3.xx 
					            (SB 2.0+ and SB-PRO) ***/
  {
    gHighSpeed = TRUE;
    Command = 0x0090;	  		/* HIGH-SPEED, AUTO-INIT MODE */
  }
  else					/*** DSP version <= 2.00 (SB 2.0) ***/
  {
    Command = 0x001C;			/* NORMAL, MONO, AUTO-INIT */
  }

  DSPWrite(0x00D1);			/* Turn speaker on. */

  /*--- NOTE: If in high-speed mode, single-cycle DMA is programmed ----*/
  /*--- using the same initial DSP command as auto-init (0x0048).   ----*/

  /* Program block tranfer size LO and HI byte and begin tranfer. */

  DSPWrite(0x0048);
  DSPWrite((Count - 1) & 0x00FF);  /* LO byte */
  DSPWrite((Count - 1) >> 8);      /* HI byte */
  DSPWrite(Command);               /* Begin Xfer */
}


/*
** FUNCTION:  DmaISR()
**
** DESCRIPTION: If the interrupt was a DMA generated by the Sound Blaster,
**              acknowledge the interrupt, update the global variables,
**              and send the end-of-interrupt command(s).
*/

/*
** a simplified interrupt handler for 8-bit DMA only
*/

void interrupt DmaISR(void)
{
  inp(gBaseIOPort + 0x000E);	/* acknowledge interrupt */

  gDMABufNowPlaying ^= 1;  /* Keep track of which 1/2 DMA buffer is playing. */

  /* Send end-of-interrupt command(s). */

  if (gIRQNumber > 7)
    outp(PIC1_COMMAND_REG, END_OF_INTERRUPT);

  outp(PIC0_COMMAND_REG, END_OF_INTERRUPT);
}


/*
** FUNCTION: RestoreOldISR()
**
** DESCRIPTION:  1) Disable all interrupts.
**               2) Restore IRQ mask for IRQs 0 to 7.
**               3) If necessary, restore IRQ mask for IRQs 8 to 15.
**               4) Restore the original ISR (which was saved to a global
**                  varaiable function pointer in SetDmaISR()) for the
**                  interrupt vector number associated with
**                  BlastSet->IRQNumber.
**               5) Enable all interrupts.
*/

void RestoreOldISR()
{
  short int IntVectorNumber;

  disable();  /* Temporarily disable interrupts */

  outp(PIC0_MASK_REG, gIRQMaskSave0);    /* Restore IRQ mask for IRQs 0 to 7. */

  if (gIRQNumber > 7)
  {
    outp(PIC1_MASK_REG, gIRQMaskSave1);  /* Restore IRQ mask for IRQs 8 to 15. */
    IntVectorNumber = gIRQNumber - 8 + 0x70;
  }
  else  /* BlastSet->IRQNumber is 0 to 7. */
    IntVectorNumber = gIRQNumber + 8;

  /* Restore the old ISR to the interrupt vector number. */

  setvect(IntVectorNumber, gOldISRFuncPtr);

  enable();   /* Enable interrupts */
}


/*
** FUNCTION: SetDmaISR()
**
** DESCRIPTION:  1) Disable all interrupts.
**               2) Save current interrupt mask(s) to global variable(s).
**               3) Set new interrupt mask(s).
**               4) Save ISR associated with BlastSet->IRQNumber to
**                  a global variable function pointer.
**               5) Set the new ISR associated with BlastSet->IRQNumber.
**               6) Enable all interrupts.
*/

void SetDmaISR()
{
  short int IntVectorNum,
	    IRQMaskNew;

  disable();  /* Temporarily disable interrupts. */

  /*--- Save current interrupt masks and set the new ones. -------------*/

  gIRQMaskSave0 = inp(PIC0_MASK_REG);    /* Save IRQ 0 to 7 mask. */
  if (gIRQNumber > 7)
  {
    IntVectorNum  = gIRQNumber - 8 + 0x70;
    gIRQMaskSave1 = inp(PIC1_MASK_REG);  /* Save IRQ 8 to 15 mask. */

    /* Set new IRQ mask for IRQs 8 to 15. */

    IRQMaskNew = ~(((short int) 0x0001) << (gIRQNumber - 8));
    outp(PIC1_MASK_REG, gIRQMaskSave1 & IRQMaskNew);

    /* Setting IRQ mask 2 on PIC 0 enables IRQs 8 to 15 on PIC 1. */

    outp(PIC0_MASK_REG, gIRQMaskSave0 & ~0x0004);
  }
  else  /* gIRQNumber is 0 to 7. */
  {
    IntVectorNum = gIRQNumber + 8;

    /* Set new IRQ mask for IRQs 0 to 7. */

    IRQMaskNew = ~(((short int) 0x0001) << gIRQNumber);
    outp(PIC0_MASK_REG, gIRQMaskSave0 & IRQMaskNew);
  }

  /*--- Save current ISR and set the new one. --------------------------*/

  gOldISRFuncPtr = getvect(IntVectorNum);

  setvect(IntVectorNum, DmaISR);

  enable();  /* Enable interrupts. */
}


/*
** FUNCTION: GetBlastEnv()
**
** DESCRIPTION: Search the BLASTER environment string for:
**
**              A) Base IO Port Address
**              B) LO (8 bit)  DMA Channel
**              C) HI (16 bit) DMA Channel
**              D) IRQ Number
**              E) MIDI Port address
**
**              The Base I/O port address and the MIDI address are stored
**              in the environment string in hex--convert them to integer.
**              These numbers from the environment string are then placed
**              in the BLASTER struct passed to this function as a pointer.
**              The BLASTER struct is defined as:
**
**              typedef struct _BLASTER
**              {
**                short int BaseIOPort,
**                          DMAChan8Bit,
**                          DMAChan16Bit,
**                          DSPVersion,
**                          IRQNumber,
**                          MIDIPort;
**              } BLASTER;
**
**              Then, get the DSP version of the Sound Blaster DSP chip.
**              This is used to determine the Sound Blaster's capabilities.
**
** RETURN: FAIL - BLASTER environment string is not found or any of
**                the BLASTER structure members aren't found.
**
**         SUCCESS - All 5 members of BLASTER struct are found in the
**                   BLASTER environment string.
*/

char GetBlastEnv()
{
  char  Buffer[5],
	DMAChannelNotFound = TRUE,
       *EnvString,
	IOPortNotFound     = TRUE,
	IRQNotFound        = TRUE,
	SaveChar,
	ResetDSPValue;

  short int digit,
	    i,
	    Major,
	    Minor,
	    multiplier;

  EnvString = getenv("BLASTER");

  if (EnvString == NULL)
    return(FAIL);  /* BLASTER environment variable not found. */

  do
  {
    switch(*EnvString)
    {
      case 'A':  /* I/O base port address found */
      case 'a':
	EnvString++;
	for (i = 0; i < 3; i++)  /* Grab the digits */
	{
	  Buffer[i] = *EnvString;
	  EnvString++;
	}

	/* The string is in ASCII HEX, convert it to decimal */

	multiplier = 1;
	gBaseIOPort = 0;
	for (i -= 1; i >= 0; i--)
	{
	  if (Buffer[i] >= '0' && Buffer[i] <= '9')
	    digit = Buffer[i] - '0';
	  else if (Buffer[i] >= 'A' && Buffer[i] <= 'F')
	    digit = Buffer[i] - 'A' + 10;
	  else if (Buffer[i] >= 'a' && Buffer[i] <= 'f')
	    digit = Buffer[i] - 'a' + 10;

	  gBaseIOPort += digit * multiplier;
	  multiplier *= 16;
	}

	IOPortNotFound = FALSE;
      break;


      case 'D': /* 8-bit DMA channel */
      case 'd':
      case 'H': /* 16-bit DMA channel */
      case 'h':
	SaveChar = *EnvString;
	EnvString++;
	Buffer[0] = *EnvString;
	EnvString++;

	if (*EnvString >= '0' && *EnvString <= '9')
	{
	  Buffer[1] = *EnvString; /* DMA Channel No. is 2 digits */
	  Buffer[2] = NULL;
	  EnvString++;
	}
	else
	  Buffer[1] = NULL;       /* DMA Channel No. is 1 digit */

	if (SaveChar == 'D' || SaveChar == 'd')
	  gDMAChan8Bit  = atoi(Buffer);  /* 8-Bit DMA channel */
	else
	  gDMAChan16Bit = atoi(Buffer);  /* 16-bit DMA channel */

	DMAChannelNotFound = FALSE;
      break;


      case 'I':  /* IRQ number */
      case 'i':
	EnvString++;
	Buffer[0] = *EnvString;
	EnvString++;

	if (*EnvString >= '0' && *EnvString <= '9')
	{
	  Buffer[1] = *EnvString; /* IRQ No. is 2 digits */
	  Buffer[2] = NULL;
	  EnvString++;
	}
	else
	  Buffer[1] = NULL;       /* IRQ No. is 1 digit */

	gIRQNumber  = atoi(Buffer);
	IRQNotFound = FALSE;
      break;


      default:
	EnvString++;
      break;
    }

  } while (*EnvString != NULL);

  if (DMAChannelNotFound || IOPortNotFound || IRQNotFound)
    return(FAIL);

  /*--- Get the DSP version number.  The next read from the DSP will ---*/
  /*--- return the major version number.  The following read will    ---*/
  /*--- return the minor version number.                             ---*/

  /*** this function should check return value of ResetDSP -- it can fail ***/

  ResetDSPValue = ResetDSP();
  if (ResetDSPValue == FAIL)
    return(FAIL);

  DSPWrite(DSP_GET_VERSION);

  Major = DSPRead();  /* Read Major DSP version no. */
  Minor = DSPRead();  /* Read Minor DSP version no. */
  gDSPVersion = (Major << 8) | Minor;

  return(SUCCESS);
}


/*
** FUNCTION: DSPRead()
**
** DESCRIPTION: Reads a value from the DSP Read Port.
*/

short int DSPRead(void)
{
  int count = 0;

  /* Wait until DSP is ready before reading from the DSP. */

  while ((inp(gBaseIOPort + DSP_DATA_AVAIL) & 0x80) == 0)
  {
    if (count++ > 1000) return(0);
  }

  /* Return value read from the Read Port. */

  return(inp(gBaseIOPort + DSP_READ_PORT));
}


/*
** FUNCTION: DSPWrite()
**
** DESCRIPTION: Writes the value passed to this function to the DSP Write
**              Port.
*/

void DSPWrite(short int WriteValue)
{
  int count = 0;

  /* Wait until DSP is ready before writing to the DSP. */

  while ((inp(gBaseIOPort + DSP_WRITE_PORT) & 0x80) != 0)
  {
    if (count++ > 1000) return;
  }

  outp(gBaseIOPort + DSP_WRITE_PORT, WriteValue);
}


/*
** FUNCTION: ResetDSP()
**
** DESCRIPTION: Self explanatory
*/

char ResetDSP(void)
{
  int count = 0;

  outp(gBaseIOPort + DSP_RESET_PORT, 0x0001);  /* Write "1" to Reset Port. */
  delay(10);                                  /* Wait 10 mS.              */
  outp(gBaseIOPort + DSP_RESET_PORT, 0x0000);  /* Write "0" to Reset port. */

  /* Wait until data is available. (Wait while BIT-7 == 0.) */

  while ((inp(gBaseIOPort + DSP_DATA_AVAIL) & 0x80) == 0)
  {
    if (count++ > 1000) return(FAIL);
  }

  if (inp(gBaseIOPort + DSP_READ_PORT) == DSP_READY)
    return(SUCCESS);
  return(FAIL);
}


/*
** FUNCTION: AllocateDMABuffer()
**
** DESCRIPTION : Allocate memory for the DMA buffer.  After memory is
**               allocated for the buffer, call OnSamePage() to verify
**               that the entire buffer is located on the same page.
**               If the buffer crosses a page boundary, allocate another
**               buffer. Continue this process until the DMA buffer resides
**               entirely within the same page.
**
**               For every malloc() called, save a pointer that points to
**               the block of memory allocated.  Deallocate ALL memory blocks
**               allocated that cross a page boundary.  Once a memory block
**               is allocated that does NOT cross a page boudary, this block
**               will be used for the DMA buffer--any previously allocated
**               memory blocks will be deallocated.
**
** ENTRY: **DMABuffer is the address of the pointer that will point to
**        the memory allocated.
**
** EXIT: If a buffer is succesfully allocated, *DMABuffer will point to
**       the buffer and the physical address of the buffer pointer will
**       be returned.
**
**       If a buffer is NOT successfully allocated, return FAIL.
*/

unsigned long int AllocateDMABuffer(unsigned char **DMABuffer,
				    unsigned short int *DMABufSize)
{
  unsigned char     BufferNotAllocated = TRUE,
		    Done = FALSE,
		   *PtrAllocated[50];
  short int         i,
		    Index = 0;
  unsigned long int PhysAddress;

  /*--- BUMP *DMABufSize UP TO NEXT 8-BYTE BOUNDARY. -------------------*/

  if (*DMABufSize == 0 || *DMABufSize % 8)
    *DMABufSize = *DMABufSize + (8 - (*DMABufSize % 8));

  do
  {
    *DMABuffer = (unsigned char *) malloc(*DMABufSize);

    if (*DMABuffer != NULL)
    {
      /*--- Save the ptr for every malloc() performed ---*/

      PtrAllocated[Index] = *DMABuffer;
      Index++;

      /*--- If entire buffer is within one page, we're out of here! ---*/

      PhysAddress = OnSamePage(*DMABuffer, *DMABufSize);
      if (PhysAddress != FAIL)
      {
	BufferNotAllocated = FALSE;
	Done = TRUE;
      }
    }
    else
      Done = TRUE;  /* malloc() couldn't supply requested memory */

  } while (!Done);


  if (BufferNotAllocated)
  {
    Index++;             /* Incr. Index so most recent malloc() gets free()d */
    PhysAddress = FAIL;  /* return FAIL */
  }

  /*--- Deallocate all memory blocks crossing a page boundary ---*/

  for (i= 0; i < Index - 1; i++)
    free(PtrAllocated[i]);

  return(PhysAddress);
}


/*
** FUNCTION: OnSamePage()
**
** DESCRIPTION: Check the memory block pointed to by the parameter
**              passed to make sure the entire block of memory is on the
**              same page.  If a buffer DOES cross a page boundary,
**              return FAIL. Otherwise, return the physical address
**              of the beginning of the DMA buffer.
*/

unsigned long int OnSamePage(unsigned char *DMABuffer,
			     unsigned short int DMABufSize)
{
  unsigned long int BegBuffer;

  /*----- Obtain the physical address of DMABuffer -----*/

  BegBuffer = ((unsigned long) (FP_SEG(DMABuffer)) << 4) +
	       (unsigned long) FP_OFF(DMABuffer);

  if ((BegBuffer >> 16) == ((BegBuffer + DMABufSize - 1) >> 16))
    return(BegBuffer);		/* Entire buffer IS on same page! */
  return(FAIL);			/* Entire buffer NOT on same page.  Thanks Intel! */
}


/*
** FUNCTION: ManageVolume(char Command)
*/

void ManageVolume(char Command)
{
static int MasterVolume;

  if (gDSPVersion < 0x0300)         /* Only SB 2 with CD has a mixer. */
    outp(gBaseIOPort + 4, 0x0002);  /* Select master volume reg. */
  else  			    /* SB Pro or SB16/AWE32 mixer. */
    outp(gBaseIOPort + 4, 0x0022);  /* Select master volume reg. */

  if (Command == REMEMBER_VOLUME)
    MasterVolume = inp(gBaseIOPort + 5);  /* Save master volume. */
  else if (Command == RESTORE_VOLUME)
    outp(gBaseIOPort + 5, MasterVolume);  /* Restore master volume. */
  else if (Command == KILL_VOLUME)
    outp(gBaseIOPort + 5, 0x0000);        /* KILL the volume. */
}


/*
** FUNCTION: ContinueDMA()
**
** DESCRIPTION: Continues the DMA transfer that was halted.  The DMA
**              tranfer can be halted by calling PauseDMA().
**
** SEE ALSO: PauseDMA()
*/

void ContinueDMA(void)
{
  if (gDSPVersion >= 0x0200 && gDSPVersion < 0x0400)
    ManageVolume(RESTORE_VOLUME);

  if (gHighSpeed) return;	/* can't reprogram DSP if high speed mode */

  DSPWrite(0x00D4);		/* Continue SB 8-bit DMA xfer. */
}


/*
** FUNCTION: PauseDMA()
**
** DESCRIPTION: Halts the DMA tranfer.  The DMA tranfer can be resumed by
**              calling ContinueDMA().
**
** SEE ALSO: ContinueDMA()
*/

void PauseDMA(void)
{
  if (gDSPVersion >= 0x0200 && gDSPVersion < 0x0400)
  {
    ManageVolume(REMEMBER_VOLUME);
    ManageVolume(KILL_VOLUME);
  }

  if (gHighSpeed) return;	/* can't reprogram DSP if high speed mode */

  DSPWrite(0x00D0);		/* Pause SB 8-bit DMA xfer. */
}
