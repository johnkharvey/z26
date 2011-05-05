/*
** z26 is Copyright 1997-2011 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

void (* ReadAccess[0x10000])(void);
void (* WriteAccess[0x10000])(void);
void (* TIARIOTReadAccess[0x1000])(void);
void (* TIARIOTWriteAccess[0x1000])(void);

db RiotRam[128]; /* RIOT RAM (must be zero initially) */
db TIA[64];      /* TIA registers (also zeroed) */
db Ram[32768];   /* Extra RAM (used or not depends on bankswitch scheme) */

dd Frame = 0;     /* Frame counter */
dd PrevFrame = 0; /* Previous value of frame counter */

dd VBlanking = 0; /* 0 if vblanking, -1 otherwise */
db VBlank = 0;    /* VBlank flag */
db VSyncFlag = 0; /* VSync flag */

dd ScanLine = 0;  /* Current scan line */
dd OurBailoutLine = 0; /* Initial bailout line (fine tune if exceeded) */

dw *DisplayPointer = 0; // should init to RealScreenBuffer

#define CYCLESPERSCANLINE 76

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

#define CONTROLLERS_MAX 12

// char cli_controllers[CONTROLLERS_MAX][3] =
// {"JS","PC","KP","DC","LG","CM","KV","ML","ST","TB","AM","NC"};

#define BANKSWITCHING_MAX 38

char cli_bankswitching_types[BANKSWITCHING_MAX][5] =
{"1","2","3","4","5","6","7","8","9","10","11","12","13","14",
"4K","CV","F8SC","E0","3F","FE","F6SC","E7","F4SC","F8R","CM","3F+",
"UA","EF","3E","AR","F6","F4","MB","FASC","F8","DPC","4A50","0840"};

int cli_bankswitching_numbers[BANKSWITCHING_MAX] =
{1,2,3,4,5,6,7,8,9,10,11,12,13,14,
0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23};

// char MessageCode=0;	/* gets message code for final output */
char msg[1000];		/* message buffer */
char stat_msg[100];  /* status message buffer */
// int status_timer = -1; /* counts down once per frame while status is shown,
//								  status disappears when it's -1 again. */

// dd CartSize=0;		/* gets cart size */
// dd Checksum=0;		/* gets cart checksum */
// dd XChecksum=0;		/* gets alternative checksum */

db CartRom[0x8000f];

db PCXPalette[384];	/* palette information for PCX files goes here */

db *ScreenBuffer;       /* pointer to screen buffer (set to RealScreenBuffer 1-4) */
db *ScreenBufferPrev;   /* pointer to previous screen buffer */
db *PrevScreenBuffer;	/* previous pointer to screen buffer */
db *PrevScreenBufferPrev; /* previous pointer to previous screen buffer */

dd LinesInFrame;	/* # of lines in last frame */
dd PrevLinesInFrame;	/* # of lines in frame before that */
dd VBlankOff;		/* a valid VBlankOff was detected here */
dd VBlankOn;		/* a valid VBlankOn was detected here */
dd MaxLines;		/* # of lines in this video mode */
dd UserMaxLines;	/* user can limit the number of lines to display */
dd BailoutLine;		/* auto-sync occurs if game goes past this line */

dd SC_StartAddress;	/* supercharger start address */
db SC_ControlByte;	/* supercharger control byte */

dd crc;			/* holds accumulated CRC */

// #ifdef NEW_KEYBOARD
// #define KEYTABLESIZE 512
// #else
// #define KEYTABLESIZE 128
// #endif
// db KeyTable[KEYTABLESIZE];	/* event handler should tell z26 about keystrokes here */

/* SDL event handler should tell z26 about joystick states here */
int JoystickAxis[16][6];
db JoystickButton[16][32];
db Stelladaptor[16];	/* is joystick a Stealladaptor */

db ShowFPS;
db SoundQ[65537];	/* sound queue */
// dd SQ_Max = DEFAULT_SQ_MAX*3;
db signed_audio = 0;

