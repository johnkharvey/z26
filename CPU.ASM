; *****************************************************************************
;				Reset the CPU
; *****************************************************************************

Reset:	push	bx
	mov	bx,FEnd	- RA-1
ResLoop:mov	byte ptr RA[bx],0
	dec	bx
	jge	ResLoop
	pop	bx
	call	RLoad
	mov	cl,0FFh			; SP initialises to 255
	mov	bp,0FFFCh		; get reset address
	read	bl,bp			; from 0fffc,0fffd
	inc	bp
	read	bh,bp
	mov	bp,bx			; and set the pctr
	ret

; *****************************************************************************
;			Load registers from memory
; *****************************************************************************

RLoad:	mov	al,[RA]
	mov	ah,[RCarry]
	mov	cl,[RS]
	mov	bp,[RPC]
	ret
        
; *****************************************************************************
;			Save registers to memory
; *****************************************************************************

RSave:	mov	[RA],al
	mov	[RCarry],ah
	mov	[RS],cl
	mov	[RPC],bp
	ret

; *****************************************************************************
;		Set vectors according to Decimal Flag
; *****************************************************************************

SetMathVectors:
	push	ax
	mov	al,[FDec]
	cmp	al,0
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

GetPSW:	push	ax
	mov	dl,[RNTest]		; dl = last result
	and	dl,128			; use bit 7 of that as the N bit
	mov	al,[FOver]		; bit 6	is the overflow	flag
	shl	al,6
	or	dl,al
	or	dl,020H			; bit 5	is always set
	mov	al,[FBreak]		; bit 4	is the break flag
	shl	al,4
	or	dl,al
	mov	al,[FDec]		; bit 3	is the decimal flag
	shl	al,3
	or	dl,al
	mov	al,[FIntDis]		; bit 2	is interrupt disable
	shl	al,2
	or	dl,al
	mov	dh,[RZTest]		; bit 1	is zero	flag.
	cmp	dh,0
	jnz	PSWZero
	or	dl,002H
PSWZero:or	dl,ah			; bit 0	is Carry
	pop ax
	ret

; *****************************************************************************
;	   CMP code. Uses the Subtract code. AL	= acc,BX points	to data
; *****************************************************************************

DoCmp:	read	dl,bx
	mov	bl,al		;save AC

	xor	bh,bh
	mov	ah,0
	sahf			;preset	carry
	sbb	al,dl		;do the	test
	jno	CmpNO
	inc	bh
CmpNO:	mov	[FOver],bh
	usetest	al
	cmc
	lahf
	and	ah,1
	mov	al,bl		;restore AC
	ret
        
; *****************************************************************************
;	 SBC code. AL is accumulator,AH	is carry bit,BX	points to data
; *****************************************************************************

DoSbc:	read	dl,bx
	xor	bh,bh
	sahf			;set up	carry bit
	cmc			;6502 needs complement
	sbb	al,dl
	jno	SbcNO
	inc	bh		;watch that carry!
SbcNO:	mov	[FOver],bh
	usetest	al
	cmc			;6502 needs complement
	lahf
	and	ah,1
	ret

; *****************************************************************************
;	 ADC code. AL is accumulator,AH	is carry bit,BX	points to data
; *****************************************************************************

DoAdc:	read	dl,bx
	xor	bh,bh		;preset	overflow
	sahf			;set up	carry
	adc	al,dl
	jno	AdcNO
	inc	bh		;watch that carry!
AdcNO:	mov	[FOver],bh
	usetest	al
	lahf
	and	ah,1
	ret

; *****************************************************************************
;    ADC Decimal code. AL is accumulator,AH is carry bit,BX points to data
; *****************************************************************************

ADCBCD:	read	dl,bx
	xor	bh,bh
	sahf
	adc	al,dl		;get sign & overflow here (Leventhal 8-6)
;	jno	AdcDNO
;	inc	bh		;watch that carry!
;AdcDNO:	mov	[FOver],bh
;	usetest	al
	daa
	lahf
	and	ah,1
	usetest	al
	ret
        
; *****************************************************************************
;    SBC Decimal code. AL is accumulator,AH is carry bit,BX points to data
; *****************************************************************************

SBCBCD:	read	dl,bx
	xor	bh,bh
	sahf			;set up	carry bit
	cmc			;6502 needs complement
	sbb	al,dl		;get sign & overflow here (Leventhal 8-6)
