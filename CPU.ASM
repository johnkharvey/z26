;*
;* 6502 Emulation Macros
;*
;* ALL READING/WRITING DONE VIA READ/WRITE
;*

; (0.90)  Jan 24, 1998	changed to Perazzoli's timing for some indexed stuff
;                       with absolutey_rmw, absolutex_rmw
;			SAX, RLA, RRA, ISB, SLO

; 05-20-98 -- set break flag when doing BRK
;             force break when doing PHP
; 05-22-98    move some variables to cpu.asm file
;             don't set overflow when doing CMP, CPX, CPY

.CEND
.DATASEGMENT

; *****************************************************************************
;		       6502 Register Set (storage)
;	during emulation these locations do not contain correct data !
; *****************************************************************************

reg_pc		dw	0		; program counter (stored in BP)


; note: the following two locations must be in this order and next to each other

reg_a		db	0		; accumulator (stored in AL)
flag_carry	db	0		; carry bit (stored in AH)

reg_x		db	0		; x register
		db	0		;   extra byte to allow 16-bit load & store (see _index)
reg_y		db	0		; y register
		db	0		;   extra byte to allow 16-bit load & store (see _index)

reg_sp		db	0		; stack pointer

; the accumulator is stored in the following vars for later testing

RZTest		db	0		; value for zero test (Z set when 0)
RNTest		db	0		; value for sign test (N set when negative)

; these vars hold the values of flags other than Z and N

flag_decimal	db	0		; decimal flag
flag_overflow	db	0		; overflow flag
flag_interrupt	db	0		; interrupt disable flag
flag_break	db	0		; Break flag

FEnd=$					; end of memory to clear on a reset

ALIGN 2

RClock		db	0		; clock cycles (stored in SI)
RCycles		db	0		; cycles for this instruction.

SubVector	dw	DoSbc		; vectors for add and subtract
AddVector	dw	DoAdc

LastCycle	db	0		; for DoInstructions




ALIGN 2

; Vectors and Opcodes for the 6507 interpreter

vectors dw op00,op01, jam,op03,op04,op05,op06,op07
	dw op08,op09,op0a,op0b,op0c,op0d,op0e,op0f
	dw op10,op11, jam,op13,op14,op15,op16,op17
	dw op18,op19,op1a,op1b,op1c,op1d,op1e,op1f

	dw op20,op21, jam,op23,op24,op25,op26,op27
	dw op28,op29,op2a,op0b,op2c,op2d,op2e,op2f	; op2b is same as op0b
	dw op30,op31, jam,op33,op34,op35,op36,op37
	dw op38,op39,op3a,op3b,op3c,op3d,op3e,op3f

	dw op40,op41, jam,op43,op44,op45,op46,op47
	dw op48,op49,op4a,op4b,op4c,op4d,op4e,op4f
	dw op50,op51, jam,op53,op54,op55,op56,op57
	dw op58,op59,op5a,op5b,op5c,op5d,op5e,op5f

	dw op60,op61, jam,op63,op64,op65,op66,op67
	dw op68,op69,op6a,op6b,op6c,op6d,op6e,op6f
	dw op70,op71, jam,op73,op74,op75,op76,op77
	dw op78,op79,op7a,op7b,op7c,op7d,op7e,op7f

	dw op80,op81,op82,op83,op84,op85,op86,op87
	dw op88,op89,op8a,op8b,op8c,op8d,op8e,op8f
	dw op90,op91, jam,op93,op94,op95,op96,op97
	dw op98,op99,op9a,op9b,op9c,op9d,op9e,op9f

	dw opa0,opa1,opa2,opa3,opa4,opa5,opa6,opa7
	dw opa8,opa9,opaa,opab,opac,opad,opae,opaf
	dw opb0,opb1, jam,opb3,opb4,opb5,opb6,opb7
	dw opb8,opb9,opba,opbb,opbc,opbd,opbe,opbf

	dw opc0,opc1,opc2,opc3,opc4,opc5,opc6,opc7
	dw opc8,opc9,opca,opcb,opcc,opcd,opce,opcf
	dw opd0,opd1, jam,opd3,opd4,opd5,opd6,opd7
	dw opd8,opd9,opda,opdb,opdc,opdd,opde,opdf

	dw ope0,ope1,ope2,ope3,ope4,ope5,ope6,ope7
	dw ope8,ope9,opea,ope9,opec,oped,opee,opef	; opeb is same as ope9
	dw opf0,opf1, jam,opf3,opf4,opf5,opf6,opf7
	dw opf8,opf9,opfa,opfb,opfc,opfd,opfe,opff

; *****************************************************************************
;			    Cycles per instruction
; *****************************************************************************
;	      0	 1  2  3  4  5	6  7  8	 9  a  b  c  d	e  f
Cycles	db    7, 6, 2, 8, 3, 3, 5, 5, 3, 2, 2, 2, 4, 4, 6, 6  ; 0
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; 1
	db    6, 6, 2, 8, 3, 3, 5, 5, 4, 2, 2, 2, 4, 4, 6, 6  ; 2
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; 3
	db    6, 6, 2, 8, 3, 3, 7, 5, 3, 2, 2, 2, 3, 4, 6, 6  ; 4
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; 5
	db    6, 6, 2, 8, 3, 3, 5, 5, 4, 2, 2, 2, 5, 4, 6, 6  ; 6
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; 7
	db    2, 6, 2, 6, 3, 3, 3, 3, 2, 2, 2, 2, 4, 4, 4, 4  ; 8
	db    2, 6, 2, 6, 4, 4, 4, 4, 2, 5, 2, 5, 5, 5, 5, 5  ; 9
	db    2, 6, 2, 6, 3, 3, 3, 3, 2, 2, 2, 2, 4, 4, 4, 4  ; a
	db    2, 5, 2, 5, 4, 4, 4, 4, 2, 4, 2, 4, 4, 4, 4, 4  ; b
	db    2, 6, 2, 8, 3, 3, 5, 5, 2, 2, 2, 2, 4, 4, 6, 6  ; c
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; d
	db    2, 6, 2, 8, 3, 3, 5, 5, 2, 2, 2, 2, 4, 4, 6, 6  ; e
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; f


jam_msg	db	'Halt ','$'
uuo_msg	db	'Bad opcode ','$'


.DEND
.CODESEGMENT

;*
;* memory accessing macros -- get data via op2 (usually bx)
;*

read    macro   op1,op2                 ; read memory at #2 to #1
        
        mov     si,op2
        call    [ReadBank]              ; call the bank read function
        mov     op1,byte ptr [si]
        endm
      
readsx  macro   op1,op2                 ; read memory at #2 to #1
                                        ; sign extended
        mov     si,op2
        call    [ReadBank]              ; call the bank read function
        movsx   op1,byte ptr [si]
        endm

readzx  macro   op1,op2                 ; read memory at #2 to #1
                                        ; sign extended
        mov     si,op2
        call    [ReadBank]              ; call the bank read function
        movzx   op1,byte ptr [si]
        endm

read16  macro op1,op2
        mov     si,op2
        call    [ReadBank]
        mov     op1,word ptr [si]
        endm

zread   macro   op1,op2                 ; zero page read
        mov     si,op2
        call    ReadHardwarePage0
        mov     op1,[si]
        endm
        


