; init.asm -- initialize all data in z26 asm modules

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
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
TopLine		dw	0		; was 36     top line of display
BottomLine	dw	0		; was 36+200 bottom line of display

OldCFirst	dw	0		; remember original CFirst
					; (for homing the display)

OurBailoutLine	dw	1000		; initial bailout line
					; we fine tune it if exceeded

DefaultCFirst	dw	0ffffh		; recommended start of game
UserCFirst	dw	0ffffh		; remember what user specified (if anything)

InitialMaxLines	dw	204		; for remembering which games are medium and tall					 
MaxLines	dw	204		; max # of lines to scan
					; (gets changed by graphics.asm)

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

; *** stuff that gets shared with "C" program ***
; (gets saved / initialized externally)

PUBLIC _psp
_psp		dw	0		; gets set by calling C program

PUBLIC _Checksum
_Checksum	dd	0		; gets cart checksum

PUBLIC _XChecksum
_XChecksum	dd	0		; gets alternative checksum

PUBLIC _dsp
_dsp		db	0		; do digital signal processing

PUBLIC _VideoMode
_VideoMode	db	0ffh		; default video mode

PUBLIC _CFirst
_CFirst		dw	0ffffh		; <-- gets changed by SetupSpecial
					; (zero has VBlank trigger a new frame)
PUBLIC _SoundMode
_SoundMode	db	0ffh		; sound mode

PUBLIC _IOPortB
_IOPortB	db	00Bh		; IO Port B (switches)

PUBLIC _IOPortA
_IOPortA	db	0FFh		; IO Port A (joystick)

PUBLIC _DoChecksum
_DoChecksum	db	0		; set if we should print out checksum

PUBLIC _NoRetrace
_NoRetrace	db	0		; don't wait for retrace (if 0ffh) otherwise framerate

PUBLIC _FrameExit
_FrameExit	dd	0		; do this many frames and exit

PUBLIC _Joystick
_Joystick	db	1		; do joystick

PUBLIC _quiet
_quiet		db	0		; set if we want no sound

PUBLIC _PaletteNumber
_PaletteNumber	db	0ffh		; gets set by cmdline.asm

PUBLIC _PaddleGame
_PaddleGame	dd	0		; this is a paddle game (sensitivity)

PUBLIC _KeyBase
_KeyBase	db	0ffh		; which paddle to emulate

PUBLIC _CartSize
_CartSize	dw	0		; gets cart size (cmdline.asm)

PUBLIC _TraceCount
_TraceCount	db	0		; gets trace count

PUBLIC _TraceEnabled
_TraceEnabled	db	0		; if trace is enabled

PUBLIC _OldTraceCount
_OldTraceCount	db	0		; for saving trace count if we turn off tracing

PUBLIC _Use50Hz
_Use50Hz	db	0		; O.K. to use 50Hz video modes


; *** new stuff ***

InTextMode	db	0		; in text mode (TIATextMode -- graphics.asm)
BlasterLoopCount dd	0		; count # of trys initting the soundblaster
					; (sbdrv.asm)

.code

InitData:
	call	Init_CPU
	call	Init_TIA
	call	Init_Riot
	call	Init_P2
	call	Init_Starpath

	mov	[OurBailoutLine],1000


	mov	[BlasterLoopCount],0
	mov	[InTextMode],0

	mov	[Frame],0
	mov	[PrevFrame],0
	mov	[OriginalFrameExit],0
	mov	[StartTicks],0
	mov	[StopTicks],0
	mov	[ScanLine],1

	mov	[OldCFirst],0
	mov	[DefaultCFirst],0ffffh
	mov	[UserCFirst],0ffffh
	mov	[InitialMaxLines],204
	mov	[MaxLines],204

	mov	[DisplayPointer],0
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

	ret

