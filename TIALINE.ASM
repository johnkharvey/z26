;*     
;*  generate a raster line        
;*
;*  3-18-99  -- break ground
;*

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

;*
;* Table of low level rendering routines.
;* Index with the ActiveObjects variable.
;*
;* note:  If any delays are in effect, be sure to set the DL_BIT in the
;*        ActiveObjects variable to ensure that delays are processed
;*        correctly.
;*

align 2

;PF_BIT = 1
;BL_BIT = 2
;P1_BIT = 4
;M1_BIT = 8
;P0_BIT = 16
;M0_BIT = 32

RenderingRoutine label word

	dw	RenderBackground	;  0
	dw	RenderPlayfield		;  1

	dw	BK_BL			;  2
	dw	PF_BL			;  3

	dw	BK_P1			;  4
	dw	PF_P1			;  5
	dw	BK_P1_BL		;  6
	dw	PF_P1_BL		;  7

	dw	BK_M1			;  8
	dw	PF_M1			;  9
	dw	BK_M1_BL		; 10
	dw	PF_M1_BL		; 11
	dw	BK_M1_P1		; 12
	dw	PF_M1_P1		; 13
	dw	BK_M1_P1_BL		; 14
	dw	PF_M1_P1_BL		; 15

	dw	BK_P0			; 16
	dw	PF_P0			; 17
	dw	BK_P0_BL		; 18
	dw	PF_P0_BL		; 19
	dw	BK_P0_P1		; 20
	dw	PF_P0_P1		; 21
	dw	BK_P0_P1_BL		; 22
	dw	PF_P0_P1_BL		; 23
	dw	BK_P0_M1		; 24
	dw	PF_P0_M1		; 25
	dw	BK_P0_M1_BL		; 26
	dw	PF_P0_M1_BL		; 27
	dw	BK_P0_M1_P1		; 28
	dw	PF_P0_M1_P1		; 29
	dw	BK_P0_M1_P1_BL		; 30
	dw	PF_P0_M1_P1_BL		; 31

	dw	BK_M0			; 32
	dw	PF_M0			; 33
	dw	BK_M0_BL		; 34
	dw	PF_M0_BL		; 35
	dw	BK_M0_P1		; 36
	dw	PF_M0_P1		; 37
	dw	BK_M0_P1_BL		; 38
	dw	PF_M0_P1_BL		; 39
	dw	BK_M0_M1		; 40
	dw	PF_M0_M1		; 41
	dw	BK_M0_M1_BL		; 42
	dw	PF_M0_M1_BL		; 43
	dw	BK_M0_M1_P1		; 44
	dw	PF_M0_M1_P1		; 45
	dw	BK_M0_M1_P1_BL		; 46
	dw	PF_M0_M1_P1_BL		; 47
	dw	BK_M0_P0		; 48
	dw	PF_M0_P0		; 49
	dw	BK_M0_P0_BL		; 50
	dw	PF_M0_P0_BL		; 51
	dw	BK_M0_P0_P1		; 52
	dw	PF_M0_P0_P1		; 53
	dw	BK_M0_P0_P1_BL		; 54
	dw	PF_M0_P0_P1_BL		; 55
	dw	BK_M0_P0_M1		; 56
	dw	PF_M0_P0_M1		; 57
	dw	BK_M0_P0_M1_BL		; 58
	dw	PF_M0_P0_M1_BL		; 59
	dw	BK_M0_P0_M1_P1		; 60
	dw	PF_M0_P0_M1_P1		; 61
	dw	BK_M0_P0_M1_P1_BL	; 62
	dw	PF_M0_P0_M1_P1_BL	; 63


;*
;* private color registers
;*
;* we use old normal translation table to index into these (TIADisplayToColour)
;* update registers to handle SCORE and PFP
;*

ColorValue label word

BK_Color	dw	0	; \
PF_Color	dw	0	;  \  keep these in order so we can use
P1_Color	dw	0	;  /  the old color translation table
P0_Color	dw	0	; /
BL_Color	dw	0	; ball color -- this is new

ActiveObjects	dw	0
CosmicScanLine	dw	0
HBlanking	dw	0
SetHBlanking	db	0
Invisible	db	0
HMOVE_Pending	db	0
HMOVE_Cycle	db	0	; remember cycle of last HMOVE
M0_Confused	db	0
CosmicGraphicsTable	db	040h,040h,0c0h,0


;*
;* sprite related stuff
;*

DefineObjectVars macro %1
ALIGN 2
%1&_Table	dw	%1&_Sprite
%1&_Position	dw	0
%1&_Size	dw	%1&_SpriteSize
%1&_Motion	dw	0
%1&_Graphics	db	0
%1&_Delayed	db	0
%1&_TripleFlag	db	0
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
	ret

;*
;* object rendering macros
;*
;* they should OR their respective bits into BL
;* AX, DL and SI are free registers that these routines can use
;*

SetObjectBit macro %1
local done, nowrap

	movzx	si,cl
	sub	si,[%1&_Position]
	jae	nowrap
	add	si,160
