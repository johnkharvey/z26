; *****************************************************************************
;			   MAIN CODE STARTS HERE
; *****************************************************************************

start:

IFNDEF comfile
	mov	ax,_TEXT
	mov	ds,ax			;set up data segment
	mov	bx,es
	mov	psp,bx			;save pointer to PSP
	mov	es,ax			;set up extra segment
	cli
	mov	ss,ax			;set up stack segment
	mov	sp,offset mystack	;  and stack pointer
	sti
ENDIF   
        
	mov	[CartRom+0FFCh],0	; set the default reset address
	mov	[CartRom+0FFDh],0f0h	; to F000

	call	CommandLine		; Process the command line
	call	Reset			; Reset the CPU
	SaveRegs			; save the CPU status
	call	TIAGraphicMode		; Switch into VGA mode
	call	SetNewInt9		; Keyboard Handler


;*
;* the main outer loop
;*

xmain:  
;	BLIP_HP_HALF
;	TIMER_OFF

	test	[NoRetrace],1		; waiting for retrace?
	jnz	VRDone			;  no
	
	mov	dx,03dah		; wait for vertical retrace
WaitForVR:
	in	al,dx
	test	al,8
	jnz	VRDone
	jmp	WaitForVR

VRDone:
;	 TIMER_ON

	call	ScanFrame	
Paused:	call	[CtrlFn]		; check which keys pressed
	test	[GamePaused],1		; wait while game paused
	jnz	Paused
	jmp	xmain

;*
;* end of program (escape pressed or bad opcode)
;*

GoDOS:
	call	SoundOff		; turn sound off
	call	TIATextMode		; back to text mode
	call	SetOldInt9		; reset the key handler

					; empty the keyboard buffer
Empty:	mov	ah,0Bh			; key waiting....
	int	MSDOS
	cmp	al,0FFh			; if not,exit
	jne	Quit
	call	ConIn			; read it
	jmp	Empty
Quit:	
	mov	ah,04Ch			; and return to MSDOS
	int	MSDOS

;*
;* do some instructions until RClock >= al
;*

DoInstructions:
	mov	[LastCycle],al		; last cycle to do
	LoadRegs			; load the CPU registers

InstructionLoop:
	fetch	bl			; get the opcode
	xor	bh,bh
	mov	dl,Cycles[bx]		; get cycles takes to do it
	mov	[RCycles],dl		; save the number of cycles
	add	[RClock],dl		; add to the clock
	shl	bx,1
	jmp	[vectors + bx]		; --> do the instruction

ualnext:usetest al			; <-- instruction done
next:	call	[TimerVec]		; <-- instruction done, clock the RIOT timer
	mov	bh,[LastCycle]		; was CyclesPerScanLine-2
	cmp	[RClock],bh
	jl	InstructionLoop
	SaveRegs			; save the CPU registers
	ret


;*
;* Do One Frame
;*

ScanFrame:
	mov	ax,0a000h
	mov	gs,ax			; point GS to VGA area
        mov	[DisplayPointer],0	; reset display pointer
ScanFrameLoop:
	mov	bx,[ScanLine]		; reset the TIA for a new line
	mov	[TIAScanLine],bx
	mov	bx,offset TIABuffer
	mov	[TIAWritePointer],bx
	mov	dword ptr [bx],-1	;* a dword pointer *

	call	TIALineTo		; generate a raster line

	inc	[ScanLine]		; Increment the scanline counter
	sub	[RClock],CyclesPerScanLine ; adjust clock for next line

; do emergency bail-out test

;	cmp	[VBlankFrame],0		; vblank cause new frame ?
;	jnz	NDret			;   yes, skip emergency bail-out test
;	mov	ax,[ScanLine]		; 
;	cmp	ax,2000			; have we done way too many scan lines yet?
;	jl	NDret			;   not yet
;	inc	[Frame]			;   yes, to the next frame (allow escape to work)
;	mov	[ScanLine],0

	test	[KeyTable+KeyEsc],128
	jnz	GoDOS			; ESC pressed - exit

;NDret:  
	mov	ax,[Frame]
	cmp	ax,[PrevFrame]		; have we gone to a new frame ?
	je	ScanFrameLoop		;   not yet
	mov	[PrevFrame],ax		;   yes, mark it as current
	ret				;	 and return

;*
;* come here when duff opcode 
;*

