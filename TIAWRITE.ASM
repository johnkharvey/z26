; new TIA write handlers

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 3-12-1999 -- break ground

.data

TIARegHandler label word

	dw	H_VSYNC		; 00 -- VSYNC
	dw	H_VBLANK	; 01 -- VBLANK
	dw	H_WSYNC		; 02 -- WSYNC
	dw	H_Null		; 03 -- reset horizontal sync
				;       for factory testing only !

	dw	H_NUSIZ0	; 04 -- NUSIZ0
	dw	H_NUSIZ1	; 05 -- NUSIZ1
	dw	H_COLUP0	; 06 -- COLUP0
	dw	H_COLUP1	; 07 -- COLUP1
	dw	H_COLUPF	; 08 -- COLUPF
	dw	H_COLUBK	; 09 -- COLUBK
	dw	H_CTRLPF	; 0a -- CTRLPF
	dw	H_REFP0		; 0b -- REFP0
	dw	H_REFP1		; 0c -- REFP1
	dw	H_PF		; 0d -- PF0
	dw	H_PF		; 0e -- PF1
	dw	H_PF		; 0f -- PF2
	dw	H_RESP0		; 10 -- RESP0
	dw	H_RESP1		; 11 -- RESP1
	dw	H_RESM0		; 12 -- RESM0
	dw	H_RESM1		; 13 -- RESM1
	dw	H_RESBL		; 14 -- RESBL
	dw	H_Sound		; 15 -- AUDC0
	dw	H_Sound		; 16 -- AUDC1
	dw	H_Sound		; 17 -- AUDF0
	dw	H_Sound		; 18 -- AUDF1
	dw	H_Sound		; 19 -- AUDV0
	dw	H_Sound		; 1a -- AUDV1
	dw	H_GRP0		; 1b -- GRP0
	dw	H_GRP1		; 1c -- GRP1
	dw	H_ENAM0		; 1d -- ENAM0
	dw	H_ENAM1		; 1e -- ENAM1
	dw	H_ENABL		; 1f -- ENABL
	dw	H_HMP0		; 20 -- HMP0
	dw	H_HMP1		; 21 -- HMP1
	dw	H_HMM0		; 22 -- HMM0
	dw	H_HMM1		; 23 -- HMM1
	dw	H_HMBL		; 24 -- HMBL
	dw	H_VDELP0	; 25 -- VDELP0
	dw	H_VDELP1	; 26 -- VDELP1
	dw	H_VDELBL	; 27 -- VDELBL
	dw	H_RESMP0	; 28 -- RESMP0
 	dw	H_RESMP1	; 29 -- RESMP1
	dw	H_HMOVE		; 2a -- HMOVE
	dw	H_HMCLR		; 2b -- HMCLR
	dw	H_CXCLR		; 2c -- CXCLR

	dw	H_Null		; 2d -- these registers are undefined
	dw	H_Null		; 2e
	dw	H_Null		; 2f
	dw	H_Null		; 30
	dw	H_Null		; 31
	dw	H_Null		; 32
	dw	H_Null		; 33
	dw	H_Null		; 34
	dw	H_Null		; 35
	dw	H_Null		; 36
	dw	H_Null		; 37
	dw	H_Null		; 38
	dw	H_Null		; 39
	dw	H_Null		; 3a
	dw	H_Null		; 3b
	dw	H_Null		; 3c
	dw	H_Null		; 3d
	dw	H_Null		; 3e
	dw	H_Null		; 3f

	dw	H_Null

PFDelay db	4, 3, 2, 5	; delays for writes to PF registers


BallSize label byte
	db	10000000b
	db	11000000b
	db	11110000b
	db	11111111b


TIAReflect8 label byte
 db 0,128,64,192,32,160,96,224,16,144,80,208,48,176,112,240
 db 8,136,72,200,40,168,104,232,24,152,88,216,56,184,120,248
 db 4,132,68,196,36,164,100,228,20,148,84,212,52,180,116,244
 db 12,140,76,204,44,172,108,236,28,156,92,220,60,188,124,252
 db 2,130,66,194,34,162,98,226,18,146,82,210,50,178,114,242
 db 10,138,74,202,42,170,106,234,26,154,90,218,58,186,122,250
 db 6,134,70,198,38,166,102,230,22,150,86,214,54,182,118,246
 db 14,142,78,206,46,174,110,238,30,158,94,222,62,190,126,254
 db 1,129,65,193,33,161,97,225,17,145,81,209,49,177,113,241
 db 9,137,73,201,41,169,105,233,25,153,89,217,57,185,121,249
 db 5,133,69,197,37,165,101,229,21,149,85,213,53,181,117,245
 db 13,141,77,205,45,173,109,237,29,157,93,221,61,189,125,253
 db 3,131,67,195,35,163,99,227,19,147,83,211,51,179,115,243
 db 11,139,75,203,43,171,107,235,27,155,91,219,59,187,123,251
 db 7,135,71,199,39,167,103,231,23,151,87,215,55,183,119,247
 db 15,143,79,207,47,175,111,239,31,159,95,223,63,191,127,255