nowrap:	
	cmp	si,[%1&_Size]
	ja	done
	add	si,si
	add	si,[%1&_Table]
	mov	al,[%1&_Graphics]
	test	al,[si]
	jz	done
	or	bl,%1&_BIT
done:
	endm

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

RenderPixel macro %1, %2, %3, %4, %5, %6
local BKPFonly

	movzx	ebx,dh			; PF bit

	%1
	%2
	%3
	%4
	%5
	%6

	cmp	bl,2
	jb	BKPFonly
	mov	ax,TIAColTab[ebx*2]
	mov	si,[PixelColorTable]
	or	[TIACollide],ax
	mov	bl,[bx+si]

BKPFonly:
	add	di,2
	mov	ax,[ColorValue+ebx*2]
	inc	cl
	mov	es:[di-2],ax
	cmp	cl,ch

	endm


;*
;* macro for rendering multiple objects against a playfield
;*

PF_PixelLoop macro %1, %2, %3, %4, %5, %6
local PF_loop, PIX_loop, done
ALIGN 2

	movzx	bp,cl
	and	bp,0fch
	add	bp,[PF_Table]
	sub	bp,68

PF_loop:
	mov	edx,dword ptr [TIA+PF0]
	test	edx,ds:[bp]
	setnz	dh
	add	bp,4

PIX_loop:
	RenderPixel %1, %2, %3, %4, %5, %6
	ja	done
	
	test	di,7
	jnz	PIX_loop

	jmp	PF_loop

done:
	ret

	endm

;*
;* macro for rendering multiple objects against a background (no playfield)
;*

BK_PixelLoop macro %1, %2, %3, %4, %5, %6
local BK_Loop, done
ALIGN 2

	xor	dh,dh

BK_Loop:
	RenderPixel %1, %2, %3, %4, %5, %6
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
	push	cx			; save old start and finish pointers
	sub	ch,cl
	inc	ch			; pixel count

	movzx	si,cl			; compute pointer into playfield bit mask table
	and	si,0fch
	add	si,[PF_Table]
	sub	si,68

	mov	ebp,dword ptr [TIA+PF0]	; get playfield bits

	mov	ax,[BK_Color]
	shl	eax,16
	mov	ax,[BK_Color]		; 32-bit background color

	mov	dx,[PF_Color]
	shl	edx,16
	mov	dx,[PF_Color]		; 32-bit playfield color

NextPFTest:
	test	ebp,[si]		; setting a playfield bit ?
	jnz	PFLoop			;   yes

BKLoop:
	mov	es:[di],ax
	add	di,2
	dec	ch			; done?
	jz	RenderPlayfieldDone	;   yes
	test	di,7			; more odd pixels to do?
	jz	NextPFQuad		;   no
	jmp	BKLoop

PFLoop:
	mov	es:[di],dx
	add	di,2
	dec	ch			; done?
	jz	RenderPlayfieldDone	;   yes
	test	di,7			; more odd pixels to do?
	jz	NextPFQuad		;   no
	jmp	PFLoop

NextPFQuad:
	add	si,4
	test	ch,0fch			; any more quads to do?
	jz	NextPFTest		;   no, check for more singles
	test	ebp,[si]		; setting a playfield bit?
	jnz	DoPFQuad		;   yes

	mov	es:[di],eax		; render BK quad
	mov	es:[di+4],eax
	add	di,8
	sub	ch,4			; done?
	jnz	NextPFQuad		;   no, keep going
	jmp	RenderPlayfieldDone

DoPFQuad:
	mov	es:[di],edx		; render PF quad
	mov	es:[di+4],edx
	add	di,8
	sub	ch,4			; done?
	jnz	NextPFQuad		;   no, keep going


RenderPlayfieldDone:
	pop	cx			; done, restore old start and finish pointers
	mov	cl,ch
	inc	cl			; point start at finish + 1

	ret


;*
;* render background pixels from current cl through ch
;* leaves cl pointing to ch + 1
;*

ALIGN 2

RenderBackground:
	mov	ax,[BK_Color]
	shl	eax,16
	mov	ax,[BK_Color]		; 32-bit background color

RenderSolid:				; << enter here to render EAX
	push	cx
	sub	ch,cl
	movzx	cx,ch
	inc	cl			; pixel count
	test	cl,1			; any odd pixels?
	jz	SolidDouble		;   no
	mov	es:[di],ax		;   yes, render single pixel
	add	di,2
	dec	cx			; done?
	jz	SolidDone		;   yes

SolidDouble:
	shr	cx,1			; do the double pixels
	rep	stosd

SolidDone:
	pop	cx			; restore old start and finish pointers
	mov	cl,ch
	inc	cl			; point start at finish + 1
	ret


