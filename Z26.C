/*
** z26 -- an Atari 2600 emulator
** Copyright (C) 1997-1999 by John Saeger
*/

/*
** z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

/*
** If you hang onto the past you die a little every day.
*/


#define version "z26 (1.35)"


#define rom_list "ROM List"

/*
#define rom_list "Preview version A -- Please don't distribute."
*/

#include <dos.h>		/* _psp */
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <process.h>
#include <stdlib.h>
#include <time.h>


extern short int psp;		/* (data.asm) */
extern unsigned int CartSize;
extern long int Checksum;
extern long int XChecksum;

void far VGATextMode(void);	/* (vga.asm) */

unsigned char CartRom[34000];

#include "def.c"
#include "cli.c"
#include "gui.c"
#include "trace.c"


main(int argc, char *argv[])
{
	def_SaveDefaults();
	if (argc != 1)
	{
		cli_CommandLine(argc, argv);
		psp = _psp;		/* for environment scanner  (sbdrv.asm) */
		emulator();		/* call emulator             (main.asm) */
	}
	else
	{

/*
** The following printf is to prevent Win98 from halting if z26 is launched
** from a shortcut made into a button in the task bar.
*/

		printf("Entering graphics mode ... \n");
		delay(50);
		delay(50);

		gui_CheckMouse();

		gui_GraphicsMode();

		gui_ShowList();

	}

/*
** I've been having some problems *restoring* DOS text mode; Sometimes my 
** Win98 system crashes on exit. So I want the restore done the same way 
** whether it's from the GUI or not.
**
** But I've noticed that if I do a fresh boot and never run the SETI client,
** z26 will run all day, exiting as many times as I like without crashing.
**
** So I suspect it's a problem in the O.S. ;-)
*/

	VGATextMode();
}
