/*
** sdlsrv.c -- SDL service code
*/

/*
** z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

#include "SDL.h"
#include "SDL_audio.h"

#define WINDOWS 1

#ifdef WINDOWS
#include "winsrv.c"
#endif

extern dd FDoLinearCopy();
extern dd DoLinearCopy();
extern dd DoWideLinearCopy();

extern dd CFDoLinearCopy();
extern dd CDoLinearCopy();
extern dd CDoWideLinearCopy();

#define NUM_COLORS 256

SDL_Surface *srv_screen;
Uint8 *srv_buffer;
dd srv_pitch;

dd Vert;
dd Horiz;

db *screen_pixels;
db *emu_pixels;
db *emu_pixels_prev;

db screen_buffer_count = 0;

db srv_done = 0;


srv_print(char *msg)
{
#ifdef WINDOWS
	win_msg(msg);
#else
	printf("%s", msg);
#endif
}

srv_SetPalette()
{
	int i;
	SDL_Color palette[NUM_COLORS];

	GeneratePalette();
	for ( i=0; i<128; i++)
	{
		palette[i].r = PCXPalette[3*i];
		palette[i].g = PCXPalette[3*i+1];
		palette[i].b = PCXPalette[3*i+2];
	}

	SDL_SetColors(srv_screen, palette, 0, NUM_COLORS);
}

void CreateScreen(Uint16 w, Uint16 h, Uint8 bpp, Uint32 flags)
{
	srv_screen = SDL_SetVideoMode(w, h, bpp, flags);
	srv_pitch = srv_screen->pitch;
	
	if ( srv_screen == NULL ) {
		sprintf(msg, "Couldn't set display mode: %s\n", SDL_GetError());
		srv_print(msg);
		return;
	}

	SDL_WM_SetCaption(" z26"," z26");
	
	if (srv_screen->flags & SDL_FULLSCREEN)
		SDL_ShowCursor(SDL_DISABLE);
	srv_SetPalette();
}

void srv_CreateScreen(void)
{
	Uint32 videoflags;
	int    done;
	SDL_Event event;
	int width, height, bpp;

	if ( SDL_Init(SDL_INIT_VIDEO) < 0 ) 
	{
		sprintf(msg, "Couldn't initialize SDL: %s\n",SDL_GetError());
		srv_print(msg);
		exit(1);
	}

	SDL_WM_SetIcon(SDL_LoadBMP("z26win.bmp"), NULL);

        switch(VideoMode){
                case 0:
                        width = 400;
                        height = 300;
                        Vert = 20;
                        Horiz = 40;
                break;
                case 1:
                        width = 320;
                        height = 240;
                        Vert = 0;
                        Horiz = 0;
                break;
                case 2:
                        width = 320;
                        height = 200;
                        Vert = 0;
                        Horiz = 0;
                break;
                case 3:
                case 6:
                        width = 800;
                        height = 600;
                        Vert = 40;
                        Horiz = 80;
                break;
                case 4:
                case 7:
                        width = 640;
                        height = 480;
                        Vert = 0;
                        Horiz = 0;
                break;
                case 5:
                case 8:
                        width = 640;
                        height = 400;
                        Vert = 0;
                        Horiz = 0;
                break;
                default:
                        width = 400;
                        height = 300;
                        Vert = 20;
                        Horiz = 40;
                break;
        };
	bpp = 8;
	videoflags = 0;
//	videoflags |= SDL_SWSURFACE;
	if (InWindow == 0)
		videoflags |= SDL_FULLSCREEN;
	videoflags |= SDL_HWSURFACE;

	if (NoRetrace == 0)
	{
		videoflags |= SDL_DOUBLEBUF;
	}

	CreateScreen(width, height, bpp, videoflags);
}


void srv_DestroyScreen()
{
	SDL_Quit();
}


void srv_WindowScreen()
{
	InWindow = !InWindow;
	if (InWindow && (NoRetrace == 0))
	{
		OriginalNoRetrace = NoRetrace;
		NoRetrace = -1;
	}
	if (!InWindow)
	{
		NoRetrace = OriginalNoRetrace;
	}
	srv_CreateScreen();
}





int Ticks = 0;
int Flips = 0;

int FirstFlipTime = 0;
int ThisFlipTime = 0;
int LastFlipTime = 0;

int LastFlips = 0;
int ThisFlips = 0;

int CurrentFPS = 0;

void srv_Flip()
{
	int Rate;
	int NextTick;
	int Now;

	if (++Flips == FrameExit/20) FirstFlipTime = SDL_GetTicks();

	if (Flips % 20 == 0)
	{
		if ((SDL_GetTicks() - LastFlipTime) > 500)
		{
			ThisFlipTime = SDL_GetTicks();
			ThisFlips = Flips;
			CurrentFPS = (1000*(ThisFlips - LastFlips))/(ThisFlipTime - LastFlipTime);
			LastFlipTime = ThisFlipTime;
			LastFlips = ThisFlips;
		}
	}

	if (NoRetrace == 0)
	{
		SDL_Flip(srv_screen);
	}
	else
	{
		if (NoRetrace != -1)	Rate = 1000/NoRetrace;
                else
                        if ((PaletteNumber==1)||(PaletteNumber==2)) /* PAL/SECAM */
                                Rate = LinesInFrame*1000/15556;
                        else    Rate = LinesInFrame*1000/15700;

		NextTick = Ticks+Rate;
		Now = SDL_GetTicks();

		NextTick = Ticks + Rate;
		if ((NextTick-Now) > 0)
			SDL_Delay(NextTick-Now);
		Ticks = SDL_GetTicks();

                SDL_UpdateRect(srv_screen, 0, 0, 0, 0);
	}

}

