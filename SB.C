/*
** sb.c -- Sound Blaster driver code for z26
**
** based on dmav.c by Tom Bouril, Creative Technologies Ltd.  (October 1994)
**
** Jan 7, 1998 -- Added shortened interrupt handler for 8-bit DMA only.
**                This was partly needed because old SoundBlasters don't have a mixer register.
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

typedef struct _BLASTER
{
  short int BaseIOPort,
	    DMAChan8Bit,
	    DMAChan16Bit,
	    DSPVersion,
	    IRQNumber,
	    MIDIPort;
} BLASTER;


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

BLASTER gBlaster;

SOUNDSTYLE gSoundStyle;

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

char GetBlastEnv(BLASTER *Blast),
     ResetDSP(short int);

short int DSPRead(short int);

unsigned long int AllocateDMABuffer(unsigned char **, unsigned short int *),
		  OnSamePage(unsigned char *, unsigned short int);

void interrupt DmaISR(void);
void ContinueDMA(unsigned char),
     DSPWrite(short int, short int),
     KillVolume(void),
     PauseDMA(unsigned char),
     ProgramDMA(unsigned long int, SOUNDSTYLE *, unsigned short int),
     ProgramDSP(unsigned short int, SOUNDSTYLE *, unsigned char),
     RestoreOldISR(BLASTER *),
     RestoreOrRememberVolume(char),
     SetDmaISR(BLASTER *),
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
    switch(gBlaster.DMAChan8Bit)
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

    outp(DMA8_MASK_REG, gBlaster.DMAChan8Bit | 4);    /* Disable DMA */
    outp(DMA8_FF_REG, 0x0000);                         /* Clear F-F */
    outp(DMA8_MODE_REG, gBlaster.DMAChan8Bit | 0x58); /* 8-bit AI */
    outp(DMACount, ((Count - 1) & 0xFF));              /* LO byte */
    outp(DMACount, ((Count - 1) >> 8));                /* HI byte */
  }
  else  /* 16-BIT FILE */
  {
    switch(gBlaster.DMAChan16Bit)
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

    outp(DMA16_MASK_REG, (gBlaster.DMAChan16Bit - 4) | 4);    /* Disable DMA */
    outp(DMA16_FF_REG, 0x0000) ;                               /* Clear F-F */
    outp(DMA16_MODE_REG, (gBlaster.DMAChan16Bit - 4) | 0x58); /* 16-bit AI */
    outp(DMACount, ((Count/2 - 1) & 0xFF));                    /* LO byte */
    outp(DMACount, ((Count/2 - 1) >> 8));                      /* HI byte */
  }

  /* Program the starting address of the DMA buffer. */

  outp(DMAPage, Page);             /* Page number of DMA buffer. */
  outp(DMAAddr, Offset & 0x00FF);  /* LO byte offset address of DMA buffer. */
  outp(DMAAddr, (Offset >> 8));    /* HI byte offset address of DMA buffer. */

  /* Reenable 8-bit or 16-bit DMA. */

  if (SoundStyle->BitsPerSample == 8)
    outp(DMA8_MASK_REG,  gBlaster.DMAChan8Bit);
  else
    outp(DMA16_MASK_REG, gBlaster.DMAChan16Bit - 4);

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

  if (gBlaster.DSPVersion >= 0x0400)       /* DSP version >= 4.00 */
    Card = SB16;
  else if (gBlaster.DSPVersion >= 0x0300)  /* DSP version = 3.xx */
  {
    /* Set SBPRO mixer register default to MONO, Output filter to OFF. */

    outp(gBlaster.BaseIOPort + 4, 0x000E);  /* Select mixer reg. 0x0E. */
    outp(gBlaster.BaseIOPort + 5, 0x0000);  /* MONO, Output filter off. */
    Card = SBPRO;
  }
  else if (gBlaster.DSPVersion >= 0x0201)  /* 2.01 <= DSP version < 3.00 */
    Card = SB2_HI;
  else if (gBlaster.DSPVersion == 0x0200)  /* DSP version = 2.00 */
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

	DSPWrite(gBlaster.BaseIOPort, 0x0041);
	DSPWrite(gBlaster.BaseIOPort, (SoundStyle->SampPerSec & 0xFF00) >> 8);
	DSPWrite(gBlaster.BaseIOPort, (SoundStyle->SampPerSec & 0xFF));

	/*--- DETERMINE 8-bit OR 16-bit, MONO OR STEREO ----------------*/

	if (SoundStyle->BitsPerSample == 8)
	{
	  Command = 0x00C0;  /* 8-bit transfer (default: single-cycle, D/A) */

	  if (SoundStyle->Channels == 1)
	    Mode = 0x0000;   /* MONO, unsigned PCM data */
	  else
	    Mode = 0x0020;   /* STEREO, unsigned PCM data */
	}
	else  /* 16-BIT AUDIO */
	{
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

	DSPWrite(gBlaster.BaseIOPort, Command);
	DSPWrite(gBlaster.BaseIOPort, Mode);
	DSPWrite(gBlaster.BaseIOPort, (Count - 1) & 0xFF);  /* LO byte */
	DSPWrite(gBlaster.BaseIOPort, (Count - 1) >> 8);    /* HI byte */
      return;    /* RETURN! */


      case SBPRO:
	DSPWrite(gBlaster.BaseIOPort, 0x00A0);  /* Default to MONO. */

	if (SoundStyle->Channels == 2)
	{
	  /* HI-SPEED, STEREO */

	  gHighSpeed = TRUE;

	  DSPWrite(gBlaster.BaseIOPort, 0x00A8);  /* STEREO MODE */
	  outp(gBlaster.BaseIOPort + 4, 0x000E);  /* Select mixer reg. 0x0E. */
	  outp(gBlaster.BaseIOPort + 5, 0x0002);  /* STEREO, output filter off. */

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

  DSPWrite(gBlaster.BaseIOPort, 0x00D1);  /* Turn speaker on. */
  DSPWrite(gBlaster.BaseIOPort, 0x0040);  /* Program Time Constant */
  DSPWrite(gBlaster.BaseIOPort, SoundStyle->TimeConstant);

  /*--- NOTE: If in high-speed mode, single-cycle DMA is programmed ----*/
  /*--- using the same initial DSP command as auto-init (0x0048).   ----*/

  if (DMAMode == AUTO_INIT || gHighSpeed == TRUE)
  {
    /* Program block tranfer size LO and HI byte and begin tranfer. */

    DSPWrite(gBlaster.BaseIOPort, 0x0048);
    DSPWrite(gBlaster.BaseIOPort, (Count - 1) & 0x00FF);  /* LO byte */
    DSPWrite(gBlaster.BaseIOPort, (Count - 1) >> 8);      /* HI byte */
    DSPWrite(gBlaster.BaseIOPort, Command);               /* Begin Xfer */
  }
  else  /* DMAMode == SINGLE_CYCLE  If mode is high-speed, execute above code. */
  {
    /* Program size of last block and begin transfer. */

    DSPWrite(gBlaster.BaseIOPort, Command);
    DSPWrite(gBlaster.BaseIOPort, (Count - 1) & 0x00FF);  /* LO byte */
    DSPWrite(gBlaster.BaseIOPort, (Count - 1) >> 8);      /* HI byte */
  }

  return;
}


/*
** FUNCTION:  DmaISR()
**
** DESCRIPTION: If the interrupt was a DMA generated by the Sound Blaster,
**              acknowledge the interrupt, update the global variables,
**              and send the end-of-interrupt command(s).
**
**              If the interrupt was NOT generated by the Sound Blaster,
**              call the ISR (gOldISRFuncPtr) saved by SetDMAISR() or
**              return.
*/

/*
** a simplified interrupt handler for 8-bit DMA only
*/

void interrupt DmaISR(void)
{
  inp(gBlaster.BaseIOPort + 0x000E);	/* acknowledge interrupt */

  gDMABufNowPlaying ^= 1;  /* Keep track of which 1/2 DMA buffer is playing. */

  /* Send end-of-interrupt command(s). */

  if (gBlaster.IRQNumber > 7)
    outp(PIC1_COMMAND_REG, END_OF_INTERRUPT);

  outp(PIC0_COMMAND_REG, END_OF_INTERRUPT);

  return;
}

#ifdef compile_old_code
void interrupt xDmaISR(void)
{
  unsigned char InterruptStatus;

  if (gBlaster.DSPVersion < 0x0300)  /* DSP version < 3.xx */
  {
    /* Early SoundBlasters don't have mixer interrupt register. */
    /* Assume 8-bit DMA and don't chain interrupts. (JS) */

    inp(gBlaster.BaseIOPort + 0x000E);	/* acknowledge interrupt */
  }
  else
  {
    /* Read Sound Blaster mixer interrupt register to determine interrupt type. */

    outp(gBlaster.BaseIOPort + 4, 0x0082);           /* Select interrupt reg. */
    InterruptStatus = inp(gBlaster.BaseIOPort + 5);  /* Read interrupt reg. */

    if (InterruptStatus & 0x01)            /* Interrupt is from 8-bit DMA. */
      inp(gBlaster.BaseIOPort + 0x000E);  /* Acknowledge the interrupt. */
    else if (InterruptStatus & 0x02)       /* Interrupt is from 16-bit DMA. */
      inp(gBlaster.BaseIOPort + 0x000F);  /* Acknowledge the interrupt. */
    else
    {
      /* Interrupt is NOT SB DMA.  Call ISR saved by SetDmaISR() or return. */

      if (gOldISRFuncPtr)
        (*gOldISRFuncPtr)();
      return;
    }
  }

/* gBytesLeftToPlay  -= (long) (gDMABufSize / 2); */

  gDMABufNowPlaying ^= 1;  /* Keep track of which 1/2 DMA buffer is playing. */

  /* Send end-of-interrupt command(s). */

  if (gBlaster.IRQNumber > 7)
    outp(PIC1_COMMAND_REG, END_OF_INTERRUPT);

  outp(PIC0_COMMAND_REG, END_OF_INTERRUPT);

  return;
}
#endif

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

void RestoreOldISR(BLASTER *BlastSet)
{
  short int IntVectorNumber;

  disable();  /* Temporarily disable interrupts */

  outp(PIC0_MASK_REG, gIRQMaskSave0);    /* Restore IRQ mask for IRQs 0 to 7. */

  if (BlastSet->IRQNumber > 7)
  {
    outp(PIC1_MASK_REG, gIRQMaskSave1);  /* Restore IRQ mask for IRQs 8 to 15. */
    IntVectorNumber = BlastSet->IRQNumber - 8 + 0x70;
  }
  else  /* BlastSet->IRQNumber is 0 to 7. */
    IntVectorNumber = BlastSet->IRQNumber + 8;

  /* Restore the old ISR to the interrupt vector number. */

  setvect(IntVectorNumber, gOldISRFuncPtr);

  enable();   /* Enable interrupts */
  return;
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

void SetDmaISR(BLASTER *BlastSet)
{
  short int IntVectorNum,
	    IRQMaskNew;

  disable();  /* Temporarily disable interrupts. */

  /*--- Save current interrupt masks and set the new ones. -------------*/

  gIRQMaskSave0 = inp(PIC0_MASK_REG);    /* Save IRQ 0 to 7 mask. */
  if (BlastSet->IRQNumber > 7)
  {
    IntVectorNum  = BlastSet->IRQNumber - 8 + 0x70;
    gIRQMaskSave1 = inp(PIC1_MASK_REG);  /* Save IRQ 8 to 15 mask. */

    /* Set new IRQ mask for IRQs 8 to 15. */

    IRQMaskNew = ~(((short int) 0x0001) << (BlastSet->IRQNumber - 8));
    outp(PIC1_MASK_REG, gIRQMaskSave1 & IRQMaskNew);

    /* Setting IRQ mask 2 on PIC 0 enables IRQs 8 to 15 on PIC 1. */

    outp(PIC0_MASK_REG, gIRQMaskSave0 & ~0x0004);
  }
  else  /* BlastSet->IRQNumber is 0 to 7. */
  {
    IntVectorNum = BlastSet->IRQNumber + 8;

    /* Set new IRQ mask for IRQs 0 to 7. */

    IRQMaskNew = ~(((short int) 0x0001) << BlastSet->IRQNumber);
    outp(PIC0_MASK_REG, gIRQMaskSave0 & IRQMaskNew);
  }

  /*--- Save current ISR and set the new one. --------------------------*/

  gOldISRFuncPtr = getvect(IntVectorNum);
  setvect(IntVectorNum, DmaISR);

  enable();  /* Enable interrupts. */

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

char GetBlastEnv(BLASTER *Blast)
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
	Blast->BaseIOPort = 0;
	for (i -= 1; i >= 0; i--)
	{
	  if (Buffer[i] >= '0' && Buffer[i] <= '9')
	    digit = Buffer[i] - '0';
	  else if (Buffer[i] >= 'A' && Buffer[i] <= 'F')
	    digit = Buffer[i] - 'A' + 10;
	  else if (Buffer[i] >= 'a' && Buffer[i] <= 'f')
	    digit = Buffer[i] - 'a' + 10;

	  Blast->BaseIOPort += digit * multiplier;
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
	  Blast->DMAChan8Bit  = atoi(Buffer);  /* 8-Bit DMA channel */
	else
	  Blast->DMAChan16Bit = atoi(Buffer);  /* 16-bit DMA channel */

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

	Blast->IRQNumber  = atoi(Buffer);
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

  ResetDSPValue = ResetDSP(gBlaster.BaseIOPort);
  if (ResetDSPValue == FAIL)
    return(FAIL);

  DSPWrite(Blast->BaseIOPort, DSP_GET_VERSION);

  Major = DSPRead(Blast->BaseIOPort);  /* Read Major DSP version no. */
  Minor = DSPRead(Blast->BaseIOPort);  /* Read Minor DSP version no. */
  Blast->DSPVersion = (Major << 8) | Minor;

  return(SUCCESS);
}


/*
** FUNCTION: DSPRead()
**
** DESCRIPTION: Reads a value from the DSP Read Port.
**
** Entry: BaseIOPort - The Sound Blaster's base I/O address.
*/

short int DSPRead(short int BaseIOPort)
{
  /* Wait until DSP is ready before reading from the DSP. */

  while ((inp(BaseIOPort + DSP_DATA_AVAIL) & 0x80) == 0);

  /* Return value read from the Read Port. */

  return(inp(BaseIOPort + DSP_READ_PORT));
}


/*
** FUNCTION: DSPWrite()
**
** DESCRIPTION: Writes the value passed to this function to the DSP Write
**              Port.
**
** Entry: BaseIOAddr - The Sound Blaster's base I/O address.
*/

void DSPWrite(short int BaseIOAddr, short int WriteValue)
{
  /* Wait until DSP is ready before writing to the DSP. */

  while ((inp(BaseIOAddr + DSP_WRITE_PORT) & 0x80) != 0);

  outp(BaseIOAddr + DSP_WRITE_PORT, WriteValue);
  return;
}


/*
** FUNCTION: ResetDSP()
**
** DESCRIPTION: Self explanatory
**
** Entry: BaseIOAddr - The Sound Blaster's base I/O address.
*/

char ResetDSP(short int IOBasePort)
{
  outp(IOBasePort + DSP_RESET_PORT, 0x0001);  /* Write "1" to Reset Port. */
  delay(10);                                  /* Wait 10 mS.              */
  outp(IOBasePort + DSP_RESET_PORT, 0x0000);  /* Write "0" to Reset port. */

  /* Wait until data is available. (Wait while BIT-7 == 0.) */

  while ((inp(IOBasePort + DSP_DATA_AVAIL) & 0x80) == 0);

  if (inp(IOBasePort + DSP_READ_PORT) == DSP_READY)
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
**
**              A page corresponds to the following addresses:
**
**              PAGE NO.   SEG:OFF ADDRESS          PHYSICAL ADDRESS
**              --------   ----------------------   ----------------
**                 0       0000:0000 to 0000:FFFF   00000 to 0FFFF
**                 1       1000:0000 to 1000:FFFF   10000 to 1FFFF
**                 .                 .                    .
**                 .                 .                    .
**                 E       E000:0000 to E000:FFFF   E0000 to EFFFF
**                 F       F000:0000 to F000:FFFF   F0000 to FFFFF
**
**              NOTE: The upper nibble of the physical address is the
**                    same as the page number!
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


/*
** FUNCTION: KillVolume()
*/

void KillVolume(void)
{
  /* Only SB 2 with CD interface has a mixer chip. */

  if (gBlaster.DSPVersion < 0x0300)         /* Select master volume reg. */
    outp(gBlaster.BaseIOPort + 4, 0x0002);
  else  /* SB Pro or SB16/AWE32 mixer. */
    outp(gBlaster.BaseIOPort + 4, 0x0022);  /* Select master volume reg. */

  outp(gBlaster.BaseIOPort + 5, 0x0000);    /* KILL the volume. */

  return;
}


/*
** FUNCTION: RestoreOrRememberVolume()
*/

void RestoreOrRememberVolume(char Command)
{
  static short int MasterVolume = 0;


  if (gBlaster.DSPVersion < 0x0300)         /* Only SB 2 with CD has a mixer. */
    outp(gBlaster.BaseIOPort + 4, 0x0002);  /* Select master volume reg. */
  else /* SB Pro or SB16/AWE32 mixer. */
    outp(gBlaster.BaseIOPort + 4, 0x0022);  /* Select master volume reg. */


  if (Command == REMEMBER_VOLUME)
    MasterVolume = inp(gBlaster.BaseIOPort + 5);  /* Save master volume. */
  else if (Command == RESTORE_VOLUME)
    outp(gBlaster.BaseIOPort + 5, MasterVolume);  /* Restore master volume. */

  return;
}


/*
** FUNCTION: ContinueDMA()
**
** DESCRIPTION: Continues the DMA transfer that was halted.  The DMA
**              tranfer can be halted by calling PauseDMA().
**
** SEE ALSO: PauseDMA()
*/

void ContinueDMA(unsigned char BitsPerSample)
{

  if (gBlaster.DSPVersion >= 0x0200 && gBlaster.DSPVersion < 0x0400)
    RestoreOrRememberVolume(RESTORE_VOLUME);

  /*--- IF IN HIGH-SPEED MODE, CAN'T REPROGRAM DSP CHIP--RETURN! -------*/
  /*--- OTHERWISE, RESUME THE DMA.                               -------*/

  if (gHighSpeed == TRUE)
    return;
  else if (BitsPerSample == 8)
    DSPWrite(gBlaster.BaseIOPort, 0x00D4);  /* Continue SB 8-bit DMA xfer. */
  else  /* BitsPerSample == 16 */
    DSPWrite(gBlaster.BaseIOPort, 0x00D6);  /* Continue SB 16-bit DMA xfer. */

  return;
}


/*
** FUNCTION: PauseDMA()
**
** DESCRIPTION: Halts the DMA tranfer.  The DMA tranfer can be resumed by
**              calling ContinueDMA().
**
** SEE ALSO: ContinueDMA()
*/

void PauseDMA(unsigned char BitsPerSample)
{

  if (gBlaster.DSPVersion >= 0x0200 && gBlaster.DSPVersion < 0x0400)
  {
    RestoreOrRememberVolume(REMEMBER_VOLUME);
    KillVolume();
  }

  /*--- IF IN HIGH-SPEED MODE, CAN'T REPROGRAM DSP CHIP--RETURN. -------*/
  /*--- OTHERWISE, HALT THE DMA.                                 -------*/

  if (gHighSpeed == TRUE)
    return;
  else if (BitsPerSample == 8)
    DSPWrite(gBlaster.BaseIOPort, 0x00D0);  /* Pause SB 8-bit DMA xfer. */
  else  /* BitsPerSample == 16 */
    DSPWrite(gBlaster.BaseIOPort, 0x00D5);  /* Pause SB 16-bit DMA xfer. */

  return;
}


/*
** FUNCTION: SetMixer()
**
** DESCRIPTION: Sets mixer to maximum volume.
*/

#ifdef compile_old_code

void SetMixer(void)
{
  outp(gBlaster.BaseIOPort + 4, (int) 0x0A);
  outp(gBlaster.BaseIOPort + 5, (int) 0x00);
  outp(gBlaster.BaseIOPort + 4, (int) 0x04);
  outp(gBlaster.BaseIOPort + 5, (int) 0xFF);
  outp(gBlaster.BaseIOPort + 4, (int) 0x22);
  outp(gBlaster.BaseIOPort + 5, (int) 0xFF);

  return;
}
#endif