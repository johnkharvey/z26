; trace.asm -- z26 trace stuff

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

;dw cpu_pc;
;db cpu_a, cpu_carry, cpu_x, cpu_y, cpu_sp;
;db cpu_ZTest, cpu_NTest, cpu_D, cpu_V, cpu_I, cpu_B;

.data

debugflag	db	0


.code

PUBLIC _ReallyReadROM

;ALIGN 16 *EST*

_ReallyReadROM proc far

	push	si
	mov	si,[_cpu_MAR]

	mov	[debugflag],1
	call	[ReadBank]
	mov	[debugflag],0

	mov	al,[si]
	mov	[_cpu_Rbyte],al

	pop	si

	ret
_ReallyReadROM endp

;ALIGN 16 *EST*

TraceInstruction:

	pushad

	mov	[_cpu_a],al
	mov	[_cpu_carry],ah

	mov	eax,dword ptr [Frame]
	mov	dword ptr [_frame],eax
	mov	ax,[ScanLine]
	mov	[_line],ax
	mov	al,[RClock]
	mov	[_cycle],al

	mov	ax,[BL_Position]
	mov	[_BL_Pos],ax
	mov	ax,[M0_Position]
	mov	[_M0_Pos],ax
	mov	ax,[M1_Position]
	mov	[_M1_Pos],ax
	mov	ax,[P0_Position]
	mov	[_P0_Pos],ax
	mov	ax,[P1_Position]
	mov	[_P1_Pos],ax

	mov	ax,[reg_pc]
	mov	[_cpu_pc],ax
	and	[_cpu_pc],01fffh
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
	
;	dec	dword ptr [_TraceCount]		; this doesn't work anyway if _TraceCount > 30000 or so
						; don't know why...
						; so we trace forever every time...
	
	popad
	ret

