/*
** sdlflip.c -- SDL page flipping code
*/

double	CurrentFPS = 0.0;
double	FPStime = 0.0;
double  TotalTime = 0.0;
int	    FPSflips = 0;

// monotonic clock in nanoseconds

static long long int ns_time()
{
    struct timespec ts;
    
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long int)ts.tv_sec * 1000000000 + (long long int)ts.tv_nsec;
}

double srv_get_nanoseconds()
{
	long long int nsec;
	nsec = ns_time();
	return(nsec);
}

void srv_reset_timing()
{
	CurrentFPS = 0.0;
	FPStime = srv_get_nanoseconds();
	TotalTime = 0.0;
	FPSflips = 0;
}

void srv_Flip()
{
    if (FPSflips == 2) FPStime = srv_get_nanoseconds();

	TotalTime = srv_get_nanoseconds() - FPStime;
	CurrentFPS = ((++FPSflips-3) * 1000000000.0)/TotalTime;

	SDL_GL_SwapWindow(window);

	if (screen_buffer_count ^= 1)
	{
		ScreenBuffer = RealScreenBuffer1;
		ScreenBufferPrev = RealScreenBuffer2;
	}
	else
	{
		ScreenBuffer = RealScreenBuffer2;
		ScreenBufferPrev = RealScreenBuffer1;
	}
}

/**
	z26 is Copyright 1997-2019 by John Saeger and contributors.  
	z26 is released subject to the terms and conditions of the 
	GNU General Public License Version 2 (GPL).	
	z26 comes with no warranty.
	Please see COPYING.TXT for details.
*/
