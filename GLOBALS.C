/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/


typedef unsigned long int	dd;
typedef unsigned short int	dw;
typedef unsigned char  		db;

void far LongDelay(void);

dw psp=0;		/* gets set by C program */
dw CartSize=0;		/* gets cart size */
dd Checksum=0;		/* gets cart checksum */
dd XChecksum=0;		/* gets alternative checksum */

dd DelayTime=0;		/* gets long delay value */

db CartRom[34000]; 	/* 34000 ROM image goes here */
db FileName[260];	/* filename of current ROM being run */

db far *Megaboy;	/* pointer to Megaboy ROM */
dw MBseg, MBofs;	/* in seg, ofs form */
dw LinesInFrame;	/* # of lines in last frame */
dw PrevLinesInFrame;	/* # of lines in frame before that */
dw VBlankOff;		/* a valid VBlankOff was detected here */
dw VBlankOn;		/* a valid VBlankOn was detected here */
dw MaxLines;		/* # of lines in this video mode */
dw BailoutLine;		/* auto-sync occurs if game goes past this line */

dw SC_StartAddress;	/* supercharger start address */
dw SC_ControlByte;	/* supercharger control byte */

db InTextMode;		/* in TIA text mode outputting a message */

dd crc;			/* holds accumulated CRC */
dd crctab[256];		/* table to help CRC calculation */




/* 
** Init C Variables every time emulator() is called.
**
** called from init.asm
*/

void InitCVars(void)
{
	VBlankOff=0;
	VBlankOn=0;
	LinesInFrame=262;
	BailoutLine=320;
	InTextMode=0;
}


/*
** The following variables are typically set by command line switches.
**
** They are reinitialized at startup and from the GUI.
** The GUI reinitializes them before reading command line parms.
**
*/

db VideoMode;		/* default video mode */
dw CFirst;		/* first game line to display (zero has VBlank trigger a new frame) */
db quiet;		/* set if we want no sound */
db SoundMode;		/* sound mode */
db IOPortA;		/* IO Port A (joystick) */
db IOPortB;		/* IO Port B (switches) */
db DoChecksum;		/* set if we should print out checksum */
db NoRetrace;		/* don't wait for retrace (if 0ffh) otherwise framerate */
dd FrameExit;		/* do this many frames and exit */
db dsp;			/* do digital signal processing */
db Joystick;		/* do joystick */
db PaletteNumber;	/* 0 = NTSC, 1 = PAL */
db UserPaletteNumber;	/* palette number specified by user */
dd PaddleGame;		/* this is a paddle game (sensitivity) */
db KeyBase;		/* which paddle to emulate */
db TraceCount;		/* gets trace count */
db TraceEnabled;	/* if trace is enabled */
db OldTraceCount;	/* for saving trace count if we turn off tracing */
db Use50Hz;		/* O.K. to use 50Hz video modes */
db KeyPad;		/* which keypad to emulate *EST* */
db Driving;		/* emulate driving controller *EST* */
db BSType;		/* override bankswitching type *EST* */
db MouseBase;		/* paddle to emulate with mouse (0ffH = joystick) *EST* */
db SimColourLoss;	/* simulate PAL colour loss *EST* */
db Lightgun;		/* emulate lightgun and adjust horizontally *EST* */
dw LGadjust;		/* adjust lightgun vertically *EST* */
dw ShowLineCount;	/* display stats on game exit */
db Mindlink;            /* emulate Mindlink controller in which port *EST* */

/*
** reinitialize the above variables
*/

void def_LoadDefaults(void)
{
	VideoMode = 0xff;
	CFirst = 0xffff;
	quiet = 0;
	SoundMode = 0xff;
	IOPortA = 0xff;
	IOPortB = 0x0b;
	DoChecksum = 0;
	NoRetrace = 0;
	FrameExit = 0;
	dsp = 0;
	Joystick = 0xff;
	PaletteNumber = 0xff;
	UserPaletteNumber = 0xff;
	PaddleGame = 0;
	KeyBase = 0xff;
	TraceCount = 0;
	TraceEnabled = 0;
	OldTraceCount = 0;
	Use50Hz = 0;
	KeyPad = 0;
	Driving = 0;
	BSType = 0;
	MouseBase = 0xff;
	SimColourLoss = 0;
	Lightgun = 0;
	LGadjust = 5;
	ShowLineCount = 0;
        Mindlink = 0;
}
