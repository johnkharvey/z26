; *****************************************************************************
;			   MAIN CODE STARTS HERE
; *****************************************************************************

ALIGN_ENTRY

EXTRN _StartSound:near;
EXTRN _StopSound:near;


start:


IFDEF module

global _emulator

_emulator:

	push	ds			; because "C" program can blow es ...
	pop	es			; ... before we get here (getvect)

	mov	ax,_psp
	mov	psp,ax			; set up PSP for commandline
	pop	ModuleReturn		; save return adr
	mov	ModuleBP,bp		; save bp
	mov	ax,sp
	mov	ModuleSP,ax		; save sp (no return adr on stack)
ENDIF   


IFDEF exefile
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
	mov	bx,[_CartRom]
	mov	byte ptr[bx+0FFCh],0	; set the default reset address
	mov	byte ptr[bx+0FFDh],0f0h	; to F000

	call	CommandLine		; Process the command line (*** again! ***)
					; I don't know why we need to call this from here
					; as well as from the "C" program ...

	call	Reset			; Reset the CPU
	call	TIAGraphicMode		; Switch into VGA mode
	call	VSyncInit		; init VSync code
	call	SetNewInt9		; Keyboard Handler
	call	JoyCenter		; set joystick center position

	push	es
	mov	ax,040h
	mov	es,ax
	mov	bx,06ch			; point at time of day
	xor	cx,cx			; count ticks
	xor	edx,edx			; for prev tick

StartupDelayLoop:
	mov	eax,es:[bx]		; get start ticks
	mov	[StartTicks],eax
	cmp	eax,edx
	je	StartupDelayLoop
	mov	edx,eax			; remember prev
	inc	cx
	cmp	cx,18			; been a second?
	jbe	StartupDelayLoop

RTLoop:
	mov	eax,es:[bx]
	cmp	eax,[StartTicks]
	je	RTLoop			; wait for timer to roll over
	mov	[StartTicks],eax
	pop	es

	xor	al,al

	cli
	out	043h,al			; tell timer we wanna read it
	in	al,040h			; read lo-order byte (discard)
	in	al,040h			; read hi-order byte
	sti

	neg	al			; it's a down counter
	mov	[MicroTick],al

	mov	cl,al
	mov	eax,[StartTicks]
	shl	eax,8
	mov	al,cl			; install hi-order micro-tick into tick count
	mov	[StartTicks],eax

	mov	eax,[FrameExit]
	mov	[OriginalFrameExit],eax	; remember how many frames we did for FPS calculation

	call	_StartSound		; we need to wait till the last minute for this
					; to minimize startup noises


;*
;* the main outer loop
;*

ALIGN_ENTRY

EXTRN _Sb_init:BYTE
EXTRN _Fillbuffer:near
EXTRN _PauseDMA:near
EXTRN _ContinueDMA:near

xmain:  
	cmp	[FrameExit],0		; exiting after <n> frames ?
	je	xm1			;   no
	dec	[FrameExit]		;   yes, decrement counter
	cmp	[FrameExit],0		; did it go to zero ?
	je	GoTIME			;   yes, exit now

xm1:
	call	VSync
	call	ScanFrame

Paused:	call	[CtrlFn]		; check which keys pressed
	test	[GamePaused],1		; game paused ?
	jz	xmain			;   no, next frame
	call	PauseDMA		;   yes, pause sound
PausedLoop:
	call	[CtrlFn]		; check which keys pressed
	test	[GamePaused],1		; game paused ?
	jnz	PausedLoop		;   yes
	call	ContinueDMA		;   no, continue sound
	jmp	xmain			; to next frame

PauseDMA:
	cmp	[_Sb_init],0		; SoundBlaster initialized ?
	jz	PDRET			;   no, just return
	call	_PauseDMA		;   yes, pause DMA
PDRET:	ret

ContinueDMA:
	cmp	[_Sb_init],0		; SoundBlaster initialized ?
	jz	CDRET			;   no, just return
	call	_ContinueDMA		;   yes, continue DMA
CDRET:	ret

;*
;* end of program (escape pressed or bad opcode)
;*

