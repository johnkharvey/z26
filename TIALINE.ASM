;*     
;*  generate a raster line	  
;*
;*  3-18-99  -- break ground
;* 09-07-02 -- 32-bit
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; magic numbers:
;
;   HBLANK starts at zero, ends at 67.
;   Left Playfield starts at 68, ends at 147.
;   Right Playfield starts at 148, ends at 227.
;   HMOVE blank starts at 68, ends at 75.

; register usage:
;
;   CPU doesn't use cx, bp, di --  trashes ax, bx, dx, si
;
;   di -- display pointer
;   cl -- TIARenderPointer
;   ch -- LastPixelPointer


.data

LooseColour	dd	0ffffffffh   ; and this with pixels to turn
				     ;	  frame gray *EST*
				     ;	  see tiawrite.asm

;*
;* Table of low level rendering routines.
;* Index with the ActiveObjects variable.
;*
;* note:  If any delays are in effect, be sure to set the DL_BIT in the
;*	  ActiveObjects variable to ensure that delays are processed
;*	  correctly.
;*

align 2

;PF_BIT = 1
;BL_BIT = 2
;P1_BIT = 4
;M1_BIT = 8
;P0_BIT = 16
;M0_BIT = 32

RenderingRoutine label dword

	dd	RenderBackground	;  0
	dd	RenderPlayfield		;  1

	dd	BK_BL			;  2
	dd	PF_BL			;  3

	dd	BK_P1			;  4
	dd	PF_P1			;  5
	dd	BK_P1_BL		;  6
	dd	PF_P1_BL		;  7

	dd	BK_M1			;  8
	dd	PF_M1			;  9
	dd	BK_M1_BL		; 10
	dd	PF_M1_BL		; 11
	dd	BK_M1_P1		; 12
	dd	PF_M1_P1		; 13
	dd	BK_M1_P1_BL		; 14
	dd	PF_M1_P1_BL		; 15

	dd	BK_P0			; 16
	dd	PF_P0			; 17
	dd	BK_P0_BL		; 18
	dd	PF_P0_BL		; 19
	dd	BK_P0_P1		; 20
	dd	PF_P0_P1		; 21
	dd	BK_P0_P1_BL		; 22
	dd	PF_P0_P1_BL		; 23
	dd	BK_P0_M1		; 24
	dd	PF_P0_M1		; 25
	dd	BK_P0_M1_BL		; 26
	dd	PF_P0_M1_BL		; 27
	dd	BK_P0_M1_P1		; 28
	dd	PF_P0_M1_P1		; 29
	dd	BK_P0_M1_P1_BL		; 30
	dd	PF_P0_M1_P1_BL		; 31

	dd	BK_M0			; 32
	dd	PF_M0			; 33
	dd	BK_M0_BL		; 34
	dd	PF_M0_BL		; 35
	dd	BK_M0_P1		; 36
	dd	PF_M0_P1		; 37
	dd	BK_M0_P1_BL		; 38
	dd	PF_M0_P1_BL		; 39
	dd	BK_M0_M1		; 40
	dd	PF_M0_M1		; 41
	dd	BK_M0_M1_BL		; 42
	dd	PF_M0_M1_BL		; 43
	dd	BK_M0_M1_P1		; 44
	dd	PF_M0_M1_P1		; 45
	dd	BK_M0_M1_P1_BL		; 46
	dd	PF_M0_M1_P1_BL		; 47
	dd	BK_M0_P0		; 48
	dd	PF_M0_P0		; 49
	dd	BK_M0_P0_BL		; 50
	dd	PF_M0_P0_BL		; 51
	dd	BK_M0_P0_P1		; 52
	dd	PF_M0_P0_P1		; 53
	dd	BK_M0_P0_P1_BL		; 54
	dd	PF_M0_P0_P1_BL		; 55
	dd	BK_M0_P0_M1		; 56
	dd	PF_M0_P0_M1		; 57
	dd	BK_M0_P0_M1_BL		; 58
	dd	PF_M0_P0_M1_BL		; 59
	dd	BK_M0_P0_M1_P1		; 60
	dd	PF_M0_P0_M1_P1		; 61
	dd	BK_M0_P0_M1_P1_BL	; 62
	dd	PF_M0_P0_M1_P1_BL	; 63


