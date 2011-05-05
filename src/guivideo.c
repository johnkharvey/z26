/*
** guivideo.c -- video menu
*/

int video_current = 0;	/* currently selected GUI option */
int exit_video = 0;	/* exit video menu */

char startline_data[26];
char screen_data[26];
char line_data[26];
char narrow_data[26];
char vid_mode_data[26];
char phosphor_data[26];
char colourloss_data[26];
char eight_bit_data[26];
char width_data[26];

void set_screen_string() {
	if (InDesktop && FullScreen)	sprintf(screen_data, "Desktop");
	else if (FullScreen)		sprintf(screen_data, "Full Screen");
	else				sprintf(screen_data, "Window");
}

void set_line_string() {
	if (DoInterlace) 		sprintf(line_data, "Interlaced");
	else if (DoScanline)		sprintf(line_data, "Scanline");
	else 				sprintf(line_data, "Normal");
}

void set_width_string() {
//	if (Narrow == -1)		sprintf(width_data, "Wide");
	if (Narrow == 0)		sprintf(width_data, "Normal");
	if (Narrow == 1)		sprintf(width_data, "Narrow");
}

void set_startline_string() {
	if (UserCFirst < 0) sprintf(startline_data, "Auto");
	else
	{
		switch (UserCFirst)
		{
		case 0xffff:	sprintf(startline_data, "Auto");		break;
		default: 	sprintf(startline_data, "%d", UserCFirst);	break;
		}
	}
}

void set_videomode_string() {
	switch (VideoMode)
	{
	case 0:	 sprintf(vid_mode_data, "%d-320x200", VideoMode);	break;
	case 1:	 sprintf(vid_mode_data, "%d-320x240", VideoMode);	break;
	case 2:	 sprintf(vid_mode_data, "%d-640x480", VideoMode);	break;
	case 3:	 sprintf(vid_mode_data, "%d-800x600", VideoMode);	break;
	case 4:	 sprintf(vid_mode_data, "%d-1024x600", VideoMode);	break;
	case 5:	 sprintf(vid_mode_data, "%d-1024x768", VideoMode);	break;
	case 6:	 sprintf(vid_mode_data, "%d-1200x800", VideoMode);	break;
	case 7:	 sprintf(vid_mode_data, "%d-1200x900", VideoMode);	break;
	case 8:	 sprintf(vid_mode_data, "%d-1280x1024", VideoMode);	break;
	default: sprintf(vid_mode_data, "whoops");			break;
	}
}

void set_phosphor_string() {
	if (UserPhosphor == 0) sprintf(phosphor_data, "Off");
	else sprintf(phosphor_data, "%d", UserPhosphor);
}

void hand_screen_inc() {
	if (InDesktop && FullScreen) InDesktop = 0;			// desktop -> fullscreen
	else if (FullScreen)	     FullScreen = 0;			// fullscreen -> window
	else 			     { InDesktop = 1; FullScreen = 1; }	// window -> desktop
	set_screen_string();
	srv_SetVideoMode();
}

void hand_screen_dec() {
	if (InDesktop && FullScreen) { FullScreen = 0; InDesktop = 0; }	// desktop -> window
	else if (FullScreen)	     { FullScreen = 1; InDesktop = 1; }	// fullscreen -> desktop
	else 			     { InDesktop = 0; FullScreen = 1; }	// window -> fullscreen
	set_screen_string();
	srv_SetVideoMode();
}

void hand_line_inc() {
	if (DoInterlace)	{ DoInterlace = 0; DoScanline = 0; }	// interlace -> normal
	else if (DoScanline)	{ DoScanline = 0; DoInterlace = 1; }	// scanline -> interlace
	else 			{ DoScanline = 1; }			// normal -> scanline
	set_line_string();
	srv_SetVideoMode();
}

void hand_line_dec() {
	if (DoInterlace)	{ DoInterlace = 0; DoScanline = 1; }	// interlace -> scanline
	else if (DoScanline)	{ DoScanline = 0; DoInterlace = 0; }	// scanline -> normal
	else 			{ DoInterlace = 1; }			// normal -> interlace
	set_line_string();
	srv_SetVideoMode();
}

void hand_narrow() {
	if (Narrow == 1) Narrow = 0;
	else		 ++Narrow;
	set_width_string();
	srv_SetVideoMode();
}

void hand_colourloss() {
	SimColourLoss = !SimColourLoss;
	set_yesno_string(colourloss_data, SimColourLoss);
}

void hand_startline_inc() {
	if (UserCFirst == 0xffff) UserCFirst = 10;
	else if (UserCFirst >= 100) UserCFirst = 0xffff;
	else ++UserCFirst;
	set_startline_string();
}

void hand_startline_dec() {
	if (UserCFirst <= 10) UserCFirst = 0xffff;
	else if (UserCFirst == 0xffff) UserCFirst = 100;
	else --UserCFirst;
	set_startline_string();
}

void hand_phosphor_inc() {
	if (UserPhosphor >= 100) UserPhosphor = 0;
	else ++UserPhosphor;
	set_phosphor_string();
}

void hand_phosphor_dec() {
	if (UserPhosphor == 0) UserPhosphor = 100;
	else --UserPhosphor;
	set_phosphor_string();
}
void hand_vid_inc()
{
	VideoMode += 1;
	if (VideoMode > 8) VideoMode = 0;
	srv_SetVideoMode();
	set_videomode_string();
}

void hand_vid_dec()
{
	if (VideoMode == 0) 
		VideoMode = 8;
	else
		VideoMode -= 1;
	srv_SetVideoMode();
	set_videomode_string();
}

void hand_video_exit() {
	exit_video = 1;
}

gui_entry video_gui_items[] = {
	{ " Start Line.: %s", startline_data, 0, hand_startline_inc, hand_startline_dec },
	{ " Video Mode.: %s", vid_mode_data, 0, hand_vid_inc, hand_vid_dec },
	{ " Width......: %s ", width_data, 0, hand_narrow, hand_narrow },
	{ " Display....: %s", screen_data, 0, hand_screen_inc, hand_screen_dec },
	{ " Line Mode..: %s", line_data, 0, hand_line_inc, hand_line_dec },
	{ " Phosphor...: %s ", phosphor_data, 0, hand_phosphor_inc, hand_phosphor_dec },
	{ " Colour Loss: %s ", colourloss_data, 0, hand_colourloss, hand_colourloss },
	{ " ", NULL, 0, NULL, NULL },
	{ " Exit ", NULL, 0, hand_video_exit, NULL },
	{ NULL, NULL, 0, NULL, NULL } // last element must always be this
};

/* Main entry point. Called by gui() */

void video_gui() {
	SDL_Event ev;
	int action;
	
	set_yesno_string(narrow_data, Narrow);
	set_yesno_string(colourloss_data, SimColourLoss);
	set_screen_string();
	set_line_string();
	set_videomode_string();
	set_width_string();
	set_phosphor_string();
	set_startline_string();
	
	exit_video = 0;
	while( !exit_video ) {
		status_timer = 0;
		
		sprintf(msg, "Video Options");
		draw_gui(video_gui_items, video_current);
		
		SDL_WaitEvent(&ev);	/* TODO: respond to SDL_QUIT events */
		action = gui_navigation(&ev);
		if(action == GUI_NO_ACTION) continue;
		
		video_current = gui_handle_action(action, &exit_video, video_gui_items, video_current);
	}
}

/**
** z26 is Copyright 1997-2011 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the
** GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
