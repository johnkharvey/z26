; *****************************************************************************
;			   MAIN CODE STARTS HERE
; *****************************************************************************

start:

IFNDEF comfile
	mov	ax,_DATA
	mov	ds,ax			;set up data segment
	mov	bx,es
	mov	psp,bx			;save pointer to PSP
	mov	es,ax			;set up extra segment (ES = DS)
	cli
	mov	ss,ax			;set up stack segment (SS = DS)
					; (necessary because we use bp as a general
					;  purpose index register)

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

	mov	al,[VBlankFrame]	; vblank causes new frame (bowling?)
	cmp	al,0
	jnz	NDret			;   yes, skip emergency bail-out test
	mov	ax,[ScanLine]		; 
	cmp	ax,2000			; have we done way too many scan lines yet?
	jl	NDret			;   not yet
	inc	[Frame]			;   yes, to the next frame (allow escape to work)
	mov	[ScanLine],0
;	call	TIABlank

NDret:  
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

CollisionTest macro
local Done

	movzx	ebx,byte ptr [si]
	cmp	bl,3
	jb	Done
	mov	ax,TIAColTab[ebx*2]
	or	[TIACollide],ax

Done:
	endm

;*
;* combine collision test and output conversion
;*

CollisionConvert macro
local BackgroundPFOnly

	movzx	ebx,byte ptr [si]	; pick up a byte from TIADisplay
	cmp	bl,2			; looking at background or playfield only?
	jb	BackgroundPFOnly	;   yes
	mov	di,[TIADisplayToColor]	; < preload table pointer
	mov	ax,TIAColTab[ebx*2]	; do collision test
	or	[TIACollide],ax
	mov	bl,[di+bx]		; get high priority color

BackgroundPFOnly:
	mov	di,cx			; < preload display pointer
	mov	bl,TIAColourTable[bx]	; pointer to color register
	add	cx,2			; < increment display pointer
	mov	al,TIA[bx]		; color value
	mov	ah,al			; two bytes at a time
	mov	gs:[di],ax

	endm


;*
;* only call this one if playfield clock is a multiple of 4
;*

PlayfieldBit macro
local PFSkip
	
	mov	di,[PFClockToBitTable]
	mov	eax,dword ptr [TIA+TIAPf0]
;	movzx	bx,dl
	mov	bx,dx
	test	eax,[di + bx]			; setting a playfield bit ?
	jz	PFSkip
	or	dword ptr [si],TGPlay*01000000h+TGPlay*010000h+TGPlay*0100h+TGPlay
PFSkip:
	endm


;*
;* macro to process objects
;*

DoObjects macro
local ObjectLoop, Skip, Branch, Done

ObjectLoop:
	cmp	TIAClock[bp],dl		
	ja	Done			; if next change clock <= next pf write
Branch:
	mov	bl,TIAReg[bp]		;   goto register change handler
	and	ebx,03fh		; only 63 options
	call	[TIARegVector + ebx*2]
        
Skip:	add	bp,4			; go on to the next change
	cmp	byte ptr TIAClock[bp],TIAInvalid ; if moved onto an invalid
	je	Skip			; skip it.

	cmp	TIAClock[bp],dl		; < another change to handle? (pentium opt)
	jbe	Branch			;   yes
Done:
	endm

;*
;* macro to put a blank bit into the display
;*

BlankBit macro
	mov	di,cx
	xor	ax,ax
	mov	gs:[di],ax
	add	cx,2
endm


;*
;* macro to do 4 blank bits
;*

DoBlank4 macro

	DoObjects
	PlayfieldBit
	CollisionTest
	BlankBit
	inc	dl
	inc	si

	DoObjects
	CollisionTest
	BlankBit
	inc	dl
	inc	si

	DoObjects
	CollisionTest
	BlankBit
	inc	dl
	inc	si

	DoObjects
	CollisionTest
	BlankBit
	inc	dl
	inc	si

	endm	

;*
;* macro to do a real bit (complete)
;*

DoReal	macro

	DoObjects
	PlayfieldBit
	CollisionConvert
	inc	dl			; increment color clock
	inc	si			; increment pf write / collision pointer

	endm

;*
;* do 4 real bits
;*

DoReal4 macro

	DoObjects
	PlayfieldBit
	CollisionConvert
	inc	dl			; increment color clock
	inc	si			; increment pf write / collision pointer

	DoObjects
	CollisionConvert
	inc	dl			; increment color clock
	inc	si			; increment pf write / collision pointer

	DoObjects
	CollisionConvert
	inc	dl			; increment color clock
	inc	si			; increment pf write / collision pointer

	DoObjects
	CollisionConvert
	inc	dl			; increment color clock
	inc	si			; increment pf write / collision pointer

	endm


;*****************************************************************************