WeirdRespCorrection label word
 dw   0,  0,  0,  0,  0,  0,  1,  2,  2,  3
 dw   4,  5,  5,  6,  7,  8,  8,  9, 10, 11
 dw  11, 12, 13, 14, 14, 15

TempCFirst		dw	0
MinCFirst		dw	0
MinVBlankOff		dw	0
FavorTop		dw	0
StableCount		dw	0
TopLineToCenter		dw	0
MaxVisibleToCenter	dw	0


.code

;*
;* deep motion tracing macro
;*

CheckDeep macro
local NotDeep, IsDeep, VeryDeep
IFDEF showdeep
	test	[_TraceCount],4
	jz	NotDeep

	cmp	[RClock],25
	ja	NotDeep
	cmp	[HMOVE_Cycle],0
	jne	IsDeep
	cmp	[Last_HMOVE_Cycle],54
	ja	IsDeep
	jmp	NotDeep

IsDeep:
	cmp	[HMOVE_Cycle],3
	jne	VeryDeep

	pushad
	movzx	dx,[RClock]
	push	dx
	movzx	dx,[TIA+si]
	and	dx,0fh
	push	dx
	mov	dl,[WByte]
	sar	dl,4
	movzx	dx,dl
	and	dx,0fh
	push	dx
	call	_ShowDeep
	pop	dx
	pop	dx
	pop	dx
	popad

	jmp	NotDeep

VeryDeep:
	pushad
	movzx	dx,[RClock]
	push	dx
	movzx	dx,[TIA+si]
	and	dx,0fh
	push	dx
	mov	dl,[WByte]
	sar	dl,4
	movzx	dx,dl
	and	dx,0fh
	push	dx
	call	_ShowVeryDeep
	pop	dx
	pop	dx
	pop	dx
	popad

NotDeep:
ENDIF
	endm

;*
;* weird motion tracing macro
;*

CheckWeird macro
local NotWeird
IFDEF showdeep
	test	[_TraceCount],2
	jz	NotWeird

	cmp	[RClock],3
	je	NotWeird

	pushad
	movzx	dx,[RClock]
	push	dx
	call	_ShowWeird
	pop	dx
	popad

NotWeird:
ENDIF
	endm

;*
;* This is the TIA write handler.
;*
;* on entry:
;*
;*	si =	  TIA register to write to
;*	[WByte] = value to write
;*

NewTIA:	
	SaveCPUState
	and	esi,03fh
	call	[TIARegHandler + esi*2]	; call the write handler
	RestoreCPUState
	ret


;*
;* WSYNC -- wait for horizontal sync
;*

H_WSYNC:
	cmp	[RClock],CYCLESPERSCANLINE	; did WSYNC come after end of line?
	ja	SetSkip				;   yes, skip a line (** check this **)

WsyncSimple:
	mov	edx,CYCLESPERSCANLINE
	sub	dl,[RClock]
	sub	dword ptr [Timer],edx		; clock RIOT
	mov	[RClock],CYCLESPERSCANLINE	; and CPU clock
	ret

SetSkip:
	mov	edx,2*CYCLESPERSCANLINE		; skipping a line, bigger adjustment
	sub	dl,[RClock]
	sub	dword ptr [Timer],edx		; clock RIOT
	mov	[RClock],2*CYCLESPERSCANLINE	; and CPU clock
	ret

;*
;* VSYNC -- vertical sync set-clear
;*

H_VSYNC:
	test	[WByte],2		; if d1 is set then ....
	jz	ZRET
	test	[VSyncFlag],2		; somebody hitting Vsync more than necessary?
	jnz	VSyncAlreadySet		;	  yep

	mov	dx,[_LinesInFrame]
	mov	[_PrevLinesInFrame],dx
	mov	dx,[ScanLine]
	mov	[_LinesInFrame],dx	; *EST*
	dec	[_LinesInFrame]

DontUpdateLinesInFrame:
	mov	dword ptr [LooseColour],0ffffffffh
;	cmp	[_PaletteNumber],1	; PAL palette?
;	jne	GrayFrame		;   no, don't simulate color loss
	test	[_SimColourLoss],1
	jz	GrayFrame
	test	[_LinesInFrame],1
	jz	GrayFrame
	mov	dword ptr [LooseColour],007070707h ; see tialine.asm
GrayFrame:
	mov	[ScanLine],1		; back to screen top

	cmp	dx,5			; a quick double hit (pickpile)?
	jb	VSyncAlreadySet		;   yes, no new frame
	inc	[Frame]			; new frame.

;*
;* automatic adjustment of game position (and video mode)
;*

	mov	dx,[_CFirst]
	mov	[TempCFirst],dx	; to see how much we're changing by

	cmp	[Frame],5
	je	AdjustUnstable		; force adjustment of unstable games (pickpile)

	mov	dx,[_LinesInFrame]
	cmp	dx,[_PrevLinesInFrame]
	jne	AlreadyInPALMode	; don't change video mode if not matching previous frame (quadrun)

	test	[_IOPortB],1		; reset being pressed?
	jz	VSyncAlreadySet		;   yes, don't adjust

