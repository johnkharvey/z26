; init.asm -- initialize all data in z26 asm modules

.data

; *** data.asm ***

ALIGN 2

; *** keep next 4 variables in order !!!!
; they are arranged to match the order of the entries in TIAColourTable

BackgroundColor	dd	0
PlayfieldColor	dd	0
Player1Color	dd	0
Player0Color	dd	0
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

DefaultCFirst	dw	0ffffh		; recommended start of game
UserCFirst	dw	0ffffh		; remember what user specified (if anything)

InitialMaxLines	dw	204		; for remembering which games are medium and tall					 
MaxLines	dw	204		; max # of lines to scan
					; (gets changed by graphics.asm)

DisplayPointer	dw	0		;pointer into display RAM

ColumnBlank	db	0		; blank this many columns
GamePaused	db	0		; game paused
NoScoreMode	db	0		; set if we don't want PF to take on player colors
CPUOffset	db	66		; 64 default offset for CPU clock
CPUClock	db	0
WrapZero	db	0		; wrap negative player pos to zero
WrapWsync	db	0		; push late Wsyncs to next line
OldMissile	db	0		; use old missile code for resmpx

WByte		db	0		; byte to write

ALIGN 2

VDP0Gr		db	0		; Buffer for Player 0 Vert Del Graphic
VDP1Gr		db	0		; Buffer for Player 1 Vert Del Graphic
VDBlEn		db	0		; Buffer for Ball Vertical Delay Enable

TIAWritePointer dw	0		; Write to TIA Buffer pointer
TIAReadPointer	dw	0		; Read from TIA Buffer pointer
TIACollide	dw	0		; Collision flag word.

psp		dw	0		; gets pointer to PSP 
					; (if .EXE file or module)

ALIGN 2
; *** banks.asm ***

ReadBank	dw	RBank4		; R/W vectors -- default to 4K cart
WriteBank	dw	WBank4
        
RomBank		dw	0		; Rom bank pointer for F8 & F16

; Parker Brother's ROM Slices

PBSlice0	dw	0
PBSlice1	dw	1*400h
PBSlice2	dw	2*400h
PBSlice3	dw	7*400h		; this one doesn't change
					; points to 1K bank #7
; Tigervision ROM Slices

TVSlice0	dw	0
TVSlice1	dw	3*800h		; this one doesn't change
					; points to 2K bank #3
; M-Network ROM Slices

MNSlice0	dw	0
MNSlice1	dw	7*800h		; this one doesn't change
					; points to 2K bank #3

; M-Network RAM Slices

MNRamSlice	dw	0		; which 256 byte ram slice


; *** trace.asm ***

trace_count	dd	0	; nonzero if tracing


; *** cpu.asm ***

reg_pc		dw	0		; program counter (stored in DI)

; the following two locations must be in this order and next to each other

reg_a		db	0		; accumulator (stored in AL)
flag_carry	db	0		; carry bit   (stored in AH)

; the following two locations are padded with an extra byte 
; to allow 16-bit access (see _index)

reg_x		db	0		; x register
		db	0
reg_y		db	0		; y register
		db	0

reg_sp		db	0		; stack pointer

; a value is stored in the following vars for later testing

RZTest		db	0		; zero test value (Z set when 0)
RNTest		db	0		; sign test value (N set when negative)

; these vars hold the values of flags other than Z and N

flag_D		db	0		; decimal flag
flag_V		db	0		; overflow flag
flag_I		db	0		; interrupt disable flag
flag_B		db	0		; break flag

; some temporaries for use by decimal arith and ARR

_value		db	0
_reg_a		db	0
_flag_carry	db	0

ALIGN 2

RClock		db	0		; clock cycles
RCycles		db	0		; cycles for this instruction

LastCycle	db	0		; for DoInstructions


; *** cpuhand.asm ***

VBlanking	dd	-1		; 0 if vblanking, -1 otherwise
VBlank		db	0		; VBlank flag
VSyncFlag	db	0		; VSync flag

Ret0F		db	0Fh
RetWd		db	0		; byte returned from collision read

;*** keep these in order ***

DumpPorts	db	0,0,0,0		; Input ports (inp0..3)

InputLatch	db	080h		; Input latch (inp4)
		db	080h		; Input latch (inp5)

ALIGN 2

; *** joy.asm ***

JH1			dw	0
JH2			dw	0
JH3			dw	0
JH4			dw	0

JV1			dw	0
JV2			dw	0
JV3			dw	0
JV4			dw	0

JoyHorizontalCenter	dw	0
JoyVerticalCenter	dw	0

JoyLeft			dw	0
JoyRight		dw	0
JoyUp			dw	0
JoyDown			dw	0

DoJoystick		db	1


; *** keyboard.asm ***

OldInt9		dw	0,0	; old vector for int9

CtrlSkipFlag	db	0	; skip this control key test


ALIGN 2
; *** riot.asm ***

Timer		dd	0		; the RIOT Timer
TimerFudge	dd	0		; fudge timer by this amount (frogpond)
TimerVec	dw	Timer1		; timer vector -- Timer0 for espial (why??)
TimerReadVec	dw	ReadTimer1	; timer read vector
TimerByte	db	0		; a return value
TimerIntReg	db	080h		; Timer Interrupt Register
RetFF		db	0FFh


