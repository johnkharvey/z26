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
** (0.89)  Jan 11, 1998  fix time constant calculation for 8-bit cards
** (0.89)                fix pitch on 16-bit cards
** (0.89)                added difficulty switches within emu F5 & F6
** (0.90)  Jan 22, 1998  lay groundwork for Mode-X
** (0.90)                new VGA sync based on vertical nondisplay interval
** (0.90)  Jan 23, 1998  multiple missiles -- fixed missile command!
** (0.90)  Jan 24, 1998  mid-line collisions -- freeway and oystron(!)
** (0.91)  Feb  2, 1998  60 Hz refresh video modes
*/

#include <stdio.h>		/* puts */
#include <stdlib.h>		/* getenv */
#include <dos.h>		/* _psp */
#include <alloc.h>		/* farmalloc */

#include "sb.c"			/* Sound Blaster driver code */
#include "tiasound.c"		/* Ron Fries' sound code */

#define SAMPLE_FREQ 31400

unsigned int playback_freq = SAMPLE_FREQ;	/* was 31400 */
unsigned int sample_freq =   SAMPLE_FREQ;	/* was 31400 */

unsigned int gHalfBufSize;	/* half of the DMA buffer size */

extern short int psp;		/* (data.asm) */
extern char *CartRom;
extern char *RomPtr;
extern short int DoCopyright;
extern short int quiet;
extern short int DoChecksum;
extern short int Checksum;
extern short int verbose;
extern short int credits;
extern unsigned short int VideoBufferSegment;  /* gets segment address of video buffer */


/*
** press a key to continue
*/

PressKeyToContinue()
{
  int ch;

  puts("\nPress a key to continue, <esc> to exit...");
  while(!kbhit());
  ch = getch();
  if (ch == 27) exit(0);	/* escape pressed */
}

/*
** show SoundBlaster information
*/

ShowBlaster()
{
    printf("           I/O port: %x (hex)\n",  gBlaster.BaseIOPort);
    printf("          DMA 8-bit: %d\n",        gBlaster.DMAChan8Bit);
    printf("         DMA 16-bit: %d\n",        gBlaster.DMAChan16Bit);
    printf("                IRQ: %d\n",        gBlaster.IRQNumber);
    printf("        DSP Version: %d.%02d\n",  (gBlaster.DSPVersion >> 8) & 0x00FF,
				              (gBlaster.DSPVersion & 0x00FF));
}

/*
** called from inside the emulator when it's time to start the sound
*/

StartSound()
{
  if (Sb_init)
  {
    ProgramDSP(gDMABufSize / 2, &gSoundStyle, AUTO_INIT);	/* turn on DMA */
  }
}

StopSound()
{
  if (Sb_init)
  {
    ResetDSP(gBlaster.BaseIOPort);		/* turn off DMA */
  }
}

