/*
** z26 -- an Atari 2600 emulator
*/

/*
** z26 is Copyright 1997-2001 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/



#define version "z26 (1.48)"

/*
#define version "Pre 1.48-C"
*/

/*
#define rom_list "ROM List"
*/

#define rom_list ""


#include <dos.h>		/* _psp */
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <process.h>
#include <stdlib.h>
#include <time.h>
#include <alloc.h>

#include "globals.c"
#include "ct.c"
#include "carts.c"
#include "cli.c"
#include "gui.c"
#include "trace.c"
#include "pcx.c"


extern unsigned _stklen = 16384U;       /* set stack size to 16K */ 


void main(int argc, char *argv[])
{
        def_LoadDefaults();

        ScreenBuffer=(char *) calloc(65000,sizeof(char));
        if(ScreenBuffer==NULL)
        {
                printf("Couldn't allocate ScreenBuffer!\n");
                exit(1);
        }
        ScreenSeg=FP_SEG(ScreenBuffer);
        ScreenOfs=FP_OFF(ScreenBuffer);

        Megaboy=(char *) calloc(39000,sizeof(char));
        if(Megaboy==NULL)
        {
                printf("Couldn't allocate Megaboy buffer!\n");
                exit(1);
        }
	MBseg=FP_SEG(Megaboy);
	MBofs=FP_OFF(Megaboy);

	if (argc != 1)
	{
	   	cli_CommandLine(argc, argv);
	   	psp = _psp;		   /* for environment scanner	 (sbdrv.asm) */
	   	emulator();		   /* call emulator		 (main.asm) */
	   	if(ShowLineCount) 
		{
			printf("Filename %s\n", FileName);
			printf("%06lx checksum -- %08lx crc\n", Checksum, crc);
			printf("%u scanlines in last frame\n",LinesInFrame);
			printf("CFirst %u\n", CFirst);
	   		DelayTime = 250000;
	   		LongDelay();
		}
		else if (!InTextMode)
		{
	   		gui_GraphicsMode();
	   		gui_SetPalette(35, 40, 45);
	   		gui_ShowExitScreen();
	   		DelayTime = 250000;
	   		LongDelay();
	   		gui_RestoreVideoMode();
		}
	}
	else
	{
		printf("Entering graphics mode ... \n");
		DelayTime = 250000;

		LongDelay();

                gui_CheckLFN();		/* check for long filename support */
		gui_CheckMouse();
		gui_GraphicsMode();
		gui_SetPalette(35, 40, 45);

		gui_ShowList();

		gui_ShowExitScreen();
		DelayTime = 250000;
		LongDelay();
		gui_RestoreVideoMode();
	}

        free(ScreenBuffer);
        free(Megaboy);
}
