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
** Mar 23, 1998 -- Have initialization wait for Windows 95 to finish with sound.
** (0.96)
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

short int sbBaseIOPort;
short int sbDMAChan8Bit;
short int sbDMAChan16Bit;
short int sbDSPVersion;
unsigned char sbIRQNumber;


/*
** Properties of sound being played
*/

typedef struct _SOUNDSTYLE
{
  unsigned char      BitsPerSample, /* 8 or 16 */
		     Channels;      /* MONO = 1, STEREO = 2 */
  unsigned short int SoundFormat,   /* Determines BitsPerSample in old .VOC */
		     TimeConstant;  /* Old .VOC version of SampPerSec */
  signed long int    SampPerSec;
} SOUNDSTYLE;


typedef unsigned long int DWORD;


/*
** global variables
*/

SOUNDSTYLE gSoundStyle;

unsigned short int gDMABufSize,
		   gHighSpeed,
		   gIRQMaskSave0,
		   gIRQMaskSave1;

unsigned char	gDMABufNowPlaying;

signed long int gBytesLeftToPlay;

unsigned char     *DMABuf, *MallocDMABuf;
long int DMABufPhysAddr;

void interrupt (*gOldISRFuncPtr)(void);




/*
** SoundBlaster functions
*/

char GetBlastEnv(void),
     ResetDSP(void);

short int DSPRead(void);

unsigned long int AllocateDMABuffer(),
		  OnSamePage(unsigned char *, unsigned short int);

extern void interrupt DmaISR(void); 
void ContinueDMA(unsigned char),
     DSPWrite(short int),
     KillVolume(void),
     PauseDMA(unsigned char),
     ProgramDMA(unsigned long int, SOUNDSTYLE *, unsigned short int),
     ProgramDSP(unsigned short int, SOUNDSTYLE *, unsigned char),
     RestoreOldISR(void),
     RestoreOrRememberVolume(char),
     SetDmaISR(void),
     SetMixer(void);


/*
** FUNCTION: ProgramDMA()
**
** DESCRIPTION:  This function programs the DMA chip to use a single
**               8-bit or 16-bit DMA channel (specified by the BLASTER
**               environment string) for audio transfer.  It also programs
**               the size of the DMA transfer and the DMA buffer address
**               used for the audio transfer.
*/

void ProgramDMA(unsigned long int DMABufPhysAddr, SOUNDSTYLE *SoundStyle,
		unsigned short int Count)
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

  if (SoundStyle->BitsPerSample == 8)  /* 8-BIT FILE */
  {
    switch(sbDMAChan8Bit)
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

    outp(DMA8_MASK_REG, sbDMAChan8Bit | 4);    /* Disable DMA */
    outp(DMA8_FF_REG, 0x0000);                         /* Clear F-F */
    outp(DMA8_MODE_REG, sbDMAChan8Bit | 0x58); /* 8-bit AI */
    outp(DMACount, ((Count - 1) & 0xFF));              /* LO byte */
    outp(DMACount, ((Count - 1) >> 8));                /* HI byte */
  }
  else  /* 16-BIT FILE */
  {
    switch(sbDMAChan16Bit)
    {
      case 5:
	DMAAddr  = 0x00C4;
	DMACount = 0x00C6;
	DMAPage  = 0x008B;
      break;

      case 6:
	DMAAddr  = 0x00C8;
	DMACount = 0x00CA;
	DMAPage  = 0x0089;
      break;

      case 7:
	DMAAddr  = 0x00CC;
	DMACount = 0x00CE;
	DMAPage  = 0x008A;
      break;
    }

    /* Offset for 16-bit DMA must be calculated different than 8-bit. */
    /* Shift Offset 1 bit right.  Then copy LSBit of Page to MSBit of Offset. */

    Temp = Page & 0x0001;  /* Get LSBit of Page and... */
    Temp <<= 15;           /* move it to MSBit of Temp. */
    Offset >>= 1;          /* Divide Offset by 2. */
    Offset &= 0x7FFF;      /* Clear MSBit of Offset. */
    Offset |= Temp;        /* Put LSBit of Page into MSBit of Offset. */

    outp(DMA16_MASK_REG, (sbDMAChan16Bit - 4) | 4);    /* Disable DMA */
    outp(DMA16_FF_REG, 0x0000) ;                               /* Clear F-F */
    outp(DMA16_MODE_REG, (sbDMAChan16Bit - 4) | 0x58); /* 16-bit AI */
    outp(DMACount, ((Count/2 - 1) & 0xFF));                    /* LO byte */
    outp(DMACount, ((Count/2 - 1) >> 8));                      /* HI byte */
  }

  /* Program the starting address of the DMA buffer. */

  outp(DMAPage, Page);             /* Page number of DMA buffer. */
  outp(DMAAddr, Offset & 0x00FF);  /* LO byte offset address of DMA buffer. */
  outp(DMAAddr, (Offset >> 8));    /* HI byte offset address of DMA buffer. */

  /* Reenable 8-bit or 16-bit DMA. */

  if (SoundStyle->BitsPerSample == 8)
    outp(DMA8_MASK_REG,  sbDMAChan8Bit);
  else
    outp(DMA16_MASK_REG, sbDMAChan16Bit - 4);

  return;
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

