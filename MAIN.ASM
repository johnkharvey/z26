;*
;* main.asm -- main entry point here...
;*
;* 09-02-02 -- 32-bit
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.


.data

ModuleSP	dd	?


.code

PUBLIC _emulator

_emulator:				; near if small model, far if medium
	pushad

     	mov	eax,esp
	mov	[ModuleSP],eax		; save sp (no return adr on stack)

	jmp	start

ModuleReturn:
	mov	eax,[ModuleSP]
	mov	esp,eax

	popad

	ret



;*
;* main startup
;*

start:
	call	InitData		; initialize data
	call	_RecognizeCart		; do special setup for individual carts
	call	SetupBanks
	call	Reset			; Reset the CPU -- must follow SetupBanks
	call	Init_Service
	call	Controls		; check controls before emulation starts

;*
;* the main outer loop
;*

xmain:  
	call	_VSync			; now look for vblank
	call	_ModeXCopyScreen	; copy screenbuffer to video RAM
	call	ScanFrame

Paused:	call	Controls		; check which keys pressed
	test	[GamePaused],1		; game paused ?
	jz	xmain			;   no, next frame

PausedLoop:
	call	Controls		; check which keys pressed
	test	[GamePaused],1		; game paused ?
	jnz	PausedLoop		;   yes
	jmp	xmain			; to next frame


;*
;* Do One Frame
;*

ScanFrame:
	mov	eax,[_ScreenBuffer]	; reset display pointer
	mov	[DisplayPointer],eax
ScanFrameLoop:

	call	nTIALineTo		; generate a raster line

	call	_TestEscExit		; exit if ESC pressed

	inc	[ScanLine]		; Increment the scanline counter
	sub  [RClock],CYCLESPERSCANLINE ; adjust RClock for next line

	test	[VBlank],080h		; discharging capacitors ?
	jnz	ScanBailOut		;   yes
					;	 no, put some charge on the capacitors
	test [ChargeCounter],080000000h ; already fully charged ?
	jnz	ScanBailOut		;   yes, don't increment
	inc  [ChargeCounter]		;   no, add some charge

ScanBailOut:
	mov	eax,[ScanLine]		; do emergency bail-out test
	cmp	eax,[OurBailoutLine]	; too many lines?
	jl	NDret			;   not yet
	mov	eax,[_BailoutLine]	;   yes, sharpen (or loosen) the test
	mov	[OurBailoutLine],eax	

	mov	edx,[_LinesInFrame]
	mov	[_PrevLinesInFrame],edx
        mov     edx,[ScanLine]          ; LinesInFrame is important for
        mov     [_LinesInFrame],edx     ;   calculating the video frame delay
        dec     [_LinesInFrame]         ;   So, we need to do it here too!

DontSharpen:
	inc	[Frame]			; to the next frame
	mov	[ScanLine],1

NDret:
	mov	eax,[Frame]
	cmp	eax,[PrevFrame]		; have we gone to a new frame ?
	je	ScanFrameLoop		;   not yet
        call    BlankBufferEnd          ;   yes, blank screen buffer if anything left
	mov	[PrevFrame],eax		;   yes, mark it as current
	ret				;	 and return

