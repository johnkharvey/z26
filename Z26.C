/*
** z26 -- an Atari 2600 emulator
*/

/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/



#define version "z26 (1.36)"


#define rom_list "ROM List"

/*
#define rom_list "Preview version C -- Please don't distribute."
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
		emulator();		/* call emulator              (tia.asm) */
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
		gui_SetPalette(35, 40, 45);	/* 31, 34, 41 */

		gui_ShowList();

		gui_RestoreVideoMode();
	}
}
