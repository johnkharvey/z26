/*
** guitiming.c --  menu
*/

int timing_current = 0;	/* currently selected GUI option */
int exit_timing = 0;	/* exit timing menu */

char framerate_data[26];
char sync_data[26];

void set_framerate_string() {
	if (UserFrameRate == -1) sprintf(framerate_data, "Auto");
	else sprintf(framerate_data, "%d", UserFrameRate);
}

void set_sync_string() {
	if (SyncToSoundBuffer) 		sprintf(sync_data, "Sound");
	else if (SyncToMonitor)		sprintf(sync_data, "Monitor");
	else 				sprintf(sync_data, "Clock");
}

void hand_framerate_inc() {
	if (UserFrameRate == 9999) UserFrameRate = -1;
	else ++UserFrameRate;
	if (UserFrameRate == 0) ++UserFrameRate;
	set_framerate_string();
}

void hand_framerate_dec() {
	if      (UserFrameRate == -1) UserFrameRate = 9999;
	else if (UserFrameRate == 1)  UserFrameRate = -1;
	else --UserFrameRate;
	set_framerate_string();
}

void hand_sync_inc() {
	if (SyncToMonitor)		{ SyncToMonitor = 0; SyncToSoundBuffer = 1; }
	else if (SyncToSoundBuffer)	{ SyncToSoundBuffer = 0; }
	else 				{ SyncToMonitor = 1; }

	srv_SetVideoMode();
	set_sync_string();
}

void hand_sync_dec() {
	if (SyncToMonitor)		{ SyncToMonitor = 0; }
	else if (SyncToSoundBuffer)	{ SyncToSoundBuffer = 0; SyncToMonitor = 1; }
	else 				{ SyncToSoundBuffer = 1; }

	srv_SetVideoMode();
	set_sync_string();
}

void hand_timing_exit() {
	
	exit_timing = 1;
}

gui_entry timing_gui_items[] = {
	{ " Framerate....: %s ", framerate_data, 0, hand_framerate_inc, hand_framerate_dec },
	{ " Sync.........: %s ", sync_data, 0, hand_sync_inc, hand_sync_dec },
	{ " ", NULL, 0, NULL, NULL },
	{ " Exit ", NULL, 0, hand_timing_exit, NULL },
	{ NULL, NULL, 0, NULL, NULL } // last element must always be this
};


/* Main entry point. Called by gui() */

void timing_gui() {
	SDL_Event ev;
	int action;
	
	set_framerate_string();
	set_sync_string();

	exit_timing = 0;
	while( !exit_timing ) {
		status_timer = 0;

		sprintf(msg, "Timing Options");
		draw_gui(timing_gui_items, timing_current);
		
		SDL_WaitEvent(&ev);	/* TODO: respond to SDL_QUIT events */
		action = gui_navigation(&ev);
		if(action == GUI_NO_ACTION) continue;
		
		timing_current = gui_handle_action(action, &exit_timing, timing_gui_items, timing_current);
	}
}



/**
** z26 is Copyright 1997-2011 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the
** GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