;	jno	SbcDNO
;	inc	bh		;watch that carry!
;SbcDNO:	mov	[FOver],bh
;	usetest	al
	das
	cmc
	lahf
	and	ah,1
	usetest	al
	ret
        

; BRK -- programmed interrupt

op00:	mov	dx,bp		; return address in dx
	mov	bl,cl		; bx is	stack address
	mov	bh,1
	write	dh,bx		; push return address
	dec	bl
	write	dl,bx
	dec	cl
	dec	cl
	call	xop08		; push PSW
	mov	bx,0FFFEh	; fetch	the vector
	read	dl,bx
	inc	bx
	read	dh,bx
	mov	bp,dx		; and transfer execution to addr there
	jmp	next


; ORA (adr,X)

op01:	indirectx
	read	dl,bx
	or	al,dl
	jmp	ualnext


; ORA adr

op05:	zeropage
	zread	dl,bx
	or	al,dl
	jmp	ualnext


; ASL adr

op06:	zeropage
	zread	dl,bx
	DoASL
	rewrite	dl
	jmp	next


; PHP -- push processor	status word

op08:	call	xop08
	jmp	next

xop08:	call	GetPSW		; get PSW in DL
	mov	bl,cl		; bx points to stack
	mov	bh,1
	write	dl,bx		; save it on the stack
	dec	cl		; decrement Stack pointer
	ret

; ORA data

op09:	fetch	dl
	or	al,dl
	jmp	ualnext


; ASL A

op0a:	mov	dl,al
	DoASL
	mov	al,dl
	jmp	next


; ORA adr16

op0d:	absolute
	read	dl,bx
	or	al,dl
	jmp	ualnext


; ASL adr16

op0e:	absolute
	read	dl,bx
	DoASL
	rewrite	dl
op0ejn:	jmp	next


; BPL disp -- branch if	plus

op10:	relative		; get branch to	dx,sign	extend
	mov	ch,[RNTest]
	test	ch,128
	jnz	op0ejn		; if negative goto near	return
	jmp	DoBranch


; ORA (adr),Y

op11:	indirecty
	pagechange
	read	dl,bx
	or	al,dl
	jmp	ualnext


; ORA adr,X

op15:	zeropagex
	zread	dl,bx
	or	al,dl
	jmp	ualnext


; ASL adr,X

op16:	zeropagex
	zread	dl,bx
	DoASL
	rewrite	dl
	jmp	next


; CLC -- clear carry flag

op18:	xor	ah,ah
	jmp	next


; ORA adr16,Y

op19:	absolutey
	pagechange
	read	dl,bx
	or	al,dl
	jmp	ualnext


; ORA adr16,X

op1d:	absolutex
	pagechange
	read	dl,bx
	or	al,dl
	jmp	ualnext


; ASL adr16,X

op1e:	absolutex
	read	dl,bx
	DoASL
	rewrite	dl
	jmp	next


; JSR adr16 -- call subroutine

op20:	absolute		; call address in bx now
	push	ax
	push	bx
	push	dx
	mov	ax,bp		; ax is	the return address
	dec	ax		; push return-1
	mov	bl,cl		; bl is	the stack index
	mov	bh,1
	write	ah,bx		; push the return address
	dec	bl
	write	al,bx
	dec	cl		; decrement the	stack pointer
	dec	cl
	pop	dx
	pop	bx
	pop	ax
	mov	bp,bx		; transfer control
	jmp	next


; AND (adr,X)

op21:	indirectx
	read	dl,bx
	and	al,dl
	jmp	ualnext


; BIT adr

op24:	zeropage		; bx = zero page.
BitTest:read	dl,bx		; read the byte
	mov	dh,dl		; save read number in DH
	and	dl,al		; this is the and result
	useztest dl		; use it to test for zero
	usentest dh		; the memory bit 7 is the n flag
	shr	dh,6		; and bit 6 is the overflow flag
	and	dh,1
	mov	[FOver],dh
	jmp	next


; AND adr

op25:	zeropage
	zread	dl,bx
	and	al,dl
	jmp	ualnext


; ROL adr

op26:	zeropage
	zread	dl,bx
	DoROL
	rewrite	dl
	jmp	next


; PLP -- pull PSW

op28:	call	xop28
	jmp	next

