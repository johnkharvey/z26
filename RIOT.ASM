;*
;* z26 RIOT emu
;*


.data


ALIGN 2

ReadRIOTTab label word
	dw	ReadPortA		; 280h PA Data
	dw	ReadFF			; 281h PA Direction
	dw	ReadPortB		; 282h PB Data
	dw	ReadFF			; 283h PB Direction
	dw	ReadTimer		; 284h Read Timer
	dw	ReadTimerIntReg		; 285h Read Timer Interrupt Register
	dw	ReadTimer		; 286h Read Timer
	dw	ReadTimerIntReg		; 287h Read Timer Interrupt Register

WriteRIOTTab label word
;	dw	WriteNothing		; 290h \
;	dw	WriteNothing		; 291h  \  were commented out
;	dw	WriteNothing		; 292h  /
;	dw	WriteNothing		; 293h /

	dw	SetRIOTTimer1		; 294h
	dw	SetRIOTTimer8		; 295h
	dw	SetRIOTTimer64		; 296h
	dw	SetRIOTTimer1024	; 297h

.code

;*
;* CPU wants to read a RIOT register
;*

ReadRIOT:
	and	esi,07h
	jmp	[ReadRIOTTab + esi*2]

ReadFF:
	mov	si,offset RetFF
	ret

ReadPortB:				; read console switches (port b)
	mov	si,offset _IOPortB
	ret

ReadPortA:				; read hand controllers (port b)
	mov	si,offset IOPortA
	ret


;*
;* CPU wants to write to a RIOT register
;*

WriteRIOT:
	test	si,080h
	jz	WriteNothing
	test	si,014h
	jz	WriteNothing

	and	esi,03h			; was 3
	jmp	[WriteRIOTTab + esi*2]
	

WriteNothing:
	ret

;*
;* CPU wants to set the timer by writing to one of the RIOT timer regs:
;*
;* 	$294 (TIM1T)
;* 	$295 (TIM8T)
;* 	$296 (TIM64T)
;* 	$297 (TIM1024T)
;*
;* On entry, si contains the address and [WByte] contains the value
;*

set_timer macro op1,op2

SetRIOTTimer&op2:
	mov	[RCycles],0		; don't clock this instruction
	movzx	edx,[WByte]
	shl	edx,op1

	add	edx,[TimerFudge]	; fudge the timer (usually zero)

	mov	[Timer],edx
	mov	[TimerReadVec], offset ReadTimer&op2
	mov	[TimerVec], offset Timer1
	ret

	endm

	set_timer 0,1
	set_timer 3,8
	set_timer 6,64
	set_timer 10,1024


;*
;* CPU wants to read the RIOT timer
;*
;* return with si pointing to value to read from $284 (INTIM)
;*

read_timer macro op1,op2

ReadTimer&op2:
	shr	edx,op1
	mov	[TimerByte],dl
	mov	si,offset TimerByte

	ret

	endm

	read_timer 0,1
	read_timer 3,8
	read_timer 6,64
	read_timer 10,1024

ReadTimer:
	movzx	edx,[RCycles]		; clock this instruction
	sub	[Timer],edx
	mov	[RCycles],0		; prevent double clock

	mov	edx,[Timer]
	test	edx,040000000h		; has the timer overflowed yet ?
	jnz	ReadOverflowed		;   yes
	jmp	[TimerReadVec]		;   no, do appropriate read

ReadOverflowed:
	cmp	edx,0ffffffffh		; did we JUST overflow ?
	je	ReadNoClear		;   yes, don't clear interrupt
					; (BTW, there are no skipped cycles)

	and	[Timer],07fffffffh	; clear interrupt flag
ReadNoClear:
	mov	[TimerByte],dl		; return this value
	mov	si, offset TimerByte
	ret

;*
;* CPU wants to read the RIOT Timer Interrupt Register
;*
;* return with si pointing to value to read from $285
;*

ReadTimerIntReg:
	mov	edx,[Timer]
	shr	edx,24
	and	dl,080h			; position the very top bit
	mov	[TimerIntReg],dl	; return this value
	and	[Timer],07fffffffh	; clear interrupt flag
	mov	si,offset TimerIntReg
	ret

;*
;* Process the timer (after every instruction)
;*
;* TimerVec points to one of these routines...
;*

Timer1:	movzx	edx,[RCycles]		; # of cycles for this instruction
	sub	[Timer],edx		; subtract from timer
Timer0:	ret