write   macro   op1,op2                 ; write #1 to memory at #2
        mov     si,op2                  ; set address
        mov     [WByte],op1             ; set data
        call    [WriteBank]
        endm

zwrite  macro   op1,op2                 ; zeropage write
        mov     si,op2                  ; set address
        mov     [WByte],op1             ; set data
        call    WriteHardwarePage0      ; and write
        endm

zrewrite macro op1			; page zero rewrite byte in #1
	mov	byte ptr [si],op1
	endm



fetch   macro   op1
        read    op1,bp
        inc     bp
        endm

fetchsx macro   op1
        readsx  op1,bp
        inc     bp
        endm

fetchzx macro   op1
        readzx  op1,bp
        inc     bp
        endm

fetch_opcode macro   op1		; special fetchzx for trace logging
        readzx  op1,bp
        inc     bp
        endm

fetch16 macro   op1
        read16  op1,bp
        add     bp,2
        endm


;*
;* memory addressing macros -- get operand address into bx
;*

IFDEF memcheats
absolute macro
        fetch16 bx
        endm
ELSE
absolute macro                          ; fetch absolute address to bx
        fetch   bl
        fetch   bh
        endm
ENDIF   


zeropage macro                          ; fetch zero page to bx
	fetchzx	bx
        endm


_index macro    op1
        add     bx,word ptr[op1]        ;this is not a cheat
        endm


indexx  macro                           ; x index
        _index  reg_x
        endm
        

indexy  macro                           ; y index
        _index  reg_y
        endm


bumpclock macro
	inc	[RClock]
	inc	[RCycles]
	endm

pagechange macro
        local   M1
        
        cmp     dh,bh                   ; page changed
        jz      M1
	bumpclock
M1:
        endm

IFDEF memcheats
readaddress macro
	and	bx,0ffh			; must be in page zero
        read16  bx,bx
        endm
ELSE
readaddress macro                       ; read data in bx -> bx
        and	bx,0ffh			; must be in page zero
        read    dl,bx
        inc     bl
        read    dh,bx
        mov     bx,dx
        endm
ENDIF   


absolutex macro                         ; absolute,x EAC
        absolute
        mov     dx,bx			; set up for pagechange test
        indexx
	pagechange
        endm

absolutex_rmw macro			; * Perazzoli *
	absolute
	indexx
	bumpclock
	endm	

x_absolutex_rmw macro
	absolutex
	endm

absolutey macro                         ; absolute,y EAC
        absolute
        mov     dx,bx			; set up for pagechange test
        indexy
	pagechange
        endm

absolutey_rmw macro			; * Perazzoli *
	absolute
	indexy
	bumpclock
	endm

x_absolutey_rmw macro
	absolutey
	endm

zeropagex macro                         ; zeropage,x EAC
        zeropage
        add     bl,[reg_x]
        endm


zeropagey macro                         ; zeropage,y EAC
        zeropage
        add     bl,[reg_y]
        endm


indirectx macro                         ; (indirect,x) EAC
        zeropage
        indexx
        readaddress
        endm


indirecty macro                         ; (indirect),y EAC
        zeropage
        readaddress
        mov     dx,bx			; set up for pagechange macro
        indexy
	pagechange
        endm


;*
;* get relative branch address
;*

relative macro                          ; sign extend fetch byte -> dx
        fetchsx dx
        endm


;*
;* flag setting macros
;*

useztest macro  op1                     ; use #1 to test Z
        mov     [RZTest],op1
        endm
        

usentest macro  op1                     ; use #1 to test N      
        mov     [RNTest],op1
        endm
        

usetest macro   op1                     ; use #1 to test both N and Z (normal)
        useztest op1
        usentest op1
        endm


;*
;* arithmetic macros
;*

;* don't disturb si in these macros!

DoASL macro
	shl	dl,1
	setc	ah
        usetest dl                      ; update the Z & N value registers
        endm

DoROL macro
        shr     ah,1
        rcl     dl,1
        setc	ah
        usetest dl
        endm

DoROR macro
        shr     ah,1
        rcr     dl,1
	setc	ah
        usetest dl
        endm

DoLSR macro
        shr     dl,1                    ; shift it right
	setc	ah
        usetest dl                      ; use the result to test
        endm

DoSAX macro
	mov	dl,al
	and	dl,[reg_x]
	endm

DoRLA macro
	shr	ah,1
	rcl	dl,1
	setc	ah
	and	al,dl
	usetest	al
	endm

DoRRA macro
	shr	ah,1
	rcr	dl,1
	setc	ah
	call	[AddVector]
	endm

DoISB macro
	inc	dl
	call	[SubVector]
	endm

DoSLO macro
	shl	dl,1
	setc	ah
	or	al,dl
;	mov	dl,al
	usetest	al
	endm

DoSRE macro
	mov	ah,1
	and	ah,dl
	shr	dl,1
	xor	al,dl
	usetest	al
	endm


; load CPU registers

LoadRegs macro
	mov	ax,word ptr [reg_a]	; mov al,[reg_a]; mov ah,[flag_carry]
	mov	bp,[reg_pc]
	endm

; save CPU registers

SaveRegs macro
	mov	word ptr [reg_a],ax	; mov [reg_a],al; mov [flag_carry],ah
	mov	[reg_pc],bp
	endm

;*
;* do some instructions until RClock >= al
;*

ALIGN_ENTRY

DoInstructions:
	mov	[LastCycle],al		; last cycle to do
	push	dx
	push	bp
	push	si
	LoadRegs			; load the CPU registers

InstructionLoop:
	fetch_opcode	ebx		; (fetchzx) get the opcode
	mov	dl,Cycles[bx]		; get cycles takes to do it
	mov	[RCycles],dl		; save the number of cycles
	add	[RClock],dl		; add to the clock
	call	[vectors + ebx*2]	; --> do the instruction
	call	[TimerVec]		; clock the RIOT timer

	cmp	[VsyncPending],0	; was Vsync set this instruction ?
	jne	InstructionsDone	;    yes, fast exit

	mov	bh,[LastCycle]
	cmp	[RClock],bh
	jl	InstructionLoop

InstructionsDone:
	mov	dl,[RClock]
	mov	dh,[RClock]
	add	dl,dl
	sub	dh,[CPUOffset]
	add	dl,dh
	mov	[CPUClock],dl		; CPUClock = 3 * RClock - CPUOffset

	SaveRegs			; save the CPU registers
	pop	si
	pop	bp
	pop	dx

InsRet:	ret


ALIGN_ENTRY


;*
;* do a single instruction
;*

DoInstruction macro
	push	dx
	push	bp
	push	si
	LoadRegs			; load the CPU registers

	fetch_opcode	ebx		; (fetchzx) get the opcode
	mov	dl,Cycles[bx]		; get cycles takes to do it
	mov	[RCycles],dl		; save the number of cycles
	add	[RClock],dl		; add to the clock
	call	[vectors + ebx*2]	; --> do the instruction

	mov	dl,[RClock]
	mov	dh,[RClock]
	add	dl,dl
	sub	dh,[CPUOffset]
	add	dl,dh
	mov	[CPUClock],dl		; CPUClock = 3 * RClock - CPUOffset

	call	[TimerVec]		; clock the RIOT timer

	SaveRegs			; save the CPU registers
	pop	si
	pop	bp
	pop	dx

	endm

IFDEF z64

