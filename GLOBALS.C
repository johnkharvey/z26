/*
** z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/


typedef unsigned long int	dd;
typedef unsigned short int	dw;
typedef unsigned char  		db;

char MessageCode=0;	/* gets message code for final output */
char msg[1000];		/* message buffer */

dd CartSize=0;		/* gets cart size */
dd Checksum=0;		/* gets cart checksum */
dd XChecksum=0;		/* gets alternative checksum */

db CartRom[0x1000f];

db PCXPalette[384];	/* palette information for PCX files goes here */

db *ScreenBuffer;       /* pointer to screen buffer (set to RealScreenBuffer 1-4) */
db *ScreenBufferPrev;   /* pointer to screen buffer for previous frame (RSB 1-4)*/
db *RealScreenBuffer1;  /* pointer to screen buffer (gets allocated)*/
db *RealScreenBuffer2;  /* pointer to screen buffer (gets allocated)*/
db *RealScreenBuffer3;  /* pointer to screen buffer (gets allocated)*/
db *RealScreenBuffer4;  /* pointer to screen buffer (gets allocated)*/

dd LinesInFrame;	/* # of lines in last frame */
dd PrevLinesInFrame;	/* # of lines in frame before that */
dd VBlankOff;		/* a valid VBlankOff was detected here */
dd VBlankOn;		/* a valid VBlankOn was detected here */
dd MaxLines;		/* # of lines in this video mode */
dd BailoutLine;		/* auto-sync occurs if game goes past this line */

dd SC_StartAddress;	/* supercharger start address */
db SC_ControlByte;	/* supercharger control byte */

dd crc;			/* holds accumulated CRC */

db KeyTable[128];	/* event handler should tell z26 about keystrokes here */
db ShowFPS;



/* 
** Init C Variables every time emulator() is called.
**
** called from init.asm
*/

void InitCVars(void)
{
	int i;

	VBlankOff=0;
	VBlankOn=0;
	LinesInFrame=262;
	BailoutLine=320;
	for (i=0; i<128; i++) KeyTable[i] = 0;
}


/*
** The following variables are typically set by command line switches.
**
** They are reinitialized at startup and from the GUI.
** The GUI reinitializes them before reading command line parms.
**
*/

db VideoMode;		/* default video mode */
db InWindow;		/* run game in a window */
dd CFirst;		/* first game line to display (zero has VBlank trigger a new frame) */
db quiet;		/* set if we want no sound */
db IOPortA;		/* IO Port A (joystick) */
db IOPortB;		/* IO Port B (switches) */
db DoChecksum;		/* set if we should print out checksum */
dd NoRetrace;		/* don't wait for retrace (if 0ffh) otherwise framerate */
dd OriginalNoRetrace;	/* save NoRetrace when swapping Windowed mode */
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
db KeyPad;		/* which keypad to emulate *EST* */
db Driving;		/* emulate driving controller *EST* */
dd BSType;		/* override bankswitching type *EST* */
db MouseBase;		/* paddle to emulate with mouse (0ffH = joystick) *EST* */
db SimColourLoss;	/* simulate PAL colour loss *EST* */
db Lightgun;		/* emulate lightgun and adjust horizontally *EST* */
dd LGadjust;		/* adjust lightgun vertically *EST* */
db ShowLineCount;	/* display stats on game exit */
db Mindlink;		/* emulate Mindlink controller in which port *EST* */
db AllowAll4;		/* allow all 4 directions on the joystick simultaniously */
db EnableFastCopy;	/* use 32 bit mode X copy routines */
db KidVid;		/* ID byte on tapes for KidVid game *EST* */
db KidVidTape;		/* tape number to be played *EST* */
db DisableCompareCopy;  /* dont compare new frame with old frame before copying *EST* */
db DoInterlace;         /* simulate interlaced display *EST* */

/*
** reinitialize the above variables
*/

void def_LoadDefaults(void)
{
	VideoMode = 0xff;
	InWindow = 0;
	CFirst = 0xffff;
	quiet = 0;
	IOPortA = 0xff;
	IOPortB = 0x0b;
	DoChecksum = 0;
	NoRetrace = -1;
	OriginalNoRetrace = NoRetrace;
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
	KeyPad = 0;
	Driving = 0;
	BSType = 0;
	MouseBase = 0xff;
	SimColourLoss = 0;
	Lightgun = 0;
	LGadjust = 5;
	ShowLineCount = 0;
	Mindlink = 0;
	AllowAll4 = 0;
	EnableFastCopy = 0;
	KidVid = 0;
	KidVidTape = 0;
        MaxLines = 0xffff ;  /* unreasonable default screen height - gets fixed by auto positioning */
        DisableCompareCopy = 0;
        DoInterlace = 0;
}