;*
;* private color registers
;*
;* we use old normal translation table to index into these (TIADisplayToColour)
;* update registers to handle SCORE and PFP
;*

ColorValue label dword

BK_Color	dd	0	; \
PF_Color	dd	0	;	 \  keep these in order so we can use
P1_Color	dd	0	;	 /  the old color translation table
P0_Color	dd	0	; /
BL_Color	dd	0	; ball color -- this is new

RenderingHBLANK	db	-1

ActiveObjects	dd	0
CosmicScanLine	dd	0
HBlanking	db	0
SetHBlanking	db	0
Invisible	db	0
HMOVE_Pending	db	0
HMOVE_Cycle	db	0	; remember cycle of last HMOVE
Last_HMOVE_Cycle db	0
M0_Confused	db	0


CosmicGraphicsTable	db	040h,040h,0c0h,0


;*
;* sprite related stuff
;*

DefineObjectVars macro arg1
ALIGN 2
arg1&_Table	  dd	arg1&_Sprite
arg1&_Position	  dd	0
arg1&_Size	  dd	arg1&_SpriteSize
arg1&_Motion	  dd	0
arg1&_Graphics	  db	0
arg1&_Delayed	  db	0
arg1&_TripleFlag  db	0
	endm

DefineObjectVars BL
DefineObjectVars M0
DefineObjectVars M1
DefineObjectVars P0
DefineObjectVars P1

.code


;*
;* TIA initialization code
;*

Init_TIA:
	mov	[ActiveObjects],0
	mov	[PF_Table], offset PFClockToBitForward
	mov	[BK_Color],0
	mov	[PF_Color],0
	mov	[P0_Position],228-68
	mov	[P1_Position],228-68
	mov	[M0_Position],228-68
	mov	[M1_Position],228-68
	mov	[BL_Position],228-68

	mov	[M0_Confused],0

	mov	[RenderingHBLANK],-1
	ret

_BL	macro
	SetObjectBit BL
	endm

_M0	macro
	SetObjectBit M0
	endm

_M1	macro
	SetObjectBit M1
	endm

_P0	macro
	SetObjectBit P0
	endm


_P1	macro
	SetObjectBit P1
	endm


;*
;* RenderPixel -- render pixel with multiple objects
;*

RenderPixel macro arg1, arg2, arg3, arg4, arg5, arg6
local BKPFonly

	movzx	ebx,dh			; PF bit

	arg1
	arg2
	arg3
	arg4
	arg5
	arg6

	cmp	bl,2
	jb	BKPFonly
	mov	eax,TIAColTab[ebx*4]
	mov	esi,[PixelColorTable]
	or	[TIACollide],eax
	mov	bl,[ebx+esi]

BKPFonly:
	mov	al,byte ptr [ColorValue+ebx*4]
	and	al,byte ptr [LooseColour]	; *EST*
	inc	edi
	and	al,[RenderingHBLANK]
	inc	cl
	gs_store [edi-1],al
	cmp	cl,ch

	endm


;*
;* macro for rendering multiple objects against a playfield
;*

PF_PixelLoop macro arg1, arg2, arg3, arg4, arg5, arg6
local PF_loop, PIX_loop, done
ALIGN 2

	movzx	ebp,cl
	and	ebp,0fch
	add	ebp,[PF_Table]
	sub	ebp,68

PF_loop:
	xchg	ebp,esi
	mov	edx,dword ptr [TIA+PF0]
	test	edx,[esi]
	setnz	dh
	add	esi,4
	xchg	ebp,esi
PIX_loop:
	RenderPixel arg1, arg2, arg3, arg4, arg5, arg6
	ja	done

	test	edi,3
	jnz	PIX_loop

	jmp	PF_loop

done:
	ret

	endm

;*
;* macro for rendering multiple objects against a background (no playfield)
;*

BK_PixelLoop macro arg1, arg2, arg3, arg4, arg5, arg6
local BK_Loop, done
ALIGN 2

	xor	dh,dh

