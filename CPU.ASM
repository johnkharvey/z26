;*
;* 6507 CPU emulator for z26
;*

; 06-27-98 -- new design
; 07-17-98 -- simplify


.code

;*
;* memory accessing macros -- get/put data via op2
;*

read    macro   op1,op2			; read memory
        mov     si,op2
        call    [ReadBank]

IFDEF z64
	mov	op1,[RByte]
ELSE
        mov     op1,byte ptr [si]
ENDIF

        endm
      
readsx  macro   op1,op2			; sign extended
        mov     si,op2
        call    [ReadBank]

IFDEF z64
	movsx	op1,[RByte]
ELSE
        movsx   op1,byte ptr [si]
ENDIF

        endm

readzx  macro   op1,op2			; zero extended
        mov     si,op2
        call    [ReadBank]

IFDEF z64
	movzx	op1,[RByte]
ELSE
        movzx   op1,byte ptr [si]
ENDIF

        endm

write   macro   op1,op2			; write memory
        mov     si,op2
        mov     [WByte],op1
        call    [WriteBank]
        endm

;*
;* opcode (and immediate data) fetching macros
;*

fetch   macro   op1
        read    op1,di
        inc     di
        endm

fetchsx macro   op1
        readsx  op1,di
        inc     di
        endm

fetchzx macro   op1
        readzx  op1,di
        inc     di
        endm

fetch_opcode macro   op1		; special fetchzx for trace logging
local fo_1

	cmp	[trace_count],0
	jz	fo_1

	call	TraceInstruction

fo_1:	readzx  op1,di
        inc     di
        endm

;*
;* 6507 stack macros
;*

zpush	macro	op1
	mov	bl,[reg_sp]
	mov	bh,1
	write	op1,bx		; write byte to top of stack
	dec	[reg_sp]	; and decrement stack pointer
	endm

zpop	macro	op1
	inc	[reg_sp]	; increment the	stack pointer
	mov	bl,[reg_sp]	; and read the top byte
	mov	bh,1
	read	op1,bx
	endm

;*
;* memory addressing helper macros -- get operand address into bx
;*

absolute macro
        fetch   bl
        fetch   bh
        endm

zeropage macro
	fetchzx	bx
        endm

_index macro    op1
        add     bx,word ptr[op1]        ; this is not a cheat
        endm

indexx  macro
        _index  reg_x
        endm
        
indexy  macro
        _index  reg_y
        endm

bumpclock macro
	inc	[RClock]
	inc	[RCycles]
	endm

pagechange macro
        local   M1
        
        cmp     dh,bh                   ; page changed ?
        jz      M1
	bumpclock
M1:
        endm

readaddress macro                       ; read data in bx -> bx
        and	bx,0ffh			; must be in page zero
        read    dl,bx
        inc     bl
        read    dh,bx
        mov     bx,dx
        endm

absolutex macro
        absolute
        mov     dx,bx			; set up for pagechange test
        indexx
	pagechange
        endm

absolutex_nopc macro
        absolute
        indexx
        endm

absolutey macro
        absolute
        mov     dx,bx			; set up for pagechange test
        indexy
	pagechange
        endm

absolutey_nopc macro
        absolute
        indexy
        endm

zeropagex macro
        zeropage
        add     bl,[reg_x]
        endm

zeropagey macro
        zeropage
        add     bl,[reg_y]
        endm

indirectx macro
        zeropage
        indexx
        readaddress
        endm

indirecty macro
        zeropage
        readaddress
        mov     dx,bx			; set up for pagechange macro
        indexy
	pagechange
        endm

indirecty_nopc macro
        zeropage
        readaddress
        indexy
        endm

;*
;* memory addressing macros (and instruction timing)
;*

inc_clock macro op1
	mov	[RCycles],op1
	add	[RClock],op1
	endm

abs_read macro
	inc_clock 4
	absolute
	endm

abs_rmw macro
	inc_clock 6
	absolute
	endm

abs_write macro
	inc_clock 4
	absolute
	endm

abs_x_read macro
	inc_clock 4
	absolutex
	endm	

abs_x_rmw macro
	inc_clock 7
	absolutex_nopc
	endm

abs_x_write macro
	inc_clock 5
	absolutex_nopc
	endm

abs_y_read macro
	inc_clock 4
	absolutey
	endm

abs_y_rmw macro
	inc_clock 7
	absolutey_nopc
	endm

abs_y_write macro
	inc_clock 5
	absolutey_nopc
	endm

