/*
** sdlpixcopy.c -- pixel copy routines
*/


// 32-bpp phosphor

void PixAv32()
{
	dd p, i, j, l;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *prev_source = prev_emu_pixels;
	db *prev_prev = prev_emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;
	dd *ptr = (dd*) screen_pixels;
	dd ptr_inc = srv_pitch/4 - pixelspread;

	i = tiawidth/4;
	while (i--)
	{
		if ((* (dd*) source != * (dd*) prev_source) || (* (dd*) prev != * (dd*) prev_prev))
		{
			p = 4;		// do 4 pixels
			while (p--)
			{
				j = pixelspread; ptr = dest; l = lines2draw;
				pixel = srv_average[*source++][*prev++];
				while (l--) { while (j--) { *ptr++ = pixel; }; j = pixelspread; ptr += ptr_inc; };
				dest += pixelspread;
			}
		}
		else
		{
			source += 4; prev += 4; dest += pixelspread*4;
		}
		prev_source += 4; prev_prev += 4;
	}
}


// 24-bpp phosphor

void PixAv24()
{
	dd p, i, j, l;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *prev_source = prev_emu_pixels;
	db *prev_prev = prev_emu_pixels_prev;
	db *dest = (db*) screen_pixels;
	db *ptr = (db*) screen_pixels;
	dd ptr_inc = srv_pitch - pixelspread*3;

	i = tiawidth/4;
	while (i--)
	{
		if ((* (dd*) source != * (dd*) prev_source) || (* (dd*) prev != * (dd*) prev_prev))
		{
			p = 4;		// do 4 pixels
			while (p--)
			{
				j = pixelspread; ptr = dest; l = lines2draw;
				pixel = srv_average[*source++][*prev++];
				while (l--) 
				{
					while (j--) 
					{ 
						*ptr++ = pixel;		// little endian
						*ptr++ = pixel >> 8;
						*ptr++ = pixel >> 16;
					}; 
					j = pixelspread; ptr += ptr_inc; 
				};
				dest += pixelspread*3;
			}
		}
		else
		{
			source += 4; prev += 4; dest += pixelspread*12;
		}
		prev_source += 4; prev_prev += 4;
	}
}


// 16-bpp phosphor

void PixAv16()
{
	dd p, i, j, l;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *prev_source = prev_emu_pixels;
	db *prev_prev = prev_emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;
	dw *ptr = (dw*) screen_pixels;
	dd ptr_inc = srv_pitch/2 - pixelspread;

	i = tiawidth/4;
	while (i--)
	{
		if ((* (dd*) source != * (dd*) prev_source) || (* (dd*) prev != * (dd*) prev_prev))
		{
			p = 4;		// do 4 pixels
			while (p--)
			{
				j = pixelspread; ptr = dest; l = lines2draw;
				pixel = srv_average[*source++][*prev++];
				while (l--) { while (j--) { *ptr++ = pixel; }; j = pixelspread; ptr += ptr_inc; };
				dest += pixelspread;
			}
		}
		else
		{
			source += 4; prev += 4; dest += pixelspread*4;
		}
		prev_source += 4; prev_prev += 4;
	}
}


// 32-bpp normal

void PixCopy32()
{
	dd p, i, j, l;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;
	dd *ptr = (dd*) screen_pixels;
	dd ptr_inc = srv_pitch/4 - pixelspread;

	i = tiawidth/4;
	while (i--)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			p=4;
			while (p--)
			{
				j = pixelspread; ptr = dest; l = lines2draw;
				pixel = srv_colortab[*source++];
				while (l--) { while (j--) { *ptr++ = pixel; }; j = pixelspread; ptr += ptr_inc; };
				dest += pixelspread;
			}
		}
		else
		{
			source += 4; dest += pixelspread*4;
		}
		prev += 4;
	}
}


// 24-bpp normal

void PixCopy24()
{
	dd i, j, l, p;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;
	db *ptr = (db*) screen_pixels;
//	dd ptr_inc = (width - pixelspread)*3;
	dd ptr_inc = srv_pitch - pixelspread*3;
		
	i = tiawidth/4;
	while (i--)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			p=4;
			while (p--)
			{
				j = pixelspread; ptr = dest; l = lines2draw;
				pixel = srv_colortab[*source++];
				while (l--) 
				{ 
					while (j--) 
					{ 
						*ptr++ = pixel;		// little endian
						*ptr++ = pixel >> 8;
						*ptr++ = pixel >> 16;
					}; 
					j = pixelspread; ptr += ptr_inc; 
				};
				dest += pixelspread*3;
			}
		}
		else
		{
			source += 4; dest += pixelspread*12;
		}
		prev += 4;
	}
}


// 16-bpp normal

void PixCopy16()
{
	dd p, i, j, l;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;
	dw *ptr = (dw*) screen_pixels;
	dd ptr_inc = srv_pitch/2 - pixelspread;

	i = tiawidth/4;
	while (i--)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			p=4;
			while (p--)
			{
				j = pixelspread; ptr = dest; l = lines2draw;
				pixel = srv_colortab[*source++];
				while (l--) { while (j--) { *ptr++ = pixel; }; j = pixelspread; ptr += ptr_inc; };
				dest += pixelspread;
			}
		}
		else
		{
			source += 4; dest += pixelspread*4;
		}
		prev += 4;
	}
}


// 8-bpp normal

void PixCopy8()
{
	dd p, i, j, l;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;
	db *ptr = (db*) screen_pixels;
	dd ptr_inc = srv_pitch - pixelspread;

	i = tiawidth/4;
	while (i--)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			p=4;
			while (p--)
			{
				j = pixelspread; ptr = dest; l = lines2draw;
				pixel = *source++;
				while (l--) { while (j--) { *ptr++ = pixel; }; j = pixelspread; ptr += ptr_inc; };
				dest += pixelspread;
			}
		}
		else
		{
			source += 4; dest += pixelspread*4;
		}
		prev += 4;
	}
}	



/**
** z26 is Copyright 1997-2011 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