;*
;*  render blackness
;*
;*  note:  This approach causes collisions not to be processed during HMOVE
;*         blanks and vertical blanks.  This may not be correct.
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

	cmp	[VBlanking],0		; doing VBlanking?
	je	RenderNothing		;   yes, render blackness

	cmp	[HBlanking],-1		; doing HBlanking?
	je	RenderMiddle		;   no, don't split out HBlank area

	cmp	cl,75			; render pointer past HBlank?
	ja	RenderMiddle		;   yes
	cmp	ch,75			; final pointer before end of HBlank?
	jbe	RenderNothing		;   yes, render blackness

	mov	al,ch			;   no, render pixels through HBlank
	push	ax
	mov	ch,75
	xor	eax,eax
	call	RenderSolid
	pop	ax
	mov	ch,al

	mov	[HBlanking],-1		; turn off HBlanking

RenderMiddle:
	cmp	ch,227			; final request for this line?
	jne	RenderPartial		;   no
	test	[ActiveObjects],3	; PF or Ball active ?
	jz	RenderShortcutBK	;   no, take a shortcut

RenderPartial:
	cmp	cl,147			; render pointer past mid-playfield?
	ja	RenderFinal		;   yes
	cmp	ch,147			; final pointer before mid-playfield?
	jbe	RenderFinal		;   yes

	mov	al,ch			;   no, render pixels through mid-playfield
	push	ax
	mov	ch,147
	call	DoRender
	pop	ax
	mov	ch,al

RenderFinal:
	cmp	cl,148			; at mid-playfield?
	jne	DoRender		;   no

	UpdatePlayfieldReflection	;   yes, update reflection table

DoRender:
	UpdatePlayfieldColor		; every pixel run with PF active

RenderShortcutBK:
	mov	si,[ActiveObjects]
	and	esi,63
	jmp	[RenderingRoutine + esi*2]	; call rendering routine

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
;*       missed.
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
	add	ch,dl			;       add the extra offset

	cmp	ch,227			; request too many pixels?
	jbe	CatchupGo		;   no

CatchupLast:
	mov	ch,227			;   yes, limit to 227
CatchupGo:
	push	si			; for the sake of TIA write handlers
	call	RenderPixels
	pop	si

CatchupDone:
	ret


;*
;* do some instructions until RClock >= CYCLESPERSCANLINE
;*

ALIGN 2

nDoInstructions macro
local InstructionLoop, InstructionsDone

	LoadRegs			; load the CPU registers

InstructionLoop:
	fetch_opcode	ebx		; (fetchzx) get the opcode
	call	[vectors + ebx*2]	; --> do the instruction
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
	push	gs			; have stosw point at graphics segment
	pop	es			; es gets restored before returning
					; to C program

	call	_QueueSoundBytes	; put another 2 bytes in the sound queue

	mov	[HMOVE_Cycle],0		; forget where last HMOVE was (cosmic)
	cmp	[M0_Confused],0
	jz	NotCosmic

	push	[M0_Motion]
	mov	[M0_Motion],17		; (17)
	DoMotion M0
	pop	[M0_Motion]
	mov	bx,[CosmicScanLine]
	inc	[CosmicScanLine]
	and	bx,3
	mov	dl,[CosmicGraphicsTable+bx]
	mov	[M0_Graphics],dl

NotCosmic:
	mov	bx,[ScanLine]
	cmp	bx,[TopLine]		; line before first displayable?
	jb	nTIANoGenerate		;   yes, don't render
	cmp	bx,[BottomLine]		; line after last displayable?
	jae	nTIANoGenerate		;   yes, don't render

;	mov	ax,[MaxLines]
;	imul	ax,320

	movzx	eax,[MaxLines]
	lea	eax,[eax+eax*4]
	shl	ax,6			; *320

	cmp	[DisplayPointer],ax	; render pointer past end of displayable?
	jae	nTIANoGenerate		;   yes, don't render

	push	bp			; rendering -- free up a register

	call	ModeXNewLine		; init mode-x code for this line
	mov	di,[DisplayPointer]
	mov	cl,68			; point TIARenderPointer at beginning of playfield

	mov	[HBlanking],-1		; assume we're not HBlanking
	cmp	[SetHBlanking],0	; should we be HBlanking?
	je	NoColumnBlank		;   no
	mov	[HBlanking],0		;   yes, start HBlanking

NoColumnBlank:
	mov	[SetHBlanking],0	; clear the set HBlanking flag

	call	SetupMultiSpriteTrick

	cmp	[RClock],CYCLESPERSCANLINE ; done before we started ?
	jae	nLastPixels		   ;   yes, WSYNC straddled a line
					;	    render pixels w/o CPU

	mov	[Invisible],0		; tell CatchUpPixels to render pixels
	nDoInstructions			; do a line full of instructions

nLastPixels:
	mov	ch,227			; line done, render any left over pixels
	call	RenderPixels

nTIAExit:				; we've finished the scanline...
	call	ModeXCopyLine
	mov	[DisplayPointer],di

	pop	bp
	ret


;*
;* do a blank line (outside of display area)
;*

nTIANoGenerate:

	mov	[Invisible],1		; tell CatchUpPixels not to render any pixels
	nDoInstructions			; do a line full of instructions

	ret

