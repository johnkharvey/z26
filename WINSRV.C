/*
** winsrv.c -- Windows specific service code
*/

/*
** z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

#include <windows.h>

win_msg(char *msg)
{
	MessageBox(NULL, msg, "z26", MB_OK);
}


