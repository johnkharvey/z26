/*
** sdlvideo.c -- SDL video code
*/

dd video_mode_quiet = 0;

const SDL_VideoInfo *screen_info;

SDL_Surface *screen_surface;

#include "sdlpixcopy.c"

#ifdef WINDOWS
extern void CFDoLinearCopy();
extern void CDoLinearCopy();
extern void CDoWideLinearCopy();
extern void FDoLinearCopy();
extern void DoLinearCopy();
extern void DoWideLinearCopy();
#endif

void ClearScreenBuffers()
{
	if (PageFlipping())
	{
		memset(RealScreenBuffer1, 0,	MaxLines*tiawidth);
		memset(RealScreenBuffer2, 0,	MaxLines*tiawidth);
		memset(RealScreenBuffer3, 0x80, MaxLines*tiawidth);
		memset(RealScreenBuffer4, 0x80, MaxLines*tiawidth);
	}
	else
	{
		memset(RealScreenBuffer1, 0,    MaxLines*tiawidth);
		memset(RealScreenBuffer2, 0x80, MaxLines*tiawidth);
		memset(RealScreenBuffer3, 0,    MaxLines*tiawidth);
		memset(RealScreenBuffer4, 0x80, MaxLines*tiawidth);
	}
}


void CreateScreen()	// need to be able to force video mode change
{			// in case of effect change
	dd pixdepth = 0;
	dd flags = SDL_SWSURFACE;
	
	if (PageFlipping()) flags = SDL_HWSURFACE | SDL_DOUBLEBUF;
	
	if (FullScreen) flags |= SDL_FULLSCREEN;
		
	if (screen_bpp == 8)			pixdepth = 8;
	else if (screen_bpp == 16) 		pixdepth = 16;
	else if (screen_bpp == 24)		pixdepth = 24;
	else			   		pixdepth = 32;

	srv_screen = SDL_SetVideoMode(width, height, pixdepth, flags);
			
	if ( srv_screen == NULL ) 
	{
		if (video_mode_quiet)	// called from srv_print
		{
			printf("Couldn't set messaging mode.\n");
			SDL_Quit();
			exit(1);
		}
		else
		{
			sprintf(msg, "Couldn't set display mode.");
			srv_print(msg);
			return;
		}
	}

	srv_pitch = srv_screen->pitch;

	SDL_WM_SetCaption(FileName, FileName);
	
	if (MouseRude|FullScreen)
		SDL_ShowCursor(SDL_DISABLE);
	else	
		SDL_ShowCursor(SDL_ENABLE);
}


db srv_Phosphor(int c1, int c2)
{
	dd i;

	if (c2 > c1)
	{
		i = c2;
		c2 = c1;
		c1 = i;
	}
	i = ((c1-c2)*Phosphor)/100 + c2;
	return i;
}

/*
** set up the palette
*/

void srv_SetPalette()
{
	dd i,j;
	db red, grn, blu;
	SDL_Color palette[256];

	GeneratePalette();
	for ( i=0; i<128; i++)
	{
		red = PCXPalette[3*i];
		grn = PCXPalette[3*i+1];
		blu = PCXPalette[3*i+2];

		palette[i].r = red;
		palette[i].g = grn;
		palette[i].b = blu;

		srv_colortab[i] = SDL_MapRGB(srv_screen->format, red, grn, blu);
//		srv_colorsoft[i] = SDL_MapRGB(screen_info->vfmt, red*9/10, grn*9/10, blu*9/10);
	}
	
	if (screen_bpp == 8)
		SDL_SetColors(srv_screen, palette, 0, 256);

	if (Phosphor)
	{
		for ( i=0; i<128; i++)
		{
			for ( j=0; j<128; j++)
			{
			red = srv_Phosphor(PCXPalette[3*i], PCXPalette[3*j]);
			grn = srv_Phosphor(PCXPalette[3*i+1], PCXPalette[3*j+1]);
			blu = srv_Phosphor(PCXPalette[3*i+2], PCXPalette[3*j+2]);

			srv_average[i][j] = SDL_MapRGB(srv_screen->format, red, grn, blu);
//			srv_averagesoft[i][j] = SDL_MapRGB(screen_info->vfmt, red*9/10, grn*9/10, blu*9/10);
			}
		}
	}
}


