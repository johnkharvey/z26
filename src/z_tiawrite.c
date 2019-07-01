/*
	z_tiawrite.c -- handlers for writes to and reads from TIA registers
					this goes with z_tialine.c (the simple version)
*/

/*
	TIA read handlers
*/

void ReadCollision(void){
	dl = 0;
	CatchUpPixels();
	DataBus = (DataBus & 0x3f) |
	          ((TIACollide >> ((AddressBus & 0x7) << 1)) & 0x3) << 6;
}

void ReadAnalogINPT(void){

	if(ChargeTrigger0[AddressBus & 0x3] <= ChargeCounter)
		DataBus = (DataBus & 0x3f) | 0x80;
}

void ReadDigitalINPT(void){

	TestLightgunHit(RClock, ScanLine);
	DataBus = (DataBus & 0x3f) | InputLatch[AddressBus & 0x1];
}

void ReadTIAdummy ( void){

	DataBus &= 0x3f;	/* TIA only sets the two topmost bits */
}

void AdjustPalette() {

	if (Frame > 256) return;
	if (UserPaletteNumber != 0xff) return;
	if (GamePaletteNumber != 0xff) return;
	if (LinesInFrame != PrevLinesInFrame)
	{
		if (Frame != 3) return;		// force adjustment of unstable games (once)
	}

	if (LinesInFrame < 287)
	{	// NTSC
		if (PaletteNumber == 0) return;
		PaletteNumber = 0;
	}
	else
	{	// PAL
		if (PaletteNumber == 1) return;
		PaletteNumber = 1;
	}
	srv_SetPalette();
	ClearScreenBuffers();
	position_game();
}

void H_VSYNC(void){
	if(DataBus & 0x02){

		++VSyncCount;			// make sure we don't get WAY too many VSyncs
								// see ScanFrame()

		if (VSyncFlag) return;	// somebody hitting VSYNC more than necessary
		PrevLinesInFrame = LinesInFrame;
		LinesInFrame = ScanLine - 1;
		ScanLine = 1;
		if (LinesInFrame > 3)	// ignore quick double-hit (pickpile)
		{
			Frame++;
			VSyncCount = 0;
			AdjustPalette();
		}
	}
	VSyncFlag = DataBus & 0x02;
}

// ;*
// ;* VBLANK -- vertical blank set-clear
// ;*

void H_VBLANK(void){
	dl = 1;
	CatchUpPixels();
	VBlank = DataBus;
	TIA_VBLANK = DataBus & 0x02;

	if (VBlank & 2) VBlanking = 0;
	else 			VBlanking = -1;

	TopLine = CFirst + 1;

	if (PaletteNumber == 0)
		BottomLine = CFirst + MaxNTSC;
	else
		BottomLine = CFirst + MaxLines;
	
	if(DataBus & 0x80) ChargeCounter = 0;
}

// ;*
// ;* WSYNC -- wait for horizontal sync
// ;*

void H_WSYNC(void) {
	if (RClock <= CYCLESPERSCANLINE) {
		Timer -= CYCLESPERSCANLINE - RClock;
		RClock = CYCLESPERSCANLINE;
	}
	else {
		Timer -= 2*CYCLESPERSCANLINE - RClock;
		RClock = 2*CYCLESPERSCANLINE;
	}
}

//
// TIA graphics stuff
//

// ;*
// ;* some support code for TIA registers
// ;*

// ;*
// ;* get object position into ebx
// ;*

#define PositionObject($1) \
	if (RClock >= CYCLESPERSCANLINE) \
	{ \
		ebx = (RClock - CYCLESPERSCANLINE) * 3; \
		if (ebx <= 67) ebx = 226; \
	} \
	else if ((HMOVE_Cycle != 3) || (RClock > 24)) \
	{ \
		ebx = RClock * 3; \
		if (ebx <= 67) ebx = 226; \
	} \
	else \
	{ \
		ebx = WeirdRespCorrection[RClock] - $1##_Motion + 226; \
		if (ebx > 234) ebx = 234; \
		if (ebx >= 228) ebx -= 160; \
	} \

