/*
** z26 -- an Atari 2600 emulator
*/

#define version "z26 (1.24)"

#include <dos.h>		/* _psp */
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <process.h>
#include <stdlib.h>
#include <time.h>

extern short int psp;		/* (data.asm) */
extern int CartSize;
extern long int Checksum;

extern unsigned char CartRom[];

#include "def.c"
#include "cli.c"
#include "gui.c"


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
		gui_CheckMouse();
		gui_GraphicsMode();
		gui_SetPalette(35, 40, 45);	/* 31, 34, 41 */

/*		gui_ShowPrototype(); */
/*		gui_ShowHelp(); */

		gui_ShowList();

		gui_RestoreVideoMode();
	}
}