xop28:	inc	cl		; increment the	stack pointer
	mov	bl,cl		; and read the top byte
	mov	bh,1		; into ch
	read	ch,bx
	mov	[RNTest],ch	; it will do for use as	the N Flag

	mov	ah,ch		; bit 0	is the carry flag
	and	ah,1
	shr	ch,1		; bit 1	is the zero flag
	mov	dl,ch
	and	dl,1
	xor	dl,1
	mov	[RZTest],dl
	shr	ch,1		; bit 2	is the intdis flag
	mov	dl,ch
	and	dl,1
	mov	[FIntDis],dl
	shr	ch,1		; bit 3	is the decimal flag
	mov	dl,ch
	and	dl,1
	mov	[FDec],dl
	shr	ch,1		; bit 4	is the break flag
	mov	dl,ch
	and	dl,1
	mov	[FBreak],dl
	shr	ch,2		; bit 6	is overflow
	and	ch,1
	mov	[FOver],ch
	call	SetMathVectors	; adjust for decimal/binary mode
	ret

; AND data

op29:	fetch	dl
	and	al,dl
	jmp	ualnext


; ROL A

op2a:	mov	dl,al
	DoROL
	mov	al,dl
	jmp	next


; BIT adr16

op2c:	absolute
	jmp	BitTest


; AND adr16

op2d:	absolute
	read	dl,bx
	and	al,dl
	jmp	ualnext


; ROL adr16

op2e:	absolute
	read	dl,bx
	DoROL
	rewrite	dl
op2ejn:	jmp	next


; BMI disp -- branch if	minus

op30:	relative
	mov	ch,[RNTest]
	test	ch,128
	jz	op2ejn		; if negative goto near	return
	jmp	DoBranch


; AND (adr),Y

op31:	indirecty
	pagechange
	read	dl,bx
	and	al,dl
	jmp	ualnext


; AND adr,X

op35:	zeropagex
	zread	dl,bx
	and	al,dl
	jmp	ualnext


; ROL adr,X

op36:	zeropagex
	zread	dl,bx
	DoROL
	rewrite	dl
	jmp	next


; SEC -- set carry

op38:	mov	ah,1
	jmp	next


; AND adr16,Y

op39:	absolutey
	pagechange
	read	dl,bx
	and	al,dl
	jmp	ualnext


; AND adr16,X

op3d:	absolutex
	pagechange
	read	dl,bx
	and	al,dl
	jmp	ualnext


; ROL adr16,X

op3e:	absolutex		;* was absolutey !
	read	dl,bx
	DoROL
	rewrite	dl
	jmp	next


; RTI -- return	from interrupt

op40:	call	xop28		; pull psw
	inc	cl		; same as return but don't inc PCTR
	mov	bl,cl		; bx points to PCL to pop
	inc	cl		; sp gone up 2 now,its ok
	mov	bh,1
	read	dl,bx		; read return address in bx
	inc	bl
	read	dh,bx
	mov	bp,dx		; and return
	jmp	next


; EOR (adr,X)

op41:	indirectx
	read	dl,bx
	xor	al,dl
	jmp	ualnext


; EOR adr

op45:	zeropage
	zread	dl,bx
	xor	al,dl
	jmp	ualnext


; LSR adr

op46:	zeropage
	zread	dl,bx
	DoLSR
	rewrite	dl
	jmp	next


; PHA -- push accumulator

op48:	mov	bl,cl		; bx ^ stack
	mov	bh,1
	write	al,bx
	dec	cl		; decrement stack pointer
	jmp	next


; EOR data

op49:	fetch	dl
	xor	al,dl
	jmp	ualnext


; LSR A

op4a:	mov	dl,al
	DoLSR
	mov	al,dl
	jmp	next


; JMP adr16

op4c:	absolute		; fetch	the address
	mov	bp,bx		; jump to it
	jmp	next


; EOR adr16

op4d:	absolute
	read	dl,bx
	xor	al,dl
	jmp	ualnext


; LSR adr16

op4e:	absolute
	read	dl,bx
	DoLSR
	rewrite	dl
op4ejn:	jmp	next


; BVC disp -- branch if	overflow clear

op50:	relative
	mov	ch,[FOver]
	cmp	ch,0
	jnz	op4ejn
	jmp	DoBranch


; EOR (adr),Y

op51:	indirecty
	pagechange
	read	dl,bx
	xor	al,dl
	jmp	ualnext


; EOR adr,X

op55:	zeropagex
	zread	dl,bx
	xor	al,dl
	jmp	ualnext


