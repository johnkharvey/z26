;*
;* module entry point
;*

IFDEF module

.data

ModuleReturnAdr	dd	0		; word if small model, dword if medium
ModuleSP	dw	0

.code

global _emulator

_emulator PROC FAR			; near if small model, far if medium

	push	ds			; because "C" program can blow es ...
	pop	es			; ... before we get here (getvect)

	mov	ax,_psp
	mov	psp,ax			; set up PSP for commandline
	pop	ModuleReturnAdr		; save return adr
	mov	ax,sp
	mov	ModuleSP,ax		; save sp (no return adr on stack)
	jmp	start

ModuleReturn:
	mov	ax,ModuleSP
	mov	sp,ax
	push	ModuleReturnAdr
	ret

_emulator ENDP

ENDIF

;*
;* main startup
;*

start:

IFDEF exefile
	mov	ax,_DATA
	mov	ds,ax			;set up data segment
	mov	bx,es
	mov	psp,bx			;save pointer to PSP
	mov	es,ax			;set up extra segment (ES = DS)
ENDIF

	call	SetupSpecial
	call	SetupBanks

	mov	di,offset StartMemory
	mov	cx,offset EndMemory
	sub	cx,di			; # of bytes to clear
	xor	al,al
	rep	stosb			; clear memory

	cmp	[_quiet],0
	jnz	STUP_4
	cmp	[_SoundMode],1		; sound mode 1 (force PC speaker) ?
	je	STUP_4			;   yes
	call	_SetupSoundBlaster
	test	ax,ax			; did user press escape ?
	jnz	ReallyQuit		;   yes

STUP_4:
	call	Reset			; Reset the CPU

	call	_SetupTimer		; put timer in mode 2
	call	TIAGraphicMode		; Switch into VGA mode
	call	SetNewInt9		; Keyboard Handler
	call	JoyCenter		; set joystick center position

	mov	eax,200000
	call	_Delay			; let monitor sync

	call	TIAGraphicMode		; flush twice, it's a long way to Broiler Hut
	mov	eax,800000
	call	_Delay			; let monitor sync

	call	_ProgramDSP		; start DMA

	call	VSync

	call	_GetTime		; start time for frame timer
	mov	[StartTicks],eax

	mov	eax,[_FrameExit]
	mov	[OriginalFrameExit],eax	; remember how many frames for FPS calculation
	inc	[_FrameExit]		; do correct # of loops


;*
;* the main outer loop
;*


xmain:  
	cmp	[OriginalFrameExit],0	; exiting after <n> frames ?
	je	xm1			;   no
	dec	[_FrameExit]		;   yes, decrement counter
	jz	GoTIME			;     zero, exit now

xm1:
	call	ModeXFlipPage		; done rendering, flip page display page

	call	VSync

	call	ScanFrame


; the following kludge is needed for frogpond and congbong only

	cmp	[MXDelayedClear],0	; doing delayed clear to clean up mess in first couple of frames ?
	jz	ClearDone		;   no
	dec	[MXDelayedClear]	;   yes
	call	MXClearMem		; clear mem 

ClearDone:

Paused:	call	[CtrlFn]		; check which keys pressed
	test	[GamePaused],1		; game paused ?
	jz	xmain			;   no, next frame

PausedLoop:
	call	[CtrlFn]		; check which keys pressed
	test	[GamePaused],1		; game paused ?
	jnz	PausedLoop		;   yes
	jmp	xmain			; to next frame



;*
;* shutdown the weird stuff
;*

sd_weird:
	call	_sound_clear		; turn sound off (Soundblaster)
	call	SoundOff		; turn sound off (PC speaker)
	call	TIATextMode		; back to text mode
	call	SetOldInt9		; reset the key handler
	call	_RestoreTimer		; put timer back into mode 3
	call	_RestoreISR		; restore SoundBlaster ISR (if was on)
	ret

;*
;* end of program (escape pressed or bad opcode)
;*

GoTIME:
	call	VSync

	call	_GetTime
	sub	eax,[StartTicks]
	mov	[StopTicks],eax		; how long game took

	call	sd_weird		; shutdown the weird stuff

	call	FramesPerSecond		; output frames per second message

	jmp	Empty

	

GoDOS:
	call	sd_weird		; shutdown the weird stuff

Empty:	call	_kb_hit			; empty the keyboard buffer
	jz	Quit			;   buffer empty
	call	_get_char		; read char
	jmp	Empty

Quit:

IFDEF module
	jmp	ModuleReturn
ENDIF

ReallyQuit:
;	mov	ax,[CFirst]
;	cmp	ax,[OldCFirst]
;	je	RQ1
;	push	ax
;	call	_crlf
;	call	_put_dec
;	call	_crlf
;	call	_ShowChecksum
;	call	_crlf

