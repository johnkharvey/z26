; trace.asm -- z26 trace stuff

;dw cpu_pc;
;db cpu_a, cpu_carry, cpu_x, cpu_y, cpu_sp;
;db cpu_ZTest, cpu_NTest, cpu_D, cpu_V, cpu_I, cpu_B;


.code

PUBLIC _ReallyReadROM

_ReallyReadROM proc far

	push	si
	mov	si,[_cpu_MAR]

	call	[ReadBank]
	mov	al,byte ptr[si]
	mov	[_cpu_Rbyte],al

	pop	si

	ret
_ReallyReadROM endp


TraceInstruction:

	pushad

	mov	[_cpu_a],al
	mov	[_cpu_carry],ah

	mov	eax,dword ptr [Timer]
	mov	dword ptr [_timer],eax

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