void srv_SetVideoMode() {
	dd i;

	/* If user gave a valid video mode, use it, or else use default */
	if (VideoMode > 8) 
	{
		if (screen_height >= 480)
			VideoMode = 2;
		else
			VideoMode = 1;
	}
	
	srv_CreateIcon();
	SDL_WM_SetIcon(z26Icon, z26IconMask);

	if (JoystickEnabled)	/* joystick support not disabled with -iJ */
	{
		SDL_InitSubSystem(SDL_INIT_JOYSTICK);
		if ((SDL_NumJoysticks()>0)&&(SDL_NumJoysticks()<17))
		{
			for (i=0; i<SDL_NumJoysticks(); i++)
			{
				JoystickTable[i]=SDL_JoystickOpen(i);
				/* Stelladaptor only has 2 buttons and 2 axes */
				if ((SDL_JoystickNumAxes(JoystickTable[i]) == 2) &&
				    (SDL_JoystickNumButtons(JoystickTable[i]) == 2) &&
				    (SDL_JoystickNumHats(JoystickTable[i]) == 0) &&
				    (SDL_JoystickNumBalls(JoystickTable[i]) == 0) &&
				    (StelladaptorEnabled))
				{
					Stelladaptor[i] = 1;
				}
				else Stelladaptor[i] = 0;
			}
//			SDL_JoystickEventState(SDL_ENABLE);
		}
		else JoystickEnabled = 0;	/* disable joystick polling */
	}

	switch(VideoMode)
	{
	default:
	case 0:	 MaxLines = 200; width = 320;  height = 200;  break;
	case 1:	 MaxLines = 240; width = 320;  height = 240;  break;
	case 2:	 MaxLines = 240; width = 640;  height = 480;  break;
	case 3:	 MaxLines = 256; width = 800;  height = 600;  break;
	case 4:	 MaxLines = 200; width = 1024; height = 600;  break;
	case 5:	 MaxLines = 256; width = 1024; height = 768;  break;
	case 6:	 MaxLines = 200; width = 1200; height = 800;  break;
	case 7:	 MaxLines = 225; width = 1200; height = 900;  break;
	case 8:	 MaxLines = 256; width = 1280; height = 1024;  break;
	}

	if ((width > screen_width) || (height > screen_height))		// mode too big -- wrap to zero
	{
		VideoMode = 0; MaxLines = 200; width = 320; height = 200;
	}

	scanlinespread = height / MaxLines;

//	if (Narrow == -1)	// running wide
//	{
//		width = screen_width;
//	}

	pixelspread = width / tiawidth;
	pixelspread -= Narrow;
	if (pixelspread <= 0) pixelspread = 1;

	if (InDesktop)
	{
		width = screen_width;
		height = screen_height;
	}

	if (!FullScreen)
	{
		height = scanlinespread*MaxLines;
		width = pixelspread*tiawidth;
	}

	ClearScreenBuffers();
	CreateScreen();
	srv_SetPalette();

	if(GrabInput) SDL_WM_GrabInput(SDL_GRAB_ON);
	
	position_game(); 	/* set game's vertical position */
}


void srv_CopyScreen()
{
 	void (*copy)();
	dd bpp = srv_screen->format->BytesPerPixel;
	dd i;
	dd oldpixelspread = pixelspread;
	
	odd++;		  // alternate startline for interlaced display
	
	if (tiawidth == 160) pixelspread *= 2;	// for the narrow tia engine

	Vert = 0;
	Horiz = 0;

	if (FullScreen)
	{
		Vert = (height - scanlinespread*MaxLines) / 2;
		Horiz = (width - pixelspread*tiawidth) / 2;
	}

	if (PageFlipping())
		if (SDL_LockSurface(srv_screen) < 0) 
		{
			sprintf(msg, "Couldn't lock display surface: %s\n\nExiting...", SDL_GetError());
			srv_print(msg);
			exit(1);
			return;
		}

	srv_buffer = srv_screen->pixels;
	srv_pitch = srv_screen->pitch;

	emu_pixels = ScreenBuffer;
	emu_pixels_prev = ScreenBufferPrev;
	prev_emu_pixels = PrevScreenBuffer;
	prev_emu_pixels_prev = PrevScreenBufferPrev;
	
	if (screen_bpp == 8)
		copy = PixCopy8;
	else if (screen_bpp == 16)			
		{ if (Phosphor) copy = PixAv16; else copy = PixCopy16; }
	else if (screen_bpp == 24)			
		{ if (Phosphor) copy = PixAv24; else copy = PixCopy24; }
	else						
		{ if (Phosphor) copy = PixAv32; else copy = PixCopy32; }

#ifndef C_ENGINE
#ifdef WINDOWS
	if ((copy == PixCopy8) && (tiawidth == 160) && (scanlinespread == 1))
	{
		switch (pixelspread)
		{
		case 1:	copy = CFDoLinearCopy;		break;
		case 2:	copy = CDoLinearCopy;		break;
		case 4:	copy = CDoWideLinearCopy;	break;
		}
	}
#endif
#endif

	screen_pixels = srv_buffer + Horiz*bpp + (Vert)*srv_pitch;

	if (status_timer > 0) 
		{
			show_transient_status();
			status_timer--;
		}
		else if (ShowLineCount && !GamePaused)
		{
			show_scanlines();
		}

	if (DoInterlace && ((scanlinespread % 2) == 0))
	{
		if (odd & 1) screen_pixels += (scanlinespread / 2) * srv_pitch;
		lines2draw = scanlinespread / 2;
	}
	else if (DoScanline && (scanlinespread > 1))
		lines2draw = scanlinespread - 1;
	else	lines2draw = scanlinespread;
	
	for (i=0; i<MaxLines; ++i)
	{	
		(*copy)();
		screen_pixels += scanlinespread * srv_pitch;
		emu_pixels += tiawidth;
		emu_pixels_prev += tiawidth;
		prev_emu_pixels += tiawidth;
		prev_emu_pixels_prev += tiawidth;
	}
	
	pixelspread = oldpixelspread;
	
	if (PageFlipping()) SDL_UnlockSurface(srv_screen);
}


void gui_CopyScreen()
{
	db oldPhosphor = Phosphor;
	db oldDoInterlace = DoInterlace;
	dd oldpixelspread = pixelspread;
	dd oldtiawidth = tiawidth;
	
	Phosphor = 0;
	DoInterlace = 0;
	tiawidth = 320;
	
	srv_CopyScreen();
	
	pixelspread = oldpixelspread;
	Phosphor = oldPhosphor;
	DoInterlace = oldDoInterlace;
	tiawidth = oldtiawidth;
	if (PageFlipping()) 
		SDL_Flip(srv_screen);
	else
		SDL_UpdateRect(srv_screen, 0, 0, 0, 0);
}



/**
** z26 is Copyright 1997-2011 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