GoTIME:
	cli	

	xor	al,al
	out	043h,al			; tell timer we wanna read it
	in	al,040h			; read lo-order byte (discard)
	in	al,040h			; read hi-order byte
	neg	al			; it's a down counter
	mov	cl,al

	push	es
	mov	ax,040h
	mov	es,ax
	mov	bx,06ch			; point at time of day
	mov	eax,es:[bx]		; get stop ticks
	pop	es
	mov	[StopTicks],eax

	mov	eax,[StopTicks]
	shl	eax,8
	mov	al,cl			; install hi-order micro-tick into tick count
	mov	[StopTicks],eax
	mov	eax,[StopTicks]
	sub	eax,[StartTicks]	; get the difference
	mov	[StopTicks],eax

	sti

	call	SoundOff		; turn sound off (PC speaker)
	call	_StopSound		; turn sound off (Soundblaster)
	call	TIATextMode
	call	SetOldInt9

	mov	eax,[StopTicks]
	call	DPT			; print it out (decimal)

	mov	dx,offset ticklets
	mov	ah,9
	int	MSDOS			; output a message

	mov	eax,[OriginalFrameExit]
	imul	eax,4661		; ticklets per second ((14318180/12)/256)
	mov	ebx,[StopTicks]
	xor	edx,edx
	div	ebx
	call	DPT
	mov	dx,offset fps
	mov	ah,9
	int	MSDOS

	jmp	Empty

	

GoDOS:
	call	SoundOff		; turn sound off (PC speaker)
	call	_StopSound		; turn sound off (Soundblaster)
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
IFDEF module
	mov	bp,ModuleBP
	mov	ax,ModuleSP
	mov	sp,ax
	push	ModuleReturn
	ret
ENDIF
	mov	ah,04Ch			; and return to MSDOS
	int	MSDOS

;*
;* Do One Frame
;*

EXTRN _Fillbuffer:near
EXTRN _Sb_init:BYTE

ALIGN_ENTRY

ScanFrame:
	mov	ax,0a000h		;   no
	mov	gs,ax			; point GS to VGA area
        mov	[DisplayPointer],0	; reset display pointer
ScanFrameLoop:
	mov	bx,[ScanLine]		; reset the TIA for a new line
	mov	[TIAScanLine],bx
	mov	bx,offset TIABuffer
	mov	[TIAWritePointer],bx
	mov	dword ptr [bx],-1	;* a dword pointer *

	call	TIALineTo		; generate a raster line

	test	[ScanLine],0fh		; time to check sound buffer ?
	jnz	ScanNextLine		;   no
	call	_Fillbuffer		;   yes, fill sound buffer if necessary

ScanNextLine:
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
;* macro to see if we should do a CPU instruction
;*

TryCPU macro
local Done

	cmp	dl,[CPUClock]	; time for an instruction ?
	jbe	Done		;   no
	DoInstruction		;   yes
Done:
	endm


;*
;* collision test macros
;*

CollisionTest macro
local Done

	movzx	ebx,byte ptr[si]
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

	movzx	ebx,byte ptr[si]	; pick up a byte from TIADisplay
	cmp	bl,2			; looking at background or playfield only?
	jb	BackgroundPFOnly	;   yes
	mov	ax,TIAColTab[ebx*2]	; do collision test
	mov	di,[TIADisplayToColor]	; < preload table pointer
	or	[TIACollide],ax
	mov	bl,[bx + di]		; get high priority color

BackgroundPFOnly:
	mov	di,cx
	mov	ax,word ptr BackgroundColor[ebx*4]	; get color value word
	add	cx,2
	mov	gs:[di],ax
	endm


;*
;* only call this one if playfield clock is a multiple of 4
;*

PlayfieldBit macro
local PFSkip
	
	mov	di,[PFClockToBitTable]
	movzx	bx,dl
	mov	eax,dword ptr [TIA+TIAPf0]
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

	TryCPU

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
;* do 4 real bits
;*

DoReal4 macro

	TryCPU

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

Set4BitsFast macro
	mov	di,cx			; display pointer
	add	cx,8
	mov	gs:[di],eax
	mov	gs:4[di],eax
	endm


