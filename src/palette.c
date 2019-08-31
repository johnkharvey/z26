/*
** palette.c -- palette setup code
*/

/*
** Inspired by tia.cpp in mame 0.212 by Wilbert Pol and Stefan Jokisch.
*/

double brightness = 1.0;
double warmth = 0.0;

double NTSC_PS = 26.2;	// tunable phase shift
			// 25.714 -- chroma1   == chroma15
			// 26.572 -- chroma1.5 == chroma15 (perfect split)
			// 27.429 -- chroma2   == chroma15

			// 26.2 -- vintage z26 approximately
			// 26.2 -- mame 0.212 approximately
			// 26.7 -- Sunnyvale 4-switch (20190820)

double PAL_PS = 21.5;	// tunable phase shift
			// 21.68859 -- middle of the range
			// 21.50    -- vintage z26 approximately
			// 21.50	-- mame 0.212 approximately

double NTSC_luma[] = {0.08,0.15,0.26,0.40,0.52,0.65,0.76,0.84};
double PAL_luma[]  = {0.08,0.15,0.26,0.40,0.52,0.65,0.76,0.84};
//                    00   02   04   06   08   0A   0C   0E

// phase corrections since the 2600 doesn't generate perfect sine waves
// Set corrections for chroma1 and chromaF to be the same to get
// phase shift numbers to match mame numbers.
double NTSC_corr[] = 
	{ 0.0, 0.4, 0.4, 0.0,-0.1, 0.1, 0.5, 0.6, 0.5, 0.4, 0.0,-0.0,-0.2,-0.4, 0.5, 0.4 };
//    0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F

/*
** modern NTSC palette
*/

void NTSC_Palette()
{
	int chroma, luma, i;

	double color[16][2] = {{0.0}};
	double pi = 4*atan(1);
	double A = 0.225;
//	double delta_scale = (8.0+CORR1)/8.0;
//	double delta =  delta_scale * NTSC_PS * (2*pi/360);

	double delta = NTSC_PS * (2*pi/360);
//	double P0 = 0.23;	// .30

	for (i=1; i<16; i++)
	{	
		double corr = delta * NTSC_corr[i];

		color[i][0] = A * sin(delta*i + corr);
		color[i][1] = A * sin(delta*(i-pi) + corr);
	}

	for (chroma = 0; chroma < 16; chroma++)
	{
		double I = color[chroma][0];
		double Q = color[chroma][1];
		double Y, R, G, B = 0.0;

		for (luma=0; luma<=7; luma++)
		{
			Y = NTSC_luma[luma];

			Y = pow(Y, 2-brightness);

			R = Y + 0.956 * I + 0.621 * Q;
			G = Y - 0.272 * I - 0.647 * Q;
			B = Y - 1.106 * I + 1.703 * Q;

			if (chroma == 1)	// attempt a gold correction
				{
					R *= 1.00;
					G *= 1.00;
					B *= 0.00;
				}

			R *= 1.0 + warmth*0.2;
			G *= 1.0 + warmth*0.1;
			B *= 1.0 - warmth*0.1;

			if (R < 0) R = 0.0;
			if (G < 0) G = 0.0;
			if (B < 0) B = 0.0;

			if (R > 1) R = 1;
			if (G > 1) G = 1;
			if (B > 1) B = 1;

			PCXPalette[chroma*3*8 + luma*3+0] = (db) (R*255.0);
			PCXPalette[chroma*3*8 + luma*3+1] = (db) (G*255.0);
			PCXPalette[chroma*3*8 + luma*3+2] = (db) (B*255.0);
		}
	}
	PCXPalette[0] = 0; PCXPalette[1] = 0; PCXPalette[2] = 0;
}

/*
** modern PAL palette
*/

void PAL_Palette()
{
	int chroma, luma, i;

	double color[16][2] = {{0.0}};
	double pi = 4*atan(1);

	double A = 0.225;	// .225
	double delta = PAL_PS * (2*pi/360);

	for (i=2; i<14; i++)
	{	
		color[i][0] = A * sin(delta*i - PAL_PS);
		color[i][1] = A * -sin(delta*i/2 - PAL_PS);

		if (i & 1) color[i][1] = -color[i][1];
	}

	for (chroma = 0; chroma < 16; chroma++)
	{
		double U = color[chroma][0];
		double V = color[chroma][1];
		double Y, R, G, B = 0.0;

		for (luma=0; luma<=7; luma++)
		{
			Y = PAL_luma[luma];

			Y = pow(Y, 2-brightness);

			R = Y + 1.403 * V;
			G = Y - 0.344 * U - 0.714 * V;
			B = Y + 1.770 * U;

			R *= 1.0 + warmth*0.2;
			G *= 1.0 + warmth*0.1;
			B *= 1.0 - warmth*0.1;

			if (R < 0) R = 0.0;
			if (G < 0) G = 0.0;
			if (B < 0) B = 0.0;

			if (R > 1) R = 1;
			if (G > 1) G = 1;
			if (B > 1) B = 1;

			PCXPalette[chroma*3*8 + luma*3+0] = (db) (R*255.0);
			PCXPalette[chroma*3*8 + luma*3+1] = (db) (G*255.0);
			PCXPalette[chroma*3*8 + luma*3+2] = (db) (B*255.0);
		}
	}
	PCXPalette[0] = 0; PCXPalette[1] = 0; PCXPalette[2] = 0;
}

