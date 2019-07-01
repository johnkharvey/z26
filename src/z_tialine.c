// ;*
// ;* z_tialine.c -- generate a raster line (simple version)
// ;*
// ;* 3-18-99 -- break ground
// ;*  9-7-02 -- 32-bit
// ;*  5-7-19 -- C version of classic engine
// ;* 5-22-19 -- simplified version of classic engine
// ;*
//
// ; magic numbers:
// ;
// ;  HBLANK starts at zero, ends at 67.
// ;  Left Playfield starts at 68, ends at 147.
// ;  Right Playfield starts at 148, ends at 227.
// ;  HMOVE blank starts at 68, ends at 75.

// ;*
// ;* store TIA graphics data two bytes at a time
// ;*

#define gs_store($1) \
    *DisplayPointer++ = $1; \
    *DisplayPointer++ = $1; \

// ;*
// ;* set object bits
// ;*

#define SetObjectBit($1) \
    if ($1##_Graphics) \
    { \
        esi = cl - $1##_Position; \
        if (cl < $1##_Position) \
            esi += 160; \
        if ((esi <= $1##_Size) && ($1##_Graphics & $1##_Table[esi*2])) \
            bl |= $1##_BIT; \
    } \

// ;*
// ;* render multiple objects against a playfield
// ;*

void PF_PixelLoop(void)
{
	while (cl <= ch)
	{
		bl = (PF_Table[(cl-68)>>2] & playfield_bits) != 0;
        SetObjectBit(BL);
        SetObjectBit(M0);
        SetObjectBit(M1);
        SetObjectBit(P0);
        SetObjectBit(P1);
        if (bl >= 2)
        {
            TIACollide |= TIAColTab[bl];
            bl = PixelColorTable[bl];
        };
//        al =  *ColorTab[bl] & RenderingHBLANK & LooseColour;
        al =  *ColorTab[bl] & RenderingHBLANK;
        gs_store(al);
        ++cl;
	}
}

// ;*
// ;*  render blackness
// ;*
// ;*  note:  This approach may cause collisions not to be processed during
// ;*         vertical blanks.  This may not be correct.
// ;*

void RenderNothing(void)
{
	while (cl <= ch)
    {
		gs_store(0);
        cl++;
    }
}

// ;*
// ;* render HBLANK
// ;*

void RenderHBLANK(void)
{
        RenderingHBLANK = 0;
        PF_PixelLoop();
        RenderingHBLANK = -1;
}

// ;*
// ;* RenderPixels
// ;*
// ;* Since the underlying routines are not capable of dealing with a change of
// ;* the state of HBlanking, we split calls to RenderPixels if necessary.
// ;*
// ;* We do the same thing at mid-playfield to update playfield color translation.
// ;*

void DoRender(void)
{
    if (VBlanking == 0) {
        RenderNothing();
    }
    else {
        UpdatePlayfieldColor;
        PF_PixelLoop();
    }
}

void RenderPixels(void)
{
    db t_ch;

    if (cl <= ch)
    {
        if ((HBlanking != -1) && (cl <= 75))
        {
            if (ch <= 75)
            {
                RenderHBLANK();
                return;
            }
            t_ch = ch;
            ch = 75;
            RenderHBLANK();
            ch = t_ch;
            HBlanking = -1;
        }
        if ((cl <= 147) && (ch > 147))
        {
            t_ch = ch;
            ch = 147;
            DoRender();
            ch = t_ch;
        }
        if (cl == 148)
        {
            UpdatePlayfieldReflection;
        }
        DoRender();
    }
}

// ;*
// ;* render pixels from cl through RClock
// ;*
// ;* points ch to RClock (RClock*3 - 1 + offset parameter in dl)
// ;* leaves cl pointing to ch + 1
// ;*
// ;* Normally the offset parameter should be zero, but this is where we can make
// ;* small adjustments for register writes that need some additional delays,
// ;* providing the delays don't need to straddle a line.
// ;*
// ;* note: Ignoring invisible regions might cause off-screen collisions to be
// ;*       missed.
// ;*

void CatchUpPixels(void)
{
	if (!Invisible)
	{
		if (RClock > CYCLESPERSCANLINE)
			ch = 227;
		else
		{
			ch = RClock*3 + dl - 1;
			if (ch > 227) ch = 227;
		}
		RenderPixels();
	}
}

// ;*
// ;* do some instructions until RClock >= CYCLESPERSCANLINE
// ;*

#define nDoInstructions \
    while (RClock < CYCLESPERSCANLINE) \
    { \
        do_Instruction(); \
        ClockRIOT \
        if (ExitEmulator) break; \
    } \

// ;*
// ;* TIALineTo -- the actual raster line code
// ;*

void nTIALineTo(void)
{
    int t_motion;

    QueueSoundBytes();
    Last_HMOVE_Cycle = HMOVE_Cycle;
    HMOVE_Cycle = 0;
    if (M0_Confused)
    {
        t_motion = M0_Motion;
        M0_Motion = 17;
        DoMotion(M0);
        M0_Motion = t_motion;

        if ((TIA[ENAM0] & 2) && !(TIA[RESM0P] & 2))
        {
            M0_Graphics = CosmicGraphicsTable[CosmicScanLine++ & 3];
        }    
    }
    if ((ScanLine < TopLine)     ||
        (ScanLine >= BottomLine) ||
        (DisplayPointer >= ScreenBuffer + MaxLines*tiawidth))
    {
        Invisible = 1;
        nDoInstructions;
        return;
    }
    cl = 68;
    if (SetHBlanking)
        HBlanking = 0;
    else
        HBlanking = -1;
    SetHBlanking = 0;
    SetupMultiSpriteTrick();
    if (RClock < CYCLESPERSCANLINE)
    {
        Invisible = 0;
        nDoInstructions;
    }
    ch = 227;
    RenderPixels();
}

// ; z26 is Copyright 1997-2019 by John Saeger and contributors.
// ; contributors.  z26 is released subject to the terms and conditions of the
// ; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
// ; Please see COPYING.TXT for details.
