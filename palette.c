/*
** palette.c -- palette setup code
*/

/*
** z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

/*
** NTSC stuff
*/

/* note: RGB values are for the $x6 color */

unsigned char NTSC_RGB_table[] = 
{
 120, 120, 120,		/* (00) <120,120,120> grey */
 128, 144,   0,		/* (10) <128,144,2>   gold */
 163, 117,  19,		/* (20) <163,117,19>  yellow orange */
 183,  97,  64,		/* (30) <183,97,64>   yar's bright orange */
 185,  78, 104,		/* (40) <185,83,124>  pink */
 175,  68, 173,		/* (50) <175,78,173>  purple */
 153,  71, 206,		/* (60) <153,81,211>  blue purple */
 124,  81, 213,		/* (70) <124,91,228>  atlantis right blinker blue */
 97,   97, 207,		/* (80) <97,107,217>  blue */
 75,  112, 188,		/* (90) <75,122,188>  light blue */
 64,  126, 150,		/* (a0) <64,136,145>  atlantis turquoise */
 64,  139, 108,		/* (b0) <64,144,103>  green blue */
 75,  145,  70,		/* (c0) <75,145,65>   light green */
 91,  141,  45,		/* (d0) <91,141,45>   yellow green */
 112, 130,  40,		/* (e0) <112,130,40>  orange green */
 130, 120,  40		/* (f0) <130,120,44>  light orange */
};

unsigned char set_luma(int luma, int val)
{
	val += luma*20 - 60;
	if (val<0) return 0;
	if (val>255) return 255;
	return(val);
}

void NTSC_Palette()
{
	int chroma, luma, red, green, blue, i;

	for (chroma = 0; chroma <=15; chroma++)
		for (luma=0; luma<=7; luma++)
			for (i=0; i<3; i++)
				PCXPalette[chroma*3*8 + luma*3+i] = set_luma(luma, NTSC_RGB_table[chroma*3+i]);
	PCXPalette[0] = 0; PCXPalette[1] = 0; PCXPalette[2] = 0;
}

/*
** PAL stuff
*/

/* note: RGB values are for the $x6 color */

#define PL 60

unsigned char PAL_RGB_table[] = 
{
 120, 120, 120,		/* (00) grey */
 120, 120, 120,		/* (10) grey */
 162, 164,  50,         /* (20) gold */
 140, 172,  PL,		/* (30) yellow green */
 180, 132,  PL,		/* (40) orange brown */
  PL, 180,  PL,		/* (50) light green */
 190,  90,  76,         /* (60) pink */
  PL, 190, 110,         /* (70) blue green */
 196,  70, 148,         /* (80) purple */
  PL, 164, 164,		/* (90) turquoise */
 148,  PL, 180,		/* (a0) lilac */
  PL, 116, 180,		/* (b0) light blue */
 108,  PL, 188,         /* (c0) purple blue */
  PL,  PL, 192,		/* (d0) blue */
 120, 120, 120,		/* (e0) grey */
 120, 120, 120		/* (f0) grey */
};


void PAL_Palette()
{
	int chroma, luma, red, green, blue, i;

	for (chroma = 0; chroma <=15; chroma++)
		for (luma=0; luma<=7; luma++)
			for (i=0; i<3; i++)
				PCXPalette[chroma*3*8 + luma*3+i] = set_luma(luma, PAL_RGB_table[chroma*3+i]);

	for(i=0; i<=2; i++)
	{	
		PCXPalette[0+i]=0;;
		PCXPalette[3*8+i]=0;;
		PCXPalette[14*3*8+i]=0;
		PCXPalette[15*3*8+i]=0;
	}
}

/*
** SECAM stuff
*/

unsigned char SECAM_RGB_table[] = 
{
   0,   0,   0,		/* black */
  33,  33, 255,		/* blue */
 240,  60, 121,		/* red */
 255,  60, 255,		/* magenta */
 127, 255,   0,		/* green */
 127, 255, 255,		/* cyan */
 255, 255,  63,		/* yellow */
 255, 255, 255		/* white */
};

void SECAM_palette()
{
	int i,j;
	unsigned char *d, *s;

	d = PCXPalette;			/* dest pointer */
	
	for (i=0; i<16; i++)
	{
		s = SECAM_RGB_table;	/* source pointer */
		for(j=1; j<=24; j++)
			*d++ = *s++;
	}
}
