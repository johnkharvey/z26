/*
**	z26 sound stuff
*/

/*
 We convert 5 input samples to 7 output samples.

 31400 * 7/5 = 43960

 At 44100 Hz with an NTSC game that has 262 scanlines, the buffer should 
 underflow. So we should need to add some extra samples. This should allow sync 
 to monitor at 60 Hz to work for these games. Games with more scanlines should 
 overflow the buffer and slow down to actual game speed, unless you set the 
 monitor to 50 Hz. Then many PAL games should sync to monitor too. The PAL 
 version of Yars' Revenge seems to sync just fine at 50 Hz. It has 314 
 scanlines.

 It's a pretty tight ship, but otherwise the quadrun voice pitch is off.
 It seems to work on most modern platforms though.
*/

void QueueSoundByte() {
	if (KidvidFileOpened && KidVid)
	{
		kv_GetNextSampleByte();
		SQ_byte = (TIA_Sound_Byte() >> 1) + KidvidSampleByte - 0x80;
	}
	else
		SQ_byte = TIA_Sound_Byte() >> 1;

	SQ_resample--;
	if (SQ_resample == 2) SQ_Store();
	if (SQ_resample == 0)
	{
		SQ_resample = 5;
		SQ_Store();
	}
	
	SQ_Store();
}


/* 
 Put sound bytes into buffer.
 Called once per scan line.
*/

void QueueSoundBytes() {
	if (quiet) return;
	if (SQ_Count() >= SQ_Max-4) 
	{
		if (Vsync) SDL_Delay(1);	// overflowed -- slow game down
		return;
	}
	if (SQ_Count() >= 5*SQ_BUCKET) 
	{
		if (Vsync) SDL_Delay(1);	// overflowing -- slow game down
	}
	do {
		QueueSoundByte();
		QueueSoundByte();
	} while(SQ_Count() < 2*SQ_BUCKET);
}


/**
 z26 is Copyright 1997-2019 by John Saeger and contributors.  
 contributors.	 z26 is released subject to the terms and conditions of the 
 GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
 Please see COPYING.TXT for details.
*/