main() 
{
  CartRom = malloc(16384);	/* memory for cartridge rom */
  if (CartRom == NULL)
  {
    puts("Couldn't allocate memory for cartridge ROM");
    return;
  }
  RomPtr = CartRom - 0x1000;	/* adjust pointer to rom area within CartRom */

  VideoBufferSegment = DOSalloc(0x1000); 	/* allocate this many paragraphs */
						/* big enough to contain a wild pointer */
						/* try THAT on a 32-bit compiler! */
  if (VideoBufferSegment == NULL)
  {
    puts("Couldn't allocate memory for video buffer");
    free(CartRom);
    return;
  }

  psp = _psp;			/* for command line processor (cmdline.asm) */
  CommandLine();		/* call command line processor */

  if (DoCopyright)
  {
    puts("\n\nz26 -- An Atari 2600 emulator (0.91)");
    puts("Copyright (C) 1997-1998 by John Saeger\n");

    puts("Home Page:  http://www.whimsey.com/z26.html\n");

    puts("    F1 -- reset        F2 -- select    F5 -- P0 easy      F6 -- P0 hard");
    puts("    F9 -- B/W         F10 -- color      p -- pause     ENTER -- resume");
    puts(" SPACE -- fire        ESC -- quit game  = -- PCX screen capture\n");

    puts("The Atari joystick is emulated with the arrow keys.\n");

    puts("Command Line Switches (put before filename)\n");

    puts(" -0    -- player 0 hard");
    puts(" -r    -- do not wait for VGA retrace (full speed)");
    puts(" -q    -- quiet (no sound)");
    puts(" -s    -- show sound diagnostic messages");
    puts(" -f<n> -- run emulator for <n> frames and display timing results");
    puts(" -d<n> -- use digital signal processing on sound (1=low, 2=high)");
    puts(" -v<n> -- video mode (1=60Hz, 2=60Hz narrow)");
    puts(" -c    -- show credits (please do!)\n\n");
    goto free_mem;
  }

  if (credits)
  {
    puts("\nz26 is based on A26 version 0.15 (C) 1996 by Paul Robson (autismuk@aol.com).\n");

    puts("PCX screen capture is (C) 1997 by Ronnie Greene (ender@abts.net).\n");

    puts("Atari 2600 sound emulation is (C) 1996 by Ron Fries (rfries@tcmail.frco.com).\n");

    puts("60Hz chained video modes courtesy of Jim Leonard (Trixter / Hornet).");
    puts("                                                 (trixter@hornet.org)\n");

    puts("z26 is provided without any warranty of any kind, either express or implied.");
    puts("Neither John Saeger, nor anyone who has worked on the code, may be held");
    puts("responsible for any damages caused by the use of z26.\n");

    puts("z26 is freeware and may not be sold.");
    goto free_mem;
  }

  if (DoChecksum)
  {
    printf("%X", Checksum);
    goto free_mem;
  }

  if (quiet) goto no_sound;

  if (GetBlastEnv(&gBlaster) == FAIL)
  {
    if (verbose)
    {
      puts("Sound Blaster not found.");
      PressKeyToContinue();
    }
    goto no_sound;
  }

  if (gBlaster.DSPVersion < 0x0200)  /* DSP version < 2.xx */
  {
    if (verbose)
    {
      puts("Sound Blaster too old!\n");
      ShowBlaster();
      PressKeyToContinue();
    }
    goto no_sound;
  }

  if (gBlaster.DSPVersion == 0x200)  /* DSP version = 2.00 */
  {
    playback_freq = SAMPLE_FREQ / 2;	/* was 15700 */
  }

  Tia_sound_init (sample_freq, playback_freq);

  gDMABufSize = 128;		/* 64 bytes per interrupt */
				/* experimental "a"=256/2 "b"=512/2 */

  gHalfBufSize = gDMABufSize / 2;

  DMABufPhysAddr = AllocateDMABuffer(&DMABuf, &gDMABufSize);
  if (DMABufPhysAddr == FAIL)
  {
    puts("Couldn't allocate memory for sound buffer.");
    free(CartRom);
    return;
  }

  memset(DMABuf, gDMABufSize, 0);	/* clear out sound buffer */
					/* to minimize startup noises */

  gSoundStyle.BitsPerSample = 8;	/* 8 bit */
  gSoundStyle.Channels = 1;		/* mono */
  gSoundStyle.SoundFormat = 0;		/* 8-bit uncompressed */
  gSoundStyle.SampPerSec = playback_freq;
  gSoundStyle.TimeConstant = (unsigned short int) ((256L - 1000000L)
				   / ((long) gSoundStyle.Channels * gSoundStyle.SampPerSec) & 0x00FF);

  if (verbose)
  {
    printf("\nSound Blaster detected.\n\n");
    ShowBlaster();
    printf("        Buffer Size: %d\n",gDMABufSize);
    printf(" Playback Frequency: %d\n",playback_freq);
    printf("      Time Constant: %d\n",gSoundStyle.TimeConstant);
    PressKeyToContinue();
  }

  ResetDSP(gBlaster.BaseIOPort);	/* knock-knock */

  DMABufToLoad = 1;			/* next half buffer to load is top half */
  gDMABufNowPlaying = 0;		/* altered by ISR when buffer done playing */
  gHighSpeed = FALSE;			/* init to NOT hi-speed DMA */

  SetDmaISR(&gBlaster);  		/* setup the interrupt handler */

  ProgramDMA(DMABufPhysAddr, &gSoundStyle, gDMABufSize);

/*  ProgramDSP(gDMABufSize / 2, &gSoundStyle, AUTO_INIT); */

  Sb_init = 1;				/* mark Sound Blaster initialized */

no_sound:

  emulator();				/* call emulator (tia.asm) */

free_mem:
  free(CartRom);
  DOSfree(VideoBufferSegment);

  if (Sb_init)
  {
    ResetDSP(gBlaster.BaseIOPort);	/* stop DMA */
    RestoreOldISR(&gBlaster); 		/* restore old ISR */
    free(DMABuf);
  }

}
