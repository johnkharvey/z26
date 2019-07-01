/*
** guisound.c --  menu
*/

#define SQMIN 2048

int sound_current = 0;	/* currently selected GUI option */
int exit_sound = 0;	/* exit sound menu */

char quiet_data[52];

void hand_quiet() {
	quiet = !quiet;
	set_yesno_string(quiet_data, quiet);
}

void hand_sound_exit() {
	exit_sound = 1;
}

gui_entry sound_gui_items[] = {
	{ " Quiet..: %s ", quiet_data, 0, hand_quiet, hand_quiet },
	{ " ", NULL, 0, NULL, NULL },
	{ " Exit ", NULL, 0, hand_sound_exit, NULL },
	{ NULL, NULL, 0, NULL, NULL } // last element must always be this
};


/* Main entry point. Called by gui() */

void sound_gui() {
	SDL_Event ev;
	int action;
	
	set_yesno_string(quiet_data, quiet);
	
	exit_sound = 0;
	while( !exit_sound ) {
		status_timer = 0;

		sprintf(msg, "Sound Options");
		draw_gui(sound_gui_items, sound_current);
		
		SDL_WaitEvent(&ev);	/* TODO: respond to SDL_QUIT events */
		action = gui_navigation(&ev);
		if(action == GUI_NO_ACTION) continue;
		
		sound_current = gui_handle_action(action, &exit_sound, sound_gui_items, sound_current);
	}
}


/**
** z26 is Copyright 1997-2019 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the
** GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