; LSR adr,X

op56:	zeropagex
	zread	dl,bx
	DoLSR
	rewrite	dl
	jmp	next


; CLI -- clear interrupt disable

op58:	mov	[FIntDis],0
	jmp	next


; EOR adr16,Y

op59:	absolutey
	pagechange
	read	dl,bx
	xor	al,dl
	jmp	ualnext


; EOR adr16,X

op5d:	absolutex
	pagechange
	read	dl,bx
	xor	al,dl
	jmp	ualnext


; LSR adr16,X

op5e:	absolutex
	zread	dl,bx
	DoLSR
	rewrite	dl
	jmp	next


; RTS -- return	from subroutine

op60:	inc	cl
	mov	bl,cl		; bx points to PCL to pop
	inc	cl		; sp gone up 2 now,its ok
	mov	bh,1
	read	dl,bx		; read return address in bx
	inc	bl
	read	dh,bx
	mov	bp,dx		; and return
	inc	bp
	jmp	next


; ADC (adr,X)

op61:	indirectx
	call	[AddVector]
	jmp	next


; ADC adr

op65:	zeropage
	call	[AddVector]
	jmp	next


; ROR adr

op66:	zeropage
	zread	dl,bx
	DoROR
	rewrite	dl
	jmp	next


; PLA -- pop accumulator

op68:	inc	cl		; increment sp
	mov	bl,cl		; build	the read address
	mov	bh,1
	read	al,bx
	jmp	ualnext		;set flags...


; ADC data

op69:	mov	bx,bp
	inc	bp
	call	[AddVector]
	jmp	next


; ROR A

op6a:	mov	dl,al
	DoROR
	mov	al,dl
	jmp	next


; JMP (adr16)

op6c:	absolute		; read the address of the the jump
	read	dl,bx
	inc	bx
	read	dh,bx
	mov	bp,dx		; and jump to it
	jmp	next


; ADC adr16

op6d:	absolute
	call	[AddVector]
	jmp	next


; ROR adr16

op6e:	absolute
	read	dl,bx
	DoROR
	rewrite	dl
	jmp	next


; BVS disp -- branch if	overflow set

op70:	relative
	mov	ch,[FOver]
	cmp	ch,0
	jz	op71jn
	jmp	DoBranch


; ADC (adr),Y

op71:	indirecty
	pagechange
	call	[AddVector]
op71jn:	jmp	next


; ADC adr,X

op75:	zeropagex
	call	[AddVector]
	jmp	next


; ROR adr,X

op76:	zeropagex
	zread	dl,bx
	DoROR
	rewrite	dl
	jmp	next


; SEI -- disable interrupts

op78:	mov	[FIntDis],1
	jmp	next


; ADC adr16,Y

op79:	absolutey
	pagechange
	call	[AddVector]
	jmp	next


; ADC adr16,X

op7d:	absolutex
	pagechange
	call	[AddVector]
	jmp	next


; ROR adr16,X

op7e:	absolutex
	read	dl,bx
	DoROR
	rewrite	dl
	jmp	next


; STA adr,X

op81:	indirectx
	write	al,bx
	jmp	next


; STY adr

op84:	zeropage
	mov	dl,[RY]
	zwrite	dl,bx
	jmp	next


; STA adr

op85:	zeropage
	zwrite	al,bx
	jmp	next


; STX adr

op86:	zeropage
	mov	dl,[RX]
	zwrite	dl,bx
	jmp	next


; DEY -- decrement Y

op88:	mov	bl,[RY]
	dec	bl
	mov	[RY],bl
	usetest	bl
	jmp	next


; TXA -- transfer X to accumulator

op8a:	mov	al,[RX]
	jmp	ualnext


; STY adr16

op8c:	absolute
	mov	dl,[RY]
	write	dl,bx
	jmp	next


; STA adr16

op8d:	absolute
	write	al,bx
	jmp	next


; STX adr16

op8e:	absolute
	mov	dl,[RX]
	write	dl,bx
	jmp	next


; BCC disp -- branch if	carry clear

op90:	relative
	cmp	ah,0
	jnz	op91jn
	jmp	DoBranch


; STA (adr),Y

op91:	indirecty
	write	al,bx
op91jn:	jmp	next


; STY adr,X

op94:	zeropagex
	mov	dl,[RY]
	zwrite	dl,bx
	jmp	next


; STA adr,X

op95:	zeropagex
	zwrite	al,bx
	jmp	next


