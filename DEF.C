/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

extern char VideoMode;
extern short int CFirst;
extern char quiet;
extern char SoundMode;
extern char IOPortB;
extern char DoChecksum;
extern char NoRetrace;
extern long int FrameExit;
extern char dsp;
extern char Joystick;
extern char PaletteNumber;
extern long int PaddleGame;
extern char KeyBase;
extern char TraceCount;
extern char TraceEnabled;
extern char OldTraceCount;
extern char Use50Hz;
extern char KeyPad;		/* *EST* */
extern char Driving;		/* *EST */
extern char BSType;		/* *EST* */
extern char MouseBase;		/* *EST* */
extern char SimColourLoss;	/* *EST* */
extern char Lightgun;		/* *EST* */
extern int LGadjust;		/* *EST* */

char def_VideoMode;
short int def_CFirst;
char def_quiet;
char def_SoundMode;
char def_IOPortB;
char def_DoChecksum;
char def_NoRetrace;
long int def_FrameExit;
char def_dsp;
char def_Joystick;
char def_PaletteNumber;
long int def_PaddleGame;
char def_KeyBase;
long int def_TraceCount;
char def_Use50Hz;
char def_KeyPad;		/* *EST* */
char def_Driving;		/* *EST* */
char def_BSType;		/* *EST* */
char def_MouseBase;		/* *EST* */
char def_SimColourLoss;		/* *EST* */  
char def_Lightgun;		/* *EST* */
int def_LGadjust;		/* *EST* */

void def_SaveDefaults(void)
{
	def_VideoMode = VideoMode;
	def_CFirst = CFirst;
	def_quiet = quiet;
	def_SoundMode = SoundMode;
	def_IOPortB = IOPortB;
	def_DoChecksum = DoChecksum;
	def_FrameExit = FrameExit;
	def_dsp = dsp;
	def_Joystick = Joystick;
	def_PaletteNumber = PaletteNumber;
	def_PaddleGame = PaddleGame;
	def_KeyBase = KeyBase;
	def_TraceCount = TraceCount;
	def_NoRetrace = NoRetrace;
	def_Use50Hz = Use50Hz;
	def_KeyPad = KeyPad;			/* *EST* */
	def_Driving = Driving;			/* *EST* */
	def_BSType = BSType;			/* *EST* */
	def_MouseBase = MouseBase;		/* *EST* */
	def_SimColourLoss = SimColourLoss;	/* *EST* */
	def_Lightgun = Lightgun;		/* *EST* */
	def_LGadjust = LGadjust;		/* *EST* */
}

void def_LoadDefaults(void)
{
	VideoMode = def_VideoMode;
	CFirst = def_CFirst;
	quiet = def_quiet;
	SoundMode = def_SoundMode;
	IOPortB = def_IOPortB;
	DoChecksum = def_DoChecksum;
	FrameExit = def_FrameExit;
	dsp = def_dsp;
	Joystick = def_Joystick;
	PaletteNumber = def_PaletteNumber;
	PaddleGame = def_PaddleGame;
	KeyBase = def_KeyBase;
	TraceCount = def_TraceCount;
	NoRetrace = def_NoRetrace;
	Use50Hz = def_Use50Hz;
	KeyPad = def_KeyPad;			/* *EST* */
	Driving = def_Driving;			/* *EST* */
	BSType = def_BSType;			/* *EST* */
	MouseBase = def_MouseBase;		/* *EST* */
	SimColourLoss = def_SimColourLoss;	/* *EST* */
	Lightgun = def_Lightgun;		/* *EST* */
	LGadjust = def_LGadjust;		/* *EST* */
}

