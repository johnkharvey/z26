/*
** Messages -- we save ~ 1500 bytes by not using printf
**	       see console.asm for implementations
*/


/*
** show Copyright information
*/

ShowCopyright()
{
  put_str("\n\nz26 -- An Atari 2600 emulator (0.97)\n");
  put_str("Copyright (C) 1997-1998 by John Saeger\n\n");

  put_str("Home Page:  http://www.whimsey.com/z26\n\n");

  put_str("    F1 -- reset        F2 -- select    F5 -- P0 easy      F6 -- P0 hard\n");
  put_str("    F9 -- B/W         F10 -- color      p -- pause     ENTER -- resume\n");
  put_str(" SPACE -- fire        ESC -- quit game  = -- PCX screen capture\n\n");

  put_str("The Atari joystick is emulated with the arrow keys.\n\n");

  put_str("Command Line Switches (put before filename)\n\n");

  put_str(" -0    -- player 0 hard\n");
  put_str(" -r    -- do not wait for VGA retrace (full speed)\n");
  put_str(" -q    -- quiet (no sound)\n");
  put_str(" -s    -- show sound diagnostic messages\n");
  put_str(" -f<n> -- run emulator for <n> frames and display timing results\n");
  put_str(" -d<n> -- use digital signal processing on sound (1=low, 2=high)\n");
  put_str(" -v<n> -- video mode (0=70Hz, 1=60Hz, 2=60Hz narrow, 3=60Hz 204 scan lines)\n");
  put_str(" -j<n> -- joystick (0=joystick off)\n");
  put_str(" -c    -- show credits (please do!)\n\n");
}


/*
** show credits
*/

ShowCredits()
{
  put_str("\nz26 is based on A26 version 0.15 (C) 1996 by Paul Robson (autismuk@aol.com).\n\n");

  put_str("PCX screen capture is (C) 1997 by Ronnie Greene (ender@abts.net).\n\n");

  put_str("Atari 2600 sound emulation is (C) 1996 by Ron Fries (rfries@tcmail.frco.com).\n\n");

  put_str("60Hz chained video modes courtesy of Jim Leonard (Trixter / Hornet).\n");
  put_str("                                                 (trixter@hornet.org)\n\n");

  put_str("Assembly language sound drivers based in part on Asteroids v3.02.\n");
  put_str("(c) 1997 by Chris Pile (pegasus@enterprise.net)\n\n");

  put_str("z26 is provided without any warranty of any kind, either express or implied.\n");
  put_str("Neither John Saeger, nor anyone who has worked on the code, may be held\n");
  put_str("responsible for any damages caused by the use of z26.\n\n");

  put_str("z26 is freeware and may not be sold.\n");
}


/*
** show cartridge checksum
*/

ShowChecksum()
{
  put_hex(Checksum);
}

/*
** press a key to continue
*/

PressKeyToContinue()
{
  int ch;

  put_str("\nPress a key to continue, <esc> to exit...\n");
  ch = getch();
  if (ch == 27) exit(0);	/* escape pressed */
}


/*
** show Sound Blaster information
*/

ShowBlaster()
{
  int ver;

  put_str("           I/O port: "); put_hex(sbBaseIOPort); crlf();
  put_str("          DMA 8-bit: "); put_dec(sbDMAChan8Bit); crlf();
  put_str("                IRQ: "); put_dec(sbIRQNumber); crlf();
  put_str("        DSP Version: "); put_dec((sbDSPVersion >> 8) & 0x00FF);
				    put_str(".");
				    ver = sbDSPVersion & 0xFF;
				    if (ver < 10) put_str("0");
				    put_dec(ver);
				    crlf();
}


/*
** show Sound Blaster not found
*/

ShowBlasterNotFound()
{
  put_str("Sound Blaster not found.\n");
  PressKeyToContinue();
}


/*
** show Sound Blaster too old
*/

ShowBlasterTooOld()
{
  put_str("Sound Blaster too old!\n\n");
  ShowBlaster();
  PressKeyToContinue();
}


/*
** show Sound Blaster detected
*/

ShowBlasterDetected()
{
  put_str("\nSound Blaster detected.\n\n");
  ShowBlaster();
  put_str("        Buffer Size: "); put_dec(gDMABufSize); crlf();
  put_str(" Playback Frequency: "); put_dec(playback_freq); crlf();
  put_str("      Time Constant: "); put_dec(ssTimeConstant); crlf();
  PressKeyToContinue();
}


/*
** show waiting for Sound Blaster
*/

ShowBlasterWaiting()
{
  put_str("\nWaiting for Sound Blaster...\n\n");
  put_str("Press <esc> to exit, any other key to continue with PC speaker sound.\n");
}
