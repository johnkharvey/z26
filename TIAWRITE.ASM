; new TIA write handlers

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 3-12-1999 -- break ground
; 09-07-02 -- 32-bit

.data

TIARegHandler label dword

	dd	H_VSYNC		; 00 -- VSYNC
	dd	H_VBLANK		; 01 -- VBLANK
	dd	H_WSYNC		; 02 -- WSYNC
	dd	H_Null		; 03 -- reset horizontal sync
					;	  for factory testing only !

	dd	H_NUSIZ0		; 04 -- NUSIZ0
	dd	H_NUSIZ1		; 05 -- NUSIZ1
	dd	H_COLUP0		; 06 -- COLUP0
	dd	H_COLUP1		; 07 -- COLUP1
	dd	H_COLUPF		; 08 -- COLUPF
	dd	H_COLUBK		; 09 -- COLUBK
	dd	H_CTRLPF		; 0a -- CTRLPF
	dd	H_REFP0		; 0b -- REFP0
	dd	H_REFP1		; 0c -- REFP1
	dd	H_PF			; 0d -- PF0
	dd	H_PF			; 0e -- PF1
	dd	H_PF			; 0f -- PF2
	dd	H_RESP0		; 10 -- RESP0
	dd	H_RESP1		; 11 -- RESP1
	dd	H_RESM0		; 12 -- RESM0
	dd	H_RESM1		; 13 -- RESM1
	dd	H_RESBL		; 14 -- RESBL
	dd	H_AUDC0		; 15 -- AUDC0
	dd	H_AUDC1		; 16 -- AUDC1
	dd	H_AUDF0		; 17 -- AUDF0
	dd	H_AUDF1		; 18 -- AUDF1
	dd	H_AUDV0		; 19 -- AUDV0
	dd	H_AUDV1		; 1a -- AUDV1
	dd	H_GRP0		; 1b -- GRP0
	dd	H_GRP1		; 1c -- GRP1
	dd	H_ENAM0		; 1d -- ENAM0
	dd	H_ENAM1		; 1e -- ENAM1
	dd	H_ENABL		; 1f -- ENABL
	dd	H_HMP0		; 20 -- HMP0
	dd	H_HMP1		; 21 -- HMP1
	dd	H_HMM0		; 22 -- HMM0
	dd	H_HMM1		; 23 -- HMM1
	dd	H_HMBL		; 24 -- HMBL
	dd	H_VDELP0		; 25 -- VDELP0
	dd	H_VDELP1		; 26 -- VDELP1
	dd	H_VDELBL		; 27 -- VDELBL
	dd	H_RESMP0		; 28 -- RESMP0
 	dd	H_RESMP1		; 29 -- RESMP1
	dd	H_HMOVE		; 2a -- HMOVE
	dd	H_HMCLR		; 2b -- HMCLR
	dd	H_CXCLR		; 2c -- CXCLR

	dd	H_Null		; 2d -- these registers are undefined
	dd	H_Null		; 2e
	dd	H_Null		; 2f
	dd	H_Null		; 30
	dd	H_Null		; 31
	dd	H_Null		; 32
	dd	H_Null		; 33
	dd	H_Null		; 34
	dd	H_Null		; 35
	dd	H_Null		; 36
	dd	H_Null		; 37
	dd	H_Null		; 38
	dd	H_Null		; 39
	dd	H_Null		; 3a
	dd	H_Null		; 3b
	dd	H_Null		; 3c
	dd	H_Null		; 3d
	dd	H_Null		; 3e
	dd	H_Null		; 3f

	dd	H_Null

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


WeirdRespCorrection label dword
 dd   0,  0,  0,  0,  0,  0,  1,  2,  2,  3
 dd   4,  5,  5,  6,  7,  8,  8,  9, 10, 11
 dd  11, 12, 13, 14, 14, 15

TempCFirst	dd	0


.code


;*
;* blank the remainder of the display each frame
;*

TIABlank:
	pushad
	xor	eax,eax
	mov	edi,[DisplayPointer]
	cmp	edi,15000
	jb	TIABRet
	mov	ebx,[_MaxLines]
	imul	ebx,160
TIABLoop:
	cmp	edi,ebx			; reached end of display area?
	jae	TIABRet			;   yes, done
	gs_store [edi],eax
	add	edi,4
	jmp	TIABLoop

