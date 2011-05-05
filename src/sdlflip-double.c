/*
** sdlflip.c -- SDL page flipping code
*/

dd	Flips = 0;
double	Ticks = 0.0;
double	FirstFlipTime = 0.0;

double	CurrentFPS = 0.0;
double	FPStime = 0.0;
dd	FPSflips = 0;

int PageFlipping()
{
	return(!Phosphor && FullScreen && !InDesktop && SyncToMonitor);
}

double srv_get_microseconds()
{
	double ticks;
	ticks = (double) SDL_GetTicks();
	ticks *= 1000.0;
	return(ticks);
}

void srv_sleep_microseconds(double wait_time)
{
	SDL_Delay((dd) wait_time/1000.0);
}

double Calc_Period()
{
	double myPeriod;

	if (UserFrameRate != -1)				/* user specified rate? */
		myPeriod = 1000000.0/UserFrameRate;		/*   yes, use it (microseconds) */
	else if ((PaletteNumber==1)||(PaletteNumber==2))	
		myPeriod = (LinesInFrame*1000000.0)/15600.0;	/* PAL/SECAM -- 312 * 50 = 15600 */
	else    myPeriod = (LinesInFrame*1000000.0)/15720.0;	/* NTSC --	262 * 60 = 15720 */
	
	// make rate a little fast to force sync with audio stream
	if (SyncToSoundBuffer) myPeriod *= 0.99; // LinesInFrame * 1000000.0/16000;	

	return(myPeriod);
}

void srv_reset_timing()
{
	Flips = 0;
	Ticks = 0.0;			/* reset timing calculation */
	FirstFlipTime = 0.0;
	CurrentFPS = 0.0;
	FPStime = 0.0;
	FPSflips = 0;
}

void srv_Flip()
{
	double Now;
	double sleepytime;

	Now = srv_get_microseconds();

	if (Ticks == 0.0)		Ticks = Now;
	if (Flips++ == 0)	FirstFlipTime = Now;
	if (FPStime == 0.0)	FPStime = Now;

	++FPSflips;

	if (Now - FPStime > 4000000.0)	/* update FPS every 4 seconds or ... */
	{	
		CurrentFPS = (FPSflips * 1000000.0)/(Now - FPStime);
		FPStime = Now;
		FPSflips = 0;
	}
	else if (Now - FPStime <= 0.0)	/* ... if there was a time quake */
	{
		CurrentFPS = 0.0;
		FPStime = Now;
		FPSflips = 0;
	}
	
	Ticks += Calc_Period();		/* time of next flip */

	if (PageFlipping())
		SDL_Flip(srv_screen);
	else
	{
		sleepytime = Ticks - Now;
		if ((sleepytime > 0.0) && (sleepytime < 200000.0))	// 1/5 second max sleep time
			srv_sleep_microseconds(sleepytime);
		else	
		{	/* we've fallen behind more than 1/5 second or there was a time quake */
			if (sleepytime < -200000.0) Ticks = Now;
		}
		
		if (!Phosphor || (Phosphor && (Flips & 1)))
			SDL_UpdateRect(srv_screen, Horiz, Vert, pixelspread*tiawidth, scanlinespread*MaxLines);

	}

	screen_buffer_count = (screen_buffer_count + 1) & 0x03;
	if (DoInterlace || PageFlipping())
	{
		switch(screen_buffer_count)
		{
			case 0:
				ScreenBuffer = RealScreenBuffer1;
				ScreenBufferPrev = RealScreenBuffer2;
			break;
			case 1:
				ScreenBuffer = RealScreenBuffer3;
				ScreenBufferPrev = RealScreenBuffer4;
			break;
			case 2:
				ScreenBuffer = RealScreenBuffer2;
				ScreenBufferPrev = RealScreenBuffer1;
			break;
			case 3:
				ScreenBuffer = RealScreenBuffer4;
				ScreenBufferPrev = RealScreenBuffer3;
			break;
		}
	}
	else  // maybe phosphor mode
	{
		switch(screen_buffer_count)
		{
			case 0:
				ScreenBuffer = RealScreenBuffer1;
				ScreenBufferPrev = RealScreenBuffer4;
				PrevScreenBuffer = RealScreenBuffer3;
				PrevScreenBufferPrev = RealScreenBuffer2;
			break;
			case 1:
				ScreenBuffer = RealScreenBuffer2;
				ScreenBufferPrev = RealScreenBuffer1;
				PrevScreenBuffer = RealScreenBuffer4;
				PrevScreenBufferPrev = RealScreenBuffer3;
			break;
			case 2:
				ScreenBuffer = RealScreenBuffer3;
				ScreenBufferPrev = RealScreenBuffer2;
				PrevScreenBuffer = RealScreenBuffer1;
				PrevScreenBufferPrev = RealScreenBuffer4;
			break;
			case 3:
				ScreenBuffer = RealScreenBuffer4;
				ScreenBufferPrev = RealScreenBuffer3;
				PrevScreenBuffer = RealScreenBuffer2;
				PrevScreenBufferPrev = RealScreenBuffer1;
			break;
		}
	}
}

/**
** z26 is Copyright 1997-2011 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