void ProgramDSP(unsigned short int Count, SOUNDSTYLE *SoundStyle,
		unsigned char DMAMode)
{
  unsigned char Card;
  short int     Command,
		Mode;

  if (gHighSpeed == TRUE)  /* Once in high-speed mode, DSP can only be reset! */
    return;

  /* Make sure Count is >= 2, so when the DSP is programmed for a block */
  /* tranfer, Count doesn't wrap around to a large number when 1 is */
  /* subtracted from it. */

  if (Count <= 1)
    Count = 2;

  /*--- DETERMINE SOUND BLASTER CARD TYPE ----------------------------*/

  if (sbDSPVersion >= 0x0400)       /* DSP version >= 4.00 */
    Card = SB16;
  else if (sbDSPVersion >= 0x0300)  /* DSP version = 3.xx */
  {
    /* Set SBPRO mixer register default to MONO, Output filter to OFF. */

    outp(sbBaseIOPort + 4, 0x000E);  /* Select mixer reg. 0x0E. */
    outp(sbBaseIOPort + 5, 0x0000);  /* MONO, Output filter off. */
    Card = SBPRO;
  }
  else if (sbDSPVersion >= 0x0201)  /* 2.01 <= DSP version < 3.00 */
    Card = SB2_HI;
  else if (sbDSPVersion == 0x0200)  /* DSP version = 2.00 */
    Card = SB2_LO;

  /*--- FILE IS 8-BIT ADPCM PLAYBACK. IN THIS CASE, ALL SB CARDS  ------*/
  /*--- ARE PROGRAMMED IDENTICALLY.  DETERMINE THE COMMAND.       ------*/

  if (SoundStyle->SoundFormat > 0 && SoundStyle->SoundFormat < 4)
  {
    switch(SoundStyle->SoundFormat)
    {
      case 1:  /* 8-bit 2:1 compression (4-bit ADPCM) */
	Command = 0x0074;  /* default to single-cycle */
      break;

      case 2:  /* 8-bit 8:3 compression (2.6-bit ADPCM) */
	Command = 0x0076;  /* default to single-cycle */
      break;

      case 3:  /* 8-bit 4:1 compression (2-bit ADPCM) */
	Command = 0x0016;  /* default to single-cycle */
      break;
    }

    if (DMAMode == AUTO_INIT)
      Command |= 0x0009;   /* Set to auto-init mode. */
  }
  else
  {
    /*--- FILE IS 8-BIT OR 16-BIT UNCOMPRESSED AUDIO.  PROGRAM EACH ----*/
    /*--- SOUND BLASTER CARD DIFFERENTLY.                           ----*/

    switch(Card)
    {
      case SB16:

	/* Program sample rate HI and LO byte. */
/*
	DSPWrite(0x0041);
	DSPWrite((SoundStyle->SampPerSec & 0xFF00) >> 8);
	DSPWrite((SoundStyle->SampPerSec & 0xFF));
*/
	/*--- DETERMINE 8-bit OR 16-bit, MONO OR STEREO ----------------*/

	if (SoundStyle->BitsPerSample == 8)
	{
	  /* do 8-bit sound the old-fashioned way (JS) */
          DSPWrite(0x0040);  /* Program Time Constant */
          DSPWrite(SoundStyle->TimeConstant);

	  Command = 0x00C0;  /* 8-bit transfer (default: single-cycle, D/A) */

	  if (SoundStyle->Channels == 1)
	    Mode = 0x0000;   /* MONO, unsigned PCM data */
	  else
	    Mode = 0x0020;   /* STEREO, unsigned PCM data */
	}
	else  /* 16-BIT AUDIO */
	{
          /* do 16-bit sound the modern way (JS)*/

	  /* Program sample rate HI and LO byte. */
          DSPWrite(0x0041);
	  DSPWrite((SoundStyle->SampPerSec & 0xFF00) >> 8);
	  DSPWrite((SoundStyle->SampPerSec & 0xFF));

	  Command = 0x00B0;  /* 16-bit transfer (default: single-cycle, D/A) */
	  Count  /= 2;       /* Set Count to transfer 16-bit words. */

	  if (SoundStyle->Channels == 1)
	    Mode = 0x0010;   /* MONO, signed PCM data */
	  else
	    Mode = 0x0030;   /* STEREO, signed PCM data */
	}

	/*--- CHANGE COMMAND TO AUTO-INIT, IF NEEDED. ------------------*/

	if (DMAMode == AUTO_INIT)
	  Command |= 0x0004;     /* Auto-init */


	/*--- PROGRAM THE DSP CHIP (BEGIN DMA TRANSFER) AND RETURN! ----*/

	DSPWrite(Command);
	DSPWrite(Mode);
	DSPWrite((Count - 1) & 0xFF);  /* LO byte */
	DSPWrite((Count - 1) >> 8);    /* HI byte */
      return;    /* RETURN! */


      case SBPRO:
	DSPWrite(0x00A0);  /* Default to MONO. */

	if (SoundStyle->Channels == 2)
	{
	  /* HI-SPEED, STEREO */

	  gHighSpeed = TRUE;

	  DSPWrite(0x00A8);  /* STEREO MODE */
	  outp(sbBaseIOPort + 4, 0x000E);  /* Select mixer reg. 0x0E. */
	  outp(sbBaseIOPort + 5, 0x0002);  /* STEREO, output filter off. */

	  if (DMAMode == AUTO_INIT)
	    Command = 0x0090;  /* HIGH-SPEED, AUTO-INIT MODE */
	  else
	    Command = 0x0091;  /* HIGH-SPEED, SINGLE-CYCLE MODE */
	}
	else if (SoundStyle->SampPerSec >= 23000)
	{
	  /* HI-SPEED, MONO */

	  gHighSpeed = TRUE;

	  if (DMAMode == AUTO_INIT)
	    Command = 0x0090;  /* HIGH-SPEED, AUTO-INIT MODE */
	  else
	    Command = 0x0091;  /* HIGH-SPEED, SINGLE-CYCLE MODE */
	}
	else if (DMAMode == AUTO_INIT)
	  Command = 0x001C;   /* NORMAL, AUTO-INIT */
	else
	  Command = 0x0014;   /* NORMAL, SINGLE-CYCLE */
      break;


      case SB2_HI:
	if (SoundStyle->SampPerSec > 13000 || SoundStyle->Channels == 2)
	{
	  /* HI-SPEED */

	  gHighSpeed = TRUE;

	  if (DMAMode == AUTO_INIT)
	    Command = 0x0090;  /* HIGH-SPEED, AUTO-INIT MODE */
	  else
	    Command = 0x0091;  /* HIGH-SPEED, SINGLE-CYCLE MODE */
	}
	else if (DMAMode == AUTO_INIT)
	  Command = 0x001C;  /* NORMAL, MONO, AUTO-INIT */
	else
	  Command = 0x0014;  /* NORMAL, MONO, SINGLE-CYCLE */
      break;


      case SB2_LO:  /* DSP VERSION == 2.00.  HIGH-SPEED MODE NOT AVAILABLE. */
	if (DMAMode == AUTO_INIT)
	  Command = 0x001C;  /* NORMAL, MONO, AUTO-INIT */
	else
	  Command = 0x0014;  /* NORMAL, MONO, SINGLE-CYCLE */
      break;
    }
  }

  /*--- IF FILE IS 8-BIT ADPCM (REGARDLESS OF CARD TYPE), OR CARD IS ---*/
  /*--- AN 8-BIT AUDIO CARD (DSP VERSION < 4.xx), BEGIN DMA TRANFER. ---*/

  DSPWrite(0x00D1);  /* Turn speaker on. */
  DSPWrite(0x0040);  /* Program Time Constant */
  DSPWrite(SoundStyle->TimeConstant);

  /*--- NOTE: If in high-speed mode, single-cycle DMA is programmed ----*/
  /*--- using the same initial DSP command as auto-init (0x0048).   ----*/

  if (DMAMode == AUTO_INIT || gHighSpeed == TRUE)
  {
    /* Program block tranfer size LO and HI byte and begin tranfer. */

    DSPWrite(0x0048);
    DSPWrite((Count - 1) & 0x00FF);  /* LO byte */
    DSPWrite((Count - 1) >> 8);      /* HI byte */
    DSPWrite(Command);               /* Begin Xfer */
  }
  else  /* DMAMode == SINGLE_CYCLE  If mode is high-speed, execute above code. */
  {
    /* Program size of last block and begin transfer. */

    DSPWrite(Command);
    DSPWrite((Count - 1) & 0x00FF);  /* LO byte */
    DSPWrite((Count - 1) >> 8);      /* HI byte */
  }

  return;
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
**
**              Then, get the DSP version of the Sound Blaster DSP chip.
**              This is used to determine the Sound Blaster's capabilities.
**
** RETURN: FAIL - BLASTER environment string is not found or any of
**                the BLASTER structure members aren't found.
**
**         SUCCESS - All members of BLASTER struct are found in the
**                   BLASTER environment string.
*/

char GetBlastEnv(void)
{
  char  ch;

  char  Buffer[5],
	DMAChannelNotFound = TRUE,
       *EnvString,
	IOPortNotFound     = TRUE,
	IRQNotFound        = TRUE,
	SaveChar;

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
	sbBaseIOPort = 0;
	for (i -= 1; i >= 0; i--)
	{
	  if (Buffer[i] >= '0' && Buffer[i] <= '9')
	    digit = Buffer[i] - '0';
	  else if (Buffer[i] >= 'A' && Buffer[i] <= 'F')
	    digit = Buffer[i] - 'A' + 10;
	  else if (Buffer[i] >= 'a' && Buffer[i] <= 'f')
	    digit = Buffer[i] - 'a' + 10;

	  sbBaseIOPort += digit * multiplier;
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
	  sbDMAChan8Bit  = atoi(Buffer);  /* 8-Bit DMA channel */
	else
	  sbDMAChan16Bit = atoi(Buffer);  /* 16-bit DMA channel */

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

	sbIRQNumber  = atoi(Buffer);
	IRQNotFound = FALSE;
      break;


      default:
	EnvString++;
      break;
    }

  } while (*EnvString != NULL);

  if (DMAChannelNotFound || IOPortNotFound || IRQNotFound)
    return(FAIL);

  /*** this function should check return value of ResetDSP -- it can fail ***/

  printf("\nWaiting for Sound Blaster...\n\n");
  printf("Press <esc> to exit, any other key to continue with PC speaker sound.\n");
  while (1)
  {
    if (ResetDSP() == FAIL)
    {
      if (kbhit())
      {
        ch = getch();
        if (ch == 27) 
          exit(0);	/* escape pressed */
        else 
          return(FAIL);
      }
    }
    else
      break;
  }

  /*--- Get the DSP version number.  The next read from the DSP will ---*/
  /*--- return the major version number.  The following read will    ---*/
  /*--- return the minor version number.                             ---*/

  DSPWrite(DSP_GET_VERSION);

  Major = DSPRead();  /* Read Major DSP version no. */
  Minor = DSPRead();  /* Read Minor DSP version no. */
  sbDSPVersion = (Major << 8) | Minor;

  return(SUCCESS);
}