TIABRet:
	mov	[DisplayPointer],edi
	popad
	ret

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
	movzx	edx,[RClock]
	push	edx
	movzx	edx,[TIA+esi]
	and	edx,0fh
	push	edx
	mov	dl,[WByte]
	sar	dl,4
	movzx	edx,dl
	and	edx,0fh
	push	edx
	call	_ShowDeep
	pop	edx
	pop	edx
	pop	edx
	popad

	jmp	NotDeep

VeryDeep:
	pushad
	movzx	edx,[RClock]
	push	edx
	movzx	edx,[TIA+esi]
	and	edx,0fh
	push	edx
	mov	dl,[WByte]
	sar	dl,4
	movzx	edx,dl
	and	edx,0fh
	push	edx
	call	_ShowVeryDeep
	pop	edx
	pop	edx
	pop	edx
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
	movzx	edx,[RClock]
	push	edx
	call	_ShowWeird
	pop	edx
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
	call	VecTIA		; call the write handler
	RestoreCPUState
	ret

VecTIA:
	jmp	[TIARegHandler + esi*4]


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

	mov	edx,[_LinesInFrame]
	mov	[_PrevLinesInFrame],edx
	mov	edx,[ScanLine]
	mov	[_LinesInFrame],edx	; *EST*
	dec	[_LinesInFrame]

DontUpdateLinesInFrame:
	mov	[LooseColour],0ffffffffh
;	cmp	[_PaletteNumber],1	; PAL palette?
;	jne	GrayFrame		;   no, don't simulate color loss
	test	[_SimColourLoss],1
	jz	GrayFrame
	test	[_LinesInFrame],1
	jz	GrayFrame
	mov	[LooseColour],007070707h ; see tialine.asm
GrayFrame:
	mov	[ScanLine],1		; back to screen top

	cmp	edx,5			; a quick double hit (pickpile)?
	jb	VSyncAlreadySet		;	 yes, no new frame
	inc	[Frame]			; new frame.

;*
;* automatic adjustment of game position (and video mode)
;*

	mov	edx,[_CFirst]
	mov	[TempCFirst],edx	; to see how much we're changing by

	cmp	[Frame],5
	je	AdjustUnstable		; force adjustment of unstable games (pickpile)

	mov	edx,[_LinesInFrame]
	cmp	edx,[_PrevLinesInFrame]
	jne	AlreadyInPALMode	; don't change video mode if not matching previous frame (quadrun)

	test	[_IOPortB],1		; reset being pressed?
	jz	VSyncAlreadySet		;	 yes, don't adjust

