/*
** note:  pixcopy.c is generated from pixcopy.m4
**        please modify pixcopy.m4 to make changes
*/






























// single pixel routines

void FDoPixelCopy4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


	}
}	

void FDoPixelAv4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel;


pixel = srv_average[*source++][*prev++];
*dest++ = pixel;


pixel = srv_average[*source++][*prev++];
*dest++ = pixel;


pixel = srv_average[*source++][*prev++];
*dest++ = pixel;


	}
}	

void CFDoPixelCopy4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


		}
		else
		{
			source += 4;
			prev += 4;

			dest += 4;
		}
	}
}	


void FDoPixelCopy3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


	}
}	

void FDoPixelAv3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


	}
}	

void CFDoPixelCopy3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


		}
		else
		{
			source += 4;
			prev += 4;

			dest += 12;
		}
	}
}	


void FDoPixelCopy2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


	}
}	

void FDoPixelAv2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel;


pixel = srv_average[*source++][*prev++];
*dest++ = pixel;


pixel = srv_average[*source++][*prev++];
*dest++ = pixel;


pixel = srv_average[*source++][*prev++];
*dest++ = pixel;


	}
}	

void CFDoPixelCopy2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;


		}
		else
		{
			source += 4;
			prev += 4;

			dest += 4;
		}
	}
}	


// double pixel routines

void DoPixelCopy4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



	}
}	

void DoPixelAv4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;



	}
}	

void CDoPixelCopy4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



		}
		else
		{
			source += 4;
			prev += 4;

			dest += 8;
		}
	}
}	


void DoPixelCopy3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



	}
}	

void DoPixelAv3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



	}
}	

void CDoPixelCopy3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



		}
		else
		{
			source += 4;
			prev += 4;

			dest += 24;
		}
	}
}	


void DoPixelCopy2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



	}
}	

void DoPixelAv2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;



	}
}	

void CDoPixelCopy2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;



		}
		else
		{
			source += 4;
			prev += 4;

			dest += 8;
		}
	}
}	


// triple pixel routines

void DoTrPixelCopy4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



	}
}	

void DoTrPixelAv4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



	}
}	

void CDoTrPixelCopy4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



		}
		else
		{
			source += 4;
			prev += 4;

			dest += 12;
		}
	}
}	


void DoTrPixelCopy3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



	}
}	

void DoTrPixelAv3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



	}
}	

void CDoTrPixelCopy3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;



		}
		else
		{
			source += 4;
			prev += 4;

			dest += 36;
		}
	}
}	


void DoTrPixelCopy2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



	}
}	

void DoTrPixelAv2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



	}
}	

void CDoTrPixelCopy2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



		}
		else
		{
			source += 4;
			prev += 4;

			dest += 12;
		}
	}
}	


void DoTrPixelCopy1()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = *source++;  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = *source++;  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = *source++;  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = *source++;  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



	}
}	

void CDoTrPixelCopy1()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = *source++;  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = *source++;  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = *source++;  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



pixel = *source++;  ++prev;
*dest++ = pixel;

*dest++ = pixel;

*dest++ = pixel;



		}
		else
		{
			source += 4;
			prev += 4;

			dest += 12;
		}
	}
}	


// quad pixel routines

void DoWidePixelCopy4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




	}
}	

void DoWidePixelAv4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




	}
}	

void CDoWidePixelCopy4()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dd *dest = (dd*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




		}
		else
		{
			source += 4;
			prev += 4;

			dest += 16;
		}
	}
}	


void DoWidePixelCopy3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




	}
}	

void DoWidePixelAv3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




pixel = srv_average[*source++][*prev++];
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




	}
}	

void CDoWidePixelCopy3()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	db *dest = (db*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;


*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;

*dest++ = pixel&0xff;
*dest++ = (pixel&0xff00)>>8;
*dest++ = (pixel&0xff0000)>>16;




		}
		else
		{
			source += 4;
			prev += 4;

			dest += 48;
		}
	}
}	


void DoWidePixelCopy2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




	}
}	

void DoWidePixelAv2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_average[*source++][*prev++];
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




	}
}	

void CDoWidePixelCopy2()
{
	int i;
	dd pixel;
	db *source = emu_pixels;
	db *prev = emu_pixels_prev;
	dw *dest = (dw*) screen_pixels;

	for (i=0; i<40; i++)
	{
		if (* (dd*) source != * (dd*) prev)
		{
			pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




pixel = srv_colortab[*source++];  ++prev;
*dest++ = pixel;

*dest++ = pixel;


*dest++ = pixel;

*dest++ = pixel;




		}
		else
		{
			source += 4;
			prev += 4;

			dest += 16;
		}
	}
}	