; *** stuff that gets shared with "C" program ***
; (gets saved / initialized externally)

global _psp
_psp		dw	0		; gets set by calling C program

global _Checksum
_Checksum	dd	0		; gets cart checksum

global _dsp
_dsp		db	0		; do digital signal processing

global _VideoMode
_VideoMode	db	0ffh		; default video mode

global _CFirst
_CFirst		dw	0ffffh		; <-- gets changed by SetupSpecial
					; (zero has VBlank trigger a new frame)
global _SoundMode
_SoundMode	db	0ffh		; sound mode

global _IOPortB
_IOPortB	db	00Bh		; IO Port B (switches)
IOPortA		db	0FFh		; IO Port A (joystick)

global _DoChecksum
_DoChecksum	db	0		; set if we should print out checksum

global _NoRetrace
_NoRetrace	db	0		; don't wait for retrace (if 0ffh) otherwise framerate

global _FrameExit
_FrameExit	dd	0		; do this many frames and exit

global _Joystick
_Joystick	db	1		; do joystick

global _quiet
_quiet		db	0		; set if we want no sound

global _PaletteNumber
_PaletteNumber	db	0ffh		; gets set by cmdline.asm

global _PaddleGame
_PaddleGame	dd	0		; this is a paddle game (sensitivity)

global _KeyBase
_KeyBase	db	0ffh		; which paddle to emulate

global _CartSize
_CartSize	dw	0		; gets cart size (cmdline.asm)


; *** new stuff ***

InTextMode	db	0		; in text mode (TIATextMode -- graphics.asm)
BlasterLoopCount dd	0		; count # of trys initting the soundblaster
					; (sbdrv.asm)

.code

InitData:
	mov	[BlasterLoopCount],0
	mov	[InTextMode],0

	mov	[BackgroundColor],0
	mov	[PlayfieldColor],0
	mov	[Player1Color],0
	mov	[Player0Color],0
	mov	[Frame],0
	mov	[PrevFrame],0
	mov	[OriginalFrameExit],0
	mov	[StartTicks],0
	mov	[StopTicks],0
	mov	[ScanLine],1
	mov	[TopLine],0
	mov	[BottomLine],0
	mov	[OldCFirst],0
	mov	[DefaultCFirst],0ffffh
	mov	[UserCFirst],0ffffh
	mov	[InitialMaxLines],204
	mov	[MaxLines],204
	mov	[DisplayPointer],0
	mov	[ColumnBlank],0
	mov	[GamePaused],0
	mov	[NoScoreMode],0
	mov	[CPUOffset],66
	mov	[WrapZero],0
	mov	[WrapWsync],0
	mov	[OldMissile],0
	mov	[WByte],0
	mov	[VDP0Gr],0
	mov	[VDP1Gr],0
	mov	[VDBlEn],0
	mov	[TIAWritePointer],0
	mov	[TIAReadPointer],0
	mov	[TIACollide],0
;	mov	[psp],0

	mov	[ReadBank], offset RBank4
	mov	[WriteBank], offset WBank4
	mov	[RomBank],0
	mov	[PBSlice0],0
	mov	[PBSlice1],1*400h
	mov	[PBSlice2],2*400h
	mov	[PBSlice3],7*400h
	mov	[TVSlice0],0
	mov	[TVSlice1],3*800h
	mov	[MNSlice0],0
	mov	[MNSlice1],7*800h
	mov	[MNRamSlice],0

	mov	[trace_count],0

	mov	[reg_pc],0
	mov	[reg_a],0
	mov	[flag_carry],0
	mov	word ptr [reg_x],0
	mov	word ptr [reg_y],0
	mov	[reg_sp],0
	mov	[RZTest],0
	mov	[RNTest],0
	mov	[flag_D],0
	mov	[flag_V],0
	mov	[flag_I],0
	mov	[flag_B],0
	mov	[_value],0
	mov	[_reg_a],0
	mov	[_flag_carry],0
	mov	[RClock],0
	mov	[RCycles],0
	mov	[LastCycle],0

	mov	[VBlanking],-1
	mov	[VBlank],0
	mov	[VSyncFlag],0
	mov	[Ret0F],0fh
	mov	[RetWd],0
	mov	dword ptr [DumpPorts],0
	mov	word ptr [InputLatch],08080h

	mov	[JH1],0
	mov	[JH2],0
	mov	[JH3],0
	mov	[JH4],0
	mov	[JV1],0
	mov	[JV2],0
	mov	[JV3],0
	mov	[JV4],0
	mov	[JoyHorizontalCenter],0
	mov	[JoyVerticalCenter],0
	mov	[JoyLeft],0
	mov	[JoyRight],0
	mov	[JoyUp],0
	mov	[JoyDown],0
	mov	[DoJoystick],1

	mov	dword ptr [OldInt9],0
	mov	[CtrlSkipFlag],0

	mov	[Timer],0
	mov	[TimerFudge],0
	mov	[TimerVec], offset Timer1
	mov	[TimerReadVec], offset ReadTimer1
	mov	[TimerByte],0
	mov	[TimerIntReg],080h
	mov	[RetFF],0ffh

	ret

