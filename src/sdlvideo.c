/*
	sdlvideo.c -- SDL video code
*/

SDL_Surface *screen_surface;

#include "sdlpixcopy.c"

void ClearScreenBuffers()
{
	memset(RealScreenBuffer1, 0,    MaxLines*tiawidth);
	memset(RealScreenBuffer2, 0x80, MaxLines*tiawidth);
	memset(texture_buffer, 0, 4*1280*1280);
}

void CreateScreen()	// need to be able to force video mode change
{
	gl_CreateScreen();
	srv_pitch = srv_screen->pitch;
	SDL_SetWindowTitle(window, FileName);

	if (FullScreen)
		SDL_ShowCursor(SDL_DISABLE);
	else	
		SDL_ShowCursor(SDL_ENABLE);
}

void srv_SetPalette()
{
	int i;
	dd hi = Depth;
	dd med = (Depth + 100)/2;
	db red, grn, blu;

	GeneratePalette();
	for ( i=0; i<128; i++)
	{
		red = PCXPalette[3*i];
		grn = PCXPalette[3*i+1];
		blu = PCXPalette[3*i+2];

		srv_colortab_hi[i] =  SDL_MapRGB(srv_screen->format, red, grn, blu);
		srv_colortab_med[i] = SDL_MapRGB(srv_screen->format, (red*med)/100, (grn*med)/100, (blu*med)/100);
		srv_colortab_low[i] = SDL_MapRGB(srv_screen->format, (red*hi)/100,  (grn*hi)/100,  (blu*hi)/100);
	}
}

void srv_InitJoystick() {
dd i;

	if (JoystickEnabled)	/* joystick support not disabled with -iJ */
	{
		SDL_InitSubSystem(SDL_INIT_JOYSTICK);
		if ((SDL_NumJoysticks()>0)&&(SDL_NumJoysticks()<17))
		{
			for (i=0; i<SDL_NumJoysticks(); i++)
			{
				JoystickTable[i]=SDL_JoystickOpen(i);
			}
//			SDL_JoystickEventState(SDL_ENABLE);
		}
		else JoystickEnabled = 0;	/* disable joystick polling */
	}

}

void srv_ChooseScreenResolution()
{
	switch(VideoMode)
	{
	default:
	case 0:	win_width = 640;  tex_width = 512;  tex_height = 512;  
			srv_screen = small_screen; 
			break;
	
	case 1:	win_width = 640;  tex_width = 512;  tex_height = 512;  
			srv_screen = small_screen; 
			break;
	
	case 2:	win_width = 1280;  tex_width = 1024; tex_height = 1024; 
			srv_screen = large_screen; 
			break;
	
	case 3:	win_width = 1280;  tex_width = 1024; tex_height = 1024; 
			srv_screen = large_screen; 
			break;
	
	case 4:	win_width = 320;  tex_width = 256;  tex_height = 256;  
			srv_screen = tiny_screen;  
			break;
	
	case 5:	win_width = 320;  tex_width = 256;  tex_height = 256;  
			srv_screen = tiny_screen;  
			break;
	}
	MaxLines = 256;
	win_height = tex_height;
}

void srv_set_screen_size(void)
{
	screen_width = win_width;
	screen_height = win_height;

	if (FullScreen)
	{
		SDL_DisplayMode DM;
		SDL_GetCurrentDisplayMode(0, &DM);
		screen_width = DM.w;
		screen_height = DM.h;
	}

}

void srv_set_fullscreen(void)
{
	if (FullScreen)
	{
		SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN_DESKTOP);
	}
	else
	{
		SDL_SetWindowFullscreen(window, 0);
	}
	
}

void srv_SetVideoMode() {

	if (VideoMode > 5) VideoMode = 4; 

	srv_InitJoystick();

	srv_set_fullscreen();
	srv_ChooseScreenResolution();
	srv_set_screen_size();
	SDL_SetWindowSize(window, screen_width, screen_height);
	SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
//	srv_set_fullscreen();

	scanlinespread = tex_height / MaxLines;

	pixelspread = tex_width / tiawidth;
	if (pixelspread == 0) pixelspread = 1;

	ClearScreenBuffers();
	CreateScreen();
	srv_SetPalette();

	position_game();
}

void srv_CopyScreen()
{
 	void (*copy)();
	dd i;

	srv_buffer = srv_screen->pixels;
	srv_pitch = srv_screen->pitch;

	emu_pixels = ScreenBuffer;
	emu_pixels_prev = ScreenBufferPrev;
	screen_pixels = srv_buffer;
	
	if (status_timer > 0) 
		{
			show_transient_status();
			status_timer--;
		}
		else if (ShowLineCount && !GamePaused)
		{
			show_scanlines();
		}
	
	lines2draw = scanlinespread;

	copy = PixCopy32_1;
	if (scanlinespread == 1)	 	copy = PixCopy32_1;
	else if (scanlinespread == 2)	copy = PixCopy32_2;
	else if (scanlinespread == 4)	copy = PixCopy32_4;

	for (i=0; i<MaxLines; ++i)
	{	
		(*copy)();
		screen_pixels += scanlinespread * srv_pitch;
		emu_pixels += tiawidth;
		emu_pixels_prev += tiawidth;
	}

	gl_DrawScreen();
	srv_Flip();
}

void gui_CopyScreen()
{
	int oldtiawidth = tiawidth;
	int oldscanline = DoScanline;
	tiawidth = 320;
	if ((VideoMode == 4) || (VideoMode == 5)) DoScanline = 0;
	srv_CopyScreen();
	tiawidth = oldtiawidth;
	DoScanline = oldscanline;
}


/**
	z26 is Copyright 1997-2019 by John Saeger and contributors.  
	z26 is released subject to the terms and conditions of the 
	GNU General Public License Version 2 (GPL).	
	z26 comes with no warranty.
	Please see COPYING.TXT for details.
*/
