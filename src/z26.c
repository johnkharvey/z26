/*
**	z26 -- an Atari 2600 emulator
*/

#define Z26_RELEASE "z26 -- An Atari 2600 Emulator"

void QueueSoundBytes(void);
void position_game(void);
void srv_print(char *msg);
void srv_Events(void);
void show_scanlines(void);
void show_transient_status(void);
void set_status(char *status);
void gui(void);

#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dirent.h>		// not in vc++ -- must be supplied 
#include <sys/stat.h>
#include <time.h>

const char *homedir;
char z26cli[1024] = {0};
char z26gui[1024] = {0};
char z26home[1024] = {0};
char z26log[1024] = {0};

#ifdef LINUX
#include <unistd.h>		// for chdir
#include <sys/types.h>
#include <pwd.h>
#endif

FILE *parmfp = NULL;

#include <SDL2/SDL.h>
#include <SDL2/SDL_audio.h>
#include <SDL2/SDL_opengl.h>
#include <SDL2/SDL_keyboard.h>

typedef unsigned long long int  dq;
typedef unsigned int			dd;
typedef unsigned short int		dw;
typedef unsigned char			db;

void draw_trace_column_headers(void);

#include "globals.c"
#include "ct.c"
#include "carts.c"
#include "cli.c"
#include "palette.c"
#include "kidvid.c"
#include "sdlsrv.c"
#include "text.c"
#include "controls.c"
#include "position.c"
#include "gui.c"
#include "2600core.c"

int main(int argc, char *argv[]) 
{

#ifdef LINUX
#ifndef MAC
	playwav();	// play a little wav file twice on Linux startup
	playwav();	// otherwise sound doesn't always work (see sdlplaywav.c)
#endif
	if ((homedir = getenv("HOME")) == NULL) {
	    homedir = getpwuid(getuid())->pw_dir;
	}
#endif
#ifdef WINDOWS
	putenv("SDL_AUDIODRIVER=directsound");	// windows needs env var for sound
	homedir = getenv("USERPROFILE");
#endif

	strncpy(z26home, homedir, sizeof(z26home)-1);
	strncpy(z26gui, homedir, sizeof(z26gui)-1);
	strncpy(z26cli, homedir, sizeof(z26cli)-1);
	strncpy(z26log, homedir, sizeof(z26log)-1);

#ifdef LINUX
	strncat(z26gui, "/z26.gui", sizeof(z26gui)-1);
	strncat(z26cli, "/z26.cli", sizeof(z26cli)-1);
	strncat(z26log, "/z26.log", sizeof(z26log)-1);
#endif
#ifdef WINDOWS
	strncat(z26gui, "\\z26.gui", sizeof(z26gui)-1);
	strncat(z26cli, "\\z26.cli", sizeof(z26cli)-1);
	strncat(z26log, "\\z26.log", sizeof(z26log)-1);
#endif

	if (chdir(z26home) != 0)
	{
		printf("couldn't go home\n");
	}

	srand(time(0));
	def_LoadDefaults();

	if (argc == 1)
	{
		StartInGUI = 1;
		GamePaused = 1;
		LaunchedFromCommandline = 0;
		cli_ReadParms(z26gui);
	}
	else
	{
		LaunchedFromCommandline = 1;
		cli_CommandLine(argc, argv);
	}
	
	Init_SDL();
	c_emulator();

	if(TraceEnabled && (zlog != NULL)) {
		fprintf(zlog, "Exiting emulator with status %d\n", MessageCode);
		fflush(zlog);
		fclose(zlog);
	}

	srv_sound_off();
	SDL_Quit();

	return MessageCode;
}                                                         


/**
	z26 is Copyright 1997-2019 by John Saeger and contributors.
	z26 is released subject to the terms and conditions of the 
	GNU General Public License Version 2 (GPL).
	z26 comes with no warranty.
	Please see COPYING.TXT for details.
*/
