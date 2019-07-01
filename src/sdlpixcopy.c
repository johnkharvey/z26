/*
	sdlpixcopy.c -- pixel copy routines
*/

// for fast textures -- display every other TIA pixel (160 pixels)

void PixCopy32_1()
{
	int i;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	i = tiawidth/8;
	while (i--)
	{
		if (* (dq*) source != * (dq*) prev)
		{
			*dest++ = srv_colortab_hi[*source++]; ++source;
			*dest++ = srv_colortab_hi[*source++]; ++source;
			*dest++ = srv_colortab_hi[*source++]; ++source;
			*dest++ = srv_colortab_hi[*source++]; ++source;
		}
		else
		{
			source += 8; dest += 4;
		}
		prev += 8;
	}
}

// for normal textures

void PixCopy32_2()
{
	dd p, i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;
	dd ptr_inc = srv_pitch/4;

	i = tiawidth/8;
	while (i--)
	{
		if (* (dq*) source != * (dq*) prev)
		{
			p=8;
			while (p--)
			{
				pixel = srv_colortab_hi[*source];
				*dest = pixel;
				if (DoScanline) pixel = srv_colortab_low[*source];
				*(dest++ + ptr_inc) = pixel;
				++source;
			}
		}
		else
		{
			source += 8; dest += 8;
		}
		prev += 8;
	}
}


// for HD textures

void PixCopy32_4()
{
	dd p, i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;
	dd *ptr = (dd*) screen_pixels;
	dd ptr_inc = srv_pitch/4 - 1;

	i = tiawidth/8;
	while (i--)
	{
		if (* (dq*) source != * (dq*) prev)
		{
			p=8;
			while (p--)
			{
				ptr = dest;
				pixel = srv_colortab_hi[*source];
				if (DoScanline) pixel = srv_colortab_med[*source];
				*ptr++ = pixel; *ptr = pixel; ptr += ptr_inc; 
				if (DoScanline) pixel = srv_colortab_hi[*source];
				*ptr++ = pixel; *ptr = pixel; ptr += ptr_inc; 
				if (DoScanline) pixel = srv_colortab_med[*source];
				*ptr++ = pixel; *ptr = pixel; ptr += ptr_inc; 
				if (DoScanline) pixel = srv_colortab_low[*source];
				*ptr++ = pixel; *ptr = pixel;
				++source;
				dest += 2;
			}
		}
		else
		{
			source += 8; dest += 16;
		}
		prev += 8;
	}
}

/**
	z26 is Copyright 1997-2019 by John Saeger and contributors.  
	z26 is released subject to the terms and conditions of the 
	GNU General Public License Version 2 (GPL).	
	z26 comes with no warranty.
	Please see COPYING.TXT for details.
*/