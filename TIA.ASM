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
	call	RSave			; save the CPU status
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
	xor	dl,dl			; next clock line for playfield write..
	call	RLoad			; load the CPU registers

;*
;* do some instructions
;*

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
	cmp	[RClock],CyclesPerScanLine-2	;* why -2?
	jl	InstructionLoop

;*
;* we've done a line full of instructions
;*

	call	RSave			; save the CPU registers

	pusha
	call	TIALineTo		; generate a raster line
	popa

	inc	[ScanLine]		; Increment the scanline counter
	sub	[RClock],CyclesPerScanLine

; * this stuff is only needed if a game doesn't write to vsync
; * like bowling

	mov	ax,[ScanLine]		; (chopper command needs 266)
	cmp	ax,270			; have we done all 262 scan lines yet?
	jl	NDret			;   not yet
	inc	[Frame]			;   yes, to the next frame
	mov	[ScanLine],0
;	call	TIABlank

NDret:  
	mov	ax,[Frame]
	cmp	ax,[PrevFrame]		; have we gone to a new frame ?
	je	ScanFrameLoop		;   not yet
	mov	[PrevFrame],ax		;   yes, mark it as current
	ret				;	 and return

;*
;* blank the remainder of the display each frame
;*

TIABlank:
	push	ax
	push	di
	xor	ax,ax
	mov	di,[DisplayPointer]
TIABLoop:
	cmp	di,30000
	jb	TIABRet
	cmp	di,64000		; reached end of display area?
	jae	TIABRet			;    yes, done
	mov	gs:[di],ax
	add	di,2
	jmp	TIABLoop

TIABRet:
	mov	[DisplayPointer],di
	pop	di
	pop	ax
	ret

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
	mov	bl,op1[si]
	cmp	bl,3
	jb	TIACollisionNext&op1
	shl	bl,1    
	jc	TIACollisionClear&op1	;   if collision reset bit set
	or	di,TIAColTab[bx]
	jmp	TIACollisionNext&op1
        
TIACollisionClear&op1:
	xor	di,di
	or	di,TIAColTab[bx]
TIACollisionNext&op1:

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

;*
;* macro to output a playfield bit
;*
;* there may be a bug in here
;*   try seaquest 
;*   there's a stripe in the middle when playfield takes on player color wrongly
;* 

PlayfieldBit macro
local PFDoIt, PFSkip, L1, L2
	mov	[TIAColourTable+TCTPF],TIAColupf
	test	[TIA+TIACtrlPf],2	; if colour split, pf col = p0 col
	jz	L2
	mov	[TIAColourTable+TCTPF],TIAColup0
L2:    	cmp	dl,80			; do a playfield bit, at center of screen ?
	jne	PFDoIt			;   no, just do it

	test	[TIA+TIACtrlPf],2	;   yes, if colour split, pf col = p1 col
	jz	L1
	mov	[TIAColourTable+TCTPF],TIAColup1
L1:	test	[TIA+TIACtrlPf],1	; reversing the current line ?
	jnz	PFDoIt			;    yes, continue
	xor	cx,cx			;    no, restart from beginning

PFDoIt:					; note: one pf bit = 4 color clocks
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
	mov	bp,offset TIABuffer	; initialise the buffer

	mov	bx,[ScanLine]
	cmp	bx,[TopLine]		;was 10
	jb	TIANoGenerate
	cmp	bx,[BottomLine]		;was 250
	jae	TIANoGenerate

TIAGenerate:
	mov	si,offset TIADisplay	; playfield write pointer

	mov	di,si
	xor	eax,eax
	mov	cx,40
	rep	stosd			; clear the TIA display buffer

	call	TIAInsertObjects	; insert objects from the last line

	xor	dl,dl			; start position
	xor	cx,cx			; clear playfield clock

TIALoop:
	DoObjects
	PlayfieldBit
	add	dl,4			; increment color clock
	add	cx,4			; increment playfield clock
	
	DoObjects
	Convert4
	Collision4

	add	si,4			; increment pf write / collision pointer
	cmp	dl,160			; reached end of line?
	jae	TIAExit			;   yes, exit
	jmp	TIALoop

TIAExit:				; we've finished the line scan...
	ret

;*
;* do a blank line (outside of display area)
;*

TIANoGenerate:
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

