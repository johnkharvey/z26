;*
;* 6507 CPU emulator for z26
;*

; 06-27-98 -- new design
; 07-17-98 -- simplify
; 06-26-99 -- cycle perfect

; CPU doesn't use cx, bp, di -- trashes ax, bx, dx, si

.data
ALIGN 2

reg_pc		dw	0		; program counter

wreg_sp label word			; a word sized alias to the stack pointer
reg_sp		db	0,1		; stack pointer

; the following two locations must be in this order and next to each other

reg_a		db	0		; accumulator (stored in AL)
flag_carry	db	0		; carry bit   (stored in AH)

; the following two locations are padded with an extra byte 
; to allow 16-bit access (see _index)

reg_x		db	0		; x register
		db	0
reg_y		db	0		; y register
		db	0

; a value is stored in the following vars for later testing

RZTest		db	0		; zero test value (Z set when 0)
RNTest		db	0		; sign test value (N set when negative)

; these vars hold the values of flags other than Z and N

flag_D		db	0		; decimal flag
flag_V		db	0		; overflow flag
flag_I		db	0		; interrupt disable flag
flag_B		db	0		; break flag

; clock variables

RCycles		db	0		; cycles per instruction
RClock		db	0		; clock cycles

; some temporaries for use by decimal arith and ARR

_value		db	0
_reg_a		db	0
_flag_carry	db	0

.code

Init_CPU:
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
	mov	[RCycles],0
	ret

;*
;* state saving macros
;*

SaveCPUState macro
	push	ax
	push	bx
	push	dx
	push	si
	endm

RestoreCPUState macro
	pop	si
	pop	dx
	pop	bx
	pop	ax
	endm


;*
;* timing macro
;*

bumpclock macro
	inc	[RClock]
	inc	[RCycles]
	endm

;*
;* memory accessing macros -- everything should go through here
;*

read_bank macro
	bumpclock
	call	[ReadBank]
	endm

write_bank macro
	bumpclock
	call	[WriteBank]
	endm

;*
;* memory accessing macros -- get/put data via op2
;*

read	macro	op1,op2		; read memory
	mov	si,op2
	read_bank
	mov	op1,byte ptr [si]
	endm
      
readsx	macro	op1,op2		; sign extended
	mov	si,op2
	read_bank
	movsx	op1,byte ptr [si]
	endm

readzx	macro	op1,op2		; zero extended
	mov	si,op2
	read_bank
	movzx	op1,byte ptr [si]
	endm

slack_read macro %1		; read and throw away result
	mov	si,%1
	read_bank
	endm

write	macro	op1,op2		; write memory
	mov	si,op2
	mov	[WByte],op1
	write_bank
	endm

slack_write	macro	op1,op2	; write memory
	mov	si,op2
	mov	[WByte],op1
	write_bank
	endm

;*
;* opcode (and immediate data) fetching macros
;*

fetch	macro	op1
	read	op1,[reg_pc]
	inc	[reg_pc]
	endm

fetchsx macro	op1
	readsx	op1,[reg_pc]
	inc	[reg_pc]
	endm

fetchzx macro	op1
	readzx	op1,[reg_pc]
	inc	[reg_pc]
	endm

fetch_opcode macro   op1	; special fetchzx for trace logging
local fo_1


IFDEF TRACE
	test	[_TraceCount],1
	jz	fo_1

	call	TraceInstruction

fo_1:	
ENDIF
	mov	[RCycles],0
	readzx	 op1,[reg_pc]
	inc	[reg_pc]
	endm

slack_fetch macro		; read and throw away, don't inc PC
	slack_read [reg_pc]
	endm

;*
;* 6507 stack macros
;*

zpush	macro	op1
	write	op1,[wreg_sp]	; write byte to top of stack
	dec	[reg_sp]	; and decrement stack pointer
	endm

zpop	macro	op1
	inc	[reg_sp]	; increment the	stack pointer
	read	op1,[wreg_sp]	; and read the top byte
	endm

slack_pop macro			; read stack and throw away, don't inc SP
	slack_read [wreg_sp]
	endm

;*
;* memory addressing helper macros
;*

absolute macro
	fetch	bl
	fetch	bh
	endm

zeropage macro
	fetchzx	bx
	endm

readaddress macro		; read data in bx -> bx
	and	bx,0ffh		; must be in page zero
	read	dl,bx
	inc	bl
	read	dh,bx
	mov	bx,dx
	endm

