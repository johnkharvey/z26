/*
** z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/


/* controller code definitions */
#define JS 0	/* joystick */
#define PC 1	/* paddle controller */
#define KP 2	/* keypad */
#define DC 3	/* driving controller */
#define LG 4	/* lightgun */
#define CM 5	/* Compumate keyboard */
#define KV 6	/* Kid Vid tape player */
#define ML 7	/* Mindlink */
#define ST 8	/* ST mouse / CX-80 TRAK Ball */
#define TB 9	/* CX-22 TRAK Ball */
#define AM 10	/* Amiga mouse */
#define NC 11	/* no controller connected */

typedef unsigned long int	dd;
typedef unsigned short int	dw;
typedef unsigned char  		db;

char MessageCode=0;	/* gets message code for final output */
char msg[1000];		/* message buffer */

dd CartSize=0;		/* gets cart size */
dd Checksum=0;		/* gets cart checksum */
dd XChecksum=0;		/* gets alternative checksum */

db CartRom[0x8000f];

db PCXPalette[384];	/* palette information for PCX files goes here */

db *ScreenBuffer;       /* pointer to screen buffer (set to RealScreenBuffer 1-4) */
db *ScreenBufferPrev;   /* pointer to screen buffer for previous frame (RSB 1-4)*/

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

/* SDL event handler should tell z26 about joystick states here */
int JoystickAxis[16][6];
db JoystickButton[16][32];
db Stelladaptor[16];	/* is joystick a Stealladaptor */

db ShowFPS;
db SoundQ[65537];	/* sound queue */
dd SQ_Max = 2048*3;

char RealScreenBuffer1[65000];
char RealScreenBuffer2[65000];
char RealScreenBuffer3[65000];
char RealScreenBuffer4[65000];

#define TRIGMIN 1
#define TRIGMAX 240

//dd ChargeTrigger0 = TRIGMAX/2;        /* paddle charges (can be 1-240) */
//dd ChargeTrigger1 = TRIGMAX/2;
//dd ChargeTrigger2 = TRIGMAX/2;
//dd ChargeTrigger3 = TRIGMAX/2;

dd ChargeTrigger0[4] = {TRIGMAX/2, TRIGMAX/2, TRIGMAX/2, TRIGMAX/2};

#define CHARGEMAX 0x800000;	/* don't charge capacitors over this value (MAIN.ASM)*/
dd ChargeCounter = 0;		/* # of lines capacitors have been charging */

db DumpPorts[4] = {0, 0 ,0 ,0};	/* INPT0 - INPT3 */
db InputLatch[2] = {0, 0};	/* INPT4 + INPT5 */

db CM_Collumn = 0;	/* Compumate key collumn to read - gets set by bankswitching */

db ExitEmulator;	/* leave the emulator when ESC or backslash are pressed */
db GamePaused;		/* toggle to pause emulator */