void srv_CopyScreen()
{
	int i,j;
	db *p;
	db *q;
	db ch;

        static int odd = 0;

//	if(ShowLineCount) show_scanlines();

        odd++;                  // alternate startline for interlaced display

	if ( SDL_LockSurface(srv_screen) < 0 ) 
	{
		sprintf(msg, "Couldn't lock display surface: %s\n", SDL_GetError());
		srv_print(msg);
		return;
	}

	srv_buffer = srv_screen->pixels;
	srv_pitch = srv_screen->pitch;

	emu_pixels = ScreenBuffer;
        emu_pixels_prev = ScreenBufferPrev;

        if ((DisableCompareCopy!=0)||((Flips & 0x2e)==0x2e))
        {
                if (EnableFastCopy)
                {
                        screen_pixels = srv_buffer + Horiz + 80 + (Vert)*srv_pitch;
                        for (i=0; i<MaxLines; ++i)
                        {
                                FDoLinearCopy();
                                emu_pixels += 160;
                                screen_pixels += srv_pitch;
                        }
                }
                else if ((VideoMode>=3)&&(VideoMode<=5))  /* simulate scanlines */
                {
                        screen_pixels = srv_buffer + Horiz + (Vert)*srv_pitch;
                        if ((DoInterlace) && (odd & 1)) screen_pixels += srv_pitch;
                        for (i=0; i<MaxLines; ++i)
                        {
                                DoWideLinearCopy();
                                emu_pixels += 160;
                                screen_pixels += (2 * srv_pitch);
                        }
                }
                else if ((VideoMode>=6)&&(VideoMode<=8))  /* no scanlines */
                {
                        screen_pixels = srv_buffer + Horiz + (Vert)*srv_pitch;
                        for (i=0; i<MaxLines; ++i)
                        {
                                DoWideLinearCopy();
                                screen_pixels += (srv_pitch);
                                DoWideLinearCopy();
                                emu_pixels += 160;
                                screen_pixels += (srv_pitch);
                        }
                }
                else
                {
                        screen_pixels = srv_buffer + Horiz + (Vert)*srv_pitch;
                        for (i=0; i<MaxLines; ++i)
                        {
                                DoLinearCopy();
                                emu_pixels += 160;
                                screen_pixels += srv_pitch;
                        }

                }
        }
        else    /* Compare-Copy routines enabled */
        {
                if (EnableFastCopy)
                {
                        screen_pixels = srv_buffer + Horiz + 80 + (Vert)*srv_pitch;
                        for (i=0; i<MaxLines; ++i)
                        {
                                CFDoLinearCopy();
                                emu_pixels += 160;
                                emu_pixels_prev += 160;
                                screen_pixels += srv_pitch;
                        }
                }
                else if ((VideoMode>=3)&&(VideoMode<=5))  /* simulate scanlines */
                {
                        screen_pixels = srv_buffer + Horiz + (Vert)*srv_pitch;
                        if ((DoInterlace) && (odd & 1)) screen_pixels += srv_pitch;
                        for (i=0; i<MaxLines; ++i)
                        {
                                CDoWideLinearCopy();
                                emu_pixels += 160;
                                emu_pixels_prev += 160;
                                screen_pixels += (2 * srv_pitch);
                        }
                }
                else if ((VideoMode>=6)&&(VideoMode<=8))  /* no scanlines */
                {
                        screen_pixels = srv_buffer + Horiz + (Vert)*srv_pitch;
                        for (i=0; i<MaxLines; ++i)
                        {
                                CDoWideLinearCopy();
                                screen_pixels += (srv_pitch);
                                CDoWideLinearCopy();
                                emu_pixels += 160;
                                emu_pixels_prev += 160;
                                screen_pixels += (srv_pitch);
                        }
                }
                else
                {
                        screen_pixels = srv_buffer + Horiz + (Vert)*srv_pitch;
                        for (i=0; i<MaxLines; ++i)
                        {
                                CDoLinearCopy();
                                emu_pixels += 160;
                                emu_pixels_prev += 160;
                                screen_pixels += srv_pitch;
                        }

                }
        }

        if((NoRetrace == 0) || (DoInterlace && (VideoMode >= 3) && (VideoMode <= 5)))
        {
                screen_buffer_count = (screen_buffer_count + 1) & 0x03;

                switch(screen_buffer_count)
                {
                        case 0:
                                ScreenBuffer = RealScreenBuffer1;
                                ScreenBufferPrev = RealScreenBuffer2;
                        break;
                        case 1:
                                ScreenBuffer = RealScreenBuffer3;
                                ScreenBufferPrev = RealScreenBuffer4;
                        break;
                        case 2:
                                ScreenBuffer = RealScreenBuffer2;
                                ScreenBufferPrev = RealScreenBuffer1;
                        break;
                        case 3:
                                ScreenBuffer = RealScreenBuffer4;
                                ScreenBufferPrev = RealScreenBuffer3;
                        break;
                }
        }
        else
        {
                screen_buffer_count = (screen_buffer_count + 1) & 0x01;

                switch(screen_buffer_count)
                {
                        case 0:
                                ScreenBuffer = RealScreenBuffer1;
                                ScreenBufferPrev = RealScreenBuffer2;
                        break;
                        case 1:
                                ScreenBuffer = RealScreenBuffer2;
                                ScreenBufferPrev = RealScreenBuffer1;
                        break;
                }
        }

	if (ShowLineCount)
	{
		show_scanlines();
//		show_FPS();
	}

	SDL_UnlockSurface(srv_screen);
//        SDL_UpdateRect(srv_screen, 0, 0, 0, 0);
}