RQ1:
	mov	ah,04Ch			; and return to MSDOS
	int	MSDOS

;*
;* Do One Frame
;*


ScanFrame:
        mov	[DisplayPointer],0	; reset display pointer
ScanFrameLoop:
	mov	bx,offset TIABuffer
	mov	[TIAWritePointer],bx
	mov	dword ptr [bx],-1	;* a dword pointer *

	call	TIALineTo		; generate a raster line

	test	[ScanLine],0fh		; time to read the time ?
	jnz	ScanNextLine		;   no
	call	_GetTime		;   yes, needed to prevent timer overflow

ScanNextLine:
	inc	[ScanLine]		; Increment the scanline counter
	sub  [RClock],CyclesPerScanLine ; adjust RClock for next line

	test	[VBlank],080h		; discharging capacitors ?
	jnz	ScanBailOut		;   yes
					;   no, put some charge on the capacitors
	test [ChargeCounter],080000000h ; already fully charged ?
	jnz	ScanBailOut		;   yes, don't increment
	inc	dword ptr [ChargeCounter] ;   no, add some charge

ScanBailOut:
	mov	ax,[ScanLine]		; do emergency bail-out test
	cmp	ax,500			; have we done way too many scan lines yet?
	jl	NDret			;   not yet
	inc	[Frame]			;   yes, to the next frame (allow escape to work)
	mov	[ScanLine],1

NDret:  
	mov	eax,[Frame]
	cmp	eax,[PrevFrame]		; have we gone to a new frame ?
	je	ScanFrameLoop		;   not yet
	mov	[PrevFrame],eax		;   yes, mark it as current
	ret				;	 and return

; *****************************************************************************
;
;			       TIA Emulator
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
;* macro to set CPUClock
;*

xSetCPUClock macro
	push	dx
	mov	dl,[RClock]
	mov	dh,[RClock]
	add	dl,dl
	sub	dh,[CPUOffset]
	add	dl,dh
	mov	[CPUClock],dl		; CPUClock = 3 * RClock - CPUOffset
	pop	dx

	endm

SetCPUClock macro
	mov	bl,[RClock]
	mov	bh,[RClock]
	add	bl,bl
	sub	bh,[CPUOffset]
	add	bl,bh
	mov	[CPUClock],bl		; CPUClock = 3 * RClock - CPUOffset

	endm


;*
;* macro to see if we should do a CPU instruction
;*

TryCPU macro
local Done

	cmp	dl,[CPUClock]	; time for an instruction ?
	jbe	Done		;   no
	DoInstruction		;   yes
	SetCPUClock

Done:
	endm


;*
;* do some instructions until RClock >= al
;*


DoInstructions:
	mov	[LastCycle],al		; last cycle to do
	push	dx
	push	di
	push	si
	LoadRegs			; load the CPU registers

InstructionLoop:
	fetch_opcode	ebx		; (fetchzx) get the opcode
	call	[vectors + ebx*2]	; --> do the instruction
	call	[TimerVec]		; clock the RIOT timer

	mov	bh,[LastCycle]
	cmp	[RClock],bh
	jl	InstructionLoop

InstructionsDone:

	SaveRegs			; save the CPU registers
	pop	si
	pop	di
	pop	dx

InsRet:	ret


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
	movzx	ecx,[TIADisplayToColor]	; < preload table pointer
	or	[TIACollide],ax
	mov	bl,[ebx + ecx]		; get high priority color

BackgroundPFOnly:
	mov	ax,word ptr BackgroundColor[ebx*4]	; get color value word
	mov	bx,[DisplayPointer]
	and	ax,word ptr [VBlanking]
	add	[DisplayPointer],2
	mov	gs:[bx],ax
	endm

;*
;* only call this one if playfield clock is a multiple of 4
;*

PlayfieldBit macro
local PFSkip
	
	movzx	ecx,[PFClockToBitTable]
	movzx	ebx,dl
	mov	eax,dword ptr [TIA+TIAPf0]
	test	eax,[ebx + ecx]			; setting a playfield bit ?
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
	cmp	TIAClock[di],dl		
	ja	Done			; if next change clock <= next pf write
Branch:
	mov	bl,TIAReg[di]		;   goto register change handler
	and	ebx,03fh		; only 63 options
	call	[TIARegVector + ebx*2]
        
Skip:	add	di,4			; go on to the next change
	cmp	byte ptr TIAClock[di],TIAInvalid ; if moved onto an invalid
	je	Skip			; skip it.

	cmp	TIAClock[di],dl		; < another change to handle? (pentium opt)
	jbe	Branch			;   yes
Done:
	endm


;*
;* macro to put a blank bit into the display
;*