do_instruction:
	push	dx
	push	bp
	push	si
	LoadRegs			; load the CPU registers

	fetch_opcode	ebx		; (fetchzx) get the opcode
	mov	dl,Cycles[bx]		; get cycles takes to do it
	mov	[RCycles],dl		; save the number of cycles
	add	[RClock],dl		; add to the clock
	call	[vectors + ebx*2]	; --> do the instruction

	mov	dl,[RClock]
	mov	dh,[RClock]
	add	dl,dl
	sub	dh,[CPUOffset]
	add	dl,dh
	mov	[CPUClock],dl		; CPUClock = 3 * RClock - CPUOffset

	call	[TimerVec]		; clock the RIOT timer

	SaveRegs			; save the CPU registers
	pop	si
	pop	bp
	pop	dx
	ret

ENDIF

;*
;* come here when duff opcode 
;*

ALIGN_ENTRY

jam:
	push	offset jam_msg
	call	_put_str
	jmp	showinst

fail:
	push	offset uuo_msg
	call	_put_str

showinst:
	dec	bp			; backup the instruction pointer
	read	al,bp			; read the byte
	call	ConHex			; display it
	mov	al,'@'			; here comes the address
	call	ConOut
	mov	ax,bp			; pick up the address
	call	ConWord			; display it

IFNDEF z64
WaitEsc:test	[KeyTable+KeyEsc],128	; wait for ESC to be pressed
	jz	WaitEsc
ENDIF

	jmp	GoDOS


; *****************************************************************************
;				Reset the CPU
; *****************************************************************************

ALIGN_ENTRY

Reset:	push	bx
	mov	bx,FEnd	- reg_a - 1
ResLoop:mov	byte ptr reg_a[bx],0
	dec	bx
	jge	ResLoop
	pop	bx
	LoadRegs
	mov	[reg_sp],0FFh		; SP initialises to 255
	mov	bp,0FFFCh		; get reset address
	read	bl,bp			; from 0fffc,0fffd
	inc	bp
	read	bh,bp
	mov	bp,bx			; and set the pctr
	SaveRegs
	ret

; *****************************************************************************
;		Set vectors according to Decimal Flag
; *****************************************************************************

ALIGN_ENTRY

SetMathVectors:
	push	ax
	cmp	[flag_decimal],0
	jz	SMVBinary

	mov	ax,offset ADCBCD
	mov	[AddVector],ax
	mov	ax,offset SBCBCD
	mov	[SubVector],ax

	jmp	SMVExit
SMVBinary:
	mov	ax,offset DoSbc
	mov	[SubVector],ax
	mov	ax,offset DoAdc
	mov	[AddVector],ax
SMVExit:
	pop	ax
	ret

; *****************************************************************************
;      Build the PSW out of the	various	flags and the last register into DL
; *****************************************************************************

ALIGN_ENTRY

GetPSW:	push	ax
	mov	dl,[RNTest]		; dl = last result
	and	dl,128			; use bit 7 of that as the N bit

	mov	al,[flag_overflow]	; bit 6	is the overflow	flag
	and	al,1
	shl	al,6
	or	dl,al

	or	dl,020H			; bit 5	is always set

	mov	al,[flag_break]		; bit 4	is the break flag
	and	al,1
	shl	al,4
	or	dl,al

	mov	al,[flag_decimal]	; bit 3	is the decimal flag
	and	al,1
	shl	al,3
	or	dl,al

	mov	al,[flag_interrupt]	; bit 2	is interrupt disable
	and	al,1
	shl	al,2
	or	dl,al

	cmp	[RZTest],0		; bit 1 is zero flag.
	jnz	PSWZero
	or	dl,002H

PSWZero:or	dl,ah			; bit 0	is Carry
	pop ax
	ret

; *****************************************************************************
;	   CMP code. AL	= acc,BX points	to data
; *****************************************************************************

ALIGN_ENTRY

DoCmp macro
	mov	dh,al

	sub	dh,dl
	usetest	dh
	cmc
	setc	ah

	endm

; *****************************************************************************
;			Compare	DH vs DL
; *****************************************************************************

ALIGN_ENTRY

CompDH macro
	sub	dh,dl
	usetest	dh
	setnc	ah
	
	endm
	
; *****************************************************************************
;	 SBC code. AL is accumulator,AH	is carry bit,BX	points to data
; *****************************************************************************

ALIGN_ENTRY

DoSbc:
	shr	ah,1
	cmc			; set carry
	sbb	al,dl
	seto	[flag_overflow]
	usetest	al
	setnc	ah
	ret


; *****************************************************************************
;	 ADC code. AL is accumulator,AH	is carry bit, DL has data
; *****************************************************************************

ALIGN_ENTRY

DoAdc:
	shr	ah,1
	adc	al,dl
	seto	[flag_overflow]
	usetest	al
	setc	ah
	ret

;*
;* ADC Decimal  
;* AL is accumulator,AH is carry bit, dl has data
;*

ALIGN_ENTRY

ADCBCD:
	jmp	_ADCdecimal	; use routine in pmath.asm

        
;*
;* SBC Decimal for quiche eaters.
;* AL is accumulator,AH is carry bit,BX points to data
;* this routine is not currently in use (see math.asm)
;*

ALIGN_ENTRY

SBCBCD:
	jmp	_SBCdecimal

	shr	ah,1		;set up	carry bit
	cmc			;6502 needs complement
	sbb	al,dl
	usetest	al
	seto	[flag_overflow]
	das
	cmc
	setc	ah
	ret


;*
;* opcode handlers
;*
        

; BRK -- programmed interrupt

ALIGN_ENTRY

op00:	
	mov	[flag_break],1	;+
	mov	dx,bp		; return address in dx
	mov	bl,[reg_sp]	; bx is	stack address
	mov	bh,1
	write	dh,bx		; push return address
	dec	bl
	write	dl,bx
	dec	[reg_sp]
	dec	[reg_sp]
	call	op08		; push PSW
	mov	bx,0FFFEh	; fetch	the vector
	read	dl,bx
	inc	bx
	read	dh,bx
	mov	bp,dx		; and transfer execution to addr there
	ret


; ORA (adr,X)

ALIGN_ENTRY

op01:	indirectx
	read	dl,bx
	or	al,dl
	usetest	al
	ret


; SLO (adr,X) (undoc)

ALIGN_ENTRY

op03:	indirectx
	read	dl,bx
	DoSLO
	write	dl,bx
	ret


; NOP adr (undoc)

ALIGN_ENTRY

op04:	inc	bp
	ret


; ORA adr

ALIGN_ENTRY

op05:	zeropage
	zread	dl,bx
	or	al,dl
	usetest	al
	ret


; ASL adr

ALIGN_ENTRY

op06:	zeropage
	zread	dl,bx
	DoASL
	zwrite dl,bx
	ret


; SLO adr (undoc)

ALIGN_ENTRY

op07:	zeropage
	zread	dl,bx
	DoSLO
	zwrite	dl,bx
	ret


; PHP -- push processor	status word

ALIGN_ENTRY

op08:	call	GetPSW		; get PSW in DL

	or	dl,010h		;+ force break flag

	mov	bl,[reg_sp]	; bx points to stack
	mov	bh,1
	write	dl,bx		; save it on the stack
	dec	[reg_sp]	; decrement Stack pointer
	ret


; ORA data

ALIGN_ENTRY

op09:	fetch	dl
	or	al,dl
	usetest	al
	ret