;*
;* memory addressing macros
;*

abs_read macro			; Absolute addressing
	absolute
	endm

abs_rmw macro
	absolute
	endm

abs_write macro
	absolute
	endm


zero_read macro			; Zero page addressing
	zeropage
	endm

zero_rmw macro
	zeropage
	endm

zero_write macro
	zeropage
	endm


zero_x_read macro		; Zero page indexed addressing
	zeropage
	slack_read bx
	add	bl,[reg_x]
	endm

zero_x_rmw macro
	zero_x_read
	endm

zero_x_write macro
	zero_x_read
	endm

zero_y_read macro
	zeropage
	slack_read bx
	add	bl,[reg_y]
	endm

zero_y_write macro
	zero_y_read
	endm


abs_x_read macro		; Absolute indexed addressing
local done

	absolute
	add	bl,[reg_x]
	jnc	done
	slack_read bx
	inc	bh
done:
	endm	

abs_x_rmw macro
	absolute
	slack_read bx
	add	bx, word ptr [reg_x]
	endm

abs_x_write macro
	abs_x_rmw
	endm

abs_y_read macro
local done

	absolute
	add	bl,[reg_y]
	jnc	done
	slack_read bx
	inc	bh
done:
	endm

abs_y_rmw macro
	absolute
	slack_read bx
	add	bx, word ptr [reg_y]
	endm

abs_y_write macro
	abs_y_rmw
	endm


ind_x_read macro		; Indexed indirect addressing
	zeropage
	slack_read bx
	add	bx, word ptr [reg_x]
	readaddress
	endm

ind_x_rmw macro
	ind_x_read
	endm

ind_x_write macro
	ind_x_read
	endm


ind_y_read macro		; Indirect indexed addressing
local done

	zeropage
	readaddress
	add	bl,[reg_y]
	jnc	done
	slack_read bx
	inc	bh
done:
	endm

ind_y_rmw macro
	zeropage
	readaddress
	push	bx
	add	bl,[reg_y]
	slack_read bx
	pop	bx
	add	bx, word ptr [reg_y]
	endm

ind_y_write macro
	ind_y_rmw
	endm

;*
;* opcode definition macros
;*

op_align macro
;ALIGN 4
	endm

op_register macro op1, op2, op3
op_align
op1:	slack_fetch
	mov	dl,op3
	_&op2
	mov	op3,dl
	ret
	endm

op_transfer macro op1, op2, op3
op_align
op1:	slack_fetch
	mov	dl,op3
	mov	op2,dl
	ret
	endm

op_transfertest macro op1, op2, op3
op_align
op1:	slack_fetch
	mov	dl,op3
	mov	op2,dl
	usetest	dl
	ret
	endm

op_immediate macro op1, op2
op_align
op1:	fetch	dl
	_&op2
	ret
	endm

op_read macro op1,op2,op3
op_align
op1:	op3&_read
	read	dl,bx
	_&op2
	ret
	endm

op_rmw macro op1,op2,op3
op_align
op1:	op3&_rmw
	read	dl,bx
	slack_write dl,bx
	_&op2
	write	dl,bx
	ret
	endm

op_write macro op1,op2,op3
op_align
op1:	op3&_write
	_&op2
	write	dl,bx
	ret
	endm

op_branch macro op1,op2,op3,op4
op_align
op1:	fetchsx dx		; sign-extended branch offset into dx
	test	op2,op3
	op4	DoBranch
	ret
	endm

op_weird macro op1,op2
op_align
op1:	_&op2
	ret
	endm

;*
;* flag setting macros
;*

useztest macro	op1		; use to test Z
	mov	[RZTest],op1
	endm

usentest macro	op1		; use to test N	     
	mov	[RNTest],op1
	endm

usetest macro	op1		; use to test both N and Z (normal)
	useztest op1
	usentest op1
	endm

;*
;* compare macros
;*

CompDH macro			; compare dh and dl
	sub	dh,dl
	usetest	dh
	setnc	ah
	endm

_CMP macro			; compare al and dl
	mov	dh,al
	CompDH
	endm

;*
;*  CPU macros
;*
;* (al=accumulator, ah=carry, dl=operand)
;*

_ADC macro
	call	DoADC
	endm