AdjustUnstable:
	cmp	[_LinesInFrame],282	; NTSC game? (pharhcrs 296 when fire button pressed ...
					;	     (... air_raid 292, zoofun 291, dumbo 286, curtiss 286,
					;	     (... tps 285, galaga 282, tomboy 277)
	jb	AlreadyInPALMode	;   yes

	cmp	[_PaletteNumber],1	; PAL mode already ?
	jz	AlreadyInPALMode	;   yes
	cmp	[_UserPaletteNumber],0ffh ; is there a palette override?
	jnz	AlreadyInPALMode	;   yes, don't switch

        test    [Frame],0ffffff00h      ; more than 256 frames passed?
        jnz     AlreadyInPALMode        ;    yes, don't change TV type *EST*

	mov	[_PaletteNumber],1	; set up PAL palette
	pushad
	call	TIAGraphicMode		; reset video mode for PAL games
	popad

AlreadyInPALMode:
	cmp	[_LinesInFrame],512	; game ridiculously large?
	ja	VSyncAlreadySet		;   yes, no automatic adjustment
	cmp	[_LinesInFrame],220	; game ridiculously small?
	ja	GameSizeOK		;   no
	cmp	[_BailoutLine],512	; maybe BailoutLine is too small -- too big already?
	ja	GameSizeOK
	mov	dx,[_LinesInFrame]
	add	dx,4			; match offset to below (aciddrop)
	add	[_BailoutLine],dx
	jmp	BailoutSet

GameSizeOK:
	mov	dx,[_LinesInFrame]
	cmp	dx,[_PrevLinesInFrame]
	jne	BailoutSet		; don't reset BailoutLine if not matching previous frame (quadrun)
	add	dx,4			; minimum 6 is needed for aciddrop or it flashes
	mov	[_BailoutLine],dx

BailoutSet:

VSyncAlreadySet:
	mov	dx,[_CFirst]
	cmp	dx,0			; forcing first line ?
	jz	ZRET			;   no, let vblank take care of it

	call	TIABlank

DontBlank:
	mov	[TopLine],dx
	add	dx,[_MaxLines]
	mov	[BottomLine],dx
ZRET:	mov	dl,[WByte]
	mov	[VSyncFlag],dl	
 	Ret

;*
;* VBLANK -- vertical blank set-clear
;*

H_VBLANK:
	SaveCPUState
	mov	dl,1			; VBlank delayed by 1 pixel
	call	CatchUpPixels		; render pixels up to the write clock
	RestoreCPUState

	mov	dl,[WByte]
	mov	[VBlank],dl
	test	dl,2			; setting or clearing ?
	jz	WVBClear		;	  clearing

	mov	dx,[ScanLine]
	cmp	dx,200
	jb	VBOnAlreadySet
	mov	[_VBlankOn],dx

VBOnAlreadySet:
	cmp	[_CFirst],0		; VBlank triggering new frame ?
	je	WTB_1			;	yes, don't mess with VBlanking
	mov	[VBlanking],0
	jmp	HandleDumpedInputs

WTB_1:
	mov	[TopLine],65535		;	  setting -- turn off Tia
	call	TIABlank		; clear rest of screen
	jmp	HandleDumpedInputs

WVBClear:
	mov	dx,[ScanLine]
	cmp	[_PaletteNumber],1	; NTSC game?
	jnz	DoNTSCTest		;   yes
	cmp	dx,78			; allow penguin vblank
	ja	VBOffAlreadySet
	mov	[_VBlankOff],dx
	jmp	VBOffAlreadySet

DoNTSCTest:
	cmp	dx,58			; allow brickick vblank
	ja	VBOffAlreadySet
	mov	[_VBlankOff],dx

VBOffAlreadySet:
	cmp	[_CFirst],0		; VBlank triggering new frame ?
	je	WTB_2			;	yes, don't mess with VBlanking
	mov	[VBlanking],-1
	jmp	HandleDumpedInputs

WTB_2:
	mov	dx,[ScanLine]
	cmp	dx,[_CFirst]
	jae	WVBPastMin
	mov	dx,[_CFirst]
WVBPastMin:
	inc	dx
	mov	[TopLine],dx
	add	dx,[_MaxLines]
	mov	[BottomLine],dx
	jmp	HandleDumpedInputs	 


HandleDumpedInputs:
	test	[VBlank],080h		; discharging capacitors ?
	jz	HandleLatchedInputs	;   no
	mov	dword ptr [ChargeCounter],0 ;   yes, zero the line counter

HandleLatchedInputs:
	ret




;*
;* some support code for TIA registers
;*

;*
;* get object position into bx
;*

.code

PositionObject macro arg1
local HBLnowrap, HBLdone, HBLnotweird, HBLinrange, HBLhandle78

	movzx	ebx,[RClock]
	sub	ebx,CYCLESPERSCANLINE	; beyond end of scanline?
	jb	HBLnowrap		;   no
HBLnotweird:
	lea	ebx,[ebx+ebx*2]
	cmp	bl,67			; positioned in HBLANK area?
	ja	HBLdone			;	  no
	mov	bl,226
	jmp	HBLdone

HBLnowrap:
	add	ebx,CYCLESPERSCANLINE

	cmp	[HMOVE_Cycle],3		; HMOVE happening?
	jne	HBLnotweird		;   no

	cmp	bl,24			; affected by weirdness?
	ja	HBLnotweird		;   no
	mov	bx,[WeirdRespCorrection+2*ebx]
	sub	bx,[arg1&_Motion]
	add	bx,226
	cmp	bx,234
	jbe	HBLinrange
	mov	bx,234
HBLinrange:	
	cmp	bx,228
	jb	HBLdone
	sub	bx,160

HBLdone:
	endm


;*
;* get dl = object delay
;*     al = triple flag
;*     bx = object position
;*

GetObjectDelay macro arg1
local done, nowrap

	PositionObject arg1
	mov	si,bx

	xor	dl,dl			; assume delay 0
	xor	al,al			; assume no triple flag

	sub	si,[arg1&_Position]	  ; where the object is
	jae	nowrap
	add	si,160			
nowrap:	
	cmp	si,[arg1&_Size]		  ; beyond it's size?
	ja	done			;   yes, no delay
	add	si,si
	inc	si			; point at delay byte
	add	si,[arg1&_Table]	  ; object's table
	mov	dl,[si]			; get delay byte
	test	dl,080h			; triple flag set?
	setnz	al			;	set al if so
	and	dl,07fh			; delay value
done:
	endm


;*
;* Object activation/deactivation
;*
;* bit to activate/deactivate in al
;*

ActivateObject macro arg1
	or	[ActiveObjects],arg1
	endm

DeactivateObject macro arg1
	and	[ActiveObjects], not arg1
	endm


;*
;* update playfield color
;*
;* call before every pixel run (lots of things can affect PF color)
;*

doUpdatePlayfieldColor:
	mov	dl,[TIA+COLUPF]
	mov	dh,dl			; 16-bit playfield color
	mov	[BL_Color],dx		; ball is always this color
	mov	[PF_Color],dx		; assume *normal* state of affairs

	mov	dx,offset TIADisplayToColour
	test	[TIA+CTRLPF],PFP	; does playfield have priority?
	jz	UPFC_CheckScore		;	 no
	mov	dx,offset TIADisplayToColour2
	mov	[PixelColorTable],dx	;   yes, update pixel to color translation table
	jmp	UPFC_done		; don't pay attention to score mode...

UPFC_CheckScore:
	mov	[PixelColorTable],dx	; update pixel to color translation table
	test	[TIA+CTRLPF],SCORE	; in score mode?
	jz	UPFC_done		;   no
	mov	dx,[P0_Color]		; assume Player 0 color
	cmp	cl,147			; right side of playfield?
	jbe	UPFC_SetReg		;   no
	mov	dx,[P1_Color]		;	yes, use Player 1 color
UPFC_SetReg:
	mov	[PF_Color],dx		; update the register

UPFC_done:
	ret


UpdatePlayfieldColor macro
	call	doUpdatePlayfieldColor
	endm


;*
;* update playfield reflection
;*
;* call at mid-line, and when CTRLPF is updated
;*

UpdatePlayfieldReflection macro
local UPFR_Ret

	mov	[PF_Table],offset PFClockToBitForward
	test	[TIA+CTRLPF],REF	; playfield reflected?
	jz	UPFR_Ret		;	  no
	mov	[PF_Table],offset PFClockToBitReversed
UPFR_Ret:

	endm


;*
;* update ball graphics
;*

UpdateBallGraphics:
	
	mov	dl,[TIA+ENABL]		; assume regular ball
	test	[TIA+VDELBL],1		; using delayed register?
	jz	UBGtestball		;   no
	mov	dl,[BL_Delayed]		;	  yes, use delayed ball

UBGtestball:
	test	dl,2			; ball turned on?
	jz	UBGnoball		;   no
	ActivateObject	BL_BIT		;   yes, ActivateObject
	mov	dl,030h			; mask ball size
	and	dl,[TIA+CTRLPF]
	movzx	si,dl
	shr	si,4
	mov	dl,[BallSize + si]	; look up in table
	mov	[BL_Graphics],dl	; set graphics register
	ret


UBGnoball:
	DeactivateObject BL_BIT		; no ball, DeactivateObject
	mov	[BL_Graphics],0		; clear the graphics register

	ret


;*
;* player graphics support macro
;*

UpdatePlayerGraphics macro arg1
local UPnodelay, UPdone

	mov	dl,[TIA+GR&arg1]	  ; assume regular graphics
	test	[TIA+VDEL&arg1],1	  ; using delayed register?
	jz	UPnodelay		;   no
	mov	dl,[arg1&_Delayed]	  ;   yes, use delayed graphics
UPnodelay:
	DeactivateObject arg1&_BIT	  ; assume not active
	test	dl,dl			; graphics active?
	jz	UPdone			;	 no, done
	ActivateObject arg1&_BIT	  ;   yes, ActivateObject
	test	[TIA+REF&arg1],08h	  ; reflected?
	jz	UPdone			;	 no
	movzx	si,dl			;   yes
	mov	dl,[TIAReflect8+si]	; reflect it
UPdone:
	mov	[arg1&_Graphics],dl	  ; update register
	endm


;*
;* update P0 graphics
;*

UpdateP0Graphics:

	UpdatePlayerGraphics P0

	ret


;*
;* update P1 graphics
;*

UpdateP1Graphics:

	UpdatePlayerGraphics P1	

	ret

;*
;* missile graphics support macro
;*

RESM0P = RESMP0
RESM1P = RESMP1

UpdateMissileGraphics macro arg1
local noMissile

	DeactivateObject arg1&_BIT	  ; assume inactive
	mov	[arg1&_Graphics],0	  ; clear register
	test	[TIA+RES&arg1&P],2	  ; missile locked to player?
	jnz	noMissile		;   yes, no missile
	test	[TIA+ENA&arg1],2	  ; missile enabled?
	jz	noMissile		;   no
	ActivateObject arg1&_BIT	  ;   yes, ActivateObject
	movzx	si,[TIA+NUSIZ&arg1]	  ; size is here
	and	si,030h			; mask size bits
	shr	si,4
	mov	dl,[BallSize + si]	; look up in table
	mov	[arg1&_Graphics],dl	  ; update register
noMissile:
	endm


;*
;* update M0 graphics
;*

UpdateM0Graphics:

	UpdateMissileGraphics M0

	ret

;*
;* update M1 graphics
;*

UpdateM1Graphics:

	UpdateMissileGraphics M1

	ret

;*
;* table update support macro
;*

UpdateTable macro arg1
local regular_ok

	movzx	si,[TIA+NUSIZ&arg1]
	and	si,7
	movzx	dx,[arg1&_SizeTable+si]
	mov	[arg1&_Size],dx
	shl	si,1
	mov	dx,[arg1&_RegularTable+si] ; assume regular table
	cmp	[arg1&_TripleFlag],0
	jnz	regular_ok
	mov	dx,[arg1&_MultipleTable+si] ; use multiple table

regular_ok:
	mov	[arg1&_Table],dx

	endm

;*
;* update P0 Table
;*

UpdateP0Table:

	UpdateTable P0

	ret

;*
;* update P1 Table
;*

UpdateP1Table:

	UpdateTable P1

	ret

;*
;* update M0 Table
;*

UpdateM0Table:

	UpdateTable M0

	ret

;*
;* update M1 Table
;*

UpdateM1Table:

	UpdateTable M1

	ret

;*
;* set up multi-sprite trick
;* call at beginning of each scanline
;*

SetupMultiSpriteTrick:
	cmp	[M0_TripleFlag],1
	je	SMS_M1
	mov	[M0_TripleFlag],1
	call	UpdateM0Table

SMS_M1:	cmp	[M1_TripleFlag],1
	je	SMS_P0
	mov	[M1_TripleFlag],1
	call	UpdateM1Table

SMS_P0:	cmp	[P0_TripleFlag],1
	je	SMS_P1
	mov	[P0_TripleFlag],1
	call	UpdateP0Table

SMS_P1:	cmp	[P1_TripleFlag],1
	je	SMS_done
	mov	[P1_TripleFlag],1
	call	UpdateP1Table

SMS_done:	
	ret


;*
;* missile locking support macro
;*

.data
MissileOffset db 5, 5, 5, 5, 5, 8, 5, 12
.code

LockMissile macro arg1, arg2
local nowrap

	push	si
	movzx	si,[TIA+NUSIZ&arg1]
	and	si,7
	movzx	dx,[MissileOffset+si]
	pop	si

	add	dx,[arg2&_Position]
	cmp	dx,227
	jbe	nowrap
	sub	dx,160
nowrap:
	mov	[TIA+RES&arg1],dl
	mov	[arg1&_Position],dx

	endm

;*
;* update M0 locking
;*

UpdateM0Locking:
	test	[TIA+RESMP0],2
	jz	M0nolock

	LockMissile M0 P0

M0nolock:
	ret

;*
;* update M1 locking
;*

UpdateM1Locking:
	test	[TIA+RESMP1],2
	jz	M1nolock

	LockMissile M1 P1

M1nolock:
	ret

;*
;* a do nothing TIA register write
;*

H_Null:	ret				; a null TIA register write


;*
;* a TIA sound register write
;*

H_Sound:
	cmp	[_quiet],0		; doing sound at all?
	jnz	nTRQuiet		;   no
	cmp	[_Sb_init],0		; SoundBlaster initialized ?
	jz	nDoPCSpeaker		;   no, use speaker

	mov	bx,si
	mov	al,[WByte]

	call	_Update_tia_sound

nTRQuiet:
	ret
	
nDoPCSpeaker:
	mov	bx,si			; bl = register
	mov	bh,[WByte]		; bh = data
	call	Sound			; do some PC speaker sound stuff
	ret

;*
;* color setting support macro
;*

SetColor macro arg1
	mov	dl,0
	call	CatchUpPixels

	mov	dl,[WByte]
	shr	dl,1			; pre shift right 1 bit
	mov	[TIA+COLU&arg1],dl	  ; update the register
	mov	dh,dl

	endm

;*
;* a TIA color register write
;*

H_COLUP0:
	SetColor P0
	mov	[P0_Color],dx

	ret

H_COLUP1:
	SetColor P1
	mov	[P1_Color],dx

	ret

H_COLUBK:
	SetColor BK
	mov	[BK_Color],dx	

	ret

H_COLUPF:
	SetColor PF

	ret


;*
;* CTRLPF write
;*

H_CTRLPF:
	mov	dl,0
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+CTRLPF],dl

HCPFdone:
	call	UpdateBallGraphics
	ret

;*
;* a TIA playfield bit write
;*
;* Delays are set to make sure all 4 pixels of a playfield bit go 
;* out unchanged even if the write occurs in middle of 4 bit group.
;* Plus there is additional delay if write occurs on last pixel 
;* of a 4 bit group.  The next group uses the old value.
;*

H_PF:
	mov	bl,[RClock]
	add	bl,bl
	add	bl,[RClock]		; write occurred here

	and	bx,3
	mov	dl,[PFDelay+bx]		; render this far into the future

	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+si],dl		; update the register

	DeactivateObject PF_BIT
	test	dword ptr [TIA+PF0],0ffffffh  ; test playfield bits
	jz	H_PFRet
	ActivateObject PF_BIT