BlankBit macro
	mov	bx,[DisplayPointer]
	xor	ax,ax
	mov	gs:[bx],ax
	add	[DisplayPointer],2
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
	mov	al,TIAClock[di]
	cmp	al,dl		
	ja	Done			; if next change clock <= next pf write
Branch:
	mov	bl,TIAReg[di]		;   goto register change handler
	and	ebx,03fh		; only 63 options
	call	[TIARegVector + ebx*2]
        
Skip:	add	di,4			; go on to the next change
	mov	al,TIAClock[di]
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
	and	eax,[VBlanking]
	mov	bx,[DisplayPointer]		; display pointer
	add	[DisplayPointer],8
	mov	gs:[bx],eax
	mov	gs:4[bx],eax
	endm


xFastPlayfieldBit macro op1
local PFSkip, SlowLane, SetPFBit, SetBkBit, FastSetPFBit

	movzx	ecx,[PFClockToBitTable]		; < preload table pointer
	sub	al,dl				; # of color clocks to next object
	movzx	ebx,dl				; < preload offset
	cmp	al,4				; at least 4 ?
	mov	eax,[si]			; < pick up next 4 TIA bits
	jb	SlowLane			;   no
	test	eax,eax				; anything set in next 4 TIA bits ?
	jne	SlowLane			;   yes

	mov	ebx,[ecx + ebx]			; playfield bit for this color clock
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
	mov	ebx,[ecx + ebx]
	or	eax,TGPlay*01000000h+TGPlay*010000h+TGPlay*0100h+TGPlay
	test	ebx,dword ptr [TIA+TIAPf0]
	jz	PFSkip
SetPFBit:
	mov	[si],eax
PFSkip:
	endm


FastPlayfieldBit macro op1
local PFSkip, SlowLane, SetPFBit, SetBkBit, FastSetPFBit

	movzx	bx,dl				; < preload offset
	sub	al,dl				; # of color clocks to next object
	add	bx,[PFClockToBitTable]
	cmp	al,4				; at least 4 ?
	mov	eax,[si]			; < pick up next 4 TIA bits
	jb	SlowLane			;   no
	test	eax,eax				; anything set in next 4 TIA bits ?
	jne	SlowLane			;   yes

	mov	ebx,[bx]			; playfield bit for this color clock
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
	mov	ebx,[bx]			; playfield bit for this color clock
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
	mov	ax,[MaxLines]
	imul	ax,320
	cmp	[DisplayPointer],ax	;was 64000
	jae	TIANoGenerate


TIAGenerate:
	call	ModeXNewLine

	mov	si,offset TIADisplay	; playfield write pointer

	mov	di,offset TIADisplay
	xor	eax,eax
	mov	cx,40
	rep	stosd			; clear the TIA display buffer

	mov	di,offset TIABuffer	; initialise the buffer
	mov	[TIAWritePointer],di	
	mov	byte ptr TIAClock[di],TIAEnd

;	call	TIAInsertObjects	; insert objects from the last line

	mov	al,24
	call	DoInstructions		; do horizontal blank instructions
	SetCPUClock

	cmp	[TopLine],65535		; did TIA turn off (VBlanking) ?
	je	TIAFinishNoGenerate	;   yes, stop drawing

	call	TIAInsertObjects	; insert objects from the last line

	xor	dl,dl			; start position
;	mov	cx,[DisplayPointer]
	mov	dh,80			; first loop exit at column 80

	mov	bx,[TIAPFColorByClock]	; update playfield color
	mov	al,[bx]			; clock position 0
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

	movzx	ecx,[TIAPFColorByClock]	; update playfield color
	movzx	ebx,dl
	mov	al,[ecx + ebx]
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
;	mov	[DisplayPointer],cx
	call	ModeXCopyLine

	ret

;*
;* do a blank line (outside of display area)
;*


TIANoGenerate:
	mov	di,offset TIABuffer	; initialise the buffer
	mov	[TIAWritePointer],di	
	mov	byte ptr TIAClock[di],TIAEnd

	mov	al,24
	call	DoInstructions		; do horizontal blank instructions
	SetCPUClock

TIAFinishNoGenerate:
	xor	dl,dl
TIAFinishNoGenerateLoop:
	TryCPU
	add	dl,4
	cmp	dl,160
	jne	TIAFinishNoGenerateLoop

;	mov	al,[CyclesPerLine]
;	call	DoInstructions
;	SetCPUClock

TIAProcessBuffer:
	mov	di,offset TIABuffer	; initialise the buffer
TIABLLoop:
	cmp	byte ptr TIAClock[di],TIAEnd	; check if finished
	je	TIABLExit
	mov	bl,TIAReg[di]		; register to change
	and	bx,03fh			; only 63 options !
	shl	bx,1
	call	TIARegVector2[bx]
	add	di,4
	jmp	TIABLLoop
TIABLExit:
	ret