/*
** FUNCTION: AllocateDMABuffer()
**
** DESCRIPTION : Allocate memory for the DMA buffer.  
**               Get twice as much as we need.
**               If first half of buffer crosses a page boundary use second half.
**
**       If a buffer is NOT successfully allocated, return FAIL.
*/

unsigned long int AllocateDMABuffer()
{
  MallocDMABuf = (unsigned char *) malloc((gDMABufSize+1)*2);
  if (MallocDMABuf == NULL) return(FAIL);
  DMABuf = MallocDMABuf;
  DMABufPhysAddr = OnSamePage(DMABuf, gDMABufSize); 
  if (DMABufPhysAddr == FAIL)
  {
    DMABuf += gDMABufSize;
    DMABufPhysAddr = OnSamePage(DMABuf, gDMABufSize); 
  }
  return(DMABufPhysAddr);
}


/*
** FUNCTION: OnSamePage()
**
** DESCRIPTION: Check the memory block pointed to by the parameter
**              passed to make sure the entire block of memory is on the
**              same page.  If a buffer DOES cross a 6page boundary,
**              return FAIL. Otherwise, return the physical address
**              of the beginning of the DMA buffer.
**
** ENTRY: *DMABuffer - Points to beginning of DMA buffer.
**
** EXIT: If the buffer is located entirely within one page, return the
**       physical address of the buffer pointer.  Otherwise return FAIL.
*/

unsigned long int OnSamePage(unsigned char *DMABuffer,
			     unsigned short int DMABufSize)
{
  unsigned long int BegBuffer,
		    EndBuffer,
		    PhysAddress;

  /*----- Obtain the physical address of DMABuffer -----*/

  BegBuffer = ((unsigned long) (FP_SEG(DMABuffer)) << 4) +
	       (unsigned long) FP_OFF(DMABuffer);
  EndBuffer   = BegBuffer + DMABufSize - 1;
  PhysAddress = BegBuffer;

  /*-- Get page numbers for start and end of DMA buffer. --*/

  BegBuffer >>= 16;
  EndBuffer >>= 16;

  if (BegBuffer == EndBuffer)
    return(PhysAddress);  /* Entire buffer IS on same page! */
  return(FAIL); /* Entire buffer NOT on same page.  Thanks Intel! */
}
