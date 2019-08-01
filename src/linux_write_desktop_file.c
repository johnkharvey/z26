/*
** linux_write_desktop_file.c -- write icon and .desktop file on linux
*/

//	To put the icon file in a format to include in a C program:
//	xxd --include z26.ico > z26_icon.c

// We put the icon file in the same place as the .desktop file:
// ~/.local/share/applications

#include "z26_ico.c"

void linux_write_desktop_file(void)
{
	char szTmp[32];
	char z26exe[1024];
	char z26icon[1024];
	char z26desktop[1024];
	FILE *desktop;
	FILE *icon;

// from: https://stackoverflow.com/questions/143174/
//       how-do-i-get-the-directory-that-a-program-is-running-from
// by:   Mike

	sprintf(szTmp, "/proc/%d/exe", getpid());
	int bytes = readlink(szTmp, z26exe, sizeof(z26exe));
	if(bytes >= 0)
    	z26exe[bytes] = '\0';

	strncpy(z26icon, homedir, sizeof(z26icon)-1);
	strncat(z26icon, "/.local/share/icons/z26.ico", sizeof(z26icon)-1);

	icon = fopen(z26icon, "wb");
	if (icon == NULL)
	{
		printf("Couldn't build z26.ico: %s\n", z26icon);
		return;
	}
	fwrite(z26_ico, z26_ico_len, 1, icon);
	fclose(icon);

	strncpy(z26desktop, homedir, sizeof(z26desktop)-1);
	strncat(z26desktop, "/.local/share/applications/z26.desktop", sizeof(z26desktop)-1);

	desktop = fopen(z26desktop, "w");
	if (desktop == NULL)
	{
		printf("Couldn't build desktop file: %s\n", z26desktop);
		return;
	}
	fprintf(desktop, "[Desktop Entry]\n");
	fprintf(desktop, "Type=Application\n");
	fprintf(desktop, "Name=z26\n");
	fprintf(desktop, "Exec=%s\n", z26exe);
	fprintf(desktop, "Icon=%s\n", z26icon);
	fprintf(desktop, "Comment=An Atari 2600 Emulator\n");
	fprintf(desktop, "Categories=Game;\n");
	fclose(desktop);
}

/**
** z26 is Copyright 1997-2019 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