/*
char RealScreenBuffer1[65000*2];
char RealScreenBuffer2[65000*2];
char RealScreenBuffer3[65000*2];
char RealScreenBuffer4[65000*2];
*/
// dd RealScreenBuffer1[32500];
// dd RealScreenBuffer2[32500];
// dd RealScreenBuffer3[32500];
// dd RealScreenBuffer4[32500];

#define TRIGMIN 1
// #define TRIGMAX 260	/* was 240 - Casino game 4 needs more */

//dd ChargeTrigger0 = TRIGMAX/2;        /* paddle charges (can be 1-240) */
//dd ChargeTrigger1 = TRIGMAX/2;
//dd ChargeTrigger2 = TRIGMAX/2;
//dd ChargeTrigger3 = TRIGMAX/2;

// dd ChargeTrigger0[4] = {TRIGMAX/2, TRIGMAX/2, TRIGMAX/2, TRIGMAX/2};

// #define CHARGEMAX 0x80000000;	/* don't charge capacitors over this value (MAIN.ASM)*/
// dd ChargeCounter = 0;		/* # of lines capacitors have been charging */

// db InputLatch[2] = {0, 0};	/* INPT4 + INPT5 */

// db CM_Collumn = 0;	/* Compumate key collumn to read - gets set by bankswitching */

db ExitEmulator;	/* leave the emulator when ESC or backslash are pressed */
db GamePaused;		/* toggle to pause emulator */
// dd ResetEmulator = 0; /* set to 1 after loading a new ROM */
db StartInGUI;
// char ROMLoaded = 0;

time_t MyTime;		/* structure used by the timer function to return 'Seconds' */
dd Seconds;		/* seconds since 1.1.1970 - used to randomize RIOT timer */

int target_fps = 0;

db DataBus;			/* state of the data bus - used for  moving data to and from the CPU emu */
dw AddressBus;		/* state of the address bus - used for read and write accesses */
void (* ReadROMAccess)(void);	/* the bankswitching read handlers will be called though this */
void (* WriteROMAccess)(void);	/* the bankswitching write handlers will be called through this */

/* variables from CPU emulation - used in tracing too */

dw reg_pc = 0;		/*  program counter */
db reg_sp = 0;		/*  stack pointer */
db reg_a = 0;		/*  accumulator (stored in AL) */
db flag_C = 0;		/*  carry bit   (stored in AH) */
db reg_x = 0;		/*  x register */
db reg_y = 0;		/*  y register */
db flag_Z = 0;		/*  zero test value (Z set when 0) */
db flag_N = 0;		/*  sign test value (N set when negative) */
db flag_D = 0;		/*  decimal flag */
db flag_V = 0;		/*  overflow flag */
db flag_I = 0;		/*  interrupt disable flag */
db flag_B = 0;		/*  break flag */
db RCycles = 0;		/*  cycles per instruction */
db RClock = 0;		/*  clock cycles */

db TriggerWSYNC = 0;	/* TIA tells CPU to pause on next read cycle */

