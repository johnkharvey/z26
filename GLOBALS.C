/*
** z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/


typedef unsigned long int	dd;
typedef unsigned short int	dw;
typedef unsigned char  		db;

void far LongDelay(void);

dw psp;			/* gets set by C program */
dw CartSize;		/* gets cart size */
dd Checksum;		/* gets cart checksum */
dd XChecksum;		/* gets alternative checksum */

dd DelayTime;		/* gets long delay value */

db CartRom[32770];      /* ROM image goes here */
db KeyTable[128];	/* holds keystrokes */
db PCXPalette[384];     /* palette information for PCX files goes here */
db RiotRam[128];	/* RIOT RAM */
db TIA[64];		/* TIA registers */
db Ram[2048];		/* extra RAM */
db Bit9[511];		/* for 9-bit polynomial (tiasnd) */
dw sb_buf_size=2048;	/* size of soundblaster hardware buffer 
			   don't change -- hardcoded asm depends on it */
db BaseDMABuf[2050];	/* sound output goes here */

/* Pitfall2 stuff */

db P2_Flags[8];
db P2_Counters[16];
db P2_Top[8];
db P2_Bottom[8];
db P2_Enable[8];
dw P2_Music_Top[8];
dw P2_Music_Bottom[8];
dw P2_Music_Count[8];

db Pitfall2; 		/* tell RIOT timer to clock the music */
dw P2_sreg; 		/* initialize shift register to non-zero val */
db P2_Rbyte; 		/* return value for CPU read commands */
db P2_AUDV; 		/* create an AUDV byte here */


db far *ScreenBuffer;   /* pointer to screen buffer */
dw ScreenSeg;           /* in seg and ofs form */
dw ScreenOfs;

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
	InTextMode=0;

	for (i=0; i<128;  i++) KeyTable[i]=0;
	for (i=0; i<128;  i++) RiotRam[i]=0;
	for (i=0; i<64;   i++) TIA[i]=0;
	for (i=0; i<2048; i++) Ram[i]=0;
	for (i=0; i<2050; i++) BaseDMABuf[i]=0;

	for (i=0; i<8;    i++) P2_Flags[i]=0;
	for (i=0; i<16;   i++) P2_Counters[i]=0;
	for (i=0; i<8;    i++) P2_Top[i]=0;
	for (i=0; i<8;    i++) P2_Bottom[i]=0;
	for (i=0; i<8;    i++) P2_Enable[i]=0;
	for (i=0; i<8;    i++) P2_Music_Top[i]=0;
	for (i=0; i<8;    i++) P2_Music_Bottom[i]=0;
	for (i=0; i<8;    i++) P2_Music_Count[i]=0;

	Pitfall2 = 0;
	P2_sreg = 1;
	P2_Rbyte = 0;
	P2_AUDV = 0;
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
db AllowAll4;           /* allow all 4 directions on the joystick simultaniously */
db EnableFastCopy;      /* use 32 bit mode X copy routines */
db TurnScreen;          /* rotate screen 90ø counter-clockwise in linear modes *EST* */
db HalfScreen;		/* copy alternate scanlines to screen */
db KidVid;              /* ID byte on tapes for KidVid game *EST* */
db KidVidTape;          /* tape number to be played *EST* */

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
        AllowAll4 = 0;
        EnableFastCopy = 0;
        TurnScreen = 0;
        HalfScreen = 0;
        KidVid = 0;
        KidVidTape = 0;
}
