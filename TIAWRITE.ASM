; new TIA write handlers

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
	dw	H_Motion	; 20 -- HMP0
	dw	H_Motion	; 21 -- HMP1
	dw	H_Motion	; 22 -- HMM0
	dw	H_Motion	; 23 -- HMM1
	dw	H_Motion	; 24 -- HMBL
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


.code

;*
;* This is the new TIA write handler.
;* Gets called when CPU detects a TIA write that isn't 
;* an immediate command.
;*
;* on entry:
;*
;*	si =	  TIA register to write to
;*      [WByte] = value to write
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
	mov	dl,CYCLESPERSCANLINE		;   no
	sub	dl,[RClock]
	add	[RCycles],dl			; adjust instruction length
	mov	[RClock],CYCLESPERSCANLINE	; and CPU clock
	ret

SetSkip:
	mov	dl,2*CYCLESPERSCANLINE		; skipping a line, bigger adjustment
	sub	dl,[RClock]
	add	[RCycles],dl			; adjust instruction length
	mov	[RClock],2*CYCLESPERSCANLINE	; and CPU clock
	ret

;*
;* VSYNC -- vertical sync set-clear
;*

H_VSYNC:
	test	[WByte],2		; if d1 is set then ....
	jz	ZRET
	test	[VSyncFlag],2		; somebody hitting Vsync more than necessary?
	jnz	VSyncAlreadySet		;   yep
	mov	[ScanLine],1		; back to screen top
	inc	[Frame]			; new frame.
VSyncAlreadySet:
	mov	dx,[_CFirst]
	cmp	dx,0			; forcing first line ?
	jz	ZRET			;   no, let vblank take care of it
	mov	[TopLine],dx
	add	dx,[MaxLines]
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
	jz	WVBClear		;   clearing
	cmp	[_CFirst],0		; VBlank triggering new frame ?
	je	WTB_1			;   yes, don't mess with VBlanking
	mov	[VBlanking],0
	jmp	HandleDumpedInputs

WTB_1:
	mov	[TopLine],65535		;   setting -- turn off Tia
	call	TIABlank		; clear rest of screen
	jmp	HandleDumpedInputs

WVBClear:
	cmp	[_CFirst],0		; VBlank triggering new frame ?
	je	WTB_2			;   yes, don't mess with VBlanking
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
	add	dx,[MaxLines]
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
;* get object delay into dl
;*

GetObjectDelay macro %1
local done, nowrap

	mov	dl,0			; assume delay 0
	mov	al,0			; assume no triple flag
	movzx	esi,[RClock]		; CPU clock
	lea	esi,[esi+esi*2]		; *3
	sub	si,[%1&_Position]	; where the object is
	jae	nowrap
	add	si,160			
nowrap:	
	cmp	si,[%1&_Size]		; beyond it's size?
	ja	done			;   yes, no delay
	add	si,si
	inc	si			; point at delay byte
	add	si,[%1&_Table]		; object's table
	mov	dl,[si]			; get delay byte
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

ActivateObject macro %1
	or	[ActiveObjects],%1
	endm

DeactivateObject macro %1
	and	[ActiveObjects], not %1
	endm


;*
;* update playfield color
;*
;* call before every pixel run (lots of things can affect PF color)
;*

doUpdatePlayfieldColor:
	mov	dl,[TIA+COLUPF]
	mov	dh,dl			; 16-bit playfield color
	test	[TIA+CTRLPF],SCORE	; in score mode?
	jz	UPFC_SetReg		;   no
	mov	dx,[P0_Color]		; assume Player 0 color
	cmp	cl,147			; right side of playfield?
	jbe	UPFC_SetReg		;   no
	mov	dx,[P1_Color]		;   yes, use Player 1 color

UPFC_SetReg:
	mov	[PF_Color],dx		; update the register

	mov	dx,offset TIADisplayToColour
	test	[TIA+CTRLPF],PFP	; does playfield have priority?
	jz	UPFCdone		;   no
	mov	dx,offset TIADisplayToColour2
UPFCdone:
	mov	[PixelColorTable],dx	; update pixel to color translation table
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
	jz	UPFR_Ret		;   no
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
	mov	dl,[BL_Delayed]		;   yes, use delayed ball

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
;* player graphics support macroo
;*

UpdatePlayerGraphics macro %1
local UPnodelay, UPdone

	mov	dl,[TIA+GR&%1]		; assume regular graphics
	test	[TIA+VDEL&%1],1		; using delayed register?
	jz	UPnodelay		;   no
	mov	dl,[%1&_Delayed]	;   yes, use delayed graphics
UPnodelay:
	DeactivateObject %1&_BIT	; assume not active
	test	dl,dl			; graphics active?
	jz	UPdone			;   no, done
	ActivateObject %1&_BIT		;   yes, ActivateObject
	test	[TIA+REF&%1],08h	; reflected?
	jz	UPdone			;   no
	movzx	si,dl			;   yes
	mov	dl,[TIAReflect8+si]	; reflect it
UPdone:
	mov	[%1&_Graphics],dl	; update register
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

UpdateMissileGraphics macro %1
local noMissile

	DeactivateObject %1&_BIT	; assume inactive
	mov	[%1&_Graphics],0	; clear register
	test	[TIA+RES&%1&P],2	; missile locked to player?
	jnz	noMissile		;   yes, no missile
	test	[TIA+ENA&%1],2		; missile enabled?
	jz	noMissile		;   no
	ActivateObject %1&_BIT		;   yes, ActivateObject
	movzx	si,[TIA+NUSIZ&%1]	; size is here
	and	si,030h			; mask size bits
	shr	si,4
	mov	dl,[BallSize + si]	; look up in table
	mov	[%1&_Graphics],dl	; update register
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

