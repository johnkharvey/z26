;*
;* main.asm -- main entry point here...
;*
;* 2002-09-02 -- 32-bit
;*


[section .data]

ModuleSP	dd	0


[section .code]
global z_emulator

z_emulator:				;  near if small model, far if medium
	pushad

     	mov	eax,esp
 	mov	dword [ModuleSP],eax	; save sp (no return adr on stack)

	jmp	start

ModuleReturn:
 	mov	eax,dword [ModuleSP]
	mov	esp,eax

	popad

	ret



;*
;* main startup
;*

start:
	mov	dword [ResetEmulator],0
	call	InitData		;  initialize data (C)
	call	RecognizeCart		;  do special setup for individual carts (C)
	call	SetupBanks		; (asm)
	call	Reset			;  Reset the CPU -- must follow SetupBanks (asm)
;	mov	dword [tiawidth],160
	call	Init_Service		; (C)
;	mov	dword [tiawidth],320
	call	Controls		;  check controls before emulation starts (C)
	
	test	byte [ResetEmulator],1	; "reboot" the emu?
	jnz	near start		;   yes

;*
;* the main outer loop
;*

xmain:	mov	dword [tiawidth],160
	call	ScanFrame
	pushad
	call	Controls		; paint the lightgun cursor before copy
	popad
	call	srv_CopyScreen
	mov	dword [tiawidth],320
	call	VSync

 	test	byte [GamePaused],1	; game paused ?
	jz near xmain			;    no, next frame
	test	byte [ResetEmulator],1	; "reboot" the emu?
	jnz	near start		;   yes

PausedLoop:
	pushad
	call	Controls		;  check which keys pressed
	popad
 	test	byte [GamePaused],1	; game paused ?
	jnz near PausedLoop		;    yes
	test	byte [ResetEmulator],1	; "reboot" the emu?
	jnz	near start		;   yes
	jmp	xmain			;  to next frame


;*
;* Do One Frame
;*

ScanFrame:
 	mov	eax,dword [ScreenBuffer] ; reset display pointer
 	mov	dword [DisplayPointer],eax
ScanFrameLoop:

	call	nTIALineTo		;  generate a raster line

	call	TestEscExit		;  exit if ESC pressed

 	inc	dword [ScanLine]	; Increment the scanline counter
 	sub  byte [RClock],CYCLESPERSCANLINE ; adjust RClock for next line

 	test	byte [VBlank],080h	; discharging capacitors ?
	jnz near ScanBailOut		;    yes
					; 	 no, put some charge on the capacitors
 	test dword [ChargeCounter],080000000h ; already fully charged ?
	jnz near ScanBailOut		;    yes, don't increment
 	inc  dword [ChargeCounter]	; no, add some charge

ScanBailOut:
 	mov	eax,dword [ScanLine]	; do emergency bail-out test
 	cmp	eax,dword [OurBailoutLine] ; too many lines?
	jl near NDret			;    not yet
 	mov	eax,dword [BailoutLine] ; yes, sharpen (or loosen) the test
 	mov	dword [OurBailoutLine],eax	

 	mov	edx,dword [LinesInFrame]
 	mov	dword [PrevLinesInFrame],edx
        mov     edx,dword [ScanLine]	; LinesInFrame is important for
        mov     dword [LinesInFrame],edx ; calculating the video frame delay
        dec     dword [LinesInFrame]	; So, we need to do it here too!

DontSharpen:
 	inc	dword [Frame]		; to the next frame
 	mov	dword [ScanLine],1

NDret:
 	mov	eax,dword [Frame]
 	cmp	eax,dword [PrevFrame]	; have we gone to a new frame ?
	je near ScanFrameLoop		;    not yet
        call    BlankBufferEnd          ;    yes, blank screen buffer if anything left
 	mov	dword [PrevFrame],eax	; yes, mark it as current
	ret				; 	 and return


; z26 is Copyright 1997-2011 by John Saeger and contributors.  
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.
