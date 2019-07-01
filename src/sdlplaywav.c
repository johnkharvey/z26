/*
** sdlplaywav.c -- play a little wav file at startup
*/

// from: Nick Arnoeyts
// https://gist.github.com/armornick/3447121

/*
	To make the startup wave file:
	sox -n -r 44100 -b 16 -e signed-integer z26.wav synth .1 sine 200 vol -100db

	We need the startup wave file because one of my Linux systems has trouble
	initializing the sound. It has an Nvidia GTX 960 with sound through HDMI.
	It's running Linux Mint 9.1 64-bit. I accidently discovered that if I play 
	a wave file with the right format before launching z26, the sound would 
	start properly most of the time. The key point seems to be the sample rate. 
	If I play the wave file twice it seems to always work. So I play the files 
	with z26 on Linux platforms. It's ugly and someday maybe the bug gets fixed, 
	but for now we "flush twice" to get the sound going on Linux.
*/

#define MUS_PATH "z26.wav"

void my_audio_callback(void *userdata, Uint8 *stream, int len);

static Uint8 *audio_pos;
static Uint32 audio_len;

int playwav(void){

	if (SDL_Init(SDL_INIT_AUDIO) < 0)
			return 1;

	static Uint32 wav_length;
	static Uint8 *wav_buffer;
	static SDL_AudioSpec wav_spec;
	
	
	if( SDL_LoadWAV(MUS_PATH, &wav_spec, &wav_buffer, &wav_length) == NULL ){
	  fprintf(stderr, "Couldn't find z26.wav file.\n");
	  return 1;
	}

	wav_spec.callback = my_audio_callback;
	wav_spec.userdata = NULL;

	audio_pos = wav_buffer;
	audio_len = wav_length;
	
	if ( SDL_OpenAudio(&wav_spec, NULL) < 0 ){
	  fprintf(stderr, "Couldn't open audio: %s\n", SDL_GetError());
	  return 1;
	}
	
	SDL_PauseAudio(0);

	while ( audio_len > 0 ) {
		SDL_Delay(100); 
	}
	
	SDL_CloseAudio();
	SDL_FreeWAV(wav_buffer);

	return 0;
}

void my_audio_callback(void *userdata, Uint8 *stream, int len) {
	
	if (audio_len ==0)
		return;
	
	len = ( len > audio_len ? audio_len : len );
	SDL_memcpy (stream, audio_pos, len);
	audio_pos += len;
	audio_len -= len;
}

/**
** z26 is Copyright 1997-2019 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
