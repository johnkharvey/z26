; init.asm -- initialize all data in z26 asm modules

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

.data

ALIGN 2

Frame		dd	0		; Frame Counter
PrevFrame	dd	0		; Previous value frame counter

OriginalFrameExit dd	0		; save it here for FPS calculation
StartTicks	dd	0		; ticks at start
StopTicks	dd	0		; ticks at finish

ScanLine	dw	1		; current scan line
TopLine		dw	0		; was 36	    top line of display
BottomLine	dw	0		; was 36+200 bottom line of display

OldCFirst	dw	0		; remember original CFirst
					; (for homing the display)

OurBailoutLine	dw	1000		; initial bailout line
					; we fine tune it if exceeded

;DefaultCFirst	dw	0ffffh		; recommended start of game
;UserCFirst	dw	0ffffh		; remember what user specified (if anything)

DisplayPointer	dw	0		;pointer into display RAM

GamePaused	db	0		; game paused

WByte		db	0		; byte to write

ALIGN 2

TIACollide	dw	0		; Collision flag word.

psp		dw	0		; gets pointer to PSP 
					; (if .EXE file or module)

ALIGN 2
; *** cpuhand.asm ***

VBlanking	dd	-1		; 0 if vblanking, -1 otherwise
VBlank		db	0		; VBlank flag
VSyncFlag	db	0		; VSync flag

;*** keep these in order ***

DumpPorts	db	0,0,0,0		; Input ports (inp0..3)

InputLatch	db	080h		; Input latch (inp4)
		db	080h		; Input latch (inp5)

ALIGN 2

; *** new stuff ***

BlasterLoopCount dd	0		; count # of trys initting the soundblaster
					; (sbdrv.asm)

.code

InitData:
	call	_InitCVars

	call	Init_CPU
	call	Init_TIA
	call	Init_Riot
	call	Init_P2
	call	Init_Starpath

	mov	[OurBailoutLine],1000


	mov	[BlasterLoopCount],0

	mov	[Frame],0
	mov	[PrevFrame],0
	mov	[OriginalFrameExit],0
	mov	[StartTicks],0
	mov	[StopTicks],0
	mov	[ScanLine],1

	mov	[OldCFirst],0
;	mov	[DefaultCFirst],0ffffh
;	mov	[UserCFirst],0ffffh

	mov	[GamePaused],0
	mov	[WByte],0

	mov	[TIACollide],0

	mov	[VBlanking],-1
	mov	[VBlank],0
	mov	[VSyncFlag],0
	mov	dword ptr [DumpPorts],0
	mov	word ptr [InputLatch],08080h

	mov	dword ptr [OldInt9],0
	mov	[CtrlSkipFlag],0

        mov     ax,[_ScreenOfs]
        mov     [DisplayPointer],ax

	ret