; STX adr,Y

op96:	zeropagey
	mov	dl,[RX]
	zwrite	dl,bx
	jmp	next


; TYA -- transfer Y to accumulator

op98:	mov	al,[RY]
	jmp	ualnext


; STA adr16,Y

op99:	absolutey
	write	al,bx
	jmp	next


; TXS -- transfer X to S

op9a:	mov	cl,[RX]
	jmp	next


; STA adr16,X

op9d:	absolutex
	write	al,bx
	jmp	next


; LDY data

opa0:	fetch	bl
	mov	[RY],bl
	usetest	bl
	jmp	next


; LDA (adr,X)

opa1:	indirectx
	read	al,bx
	jmp	ualnext


; LDX data

opa2:	fetch	bl
	mov	[RX],bl
	usetest	bl
	jmp	next


; LDY adr

opa4:	zeropage
	zread	dl,bx
	usetest	dl
	mov	[RY],dl
	jmp	next


; LDA adr

opa5:	zeropage
	zread	al,bx
	jmp	ualnext


; LDX adr

opa6:	zeropage
	zread	dl,bx
	usetest	dl
	mov	[RX],dl
	jmp	next


; TAY -- transfer accumulator to Y

opa8:	mov	[RY],al
	jmp	ualnext


; LDA data

opa9:	fetch	al
	jmp	ualnext


; TAX -- transfer accumulator to X

opaa:	mov	[RX],al
	jmp	ualnext


; LDY adr16

opac:	absolute
	read	dl,bx
	usetest	dl
	mov	[RY],dl
	jmp	next


; LDA adr16

opad:	absolute
	read	al,bx
	jmp	ualnext


; LDX adr16

opae:	absolute
	read	dl,bx
	usetest	dl
	mov	[RX],dl
opaejn:	jmp	next


; BCS disp -- branch if	carry set

opb0:	relative
	cmp	ah,0
	jz	opaejn
	jmp	DoBranch


; LDA (adr),Y

opb1:	indirecty
	pagechange
	read	al,bx
	jmp	ualnext


; LDY adr,X

opb4:	zeropagex
	zread	dl,bx
	usetest	dl
	mov	[RY],dl
	jmp	next


; LDA adr,X

opb5:	zeropagex
	zread	al,bx
	jmp	ualnext


; LDX adr,Y

opb6:	zeropagey
	zread	dl,bx
	usetest	dl
	mov	[RX],dl
	jmp	next


; CLV -- clear overflow

opb8:	mov	[FOver],0
	jmp	next


; LDA adr16,Y

opb9:	absolutey
	pagechange
	read	al,bx
	jmp	ualnext


; TSX -- transfer S to X

opba:	mov	[RX],cl
	usetest	cl
	jmp	next


; LDY adr16,X

opbc:	absolutex
	pagechange
	read	dl,bx
	usetest	dl
	mov	[RY],dl
	jmp	next


; LDA adr16,X

opbd:	absolutex
	pagechange
	read	al,bx
	jmp	ualnext


; LDX adr16,Y

opbe:	absolutey
	pagechange
	read	dl,bx
	usetest	dl
	mov	[RX],dl
	jmp	next


; CPY data

opc0:	mov	bx,bp		; bp points to the value now
	inc	bp
	mov	dl,[RY]		; dl is	Y Register
	jmp	CompDL


; CMP (adr,X)

opc1:	indirectx
	call	DoCmp
	jmp	next


; CPY adr

opc4:	zeropage
	mov	dl,[RY]		; dl is	Y Register
	jmp	CompDL


; CMP adr

opc5:	zeropage
	call	DoCmp
	jmp	next


; DEC adr

opc6:	zeropage
	zread	dl,bx
	dec	dl
	rewrite	dl
	usetest	dl
	jmp	next


; INY -- increment Y

opc8:	mov	bl,[RY]
	inc	bl
	mov	[RY],bl
	usetest	bl
	jmp	next


; CMP data

opc9:	mov	bx,bp
	inc	bp
	call	DoCmp
	jmp	next


; DEX -- decrement X

opca:	mov	bl,[RX]
	dec	bl
	mov	[RX],bl
	usetest	bl
	jmp	next


; CPY adr16

opcc:	absolute
	mov	dl,[RY]
	jmp	CompDL


; CMP adr16

opcd:	absolute
	call	DoCmp
	jmp	next


; DEC adr16

