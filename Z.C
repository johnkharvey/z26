/*
** z26 -- an Atari 2600 emulator
**
**  Build like this:
**
**  tasm -dmodule=1 /ml z26.asm
**  tcc -ez26.exe z.c z26.obj
**
** (0.88)  Jan  3, 1998  First version in "C"
** (0.88)                Precision frame timer (-f<n> option)
** (0.88)  Jan 10, 1998  Ron Fries sound code added with Sound Blaster support
** (0.88)                -q switch (quiet)
**
** (0.89)  Jan 11, 1998  fix time constant calculation for 8-bit cards
** (0.89)                fix pitch on 16-bit cards
** (0.89)                added difficulty switches within emu F5 & F6
**
** (0.90)  Jan 22, 1998  lay groundwork for Mode-X
** (0.90)                new VGA sync based on vertical nondisplay interval
** (0.90)  Jan 23, 1998  multiple missiles -- fixed missile command!
** (0.90)  Jan 24, 1998  mid-line collisions -- freeway and oystron(!)
**
** (0.91)  Feb  2, 1998  60 Hz refresh video modes
** (0.91a) Feb  4, 1998  vertical blinds -v3
**
** (0.92)  Feb 11, 1998  Joystick support, 60Hz video mode 2 now default
**
** (0.93)  Feb 22, 1998  different palette, 
**			 different Joystick code,
**                       remove ModeX support 
**			 simplify sound routines
**                       added timeout to ResetDSP routine
**         Feb 27, 1998  added 1 second startup delay to allow monitor sync
** 
**	                 fixed a flicker problem
**
** (0.94)  Mar  9, 1998  added video mode 3, just like mode 2 but 4 more 
**			 scanlines
**
**			 adjusted vertical position of games to take advantage
**			 of mode 3
**
**	   Mar 11, 1998  restore 0.92 sound routines 
**			 (even leave out timeout from ResetDSP)
**
**	   Mar 11, 1998  restore 0.92 joystick routines
**
** (0.95)  Mar 17, 1998  fix blinking line in upper left corner that showed up
**			 in 0.94 by responding immediately to vblank turned on
**
**                       made some progress on jitter by triggering on the 
**			 positive going edge of vsync
**
**                       made some progress on a windows startup problem by
**			 delaying before going into graphics mode
**
**                       fix the joystick games that previously didn't work
**			 with the joystick
**
** (0.96)  Mar 18, 1998  made sound initialization wait for Windows 95 to
**			 finish with the sound card
**
**			 added timeouts to vertical sync code that causes
**			 automatic reversion to old code if timeout occurs
**
**			 reverse sync on space invaders (still doesn't fix)
**
**			 sound off during pause for all sound cards
**
**	   Mar 27, 1998	 put part of sound drivers in assembly language, based
**			 in part on Asteroids v3.02 (c) 1997 by Chris Pile
**			 this fixes rare sound related lockup on exit
**
** (0.97)  Mar 30, 1998  fix sound related lockup on termination (Try 2)
**			 implemented Atari super-chip games
**			 implemented CBS Ram Plus games
**
*/

#include <dos.h>		/* _psp */

char Sb_init = 0;		/* mark Sound Blaster currently not in use */


short int	sbBaseIOPort;
unsigned char	sbDMAChan8Bit;
short int	sbDSPVersion;
unsigned char	sbIRQNumber;
unsigned char	sbDMAPage;
short int	sbDMAOffset;
unsigned char	sbTimeConstant;


unsigned char	DMABufToLoad = 0;
unsigned char   gDMABufNowPlaying;
unsigned char   *DMABuf;

#define SAMPLE_FREQ 31400
#define gDMABufSize 256		/* 128 bytes per interrupt */
#define gHalfBufSize gDMABufSize / 2

unsigned int playback_freq;

extern short int psp;		/* (data.asm) */
extern short int Checksum;

extern char	DoCopyright;
extern char	DoChecksum;
extern char	verbose;
extern char	quiet;
extern char	credits;
extern char	JobDone;

unsigned char CartRom[16384];	/* read the cart in here */
unsigned char BaseDMABuf[(gDMABufSize+1) * 2]; /* Sound Blaster DMA buffer */
unsigned char Ram[2048];	/* extra RAM */
unsigned char TraceBuffer[8182]; /* trace buffer */


#include "tiasound.c"		/* Ron Fries' sound code */
#include "messages.c"		/* messages */


main() 
{
  memset(Ram,0,2048);		/* clear out extra ram */

  psp = _psp;			/* for command line processor (cmdline.asm) */
  CommandLine();		/* call command line processor */

  if (DoCopyright) 
  {
    ShowCopyright();
    goto done;
  }

  if (credits)
  {
    ShowCredits();
    goto done;
  }

  if (DoChecksum)
  {
    ShowChecksum();
    goto done;
  }

  if (!quiet)
  {
    if (SetupSoundBlaster()) goto done; /* user pressed escape while waiting */
  }

  emulator();			/* call emulator (tia.asm) */

done:
  if (Sb_init)
  {
    RestoreISR();		/* turn off Sound Blaster DMA 
                                   and restore old ISR */
  }
}
