;*
;* init.asm -- initialize all data in z26 asm modules
;*
;* 09-02-02 -- 32-bit
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

.data

IN_Start label byte			; <-- start clearing hera

;_KeyTable	db	128 dup (?)	; Key pressed table
RiotRam		db	128 dup (?)	; RIOT ram (must be initially zero)
TIA		db 	64 dup (?)	; TIA Registers (also should be zero)
_Ram		db	2048 dup (?)	; extra ram

Frame		dd	1 dup (?)	; Frame Counter
PrevFrame	dd	1 dup (?)	; Previous value frame counter

VBlanking	dd	1 dup (?)	; 0 if vblanking, -1 otherwise
VBlank		db	1 dup (?)	; VBlank flag
VSyncFlag	db	1 dup (?)	; VSync flag

ScanLine	dd	1 dup (?)	; current scan line
OurBailoutLine	dd	1 dup (?)	; initial bailout line
					; we fine tune it if exceeded

TopLine		dd	1 dup (?)	; top line of display
BottomLine	dd	1 dup (?)	; bottom line of display

OldCFirst	dd	1 dup (?)	; remember original CFirst
					; (for homing the display)

GamePaused	db	1 dup (?)	; game paused
WByte		db	1 dup (?)	; byte to write

DisplayPointer	dd	1 dup (?)	; pointer into display RAM

IN_End label byte			; <-- finish clearing here


.code

;*
;* routine to do rep stosb to data segment
;*

rep_stosb:
	cmp	ecx,0
	jz	rs_done

rs_loop:
	mov	[edi],al
	inc	edi
	dec	ecx
	jnz	rs_loop

rs_done:
	ret


;*
;* macro to clear memory
;*

clear_mem macro mem_start, mem_finish

	mov	edi,offset mem_start
	mov	ecx,offset mem_finish
	sub	ecx,edi			; # of bytes to clear
	xor	al,al
	call	rep_stosb		; clear memory

	endm

;*
;* initialize data
;*

InitData:
	clear_mem IN_Start, IN_End

	mov	[OurBailoutLine],1000
	mov	[ScanLine],1
	mov	[VBlanking],-1

;	mov	dword ptr [OldInt9],0
	mov	[CtrlSkipFlag],0

	mov	eax,[_ScreenBuffer]
	mov	[DisplayPointer],eax

	call	_InitCVars
	call	Init_CPU
	call	Init_CPUhand
	call	Init_TIA
	call	Init_Riot
	call	Init_P2
	call	Init_Starpath
	call	Init_Tiasnd
	call	Init_SoundQ

	call	RandomizeRIOTTimer

	ret

