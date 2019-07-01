// TIA variables

extern dd Timer;

extern db  Starpath;
extern db  KoolAide;
extern db  RSBoxing;

extern dd TopLine;
extern dd BottomLine;

void CatchUpPixels(void);
void ShowAdjusted(void);
void QueueSoundBytes(void);
void do_Instruction(void);

dd TIACollide;
db LooseColour = 0xff;			// ;  and this with pixels to turn
                                // ;  frame gray *EST*
                                // ;  see tiawrite.asm
db TIA_VBLANK = 0;

dd eax, ebx, ecx, edx, esi, edi;	// some temporary variables
db al, ah, bl, bh, cl, ch, dl, dh;

int sebx, sedx;		// signed "registers"

db t_graphics;					// graphics save for DoNUSIZ
dd t_ebx;						// for HandleMotion
int t_motion;					// for HandleMotion
db t_data;						// temp for DataBus
dd playfield_bits;				// all of the PF regs

/* Masks (used for disabling graphics objects) */
db p0_mask = 0xff;
db p1_mask = 0xff;
db m0_mask = 0xff;
db m1_mask = 0xff;
db bl_mask = 0xff;
db pf_mask = 0xff;

// ;*
// ;* private color registers
// ;*
// ;* we use old normal translation table to index into these (TIADisplayToColour)
// ;* update registers to handle SCORE and PFP
// ;*

dd BK_Color = 0;        // ; \-
dd PF_Color = 0;        // ;  \-  these no longer need to be kept in order
dd P1_Color = 0;        // ;  /-  
dd P0_Color = 0;        // ; /-
dd BL_Color = 0;        // ; ball color

dd* ColorTab[] = { &BK_Color, &PF_Color, &P1_Color, &P0_Color, &BL_Color };

int RenderingHBLANK = -1;

int ActiveObjects   =  0;
int CosmicScanLine  =  0;
int HBlanking       =  0;
int SetHBlanking    =  0;
int Invisible       =  0;
int HMOVE_Pending   =  0;
int HMOVE_Cycle     =  0;       // ; remember cycle of last HMOVE
int Last_HMOVE_Cycle = 0;
int M0_Confused     =  0;

db CosmicGraphicsTable[] = { 0x40,0x40,0xc0,0 };


// ;*
// ;* sprite related stuff
// ;*

#define DefineObjectVars($1) \
db* $1##_Table       = $1##_Sprite; \
int $1##_Position    = 228-68; \
int $1##_Size        = sizeofsprite($1##_Sprite);  \
int $1##_Motion      = 0; \
int $1##_Graphics    = 0; \
int $1##_Delayed     = 0; \
int $1##_TripleFlag  = 0; \

#define InitObjectVars($1) \
	$1##_Table       = $1##_Sprite; \
	$1##_Position    = 228-68; \
	$1##_Size        = sizeofsprite($1##_Sprite);  \
	$1##_Motion      = 0; \
	$1##_Graphics    = 0; \
	$1##_Delayed     = 0; \
	$1##_TripleFlag  = 0; \


DefineObjectVars(BL)
DefineObjectVars(M0)
DefineObjectVars(M1)
DefineObjectVars(P0)
DefineObjectVars(P1)

// ;*
// ;* TIA initialization code
// ;*

void Init_TIA(void)
{
	eax = ebx = ecx = edx = esi = edi = 0;	// some temporary variables
	al = ah = bl = bh = cl = ch = dl = dh = 0;

	ActiveObjects = 0;
	PF_Table = PFClockToBitForward;

	BK_Color = 0;        // ; \-
	PF_Color = 0;        // ;  \-  these no longer need to be kept in order
	P1_Color = 0;        // ;  /-  
	P0_Color = 0;        // ; /-
	BL_Color = 0;        // ; ball color

    RenderingHBLANK = -1;

    ActiveObjects   =  0;
    CosmicScanLine  =  0;
    HBlanking       =  0;
    SetHBlanking    =  0;
    Invisible       =  0;
    HMOVE_Pending   =  0;
    HMOVE_Cycle     =  0;       // ; remember cycle of last HMOVE
    Last_HMOVE_Cycle = 0;
    M0_Confused     =  0;


	InitObjectVars(BL)
	InitObjectVars(M0)
	InitObjectVars(M1)
	InitObjectVars(P0)
	InitObjectVars(P1)

	TIACollide = 0;
	LooseColour = 0xff;			// ;  and this with pixels to turn
                                // ;  frame gray *EST*
                                // ;  see tiawrite.asm
	TIA_VBLANK = 0;
	VBlank = 0;
	VSyncFlag = 0;
	VSyncCount = 0;
	DataBus = 0;
	TriggerWSYNC = 0;
	TopLine = 0;    			/* top line of display */
	BottomLine = 0; 			/* bottom line of display */
	playfield_bits = 0;			// all of the PF regs

}