; ASL A

ALIGN_ENTRY

op0a:	mov	dl,al
	DoASL
	mov	al,dl
	ret


; ANC data (undoc)

ALIGN_ENTRY

op0b:	fetch	dl
	and	al,dl
	usetest	al
	test	al,080h
	setnz	ah
	ret	


; NOP adr16 (undoc)

ALIGN_ENTRY

op0c:	add	bp,2
	ret


; ORA adr16

ALIGN_ENTRY

op0d:	absolute
	read	dl,bx
	or	al,dl
	usetest	al
	ret


; ASL adr16

ALIGN_ENTRY

op0e:	absolute
	read	dl,bx
	DoASL
	write	dl,bx
	ret


; SLO adr16 (undoc)

ALIGN_ENTRY

op0f:	absolute
	read	dl,bx
	DoSLO
	write	dl,bx
	ret


; BPL disp -- branch if	plus

ALIGN_ENTRY

op10:
	test	[RNTest],128
	jz	DoBranch
	inc	bp
	ret


; ORA (adr),Y

ALIGN_ENTRY

op11:	indirecty
	read	dl,bx
	or	al,dl
	usetest	al
	ret


; SLO (adr),y (undoc)

ALIGN_ENTRY

op13:	indirecty
	read	dl,bx
	DoSLO
	write	dl,bx
	ret


; NOP adr,X (undoc)

ALIGN_ENTRY

op14:	inc	bp
	ret


; ORA adr,X

ALIGN_ENTRY

op15:	zeropagex
	zread	dl,bx
	or	al,dl
	usetest	al
	ret


; ASL adr,X

ALIGN_ENTRY

op16:	zeropagex
	zread	dl,bx
	DoASL
	zwrite dl,bx
	ret


; SLO adr,X (undoc)

ALIGN_ENTRY

op17:	zeropagex
	zread	dl,bx
	DoSLO
	zwrite	dl,bx
	ret


; CLC -- clear carry flag

ALIGN_ENTRY

op18:	xor	ah,ah
	ret


; ORA adr16,Y

ALIGN_ENTRY

op19:	absolutey
	read	dl,bx
	or	al,dl
	usetest	al
	ret


; NOP (undoc)

ALIGN_ENTRY

op1a:	ret


; SLO adr16,Y (undoc)

ALIGN_ENTRY

op1b:	absolutey_rmw
	read	dl,bx
	DoSLO
	write	dl,bx
	ret


; NOP adr16,X (undoc)

ALIGN_ENTRY

op1c:	absolutex
	ret


; ORA adr16,X

ALIGN_ENTRY

op1d:	absolutex
	read	dl,bx
	or	al,dl
	usetest	al
	ret


; ASL adr16,X

ALIGN_ENTRY

op1e:	absolutex_rmw		; * Perazzoli *
	read	dl,bx
	DoASL
	write	dl,bx
	ret


; SLO adr16,X (undoc)

ALIGN_ENTRY

op1f:	absolutex_rmw
	read	dl,bx
	DoSLO
	write	dl,bx
	ret


; JSR adr16 -- call subroutine

ALIGN_ENTRY

op20:	absolute		; call address in bx now
	push	ax
	mov	ax,bp		; ax is	the return address
	mov	bp,bx		; transfer control
	dec	ax		; push return-1
	mov	bl,[reg_sp]	; bl is	the stack index
	mov	bh,1
	write	ah,bx		; push the return address
	dec	bl
	write	al,bx
	sub	[reg_sp],2	; decrement the	stack pointer
	pop	ax

IFDEF z64

	cmp	bp,0ff00h
	jae	KernalHandler

ENDIF

	ret


; AND (adr,X)

ALIGN_ENTRY

op21:	indirectx
	read	dl,bx
	and	al,dl
	usetest	al
	ret


; RLA (adr,X) (undoc)

ALIGN_ENTRY

op23:	indirectx
	read	dl,bx
	DoRLA
	write	dl,bx
	ret


; BIT adr

ALIGN_ENTRY

op24:	zeropage		; bx = zero page.
BitTest:read	dl,bx		; read the byte
	test	dl,040h		; bit 6 is the overflow flag
	setnz	[flag_overflow]
	usentest dl		; the memory bit 7 is the n flag
	and	dl,al		; this is the and result
	useztest dl		; use it to test for zero
	ret


; AND adr

ALIGN_ENTRY

op25:	zeropage
	zread	dl,bx
	and	al,dl
	usetest	al
	ret


; ROL adr

ALIGN_ENTRY

op26:	zeropage
	zread	dl,bx
	DoROL
	zwrite dl,bx
	ret


; RLA adr (undoc)

ALIGN_ENTRY

op27:	zeropage
	zread	dl,bx
	DoRLA
	zwrite	dl,bx
	ret


; PLP -- pull PSW

ALIGN_ENTRY

op28:	inc	[reg_sp]	; increment the	stack pointer
	mov	bl,[reg_sp]	; and read the top byte
	mov	bh,1		; into dh
	read	dh,bx
	mov	[RNTest],dh	; it will do for use as	the N Flag
	mov	ah,dh
	and	ah,1		; bit 0 is the carry flag
	test	dh,02h		; bit 1 is the zero flag
	setz	[RZTest]
	test	dh,04h		; bit 2 is the intdis flag
	setnz	[flag_interrupt]
	test	dh,08h		; bit 3 is the decimal flag
	setnz	[flag_decimal]
	test	dh,010h		; bit 4 is the break flag
	setnz	[flag_break]
	test	dh,040h		; bit 6 is overflow
	setnz	[flag_overflow]
	call	SetMathVectors
	ret

; AND data

ALIGN_ENTRY

op29:	fetch	dl
	and	al,dl
	usetest	al
	ret


; ROL A

ALIGN_ENTRY

op2a:	mov	dl,al
	DoROL
	mov	al,dl
	ret


; BIT adr16

ALIGN_ENTRY

op2c:	absolute
	jmp	BitTest


; AND adr16

ALIGN_ENTRY

op2d:	absolute
	read	dl,bx
	and	al,dl
	usetest	al
	ret


; ROL adr16

ALIGN_ENTRY

op2e:	absolute
	read	dl,bx
	DoROL
	write	dl,bx
	ret


; RLA adr16 (undoc)

ALIGN_ENTRY

op2f:	absolute
	read	dl,bx
	DoRLA
	write	dl,bx
	ret

; BMI disp -- branch if	minus

ALIGN_ENTRY

op30:	
	test	[RNTest],128
	jnz	DoBranch
	inc	bp
	ret


; AND (adr),Y

ALIGN_ENTRY

op31:	indirecty
	read	dl,bx
	and	al,dl
	usetest	al
	ret


; RLA (adr),Y (undoc)

ALIGN_ENTRY

op33:	indirecty
	read	dl,bx
	DoRLA
	write	dl,bx
	ret


; NOP adr,x (undoc)

ALIGN_ENTRY

op34:	inc	bp
	ret


; AND adr,X

ALIGN_ENTRY

op35:	zeropagex
	zread	dl,bx
	and	al,dl
	usetest	al
	ret


; ROL adr,X

ALIGN_ENTRY

op36:	zeropagex
	zread	dl,bx
	DoROL
	zwrite dl,bx
	ret


; RLA adr,X (undoc)

ALIGN_ENTRY