/*
** sound stuff
*/

extern Tia_process();

srv_lock_audio()
{
	SDL_LockAudio();
}



srv_unlock_audio()
{
	SDL_UnlockAudio();
}

Uint8   *DMABuf;
int	bufsize;

void fillerup(void *unused, Uint8 *stream, int len)
{
	static int bufnum = 0;
	Uint8 soundval;
	int i;

	DMABuf = stream;
	bufsize = len;

	Tia_process();

}

srv_sound_on()
{
	SDL_AudioSpec spec;

	if (quiet==0)
	{
		if ( SDL_Init(SDL_INIT_AUDIO) < 0 ) 
		{
			sprintf(msg, "Couldn't initialize SDL: %s\n",SDL_GetError());
			srv_print(msg);
			exit(1);
		}

		spec.callback = fillerup;
		spec.freq = 31400;
		spec.format = AUDIO_U8;
		spec.channels = 1;
		spec.samples = SQ_Max/3;	/* 1536 */

		if ( SDL_OpenAudio(&spec, NULL) < 0 ) 
		{
			sprintf(msg, "Couldn't open audio: %s\n", SDL_GetError());
			srv_print(msg);
			exit(2);
		}
		SDL_PauseAudio(0);
	}
}

srv_sound_off()
{
	if (quiet==0)
	{
		SDL_CloseAudio();
	}
}


/*
** mouse stuff
*/

db srv_mouse_button;
int srv_micky_x, srv_micky_y;
int srv_mouse_x, srv_mouse_y;

srv_get_mouse_button_status()
{
	srv_mouse_button = SDL_GetMouseState(&srv_mouse_x, &srv_mouse_y);
}

srv_get_mouse_movement()
{
	srv_mouse_button = SDL_GetRelativeMouseState(&srv_micky_x, &srv_micky_y);
}


/*
** event handler
*/

srv_Events()
{
	SDL_Event event;
	dd sc;

	while ( SDL_PollEvent(&event) ) {
		switch (event.type) {

			case SDL_KEYDOWN:
				sc = event.key.keysym.scancode & 0x7f;
				KeyTable[sc] = 0x80;
				break;

			case SDL_KEYUP:
				sc = event.key.keysym.scancode & 0x7f;
				KeyTable[sc] = 0;
				break;

			case SDL_QUIT:
				srv_done = 1;
				break;

			default:
				break;
		}
	}
}

