/*
** z26 -- an Atari 2600 emulator
*/

#include <dos.h>		/* _psp */
#include <ctype.h>
#include <stdio.h>
#include <string.h>

extern short int psp;		/* (data.asm) */
extern char VideoMode;
extern short int CFirst;
extern char quiet;
extern char SoundMode;
extern char IOPortB;
extern char DoChecksum;
extern char NoRetrace;
extern long int FrameExit;
extern char dsp;
extern char Joystick;
extern char PaletteNumber;
extern long int PaddleGame;
extern char KeyBase;
extern int CartSize;
extern long int Checksum;

extern unsigned char CartRom[];

#include "gui.c"
#include "cli.c"

main(int argc, char *argv[])
{
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
/*
		gui_ShowPrototype();
*/
		gui_ShowHelp();

		gui_RestoreVideoMode();
	}
}