op37:	zeropagex
	zread	dl,bx
	DoRLA
	zwrite	dl,bx
	ret


; SEC -- set carry

ALIGN_ENTRY

op38:	mov	ah,1
	ret


; AND adr16,Y

ALIGN_ENTRY

op39:	absolutey
	read	dl,bx
	and	al,dl
	usetest	al
	ret


; NOP (undoc)

ALIGN_ENTRY

op3a:	ret


; RLA adr16,Y (undoc)

ALIGN_ENTRY

op3b:	absolutey_rmw
	read	dl,bx
	DoRLA
	write	dl,bx
	ret


; NOP adr16,X (undoc)

ALIGN_ENTRY

op3c:	absolutex
	ret


; AND adr16,X

ALIGN_ENTRY

op3d:	absolutex
	read	dl,bx
	and	al,dl
	usetest	al
	ret


; ROL adr16,X

ALIGN_ENTRY

op3e:	absolutex_rmw		; * Perazzoli *
	read	dl,bx
	DoROL
	write	dl,bx
	ret


; RLA adr16,X (undoc)

op3f:	absolutex_rmw
	read	dl,bx
	DoRLA
	write	dl,bx
	ret


; RTI -- return	from interrupt

ALIGN_ENTRY

op40:	call	op28		; pull psw
	inc	[reg_sp]	; same as return but don't inc PCTR
	mov	bl,[reg_sp]	; bx points to PCL to pop
	inc	[reg_sp]	; sp gone up 2 now,its ok
	mov	bh,1
	read	dl,bx		; read return address in bx
	inc	bl
	read	dh,bx
	mov	bp,dx		; and return
	ret


; EOR (adr,X)

ALIGN_ENTRY

op41:	indirectx
	read	dl,bx
	xor	al,dl
	usetest	al
	ret


; SRE (adr,X) (undoc)

ALIGN_ENTRY

op43:	indirectx
	read	dl,bx
	DoSRE
	write	dl,bx
	ret


; NOP adr (undoc)

ALIGN_ENTRY

op44:	inc	bp
	ret


; EOR adr

ALIGN_ENTRY

op45:	zeropage
	zread	dl,bx
	xor	al,dl
	usetest	al
	ret


; LSR adr

ALIGN_ENTRY

op46:	zeropage
	zread	dl,bx
	DoLSR
	zwrite dl,bx
	ret


; SRE adr (undoc)

ALIGN_ENTRY

op47:	zeropage
	zread	dl,bx
	DoSRE
	zwrite	dl,bx
	ret


; PHA -- push accumulator

ALIGN_ENTRY

op48:	mov	bl,[reg_sp]	; bx ^ stack
	mov	bh,1
	write	al,bx
	dec	[reg_sp]	; decrement stack pointer
	ret


; EOR data

ALIGN_ENTRY

op49:	fetch	dl
	xor	al,dl
	usetest	al
	ret


; LSR A

ALIGN_ENTRY

op4a:	mov	dl,al
	DoLSR
	mov	al,dl
	ret


; ASR data (undoc)

op4b:	fetch	dl
	and	al,dl
	test	al,1
	setnz	ah
	shr	al,1
	usetest	al
	ret


; JMP adr16

ALIGN_ENTRY

op4c:
IFDEF memcheats
	read16	bp,bp
ELSE
	absolute		; fetch	the address
	mov	bp,bx		; jump to it
ENDIF

IFDEF z64

	cmp	bp,0ff00h
	jae	KernalHandler

ENDIF

	ret


; EOR adr16

ALIGN_ENTRY

op4d:	absolute
	read	dl,bx
	xor	al,dl
	usetest	al
	ret


; LSR adr16

ALIGN_ENTRY

op4e:	absolute
	read	dl,bx
	DoLSR
	write	dl,bx
	ret


; SRE adr16 (undoc)

ALIGN_ENTRY

op4f:	absolute
	read	dl,bx
	DoSRE
	write	dl,bx
	ret


; BVC disp -- branch if	overflow clear

ALIGN_ENTRY

op50:	
	cmp	[flag_overflow],0
	jz	DoBranch
	inc	bp
	ret


; EOR (adr),Y

ALIGN_ENTRY

op51:	indirecty
	read	dl,bx
	xor	al,dl
	usetest	al
	ret


; SRE (adr),Y (undoc)

ALIGN_ENTRY

op53:	indirecty
	read	dl,bx
	DoSRE
	write	dl,bx
	ret


; NOP adr,X (undoc)

ALIGN_ENTRY

op54:	inc	bp
	ret


; EOR adr,X

ALIGN_ENTRY

op55:	zeropagex
	zread	dl,bx
	xor	al,dl
	usetest	al
	ret


; LSR adr,X

ALIGN_ENTRY

op56:	zeropagex
	zread	dl,bx
	DoLSR
	zwrite dl,bx
	ret


; SRE adr,X (undoc)

ALIGN_ENTRY

op57:	zeropagex
	zread	dl,bx
	DoSRE
	zwrite	dl,bx
	ret


; CLI -- clear interrupt disable

ALIGN_ENTRY

op58:	mov	[flag_interrupt],0
	ret


; EOR adr16,Y

ALIGN_ENTRY

op59:	absolutey
	read	dl,bx
	xor	al,dl
	usetest	al
	ret


; NOP (undoc)

ALIGN_ENTRY

op5a:	ret


; SRE adr16,Y (undoc)

ALIGN_ENTRY

op5b:	absolutey
	read	dl,bx
	DoSRE
	write	dl,bx
	ret


; NOP adr16,X (undoc)

ALIGN_ENTRY

op5c:	absolutex
	ret


; EOR adr16,X

ALIGN_ENTRY

op5d:	absolutex
	read	dl,bx
	xor	al,dl
	usetest	al
	ret


; LSR adr16,X

ALIGN_ENTRY

op5e:	absolutex_rmw		; * Perazzoli *
	read	dl,bx
	DoLSR
	write dl,bx
	ret


; SRE adr16,X (undoc)

ALIGN_ENTRY

op5f:	absolutex
	read	dl,bx
	DoSRE
	write	dl,bx
	ret


; RTS -- return	from subroutine

ALIGN_ENTRY

op60:	mov	bl,[reg_sp]
	mov	bh,1
	inc	bl
	add	[reg_sp],2
	read16	bp,bx		; read return address (and return)
	inc	bp
	ret


; ADC (adr,X)

ALIGN_ENTRY

op61:	indirectx
	read	dl,bx
	call	[AddVector]
	ret


; RRA (adr,X) undoc

ALIGN_ENTRY

op63:	indirectx
	read	dl,bx
	DoRRA
	write	dl,bx
	ret


; NOP adr (undoc)

ALIGN_ENTRY

op64:	inc	bp
	ret


; ADC adr

ALIGN_ENTRY

op65:	zeropage
	zread	dl,bx
	call	[AddVector]
	ret


; ROR adr

ALIGN_ENTRY

op66:	zeropage
	zread	dl,bx
	DoROR
	zwrite dl,bx
	ret


; RRA adr (undoc)

ALIGN_ENTRY

op67:	zeropage
	zread	dl,bx
	DoRRA
	zwrite	dl,bx
	ret


; PLA -- pop accumulator

ALIGN_ENTRY

op68:	inc	[reg_sp]	; increment sp
	mov	bl,[reg_sp]	; build	the read address
	mov	bh,1
	read	al,bx
	usetest	al
	ret


