;*
;* extern.asm -- z26 externals (external to asm, internal to C program)
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

EXTRN _CartRom:byte
EXTRN _ScreenBuffer:dword

EXTRN _PCXPalette:byte

EXTRN _SoundQ:byte
EXTRN _SQ_Max:dword

EXTRN _CartSize:dword
EXTRN _Checksum:dword
EXTRN _XChecksum:dword
EXTRN _VideoMode:byte
EXTRN _CFirst:dword
EXTRN _quiet:byte
EXTRN _IOPortA:byte
EXTRN _IOPortA_Controllers:byte
EXTRN _IOPortA_UnusedBits:byte
EXTRN _IOPortB:byte
EXTRN _DoChecksum:byte
EXTRN _dsp:byte
EXTRN _Joystick:byte
EXTRN _PaletteNumber:byte
EXTRN _KeyBase:byte
EXTRN _TraceCount:byte
EXTRN _TraceEnabled:byte
EXTRN _OldTraceCount:byte
EXTRN _KeyPad:byte
EXTRN _Driving:byte
EXTRN _BSType:dword
EXTRN _MouseBase:byte
EXTRN _SimColourLoss:byte
EXTRN _Lightgun:byte
EXTRN _LGadjust:dword
EXTRN _Mindlink:byte
EXTRN _AllowAll4:byte
EXTRN _EnableFastCopy:byte
EXTRN _KidVid:byte
EXTRN _KidVidTape:byte
EXTRN _SampleByte:byte
EXTRN _kv_TapeBusy:dword

EXTRN _LinesInFrame:dword	; *EST*
EXTRN _PrevLinesInFrame:dword
EXTRN _VBlankOn:dword
EXTRN _VBlankOff:dword
EXTRN _BailoutLine:dword
EXTRN _MaxLines:dword
EXTRN _UserPaletteNumber:byte

EXTRN _SC_StartAddress:dword
EXTRN _SC_ControlByte:byte

;dw cpu_pc;
;db cpu_a, cpu_carry, cpu_x, cpu_y, cpu_sp;
;db cpu_ZTest, cpu_NTest, cpu_D, cpu_V, cpu_I, cpu_B;

EXTRN _cpu_pc:dword
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

EXTRN _cpu_MAR:dword
EXTRN _cpu_Rbyte:byte

EXTRN _frame:dword
EXTRN _line:dword
EXTRN _cycle:byte

EXTRN _BL_Pos:dword
EXTRN _M0_Pos:dword
EXTRN _M1_Pos:dword
EXTRN _P0_Pos:dword
EXTRN _P1_Pos:dword

EXTRN _InitCVars:near

EXTRN _ShowRegisters:near
EXTRN _ShowInstruction:near

EXTRN _ShowWeird:near
EXTRN _ShowDeep:near
EXTRN _ShowVeryDeep:near
EXTRN _ShowAdjusted:near
EXTRN _ShowUndocTIA:near
EXTRN _ShowCollision:near
EXTRN _ShowSCWrite:near

EXTRN _cli_LoadNextStarpath:near
EXTRN _cli_ReloadStarpath:near

EXTRN _KoolAide:byte
EXTRN _RSBoxing:byte
EXTRN _UserCFirst:dword
EXTRN _DefaultCFirst:dword
EXTRN _MPdirection:byte
EXTRN _MinVol:byte
EXTRN _LG_WrapLine:byte

EXTRN _RecognizeCart:near

EXTRN _PCXWriteFile:near

EXTRN _kv_OpenSampleFile:near
EXTRN _kv_CloseSampleFile:near
EXTRN _kv_GetNextSampleByte:near
EXTRN _kv_SetNextSong:near

EXTRN _GeneratePalette:near

EXTRN _MessageCode:byte

EXTRN _srv_CreateScreen:near
EXTRN _srv_WindowScreen:near
EXTRN _srv_DestroyScreen:near
EXTRN _srv_CopyScreen:near
EXTRN _srv_Events:near
EXTRN _srv_Flip:near

EXTRN _srv_done:byte

EXTRN _KeyTable:byte

EXTRN _srv_get_mouse_movement:near
EXTRN _srv_get_mouse_button_status:near

EXTRN _srv_mouse_button:dword
EXTRN _srv_micky_x:dword
EXTRN _srv_micky_y:dword

EXTRN _emu_pixels:dword
EXTRN _screen_pixels:dword
EXTRN _emu_pixels_prev:dword

EXTRN _srv_SetPalette:near

EXTRN _srv_sound_on:near
EXTRN _srv_sound_off:near
EXTRN _DMABuf:dword
EXTRN _bufsize:dword
EXTRN _srv_lock_audio:near
EXTRN _srv_unlock_audio:near

EXTRN _ClearScreenBuffers:near

EXTRN _NoRetrace:dword

EXTRN _SyncToSoundBuffer:byte

EXTRN _ChargeTrigger0:dword
;EXTRN _ChargeTrigger1:dword
;EXTRN _ChargeTrigger2:dword
;EXTRN _ChargeTrigger3:dword

EXTRN _ChargeCounter:dword

EXTRN _DumpPorts:byte
EXTRN _InputLatch:byte

EXTRN _CM_Collumn:byte

EXTRN _ExitEmulator:byte
EXTRN _GamePaused:byte

EXTRN _OldCFirst:dword

EXTRN _Controls:near
EXTRN _InitCompuMate:near
EXTRN _ControlSWCHAWrite:near
EXTRN _TestLightgunHit:near
EXTRN _UpdateTrakBall:near
