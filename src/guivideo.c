/*
	guivideo.c -- video menu
*/

int video_current = 0;	/* currently selected GUI option */
int exit_video = 0;		/* exit video menu */

char startline_data[52];
char screen_data[52];
char line_data[52];
char narrow_data[52];
char vid_mode_data[52];
char Depth_data[52];
char width_data[52];
char vsync_data[52];
char palette_data[52];
char brightness_data[52];
char warmth_data[52];
char NTSC_phase_data[52];
char PAL_phase_data[52];

void set_palette_string() {
	switch(UserPaletteNumber) {
		case 0:
			sprintf(palette_data, "NTSC");
			break;
		case 1:
			sprintf(palette_data, "PAL");
			break;
		case 2:
			sprintf(palette_data, "SECAM");
			break;
		case 3:
			sprintf(palette_data, "vintage NTSC");
			break;
		case 4:
			sprintf(palette_data, "vintage PAL");
			break;
		case 5:
			sprintf(palette_data, "mame 0.212 NTSC");
			break;
		case 6:
			sprintf(palette_data, "mame 0.212 PAL");
			break;
		case 0xff:
			sprintf(palette_data, "Auto");
			break;
	}
}

void hand_palette_inc() {
	if      (UserPaletteNumber == 0xff) UserPaletteNumber = 0;
	else if (UserPaletteNumber == 6) UserPaletteNumber = 0xff;
	else    UserPaletteNumber++;
	
	if (UserPaletteNumber == 0xff) PaletteNumber = 0;
	else PaletteNumber = UserPaletteNumber;
	
	gui_SetVideoMode();
	set_palette_string();
}

void hand_palette_dec() {
	if      (UserPaletteNumber == 0xff) UserPaletteNumber = 6;
	else if (UserPaletteNumber == 0) UserPaletteNumber = 0xff;
	else    UserPaletteNumber--;
	
	if (UserPaletteNumber == 0xff) PaletteNumber = 0;
	else PaletteNumber = UserPaletteNumber;

	gui_SetVideoMode();
	set_palette_string();
}

void set_warmth_string() {
	sprintf(warmth_data, "%1.2lf", warmth);
}

void hand_warmth_inc() {
	if (warmth < 2.0) warmth += 0.05;
	set_warmth_string();
	gui_SetVideoMode();
}

void hand_warmth_dec() {
	if (warmth > -2.0) warmth -= 0.05;
	set_warmth_string();
	gui_SetVideoMode();
}

void set_brightness_string() {
	sprintf(brightness_data, "%1.2lf", brightness);
}

void hand_brightness_inc() {
	if (brightness < 1.9) brightness += 0.05;
	set_brightness_string();
	gui_SetVideoMode();
}

void hand_brightness_dec() {
	if (brightness > 0.2) brightness -= 0.05;
	set_brightness_string();
	gui_SetVideoMode();
}

void set_NTSC_phase_string() {
	sprintf(NTSC_phase_data, "%2.2lf", NTSC_PS);
}

void hand_NTSC_phase_inc() {
	if (NTSC_PS < 32.0) NTSC_PS += 0.05;
	set_NTSC_phase_string();
	gui_SetVideoMode();
}

void hand_NTSC_phase_dec() {
	if (NTSC_PS > 20.01) NTSC_PS -= 0.05;
	set_NTSC_phase_string();
	gui_SetVideoMode();
}

void set_PAL_phase_string() {
	sprintf(PAL_phase_data, "%2.2lf", PAL_PS);
}

void hand_PAL_phase_inc() {
	if (PAL_PS < 23.0) PAL_PS += 0.05;
	set_PAL_phase_string();
	gui_SetVideoMode();
}

void hand_PAL_phase_dec() {
	if (PAL_PS > 20.01) PAL_PS -= 0.05;
	set_PAL_phase_string();
	gui_SetVideoMode();
}

void set_screen_string() {
	if (FullScreen)		sprintf(screen_data, "Full Screen");
	else				sprintf(screen_data, "Window");
}

void set_line_string() {
	if (DoScanline)		sprintf(line_data, "Scanline");
	else 				sprintf(line_data, "Normal");
}

void set_width_string() {
	sprintf(width_data, "%d", width_adjust);
}

void set_videomode_string() {
	switch (VideoMode)
	{
	case 0:	 sprintf(vid_mode_data, "Regular Sharp");		break;
	case 1:	 sprintf(vid_mode_data, "Regular Blurry");		break;
	case 2:  sprintf(vid_mode_data, "HD Sharp");			break;
	case 3:  sprintf(vid_mode_data, "HD Blurry");			break;
	case 4:  sprintf(vid_mode_data, "Fast Sharp");			break;
	case 5:  sprintf(vid_mode_data, "Fast Blurry");			break;
	default: sprintf(vid_mode_data, "whoops");				break;
	}
}

void set_Depth_string() {
	sprintf(Depth_data, "%d", UserDepth);
}

void hand_screen_inc() {
	if (FullScreen) FullScreen = 0; else FullScreen = 1;
	set_screen_string();
	gui_SetVideoMode();
}

void hand_screen_dec() {
	if (FullScreen) FullScreen = 0; else FullScreen = 1;
	set_screen_string();
	gui_SetVideoMode();
}

void hand_line_inc() {
	if (DoScanline)	DoScanline = 0; else DoScanline = 1;
	set_line_string();
	gui_SetVideoMode();
}

void hand_line_dec() {
	if (DoScanline)	DoScanline = 0; else DoScanline = 1;
	set_line_string();
	gui_SetVideoMode();
}

