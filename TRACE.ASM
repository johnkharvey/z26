; trace.asm -- z26 trace stuff

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-04-02 -- 32-bit


.data

debugflag	db	0

.code

;*
;* trace routines
;*
;* so trace code written in C can access the assembler language machinery
;*

PUBLIC _ReallyReadROM

_ReallyReadROM:
	pushad
	mov	esi,[_cpu_MAR]

	mov	[debugflag],1
	mov	eax, [_BSType]
	call	[RBankTab + eax*4]	; trashes eax
	mov	[debugflag],0

	mov	al,[esi]
	mov	[_cpu_Rbyte],al

	popad
	ret


PUBLIC _ReallyReadRAM

_ReallyReadRAM:
	pushad
	mov	esi,[_cpu_MAR]

	mov	[debugflag],1
	call	ReadHardware
	mov	[debugflag],0

	mov	al,[esi]
	mov	[_cpu_Rbyte],al

	popad
	ret



;*
;* trace routine so assembler routine can
;* start the C trace routine
;*

TraceInstruction:
	pushad

	mov	[_cpu_a],al
	mov	[_cpu_carry],ah

	mov	eax,[Frame]
	mov	[_frame],eax
	mov	eax,[ScanLine]
	mov	[_line],eax
	mov	al,[RClock]
	mov	[_cycle],al

	mov	eax,[BL_Position]
	mov	[_BL_Pos],eax
	mov	eax,[M0_Position]
	mov	[_M0_Pos],eax
	mov	eax,[M1_Position]
	mov	[_M1_Pos],eax
	mov	eax,[P0_Position]
	mov	[_P0_Pos],eax
	mov	eax,[P1_Position]
	mov	[_P1_Pos],eax

	mov	eax,[reg_pc]
	mov	[_cpu_pc],eax
	mov	al,[reg_x]
	mov	[_cpu_x],al
	mov	al,[reg_y]
	mov	[_cpu_y],al
	mov	al,[reg_sp]
	mov	[_cpu_sp],al
	mov	al,[RZTest]
	mov	[_cpu_ZTest],al
	mov	al,[RNTest]
	mov 	[_cpu_NTest],al
	mov	al,[flag_D]
	mov	[_cpu_D],al
	mov	al,[flag_V]
	mov	[_cpu_V],al
	mov	al,[flag_I]
	mov	[_cpu_I],al
	mov	al,[flag_B]
	mov	[_cpu_B],al

	call	_ShowRegisters
	call	_ShowInstruction

	popad
	ret

