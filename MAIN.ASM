;*
;* main.asm -- main entry point here...
;*


IFDEF module

.data

ModuleReturnAdr	dd	?		; word if small model, dword if medium
ModuleSP	dw	?

.code

global _emulator

_emulator PROC FAR			; near if small model, far if medium

	push	ds			; because "C" program can blow es ...
	pop	es			; ... before we get here (getvect)

	mov	ax,_psp
	mov	psp,ax			; set up PSP for commandline
	pop	ModuleReturnAdr		; save return adr

	pushad

	mov	ax,sp
	mov	[ModuleSP],ax		; save sp (no return adr on stack)

	jmp	start

ModuleReturn:
	push	ds
	pop	es
	mov	ax,[ModuleSP]
	mov	sp,ax

	popad

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

	call	InitData		; initialize data

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

	call	TIASaveVideoMode
	call	VSync

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
	call	VS_PreGap		; this is how we ignore false triggers
	call	VSync			; now look for vblank

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
;	call	TIATextMode		; back to text mode
	call	TIARestoreVideoMode
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