; ADC data

ALIGN_ENTRY

op69:	fetch	dl
	call	[AddVector]
	ret


; ROR A

ALIGN_ENTRY

op6a:	mov	dl,al
	DoROR
	mov	al,dl
	ret


; ARR data (undoc)

op6b:	fetch	dl
	jmp	_ARR


; JMP (adr16)

ALIGN_ENTRY

op6c:	absolute		; read the address of the the jump
IFDEF memcheats
	read16	bp,bx		; and jump to it
ELSE
	read	dl,bx
	inc	bx
	read	dh,bx
	mov	bp,dx		; and jump to it
ENDIF

IFDEF z64

	cmp	bp,0ff00h
	jae	KernalHandler

ENDIF

	ret


; ADC adr16

ALIGN_ENTRY

op6d:	absolute
	read	dl,bx
	call	[AddVector]
	ret


; ROR adr16

ALIGN_ENTRY

op6e:	absolute
	read	dl,bx
	DoROR
	write	dl,bx
	ret


; RRA adr16 (undoc)

ALIGN_ENTRY

op6f:	absolute
	read	dl,bx
	DoRRA
	write	dl,bx
	ret


; BVS disp -- branch if	overflow set

ALIGN_ENTRY

op70:
	cmp	[flag_overflow],0
	jnz	DoBranch
	inc	bp
	ret


; ADC (adr),Y

ALIGN_ENTRY

op71:	indirecty
	read	dl,bx
	call	[AddVector]
	ret


; RRA (adr),Y (undoc)

ALIGN_ENTRY

op73:	indirecty
	read	dl,bx
	DoRRA
	write	dl,bx
	ret


; NOP adr,X (undoc)

ALIGN_ENTRY

op74:	inc	bp
	ret


; ADC adr,X

ALIGN_ENTRY

op75:	zeropagex
	zread	dl,bx
	call	[AddVector]
	ret


; ROR adr,X

ALIGN_ENTRY

op76:	zeropagex
	zread	dl,bx
	DoROR
	zwrite dl,bx
	ret


; RRA adr,X (undoc)

ALIGN_ENTRY

op77:	zeropagex
	zread	dl,bx
	DoRRA
	zwrite	dl,bx
	ret


; SEI -- disable interrupts

ALIGN_ENTRY

op78:	mov	[flag_interrupt],1
	ret


; ADC adr16,Y

ALIGN_ENTRY

op79:	absolutey
	read	dl,bx
	call	[AddVector]
	ret


; NOP (undoc)

ALIGN_ENTRY

op7a:	ret


; RRA adr16,Y (undoc)

ALIGN_ENTRY

op7b:	absolutey_rmw
	read	dl,bx
	DoRRA
	write	dl,bx
	ret


; NOP adr16,X (undoc)

op7c:	absolutex
	ret


; ADC adr16,X

ALIGN_ENTRY

op7d:	absolutex
	read	dl,bx
	call	[AddVector]
	ret


; ROR adr16,X

ALIGN_ENTRY

op7e:	absolutex_rmw			; * Perazzoli *
	read	dl,bx
	DoROR
	write	dl,bx
	ret


; RRA adr16,X (undoc)

ALIGN_ENTRY

op7f:	absolutex_rmw
	read	dl,bx
	DoRRA
	write	dl,bx
	ret


; NOP data (undoc)

ALIGN_ENTRY

op80:	inc	bp
	ret


; STA adr,X

ALIGN_ENTRY

op81:	indirectx
	write	al,bx
	ret


; NOP data (undoc)

ALIGN_ENTRY

op82:	inc	bp
	ret


; SAX adr,X (undoc)

ALIGN_ENTRY

op83:	indirectx
	DoSAX
	write	dl,bx
	ret


; STY adr

ALIGN_ENTRY

op84:	zeropage
	mov	dl,[reg_y]
	zwrite	dl,bx
	ret


; STA adr

ALIGN_ENTRY

op85:	zeropage
	zwrite	al,bx
	ret


; STX adr

ALIGN_ENTRY

op86:	zeropage
	mov	dl,[reg_x]
	zwrite	dl,bx
	ret


; SAX adr (undoc)

ALIGN_ENTRY

op87:	zeropage
	DoSAX
	zwrite	dl,bx
	ret


; DEY -- decrement Y

ALIGN_ENTRY

op88:	mov	bl,[reg_y]
	dec	bl
	mov	[reg_y],bl
	usetest	bl
	ret


; NOP data (undoc)

op89:	inc	bp
	ret


; TXA -- transfer X to accumulator

ALIGN_ENTRY

op8a:	mov	al,[reg_x]
	usetest	al
	ret

; ANE data (undoc)

ALIGN_ENTRY

op8b:	fetch	dl
	or	al,0eeh
	and	al,[reg_x]
	and	al,dl
	usetest	al
	ret


; STY adr16

ALIGN_ENTRY

op8c:	absolute
	mov	dl,[reg_y]
	write	dl,bx
	ret


; STA adr16

ALIGN_ENTRY

op8d:	absolute
	write	al,bx
	ret


; STX adr16

ALIGN_ENTRY

op8e:	absolute
	mov	dl,[reg_x]
	write	dl,bx
	ret


; SAX adr16 (undoc)

ALIGN_ENTRY

op8f:	absolute
	DoSAX
	write	dl,bx
	ret


; BCC disp -- branch if	carry clear

ALIGN_ENTRY

op90:
	test	ah,ah
	jz	DoBranch
	inc	bp
	ret


; STA (adr),Y

ALIGN_ENTRY

op91:	indirecty
	write	al,bx
	ret


; SHA (adr),Y

ALIGN_ENTRY

op93:	indirecty
	mov	dh,bh
	inc	dh
	and	dh,[reg_x]
	and	dh,al
	write	dh,bx
	ret


; STY adr,X

ALIGN_ENTRY

op94:	zeropagex
	mov	dl,[reg_y]
	zwrite	dl,bx
	ret


; STA adr,X

ALIGN_ENTRY

op95:	zeropagex
	zwrite	al,bx
	ret


; STX adr,Y

ALIGN_ENTRY

op96:	zeropagey
	mov	dl,[reg_x]
	zwrite	dl,bx
	ret


; SAX adr,Y (undoc)

ALIGN_ENTRY

op97:	zeropagey
	DoSAX
	zwrite	dl,bx
	ret


; TYA -- transfer Y to accumulator

ALIGN_ENTRY

op98:	mov	al,[reg_y]
	usetest	al
	ret


; STA adr16,Y

ALIGN_ENTRY

op99:	absolutey
	write	al,bx
	ret


; TXS -- transfer X to S

ALIGN_ENTRY

op9a:	mov	dl,[reg_x]
	mov	[reg_sp],dl
	ret


; SHS adr16,Y (undoc)

op9b:	absolutey
	mov	dh,bh
	inc	dh
	and	dh,[reg_x]
	and	dh,al
	write	dh,bx
	mov	dh,al
	and	dh,[reg_x]
	mov	[reg_sp],dh
	ret


; SHY adr16,X (undoc)

op9c:	absolutex
	mov	dh,bh
	inc	dh
	and	dh,[reg_y]
	write	dh,bx
	ret


; STA adr16,X

ALIGN_ENTRY

op9d:	absolutex
	write	al,bx
	ret