BK_Loop:
	RenderPixel arg1, arg2, arg3, arg4, arg5, arg6
	jbe	BK_Loop

done:
	ret

	endm


;*
;* Here are the low-level rendering routines.
;*

PF_M0_P0_M1_P1_BL:	PF_PixelLoop	_M0 _P0 _M1 _P1 _BL	; 63
BK_M0_P0_M1_P1_BL:	BK_PixelLoop	_M0 _P0 _M1 _P1 _BL	; 62
PF_M0_P0_M1_P1:		PF_PixelLoop	_M0 _P0 _M1 _P1		; 61
BK_M0_P0_M1_P1:		BK_PixelLoop	_M0 _P0 _M1 _P1		; 60
PF_M0_P0_M1_BL:		PF_PixelLoop	_M0 _P0 _M1 _BL		; 59
BK_M0_P0_M1_BL:		BK_PixelLoop	_M0 _P0 _M1 _BL		; 58
PF_M0_P0_M1:		PF_PixelLoop	_M0 _P0 _M1		; 57
BK_M0_P0_M1:		BK_PixelLoop	_M0 _P0 _M1		; 56
PF_M0_P0_P1_BL:		PF_PixelLoop	_M0 _P0 _P1 _BL		; 55
BK_M0_P0_P1_BL:		BK_PixelLoop	_M0 _P0 _P1 _BL		; 54
PF_M0_P0_P1:		PF_PixelLoop	_M0 _P0 _P1		; 53
BK_M0_P0_P1:		BK_PixelLoop	_M0 _P0 _P1		; 52
PF_M0_P0_BL:		PF_PixelLoop	_M0 _P0 _BL		; 51
BK_M0_P0_BL:		BK_PixelLoop	_M0 _P0 _BL		; 50
PF_M0_P0:		PF_PixelLoop	_M0 _P0			; 49
BK_M0_P0:		BK_PixelLoop	_M0 _P0			; 48
PF_M0_M1_P1_BL:		PF_PixelLoop	_M0 _M1 _P1 _BL		; 47
BK_M0_M1_P1_BL:		BK_PixelLoop	_M0 _M1 _P1 _BL		; 46
PF_M0_M1_P1:		PF_PixelLoop	_M0 _M1 _P1		; 45
BK_M0_M1_P1:		BK_PixelLoop	_M0 _M1 _P1		; 44
PF_M0_M1_BL:		PF_PixelLoop	_M0 _M1 _BL		; 43
BK_M0_M1_BL:		BK_PixelLoop	_M0 _M1 _BL		; 42
PF_M0_M1:		PF_PixelLoop	_M0 _M1			; 41
BK_M0_M1:		BK_PixelLoop	_M0 _M1			; 40	
PF_M0_P1_BL:		PF_PixelLoop	_M0 _P1 _BL		; 39
BK_M0_P1_BL:		BK_PixelLoop	_M0 _P1 _BL		; 38
PF_M0_P1:		PF_PixelLoop	_M0 _P1			; 37
BK_M0_P1:		BK_PixelLoop	_M0 _P1			; 36
PF_M0_BL:		PF_PixelLoop	_M0 _BL			; 35
BK_M0_BL:		BK_PixelLoop	_M0 _BL			; 34
PF_M0:			PF_PixelLoop	_M0			; 33
BK_M0:			BK_PixelLoop	_M0			; 32

