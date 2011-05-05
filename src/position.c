/*
** position.c -- position rendering window depending on video mode
*/

dd TopLine = 0;    /* top line of display */
dd BottomLine = 0; /* bottom line of display */

void position_game() {
	CFirst = DefaultCFirst;
//	CFirst = UserCFirst;
	if(DefaultCFirst == 0xffff) 	// if no default first line to render
	{
		if(PaletteNumber > 2)	PaletteNumber = 0;
			
		if (MaxLines <= 200)
		{
			if (PaletteNumber == 0) CFirst = 31;	// NTSC
			else 			CFirst = 64;	// PAL or SECAM
		}
		else if (MaxLines <= 225)
		{
			if (PaletteNumber == 0) CFirst = 23;	// NTSC 	(chalange)
			else 			CFirst = 44;	// PAL or SECAM (41 challang, 42 drgndfnd, 44 Vg_treas)
		}
		else if (MaxLines <= 240)
		{
			if (PaletteNumber == 0) CFirst = 20;	// 24 NTSC
			else 			CFirst = 43;	// 55 PAL or SECAM
		}
		else if (MaxLines <= 266) 
		{
			if (PaletteNumber == 0) CFirst = 18;	// NTSC
			else 			CFirst = 38;	// 39 PAL or SECAM
		}
		else
		{
			if (PaletteNumber == 0) CFirst = 1;	// 8  NTSC
			else 			CFirst = 38;	// 41 PAL or SECAM
		}
	}
	
	CFirst += GameOffset;	/* add in game specific offset */
	
	OldCFirst = CFirst;	/* remember starting line for homing display */
	TopLine = CFirst;	/* set up in case there's no vsync (like bowg_tw.bin) */
	BottomLine = CFirst + MaxLines;
}

/**
 z26 is Copyright 1997-2011 by John Saeger and contributors.  
 z26 is released subject to the terms and conditions of the 
 GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
 Please see COPYING.TXT for details.
*/
