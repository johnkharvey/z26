/*
** sdlsrv.c -- SDL service code
*/

SDL_Joystick *JoystickTable[16];

SDL_Surface *srv_screen = NULL;
SDL_Surface *small_screen = NULL;
SDL_Surface *large_screen = NULL;
SDL_Surface *tiny_screen = NULL;

db *srv_buffer;
dd srv_pitch;

dd Vert, Horiz;		/* offsets into window or video display where 2600 pixels are rendered in pixels*/
dd width, height;	/* dimensions of current window or video display in pixels */

db *screen_pixels;      /* pointer to display screen */
db *emu_pixels;         /* pointer to current emulator buffer */
db *emu_pixels_prev;    /* pointer to previous emulator buffer */
db *prev_emu_pixels;	/* previous pointer to display screen */
db *prev_emu_pixels_prev; /* previous pointer to previous emulator buffer */

db screen_buffer_count = 0;
db srv_done = 0;
dd odd = 0;		/* is the frame number odd? -- for interlaced modes */

dd srv_colortab_hi[128];		/* for mapping atari 8-bit colors to 32-bit colors */
dd srv_colortab_med[128];		/* for soft scanlines */
dd srv_colortab_low[128];

#include "sdlicon.c"
#include "sdlopengl.c"
#include "sdlflip.c"
#include "sdlvideo.c"
#include "sdlsound.c"
#include "sdlmouse.c"

void Init_SDL()
{
	Init_SoundQ();

	if ( SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_AUDIO) < 0 ) 
	{
		printf("Couldn't initialize SDL: %s\n",SDL_GetError());
		exit(1);
	}
	
	screen_info = SDL_GetVideoInfo();
	screen_bpp = screen_info->vfmt->BitsPerPixel;
	
	gl_InitOpenGL();
	
	small_screen = SDL_CreateRGBSurfaceFrom(&texture_buffer, 512, 512, 32, 4*512, 0, 0, 0, 0);
	large_screen = SDL_CreateRGBSurfaceFrom(&texture_buffer, 1024, 1024, 32, 4*1024, 0, 0, 0, 0);
	tiny_screen =  SDL_CreateRGBSurfaceFrom(&texture_buffer, 256, 256, 32, 4*256, 0, 0, 0, 0);
	
	srv_screen = small_screen;

	screen_buffer_count = 0;
	
	ScreenBuffer = RealScreenBuffer1;
	ScreenBufferPrev = RealScreenBuffer2;
        PrevScreenBuffer = RealScreenBuffer3;
        PrevScreenBufferPrev = RealScreenBuffer4;
	
	ClearScreenBuffers();
}


/*
** event handler
*/

void srv_Events()
{
	dd sc;
	SDL_Event event;

	if (JoystickEnabled) SDL_JoystickUpdate();	/* poll joysticks once per frame */

	while ( SDL_PollEvent(&event) ) {
		switch (event.type) {

			case SDL_KEYDOWN:
				sc = event.key.keysym.sym;
				KeyTable[sc] = 0x80;
				break;

			case SDL_KEYUP:
				sc = event.key.keysym.sym;
				KeyTable[sc] = 0;
				break;

			case SDL_QUIT:
				srv_done = 1;
				break;

			case SDL_JOYBUTTONDOWN:
				if (event.jbutton.which < 17)
					JoystickButton[event.jbutton.which][event.jbutton.button] = 0x80;
				break;
				
			case SDL_JOYBUTTONUP:
				if (event.jbutton.which < 17)
					JoystickButton[event.jbutton.which][event.jbutton.button] = 0;
				break;

			case SDL_JOYAXISMOTION:
				if (event.jaxis.which < 17)
					JoystickAxis[event.jaxis.which][event.jaxis.axis] = event.jaxis.value;
				break;
			default:
				break;
		}
	}
}


void Init_Service() {
	srv_SetVideoMode();
	srv_sound_on();
}


void srv_Cleanup() {
	kv_CloseSampleFile();
	srv_sound_off();
}

/**
** z26 is Copyright 1997-2011 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