PF_P0_M1_P1_BL:		PF_PixelLoop	_P0 _M1 _P1 _BL		; 31
BK_P0_M1_P1_BL:		BK_PixelLoop	_P0 _M1 _P1 _BL		; 30
PF_P0_M1_P1:		PF_PixelLoop	_P0 _M1 _P1		; 29
BK_P0_M1_P1:		BK_PixelLoop	_P0 _M1 _P1		; 28
PF_P0_M1_BL:		PF_PixelLoop	_P0 _M1 _BL		; 27
BK_P0_M1_BL:		BK_PixelLoop	_P0 _M1 _BL		; 26
PF_P0_M1:		PF_PixelLoop	_P0 _M1			; 25
BK_P0_M1:		BK_PixelLoop	_P0 _M1			; 24
PF_P0_P1_BL:		PF_PixelLoop	_P0 _P1 _BL		; 23
BK_P0_P1_BL:		BK_PixelLoop	_P0 _P1 _BL		; 22
PF_P0_P1:		PF_PixelLoop	_P0 _P1			; 21
BK_P0_P1:		BK_PixelLoop	_P0 _P1			; 20
PF_P0_BL:		PF_PixelLoop	_P0 _BL			; 19
BK_P0_BL:		BK_PixelLoop	_P0 _BL			; 18
PF_P0:			PF_PixelLoop	_P0			; 17
BK_P0:			BK_PixelLoop	_P0			; 16

PF_M1_P1_BL:		PF_PixelLoop	_M1 _P1 _BL		; 15
BK_M1_P1_BL:		BK_PixelLoop	_M1 _P1 _BL		; 14
PF_M1_P1:		PF_PixelLoop	_M1 _P1			; 13
BK_M1_P1:		BK_PixelLoop	_M1 _P1			; 12
PF_M1_BL:		PF_PixelLoop	_M1 _BL			; 11
BK_M1_BL:		BK_PixelLoop	_M1 _BL			; 10
PF_M1:			PF_PixelLoop	_M1			; 9
BK_M1:			BK_PixelLoop	_M1			; 8	

PF_P1_BL:		PF_PixelLoop	_P1 _BL			; 7
BK_P1_BL:		BK_PixelLoop	_P1 _BL			; 6
PF_P1:			PF_PixelLoop	_P1			; 5
BK_P1:			BK_PixelLoop	_P1			; 4

PF_BL:			PF_PixelLoop	_BL			; 3
BK_BL:			BK_PixelLoop	_BL			; 2

;PF:			PF_PixelLoop				; 1 (used if delay set)
;BK:			BK_PixelLoop				; 0 (used if delay set)


;*
;* render playfield pixels from current cl through ch
;* leaves cl pointing to ch + 1
;*

ALIGN 2

RenderPlayfield:
	push	ecx			; save old start and finish pointers
	sub	ch,cl
	inc	ch			; pixel count

	movzx	esi,cl			; compute pointer into playfield bit mask table
	and	esi,0fch
	add	esi,[PF_Table]
	sub	esi,68

	mov	ebp,dword ptr [TIA+PF0]	; get playfield bits

	mov	eax,[BK_Color]
	and	eax,[LooseColour]	; *EST*

	mov	edx,[PF_Color]
	and	edx,[LooseColour]	; *EST*

NextPFTest:
	test	ebp,[esi]		; setting a playfield bit ?
	jnz	PFLoop			;	  yes

BKLoop:
	gs_store [edi],al
	inc	edi
	dec	ch			; done?
	jz	RenderPlayfieldDone	;   yes
	test	edi,3			; more odd pixels to do?
	jz	NextPFQuad		;   no
	jmp	BKLoop

PFLoop:
	gs_store [edi],dl
	inc	edi
	dec	ch			; done?
	jz	RenderPlayfieldDone	;   yes
	test	edi,3			; more odd pixels to do?
	jz	NextPFQuad		;   no
	jmp	PFLoop

NextPFQuad:
	add	esi,4
	test	ch,0fch			; any more quads to do?
	jz	NextPFTest		;   no, check for more singles
	test	ebp,[esi]		; setting a playfield bit?
	jnz	DoPFQuad		;   yes

	gs_store [edi],eax		; render BK quad
	add	edi,4
	sub	ch,4			; done?
	jnz	NextPFQuad		;   no, keep going
	jmp	RenderPlayfieldDone

DoPFQuad:
	gs_store [edi],edx		; render PF quad	
	add	edi,4
	sub	ch,4			; done?
	jnz	NextPFQuad		;   no, keep going


RenderPlayfieldDone:
	pop	ecx			; done, restore old start and finish pointers
	mov	cl,ch
	inc	cl			; point start at finish + 1

	ret


;*
;* render background pixels from current cl through ch
;* leaves cl pointing to ch + 1
;*