immediate macro
	inc_clock 2
	endm

implied macro
	inc_clock 2
	endm

ind_x_read macro
	inc_clock 6
	indirectx
	endm

ind_x_rmw macro
	inc_clock 8
	indirectx
	endm

ind_x_write macro
	inc_clock 6
	indirectx
	endm

ind_y_read macro
	inc_clock 5
	indirecty
	endm

ind_y_rmw macro
	inc_clock 8
	indirecty_nopc
	endm

ind_y_write macro
	inc_clock 6
	indirecty_nopc
	endm

relative macro
	inc_clock 2
	endm

zero_read macro
	inc_clock 3
	zeropage
	endm

zero_rmw macro
	inc_clock 5
	zeropage
	endm

zero_write macro
	inc_clock 3
	zeropage
	endm

zero_x_read macro
	inc_clock 4
	zeropagex
	endm

zero_x_rmw macro
	inc_clock 6
	zeropagex
	endm

zero_x_write macro
	inc_clock 4
	zeropagex
	endm

zero_y_read macro
	inc_clock 4
	zeropagey
	endm

zero_y_write macro
	inc_clock 4
	zeropagey
	endm


;*
;* opcode definition macros
;*

op_register macro op1, op2, op3
_&op1:	implied
	mov	dl,op3
	_&op2
	mov	op3,dl
	ret
	endm

op_transfer macro op1, op2, op3
_&op1:	implied
	mov	dl,op3
	mov	op2,dl
	ret
	endm

op_transfertest macro op1, op2, op3
_&op1:	implied
	mov	dl,op3
	mov	op2,dl
	usetest	dl
	ret
	endm

op_immediate macro op1, op2
_&op1:	immediate
	fetch	dl
	_&op2
	ret
	endm

op_read macro op1,op2,op3
_&op1:	op3&_read
	read	dl,bx
	_&op2
	ret
	endm

op_rmw macro op1,op2,op3
_&op1:	op3&_rmw
	read	dl,bx
	_&op2
	write	dl,bx
	ret
	endm

op_write macro op1,op2,op3
_&op1:	op3&_write
	_&op2
	write	dl,bx
	ret
	endm

op_branch macro op1,op2,op3,op4
_&op1:	relative
	test	op2,op3
	op4	DoBranch
	inc	di
	ret
	endm

op_weird macro op1,op2
_&op1:	_&op2
	ret
	endm

;*
;* flag setting macros
;*

useztest macro  op1                     ; use to test Z
        mov     [RZTest],op1
        endm

usentest macro  op1                     ; use to test N      
        mov     [RNTest],op1
        endm

usetest macro   op1                     ; use to test both N and Z (normal)
        useztest op1
        usentest op1
        endm

;*
;* compare macros
;*

CompDH macro				; compare dh and dl
	sub	dh,dl
	usetest	dh
	setnc	ah
	endm

_CMP macro				; compare al and dl
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
        shr     dl,1
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
        shr     ah,1
        rcl     dl,1
        setc	ah
        usetest dl
        endm

_ROR macro
        shr     ah,1
        rcr     dl,1
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
	cmc				; set carry
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
	sbb	al,dl			; set flags using binary subtraction
	usetest	al
	setnc	[_flag_carry]
	seto	[flag_V]

	mov	al,[_reg_a]		; now do decimal subtraction
	and	dx,0fh
	add	dl,ah
	and	ax,0fh
	sub	ax,dx			; subtract bottom nybbles with carry
	mov	cx,ax			; save result
	mov	al,[_reg_a]
	and	ax,0f0h
	mov	dl,[_value]
	and	dx,0f0h
	sub	ax,dx			; subtract top nybbles
	test	cx,010h			; bottom nybble underflow ?
	je	SBCD_5
	add	ax,-16			;   yes, fixup
	mov	dx,cx
	add	dx,-6
	jmp	SBCD_6

SBCD_5:	mov	dx,cx
SBCD_6:	and	dx,0fh
	or	ax,dx			; combine lower and upper nybble result
	test	ax,0100h		; upper nybble underflow ?
	je	SBCD_7
	sub	ax,060h			;   yes, fixup
SBCD_7:	mov	ah,[_flag_carry]
	mov	dl,[_value]		; SBC must preserve dl for ISB

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
;* weird opcodes -- they don't match a pattern
;*                  they must be timed manually
;*