DoADC:	cmp	[flag_D],0
	jnz	ADCBCD
	shr	ah,1
	adc	al,dl
	seto	[flag_V]
	usetest	al
	setc	ah
	ret

ADCBCD:	push	cx

	mov	[_reg_a],al
	mov	[_value],dl

	add	al,dl			; set some flags using binary addition
	seto	[flag_V]
	add	al,ah			; add carry
	mov	[RZTest],al

	mov	al,[_reg_a]		; now do decimal addition
	and	al,0fh
	and	dl,0fh			; dl has _value
	add	al,dl			; add bottom nybbles
	add	al,ah			; add carry
	cmp	al,9			; fixup bottom nybble
	jbe	ADCD_1
	add	al,6
ADCD_1:	mov	cl,al			; save result with half carry
	and	ax,0fh
	mov	dl,[_reg_a]
	and	dx,0f0h
	add	ax,dx			; combine with top nybble of _reg_a
	mov	dl,[_value]
	and	dx,0f0h
	add	dx,ax			; add top nybble of _value
	cmp	cl,0fh			; did lower nybble fixup overflow ?
	jbe	ADCD_3
	add	dx,010h			;   yes
ADCD_3:	mov	[RNTest],dl		; set a flag
	mov	ax,dx			; fixup top nybble
	and	dx,01f0h
	cmp	dx,090h
	jbe	ADCD_6
	add	ax,060h
ADCD_6:	test	ah,ah
	setnz	ah			; set carry
	mov	dl,[_value]		; ADC must preserve dl for RRA

	pop	cx
	ret	

_ANC macro
	and	al,dl
	usetest	al
	test	al,080h
	setnz	ah
	endm

_AND macro
	and	al,dl
	usetest	al
	endm

_ANE macro
	or	al,0eeh
	and	al,[reg_x]
	and	al,dl
	usetest	al
	endm

_ARR macro

; algorithm based on 6510core.c by Ettore Perazzoli (ettore@comm2000.it)

	push	bx
	push	cx

	and	al,dl
	mov	bl,al

	cmp	[flag_D],0
	je	ARR_4

	mov	[RNTest],ah
	shl	[RNTest],7

	mov	cx,ax
	shr	cx,1

	setnz	[RZTest]

	mov	al,cl
	xor	al,bl
	and	al,64
	setnz	[flag_V]

	mov	al,bl
	mov	dl,bl
	and	al,15
	and	dl,1
	add	al,dl
	cmp	al,5
	jbe	ARR_1
	mov	dl,cl
	and	cl,240
	add	dl,6
	and	dl,15
	or	cl,dl
ARR_1:	mov	al,bl
	and	ax,240
	and	bx,16
	add	ax,bx
	cmp	ax,80
	jbe	ARR_2
	mov	al,cl
	and	al,15
	mov	bl,cl
	add	bl,96
	and	bl,240
	or	al,bl
	mov	ah,1
	jmp	ARR_5

ARR_2:	xor	ah,ah
	mov	al,cl
	jmp	ARR_5

ARR_4:	shr	ax,1
	usetest	al

	mov	bl,al
	test	bl,64
	setnz	ah

	and	bl,32
	shl	bl,1
	mov	dl,al
	and	dl,64
	xor	bl,dl
	setnz	[flag_V]
ARR_5:
	pop	cx
	pop	bx
	endm

_ASL macro
	shl	dl,1
	setc	ah
	usetest dl
	endm

_ASR macro
	and	al,dl
	test	al,1
	setnz	ah
	shr	al,1
	usetest	al
	endm

_BIT macro
	test	dl,040h		; bit 6 is the overflow flag
	setnz	[flag_V]
	usentest dl		; the memory bit 7 is the n flag
	and	dl,al		; this is the and result
	useztest dl		; use it to test for zero
	endm

_CPX macro
	mov	dh,[reg_x]
	CompDH
	endm

_CPY macro
	mov	dh,[reg_y]
	CompDH
	endm

_DCP macro
	dec	dl
	_CMP
	endm

_DEC macro
	dec	dl
	usetest	dl
	endm

_EOR macro
	xor	al,dl
	usetest	al
	endm

_INC macro
	inc	dl
	usetest	dl
	endm

_ISB macro
	inc	dl
	call	DoSBC
	endm

_LAS macro
	and	dl,[reg_sp]
	mov	al,dl
	mov	[reg_x],dl
	mov	[reg_sp],dl
	usetest	dl
	endm

