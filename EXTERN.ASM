;*
;* extern.asm -- z26 externals (external to asm, internal to C program)
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

EXTRN _CartRom:byte
EXTRN _MBseg:word
EXTRN _MBofs:word

EXTRN _psp:word
EXTRN _CartSize:word
EXTRN _Checksum:dword
EXTRN _XChecksum:dword
EXTRN _VideoMode:byte
EXTRN _CFirst:word
EXTRN _quiet:byte
EXTRN _SoundMode:byte
EXTRN _IOPortA:byte
EXTRN _IOPortB:byte
EXTRN _DoChecksum:byte
EXTRN _NoRetrace:byte
EXTRN _FrameExit:dword
EXTRN _dsp:byte
EXTRN _Joystick:byte
EXTRN _PaletteNumber:byte
EXTRN _PaddleGame:dword
EXTRN _KeyBase:byte
EXTRN _TraceCount:byte
EXTRN _TraceEnabled:byte
EXTRN _OldTraceCount:byte
EXTRN _Use50Hz:byte
EXTRN _KeyPad:byte
EXTRN _Driving:byte
EXTRN _BSType:byte
EXTRN _MouseBase:byte
EXTRN _SimColourLoss:byte
EXTRN _Lightgun:byte
EXTRN _LGadjust:word

EXTRN _LinesInFrame:word	; *EST*
EXTRN _PrevLinesInFrame:word
EXTRN _VBlankOn:word
EXTRN _VBlankOff:word
EXTRN _BailoutLine:word
EXTRN _MaxLines:word
EXTRN _UserPaletteNumber:byte

EXTRN _SC_StartAddress:word
EXTRN _SC_ControlByte:byte

EXTRN _DelayTime:dword
EXTRN _InTextMode:byte


;dw cpu_pc;
;db cpu_a, cpu_carry, cpu_x, cpu_y, cpu_sp;
;db cpu_ZTest, cpu_NTest, cpu_D, cpu_V, cpu_I, cpu_B;

EXTRN _cpu_pc:word
EXTRN _cpu_a:byte
EXTRN _cpu_carry:byte
EXTRN _cpu_x:byte
EXTRN _cpu_y:byte
EXTRN _cpu_sp:byte
EXTRN _cpu_ZTest:byte
EXTRN _cpu_NTest:byte
EXTRN _cpu_D:byte
EXTRN _cpu_V:byte
EXTRN _cpu_I:byte
EXTRN _cpu_B:byte

EXTRN _cpu_MAR:word
EXTRN _cpu_Rbyte:byte

EXTRN _frame:dword
EXTRN _line:word
EXTRN _cycle:byte

EXTRN _BL_Pos:word
EXTRN _M0_Pos:word
EXTRN _M1_Pos:word
EXTRN _P0_Pos:word
EXTRN _P1_Pos:word

EXTRN _adr:word
EXTRN _prevadr:word

EXTRN _InitCVars:far

EXTRN _ShowRegisters:far
EXTRN _ShowInstruction:far

EXTRN _ShowWeird:far
EXTRN _ShowDeep:far
EXTRN _ShowVeryDeep:far
EXTRN _ShowAdjusted:far
EXTRN _ShowUndocTIA:far
EXTRN _ShowCollision:far
EXTRN _Showaddress:far
EXTRN _ShowSCWrite:far

EXTRN _cli_LoadNextStarpath:far
EXTRN _cli_ReloadStarpath:far

EXTRN _KoolAide:byte
EXTRN _RSBoxing:byte
EXTRN _TIAZero:byte
EXTRN _UserCFirst:word
EXTRN _DefaultCFirst:word
EXTRN _MPdirection:byte
EXTRN _MinVol:byte
EXTRN _LG_WrapLine:byte

EXTRN _RecognizeCart:far