_BRK macro
	inc_clock 7

	mov	[flag_B],1	; set break flag
	inc	di
	mov	dx,di		; push return address
	zpush	dh
	mov	dx,di
	zpush	dl

	call	_08		; push PSW
	mov	[flag_I],1	; disable interrupts
	mov	bx,0FFFEh	; fetch	the vector

	push	ax
	read	al,bx
	inc	bx
	read	ah,bx
	mov	di,ax		; and transfer control
	pop	ax
	endm

_JMPI macro
	inc_clock 5

	absolute		; read the address of the the jump
	read	dl,bx
	inc	bl		; stay in current page
	read	dh,bx
	mov	di,dx		; and jump to it

IFDEF z64
	cmp	di,0ff00h
	jae	KernalHandler
ENDIF
	endm

_JMPW macro
	inc_clock 3

	absolute		; fetch	the address
	mov	di,bx		; jump to it

IFDEF z64
	cmp	di,0ff00h
	jae	KernalHandler
ENDIF
	endm

_JSR macro
	inc_clock 6

	absolute		; call address in bx now
	push	ax
	mov	ax,di		; ax is	the return address
	mov	di,bx		; transfer control
	dec	ax		; push return-1
	zpush	ah
	zpush	al
	pop	ax

IFDEF z64
	cmp	di,0ff00h
	jae	KernalHandler
ENDIF
	endm

_PHA macro
	inc_clock 3

	zpush	al
	endm

_PLA macro
	inc_clock 4

	zpop	al
	usetest	al
	endm

_PHP macro
	inc_clock 3

	call	GetPSW		; get PSW in DL
	or	dl,010h		; force break flag
	zpush	dl
	endm

_PLP macro
	inc_clock 4

	zpop	dh		; pull PSW from stack
	call	PutPSW
	endm

_RTI macro
	inc_clock 6

	zpop	dh		; pull PSW from stack
	call	PutPSW		; and scatter the flags
	push	ax
	zpop	al
	zpop	ah		; pull return address
	mov	di,ax		; transfer control
	pop	ax
	endm

_RTS macro
	inc_clock 6

	push	ax
	zpop	al
	zpop	ah		; pull return address
	mov	di,ax		; transfer control
	inc	di
	pop	ax
	endm


; load CPU registers

LoadRegs macro
	mov	ax,word ptr [reg_a]	; mov al,[reg_a]; mov ah,[flag_carry]
	mov	di,[reg_pc]
	endm

; save CPU registers

SaveRegs macro
	mov	word ptr [reg_a],ax	; mov [reg_a],al; mov [flag_carry],ah
	mov	[reg_pc],di
	endm

;*
;* do a single instruction
;*

DoInstruction macro
	push	dx
	push	di
	push	si
	LoadRegs			; load the CPU registers

	fetch_opcode	ebx		; (fetchzx) get the opcode
	call	[vectors + ebx*2]	; --> do the instruction
	call	[TimerVec]		; clock the RIOT timer

	SaveRegs			; save the CPU registers
	pop	si
	pop	di
	pop	dx

	endm

IFDEF z64

do_instruction:
	DoInstruction
	ret

ENDIF

;*
;* jam handler 
;*

jam:	push	offset jam_msg
	call	_put_str
	dec	di			; point at jam instruction
	read	al,di
	call	ConHex			; display it
	mov	al,'@'
	call	ConOut
	mov	ax,di
	call	ConWord			; display address

IFNDEF z64
WaitEsc:test	[KeyTable+KeyEsc],128	; wait for ESC to be pressed
	jz	WaitEsc
ENDIF
	jmp	GoDOS

;*
;* Reset the CPU
;*

Reset:	mov	[reg_sp],0FFh		; SP initialises to 255
	mov	bx,0FFFCh		; get reset address
	read	dl,bx			; from 0fffc,0fffd
	inc	bx
	read	dh,bx
	mov	[reg_pc],dx
	ret

;*
;* Handle relative jumps
;*

DoBranch:
        fetchsx dx			; sign-extended branch offset into dx

	mov	bx,di			; bh is	the current page
	add	dx,di			; destination address
	mov	di,dx			; set the program counter

	bumpclock			; branch is taken -- one extra cycle
	cmp	bh,dh			; page changed ?
	je	dbjn
	bumpclock			;   yes, another cycle
dbjn:	ret

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

op_weird	00,BRK
op_read		01,ORA,ind_x