void hand_width_inc() {
	if (++width_adjust > 150) --width_adjust;
	set_width_string();
	gui_SetVideoMode();
}

void hand_width_dec() {
	if (--width_adjust < 50) ++width_adjust;
	set_width_string();
	gui_SetVideoMode();
}

void hand_vsync() {
	Vsync = !Vsync;
	set_yesno_string(vsync_data, Vsync);
	if (SDL_GL_SetSwapInterval(Vsync)) Vsync = !Vsync;
}

void hand_Depth_inc() {
	if (UserDepth >= 100) UserDepth = 0;
	else ++UserDepth;
	set_Depth_string();
	Depth = UserDepth;
	srv_SetPalette();
}

void hand_Depth_dec() {
	if (UserDepth == 0) UserDepth = 100;
	else --UserDepth;
	set_Depth_string();
	Depth = UserDepth;
	srv_SetPalette();
}

void hand_vid_inc()
{
	if (++VideoMode > 5) VideoMode = 0;
	gui_SetVideoMode();
	set_videomode_string();
}

void hand_vid_dec()
{
	if (VideoMode == 0) 
		VideoMode = 5;
	else
		VideoMode -= 1;
	gui_SetVideoMode();
	set_videomode_string();
}

void hand_video_exit() {
	exit_video = 1;
}

gui_entry video_gui_items[] = {
	{ " Display............: %s", screen_data, 0, hand_screen_inc, hand_screen_dec },
	{ " Texture............: %s", vid_mode_data, 0, hand_vid_inc, hand_vid_dec },
	{ " Width..............: %s ", width_data, 0, hand_width_inc, hand_width_dec },
	{ " Line Mode..........: %s", line_data, 0, hand_line_inc, hand_line_dec },
	{ " Scanline Depth.....: %s ", Depth_data, 0, hand_Depth_inc, hand_Depth_dec },
	{ " Vsync..............: %s ", vsync_data, 0, hand_vsync, hand_vsync },
	{ " ", NULL, 0, NULL, NULL },
	{ " Palette............: %s ", palette_data, 0, hand_palette_inc, hand_palette_dec },
	{ " ", NULL, 0, NULL, NULL },
	{ " Brightness.........: %s ", brightness_data, 0, hand_brightness_inc, hand_brightness_dec },
	{ " Warmth.............: %s ", warmth_data, 0, hand_warmth_inc, hand_warmth_dec },
	{ " NTSC Phase.(26.2)..: %s ", NTSC_phase_data, 0, hand_NTSC_phase_inc, hand_NTSC_phase_dec },
	{ " PAL Phase..(21.5)..: %s ", PAL_phase_data, 0, hand_PAL_phase_inc, hand_PAL_phase_dec },

	{ " ", NULL, 0, NULL, NULL },
	{ " Exit ", NULL, 0, hand_video_exit, NULL },
	{ NULL, NULL, 0, NULL, NULL } // last element must always be this
};

gui_entry simple_video_gui_items[] = {
	{ " Display............: %s", screen_data, 0, hand_screen_inc, hand_screen_dec },
	{ " Texture............: %s", vid_mode_data, 0, hand_vid_inc, hand_vid_dec },
	{ " Width..............: %s ", width_data, 0, hand_width_inc, hand_width_dec },
	{ " Vsync..............: %s ", vsync_data, 0, hand_vsync, hand_vsync },
	{ " ", NULL, 0, NULL, NULL },
	{ " Palette............: %s ", palette_data, 0, hand_palette_inc, hand_palette_dec },
	{ " ", NULL, 0, NULL, NULL },
	{ " Brightness.........: %s ", brightness_data, 0, hand_brightness_inc, hand_brightness_dec },
	{ " Warmth.............: %s ", warmth_data, 0, hand_warmth_inc, hand_warmth_dec },
	{ " NTSC Phase.(26.2)..: %s ", NTSC_phase_data, 0, hand_NTSC_phase_inc, hand_NTSC_phase_dec },
	{ " PAL Phase..(21.5)..: %s ", PAL_phase_data, 0, hand_PAL_phase_inc, hand_PAL_phase_dec },

	{ " ", NULL, 0, NULL, NULL },
	{ " Exit ", NULL, 0, hand_video_exit, NULL },
	{ NULL, NULL, 0, NULL, NULL } // last element must always be this
};

/* Main entry point. Called by gui() */

void video_gui() {
	SDL_Event ev;
	int action;
	
	set_yesno_string(vsync_data, Vsync);
	set_screen_string();
	set_line_string();
	set_videomode_string();
	set_width_string();
	set_Depth_string();
	set_palette_string();
	set_brightness_string();
	set_warmth_string();
	set_NTSC_phase_string();
	set_PAL_phase_string();

	exit_video = 0;
	while( !exit_video ) {
		status_timer = 0;
		
		sprintf(msg, "Video Options");
		if (VideoMode < 4)
			draw_gui(video_gui_items, video_current);
		else
			draw_gui(simple_video_gui_items, video_current);
		
		SDL_WaitEvent(&ev);	/* TODO: respond to SDL_QUIT events */
		action = gui_navigation(&ev);
		if(action == GUI_NO_ACTION) continue;
		if (VideoMode < 4)
			video_current = gui_handle_action(action, &exit_video, video_gui_items, video_current);
		else
			video_current = gui_handle_action(action, &exit_video, simple_video_gui_items, video_current);
	}
}

/**
	z26 is Copyright 1997-2019 by John Saeger and contributors.  
	z26 is released subject to the terms and conditions of the
	GNU General Public License Version 2 (GPL).  
	z26 comes with no warranty.
	Please see COPYING.TXT for details.
*/
