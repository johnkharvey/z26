;*
;* extern.asm -- z26 externals (external to asm, internal to C program)
;*

extern emu_pixels	; dword
extern emu_pixels_prev	; dword

extern ResetEmulator ; dword
extern tiawidth ; dword
extern srv_SetPalette ; dword
extern ClearScreenBuffers ; dword
extern CreateScreen ; dword
extern position_game ; dword
extern SQ_byte ; byte
extern Init_SoundQ ; dword
extern SQ_resample ; dword
extern SQ_Test ; dword
extern SQ_Store ; dword
extern SyncToSoundBuffer; dword

extern TopLine ; dword
extern BottomLine ; dword
extern srv_SetVideoMode ; near

extern CartRom  ; byte
extern ScreenBuffer  ; dword
extern SoundQ  ; byte
extern SQ_Max  ; dword
extern CartSize  ; dword
extern VideoMode  ; byte
extern CFirst  ; dword
extern quiet  ; byte
extern IOPortA  ; byte
extern IOPortA_Controllers  ; byte
extern IOPortA_UnusedBits  ; byte
extern IOPortB  ; byte
extern dsp  ; byte
;extern Joystick  ; byte
extern PaletteNumber  ; byte
;extern KeyBase  ; byte
extern TraceCount  ; byte
extern TraceEnabled  ; byte
extern OldTraceCount  ; byte
;extern KeyPad  ; byte
;extern Driving  ; byte
extern BSType  ; dword
;extern MouseBase  ; byte
extern SimColourLoss  ; byte
extern Lightgun  ; byte
extern LGadjust  ; dword
;extern Mindlink  ; byte
extern AllowAll4  ; byte
extern KidVid  ; byte
extern KidVidTape  ; byte
extern SampleByte  ; byte
extern kv_TapeBusy  ; dword
extern LinesInFrame  ; dword	; *EST*
extern PrevLinesInFrame  ; dword
extern VBlankOn  ; dword
extern VBlankOff  ; dword
extern BailoutLine  ; dword
extern MaxLines  ; dword
extern UserPaletteNumber  ; byte
extern GamePaletteNumber	;byte
extern SC_StartAddress  ; dword
extern SC_ControlByte  ; byte
extern p0_mask         ; byte
extern p1_mask         ; byte
extern m0_mask         ; byte
extern m1_mask         ; byte
extern bl_mask         ; byte
extern pf_mask        ; byte

;dw cpu_pc;
;db cpu_a, cpu_carry, cpu_x, cpu_y, cpu_sp;
;db cpu_ZTest, cpu_NTest, cpu_D, cpu_V, cpu_I, cpu_B;
extern cpu_pc  ; dword
extern cpu_a  ; byte
extern cpu_carry  ; byte
extern cpu_x  ; byte
extern cpu_y  ; byte
extern cpu_sp  ; byte
extern cpu_ZTest  ; byte
extern cpu_NTest  ; byte
extern cpu_D  ; byte
extern cpu_V  ; byte
extern cpu_I  ; byte
extern cpu_B  ; byte
extern cpu_MAR  ; dword
extern cpu_Rbyte  ; byte
extern frame  ; dword
extern line  ; dword
extern cycle  ; byte
extern BL_Pos  ; dword
extern M0_Pos  ; dword
extern M1_Pos  ; dword
extern P0_Pos  ; dword
extern P1_Pos  ; dword
extern InitCVars  ; near
extern ShowRegisters  ; near
extern ShowInstruction  ; near
extern ShowWeird  ; near
extern ShowDeep  ; near
extern ShowVeryDeep  ; near
extern ShowAdjusted  ; near
extern ShowUndocTIA  ; near
extern ShowCollision  ; near
extern ShowSCWrite  ; near
extern cli_LoadNextStarpath  ; near
extern cli_ReloadStarpath  ; near
extern KoolAide  ; byte
extern RSBoxing  ; byte
extern DefaultCFirst  ; dword
extern MPdirection  ; byte
extern MinVol  ; byte
extern LG_WrapLine  ; byte
extern RecognizeCart  ; near
extern kv_OpenSampleFile  ; near
extern kv_CloseSampleFile  ; near
extern kv_GetNextSampleByte  ; near
extern kv_SetNextSong  ; near
extern MessageCode  ; byte
extern srv_CopyScreen  ; near
extern srv_Events  ; near
extern srv_Flip  ; near
extern srv_done  ; byte
extern KeyTable  ; byte
extern srv_get_mouse_movement  ; near
; extern srv_get_mouse_button_status  ; near
extern srv_mouse_button  ; dword
extern srv_micky_x  ; dword
extern srv_micky_y  ; dword
extern screen_pixels  ; dword
extern srv_sound_on  ; near
extern srv_sound_off  ; near
extern DMABuf  ; dword
extern bufsize  ; dword
extern ChargeTrigger0  ; dword
;EXTRN _ChargeTrigger1:dword
;EXTRN _ChargeTrigger2:dword
;EXTRN _ChargeTrigger3:dword
extern ChargeCounter  ; dword
;extern DumpPorts  ; byte
extern InputLatch  ; byte
extern CM_Collumn  ; byte
extern ExitEmulator  ; byte
extern GamePaused  ; byte
extern OldCFirst  ; dword
extern Controls  ; near
extern InitCompuMate  ; near
extern ControlSWCHAWrite  ; near
extern TestLightgunHit  ; near
extern UpdateTrakBall  ; near
extern Seconds  ; dword

; from init.asm

extern RiotRam ; byte
extern TIA ; byte
extern Ram ; byte
extern Frame ; dword
extern PrevFrame ; dword
extern VBlanking ; dword
extern VBlank ; byte
extern VSyncFlag ; byte
extern ScanLine ; dword
extern OurBailoutLine ; dword
extern WByte ; byte
extern DisplayPointer ; dword


; z26 is Copyright 1997-2011 by John Saeger and contributors.  
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.