op_rmw		03,SLO,ind_x
op_read		04,NOP,zero
op_read		05,ORA,zero
op_rmw		06,ASL,zero
op_rmw		07,SLO,zero
op_weird	08,PHP
op_immediate	09,ORA
op_register	0a,ASL,al
op_immediate	0b,ANC
op_read		0c,NOP,abs
op_read		0d,ORA,abs
op_rmw		0e,ASL,abs
op_rmw		0f,SLO,abs
op_branch	10,[RNTest],128,jz
op_read		11,ORA,ind_y

op_rmw		13,SLO,ind_y
op_read		14,NOP,zero_x
op_read		15,ORA,zero_x
op_rmw		16,ASL,zero_x
op_rmw		17,SLO,zero_x
op_transfer	18,ah,0
op_read		19,ORA,abs_y
op_transfer	1a,al,al
op_rmw		1b,SLO,abs_y
op_read		1c,NOP,abs_x
op_read		1d,ORA,abs_x
op_rmw		1e,ASL,abs_x
op_rmw		1f,SLO,abs_x
op_weird	20,JSR
op_read		21,AND,ind_x

op_rmw		23,RLA,ind_x
op_read		24,BIT,zero
op_read		25,AND,zero
op_rmw		26,ROL,zero
op_rmw		27,RLA,zero
op_weird	28,PLP
op_immediate	29,AND
op_register	2a,ROL,al

op_read		2c,BIT,abs
op_read		2d,AND,abs
op_rmw		2e,ROL,abs
op_rmw		2f,RLA,abs
op_branch	30,[RNTest],128,jnz
op_read		31,AND,ind_y

op_rmw		33,RLA,ind_y
op_read		34,NOP,zero
op_read		35,AND,zero_x
op_rmw		36,ROL,zero_x
op_rmw		37,RLA,zero_x
op_transfer	38,ah,1
op_read		39,AND,abs_y
op_transfer	3a,al,al
op_rmw		3b,RLA,abs_y
op_read		3c,NOP,abs_x
op_read		3d,AND,abs_x
op_rmw		3e,ROL,abs_x
op_rmw		3f,RLA,abs_x
op_weird	40,RTI
op_read		41,EOR,ind_x

op_rmw		43,SRE,ind_x
op_read		44,NOP,zero
op_read		45,EOR,zero
op_rmw		46,LSR,zero
op_rmw		47,SRE,zero
op_weird	48,PHA
op_immediate	49,EOR
op_register	4a,LSR,al
op_immediate	4b,ASR
op_weird	4c,JMPW
op_read		4d,EOR,abs
op_rmw		4e,LSR,abs
op_rmw		4f,SRE,abs
op_branch	50,[flag_V],0ffh,jz
op_read		51,EOR,ind_y

op_rmw		53,SRE,ind_y
op_read		54,NOP,zero_x
op_read		55,EOR,zero_x
op_rmw		56,LSR,zero_x
op_rmw		57,SRE,zero_x
op_transfer	58,[flag_I],0
op_read		59,EOR,abs_y
op_transfer	5a,al,al
op_rmw		5b,SRE,abs_y
op_read		5c,NOP,abs_x
op_read		5d,EOR,abs_x
op_rmw		5e,LSR,abs_x
op_rmw		5f,SRE,abs_x
op_weird	60,RTS
op_read		61,ADC,ind_x

op_rmw		63,RRA,ind_x
op_read		64,NOP,zero
op_read		65,ADC,zero
op_rmw		66,ROR,zero
op_rmw		67,RRA,zero
op_weird	68,PLA
op_immediate	69,ADC
op_register	6a,ROR,al
op_immediate	6b,ARR
op_weird	6c,JMPI
op_read		6d,ADC,abs
op_rmw		6e,ROR,abs
op_rmw		6f,RRA,abs
op_branch	70,[flag_V],0ffh,jnz
op_read		71,ADC,ind_y

op_rmw		73,RRA,ind_y
op_read		74,NOP,zero_x
op_read		75,ADC,zero_x
op_rmw		76,ROR,zero_x
op_rmw		77,RRA,zero_x
op_transfer	78,[flag_I],1
op_read		79,ADC,abs_y
op_transfer	7a,al,al
op_rmw		7b,RRA,abs_y
op_read		7c,NOP,abs_x
op_read		7d,ADC,abs_x
op_rmw		7e,ROR,abs_x
op_rmw		7f,RRA,abs_x
op_immediate	80,NOP
op_write	81,STA,ind_x
op_immediate	82,NOP
op_write	83,SAX,ind_x
op_write	84,STY,zero
op_write	85,STA,zero
op_write	86,STX,zero
op_write	87,SAX,zero
op_register	88,DEC,[reg_y]
op_immediate	89,NOP
op_transfertest	8a,al,[reg_x]
op_immediate	8b,ANE
op_write	8c,STY,abs
op_write	8d,STA,abs
op_write	8e,STX,abs
op_write	8f,SAX,abs
op_branch	90,ah,ah,jz
op_write	91,STA,ind_y

