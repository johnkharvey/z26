/*
** sdlsound.c -- SDL sound code
*/

dd SQ_resample;	/* a counter for resampling sound to 44100 Hz */

db SQ_byte;		/* byte to put in the sound queue */
db *SQ_Input;	/* pointer to next available byte for storing */
db *SQ_Output;	/* pointer to next available byte for fetching */
db *SQ_Top;		/* pointer to the top of the queue */

void Init_SoundQ() 
{
	SQ_resample = 5;
	SQ_Input = SoundQ;
	SQ_Output = SoundQ;
	SQ_Top = SoundQ + SQ_Max;
}

int SQ_Count() {
	int count = SQ_Input - SQ_Output;

	if (count < 0) count += SQ_Max;
	return(count);
}

/*
** Please make sure calls to SQ_Store() check for a full buffer first.
*/

void SQ_Store() 
{
	*SQ_Input++ = SQ_byte;
	if(SQ_Input >= SQ_Top) SQ_Input = SoundQ;
}

/*
** the callback function
*/

void fillerup(void *unused, Uint8 *stream, int len)
{
	if(SQ_Count() < len) 
	{
		memset(stream, 0, len);
	}
	else
	{
		while(len)			/* 16-bit signed samples */
		{
			len -= 8;
			*stream++ = 0;	/* LSB = 0 */
			*stream++ = *SQ_Output++;
			*stream++ = 0;
			*stream++ = *SQ_Output++;
			*stream++ = 0;
			*stream++ = *SQ_Output++;
			*stream++ = 0;
			*stream++ = *SQ_Output++;
		}
		if(SQ_Output >= SQ_Top) SQ_Output = SoundQ;
	}
}

static int sound_is_on = 0;

void srv_sound_on()
{
	SDL_AudioSpec desired, obtained;

	if (quiet==0)
	{
		if (sound_is_on) return;

		desired.freq = 44100;		/* CD-quality */
		desired.callback = fillerup;
		desired.format = AUDIO_S16;	/* 16-bit */
		desired.channels = 1;		/* mono */
		desired.samples = 1024;		/* must be divisible by 4 (see above) */

		if ( SDL_OpenAudio(&desired, &obtained) < 0 ) 
		{
			printf("Couldn't open audio: %s\n",SDL_GetError());
			sound_is_on = 0;
			quiet = 1;
		}
		else
		{
			SDL_PauseAudio(0);		/* turn on the callback */
			sound_is_on = 1;
		}
	}
}

void srv_sound_off()
{
	if (sound_is_on && !quiet)
	{
		SDL_CloseAudio();
		SDL_Delay(100);
		sound_is_on = 0;
	}
}

/**
** z26 is Copyright 1997-2019 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