FastPlayfieldBit macro op1
local PFSkip, SlowLane, SetPFBit, SetBkBit, FastSetPFBit

	mov	di,[PFClockToBitTable]		; < preload table pointer
	sub	al,dl				; # of color clocks to next object
	movzx	bx,dl				; < preload offset
	cmp	al,4				; at least 4 ?
	mov	eax,[si]			; < pick up next 4 TIA bits
	jb	SlowLane			;   no
	test	eax,eax				; anything set in next 4 TIA bits ?
	jne	SlowLane			;   yes

	mov	ebx,[di + bx]			; playfield bit for this color clock
	add	si,4				; bump TIA pointer
	add	dl,4				; bump color clock

	test	ebx,dword ptr [TIA+TIAPf0]	; setting a playfield bit ?
	mov	eax,[BackgroundColor]		; < preload background color
	jnz	FastSetPFBit			;   yes
	Set4BitsFast				;   no, do 4 background bits
	jmp	op1				; FastExit

FastSetPFBit:
	mov	eax,[PlayfieldColor]
	Set4BitsFast
	jmp	op1
	
SlowLane:
	mov	ebx,[di + bx]
	or	eax,TGPlay*01000000h+TGPlay*010000h+TGPlay*0100h+TGPlay
	test	ebx,dword ptr [TIA+TIAPf0]
	jz	PFSkip
SetPFBit:
	mov	[si],eax
PFSkip:
	endm



;*
;* do 4 real bits
;*

DoRealFast4 macro
local FastExit

	TryCPU

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
;	mov	[ColumnBlank],0
	mov	bx,[ScanLine]
	cmp	bx,[TopLine]		;was 10
	jb	TIANoGenerate
	cmp	bx,[BottomLine]		;was 250
	jae	TIANoGenerate
	cmp	[DisplayPointer],64000
	jae	TIANoGenerate

ALIGN_ENTRY

TIAGenerate:
	mov	si,offset TIADisplay	; playfield write pointer
	mov	bp,offset TIABuffer	; initialise the buffer
	mov	[TIAWritePointer],bp	
	mov	byte ptr TIAClock[bp],TIAEnd

	mov	di,si
	xor	eax,eax
	mov	cx,40
	rep	stosd			; clear the TIA display buffer

	mov	al,24
	call	DoInstructions		; do horizontal blank instructions

	call	TIAInsertObjects	; insert objects from the last line

	xor	dl,dl			; start position
	mov	cx,[DisplayPointer]
	mov	dh,80			; first loop exit at column 80

	mov	di,[TIAPFColorByClock]	; update playfield color
	mov	al,[di]			; clock position 0
	mov	[TIAColourTable+TCTPF],al

	movzx	bx,al
	mov	al,TIA[bx]
	mov	ah,al
	shl	eax,16
	mov	al,TIA[bx]
	mov	ah,al
	mov	[PlayfieldColor],eax	; set up color for FastPlayfieldBit

TIABlankLoop:
	mov	al,ColumnBlank
	cmp	dl,al			; doing column blanking ?
	jae	TIALoop			;   no
	DoBlank4			;   no, do regular
	DoBlank4

TIALoop:
	
	DoRealFast4			;   no, do regular
	DoRealFast4

	cmp	dl,dh
	jne	TIALoop

	cmp	dl,80			; reached middle of playfield?
	je	TIARightBegin		;   yes
	jmp	TIAExit			; not column 80, must be 160 and we're done

TIARightBegin:
	mov	dh,160			; next loop exit at column 160

	mov	di,[TIAPFColorByClock]	; update playfield color
	movzx	bx,dl
	mov	al,[di+bx]
	mov	[TIAColourTable+TCTPF],al

	movzx	bx,al
	mov	al,TIA[bx]
	mov	ah,al
	shl	eax,16
	mov	al,TIA[bx]
	mov	ah,al
	mov	[PlayfieldColor],eax	; set up color for FastPlayfieldBit


; this code doesn't belong in the TIA handler because real TIA can't respond to change
; in real time  (messes up astrblst if it's there)

	mov	ax,offset PFClockToBitReversed
	test	[TIA+TIACtrlPf],1	; reversing the current line ?
	jnz	TIARB1			;    yes, continue
	mov	ax,offset PFClockToBitForward

TIARB1:
	mov	[PFClockToBitTable],ax
	jmp	TIALoop

TIAExit:				; we've finished the line scan...
	mov	[DisplayPointer],cx

TIARet:
	ret

;*
;* do a blank line (outside of display area)
;*

ALIGN_ENTRY

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

.CEND
.DATASEGMENT

ticklets	db	' ticks, ','$'
fps		db	' fps',13,10,'$'

.DEND
.CODESEGMENT