H_PFRet:
	ret

;*
;* horizontal motion support macro
;*

DoMotion macro arg1
local positive, done

	mov	dx,[arg1&_Motion]
	sub	[arg1&_Position],dx
	cmp	[arg1&_Position],68
	jae	positive
	add	[arg1&_Position],160
	jmp	done

positive:
	cmp	[arg1&_Position],228
	jb	done
	sub	[arg1&_Position],160
done:
	endm

;*
;* HMOVE
;*

;*
;* this could be called at beginning of a scanline
;* but it's called at register write time
;*

doHMOVE:
	cmp	[HMOVE_Pending],0
	jz	noHMOVE

	DoMotion P0
	DoMotion P1
	DoMotion M0
	DoMotion M1
	DoMotion BL

	call	UpdateM0Locking
	call	UpdateM1Locking

	mov	[HMOVE_Pending],0

noHMOVE:
	ret

;*
;* macro to set up amount of motion for HMOVES near beginning of scan line
;*

.data

MaxMotion label byte
 db   7,  7,  7,  7,  6,  5,  5,  4,  3,  2
 db   2,  1,  0, -1, -1, -2, -3, -4, -4, -5
 db  -6

.code

FixupMotionLow macro arg1
local MotionOK

	movsx	dx,[TIA+HM&arg1]
	push	bx
	movzx	bx,[RClock]
	movsx	bx,[MaxMotion+bx]
	cmp	dx,bx
	jl	MotionOK
	mov	dx,bx
	mov	[arg1&_Motion],dx
