;*
;* extern.asm -- z26 externals (external to asm, internal to C program)
;*

EXTRN _CartRom:byte

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

EXTRN _timer:dword
EXTRN _frame:dword
EXTRN _line:word
EXTRN _cycle:byte
EXTRN _BL_Pos:word
EXTRN _M0_Pos:word
EXTRN _M1_Pos:word
EXTRN _P0_Pos:word
EXTRN _P1_Pos:word

EXTRN _BL_Mot:word
EXTRN _M0_Mot:word
EXTRN _M1_Mot:word
EXTRN _P0_Mot:word
EXTRN _P1_Mot:word

EXTRN _P2_R0:word
EXTRN _P2_R1:word
EXTRN _P2_R2:word
EXTRN _P2_R3:word
EXTRN _P2_R4:word
EXTRN _P2_R5:word
EXTRN _P2_R6:word
EXTRN _P2_R7:word

EXTRN _P2_F0:byte
EXTRN _P2_F1:byte
EXTRN _P2_F2:byte
EXTRN _P2_F3:byte
EXTRN _P2_F4:byte
EXTRN _P2_F5:byte
EXTRN _P2_F6:byte
EXTRN _P2_F7:byte

EXTRN _VD0:byte
EXTRN _VD1:byte

EXTRN _ShowRegisters:far
EXTRN _ShowInstruction:far

EXTRN _ShowWeird:far
EXTRN _ShowDeep:far
EXTRN _ShowVeryDeep:far
EXTRN _ShowP2W:far
EXTRN _ShowP2R:far
EXTRN _ShowAdjusted:far
EXTRN _ShowUndocTIA:far
EXTRN _ShowCollision:far