; SHX adr16,Y (undoc)

op9e:	absolutey
	mov	dh,bh
	inc	dh
	and	dh,[reg_x]
	write	dh,bx
	ret


; SHA adr16,Y (undoc)

op9f:	absolutey
	mov	dh,bh
	inc	dh
	and	dh,[reg_x]
	and	dh,al
	write	dh,bx
	ret


; LDY data

ALIGN_ENTRY

opa0:	fetch	bl
	mov	[reg_y],bl
	usetest	bl
	ret


; LDA (adr,X)

ALIGN_ENTRY

opa1:	indirectx
	read	al,bx
	usetest	al
	ret


; LDX data

ALIGN_ENTRY

opa2:	fetch	bl
	mov	[reg_x],bl
	usetest	bl
	ret


; LAX (adr,X) (undoc)

ALIGN_ENTRY

opa3:	indirectx
	read	al,bx
	mov	[reg_x],al
	usetest	al
	ret


; LDY adr

ALIGN_ENTRY

opa4:	zeropage
	zread	dl,bx
	usetest	dl
	mov	[reg_y],dl
	ret


; LDA adr

ALIGN_ENTRY

opa5:	zeropage
	zread	al,bx
	usetest	al
	ret


; LDX adr

ALIGN_ENTRY

opa6:	zeropage
	zread	dl,bx
	usetest	dl
	mov	[reg_x],dl
	ret


; LAX adr (undoc)

ALIGN_ENTRY

opa7:	zeropage
	zread	al,bx
	mov	[reg_x],al
	usetest	al
	ret


; TAY -- transfer accumulator to Y

ALIGN_ENTRY

opa8:	mov	[reg_y],al
	usetest	al
	ret


; LDA data

ALIGN_ENTRY

opa9:	fetch	al
	usetest	al
	ret


; TAX -- transfer accumulator to X

ALIGN_ENTRY

opaa:	mov	[reg_x],al
	usetest	al
	ret


; LXA data (undoc)

ALIGN_ENTRY

opab:	fetch	dl
	or	al,0eeh
	and	al,dl
	mov	[reg_x],al
	usetest	al
	ret


; LDY adr16

ALIGN_ENTRY

opac:	absolute
	read	dl,bx
	usetest	dl
	mov	[reg_y],dl
	ret


; LDA adr16

ALIGN_ENTRY

opad:	absolute
	read	al,bx
	usetest	al
	ret


; LDX adr16

ALIGN_ENTRY

opae:	absolute
	read	dl,bx
	usetest	dl
	mov	[reg_x],dl
	ret


; LAX adr16 (undoc)

ALIGN_ENTRY

opaf:	absolute
	read	al,bx
	mov	[reg_x],al
	usetest	al
	ret


; BCS disp -- branch if	carry set

ALIGN_ENTRY

opb0:
	test	ah,ah
	jnz	DoBranch
	inc	bp
	ret


; LDA (adr),Y

ALIGN_ENTRY

opb1:	indirecty
	read	al,bx
	usetest	al
	ret


; LAX (adr),Y (undoc)

ALIGN_ENTRY

opb3:	indirecty
	read	al,bx
	mov	[reg_x],al
	usetest	al
	ret


; LDY adr,X

ALIGN_ENTRY

opb4:	zeropagex
	zread	dl,bx
	usetest	dl
	mov	[reg_y],dl
	ret


; LDA adr,X

ALIGN_ENTRY

opb5:	zeropagex
	zread	al,bx
	usetest	al
	ret


; LDX adr,Y

ALIGN_ENTRY

opb6:	zeropagey
	zread	dl,bx
	usetest	dl
	mov	[reg_x],dl
	ret


; LAX adr,Y (undoc)

ALIGN_ENTRY

opb7:	zeropagey
	zread	al,bx
	usetest	al
	mov	[reg_x],al
	ret


; CLV -- clear overflow

ALIGN_ENTRY

opb8:	mov	[flag_overflow],0
	ret


; LDA adr16,Y

ALIGN_ENTRY

opb9:	absolutey
	read	al,bx
	usetest	al
	ret


; TSX -- transfer S to X

ALIGN_ENTRY

opba:	mov	dl,[reg_sp]
	mov	[reg_x],dl
	usetest	dl
	ret


; LAS adr16,Y (undoc)

ALIGN_ENTRY

opbb:	absolutey
	read	al,bx
	and	al,[reg_sp]
	mov	[reg_x],al
	mov	[reg_sp],al
	usetest	al
	ret


; LDY adr16,X

ALIGN_ENTRY

opbc:	absolutex
	read	dl,bx
	usetest	dl
	mov	[reg_y],dl
	ret


; LDA adr16,X

ALIGN_ENTRY

opbd:	absolutex
	read	al,bx
	usetest	al
	ret


; LDX adr16,Y

ALIGN_ENTRY

opbe:	absolutey
	read	dl,bx
	usetest	dl
	mov	[reg_x],dl
	ret


; LAX adr16,Y (undoc)

ALIGN_ENTRY

opbf:	absolutey
	read	al,bx
	usetest	al
	mov	[reg_x],al
	ret


; CPY data

ALIGN_ENTRY

opc0:	fetch	dl
	mov	dh,[reg_y]
	CompDH
	ret


; CMP (adr,X)

ALIGN_ENTRY

opc1:	indirectx
	read	dl,bx
	DoCmp
	ret


; NOP data (undoc)

ALIGN_ENTRY

opc2:	inc	bp
	ret


; DCP (adr,X) (undoc)

ALIGN_ENTRY

opc3:	indirectx
	read	dl,bx
	dec	dl
	DoCmp
	write	dl,bx
	ret


; CPY adr

ALIGN_ENTRY

opc4:	zeropage
	zread	dl,bx
	mov	dh,[reg_y]
	CompDH
	ret


; CMP adr

ALIGN_ENTRY

opc5:	zeropage
	zread	dl,bx
	DoCmp
	ret


; DEC adr

ALIGN_ENTRY

opc6:	zeropage
	zread	dl,bx
	dec	dl
	usetest	dl
	zwrite dl,bx
	ret


; DCP adr (undoc)

ALIGN_ENTRY

opc7:	zeropage
	zread	dl,bx
	dec	dl
	DoCmp
	zwrite dl,bx
	ret


; INY -- increment Y

ALIGN_ENTRY

opc8:	mov	bl,[reg_y]
	inc	bl
	mov	[reg_y],bl
	usetest	bl
	ret


; CMP data

ALIGN_ENTRY

opc9:	fetch	dl
	DoCmp
	ret


; DEX -- decrement X

ALIGN_ENTRY

opca:	mov	bl,[reg_x]
	dec	bl
	mov	[reg_x],bl
	usetest	bl
	ret

; SBX data (undoc)

ALIGN_ENTRY

opcb:	fetch	dl
	mov	dh,al
	and	dh,[reg_x]
	sub	dh,dl
	usetest	dh
	setnc	ah
	mov	[reg_x],dh
	ret


; CPY adr16

ALIGN_ENTRY

opcc:	absolute
	read	dl,bx
	mov	dh,[reg_y]
	CompDH
	ret


; CMP adr16

ALIGN_ENTRY

opcd:	absolute
	read	dl,bx
	DoCmp
	ret


; DEC adr16

ALIGN_ENTRY

opce:	absolute
	read	dl,bx
	dec	dl
	write	dl,bx
	usetest	dl
	ret