MotionOK:
	pop	bx
	endm

;*
;* this is called at register write time
;*	

H_HMOVE:
	mov	dl,0
	call	CatchUpPixels

	CheckWeird
	
	mov	dl,[RClock]
	mov	[HMOVE_Cycle],dl	; remember where HMOVE was (cosmic)
	cmp	[M0_Confused],0
	jz	WasntConfused

	mov	[M0_Confused],0		; HMOVE cancels confusion
	call	UpdateM0Graphics

WasntConfused:
	movsx	dx,[TIA+HMP0]		; xx_Motion is different from HMxx
	mov	[P0_Motion],dx		; in case we decide to doHMOVE 
	movsx	dx,[TIA+HMP1]		; somewhere else
	mov	[P1_Motion],dx
	movsx	dx,[TIA+HMM0]
	mov	[M0_Motion],dx
	movsx	dx,[TIA+HMM1]
	mov	[M1_Motion],dx
	movsx	dx,[TIA+HMBL]
	mov	[BL_Motion],dx

	mov	[HMOVE_Pending],1	; also in case we doHMOVE elsewhere

	cmp	[RClock],20
	ja	HiBlank
	cmp	[RClock],3
	jbe	LoBlank

DoBlank:
	FixupMotionLow P0
	FixupMotionLow P1
	FixupMotionLow M0
	FixupMotionLow M1
	FixupMotionLow BL
