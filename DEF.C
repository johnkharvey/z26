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
extern long int TraceCount;
extern char Use50Hz;

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

def_SaveDefaults()
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
}

def_LoadDefaults()
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
}