fail:	dec	bp			; backup the instruction pointer
	read	al,bp			; read the byte
	call	ConHex			; display it
	mov	al,'@'			; here comes the address
	call	ConOut
	mov	ax,bp			; pick up the address
	call	ConWord			; display it
WaitEsc:test	[KeyTable+KeyEsc],128	; wait for ESC to be pressed
	jz	WaitEsc
	jmp	GoDOS


; *****************************************************************************
;
;			       TIA Emulator
;
;	Don't worry about - colours changing in mid playfield (yet)
;
; *****************************************************************************

; *****************************************************************************
;
;	Continue line building at last until column dh is reached
;	from where we previously left off (if registers still ok)
;
;	BP points to the start of the TIA Buffer
;	DL next playfield write position
;	DH limit of line building
;	SI next playfield write address
;
;	This code works down the TIABuffer which is a list of events
;	mostly writing to the TIA events, but there are special events
;	to handle putting the previous line graphic down (basically simulates
;	doing RESxxx in the same place) and multiple graphic copies (by doing
;	a dummy RESxxx that doesn't recent the horizontal position register).
;
;	Mixed in with this is test for the playfield draw,which is done in
;	4 bit 'chunks'. At the beginning of the loop, we see if the next
;	playfield write is due before the next line output. If it is, we
;	do it. If not , the next playfield write is done and so on until
;	the screen line is built.
;
;	The screen line is an array, with 6 bits, each representing the
;	presence of a screen object (pf,bl,m0,p0,m1,p1)
;
;	On entry, you must set the 'draw to' (DH). It then draws from
;	the start position to DH.
;
; *****************************************************************************

;*
;* collision test macros
;*

CollisionTest macro op1
local Clear, Next

	mov	bl,op1[si]
	cmp	bl,3
	jb	Next
	shl	bl,1    
	jc	Clear		;   if collision reset bit set
	or	di,TIAColTab[bx]
	jmp	Next
        
Clear:
	xor	di,di
	or	di,TIAColTab[bx]
Next:

	endm

Collision4 macro
	mov	di,[TIACollide]		; do the collision test
	xor	bh,bh
        
	CollisionTest 0
	CollisionTest 1
	CollisionTest 2
	CollisionTest 3

	mov	[TIACollide],di

	endm

;*
;* output conversion macros
;*

ConvertOut macro op1
	mov	bl,op1[si]		;pick up a byte from TIADisplay
	and	bx,03fh			;mask off collision reset bits
	mov	di,[DisplayTranslate]
	mov	bl,[di+bx]
	mov	bl,TIAColourTable[bx]	;pointer to color register
	mov	al,TIA[bx]		;color value
	shr	al,1
	mov	ah,al			;two bytes at a time
	mov	di,[DisplayPointer]	
	mov	gs:[di],ax
	add	di,2
	mov	[DisplayPointer],di
	endm

Convert4 macro
local	L1

	mov	ax,offset TIADisplayToColour
	test	[TIA+TIACtrlPf],4	;if pf has priority, use alternate translation
	jz	L1
	mov	ax,offset TIADisplayToColour2
L1:
	mov	[DisplayTranslate],ax
	ConvertOut 0
	ConvertOut 1
	ConvertOut 2
	ConvertOut 3
	endm

ConvertBlank4 macro
	mov	di,[DisplayPointer]
	xor	ax,ax
	mov	gs:[di],ax
	add	di,2
	mov	gs:[di],ax
	add	di,2
	mov	gs:[di],ax
	add	di,2
	mov	gs:[di],ax
	add	di,2
	mov	[DisplayPointer],di
	endm

;*
;* macros to output a playfield bit
;*

LeftPlayfieldBit macro
local  PFSkip, L2
	
	cmp	[NoScoreMode],0		; doing scores?
	jnz	L2			;   no
	mov	[TIAColourTable+TCTPF],TIAColupf
	test	[TIA + TIACtrlPf],2	; if colour split, pf col = p0 col
	jz	L2			;(was L2)
	mov	[TIAColourTable+TCTPF],TIAColup0

L2:					; note: one pf bit = 4 color clocks
	mov	bx,cx
	mov	eax,dword ptr [TIA+TIAPf0]
	test	eax,PfClockToBitTable[bx]
	jz	PFSkip
	or	dword ptr [si],TGPlay*01000000h+TGPlay*010000h+TGPlay*0100h+TGPlay
PFSkip:
	endm

RightPlayfieldBit macro
local  PFSkip, L2
	
	cmp	[NoScoreMode],0		; doing scores?
	jnz	L2			;   no
	mov	[TIAColourTable+TCTPF],TIAColupf
	test	[TIA + TIACtrlPf],2	; if colour split, pf col = p1 col
	jz	L2			;(was L2)
	mov	[TIAColourTable+TCTPF],TIAColup1

L2:					; note: one pf bit = 4 color clocks
	mov	bx,cx
	mov	eax,dword ptr [TIA+TIAPf0]
	test	eax,PfClockToBitTable[bx]
	jz	PFSkip
	or	dword ptr [si],TGPlay*01000000h+TGPlay*010000h+TGPlay*0100h+TGPlay
PFSkip:
	endm

;*
;* macro to process objects
;*

DoObjects macro
local TIAObjectLoop, TIASkip, TIAObjectDone

TIAObjectLoop:
	cmp	TIAClock[bp],dl		
	ja	TIAObjectDone		; if next change clock <= next pf write
	mov	bl,TIAReg[bp]		;   go to the register change handler
	and	bx,03fh			; only 63 options !!
	shl	bx,1
	call	TIARegVector[bx]
        
TIASkip:add	bp,4			; go on to the next change
	cmp	byte ptr TIAClock[bp],TIAInvalid ; if moved onto an invalid
	je	TIASkip			; skip it.
	jmp	TIAObjectLoop
        
TIAObjectDone:

	endm	

; *     
; *  TIALineTo -- generate a raster line        
; *
; *  This is the main inner loop -- everything is time critical
; *

TIALineTo:
	mov	bx,[ScanLine]
	cmp	bx,[TopLine]		;was 10
	jb	TIANoGenerate
	cmp	bx,[BottomLine]		;was 250
	jae	TIANoGenerate

TIAGenerate:
	mov	al,[CyclesPerLine]	; was [CyclesPerLine]
	call	DoInstructions		; do instructions for left half of screen

	mov	si,offset TIADisplay	; playfield write pointer
	mov	bp,offset TIABuffer	; initialise the buffer

	mov	di,si
	xor	eax,eax
	mov	cx,40
	rep	stosd			; clear the TIA display buffer

	call	TIAInsertObjects	; insert objects from the last line

	xor	dl,dl			; start position
	xor	cx,cx			; clear playfield clock

TIALeftLoop:
	DoObjects
	LeftPlayfieldBit
	add	dl,4			; increment color clock
	add	cx,4			; increment playfield clock
	
	DoObjects
	
	mov	al,ColumnBlank
	cmp	dl,al
	ja	RealConvert
	ConvertBlank4
	jmp	DoCollisionTest		; cosmic commuter needs collision test

RealConvert:
	Convert4

DoCollisionTest:
	Collision4

	add	si,4			; increment pf write / collision pointer
	cmp	dl,80			; reached end of line?
	jae	TIARightBegin		;   yes, exit
	jmp	TIALeftLoop

TIARightBegin:
;	pusha
;	mov	al,[CyclesPerLine]
;	call	DoInstructions		; do instructions for right half
;	popa

	test	[TIA+TIACtrlPf],1	; reversing the current line ?
	jnz	TIARightLoop		;    yes, continue
	xor	cx,cx			;    no, restart from beginning

TIARightLoop:
	DoObjects
	RightPlayfieldBit
	add	dl,4			; increment color clock
	add	cx,4			; increment playfield clock
	
	DoObjects
	Convert4
	Collision4

	add	si,4			; increment pf write / collision pointer
	cmp	dl,160			; reached end of line?
	jae	TIAExit			;   yes, exit
	jmp	TIARightLoop

TIAExit:				; we've finished the line scan...
	ret

;*
;* do a blank line (outside of display area)
;*

TIANoGenerate:
	mov	al,[CyclesPerLine]
	call	DoInstructions

	mov	bp,offset TIABuffer	; initialise the buffer
TIABLLoop:
	cmp	byte ptr TIAClock[bp],TIAEnd	; check if finished
	je	TIABLExit
	mov	bl,TIAReg[bp]		; register to change
	and	bx,03fh			; only 63 options !
	shl	bx,1
	call	TIARegVector2[bx]
	add	bp,4
	jmp	TIABLLoop
TIABLExit:
	ret