ALIGN 2

RenderBackground:
	mov	eax,[BK_Color]
	and	eax,[LooseColour]	; *EST*

RenderSolid:				; << enter here to render EAX
	push	ecx
	sub	ch,cl
	movzx	ecx,ch
	inc	cl			; pixel count
	test	cl,1			; any odd pixels?
	jz	SolidDouble		;   no
	gs_store [edi],al		;   yes, render single pixel
	inc	edi
	dec	ecx			; done?
	jz	SolidDone		;   yes

SolidDouble:
	shr	ecx,1			; do the double pixels
	gs_rep_stosw			; ** 16-bit routine **

SolidDone:
	pop	ecx			; restore old start and finish pointers
	mov	cl,ch
	inc	cl			; point start at finish + 1
	ret


;*
;* render HBLANK
;*

ALIGN 2

RenderHBLANK:
	cmp	[ActiveObjects],2
	jb	RenderNothing
	mov	esi,[ActiveObjects]
	and	esi,63
	mov	[RenderingHBLANK],0
	call	[RenderingRoutine + esi*4]	; call rendering routine
	mov	[RenderingHBLANK],-1
	ret

;*
;*  render blackness
;*
;*  note:  This approach causes collisions not to be processed during
;*	   vertical blanks.	This may not be correct.
;*

ALIGN 2

RenderNothing:
	xor	eax,eax
	jmp	RenderSolid


;*
;* RenderPixels
;*
;* Since the underlying routines are not capable of dealing with a change of
;* the state of HBlanking, we split calls to RenderPixels if necessary.
;*
;* We do the same thing at mid-playfield to update playfield color translation.
;*

ALIGN 2

RenderPixels:

	cmp	cl,ch
	ja	RenderDone		; protect rep stosw

	cmp	[HBlanking],-1		; doing HBlanking?
	je	RenderMiddle		;   no, don't split out HBlank area

	cmp	cl,75			; render pointer past HBlank?
	ja	RenderMiddle		;   yes
	cmp	ch,75			; final pointer before end of HBlank?
	jbe	RenderHBLANK		;   yes, render blackness

	mov	al,ch			;	 no, render pixels through HBlank
	push	eax
	mov	ch,75
	call	RenderHBLANK
	pop	eax
	mov	ch,al

	mov	[HBlanking],-1		; turn off HBlanking

RenderMiddle:
	cmp	ch,227			; final request for this line?
	jne	RenderPartial		;	no
	test	[ActiveObjects],3	; PF or Ball active ?
	jz	RenderShortcutBK	;	 no, take a shortcut

RenderPartial:
	cmp	cl,147			; render pointer past mid-playfield?
	ja	RenderFinal		;   yes
	cmp	ch,147			; final pointer before mid-playfield?
	jbe	RenderFinal		;   yes

	mov	al,ch			;   no, render pixels through mid-playfield
	push	eax
	mov	ch,147
	call	DoRender
	pop	eax
	mov	ch,al

RenderFinal:
	cmp	cl,148			; at mid-playfield?
	jne	DoRender		;   no

	UpdatePlayfieldReflection	;   yes, update reflection table

DoRender:
	UpdatePlayfieldColor		; every pixel run with PF active

RenderShortcutBK:

	cmp	[VBlanking],0		; doing VBlanking?
	je	RenderNothing		;   yes, render blackness

	mov	esi,[ActiveObjects]
	and	esi,63
	jmp	[RenderingRoutine + esi*4]	; call rendering routine

RenderDone:
	ret


;*
;* render pixels from cl through RClock 
;*
;* points ch to RClock (RClock*3 - 1 + offset parameter in dl)
;* leaves cl pointing to ch + 1
;*
;* Normally the offset parameter should be zero, but this is where we can make
;* small adjustments for register writes that need some additional delays,
;* providing the delays don't need to straddle a line.
;*
;* note: Ignoring invisible regions might cause off-screen collisions to be 
;*	 missed.
;*

ALIGN 2