_LAX macro
	mov	[reg_x],dl
	mov	al,dl
	usetest	dl
	endm

_LDA macro
	mov	al,dl
	usetest	dl
	endm

_LDX macro
	mov	[reg_x],dl
	usetest	dl
	endm

_LDY macro
	mov	[reg_y],dl
	usetest	dl
	endm

_LSR macro
	shr	dl,1
	setc	ah
	usetest dl
	endm

_LXA macro
	or	al,0eeh
	and	al,dl
	mov	[reg_x],al
	usetest	al
	endm

_NOP macro
	endm

_ORA macro
	or	al,dl
	usetest	al
	endm

_RLA macro
	shr	ah,1
	rcl	dl,1
	setc	ah
	and	al,dl
	usetest	al
	endm

_ROL macro
	shr	ah,1
	rcl	dl,1
	setc	ah
	usetest dl
	endm

_ROR macro
	shr	ah,1
	rcr	dl,1
	setc	ah
	usetest dl
	endm

_RRA macro
	shr	ah,1
	rcr	dl,1
	setc	ah
	call	DoADC
	endm

_SAX macro
	mov	dl,al
	and	dl,[reg_x]
	endm

_SBC macro
	call	DoSBC
	endm

DoSBC:	cmp	[flag_D],0
	jnz	SBCBCD
	shr	ah,1
	cmc			; set carry
	sbb	al,dl
	seto	[flag_V]
	usetest	al
	setnc	ah
	ret

SBCBCD:	push	cx

	mov	[_reg_a],al
	mov	[_value],dl

	xor	ah,1
	sahf
	sbb	al,dl		; set flags using binary subtraction
	usetest	al
	setnc	[_flag_carry]
	seto	[flag_V]

	mov	al,[_reg_a]	; now do decimal subtraction
	and	dx,0fh
	add	dl,ah
	and	ax,0fh
	sub	ax,dx		; subtract bottom nybbles with carry
	mov	cx,ax		; save result
	mov	al,[_reg_a]
	and	ax,0f0h
	mov	dl,[_value]
	and	dx,0f0h
	sub	ax,dx		; subtract top nybbles
	test	cx,010h		; bottom nybble underflow ?
	je	SBCD_5
	add	ax,-16		;   yes, fixup
	mov	dx,cx
	add	dx,-6
	jmp	SBCD_6

SBCD_5:	mov	dx,cx
SBCD_6:	and	dx,0fh
	or	ax,dx		; combine lower and upper nybble result
	test	ax,0100h	; upper nybble underflow ?
	je	SBCD_7
	sub	ax,060h		;   yes, fixup
SBCD_7:	mov	ah,[_flag_carry]
	mov	dl,[_value]	; SBC must preserve dl for ISB

	pop	cx
	ret	

_SBX macro
	mov	dh,al
	and	dh,[reg_x]
	sub	dh,dl
	usetest	dh
	setnc	ah
	mov	[reg_x],dh
	endm

_SHA macro
	mov	dl,bh
	inc	dl
	and	dl,[reg_x]
	and	dl,al
	endm

_SHS macro
	mov	dl,bh
	inc	dl
	and	dl,[reg_x]
	and	dl,al
	mov	dh,al
	and	dh,[reg_x]
	mov	[reg_sp],dh
	endm

_SHX macro
	mov	dl,bh
	inc	dl
	and	dl,[reg_x]
	endm

_SHY macro
	mov	dl,bh
	inc	dl
	and	dl,[reg_y]
	endm

_SLO macro
	shl	dl,1
	setc	ah
	or	al,dl
	usetest	al
	endm

_SRE macro
	mov	ah,1
	and	ah,dl
	shr	dl,1
	xor	al,dl
	usetest	al
	endm

_STA macro
	mov	dl,al
	endm

_STX macro
	mov	dl,[reg_x]
	endm

_STY macro
	mov	dl,[reg_y]
	endm

;*
;* weird opcodes
;*

_BRK macro
	slack_fetch

	mov	[flag_B],1	; set break flag
	inc	[reg_pc]
	mov	bx,[reg_pc]	; push return address
	zpush	bh
	zpush	bl

	call	GetPSW		; get PSW in DL
	or	dl,010h		; force break flag
	zpush	dl

	mov	[flag_I],1	; disable interrupts
	mov	bx,0FFFEh	; fetch	the vector

	push	ax
	read	al,bx
	inc	bx
	read	ah,bx
	mov	[reg_pc],ax	; and transfer control
	pop	ax
	endm

