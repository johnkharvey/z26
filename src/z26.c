/*
** z26 -- an Atari 2600 emulator
*/

// #define C_ENGINE

#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/stat.h>
#include <time.h>

FILE *parmfp = NULL;	// parameter file pointer

/* moved these here from sdlsrv.c */

#include "SDL.h"
#include "SDL_audio.h"

/* moved these here from globals.c */

typedef unsigned long long int	dq;
typedef unsigned int		dd;
typedef unsigned short int	dw;
typedef unsigned char		db;

#include "z26.h"
#include "globals.c"
#include "ct.c"
#include "carts.c"
#include "cli.c"
#include "kidvid.c"
#include "palette.c"
#include "sdlsrv.c"
#include "text.c"
#include "pcx.c"
#include "controls.c"
#include "position.c"
#include "gui.c"

//#include "c_tiasnd.c"
//#include "c_soundq.c"


extern void z_emulator();

#ifdef C_ENGINE
#include "2600core.c"
#else
#include "trace.c"
#endif

Uint32 total_ticks;
double seconds;

int main(int argc, char *argv[])
{
	Init_SDL();
        srand(time(0));
	def_LoadDefaults();
	LaunchedFromCommandline = 0;

	if (argc == 1)
	{
		StartInGUI = 1;
		GamePaused = 1;
		cli_ReadParms("z26.gui");
	}
	else
	{
		LaunchedFromCommandline = 1;
		cli_CommandLine(argc, argv);
	}

#ifdef C_ENGINE
	c_emulator();		   /* call emulator -- (main.asm) */
#else
	z_emulator();
#endif

	if(GrabInput)
		SDL_WM_GrabInput(SDL_GRAB_OFF);

#ifndef C_ENGINE
	switch(MessageCode) {
		case 1:
			clrscr();
			sprintf(msg, "Unable to find load %02x\n", SC_ControlByte);
			srv_print(msg);
			break;
		case 2:
			clrscr();
			sprintf(msg, "Starpath call @ %04x\n", cpu_pc);
			srv_print(msg);
			break;
		case 3:
			clrscr();
			sprintf(msg, "JAM %02x @ %04x\n", cpu_a, cpu_pc);
			srv_print(msg);
			break;
       		}
#endif

#ifdef LINUX
	printf("Total frames: %d, avg FPS: %f\n", Flips, CurrentFPS);
#endif

	if(TraceEnabled && (zlog != NULL)) {
		fprintf(zlog, "Exiting emulator with status %d\n", MessageCode);
		fflush(zlog);
		fclose(zlog);
	}

	srv_sound_off();
	SDL_Quit();

	fflush(parmfp);
	fclose(parmfp);
	
	return MessageCode;
}                                                         


/**
** z26 is Copyright 1997-2011 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