/*
**   ****** vintage palette stuff ********
*/

/*
** NTSC stuff
*/

/* note: RGB values are for the $x6 color */

db NTSC_RGB_table[] = 
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
 130, 122,  45		/* (f0) <130,122,45>  light orange */
};

db set_luma(int luma, int val)
{
	val += luma*20 - 60;
	if (val<0) return 0;
	if (val>255) return 255;
	return(val);
}

void vintage_NTSC_Palette()
{
	int chroma, luma, i;

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
/* PAL colors from Oliver Achten screen capture */

db PAL_RGB_table[] = 
{
 116, 116, 116,		/* (00) <116,116,116> grey */
 116, 116, 116,		/* (10) <116,116,116> grey */
 143, 118, 23,		/* (20) <143,118,23>  gold */
 87,  148, 21,		/* (30) <87,148,21>   yellow green */
 166, 101, 58,		/* (40) <166,101,58>  orange brown */
 67,  151, 57,		/* (50) <67,151,57>   light green */
 176, 87,  107,		/* (60) <176,87,107>  pink */
 56,  147, 106,		/* (70) <56,147,106>  blue green */
 169, 82,  155,		/* (80) <169,82,155>  purple */
 61,  136, 154,		/* (90) <61,136,154>  turquoise */
 155, 81,  196,		/* (a0) <155,81,196>  lilac */
 78,  119, 195,		/* (b0) <78,119,195>  light blue */
 129, 90,  217,		/* (c0) <129,90,217>  purple blue */
 102, 103, 218,		/* (d0) <102,103,218> blue */
 116, 116, 116,		/* (e0) <116,116,116> grey */
 116, 116, 116		/* (f0) <116,116,116> grey */
};


void vintage_PAL_Palette()
{
	int chroma, luma, i;

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

db SECAM_RGB_table[] = 
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

void SECAM_Palette()
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

/*
** mame palettes
*/

void mame_NTSC_Palette(void)
{
	/********************************************************************
	Atari 2600 NTSC Palette Notes:

	Palette on a modern flat panel display (LCD, LED, Plasma, etc.)
	appears different from a traditional CRT. The most outstanding
	difference is Hue 1x, the hue begin point. Hue 1x looks very
	'green' (~-60 to -45 degrees - depending on how poor or well it
	handles the signal conversion and its calibration) on a modern
	flat panel display, as opposed to 'gold' (~-33 degrees) on a CRT.

	The official technical documents: "Television Interface Adaptor
	[TIA] (Model 1A)", "Atari VCS POP Field Service Manual", and
	"Stella Programmer's Guide" stipulate Hue 1x to be gold.

	The system's pot adjustment manually manipulates the degree of
	phase shift, while the system 'warming-up' will automatically
	push whatever degrees has been manually set, higher.  According
	to the Atari VCS POP Field Service Manual and system diagnostic
	and test (color) cart, instructions are provide to set the pot
	adjustment having Hue 1x and Hue 15x (F$) match or within one
	shade of each other, both a 'goldenrod'.

	At power on, the system's phase shift appears as low as ~23
	degrees and after a considerable consistent runtime, can be as
	high as ~28 degrees.

	In general, the low end of ~23 degrees lasts for several seconds,
	whereas higher values such as ~25-27 degrees are the most
	dominant during system run time.  180 degrees colorburst takes
	place at ~25.7 degrees (A near exact match of Hue 1x and 15x -
	To the naked eye they appear to be the same).

	However, if the system is adjusted within the first several
	minutes of running, the warm up, consistent system run time,
	causes Hue 15x (F$) to become stronger/darker gold (More brown
	then ultimately red-brown); as well as leans Hue 14x (E$) more
	brown than green.  Once achieving a phase shift of 27.7 degrees,
	Hue 14x (E$) and Hue 15x (F$) near-exact match Hue 1x and 2x
	respectively.

	Therefore, an ideal phase shift while accounting for properly
	calibrating a system's color palette within the first several
	minutes of it running via the pot adjustment, the reality of
	shifting while warming up, as well as maintaining differences
	between Hues 1x, 2x and 14x, 15x, would likely fall between 25.7
	and 27.7 degrees.  Phase shifts 26.2 and 26.7 places Hue 15x/F$
	between Hue 1x and Hue 2x, having 26.2 degrees leaning closer to
	Hue 1x and 26.7 degrees leaning closer to Hue 2x.

	The above notion would also harmonize with what has been
	documented within "Stella Programmer's Guide" for the colors of
	1x, 2x, 14x, 15x on the 2600 and 7800.  1x = Gold, 2x = Orange,
	14x (E$) = Orange-Green. 15x (F$) = Light Orange.  Color
	descriptions are best measured in the middle of the brightness
	scale.  It should be mentioned that Green-Yellow is referenced
	at Hue 13x (D$), nowhere near Hue 1x.  A Green-Yellow Hue 1x is
	how the palette is manipulated and modified (in part) under a
	modern flat panel display.

	Additionally, the blue to red (And consequently blue to green)
	ratio proportions may appear different on a modern flat panel
	display than a CRT in some instances for the Atari 2600 system.
	Furthermore, you may have some variation of proportions even
	within the same display type.

	One side effect of this on the console's palette is that some
	values of red may appear too pinkish - Too much blue to red.
	This is not the same as a traditional tint-hue control adjustment;
	rather, can be demonstrated by changing the blue ratio values
	via MESS HLSL settings.

	Lastly, the Atari 5200 & 7800 NTSC color palettes hold the same
	hue structure order and have similar appearance differences that
	are dependent upon display type.
	********************************************************************/
	/*********************************
	Phase Shift 24.7
	        {  0.000,  0.000 },
	        {  0.192, -0.127 },
	        {  0.239, -0.052 },
	        {  0.244,  0.030 },
	        {  0.201,  0.108 },
	        {  0.125,  0.166 },
	        {  0.026,  0.194 },
	        { -0.080,  0.185 },
	        { -0.169,  0.145 },
	        { -0.230,  0.077 },
	        { -0.247, -0.006 },
	        { -0.220, -0.087 },
	        { -0.152, -0.153 },
	        { -0.057, -0.189 },
	        {  0.049, -0.193 },
	        {  0.144, -0.161 }

	Phase Shift 25.2
	        {  0.000,  0.000 },
	        {  0.192, -0.127 },
	        {  0.239, -0.052 },
	        {  0.244,  0.033 },
	        {  0.200,  0.113 },
	        {  0.119,  0.169 },
	        {  0.013,  0.195 },
	        { -0.094,  0.183 },
	        { -0.182,  0.136 },
	        { -0.237,  0.062 },
	        { -0.245, -0.020 },
	        { -0.210, -0.103 },
	        { -0.131, -0.164 },
	        { -0.027, -0.193 },
	        {  0.079, -0.187 },
	        {  0.169, -0.145 }

	Phase Shift 25.7
	        {  0.000,  0.000 },
	        {  0.192, -0.127 },
	        {  0.243, -0.049 },
	        {  0.242,  0.038 },
	        {  0.196,  0.116 },
	        {  0.109,  0.172 },
	        {  0.005,  0.196 },
	        { -0.104,  0.178 },
	        { -0.192,  0.127 },
	        { -0.241,  0.051 },
	        { -0.244, -0.037 },
	        { -0.197, -0.115 },
	        { -0.112, -0.173 },
	        { -0.004, -0.197 },
	        {  0.102, -0.179 },
	        {  0.190, -0.128 }

	Phase Shift 26.7
	        {  0.000,  0.000 },
	        {  0.192, -0.127 },
	        {  0.242, -0.046 },
	        {  0.240,  0.044 },
	        {  0.187,  0.125 },
	        {  0.092,  0.180 },
	        { -0.020,  0.195 },
	        { -0.128,  0.170 },
	        { -0.210,  0.107 },
	        { -0.247,  0.022 },
	        { -0.231, -0.067 },
	        { -0.166, -0.142 },
	        { -0.064, -0.188 },
	        {  0.049, -0.193 },
	        {  0.154, -0.155 },
	        {  0.227, -0.086 }

	Phase Shift 27.2
	        {  0.000,  0.000 },
	        {  0.192, -0.127 },
	        {  0.243, -0.044 },
	        {  0.239,  0.047 },
	        {  0.183,  0.129 },
	        {  0.087,  0.181 },
	        { -0.029,  0.195 },
	        { -0.138,  0.164 },
	        { -0.217,  0.098 },
	        { -0.246,  0.009 },
	        { -0.223, -0.081 },
	        { -0.149, -0.153 },
	        { -0.041, -0.192 },
	        {  0.073, -0.188 },
	        {  0.173, -0.142 },
	        {  0.235, -0.067 }

	Phase Shift 27.7
	        {  0.000,  0.000 },
	        {  0.192, -0.127 },
	        {  0.243, -0.044 },
	        {  0.238,  0.051 },
	        {  0.178,  0.134 },
	        {  0.078,  0.184 },
	        { -0.041,  0.194 },
	        { -0.151,  0.158 },
	        { -0.224,  0.087 },
	        { -0.248, -0.005 },
	        { -0.214, -0.096 },
	        { -0.131, -0.164 },
	        { -0.019, -0.195 },
	        {  0.099, -0.182 },
	        {  0.194, -0.126 },
	        {  0.244, -0.042 }
	*********************************/

	/*********************************
	Phase Shift 26.2
	**********************************/
	double color[16][2] =
	{
		{  0.000,  0.000 },
		{  0.192, -0.127 },
		{  0.241, -0.048 },
		{  0.240,  0.040 },
		{  0.191,  0.121 },
		{  0.103,  0.175 },
		{ -0.008,  0.196 },
		{ -0.116,  0.174 },
		{ -0.199,  0.118 },
		{ -0.243,  0.037 },
		{ -0.237, -0.052 },
		{ -0.180, -0.129 },
		{ -0.087, -0.181 },
		{  0.021, -0.196 },
		{  0.130, -0.169 },
		{  0.210, -0.107 }
	};

	for (int i = 0; i < 16; i++)
	{
		double const I = color[i][0];
		double const Q = color[i][1];

		for (int j = 0; j < 8; j++)
		{
			double const Y = j / 7.0;

			double R = Y + 0.956 * I + 0.621 * Q;
			double G = Y - 0.272 * I - 0.647 * Q;
			double B = Y - 1.106 * I + 1.703 * Q;

			if (R < 0) R = 0;
			if (G < 0) G = 0;
			if (B < 0) B = 0;

			R = pow(R, 0.9);
			G = pow(G, 0.9);
			B = pow(B, 0.9);

			if (R > 1) R = 1;
			if (G > 1) G = 1;
			if (B > 1) B = 1;


			PCXPalette[i*3*8 + j*3+0] = (db) (R*255.0);
			PCXPalette[i*3*8 + j*3+1] = (db) (G*255.0);
			PCXPalette[i*3*8 + j*3+2] = (db) (B*255.0);
		}
	PCXPalette[0] = 0; PCXPalette[1] = 0; PCXPalette[2] = 0;
	}
}

void mame_PAL_Palette(void)
{
	double color[16][2] =
	{
		{  0.000,  0.000 },
		{  0.000,  0.000 },
		{ -0.222,  0.032 },
		{ -0.199, -0.027 },
		{ -0.173,  0.117 },
		{ -0.156, -0.197 },
		{ -0.094,  0.200 },
		{ -0.071, -0.229 },
		{  0.070,  0.222 },
		{  0.069, -0.204 },
		{  0.177,  0.134 },
		{  0.163, -0.130 },
		{  0.219,  0.053 },
		{  0.259, -0.042 },
		{  0.000,  0.000 },
		{  0.000,  0.000 }
	};

	for (int i = 0; i < 16; i++)
	{
		double const U = color[i][0];
		double const V = color[i][1];

		for (int j = 0; j < 8; j++)
		{
			double const Y = j / 7.0;

			double R = Y + 1.403 * V;
			double G = Y - 0.344 * U - 0.714 * V;
			double B = Y + 1.770 * U;

			if (R < 0) R = 0;
			if (G < 0) G = 0;
			if (B < 0) B = 0;

			R = pow(R, 1.2);
			G = pow(G, 1.2);
			B = pow(B, 1.2);

			if (R > 1) R = 1;
			if (G > 1) G = 1;
			if (B > 1) B = 1;

			PCXPalette[i*3*8 + j*3+0] = (db) (R*255.0);
			PCXPalette[i*3*8 + j*3+1] = (db) (G*255.0);
			PCXPalette[i*3*8 + j*3+2] = (db) (B*255.0);
		}
	PCXPalette[0] = 0; PCXPalette[1] = 0; PCXPalette[2] = 0;
	}
}


/*
** generate appropriate palette
*/

void GeneratePalette()
{
	switch(PaletteNumber)
	{
	case 0:  NTSC_Palette();  		 break;
	case 1:  PAL_Palette();   		 break;
	case 2:  SECAM_Palette(); 		 break;
	case 3:  vintage_NTSC_Palette(); break;
	case 4:  vintage_PAL_Palette();  break;
	case 5:  mame_NTSC_Palette();	 break;
	case 6:  mame_PAL_Palette();	 break;
	default: NTSC_Palette();  		 break;
	}
}


/**
** This file contains code from the MAME project which is
** released under the BSD-3-Clause license.
** Additional copyright holders: Wilbert Pol,Stefan Jokisch
**
** BSD-3-Clause license
** --------------------
**
** Copyright (c) 2019, MAME 0.212 copyright holders
** All rights reserved.
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the <organization> nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
** 
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
** DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
** z26 is Copyright 1997-2019 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