_JMPI macro
	fetch	bl		; read the address of the the jump
	fetch	bh
	read	dl,bx
	inc	bl		; stay in current page
	read	dh,bx
	mov	[reg_pc],dx	; and jump to it
	endm

_JMPW macro
	fetch	bl		; fetch	the address
	fetch	bh
	mov	[reg_pc],bx	; jump to it
	endm

_JSR macro
	fetch	bl		; bottom byte of new PC

	slack_pop

	push	ax
	mov	ax,[reg_pc]	; ax is	the return address
	zpush	ah		; we are automatically pushing return-1
	zpush	al
	pop	ax

	fetch	bh		; now we fetch the top byte of PC
	mov	[reg_pc],bx	; transfer control
	endm

_PHA macro
	slack_fetch
	zpush	al
	endm

_PLA macro
	slack_fetch
	slack_pop
	zpop	al
	usetest	al
	endm

_PHP macro
	slack_fetch
	call	GetPSW		; get PSW in DL
	or	dl,010h		; force break flag
	zpush	dl
	endm

_PLP macro
	slack_fetch
	slack_pop
	zpop	dh		; pull PSW from stack
	call	PutPSW
	endm

_RTI macro
	slack_fetch
	slack_pop
	zpop	dh		; pull PSW from stack
	call	PutPSW		; and scatter the flags
	push	ax
	zpop	al
	zpop	ah		; pull return address
	mov	[reg_pc],ax	; transfer control
	pop	ax
	endm

_RTS macro
	slack_fetch
	slack_pop
	push	ax
	zpop	al
	zpop	ah		; pull return address
	mov	[reg_pc],ax	; transfer control
	pop	ax
	slack_fetch
	inc	[reg_pc]
	endm


; load CPU registers

LoadRegs macro
	mov	ax,word ptr [reg_a]	; mov al,[reg_a]; mov ah,[flag_carry]
	endm

; save CPU registers

SaveRegs macro
	mov	word ptr [reg_a],ax	; mov [reg_a],al; mov [flag_carry],ah
	endm

;*
;* do a single instruction (just for show)
;*

do_Instruction:

	LoadRegs			; load the CPU registers

	fetch_opcode	ebx		; (fetchzx) get the opcode
	call word ptr [vectors + ebx*2]	; --> do the instruction
	ClockRIOT

	SaveRegs			; save the CPU registers

	ret

;*
;* Reset the CPU
;*

Reset:
	mov	[reg_sp],0FFh	; SP initialises to 255
	mov	bx,0fffch	; get reset address
	read	dl,bx
	inc	bx
	read	dh,bx
	mov	[reg_pc],dx
	mov	[RClock],0
	ret

;*
;* Handle relative jumps
;*

DoBranch:
	mov	bx,[reg_pc]	; bh is	the current page
	add	dx,[reg_pc]	; destination address
	mov	[reg_pc],dx	; set the program counter

	cmp	bh,dh		; page changed ?
	je	dbjn		;   no

	xchg	bh,dh
	slack_fetch		;   yes, another cycle
	xchg	bh,dh

dbjn:	slack_fetch		; branch is taken -- one extra cycle

	ret

;*
;* Build the PSW out of the various flags and the last register into DL
;*

GetPSW:	mov	dl,[RNTest]	; dl = last result
	and	dl,128		; use bit 7 of that for N
	mov	dh,[flag_V]	; bit 6	is V
	shl	dh,6
	or	dl,dh
	or	dl,020H		; bit 5	is always set
	mov	dh,[flag_B]	; bit 4	is B
	shl	dh,4
	or	dl,dh
	mov	dh,[flag_D]	; bit 3	is D
	shl	dh,3
	or	dl,dh
	mov	dh,[flag_I]	; bit 2	is I
	shl	dh,2
	or	dl,dh
	cmp	[RZTest],0	; bit 1 is Z
	jnz	PSWZero
	or	dl,02h
PSWZero:or	dl,ah		; bit 0	is C
	ret

;*
;* set various flags from PSW in dh
;*