LoBlank:
	mov	[HBlanking],0		; set up the HMOVE blank
	call	doHMOVE
	ret

HiBlank:
	cmp	[RClock],54
	jbe	NoMotion
	cmp	[RClock],74
	jbe	NoBlank
	mov	[SetHBlanking],1

	call	doHMOVE
	ret	

.data

HiTable db 14, 13, 12, 12, 11, 10, 9, 9, 8, 7, 6, 6, 5, 4, 3, 3, 2, 1, 0, 0

.code

FixupMotionHi macro arg1
local SetMotion

	movsx	dx,[TIA+HM&arg1]
	add	dx,8
	push	bx
	movzx	bx,[RClock]
	sub	bx,55
	movsx	bx,[HiTable+bx]
	sub	dx,bx
	cmp	dx,0
	jg	SetMotion
	mov	dx,0

SetMotion:
	mov	[arg1&_Motion],dx
	pop	bx
	endm



NoBlank:
	FixupMotionHi P0
	FixupMotionHi P1
	FixupMotionHi M0
	FixupMotionHi M1
	FixupMotionHi BL

	call	doHMOVE
	ret

NoMotion:
	ret


;*
;* RESBL
;*


H_RESBL:
	GetObjectDelay BL

;*
;* mind master cheat
;*

	cmp	[Starpath],0		; if you don't do this, the cheat breaks keystone.bin
	jz	RBL_goahead
	cmp	bl,69			; other than that, you don't want to know...
	je	RBL_handle69
	cmp	bl,226
	jne	RBL_goahead