UpdateTable macro %1
	movzx	si,[TIA+NUSIZ&%1]
	and	si,7
	movzx	dx,[%1&_SizeTable+si]
	mov	[%1&_Size],dx
	shl	si,1
	mov	dx,[%1&_RegularTable+si]
	mov	[%1&_Table],dx

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
;* missile locking support macro
;*

LockMissile macro %1, %2
local nowrap

	mov	dx,[%2&_Position]
	add	dx,5
	cmp	dx,227
	jbe	nowrap
	sub	dx,160
nowrap:
	mov	[TIA+RES&%1],dl
	mov	[%1&_Position],dx

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

SetColor macro %1
	mov	dl,0
	call	CatchUpPixels

	mov	dl,[WByte]
	shr	dl,1			; pre shift right 1 bit
	mov	[TIA+COLU&%1],dl	; update the register
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

DoMotion macro %1
local positive, done

	mov	dx,[%1&_Motion]
	sub	[%1&_Position],dx
	cmp	[%1&_Position],68
	jae	positive
	add	[%1&_Position],160
	jmp	done

positive:
	cmp	[%1&_Position],228
	jb	done
	sub	[%1&_Position],160

done:
	endm

;*
;* HMOVE
;*

;*
;* this is called at beginning of a scanline
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
;* this is called at register write time
;*	

H_HMOVE:
	mov	dl,0
	call	CatchUpPixels

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

DoBlank:
	mov	[HBlanking],0		; set up the HMOVE blank
	call	doHMOVE
	ret

HiBlank:
	cmp	[RClock],74
	jbe	NoBlank
	mov	[SetHBlanking],1

	call	doHMOVE
	ret	

NoBlank:
	add	[P0_Motion],8		; weird HMOVE, move a little extra
	add	[P1_Motion],8
	add	[M0_Motion],8
	add	[M1_Motion],8
	add	[BL_Motion],8
	call	doHMOVE
	ret


;*
;* RESBL
;*

PositionObject macro %1
local HBLwrap, HBLdone

	movzx	ebx,[RClock]
	sub	ebx,CYCLESPERSCANLINE
	jae	HBLwrap	
	add	ebx,CYCLESPERSCANLINE
HBLwrap:
	lea	ebx,[ebx+ebx*2]

	cmp	bl,67			; positioned in HBLANK area
	ja	HBLdone			;   no
	mov	bl,%1			;   yes, position near end instead

HBLdone:
	endm


PositionBall macro
	
	PositionObject 226		; 227 fixes decathln

	endm

PositionPlayer macro

	PositionObject 226

	endm

PositionMissile macro

	PositionObject 226		; 227 fixes dbldragn

	endm

H_RESBL:
	GetObjectDelay BL
	call	CatchUpPixels

	PositionBall
	mov	[TIA+RESBL],bl
	mov	[BL_Position],bx

	ret


;*
;* RESP0
;*

H_RESP0:
	GetObjectDelay P0
	call	CatchUpPixels

	PositionPlayer
	mov	[TIA+RESP0],bl
	mov	[P0_Position],bx

	call	UpdateM0Locking

	ret


;*
;* RESP1
;*

H_RESP1:
	GetObjectDelay P1
	call	CatchUpPixels

	PositionPlayer
	mov	[TIA+RESP1],bl
	mov	[P1_Position],bx

	call	UpdateM1Locking

	ret

;*
;* RESM0
;*

H_RESM0:
	GetObjectDelay M0
	call	CatchUpPixels

	test	[TIA+RESMP0],2
	jnz	noRESM0
	PositionMissile
	mov	[TIA+RESM0],bl
	mov	[M0_Position],bx

noRESM0:
	ret


;*
;* RESM1
;*

H_RESM1:
	GetObjectDelay M1
	call	CatchUpPixels

	test	[TIA+RESMP1],2
	jnz	noRESM1
	PositionMissile
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
;* NUSIZ0
;*

H_NUSIZ0:
	GetObjectDelay M0
	call	CatchUpPixels
	GetObjectDelay P0
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+NUSIZ0],dl

	call	UpdateM0Graphics
	call	UpdateP0Table
	call	UpdateM0Table
	ret

;*
;* NUSIZ1
;*

H_NUSIZ1:
	GetObjectDelay M1
	call	CatchUpPixels
	GetObjectDelay P1
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+NUSIZ1],dl

	call	UpdateM1Graphics
	call	UpdateP1Table
	call	UpdateM1Table
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
	mov	dl,[GRPxDelay]		; -2 for spidrftr, 1 for picnic
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
	mov	dl,[GRPxDelay]		; -2 for spidrftr, 1 for picnic
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
;* handle a motion register
;*

H_Motion:
	mov	dl,[WByte]
	sar	dl,4			; pre-shift right 4 bits (preserve sign)
	mov	[TIA+si],dl
	ret

;*
;* HMCLR
;*

H_HMCLR:
	mov	[TIA+HMP0],0
	mov	[TIA+HMP1],0
	mov	[TIA+HMM0],0
	mov	[TIA+HMM1],0
	mov	[TIA+HMBL],0
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
	mov	dl,0
	call	CatchUpPixels

	mov	dl,[WByte]
	mov	[TIA+REFP0],dl
	call	UpdateP0Graphics
	ret



;*
;* REFP1
;*

H_REFP1:
	mov	dl,0
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