PutPSW:	mov	[RNTest],dh	; PSW will do for N
	mov	ah,dh
	and	ah,1		; bit 0 is C
	test	dh,02h		; bit 1 is Z
	setz	[RZTest]
	test	dh,04h		; bit 2 is I
	setnz	[flag_I]
	test	dh,08h		; bit 3 is D
	setnz	[flag_D]
	test	dh,010h		; bit 4 is B
	setnz	[flag_B]
	test	dh,040h		; bit 6 is V
	setnz	[flag_V]
	ret

.data

;*
;* opcode vector table
;*
;* note:  the jam handler should be defined externally
;*        (since it is typically environment dependent)
;*

vectors label word
    dw _00,_01,jam,_03,_04,_05,_06,_07,_08,_09,_0a,_0b,_0c,_0d,_0e,_0f
    dw _10,_11,jam,_13,_14,_15,_16,_17,_18,_19,_1a,_1b,_1c,_1d,_1e,_1f
    dw _20,_21,jam,_23,_24,_25,_26,_27,_28,_29,_2a,_0b,_2c,_2d,_2e,_2f ;_2b=_0b
    dw _30,_31,jam,_33,_34,_35,_36,_37,_38,_39,_3a,_3b,_3c,_3d,_3e,_3f
    dw _40,_41,jam,_43,_44,_45,_46,_47,_48,_49,_4a,_4b,_4c,_4d,_4e,_4f
    dw _50,_51,jam,_53,_54,_55,_56,_57,_58,_59,_5a,_5b,_5c,_5d,_5e,_5f
    dw _60,_61,jam,_63,_64,_65,_66,_67,_68,_69,_6a,_6b,_6c,_6d,_6e,_6f
    dw _70,_71,jam,_73,_74,_75,_76,_77,_78,_79,_7a,_7b,_7c,_7d,_7e,_7f
    dw _80,_81,_82,_83,_84,_85,_86,_87,_88,_89,_8a,_8b,_8c,_8d,_8e,_8f
    dw _90,_91,jam,_93,_94,_95,_96,_97,_98,_99,_9a,_9b,_9c,_9d,_9e,_9f
    dw _a0,_a1,_a2,_a3,_a4,_a5,_a6,_a7,_a8,_a9,_aa,_ab,_ac,_ad,_ae,_af
    dw _b0,_b1,jam,_b3,_b4,_b5,_b6,_b7,_b8,_b9,_ba,_bb,_bc,_bd,_be,_bf
    dw _c0,_c1,_c2,_c3,_c4,_c5,_c6,_c7,_c8,_c9,_ca,_cb,_cc,_cd,_ce,_cf
    dw _d0,_d1,jam,_d3,_d4,_d5,_d6,_d7,_d8,_d9,_da,_db,_dc,_dd,_de,_df
    dw _e0,_e1,_e2,_e3,_e4,_e5,_e6,_e7,_e8,_e9,_ea,_e9,_ec,_ed,_ee,_ef ;_eb=_e9
    dw _f0,_f1,jam,_f3,_f4,_f5,_f6,_f7,_f8,_f9,_fa,_fb,_fc,_fd,_fe,_ff

.code

;*
;* opcode handlers
;*

op_weird	_00,BRK
op_read		_01,ORA,ind_x

op_rmw		_03,SLO,ind_x
op_read		_04,NOP,zero
op_read		_05,ORA,zero
op_rmw		_06,ASL,zero
op_rmw		_07,SLO,zero
op_weird	_08,PHP
op_immediate	_09,ORA
op_register	_0a,ASL,al
op_immediate	_0b,ANC
op_read		_0c,NOP,abs
op_read		_0d,ORA,abs
op_rmw		_0e,ASL,abs
op_rmw		_0f,SLO,abs
op_branch	_10,[RNTest],128,jz
op_read		_11,ORA,ind_y

op_rmw		_13,SLO,ind_y
op_read		_14,NOP,zero_x
op_read		_15,ORA,zero_x
op_rmw		_16,ASL,zero_x
op_rmw		_17,SLO,zero_x
op_transfer	_18,ah,0
op_read		_19,ORA,abs_y
op_transfer	_1a,al,al
op_rmw		_1b,SLO,abs_y
op_read		_1c,NOP,abs_x
op_read		_1d,ORA,abs_x
op_rmw		_1e,ASL,abs_x
op_rmw		_1f,SLO,abs_x
op_weird	_20,JSR
op_read		_21,AND,ind_x

