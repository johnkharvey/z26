/*
** z26 -- an Atari 2600 emulator
** Copyright (C) 1997-1999 by John Saeger
*/

/*
** If you hang onto the past you die a little every day.
*/


#define version "z26 (1.29)"

#define rom_list "ROM List"

/*
#define rom_list "Preview version D -- Please don't distribute."
*/


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

unsigned char CartRom[32770];

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
		delay(100);

		gui_CheckMouse();
		gui_GraphicsMode();
		gui_SetPalette(35, 40, 45);	/* 31, 34, 41 */

/*		gui_ShowPrototype(); */
/*		gui_ShowHelp(); */

		gui_ShowList();

		gui_RestoreVideoMode();
	}
}
