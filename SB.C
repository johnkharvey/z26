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


#define AUTO_INIT                  1
#define DMA8_FF_REG           0x000C
#define DMA8_MASK_REG         0x000A
#define DMA8_MODE_REG         0x000B
#define DSP_GET_VERSION       0x00E1
#define FAIL                       0
#define FALSE                      0
#define SB2_LO                     1
#define SB2_HI                     2
#define SBPRO                      3
#define SB16                       4
#define SUCCESS                    1
#define TRUE                  !FALSE


/*
** Properties of SoundBlaster installed in system
*/

short int sbBaseIOPort;
short int sbDMAChan8Bit;
short int sbDSPVersion;
unsigned char sbIRQNumber;


/*
** Properties of sound being played
*/

unsigned char           ssChannels;
unsigned short int      ssTimeConstant;
signed long int         ssSampPerSec;


/*
** global variables
*/

unsigned char   gDMABufNowPlaying,
                gHighSpeed;

unsigned char   *DMABuf;
long int        DMABufPhysAddr;


/*
** SoundBlaster functions
*/

char GetBlastEnv(void),
     ResetDSP(void);

short int DSPRead(void);

unsigned long int AllocateDMABuffer(),
                  OnSamePage(unsigned char *, unsigned short int);

void DSPWrite(short int),
     ProgramDMA(unsigned long int, unsigned short int),
     ProgramDSP(unsigned short int, unsigned char);


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

  outp(DMA8_MASK_REG, sbDMAChan8Bit | 4);     /* Disable DMA */
  outp(DMA8_FF_REG, 0x0000);                  /* Clear F-F */
  outp(DMA8_MODE_REG, sbDMAChan8Bit | 0x58);  /* 8-bit AI */
  outp(DMACount, ((Count - 1) & 0xFF));       /* LO byte */
  outp(DMACount, ((Count - 1) >> 8));         /* HI byte */

  /* Program the starting address of the DMA buffer. */

  outp(DMAPage, Page);             /* Page number of DMA buffer. */
  outp(DMAAddr, Offset & 0x00FF);  /* LO byte offset address of DMA buffer. */
  outp(DMAAddr, (Offset >> 8));    /* HI byte offset address of DMA buffer. */

  /* Reenable DMA. */

  outp(DMA8_MASK_REG,  sbDMAChan8Bit);

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

void ProgramDSP(unsigned short int Count, unsigned char DMAMode)
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

  /*--- FILE IS 8-BIT OR 16-BIT UNCOMPRESSED AUDIO.  PROGRAM EACH ----*/
  /*--- SOUND BLASTER CARD DIFFERENTLY.                           ----*/

  switch(Card)
  {
    case SB16:

      /*--- DETERMINE 8-bit OR 16-bit, MONO OR STEREO ----------------*/

      /* do 8-bit sound the old-fashioned way (JS) */
      DSPWrite(0x0040);  /* Program Time Constant */
      DSPWrite(ssTimeConstant);

      Command = 0x00C0;  /* 8-bit transfer (default: single-cycle, D/A) */

      if (ssChannels == 1)
        Mode = 0x0000;   /* MONO, unsigned PCM data */
      else
        Mode = 0x0020;   /* STEREO, unsigned PCM data */

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

      if (ssChannels == 2)
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
      else if (ssSampPerSec >= 23000)
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
      if (ssSampPerSec > 13000 || ssChannels == 2)
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
  
  /*--- CARD IS AN 8-BIT AUDIO CARD (DSP VERSION < 4.xx) ---*/
  /*--- BEGIN DMA TRANFER. ---*/

  DSPWrite(0x00D1);  /* Turn speaker on. */
  DSPWrite(0x0040);  /* Program Time Constant */
  DSPWrite(ssTimeConstant);

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

        sbDMAChan8Bit  = atoi(Buffer);  /* 8-Bit DMA channel */

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

  ShowBlasterWaiting();

  while (1)
  {
    if (ResetDSP() == FAIL)
    {
      if (kbhit())
      {
        ch = getch();
        if (ch == 27) 
          exit(0);      /* escape pressed */
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
** DESCRIPTION : Check the DMA buffer.  
**               If first half of buffer crosses a page boundary use second half.
**
**       If a buffer is NOT successfully allocated, return FAIL.
*/

unsigned char MallocDMABuf[(gDMABufSize+1) * 2];

unsigned long int AllocateDMABuffer()
{
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


/*
** called from inside the emulator when it's time to start the sound
*/

StartSound()
{
  if (Sb_init)
  {
    ProgramDSP(gDMABufSize / 2, AUTO_INIT);     /* turn on DMA */
  }
}