op_rmw		_23,RLA,ind_x
op_read		_24,BIT,zero
op_read		_25,AND,zero
op_rmw		_26,ROL,zero
op_rmw		_27,RLA,zero
op_weird	_28,PLP
op_immediate	_29,AND
op_register	_2a,ROL,al

op_read		_2c,BIT,abs
op_read		_2d,AND,abs
op_rmw		_2e,ROL,abs
op_rmw		_2f,RLA,abs
op_branch	_30,[RNTest],128,jnz
op_read		_31,AND,ind_y

op_rmw		_33,RLA,ind_y
op_read		_34,NOP,zero
op_read		_35,AND,zero_x
op_rmw		_36,ROL,zero_x
op_rmw		_37,RLA,zero_x
op_transfer	_38,ah,1
op_read		_39,AND,abs_y
op_transfer	_3a,al,al
op_rmw		_3b,RLA,abs_y
op_read		_3c,NOP,abs_x
op_read		_3d,AND,abs_x
op_rmw		_3e,ROL,abs_x
op_rmw		_3f,RLA,abs_x
op_weird	_40,RTI
op_read		_41,EOR,ind_x

op_rmw		_43,SRE,ind_x
op_read		_44,NOP,zero
op_read		_45,EOR,zero
op_rmw		_46,LSR,zero
op_rmw		_47,SRE,zero
op_weird	_48,PHA
op_immediate	_49,EOR
op_register	_4a,LSR,al
op_immediate	_4b,ASR
op_weird	_4c,JMPW
op_read		_4d,EOR,abs
op_rmw		_4e,LSR,abs
op_rmw		_4f,SRE,abs
op_branch	_50,[flag_V],0ffh,jz
op_read		_51,EOR,ind_y

op_rmw		_53,SRE,ind_y
op_read		_54,NOP,zero_x
op_read		_55,EOR,zero_x
op_rmw		_56,LSR,zero_x
op_rmw		_57,SRE,zero_x
op_transfer	_58,[flag_I],0
op_read		_59,EOR,abs_y
op_transfer	_5a,al,al
op_rmw		_5b,SRE,abs_y
op_read		_5c,NOP,abs_x
op_read		_5d,EOR,abs_x
op_rmw		_5e,LSR,abs_x
op_rmw		_5f,SRE,abs_x
op_weird	_60,RTS
op_read		_61,ADC,ind_x

op_rmw		_63,RRA,ind_x
op_read		_64,NOP,zero
op_read		_65,ADC,zero
op_rmw		_66,ROR,zero
op_rmw		_67,RRA,zero
op_weird	_68,PLA
op_immediate	_69,ADC
op_register	_6a,ROR,al
op_immediate	_6b,ARR
op_weird	_6c,JMPI
op_read		_6d,ADC,abs
op_rmw		_6e,ROR,abs
op_rmw		_6f,RRA,abs
op_branch	_70,[flag_V],0ffh,jnz
op_read		_71,ADC,ind_y

op_rmw		_73,RRA,ind_y
op_read		_74,NOP,zero_x
op_read		_75,ADC,zero_x
op_rmw		_76,ROR,zero_x
op_rmw		_77,RRA,zero_x
op_transfer	_78,[flag_I],1
op_read		_79,ADC,abs_y
op_transfer	_7a,al,al
op_rmw		_7b,RRA,abs_y
op_read		_7c,NOP,abs_x
op_read		_7d,ADC,abs_x
op_rmw		_7e,ROR,abs_x
op_rmw		_7f,RRA,abs_x
op_immediate	_80,NOP
op_write	_81,STA,ind_x
op_immediate	_82,NOP
op_write	_83,SAX,ind_x
op_write	_84,STY,zero
op_write	_85,STA,zero
op_write	_86,STX,zero
op_write	_87,SAX,zero
op_register	_88,DEC,[reg_y]
op_immediate	_89,NOP
op_transfertest	_8a,al,[reg_x]
op_immediate	_8b,ANE
op_write	_8c,STY,abs
op_write	_8d,STA,abs
op_write	_8e,STX,abs
op_write	_8f,SAX,abs
op_branch	_90,ah,ah,jz
op_write	_91,STA,ind_y