op_write	93,SHA,ind_y
op_write	94,STY,zero_x
op_write	95,STA,zero_x
op_write	96,STX,zero_y
op_write	97,SAX,zero_y
op_transfertest	98,al,[reg_y]
op_write	99,STA,abs_y
op_transfer	9a,[reg_sp],[reg_x]
op_write	9b,SHS,abs_y
op_write	9c,SHY,abs_x
op_write	9d,STA,abs_x
op_write	9e,SHX,abs_y
op_write	9f,SHA,abs_y
op_immediate	a0,LDY
op_read		a1,LDA,ind_x
op_immediate	a2,LDX
op_read		a3,LAX,ind_x
op_read		a4,LDY,zero
op_read		a5,LDA,zero
op_read		a6,LDX,zero
op_read		a7,LAX,zero
op_transfertest	a8,[reg_y],al
op_immediate	a9,LDA
op_transfertest	aa,[reg_x],al
op_immediate	ab,LXA
op_read		ac,LDY,abs
op_read		ad,LDA,abs
op_read		ae,LDX,abs
op_read		af,LAX,abs
op_branch	b0,ah,ah,jnz
op_read		b1,LDA,ind_y

op_read		b3,LAX,ind_y
op_read		b4,LDY,zero_x
op_read		b5,LDA,zero_x
op_read		b6,LDX,zero_y
op_read		b7,LAX,zero_y
op_transfer	b8,[flag_V],0
op_read		b9,LDA,abs_y
op_transfertest	ba,[reg_x],[reg_sp]
op_read		bb,LAS,abs_y
op_read		bc,LDY,abs_x
op_read		bd,LDA,abs_x
op_read		be,LDX,abs_y
op_read		bf,LAX,abs_y
op_immediate	c0,CPY
op_read		c1,CMP,ind_x
op_immediate	c2,NOP
op_rmw		c3,DCP,ind_x
op_read		c4,CPY,zero
op_read		c5,CMP,zero
op_rmw		c6,DEC,zero
op_rmw		c7,DCP,zero
op_register	c8,INC,[reg_y]
op_immediate	c9,CMP
op_register	ca,DEC,[reg_x]
op_immediate	cb,SBX
op_read		cc,CPY,abs
op_read		cd,CMP,abs
op_rmw		ce,DEC,abs
op_rmw		cf,DCP,abs
op_branch	d0,[RZTest],0ffh,jnz
op_read		d1,CMP,ind_y

op_rmw		d3,DCP,ind_y
op_read		d4,NOP,zero_x
op_read		d5,CMP,zero_x
op_rmw		d6,DEC,zero_x
op_rmw		d7,DCP,zero_x
op_transfer	d8,[flag_D],0
op_read		d9,CMP,abs_y
op_transfer	da,al,al
op_rmw		db,DCP,abs_y
op_read		dc,NOP,abs_x
op_read		dd,CMP,abs_x
op_rmw		de,DEC,abs_x
op_rmw		df,DCP,abs_x
op_immediate	e0,CPX
op_read		e1,SBC,ind_x
op_immediate	e2,NOP
op_rmw		e3,ISB,ind_x
op_read		e4,CPX,zero
op_read		e5,SBC,zero
op_rmw		e6,INC,zero
op_rmw		e7,ISB,zero
op_register	e8,INC,[reg_x]
op_immediate	e9,SBC
op_transfer	ea,al,al

op_read		ec,CPX,abs
op_read		ed,SBC,abs
op_rmw		ee,INC,abs
op_rmw		ef,ISB,abs
op_branch	f0,[RZTest],0ffh,jz
op_read		f1,SBC,ind_y

op_rmw		f3,ISB,ind_y
op_read		f4,NOP,zero_x
op_read		f5,SBC,zero_x
op_rmw		f6,INC,zero_x
op_rmw		f7,ISB,zero_x
op_transfer	f8,[flag_D],1
op_read		f9,SBC,abs_y
op_transfer	fa,al,al
op_rmw		fb,ISB,abs_y
op_read		fc,NOP,abs_x
op_read		fd,SBC,abs_x
op_rmw		fe,INC,abs_x
op_rmw		ff,ISB,abs_x