CatchUpPixels:
	cmp	[Invisible],0		; are we visible?
	jne	CatchupDone		;   no, don't render anything

	mov	ch,[RClock]
	cmp	ch,CYCLESPERSCANLINE	; beyond end of line?
	ja	CatchupLast		;   yes, limit to 227
	add	ch,ch
	add	ch,[RClock]		;   no, compute last clock to render
	dec	ch
	add	ch,dl			;		    add the extra offset

	cmp	ch,227			; request too many pixels?
	jbe	CatchupGo		;   no

CatchupLast:
	mov	ch,227			;	  yes, limit to 227
CatchupGo:
	push	esi			; for the sake of TIA write handlers
	call	RenderPixels
	pop	esi

CatchupDone:
	ret


;*
;* do some instructions until RClock >= CYCLESPERSCANLINE
;*

ALIGN 2

nDoInstructions macro
local InstructionLoop, InstructionsDone

	LoadRegs			; load the CPU registers

	cmp	[RClock],CYCLESPERSCANLINE ; check if we need to skip a line *EST*
	jae	InstructionsDone	; (for WSYNC at cycle 74/75 fix)

InstructionLoop:
	fetch_opcode	ebx		; (fetchzx) get the opcode
	call	[vectors + ebx*4]	; --> do the instruction
	ClockRIOT			; clock the RIOT timer

	cmp	[RClock],CYCLESPERSCANLINE
	jb	InstructionLoop

InstructionsDone:
	SaveRegs			; save the CPU registers
endm


;*
;* TIALineTo -- the actual raster line code
;*

ALIGN 2

nTIALineTo:
	call	_QueueSoundBytes	; put another 2 bytes in the sound queue

	mov	dl,[HMOVE_Cycle]
	mov	[Last_HMOVE_Cycle],dl
	mov	[HMOVE_Cycle],0		; forget where last HMOVE was (cosmic)

	cmp	[M0_Confused],0
	jz	NotCosmic

	push	[M0_Motion]
	mov	[M0_Motion],17		; (17)
	DoMotion M0
	pop	[M0_Motion]
	mov	ebx,[CosmicScanLine]
	inc	[CosmicScanLine]
	and	ebx,3
	mov	dl,[CosmicGraphicsTable+ebx]
	mov	[M0_Graphics],dl

NotCosmic:
	mov	ebx,[ScanLine]
	cmp	ebx,[TopLine]		; line before first displayable?
	jb	nTIANoGenerate		;	yes, don't render
	cmp	ebx,[BottomLine]	; line after last displayable?
	jae	nTIANoGenerate		;	 yes, don't render

	mov	eax,[_MaxLines]
	lea	eax,[eax+eax*4]
	shl	eax,5			; *160

	add	eax,[_ScreenBuffer]

	cmp	[DisplayPointer],eax	; render pointer past end of displayable?
	jae	nTIANoGenerate		;	 yes, don't render

	push	ebp			; rendering -- free up a register

	mov	edi,[DisplayPointer]
	mov	cl,68			; point TIARenderPointer at beginning of playfield

	mov	[HBlanking],-1		; assume we're not HBlanking
	cmp	[SetHBlanking],0	; should we be HBlanking?
	je	NoColumnBlank		;   no
	mov	[HBlanking],0		;	yes, start HBlanking

NoColumnBlank:
	mov	[SetHBlanking],0	; clear the set HBlanking flag

	call	SetupMultiSpriteTrick

	cmp	[RClock],CYCLESPERSCANLINE ; done before we started ?
	jae	nLastPixels		   ;	 yes, WSYNC straddled a line
					;		   render pixels w/o CPU

	mov	[Invisible],0		; tell CatchUpPixels to render pixels
	nDoInstructions			; do a line full of instructions

nLastPixels:
	mov	ch,227			; line done, render any left over pixels
	call	RenderPixels

nTIAExit:				; we've finished the scanline...
	mov	[DisplayPointer],edi

	pop	ebp
	ret


;*
;* do a blank line (outside of display area)
;*

nTIANoGenerate:

	mov	[Invisible],1		; tell CatchUpPixels not to render any pixels
	nDoInstructions			; do a line full of instructions

	ret