RBL_handle69:
	cmp	[HMOVE_Cycle],5
	je	RBL_isweird
	cmp	[HMOVE_Cycle],0
	jne	RBL_goahead
	cmp	[Last_HMOVE_Cycle],78
	jne	RBL_goahead

RBL_isweird:
	mov	bl,74			; if we're cheating, the ball lands here

;*
;* end of cheat
;*

RBL_goahead:
	push	bx			; save object position
	call	CatchUpPixels
	pop	bx			; restore object position

	mov	[TIA+RESBL],bl
	mov	[BL_Position],bx

	ret


;*
;* a positioning cheat for Kool Aide
;*

CheatKoolAidePosition macro arg1, arg2, arg3
local done

	cmp	[_KoolAide],0		; doing Kool Aide cheat?
	jz	done			;   no
	cmp	[ScanLine],arg1
	jne	done
	cmp	bx,arg2+68-5
	jne	done

	mov	bx,arg3+68-5		  ;   yes, do the cheat

done:
	endm


;*
;* RESP0
;*

H_RESP0:
	GetObjectDelay P0
	push	bx			; save object position
	mov	[P0_TripleFlag],al
	call	CatchUpPixels
	call	UpdateP0Table
	pop	bx			; restore object position

	CheatKoolAidePosition 40 54 52
	CheatKoolAidePosition 49 63 61

	mov	[TIA+RESP0],bl
	mov	[P0_Position],bx

	call	UpdateM0Locking

	ret


;*
;* RESP1
;*

H_RESP1:
	GetObjectDelay P1
	push	bx			; save object position
	mov	[P1_TripleFlag],al
	call	CatchUpPixels
	call	UpdateP1Table
	pop	bx			; restore object position

	CheatKoolAidePosition 40 63 65
	CheatKoolAidePosition 49 72 74

	mov	[TIA+RESP1],bl
	mov	[P1_Position],bx

	call	UpdateM1Locking

	ret

;*
;* RESM0
;*

H_RESM0:
	test	[TIA+RESMP0],2		; missile locked to player ?
	jnz	noRESM0			;   yes, don't position

	GetObjectDelay M0
	push	bx			; save object position
	mov	[M0_TripleFlag],al
	call	CatchUpPixels
	call	UpdateM0Table
	pop	bx			; restore object position

	mov	[TIA+RESM0],bl
	mov	[M0_Position],bx

noRESM0:
	ret


;*
;* RESM1
;*

H_RESM1:
	test	[TIA+RESMP1],2		; missile locked to player ?
	jnz	noRESM1			;   yes, don't position

	GetObjectDelay M1
	push	bx			; save object position
	mov	[M1_TripleFlag],al
	call	CatchUpPixels
	call	UpdateM1Table
	pop	bx			; restore object position

	mov	[TIA+RESM1],bl
	mov	[M1_Position],bx

noRESM1:
	ret


;*
;* ENABL
;*

H_ENABL:
	mov	dl,1
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+ENABL],dl

	call	UpdateBallGraphics
	ret


;*
;* ENAM0
;*

H_ENAM0:
	mov	dl,1
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+ENAM0],dl

	call	UpdateM0Graphics
	ret


;*
;* ENAM1
;*

H_ENAM1:
	mov	dl,1
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+ENAM1],dl

	call	UpdateM1Graphics
	ret

;*
;* macro to handle writes to NUSIZ register
;*

DoNUSIZ macro arg1
local NoCatchup, CatchupWide, NoCheat, done

	GetObjectDelay M&arg1
	call	CatchUpPixels		; render any missile in progress
	
	mov	dl,[TIA+NUSIZ&arg1]
	and	dl,7
	cmp	dl,7			; quad wide player?
	je	CatchupWide		;   yes
	cmp	dl,5			; double wide player?
	je	CatchupWide		;   yes

	GetObjectDelay P&arg1		  ;   no
	call	CatchUpPixels		; complete the player in progress
	jmp	NoCatchup

CatchupWide:
	GetObjectDelay P&arg1
	test	dl,dl			; are we in the wide sprite?
	jz	NoCatchup		;   no
	mov	dl,4			; (4 for sentinel)
	call	CatchUpPixels		; render a few trailing pixels

NoCatchup:
	mov	dl,[WByte]
	mov	[TIA+NUSIZ&arg1],dl	  ; switch to new NUSIZ

	call	UpdateM&arg1&Graphics	  ; update things
	call	UpdateP&arg1&Table
	call	UpdateM&arg1&Table

	mov	dl,[P&arg1&_Graphics]
	push	dx			; save current player graphics
	mov	[P&arg1&_Graphics],0	  ; set to zero to render nothing
	GetObjectDelay P&arg1
	test	dl,dl			; would table switch land us in a sprite?
	jz	done			;   no

	cmp	[_RSBoxing],0		; doing RSBOXING cheat?
	jz	NoCheat			;	  no
	sub	dl,2			;	yes, don't render completely thru new sprite

NoCheat:
	call	CatchUpPixels		;	 yes, render nothing thru new sprite
					;	      (** messes up rsboxing a little bit -- too far into future **)
					;	      (** if I ever fix this right, it might fix PROWREST too **)