void c_ClearScreenBuffers()
{
        int i;

        for (i=0; i<(32500); i++)
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

void c_InitCVars(void)
{
	int i;

	VBlankOff=0;
	VBlankOn=0;
	LinesInFrame=262;
	BailoutLine=320;
	for (i=0; i<KEYTABLESIZE; i++) KeyTable[i] = 0;
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
db IOPortA_Write;	/* value written to SWCHA */
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
db GrabInput; /* Grab keyboard/mouse? */
db UseBMP;              /* save screen shot from VGA buffer to BMP (no PCX from render buffer *EST* */
db SyncToSoundBuffer;   /* spend idle time with creating new sound bytes *EST* */
db SyncToMonitor;	/* maybe page flipping syncs to the monitor */
db LeftController;	/* controller in left port */
db RightController;	/* controller in Right port */
db PaddleAdjust;	/* wait for N lines before starting to evaluate paddle charge */
db SwapPortsFlag;	/* user wants port 0 to be swapped with port 1 */
db JoystickEnabled;	/* allow PC joystick input for VCS controllers with multiple PC inputs */
db UseExtraButtons = 0; /* use extra buttons on joystick for select/reset */
db MouseEnabled;	/* allow PC mouse input for VCS controllers with multiple PC inputs */
db KeyboardEnabled;	/* allow PC keyboard input for VCS controllers with multiple PC inputs */
db StelladaptorEnabled;	/* allow PC Stelladaptor input for VCS controllers with multiple PC inputs */
/*
** reinitialize the above variables
*/

/* moved here from sdlsrv.c */
// unsigned int Flips = 0;

/* 20040422 bkw: these determine which version(s) of sdl_Flip()
	are available, and which to call by default. */

#define FLIP_SDL_DELAY 1 /* always defined */

#ifdef UNIX_TIMING
struct timeval start_tv;
#  define FLIP_UNIX 2
#  define FLIP_CPUHOG 3
#  ifdef LINUX_RTC_TIMING
#    define FLIP_LINUX_RTC 4
     int flipType = FLIP_LINUX_RTC; /* if both are defined, default is this */
#  else
#    ifdef __BEOS__
     int flipType = FLIP_UNIX; /* James says BeOS works best with select() */
#    else
     int flipType = FLIP_CPUHOG; /* if unix but not Linux, CPUhog is default */
#    endif
#  endif
#else
  int flipType = FLIP_SDL_DELAY; /* else this is all we have, use it */
#endif

int fast = 0; /* cause emu to run as fast as possible (-F option) */

int totalFrames = 0;

void c_def_LoadDefaults(void)
{
	VideoMode = 0xff;
	TrueColor = 0;
	InWindow = 0;
	CFirst = 0xffff;
	quiet = 0;
	IOPortA = 0xff;
	IOPortA_Controllers = 0xff;
	IOPortA_UnusedBits = 0xff;
	IOPortA_Write = 0xff;
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
	UserMaxLines = 0xffff;
	DisableCompareCopy = 0;
	DoInterlace = 0;
	MouseRude = 0;         /* this doesn't work -- why? */
	GrabInput = 0;
	UseBMP = 0;
	SyncToSoundBuffer=0;
	SyncToMonitor=0;
	LeftController=0xff;
	RightController=0xff;
	ExitEmulator = 0;
	GamePaused = 0;
	StartInGUI = 0;
	OldCFirst = 0;
	PaddleAdjust = 0;
	SwapPortsFlag = 0;
	JoystickEnabled = 1;
	MouseEnabled = 1;
	KeyboardEnabled = 1;
	StelladaptorEnabled = 1;
	Seconds = time(&MyTime);	/* randomize RIOT timer (in RIOT.ASM)*/
}

/* bkw: This is like def_LoadDefaults(), but it doesn't do a full
	reset of all the commandline and gui options like screen size,
	full/window, quite, etc.
*/
void def_ResetState(void)
{
	/* TODO: see if these three really need resetting */
	/*
	LeftController=0xff;
	RightController=0xff;
	PaddleAdjust = 0;
	*/
	
	CFirst = 0xffff;
	IOPortA = 0xff;
	IOPortA_Controllers = 0xff;
	IOPortA_UnusedBits = 0xff;
	IOPortA_Write = 0xff;
	IOPortB = 0x0b;
	DoChecksum = 0;
	FrameExit = 0;
	dsp = 0;
	PaletteNumber = 0xff;
	UserPaletteNumber = 0xff;
	BSType = 0;
	KidVid = 0;
	KidVidTape = 0;
//	MaxLines = 0xffff ;  /* unreasonable default screen height - gets fixed by auto positioning */

	ExitEmulator = 0;
	GamePaused = 0;
	StartInGUI = 0;
	OldCFirst = 0;

	/* These put the controllers back into auto-detect mode. */
	LeftController=0xff;
	RightController=0xff;

	Seconds = time(&MyTime);	/* randomize RIOT timer (in RIOT.ASM)*/
}


/*
 * $Log: globals.c,v $
 * Revision 1.15  2005/02/11 20:22:02  estolberg
 * Fianally changed the rendering routines to render 320 pixels per line.
 * The narrow -e modes currently don't work properly anymore.
 *
 * Started to change the GUI to write into the rendering buffers.
 * This still needs a lot of work.
 *
 * Fixed a samll bug in video mode changing.
 * Previously changing from a small mode to a taller one would keep
 * the small output height.
 *
 * Fixed a small type in the manual, that John has pointed out
 * half a year ago. "ALT+V" should refer to missile 1.
 *
 * Revision 1.13  2004/06/05 05:57:01  urchlay
 *
 * New option -J to allow extra joystick buttons to act as game-reset,
 * select, and enter-GUI keys. Off by default. No way to remap yet,
 * and only works with joystick games for now. Basically just messing
 * around with this for now.
 *
 * Revision 1.12  2004/06/05 03:20:14  urchlay
 *
 * Resume and Reset Emulator are greyed out in the GUI if no ROM is
 * loaded. More generally, it's possible to grey out menu items now.
 *
 * Can now set left and right controller types in the GUI. They get reset
 * when a new ROM is loaded though (this is probably desired behavior).
 *
 * Revision 1.11  2004/06/04 03:00:47  urchlay
 *
 * Controller types now set to auto-detect when resetting/loading new ROM.
 * Allows us to play a joystick game and a paddle game in the same z26
 * session.
 *
 * Revision 1.10  2004/06/02 03:24:34  urchlay
 *
 * Really, really don't let the user run the emu with no ROM loaded. I mean
 * really this time :)
 *
 * Revision 1.9  2004/06/02 03:01:54  urchlay
 *
 * Can't resume/reset the emu unless a ROM is loaded.
 *
 * Revision 1.8  2004/06/02 02:39:00  urchlay
 *
 * Windows drive letter support (untested, checking it in so I can check it
 * back out under Windows).
 *
 * Revision 1.7  2004/06/01 03:53:14  urchlay
 *
 * we now call def_LoadDefaults() when loading a new ROM or resetting
 * from the GUI. This makes everything work (so far, still testing, but
 * my problems with moonswep.bin have gone away, as has the problem with
 * loading pitfall2.bin and not getting DSP sound after a reset).
 *
 * Unfortunately, this blows away all the options the user may have set,
 * either on the command line or via the GUI (including video mode getting
 * reset to fullscreen 400x300). There should be some other way to do this
 * short of a full emulator reset...
 *
 * Also the space bar will select a file in the fileselector, and the
 * pageup/down keys have no effect if less than a page's worth of files
 * are being displayed.
 *
 * Revision 1.6  2004/05/30 00:06:15  urchlay
 *
 * Backspace now toggles pause on/off. Enter (used to unpause) doesn't
 * do anything now.
 *
 * The string `Paused' now appears in the lower right of the screen when
 * the user pauses the game, and disappears when it's unpaused.
 *
 * The string `All Graphics ON' now appears in the lower right when the user
 * presses Alt-/ and disappears after 120 frames (2 or 2.4 sec, depending
 * on TV standard).
 *
 * There is now a generic draw_string(x, y) method in text.c that we can
 * use to draw text in the simplex5 font wherever we want in the SDL
 * buffer. This is what I'm planning to use to implement the text-based
 * GUI, instead of using a font library.
 *
 * Revision 1.5  2004/05/15 15:36:13  urchlay
 *
 * The rest of the graphics can be disabled/enabled:
 *
 * Alt+key   Graphic
 * Z         P0
 * X         P1
 * C         M0
 * V         M1
 * B         Ball
 * N         Playfield (whole thing)
 * /         Turns all of the above ON
 *
 * Revision 1.4  2004/05/14 20:03:17  urchlay
 *
 * We can enable/disable player 0 and player 1 graphics by pressing alt-z and
 * alt-x, respectively. The default state (of course) is enabled.
 *
 * Revision 1.3  2004/05/09 21:31:10  urchlay
 *
 * Added -G option to grab keyboard/mouse events with SDL_WM_GrabInput().
 * I need this so I can switch video modes while z26 is running (normally,
 * Alt-1 through Alt-9 in my environment are used to switch virtual
 * desktops, and z26 never sees these keystrokes). This might also
 * disable the Windows keys if you use it on Windows (not tested yet),
 * which could be good or bad, depending on whether you hit the Win keys
 * more often on purpose or by accident :)
 *
 * Revision 1.2  2004/05/08 18:06:57  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