op_write	_93,SHA,ind_y
op_write	_94,STY,zero_x
op_write	_95,STA,zero_x
op_write	_96,STX,zero_y
op_write	_97,SAX,zero_y
op_transfertest	_98,al,[reg_y]
op_write	_99,STA,abs_y
op_transfer	_9a,[reg_sp],[reg_x]
op_write	_9b,SHS,abs_y
op_write	_9c,SHY,abs_x
op_write	_9d,STA,abs_x
op_write	_9e,SHX,abs_y
op_write	_9f,SHA,abs_y
op_immediate	_a0,LDY
op_read		_a1,LDA,ind_x
op_immediate	_a2,LDX
op_read		_a3,LAX,ind_x
op_read		_a4,LDY,zero
op_read		_a5,LDA,zero
op_read		_a6,LDX,zero
op_read		_a7,LAX,zero
op_transfertest	_a8,[reg_y],al
op_immediate	_a9,LDA
op_transfertest	_aa,[reg_x],al
op_immediate	_ab,LXA
op_read		_ac,LDY,abs
op_read		_ad,LDA,abs
op_read		_ae,LDX,abs
op_read		_af,LAX,abs
op_branch	_b0,ah,ah,jnz
op_read		_b1,LDA,ind_y

op_read		_b3,LAX,ind_y
op_read		_b4,LDY,zero_x
op_read		_b5,LDA,zero_x
op_read		_b6,LDX,zero_y
op_read		_b7,LAX,zero_y
op_transfer	_b8,[flag_V],0
op_read		_b9,LDA,abs_y
op_transfertest	_ba,[reg_x],[reg_sp]
op_read		_bb,LAS,abs_y
op_read		_bc,LDY,abs_x
op_read		_bd,LDA,abs_x
op_read		_be,LDX,abs_y
op_read		_bf,LAX,abs_y
op_immediate	_c0,CPY
op_read		_c1,CMP,ind_x
op_immediate	_c2,NOP
op_rmw		_c3,DCP,ind_x
op_read		_c4,CPY,zero
op_read		_c5,CMP,zero
op_rmw		_c6,DEC,zero
op_rmw		_c7,DCP,zero
op_register	_c8,INC,[reg_y]
op_immediate	_c9,CMP
op_register	_ca,DEC,[reg_x]
op_immediate	_cb,SBX
op_read		_cc,CPY,abs
op_read		_cd,CMP,abs
op_rmw		_ce,DEC,abs
op_rmw		_cf,DCP,abs
op_branch	_d0,[RZTest],0ffh,jnz
op_read		_d1,CMP,ind_y

op_rmw		_d3,DCP,ind_y
op_read		_d4,NOP,zero_x
op_read		_d5,CMP,zero_x
op_rmw		_d6,DEC,zero_x
op_rmw		_d7,DCP,zero_x
op_transfer	_d8,[flag_D],0
op_read		_d9,CMP,abs_y
op_transfer	_da,al,al
op_rmw		_db,DCP,abs_y
op_read		_dc,NOP,abs_x
op_read		_dd,CMP,abs_x
op_rmw		_de,DEC,abs_x
op_rmw		_df,DCP,abs_x
op_immediate	_e0,CPX
op_read		_e1,SBC,ind_x
op_immediate	_e2,NOP
op_rmw		_e3,ISB,ind_x
op_read		_e4,CPX,zero
op_read		_e5,SBC,zero
op_rmw		_e6,INC,zero
op_rmw		_e7,ISB,zero
op_register	_e8,INC,[reg_x]
op_immediate	_e9,SBC
op_transfer	_ea,al,al

op_read		_ec,CPX,abs
op_read		_ed,SBC,abs
op_rmw		_ee,INC,abs
op_rmw		_ef,ISB,abs
op_branch	_f0,[RZTest],0ffh,jz
op_read		_f1,SBC,ind_y

op_rmw		_f3,ISB,ind_y
op_read		_f4,NOP,zero_x
op_read		_f5,SBC,zero_x
op_rmw		_f6,INC,zero_x
op_rmw		_f7,ISB,zero_x
op_transfer	_f8,[flag_D],1
op_read		_f9,SBC,abs_y
op_transfer	_fa,al,al
op_rmw		_fb,ISB,abs_y
op_read		_fc,NOP,abs_x
op_read		_fd,SBC,abs_x
op_rmw		_fe,INC,abs_x
op_rmw		_ff,ISB,abs_x