AdjustUnstable:
	cmp	[_LinesInFrame],282	; NTSC game? (pharhcrs 296 when fire button pressed ...
					;		    (... air_raid 292, zoofun 291, dumbo 286, curtiss 286,
					;		    (... tps 285, galaga 282, tomboy 277)
	jb	AlreadyInPALMode	;	 yes

	cmp	[_PaletteNumber],1	; PAL mode already ?
	jz	AlreadyInPALMode	;	 yes
	cmp	[_UserPaletteNumber],0ffh ; is there a palette override?
	jnz	AlreadyInPALMode	;	  yes, don't switch

	test	[Frame],0ffffff00h	; more than 256 frames passed?
	jnz	AlreadyInPALMode	;    yes, don't change TV type *EST*

	mov	[_PaletteNumber],1	; set up PAL palette
	pushad
        call    _position_game          ; adjust starting line for PAL/NTSC
        call	_srv_SetPalette		; reset video mode for PAL games
	popad

AlreadyInPALMode:
	cmp	[_LinesInFrame],512	; game ridiculously large?
	ja	VSyncAlreadySet		;	 yes, no automatic adjustment
	cmp	[_LinesInFrame],220	; game ridiculously small?
	ja	GameSizeOK		;   no
	cmp	[_BailoutLine],512	; maybe BailoutLine is too small -- too big already?
	ja	GameSizeOK
	mov	edx,[_LinesInFrame]
	add	edx,4			; match offset to below (aciddrop)
	add	[_BailoutLine],edx
	jmp	BailoutSet

GameSizeOK:
	mov	edx,[_LinesInFrame]
	cmp	edx,[_PrevLinesInFrame]
	jne	BailoutSet		; don't reset BailoutLine if not matching previous frame (quadrun)
	add	edx,4			; minimum 6 is needed for aciddrop or it flashes
	mov	[_BailoutLine],edx

BailoutSet:

VSyncAlreadySet:
	mov	edx,[_CFirst]
	cmp	edx,0			; forcing first line ?
	jz	ZRET			;   no, let vblank take care of it

	call	TIABlank

DontBlank:
	mov	[TopLine],edx
	add	edx,[_MaxLines]
	mov	[BottomLine],edx
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

	mov	edx,[ScanLine]
	cmp	edx,200
	jb	VBOnAlreadySet
	mov	[_VBlankOn],edx

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
	mov	edx,[ScanLine]
	cmp	[_PaletteNumber],1	; NTSC game?
	jnz	DoNTSCTest		;   yes
	cmp	edx,78			; allow penguin vblank
	ja	VBOffAlreadySet
	mov	[_VBlankOff],edx
	jmp	VBOffAlreadySet

DoNTSCTest:
	cmp	edx,58			; allow brickick vblank
	ja	VBOffAlreadySet
	mov	[_VBlankOff],edx

VBOffAlreadySet:
	cmp	[_CFirst],0		; VBlank triggering new frame ?
	je	WTB_2			;	yes, don't mess with VBlanking
	mov	[VBlanking],-1
	jmp	HandleDumpedInputs

WTB_2:
	mov	edx,[ScanLine]
	cmp	edx,[_CFirst]
	jae	WVBPastMin
	mov	edx,[_CFirst]
WVBPastMin:
	inc	edx
	mov	[TopLine],edx
	add	edx,[_MaxLines]
	mov	[BottomLine],edx
	jmp	HandleDumpedInputs	 


HandleDumpedInputs:
	test	[VBlank],080h		; discharging capacitors ?
	jz	HandleLatchedInputs	;   no
	mov	dword ptr [ChargeCounter],0 ;   yes, zero the line counter

	mov	[DumpPorts],0h		; reset booster grip buttons
	mov	[DumpPorts+1],0h	;
	mov	[DumpPorts+2],0h	;
	mov	[DumpPorts+3],0h	;

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
	mov	ebx,[WeirdRespCorrection+4*ebx]
	sub	ebx,[arg1&_Motion]
	add	ebx,226
	cmp	ebx,234
	jbe	HBLinrange
	mov	ebx,234
HBLinrange:	
	cmp	ebx,228
	jb	HBLdone
	sub	ebx,160

HBLdone:
	endm

;*
;* object rendering macros
;*
;* they should OR their respective bits into BL
;* AX, DL and SI are free registers that these routines can use
;*


;*
;* table update support macro
;*

UpdateTable macro arg1
local regular_ok

	movzx	esi,[TIA+NUSIZ&arg1]
	and	esi,7
	movzx	edx,[arg1&_SizeTable+esi]
	mov	[arg1&_Size],edx
	mov	edx,[arg1&_RegularTable+esi*4] ; assume regular table
	cmp	[arg1&_TripleFlag],0
	jnz	regular_ok
	mov	edx,[arg1&_MultipleTable+esi*4] ; use multiple table

regular_ok:
	mov	[arg1&_Table],edx
	endm


SetObjectBit macro arg1
local done, nowrap

	movzx	esi,cl
	sub	esi,[arg1&_Position]
	jae	nowrap
	add	esi,160
nowrap:	
	cmp	esi,[arg1&_Size]
	ja	done
	add	esi,esi			; index into table
	AddTablePointer arg1
	mov	al,[arg1&_Graphics]
	test	al,[esi]
	jz	done
	or	bl,arg1&_BIT
done:
	endm

;*
;* get dl = object delay
;*     al = triple flag
;*     bx = object position
;*

GetObjectDelay macro arg1
local done, nowrap

	PositionObject arg1
	mov	esi,ebx

	xor	dl,dl			; assume delay 0
	xor	al,al			; assume no triple flag

	sub	esi,[arg1&_Position]	; where the object is
	jae	nowrap
	add	esi,160			
nowrap:	
	cmp	esi,[arg1&_Size]	; beyond it's size?
	ja	done			;   yes, no delay
	add	esi,esi			; index into table
	inc	esi			; point at delay byte
	AddTablePointer arg1
	mov	dl,[esi]		; get delay byte
	test	dl,080h			; triple flag set?
	setnz	al			;   set al if so
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
	shl	edx,8
	mov	dl,dh
	shl	edx,8
	mov	dl,dh			; 32-bit playfield color
	mov	[BL_Color],edx		; ball is always this color
	mov	[PF_Color],edx		; assume *normal* state of affairs

	mov	edx,offset TIADisplayToColour
	test	[TIA+CTRLPF],PFP	; does playfield have priority?
	jz	UPFC_CheckScore		;	 no
	mov	edx,offset TIADisplayToColour2
	mov	[PixelColorTable],edx	;   yes, update pixel to color translation table
	jmp	UPFC_done		; don't pay attention to score mode...

UPFC_CheckScore:
	mov	[PixelColorTable],edx	; update pixel to color translation table
	test	[TIA+CTRLPF],SCORE	; in score mode?
	jz	UPFC_done		;   no
	mov	edx,[P0_Color]		; assume Player 0 color
	cmp	cl,147			; right side of playfield?
	jbe	UPFC_SetReg		;   no
	mov	edx,[P1_Color]		;	yes, use Player 1 color
UPFC_SetReg:
	mov	[PF_Color],edx		; update the register

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
	movzx	esi,dl
	shr	esi,4
	mov	dl,[BallSize + esi]	; look up in table
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

	mov	dl,[TIA+GR&arg1]		; assume regular graphics
	test	[TIA+VDEL&arg1],1	  ; using delayed register?
	jz	UPnodelay		;   no
	mov	dl,[arg1&_Delayed]	  ;   yes, use delayed graphics
UPnodelay:
	DeactivateObject arg1&_BIT	  ; assume not active
	test	dl,dl			; graphics active?
	jz	UPdone			;	 no, done
	ActivateObject arg1&_BIT	  ;	yes, ActivateObject
	test	[TIA+REF&arg1],08h	  ; reflected?
	jz	UPdone			;	 no
	movzx	esi,dl			;   yes
	mov	dl,[TIAReflect8+esi]	; reflect it
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
	test	[TIA+ENA&arg1],2		 ; missile enabled?
	jz	noMissile		;   no
	ActivateObject arg1&_BIT	  ;	yes, ActivateObject
	movzx	esi,[TIA+NUSIZ&arg1]	  ; size is here
	and	esi,030h			; mask size bits
	shr	esi,4
	mov	dl,[BallSize + esi]	; look up in table
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

	push	esi
	movzx	esi,[TIA+NUSIZ&arg1]
	and	esi,7
	movzx	edx,[MissileOffset+esi]
	pop	esi

	add	edx,[arg2&_Position]
	cmp	edx,227
	jbe	nowrap
	sub	edx,160
nowrap:
	mov	[TIA+RES&arg1],dl
	mov	[arg1&_Position],edx

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
;* color setting support macro
;*

SetColor macro arg1
	mov	dl,0
	call	CatchUpPixels

	mov	dl,[WByte]
	shr	dl,1			; pre shift right 1 bit
	mov	[TIA+COLU&arg1],dl	  ; update the register
	mov	dh,dl
	shl	edx,8
	mov	dl,dh
	shl	edx,8
	mov	dl,dh

	endm

;*
;* a TIA color register write
;*

H_COLUP0:
	SetColor P0
	mov	[P0_Color],edx

	ret

H_COLUP1:
	SetColor P1
	mov	[P1_Color],edx

	ret

H_COLUBK:
	SetColor BK
	mov	[BK_Color],edx	

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

	and	ebx,3
	mov	dl,[PFDelay+ebx]		; render this far into the future

	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+esi],dl		; update the register

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

	mov	edx,[arg1&_Motion]
	sub	[arg1&_Position],edx
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

	movsx	edx,[TIA+HM&arg1]
	push	ebx
	movzx	ebx,[RClock]
	movsx	ebx,[MaxMotion+ebx]
	cmp	edx,ebx
	jl	MotionOK
	mov	edx,ebx
	mov	[arg1&_Motion],edx
MotionOK:
	pop	ebx
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
	movsx	edx,[TIA+HMP0]		; xx_Motion is different from HMxx
	mov	[P0_Motion],edx		; in case we decide to doHMOVE 
	movsx	edx,[TIA+HMP1]		; somewhere else
	mov	[P1_Motion],edx
	movsx	edx,[TIA+HMM0]
	mov	[M0_Motion],edx
	movsx	edx,[TIA+HMM1]
	mov	[M1_Motion],edx
	movsx	edx,[TIA+HMBL]
	mov	[BL_Motion],edx

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

	movsx	edx,[TIA+HM&arg1]
	add	edx,8
	push	ebx
	movzx	ebx,[RClock]
	sub	ebx,55
	movsx	ebx,[HiTable+ebx]
	sub	edx,ebx
	cmp	edx,0
	jg	SetMotion
	mov	edx,0

SetMotion:
	mov	[arg1&_Motion],edx
	pop	ebx
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
	push	ebx			; save object position
	call	CatchUpPixels
	pop	ebx			; restore object position

	mov	[TIA+RESBL],bl
	mov	[BL_Position],ebx

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
	cmp	ebx,arg2+68-5
	jne	done

	mov	ebx,arg3+68-5		  ;	  yes, do the cheat

done:
	endm


;*
;* RESP0
;*

H_RESP0:
	GetObjectDelay P0
	push	ebx			; save object position
	mov	[P0_TripleFlag],al
	call	CatchUpPixels
	call	UpdateP0Table
	pop	ebx			; restore object position

	CheatKoolAidePosition 40 54 52
	CheatKoolAidePosition 49 63 61

	mov	[TIA+RESP0],bl
	mov	[P0_Position],ebx

	call	UpdateM0Locking

	ret


;*
;* RESP1
;*

H_RESP1:
	GetObjectDelay P1
	push	ebx			; save object position
	mov	[P1_TripleFlag],al
	call	CatchUpPixels
	call	UpdateP1Table
	pop	ebx			; restore object position

	CheatKoolAidePosition 40 63 65
	CheatKoolAidePosition 49 72 74

	mov	[TIA+RESP1],bl
	mov	[P1_Position],ebx

	call	UpdateM1Locking

	ret

;*
;* RESM0
;*

H_RESM0:
	test	[TIA+RESMP0],2		; missile locked to player ?
	jnz	noRESM0			;   yes, don't position

	GetObjectDelay M0
	push	ebx			; save object position
	mov	[M0_TripleFlag],al
	call	CatchUpPixels
	call	UpdateM0Table
	pop	ebx			; restore object position

	mov	[TIA+RESM0],bl
	mov	[M0_Position],ebx

noRESM0:
	ret


;*
;* RESM1
;*

H_RESM1:
	test	[TIA+RESMP1],2		; missile locked to player ?
	jnz	noRESM1			;   yes, don't position

	GetObjectDelay M1
	push	ebx			; save object position
	mov	[M1_TripleFlag],al
	call	CatchUpPixels
	call	UpdateM1Table
	pop	ebx			; restore object position

	mov	[TIA+RESM1],bl
	mov	[M1_Position],ebx

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
	push	edx			; save current player graphics
	mov	[P&arg1&_Graphics],0	  ; set to zero to render nothing
	GetObjectDelay P&arg1
	test	dl,dl			; would table switch land us in a sprite?
	jz	done			;   no

	cmp	[_RSBoxing],0		; doing RSBOXING cheat?
	jz	NoCheat			;	  no
	sub	dl,2			;	yes, don't render completely thru new sprite

NoCheat:
	call	CatchUpPixels		;	 yes, render nothing thru new sprite
					;		     (** messes up rsboxing a little bit -- too far into future **)
					;		     (** if I ever fix this right, it might fix PROWREST too **)

done:
	pop	edx
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

	push	ebx

	cmp	[HMOVE_Cycle],3
	jne	NormalMotion

	cmp	[RClock],26
	jae	NormalMotion
	movzx	ebx,[TIA+HM&arg1]
	and	ebx,0fh
	shl	ebx,4
	movzx	edx,[WByte]
	shr	edx,4
	and	edx,0fh
	add	ebx,edx
	shl	ebx,5
	movzx	edx,[RClock]
	and	edx,01fh
	add	ebx,edx
	mov	dl,[DeepHMOVE + ebx]
	test	dl,dl
	jz	NormalMotion
	cmp	dl,99
	je	NormalMotion		; cosmic is normal for now
	movsx	edx,dl
	neg	edx
	mov	[arg1&_Motion],edx
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
	pop	ebx

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
	push	edx
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

	pop	edx
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