void ClearScreenBuffers()
{
        int i;

        for (i=0; i<65000; i++)
        {
                RealScreenBuffer1[i] = 0;
                RealScreenBuffer2[i] = 0;
                RealScreenBuffer3[i] = 0;
                RealScreenBuffer4[i] = 0;
       }

}

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
	for (i=0; i<65537; i++) SoundQ[i] = 0;
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
db TrueColor;		/* run game in true colors (16, 24, 32 bpp) */
dd CFirst;		/* first game line to display (zero has VBlank trigger a new frame) */
dd OldCFirst;		/* remember original CFirst (for homing the display) */
db quiet;		/* set if we want no sound */
db IOPortA;		/* IO Port A (joystick) */
db IOPortA_Controllers;	/* remember controller data throughout frame */
db IOPortA_UnusedBits;	/* bits unused by selected controller = 1 */
db IOPortB;		/* IO Port B (switches) */
db DoChecksum;		/* set if we should print out checksum */
dd NoRetrace;		/* don't wait for retrace (if 0ffh) otherwise framerate */
dd OriginalNoRetrace;	/* save NoRetrace when swapping Windowed mode */
dd FrameExit;		/* do this many frames and exit */
db dsp;			/* do digital signal processing */
db PaletteNumber;	/* 0 = NTSC, 1 = PAL */
db UserPaletteNumber;	/* palette number specified by user */
dd PaddleSensitivity;	/* keyboard sensitivity for paddle emulation */
db TraceCount;		/* gets trace count */
db TraceEnabled;	/* if trace is enabled */
db OldTraceCount;	/* for saving trace count if we turn off tracing */
dd BSType;		/* override bankswitching type *EST* */
db MouseBaseX;		/* paddle to emulate with mouse X axis (0ffH = joystick) *EST* */
db MouseBaseY;		/* paddle to emulate with mouse Y axis (0ffH = joystick) *EST* */
db SimColourLoss;	/* simulate PAL colour loss *EST* */
db Lightgun;		/* emulate lightgun and adjust horizontally *EST* */
dd LGadjust;		/* adjust lightgun vertically *EST* */
db ShowLineCount;	/* display stats on game exit */
db AllowAll4;		/* allow all 4 directions on the joystick simultaniously */
db Effect;		/* video effect */
db Phosphor;		/* phosphorescence */
db KidVid;		/* ID byte on tapes for KidVid game *EST* */
db KidVidTape;		/* tape number to be played *EST* */
db DisableCompareCopy;  /* dont compare new frame with old frame before copying *EST* */
db DoInterlace;         /* simulate interlaced display *EST* */
db MouseRude;		/* warp the mouse when running in a window */
db UseBMP;              /* save screen shot from VGA buffer to BMP (no PCX from render buffer *EST* */
db SyncToSoundBuffer;   /* spend idle time with creating new sound bytes *EST* */
db LeftController;	/* controller in left port */
db RightController;	/* controller in Right port */
db PaddleAdjust;	/* wait for N lines before starting to evaluate paddle charge */
db SwapPortsFlag;	/* user wants port 0 to be swapped with port 1 */
db JoystickEnabled;	/* allow PC joystick input for VCS controllers with multiple PC inputs */
db MouseEnabled;	/* allow PC mouse input for VCS controllers with multiple PC inputs */
db KeyboardEnabled;	/* allow PC keyboard input for VCS controllers with multiple PC inputs */
db StelladaptorEnabled;	/* allow PC Stelladaptor input for VCS controllers with multiple PC inputs */
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
	IOPortA_Controllers = 0xff;
	IOPortA_UnusedBits = 0xff;
	IOPortB = 0x0b;
	DoChecksum = 0;
	NoRetrace = -1;
	OriginalNoRetrace = NoRetrace;
	FrameExit = 0;
	dsp = 0;
	PaletteNumber = 0xff;
	UserPaletteNumber = 0xff;
	PaddleSensitivity = 0;
	TraceCount = 0;
	TraceEnabled = 0;
	OldTraceCount = 0;
	BSType = 0;
	MouseBaseX = 0xff;
	MouseBaseY = 0xff;
	SimColourLoss = 0;
	Lightgun = 0;
	LGadjust = 5;
	ShowLineCount = 0;
	AllowAll4 = 0;
	Effect = 0;
	Phosphor = 0;
	KidVid = 0;
	KidVidTape = 0;
        MaxLines = 0xffff ;  /* unreasonable default screen height - gets fixed by auto positioning */
        DisableCompareCopy = 0;
        DoInterlace = 0;
	MouseRude = 1;
        UseBMP = 0;
        SyncToSoundBuffer=0;
        LeftController=0xff;
        RightController=0xff;
	ExitEmulator = 0;
	GamePaused = 0;
	OldCFirst = 0;
	PaddleAdjust = 0;
	SwapPortsFlag = 0;
	JoystickEnabled = 1;
	MouseEnabled = 1;
	KeyboardEnabled = 1;
	StelladaptorEnabled = 1;
}