// ;*
// ;* object rendering macros
// ;*
// ;* they should OR their respective bits into ebx
// ;*

// ;*
// ;* table update support macro
// ;*

#define UpdateTable($1) \
	esi = TIA[NUSIZ##$1] & 7; \
	if ($1##_TripleFlag) \
	{ \
		$1##_Size = $1##_SizeTable[esi]; \
		$1##_Table = $1##_RegularTable[esi]; \
	} \
	else \
	{ \
		$1##_Size = $1##_MultipleSizeTable[esi]; \
		$1##_Table = $1##_MultipleTable[esi]; \
	} \

// ;*
// ;* get dl = object delay
// ;*     al = triple flag
// ;*    ebx = object position
// ;*

#define GetObjectDelay($1) \
	PositionObject($1); \
	esi = ebx; \
	al = 0; \
	dl = 0; \
	if (esi < $1##_Position) \
		esi = (esi + 160) - $1##_Position; \
	else \
		esi = esi - $1##_Position; \
	if (esi <= $1##_Size) \
	{ \
		dl = $1##_Table[esi*2+1]; \
		if (dl & 0x80) al = 1; \
		dl &= 0x7f; \
	} \

// ;*
// ;* update playfield color
// ;*
// ;* call before every pixel run (lots of things can affect PF color)
// ;*

#define UpdatePlayfieldColor \
	BL_Color = TIA[COLUPF]; \
	PF_Color = TIA[COLUPF]; \
 \
	if (TIA[CTRLPF] & PFP) \
	{ \
		PixelColorTable = TIADisplayToColour2; \
	} \
	else \
	{ \
		PixelColorTable = TIADisplayToColour; \
		if (TIA[CTRLPF] & SCORE) \
		{ \
			if (cl <= 147) \
				PF_Color = P0_Color; \
			else \
				PF_Color = P1_Color; \
		} \
	} \

// ;*
// ;* update playfield reflection
// ;*
// ;* call at mid-line, and when CTRLPF is updated
// ;*

#define UpdatePlayfieldReflection \
	PF_Table = PFClockToBitForward; \
	if (TIA[CTRLPF] & REF) PF_Table = PFClockToBitReversed; \

// ;*
// ;* update ball graphics
// ;*

void UpdateBallGraphics(void)
{
	dl = TIA[ENABL];
	if (TIA[VDELBL] & 1) dl = BL_Delayed;
	if (dl & 2)
	{
		BL_Graphics = BallSize[(TIA[CTRLPF] & 0x30) >> 4];
	}
	else {
		BL_Graphics = 0;
	}
}

// ;*
// ;* player graphics support macro
// ;*

#define UpdatePlayerGraphics($1) \
	dl = TIA[GR##$1]; \
	if (TIA[VDEL##$1] & 1) dl = $1##_Delayed; \
	if (dl) { \
		if (TIA[REF##$1] & 0x08) dl = TIAReflect8[dl]; \
	} \
	$1##_Graphics = dl; \

// ;*
// ;* update P0 graphics
// ;*

void UpdateP0Graphics(void)
{
	UpdatePlayerGraphics(P0);
}

// ;*
// ;* update P1 graphics
// ;*

void UpdateP1Graphics(void)
{
	UpdatePlayerGraphics(P1);
}

// ;*
// ;* missile graphics support macro
// ;*

#define RESM0P RESMP0
#define RESM1P RESMP1

#define UpdateMissileGraphics($1) \
	$1##_Graphics = 0; \
	if ((TIA[ENA##$1] & 2) && !(TIA[RES##$1##P] & 2)) \
	{ \
		$1##_Graphics = BallSize[(TIA[NUSIZ##$1] & 0x30) >> 4]; \
	} \

// ;*
// ;* update M0 graphics
// ;*

void UpdateM0Graphics(void)
{
	UpdateMissileGraphics(M0);
}

// ;*
// ;* update M1 graphics
// ;*

void UpdateM1Graphics(void)
{
	UpdateMissileGraphics(M1);
}

// ;*
// ;* update P0 Table
// ;*

void UpdateP0Table(void)
{
	UpdateTable(P0);
}

// ;*
// ;* update P1 Table
// ;*

void UpdateP1Table(void)
{
	UpdateTable(P1);
}


// ;*
// ;* update M0 Table
// ;*

void UpdateM0Table(void)
{
	UpdateTable(M0);
}

// ;*
// ;* update M1 Table
// ;*

void UpdateM1Table(void)
{
	UpdateTable(M1);
}

// ;*
// ;* set up multi-sprite trick
// ;* call at beginning of each scanline
// ;*

void SetupMultiSpriteTrick(void)
{
	if (M0_TripleFlag != 1)
	{
		M0_TripleFlag = 1;
		UpdateM0Table();
	}
	if (M1_TripleFlag != 1)
	{
		M1_TripleFlag = 1;
		UpdateM1Table();
	}
	if (P0_TripleFlag != 1)
	{
		P0_TripleFlag = 1;
		UpdateP0Table();
	}
	if (P1_TripleFlag != 1)
	{
		P1_TripleFlag = 1;
		UpdateP1Table();
	}
}

// ;*
// ;* missile locking support macro
// ;*

#define LockMissile($1, $2) \
	edx = MissileOffset[(TIA[NUSIZ##$1] & 7)] + $2##_Position; \
	if (edx > 227) edx -=160; \
	TIA[RES##$1] = edx; \
	$1##_Position = edx; \

// ;*
// ;* update M0 locking
// ;*

void UpdateM0Locking(void)
{
	if (TIA[RESMP0] & 2)
	{
		LockMissile(M0, P0);
	}
}

// ;*
// ;* update M1 locking
// ;*

void UpdateM1Locking(void)
{
	if (TIA[RESMP1] & 2)
	{
		LockMissile(M1, P1);
	}
}

// ;*
// ;* a do nothing TIA register write
// ;*

void H_Null(void)
{

}

// ;*
// ;* color setting support macro
// ;*

#define SetColor($1) \
	dl = 0; \
	CatchUpPixels(); \
	dl = (DataBus >> 1); \
	TIA[COLU##$1] = dl; \

// ;*
// ;* a TIA color register write
// ;*

void H_COLUP0(void)
{
	SetColor(P0);
	P0_Color = dl;
}

void H_COLUP1(void)
{
	SetColor(P1);
	P1_Color = dl;
}

void H_COLUBK(void)
{
	SetColor(BK);
	BK_Color = dl;
}

void H_COLUPF(void)
{
	SetColor(PF);
}

// ;*
// ;* CTRLPF write
// ;*

void H_CTRLPF(void)
{
	dl = 0;
	CatchUpPixels();
	TIA[CTRLPF] = DataBus;
	UpdateBallGraphics();
}

// ;*
// ;* a TIA playfield bit write
// ;*
// ;* Delays are set to make sure all 4 pixels of a playfield bit go
// ;* out unchanged even if the write occurs in middle of 4 bit group.
// ;* Plus there is additional delay if write occurs on last pixel
// ;* of a 4 bit group.  The next group uses the old value.
// ;*

#define HPF($1) \
	dl = PFDelay[(RClock*3) & 3]; \
	CatchUpPixels(); \
	TIA[$1] = DataBus & pf_mask; \
	playfield_bits = TIA[PF0] + (TIA[PF1]<<8) + (TIA[PF2]<<16); \

void H_PF0(void)
{
	HPF(PF0);
}

void H_PF1(void)
{
	HPF(PF1);
}

void H_PF2(void)
{
	HPF(PF2);
}

// ;*
// ;* horizontal motion support macro
// ;*

#define DoMotion($1) \
	$1##_Position -= $1##_Motion; \
	if ($1##_Position < 68)  \
		$1##_Position += 160; \
	else if ($1##_Position >= 228)  \
		$1##_Position -= 160; \

// ;*
// ;* HMOVE
// ;*
// 
// ;*
// ;* this could be called at beginning of a scanline
// ;* but it's called at register write time
// ;*

void doHMOVE(void)
{
	if (HMOVE_Pending)
	{
		DoMotion(P0);
		DoMotion(P1);
		DoMotion(M0);
		DoMotion(M1);
		DoMotion(BL);

		UpdateM0Locking();
		UpdateM1Locking();

		HMOVE_Pending = 0;
	}
}

// ;*
// ;* macro to set up amount of motion for HMOVES near beginning of scan line
// ;*

#define movsx($9) \
	(($9 & 0x8) ? (-16 | $9) : $9) \

#define FixupMotionLow($1) \
	sedx = movsx(TIA[HM##$1]); \
	sebx = MaxMotion[RClock]; \
	if (sedx >= sebx) $1##_Motion = sebx; \

#define FixupMotionHi($1) \
	sedx = movsx(TIA[HM##$1])+8; \
	sebx = HiTable[RClock - 55]; \
	sedx -= sebx; \
	if (sedx <= 0) sedx = 0; \
	$1##_Motion = sedx; \

// ;*
// ;* this is called at register write time
// ;*

void H_HMOVE(void)
{
	dl = 0;
	CatchUpPixels();
	HMOVE_Cycle = RClock;
	if (M0_Confused)
	{
		M0_Confused = 0;
		UpdateM0Graphics();
	}
	P0_Motion = movsx(TIA[HMP0]);
	P1_Motion = movsx(TIA[HMP1]);
	M0_Motion = movsx(TIA[HMM0]);
	M1_Motion = movsx(TIA[HMM1]);
	BL_Motion = movsx(TIA[HMBL]);
	HMOVE_Pending = 1;

	if (RClock > 20)
	{
		if (RClock <= 54) 
			return;

		if (RClock <= 74)
		{
			FixupMotionHi(P0);
			FixupMotionHi(P1);
			FixupMotionHi(M0);
			FixupMotionHi(M1);
			FixupMotionHi(BL);
			doHMOVE();
			return;			
		}

		SetHBlanking = 1;
		doHMOVE();
		return;
	}

	if (RClock <= 3)
	{
		HBlanking = 0;
		doHMOVE();
		return;
	}

	FixupMotionLow(P0);
	FixupMotionLow(P1);
	FixupMotionLow(M0);
	FixupMotionLow(M1);
	FixupMotionLow(BL);
	HBlanking = 0;
	doHMOVE();
}

// ;*
// ;* RESBL
// ;*

void H_RESBL(void)
{
	dd t_ebx;
	
	GetObjectDelay(BL);
	if (Starpath && ((ebx == 69) || (ebx == 226)))	// mind-master cheat
	{
		if ((HMOVE_Cycle == 5) || 
			(HMOVE_Cycle != 0) || 
			(Last_HMOVE_Cycle == 78))
		{
			ebx = 74;
		}	
	}
	t_ebx = ebx;
	CatchUpPixels();
	ebx = t_ebx;
	TIA[RESBL] = ebx;
	BL_Position = ebx;
}

// ;*
// ;* a positioning cheat for Kool Aide
// ;*

#define CheatKoolAidePosition($1, $2, $3) \
	if ((KoolAide) &&  \
		(ScanLine == $1) && \
		(ebx == $2+68-5)) \
	{ \
		ebx = $3+68-5; \
	} \

// ;*
// ;* RESP0
// ;*

void H_RESP0(void)
{
	dd t_ebx;

	GetObjectDelay(P0);
	t_ebx = ebx;
	P0_TripleFlag = al;
	CatchUpPixels();
	UpdateP0Table();
	ebx = t_ebx;
	CheatKoolAidePosition(40, 54, 52);
	CheatKoolAidePosition(49, 63, 61);
	TIA[RESP0] = ebx;
	P0_Position = ebx;
	UpdateM0Locking();
}

// ;*
// ;* RESP1
// ;*

void H_RESP1(void)
{
	dd t_ebx;

	GetObjectDelay(P1);
	t_ebx = ebx;
	P1_TripleFlag = al;
	CatchUpPixels();
	UpdateP1Table();
	ebx = t_ebx;
	CheatKoolAidePosition(40, 63, 65);
	CheatKoolAidePosition(49, 72, 74);
	TIA[RESP1] = ebx;
	P1_Position = ebx;
	UpdateM1Locking();
}

// ;*
// ;* RESM0
// ;*

void H_RESM0(void)
{
	dd t_ebx;

	if (!(TIA[RESMP0] & 2))
	{
		GetObjectDelay(M0);
		t_ebx = ebx;
		M0_TripleFlag = al;
		CatchUpPixels();
		UpdateM0Table();
		ebx = t_ebx;
		TIA[RESM0] = ebx;
		M0_Position = ebx;
	}
}

// ;*
// ;* RESM1
// ;*

void H_RESM1(void)
{
	dd t_ebx;

	if (!(TIA[RESMP1] & 2))
	{
		GetObjectDelay(M1);
		t_ebx = ebx;
		M1_TripleFlag = al;
		CatchUpPixels();
		UpdateM1Table();
		ebx = t_ebx;
		TIA[RESM1] = ebx;
		M1_Position = ebx;
	}
}

// ;*
// ;* ENABL
// ;*

void H_ENABL(void)
{
	dl = 1;
	CatchUpPixels();
	TIA[ENABL] = DataBus & bl_mask;
	UpdateBallGraphics();
}

// ;*
// ;* ENAM0
// ;*

void H_ENAM0(void)
{
	dl = 1;
	CatchUpPixels();
	TIA[ENAM0] = DataBus & m0_mask;
	UpdateM0Graphics();
}

// ;*
// ;* ENAM1
// ;*

void H_ENAM1(void)
{
	dl = 1;
	CatchUpPixels();
	TIA[ENAM1] = DataBus & m1_mask;
	UpdateM1Graphics();
}

// ;*
// ;* macro to handle writes to NUSIZ register
// ;*

#define DoNUSIZ($1) \
	GetObjectDelay(M##$1); \
	CatchUpPixels(); \
	if (((TIA[NUSIZ##$1]&7) == 5) || \
		((TIA[NUSIZ##$1]&7) == 7)) \
	{ \
		GetObjectDelay(P##$1); \
		if (dl) \
		{ \
			dl = 4; \
			CatchUpPixels(); \
		} \
	} \
	else \
	{ \
		GetObjectDelay(P##$1); \
		CatchUpPixels(); \
	} \
	TIA[NUSIZ##$1] = DataBus; \
	UpdateM##$1##Graphics(); \
	UpdateP##$1##Table(); \
	UpdateM##$1##Table(); \
	t_graphics = P##$1##_Graphics; \
	P##$1##_Graphics = 0; \
	GetObjectDelay(P##$1); \
	if (dl && RSBoxing) \
	{ \
		dl -=2; \
	} \
	CatchUpPixels(); \
	P##$1##_Graphics = t_graphics; \

// ;*
// ;* NUSIZ0
// ;*

void H_NUSIZ0(void)
{
	DoNUSIZ(0);
}

// ;*
// ;* NUSIZ1
// ;*

void H_NUSIZ1(void)
{
	DoNUSIZ(1);
}

// ;*
// ;* VDELBL
// ;*

void H_VDELBL(void)
{
	dl = 0;
	CatchUpPixels();
	TIA[VDELBL] = DataBus;
	UpdateBallGraphics();
}

// ;*
// ;* VDELP0
// ;*

void H_VDELP0(void)
{
	dl = 0;
	CatchUpPixels();
	TIA[VDELP0] = DataBus;
	UpdateP0Graphics();
}

// ;*
// ;* VDELP1
// ;*

void H_VDELP1(void)
{
	dl = 0;
	CatchUpPixels();
	TIA[VDELP1] = DataBus;
	UpdateP1Graphics();
}

// ;*
// ;* GRP0
// ;*

void H_GRP0(void)
{
	dl = 1;
	CatchUpPixels();
	TIA[GRP0] = DataBus & p0_mask;
	P1_Delayed = TIA[GRP1];
	UpdateP0Graphics();
	UpdateP1Graphics();
}

// ;*
// ;* GRP1
// ;*

void H_GRP1(void)
{
	dl = 1;
	CatchUpPixels();
	TIA[GRP1] = DataBus & p1_mask;
	BL_Delayed = TIA[ENABL];
	P0_Delayed = TIA[GRP0];
	UpdateBallGraphics();
	UpdateP0Graphics();
	UpdateP1Graphics();
}

// ;*
// ;* handle a non-M0 motion register
// ;*

#define HandleMotion($1) \
	t_ebx = ebx; \
	if ((HMOVE_Cycle == 3) && (RClock < 26)) \
	{ \
		ebx = (TIA[HM##$1] & 0xf) << 4; \
		edx = (DataBus >> 4) & 0xf; \
		ebx += edx; \
		ebx <<= 5; \
		edx = RClock & 0x1f; \
		ebx += edx; \
		t_motion = DeepHMOVE[ebx]; \
		if (t_motion && (t_motion != 99)) \
		{ \
			t_motion = -t_motion; \
			$1##_Motion = t_motion; \
			DoMotion($1); \
 \
			if (TraceCount) \
			{ \
				ShowAdjusted(); \
			} \
		} \
	} \
	TIA[HM##$1] = (DataBus  >> 4) & 0xf; /* not arithmetic shift */ \
	ebx = t_ebx; \

void H_HMP0(void)
{
	HandleMotion(P0);
}

void H_HMP1(void)
{
	HandleMotion(P1);
}

void H_HMM1(void)
{
	HandleMotion(M1);
}

void H_HMBL(void)
{
	HandleMotion(BL);
}

// ;*
// ;* HMM0
// ;*

void H_HMM0(void)
{
	if ((HMOVE_Cycle == 3) &&
		(RClock == 24) &&
		(M0_Motion == 7) &&
		(DataBus == 0x60))
	{
		M0_Confused = 1;
		CosmicScanLine = 1;
		M0_Motion = 2;
		DoMotion(M0);
	}
	HandleMotion(M0);
}

// ;*
// ;* HMCLR
// ;*

void H_HMCLR(void)
{
	t_data = DataBus;
	DataBus = 0;

	if ((HMOVE_Cycle == 3) &&
		(RClock == 23) &&
		(M0_Motion == 7))
	{
		M0_Confused = 1;
		CosmicScanLine = 1;
	}
	
	HandleMotion(M0);
	HandleMotion(M1);
	HandleMotion(P0);
	HandleMotion(P1);
	HandleMotion(BL);
	DataBus = t_data;

	TIA[HMP0] = 0;
	TIA[HMP1] = 0;
	TIA[HMM0] = 0;
	TIA[HMM1] = 0;
	TIA[HMBL] = 0;
}

// ;*
// ;* CXCLR
// ;*

void H_CXCLR(void)
{
	dl = 0;
	CatchUpPixels();
	TIACollide = 0;
}

// ;*
// ;* REFP0
// ;*

void H_REFP0(void)
{
	dl = 1;
	CatchUpPixels();
	TIA[REFP0] = DataBus;
	UpdateP0Graphics();
}

// ;*
// ;* REFP1
// ;*

void H_REFP1(void)
{
	dl = 1;
	CatchUpPixels();
	TIA[REFP1] = DataBus;
	UpdateP1Graphics();
}

// ;*
// ;* RESMP0
// ;*

void H_RESMP0(void)
{
	dl = 0;
	CatchUpPixels();
	TIA[RESMP0] = DataBus;
	UpdateM0Locking();
	UpdateM0Graphics();
}

// ;*
// ;* RESMP1
// ;*

void H_RESMP1(void)
{
	dl = 0;
	CatchUpPixels();
	TIA[RESMP1] = DataBus;
	UpdateM1Locking();
	UpdateM1Graphics();
}

void (* TIAReadHandler[16])(void) = {
	ReadCollision,	// CXM0P
	ReadCollision,	// CXM1P
	ReadCollision,	// CXP0FB
	ReadCollision,	// CXP1FB
	ReadCollision,	// CXM0FB
	ReadCollision,	// CXM1FB
	ReadCollision,	// CXBLPF
	ReadCollision,	// CXPPMM
	ReadAnalogINPT,	// INPT0
	ReadAnalogINPT,	// INPT1
	ReadAnalogINPT,	// INPT2
	ReadAnalogINPT,	// INPT3
	ReadDigitalINPT,	// INPT4
	ReadDigitalINPT,	// INPT5
	ReadTIAdummy,	// 0x0E
	ReadTIAdummy	// 0x0F
};

void (* TIAWriteHandler[64])(void) = {
	H_VSYNC,	 //  00 -- VSYNC
	H_VBLANK,	 //  01 -- VBLANK
	H_WSYNC,	 //  02 -- WSYNC
	H_Null,		 //  03 -- reset horizontal sync
				 // 	  for factory testing only !

	H_NUSIZ0,	 //  04 -- NUSIZ0
	H_NUSIZ1,	 //  05 -- NUSIZ1
	H_COLUP0,	 //  06 -- COLUP0
	H_COLUP1,	 //  07 -- COLUP1
	H_COLUPF,	 //  08 -- COLUPF
	H_COLUBK,	 //  09 -- COLUBK
	H_CTRLPF,	 //  0a -- CTRLPF
	H_REFP0,	 //  0b -- REFP0
	H_REFP1,	 //  0c -- REFP1
	H_PF0,		 //  0d -- PF0
	H_PF1,		 //  0e -- PF1
	H_PF2,		 //  0f -- PF2
	H_RESP0,	 //  10 -- RESP0
	H_RESP1,	 //  11 -- RESP1
	H_RESM0,	 //  12 -- RESM0
	H_RESM1,	 //  13 -- RESM1
	H_RESBL,	 //  14 -- RESBL
	H_AUDC0,	 //  15 -- AUDC0
	H_AUDC1,	 //  16 -- AUDC1
	H_AUDF0,	 //  17 -- AUDF0
	H_AUDF1,	 //  18 -- AUDF1
	H_AUDV0,	 //  19 -- AUDV0
	H_AUDV1,	 //  1a -- AUDV1
	H_GRP0,		 //  1b -- GRP0
	H_GRP1,		 //  1c -- GRP1
	H_ENAM0,	 //  1d -- ENAM0
	H_ENAM1,	 //  1e -- ENAM1
	H_ENABL,	 //  1f -- ENABL
	H_HMP0,		 //  20 -- HMP0
	H_HMP1,		 //  21 -- HMP1
	H_HMM0,		 //  22 -- HMM0
	H_HMM1,		 //  23 -- HMM1
	H_HMBL,		 //  24 -- HMBL
	H_VDELP0,	 //  25 -- VDELP0
	H_VDELP1,	 //  26 -- VDELP1
	H_VDELBL,	 //  27 -- VDELBL
	H_RESMP0,	 //  28 -- RESMP0
 	H_RESMP1,	 //  29 -- RESMP1
	H_HMOVE,	 //  2a -- HMOVE
	H_HMCLR,	 //  2b -- HMCLR
	H_CXCLR,	 //  2c -- CXCLR

	H_Null,		 //  2d -- these registers are undefined
	H_Null,		 //  2e
	H_Null,		 //  2f
	H_Null,		 //  30
	H_Null,		 //  31
	H_Null,		 //  32
	H_Null,		 //  33
	H_Null,		 //  34
	H_Null,		 //  35
	H_Null,		 //  36
	H_Null,		 //  37
	H_Null,		 //  38
	H_Null,		 //  39
	H_Null,		 //  3a
	H_Null,		 //  3b
	H_Null,		 //  3c
	H_Null,		 //  3d
	H_Null,		 //  3e
	H_Null		 //  3f
};

/*
	call the right TIA write handler
*/

void C_NewTIA(void)
{
	esi = AddressBus & 0x3f;
	(* TIAWriteHandler[esi])();
}

// ; z26 is Copyright 1997-2019 by John Saeger and contributors.
// ; contributors.  z26 is released subject to the terms and conditions of the
// ; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
// ; Please see COPYING.TXT for details.