done:
	pop	dx
	mov	[P&arg1&_Graphics],dl	  ; restore player graphics
	ENDM


;*
;* NUSIZ0
;*

H_NUSIZ0:
	DoNUSIZ 0
	ret


;*
;* NUSIZ1
;*

H_NUSIZ1:
	DoNUSIZ 1
	ret


;*
;* VDELBL
;*

H_VDELBL:
	mov	dl,0
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+VDELBL],dl

	call	UpdateBallGraphics
	ret


;*
;* VDELP0
;*

H_VDELP0:
	mov	dl,0
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+VDELP0],dl

	call	UpdateP0Graphics
	ret


;*
;* VDELP1
;*

H_VDELP1:
	mov	dl,0
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+VDELP1],dl

	call	UpdateP1Graphics
	ret

;*
;* GRP0
;*

H_GRP0:
	mov	dl,1
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+GRP0],dl

	mov	dl,[TIA+GRP1]
	mov	[P1_Delayed],dl
	call	UpdateP0Graphics
	call	UpdateP1Graphics

	ret


;*
;* GRP1
;*

H_GRP1:
	mov	dl,1
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+GRP1],dl

	mov	dl,[TIA+ENABL]
	mov	[BL_Delayed],dl
	mov	dl,[TIA+GRP0]
	mov	[P0_Delayed],dl
	call	UpdateBallGraphics
	call	UpdateP0Graphics
	call	UpdateP1Graphics

	ret

;*
;* handle a non-M0 motion register
;*

HandleMotion macro arg1
local NormalMotion

	push	bx

	cmp	[HMOVE_Cycle],3
	jne	NormalMotion

	cmp	[RClock],26
	jae	NormalMotion
	movzx	bx,[TIA+HM&arg1]
	and	bx,0fh
	shl	bx,4
	movzx	dx,[WByte]
	shr	dx,4
	and	dx,0fh
	add	bx,dx
	shl	bx,5
	movzx	dx,[RClock]
	and	dx,01fh
	add	bx,dx
	mov	dl,[DeepHMOVE + bx]
	test	dl,dl
	jz	NormalMotion
	cmp	dl,99
	je	NormalMotion		; cosmic is normal for now
	movsx	dx,dl
	neg	dx
	mov	[arg1&_Motion],dx
	DoMotion arg1
	cmp	[_TraceCount],0
	jz	NormalMotion

	pushad
	call	_ShowAdjusted
	popad

NormalMotion:
	mov	dl,[WByte]
	sar	dl,4			; pre-shift right 4 bits (preserve sign)
	mov	[TIA+HM&arg1],dl
	pop	bx

	endm


H_HMP0:
	CheckDeep
	HandleMotion P0
	ret

H_HMP1:
	CheckDeep
	HandleMotion P1
	ret

H_HMM1:
	CheckDeep
	HandleMotion M1
	ret

H_HMBL:
	CheckDeep
	HandleMotion BL
	ret

;*
;* HMM0
;*

H_HMM0:
	CheckDeep
	cmp	[HMOVE_Cycle],3
	jne	NotConfused
	cmp	[RClock],24
	jne	NotConfused
	cmp	[M0_Motion],7
	jne	NotConfused
	cmp	[WByte],060h
	jne	NotConfused
	mov	[M0_Confused],1
	mov	[CosmicScanLine],1
	mov	[M0_Motion],2
	DoMotion M0

NotConfused:
	HandleMotion M0
	ret

;*
;* HMCLR
;*

H_HMCLR:
	mov	dl,[WByte]
	push	dx
	mov	[WByte],0

	CheckDeep

	cmp	[HMOVE_Cycle],3
	jne	HMC_NotConfused
	cmp	[RClock],23
	jne	HMC_NotConfused
	cmp	[M0_Motion],7
	jne	HMC_NotConfused
	mov	[M0_Confused],1
	mov	[CosmicScanLine],1

HMC_NotConfused:
	HandleMotion M0
	HandleMotion M1
	HandleMotion P0
	HandleMotion P1
	HandleMotion BL

	pop	dx
	mov	[WByte],dl
	jmp	HMCLR_Done

HMCLR_NotWeird:
	mov	[TIA+HMP0],0
	mov	[TIA+HMP1],0
	mov	[TIA+HMM0],0
	mov	[TIA+HMM1],0
	mov	[TIA+HMBL],0

HMCLR_Done:
	ret


;*
;* CXCLR
;*

H_CXCLR:
	mov	dl,0
	call	CatchUpPixels

	mov	[TIACollide],0
	ret



;*
;* REFP0
;*

H_REFP0:
	mov	dl,1
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+REFP0],dl
	call	UpdateP0Graphics
	ret



;*
;* REFP1
;*

H_REFP1:
	mov	dl,1
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+REFP1],dl
	call	UpdateP1Graphics
	ret

;*
;* RESMP0
;*

H_RESMP0:

	mov	dl,0
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+RESMP0],dl

	call	UpdateM0Locking
	call	UpdateM0Graphics

	ret

;*
;* RESMP1
;*

H_RESMP1:

	mov	dl,0
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+RESMP1],dl

	call	UpdateM1Locking
	call	UpdateM1Graphics

	ret