opce:	absolute
	read	dl,bx
	dec	dl
	rewrite	dl
	usetest	dl
	jmp	next


; BNE disp -- branch if	non-zero

opd0:	relative
	mov	bl,[RZTest]
	cmp	bl,0
	jz	opd1jn
	jmp	DoBranch


; CMP (adr),Y

opd1:	indirecty
	pagechange
	call	DoCmp
opd1jn:	jmp	next


; CMP adr,X

opd5:	zeropagex
	call	DoCmp
	jmp	next


; DEC adr,X

opd6:	zeropagex
	zread	dl,bx
	dec	dl
	rewrite	dl
	usetest	dl
	jmp	next


; CLD -- clear decimal mode

opd8:	mov	[FDec],0
	call	SetMathVectors	; adjust for decimal/binary mode
	jmp	next


; CMP adr16,Y

opd9:	absolutey
	pagechange
	call	DoCmp
	jmp	next


; CMP adr16,X

opdd:	absolutex
	pagechange
	call	DoCmp
	jmp	next


; DEC adr16,X

opde:	absolutex
	read	dl,bx
	dec	dl
	rewrite	dl
	usetest	dl
	jmp	next


; CPX data

ope0:	mov	bx,bp		; bp points to the value now
	inc	bp
	mov	dl,[RX]		; dl is	X Register
	jmp	CompDL


; SBC adr,X

ope1:	indirectx
	call	[SubVector]
	jmp	next


; CPX adr

ope4:	zeropage
	mov	dl,[RX]		; dl is	X Register
	jmp	CompDL


; SBC adr

ope5:	zeropage
	call	[SubVector]
	jmp	next


; INC adr

ope6:	zeropage
	zread	dl,bx
	inc	dl
	rewrite	dl
	usetest	dl
	jmp	next


; INX -- increment X

ope8:	mov	bl,[RX]
	inc	bl
	mov	[RX],bl
	usetest	bl
	jmp	next


; SBC data

ope9:	mov	bx,bp
	inc	bp
	call	[SubVector]
	jmp	next


; NOP

opea:	jmp	next


; CPX adr16

opec:	absolute
	mov	dl,[RX]		; dl is	X Register
	jmp	CompDL


; SBC adr16

oped:	absolute
	call	[SubVector]
	jmp	next


; INC adr16

opee:	absolute
	read	dl,bx
	inc	dl
	rewrite	dl
	usetest	dl
	jmp	next


; BEQ disp -- branch if	zero

opf0:	relative
	mov	bl,[RZTest]
	cmp	bl,0
	jnz	opf1jn
	jmp	DoBranch


; SBC (adr),Y

opf1:	indirecty
	pagechange
	call	[SubVector]
opf1jn:	jmp	next


; SBC adr,X

opf5:	zeropagex
	call	[SubVector]
	jmp	next


; INC adr,X

opf6:	zeropagex
	zread	dl,bx
	inc	dl
	rewrite	dl
	usetest	dl
	jmp	next


; SED -- set decimal mode

opf8:	mov	[FDec],1
	call	SetMathVectors	; adjust for decimal/binary mode
	jmp	next


; SBC adr16,Y

opf9:	absolutey
	pagechange
	call	[SubVector]
	jmp	next


; SBC adr16,X

opfd:	absolutex
	pagechange
	call	[SubVector]
	jmp	next


; INC adr16,X

opfe:	absolutex
	zread	dl,bx
	inc	dl
	rewrite	dl
	usetest	dl
	jmp	next


; *****************************************************************************
;
;			  Handle relative jumps
;
;	assumes	bp = PCTR and relative macro has put jump offset in dx
;
; *****************************************************************************

DoBranch:
	mov	bx,bp			; bh is	the current page
	add	dx,bp			; work out the return address
	mov	bp,dx			; and set the program counter

	inc	[RClock]		; we require one extra cycle !
	inc	[RCycles]
	cmp	bh,dh			; page changed ?
	je	dbjn
	inc	[RCycles]
	inc	[RClock]
dbjn:	jmp	next

RelExit:ret


; *****************************************************************************
;
;			Compare	DL vs [BP]
;
; *****************************************************************************

CompDL:	mov	dh,al			; save acc
	push	dx
	mov	al,dl			; dl to	compare	against
	call	DoCmp			; do the comparison
	pop	dx			; restore the accumulator
	mov	al,dh
	jmp	next
