
/* z26.h -- forward declarations, etc. */

#ifndef _Z26_H
#define _Z26_H 1

#ifdef C_ENGINE
#define Z26_RELEASE "z26 -- An Atari 2600 Emulator (C Engine)"
#else
#define Z26_RELEASE "z26 -- An Atari 2600 Emulator"
#endif

/* engine code: */
void QueueSoundBytes();
void c_QueueSoundBytes();
void Tia_process();
void Init_CPU();
void Init_CPUhand();
void Init_TIA();
void Init_Riot();
void Init_P2();
void Init_Starpath();
void Init_Tiasnd();
void position_game();

/* c_core.c: */
void InitData();
void cleanup();
void Init_Service();
void TIAGraphicMode();
void Init_SoundQ();
void RandomizeRIOTTimer();

/* sdlsrv.c: */
void Init_SDL();
void srv_sound_on();
void srv_sound_off();
void srv_print();
void srv_get_mouse_movement();
void srv_Events();
void srv_reset_timing();
void srv_Flip();

/* text.c: */
void draw_char(char ch, char* font, char* surface, int fontheight, int row, int col, int fg, int bg);
void show_scanlines();
void show_transient_status();
void clear_status();
void set_status(char *status);

/* gui.c: */
void gui();

#endif


/**
** z26 is Copyright 1997-2011 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