;*
;* macro to process objects, leave clock of next object in AL for further testing
;*

DoObjectsAL macro
local ObjectLoop, Skip, Branch, Done

ObjectLoop:
	mov	al,TIAClock[bp]
	cmp	al,dl		
	ja	Done			; if next change clock <= next pf write
Branch:
	mov	bl,TIAReg[bp]		;   goto register change handler
	and	ebx,03fh		; only 63 options
	call	[TIARegVector + ebx*2]
        
Skip:	add	bp,4			; go on to the next change
	mov	al,TIAClock[bp]
	cmp	al,TIAInvalid 		; if moved onto an invalid
	je	Skip			; skip it.

	cmp	al,dl			; < another change to handle?
	jbe	Branch			;   yes
Done:
	endm


;*
;* set 4 display bits to value in bl, increment display pointer
;*

Set4Bits macro

	mov	di,cx			; display pointer
	mov	bh,bl
	mov	ax,bx
	shl	eax,16
	mov	ax,bx
	mov	gs:[di],eax
	add	cx,8
	mov	gs:4[di],eax

	endm


FastPlayfieldBit macro op1
local PFSkip, SlowLane, SetPFBit, SetBkBit, FastSetPFBit

	mov	di,[PFClockToBitTable]		; < preload table pointer
	sub	al,dl				; # of color clocks to next object
	cmp	al,4				; at least 4 ?
	jb	SlowLane			;   no
	cmp	dword ptr [si],0		; anything set in next 4 TIA bits ?
	jne	SlowLane			;   yes

	mov	eax,dword ptr [TIA+TIAPf0]
;	movzx	bx,dl
	mov	bx,dx
	add	dl,4
	test	eax,[di + bx]			; setting a playfield bit ?
	jnz	FastSetPFBit			;   yes

	mov	bl,TIA[TIAColubk]		;   no, do 4 background bits
	add	si,4
	Set4Bits
	jmp	op1				; FastExit

FastSetPFBit:
	mov	bl,TIAColourTable[TCTPF]	; pointer to color register
	add	si,4
	mov	bl,TIA[bx]			; color value
	Set4Bits
	jmp	op1
	

SlowLane:
	mov	eax,dword ptr [TIA+TIAPf0]
;	movzx	bx,dl
	mov	bx,dx
	test	eax,[di + bx]			; setting a playfield bit ?
	jz	PFSkip
SetPFBit:
	or	dword ptr [si],TGPlay*01000000h+TGPlay*010000h+TGPlay*0100h+TGPlay
PFSkip:
	endm

;*
;* do 4 real bits
;*

DoRealFast4 macro
local FastExit

	DoObjectsAL
	FastPlayfieldBit FastExit

	CollisionConvert
	inc	dl			; increment color clock
	inc	si			; increment pf write / collision pointer

	DoObjects
	CollisionConvert
	inc	dl			; increment color clock
	inc	si			; increment pf write / collision pointer

	DoObjects
	CollisionConvert
	inc	dl			; increment color clock
	inc	si			; increment pf write / collision pointer

	DoObjects
	CollisionConvert
	inc	dl			; increment color clock
	inc	si			; increment pf write / collision pointer

FastExit:
	endm


;*****************************************************************************


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

;	xor	dl,dl			; start position
	xor	dx,dx			; dh = 0 too for FastPlayfieldBit
	mov	cx,[DisplayPointer]

	mov	di,[TIAPFColorByClock]	; update playfield color
	mov	al,[di]			; clock position 0
	mov	[TIAColourTable+TCTPF],al

TIABlankLoop:
	mov	al,ColumnBlank
	cmp	dl,al			; doing column blanking ?
	jae	TIALoop			;   no
	DoBlank4			;   yes, do 8 columns
	DoBlank4

TIALoop:
	DoRealFast4
	DoRealFast4
	cmp	dl,80			; reached middle of playfield?
	je	TIARightBegin		;   yes
TIATestDone:
	cmp	dl,160
	jae	TIAExit
	jmp	TIALoop

TIARightBegin:
	mov	di,[TIAPFColorByClock]	; update playfield color
	movzx	bx,dl
	mov	al,[di+bx]
	mov	[TIAColourTable+TCTPF],al

; this code doesn't belong in the TIA handler because real TIA can't respond to change
; in real time  (messes up astrblst if it's there)

	mov	ax,offset PFClockToBitReversed
	test	[TIA+TIACtrlPf],1	; reversing the current line ?
	jnz	TIARB1			;    yes, continue
	mov	ax,offset PFClockToBitForward

TIARB1:
	mov	[PFClockToBitTable],ax

	cmp	dl,160
	jae	TIAExit
	jmp	TIALoop

TIAExit:				; we've finished the line scan...
	mov	[DisplayPointer],cx

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