; DCP adr16 (undoc)

ALIGN_ENTRY

opcf:	absolute
	read	dl,bx
	dec	dl
	write	dl,bx
	DoCmp
	ret


; BNE disp -- branch if	non-zero

ALIGN_ENTRY

opd0:
	cmp	[RZTest],0
	jnz	DoBranch
	inc	bp
	ret


; CMP (adr),Y

ALIGN_ENTRY

opd1:	indirecty
	read	dl,bx
	DoCmp
	ret


; DCP (adr),Y (undoc)

opd3:	indirecty
	read	dl,bx
	dec	dl
	DoCmp
	write	dl,bx
	ret


; NOP adr,X (undoc)

ALIGN_ENTRY

opd4:	inc	bp
	ret


; CMP adr,X

ALIGN_ENTRY

opd5:	zeropagex
	zread	dl,bx
	DoCmp
	ret


; DEC adr,X

ALIGN_ENTRY

opd6:	zeropagex
	zread	dl,bx
	dec	dl
	usetest	dl
	zwrite dl,bx
	ret


; DCP adr,X (undoc)

ALIGN_ENTRY

opd7:	zeropagex
	zread	dl,bx
	dec	dl
	DoCmp
	zwrite dl,bx
	ret


; CLD -- clear decimal mode

ALIGN_ENTRY

opd8:	mov	[flag_decimal],0
	call	SetMathVectors	; adjust for decimal/binary mode
	ret


; CMP adr16,Y

ALIGN_ENTRY

opd9:	absolutey
	read	dl,bx
	DoCmp
	ret


; NOP (undoc)

ALIGN_ENTRY

opda:	ret


; DCP adr16,Y (undoc)

ALIGN_ENTRY

opdb:	absolutey
	read	dl,bx
	dec	dl
	DoCmp
	write	dl,bx
	ret


; NOP adr16,X

opdc:	absolutex
	ret


; CMP adr16,X

ALIGN_ENTRY

opdd:	absolutex
	read	dl,bx
	DoCmp
	ret


; DEC adr16,X

ALIGN_ENTRY

opde:	absolutex_rmw		; * Perazzoli *
	read	dl,bx
	dec	dl
	write	dl,bx
	usetest	dl
	ret


; DCP adr16,X (undoc)

ALIGN_ENTRY

opdf:	absolutex_rmw		; * Perazzoli *
	read	dl,bx
	dec	dl
	DoCmp
	write	dl,bx
	ret


; CPX data

ALIGN_ENTRY

ope0:	fetch	dl
	mov	dh,[reg_x]
	CompDH
	ret


; SBC adr,X

ALIGN_ENTRY

ope1:	indirectx
	read	dl,bx
	call	[SubVector]
	ret


; NOP data (undoc)

ALIGN_ENTRY

ope2:	inc	bp
	ret


; ISB adr,X (undoc)

ALIGN_ENTRY

ope3:	indirectx
	read	dl,bx
	DoISB
	write	dl,bx
	ret


; CPX adr

ALIGN_ENTRY

ope4:	zeropage
	zread	dl,bx
	mov	dh,[reg_x]
	CompDH
	ret


; SBC adr

ALIGN_ENTRY

ope5:	zeropage
	zread	dl,bx
	call	[SubVector]
	ret


; INC adr

ALIGN_ENTRY

ope6:	zeropage
	zread	dl,bx
	inc	dl
	zrewrite dl		; ***codebrk***
	usetest	dl
	ret


; ISB adr (undoc)

ALIGN_ENTRY

ope7:	zeropage
	zread	dl,bx
	DoISB
	zwrite	dl,bx
	ret


; INX -- increment X

ALIGN_ENTRY

ope8:	mov	bl,[reg_x]
	inc	bl
	mov	[reg_x],bl
	usetest	bl
	ret


; SBC data

ALIGN_ENTRY

ope9:	fetch	dl
	call	[SubVector]
	ret


; NOP (standard)

ALIGN_ENTRY

opea:	ret


; CPX adr16

ALIGN_ENTRY

opec:	absolute
	read	dl,bx
	mov	dh,[reg_x]
	CompDH
	ret


; SBC adr16

ALIGN_ENTRY

oped:	absolute
	read	dl,bx
	call	[SubVector]
	ret


; INC adr16

ALIGN_ENTRY

opee:	absolute
	read	dl,bx
	inc	dl
	write	dl,bx
	usetest	dl
	ret


; ISB adr16 (undoc)

ALIGN_ENTRY

opef:	absolute
	read	dl,bx
	DoISB
	write	dl,bx
	ret


; BEQ disp -- branch if	zero

ALIGN_ENTRY

opf0:
	cmp	[RZTest],0
	jz	DoBranch
	inc	bp
	ret


; SBC (adr),Y

ALIGN_ENTRY

opf1:	indirecty
	read	dl,bx
	call	[SubVector]
	ret


; ISB (adr),Y (undoc)

ALIGN_ENTRY

opf3:	indirecty
	read	dl,bx
	DoISB
	write	dl,bx
	ret


; NOP adr,X (undoc)

ALIGN_ENTRY

opf4:	inc	bp
	ret


; SBC adr,X

ALIGN_ENTRY

opf5:	zeropagex
	zread	dl,bx
	call	[SubVector]
	ret


; INC adr,X

ALIGN_ENTRY

opf6:	zeropagex
	zread	dl,bx
	inc	dl
	usetest	dl
	zwrite dl,bx
	ret


; ISB adr,X (undoc)

ALIGN_ENTRY

opf7:	zeropagex
	zread	dl,bx
	DoISB
	zwrite	dl,bx
	ret


; SED -- set decimal mode

ALIGN_ENTRY

opf8:	mov	[flag_decimal],1
	call	SetMathVectors	; adjust for decimal/binary mode
	ret


; SBC adr16,Y

ALIGN_ENTRY

opf9:	absolutey
	read	dl,bx
	call	[SubVector]
	ret


; NOP (undoc)

ALIGN_ENTRY

opfa:	ret


; ISB adr16,Y (undoc)

ALIGN_ENTRY

opfb:	absolutey_rmw
	read	dl,bx
	DoISB
	write	dl,bx
	ret


; NOP adr16,X (undoc)

opfc:	absolutex
	ret


; SBC adr16,X

ALIGN_ENTRY

opfd:	absolutex
	read	dl,bx
	call	[SubVector]
	ret


; INC adr16,X

ALIGN_ENTRY

opfe:	absolutex_rmw		; * Perazzoli *
	read	dl,bx
	inc	dl
	write	dl,bx
	usetest	dl
	ret


; ISB adr16,X (undoc)

ALIGN_ENTRY

opff:	absolutex_rmw
	read	dl,bx
	DoISB
	write	dl,bx
	ret


; *****************************************************************************
;
;			  Handle relative jumps
;
;	assumes	bp = PCTR and relative macro has put jump offset in dx
;
; *****************************************************************************

ALIGN_ENTRY

DoBranch:
	relative

	mov	bx,bp			; bh is	the current page
	add	dx,bp			; work out the return address
	mov	bp,dx			; and set the program counter

	inc	[RClock]		; we require one extra cycle !
	inc	[RCycles]
	cmp	bh,dh			; page changed ?
	je	dbjn
	inc	[RCycles]
	inc	[RClock]
dbjn:	ret


