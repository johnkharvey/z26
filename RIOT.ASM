;*
;* z26 RIOT emu
;*
;* 07-19-02 -- 32-bit
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

;*
;* I'm not really sure what mode the timer starts up in but it's not mode 1.
;* Otherwise blueprnt.bin doesn't come up and others as well.
;*

START_TIME = 07fffh			; 03ffffh

.data

Timer		dd	START_TIME	; the RIOT Timer
					; (gets initialized in INIT.ASM now)
TimerReadVec	dd	ReadTimer1024	; timer read vector
TimerByte	db	0		; a return value
TimerIntReg	db	0		; Timer Interrupt Register

; *EST* variables
DDR_A		db	0
DDR_B		db	0

ALIGN 2

ReadRIOTTab label dword
	dd	ReadPortA		; 280h PA Data
	dd	ReadDDR_A		; 281h PA Direction
	dd	ReadPortB		; 282h PB Data
	dd	ReadDDR_B		; 283h PB Direction
	dd	ReadTimer		; 284h Read Timer
	dd	ReadTimerIntReg		; 285h Read Timer Interrupt Register
	dd	ReadTimer		; 286h Read Timer
	dd	ReadTimerIntReg		; 287h Read Timer Interrupt Register

WriteRIOTTab label dword
	dd	SetRIOTTimer1		; 294h
	dd	SetRIOTTimer8		; 295h
	dd	SetRIOTTimer64		; 296h
	dd	SetRIOTTimer1024	; 297h

; *EST* table
WriteRIOTTab2 label dword
	dd	WritePortA		; 280h
	dd	WriteDDR_A		; 281h
	dd	WriteNothing		; 282h
	dd	WriteDDR_B		; 283h

.code


Init_Riot:
	mov	[Timer],START_TIME
	mov	[TimerReadVec], offset ReadTimer1024
	mov	[TimerByte],0
	mov	[TimerIntReg],0

	ret

;*
;* CPU wants to read a RIOT register
;*

ReadRIOT:
	and	esi,07h
	jmp	[ReadRIOTTab + esi*4]

ReadDDR_A:				; read data direction register A
	mov	esi,offset DDR_A
	ret

ReadDDR_B:				; read data direction rigister B
	mov	esi,offset DDR_B
	ret

ReadPortB:				; read console switches (port b)
	mov	esi,offset _IOPortB
	ret

ReadPortA:				; read hand controllers (port a)
	mov	esi,offset _IOPortA
	ret

;*
;* CPU wants to write to a RIOT register
;* On entry, si contains the address and [WByte] contains the value
;*

WriteRIOT:
	test	esi,010h
	jnz	WR_EST2
	test	esi,04h
	jnz	WriteNothing

	and	esi,03h
	jmp	[WriteRIOTTab2 + esi*4]
WR_EST2:
	test	esi,04h
	jz	WriteNothing

	and	esi,03h
	jmp	[WriteRIOTTab + esi*4]
	

WriteNothing:
	ret


WritePortA:
	push	eax
	mov	al,[WByte]
	and	al,[DDR_A]		; make sure that only output bits
	mov	ah,[DDR_A]		;   get written to SWCHA *EST*
	xor	ah,0FFh			;
	and	ah,[_IOPortA]		;
	or	al,ah			;

	cmp	[_KeyPad],2		; *EST* cheat for Star Raiders
	jne	WPAapply		;   wouldn'd read Joystick
	and	al,00Fh			;   without it
	mov	ah,[_IOPortA]		;
	and	ah,0F0h			;
	or	al,ah			;
WPAapply:
	mov	[_IOPortA],al
	cmp	[_KidVid],0		; Kid Vid game?
	je	WPAtestML
	call	KidVidWrite		; in keyboard.asm
	pop	eax
	ret

WPAtestML:
	test	[_Mindlink],3		; Mindlink game?
	jnz	[WPAhandleML]
	pop	eax
	cmp	[_BSType],10		; CompuMate?
	je	WPAhandleCM
	call	HandleKeyPad
	ret

WPAhandleCM:
	call	HandleCompuMate
	ret

WPAhandleML:
	test	al,[MindlinkTEST]	; ready to receive next bit?
	jz	WPAhML1
	call	NextMindlinkBit		; in mouse.asm
WPAhML1:
	pop	eax
	ret


WriteDDR_A:
	push	eax
	mov	al,[WByte]
	mov	[DDR_A],al
	pop	eax
	ret

WriteDDR_B:
	push	eax
	mov	al,[WByte]
	mov	[DDR_B],al
	pop	eax
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
	mov	[Timer],edx
	mov	[TimerReadVec], offset ReadTimer&op2
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
	mov	esi,offset TimerByte

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
	test	edx,040000h		; has the timer overflowed yet ?
	jnz	ReadOverflowed		;	 yes
	mov	esi,[TimerReadVec]	;   no, do appropriate read
	jmp	esi			; jmp [TimerReadVec] doesn't work in 16-bit segment 

ReadOverflowed:
	mov	[TimerByte],dl		; return this value
	mov	esi, offset TimerByte
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

;*
;* I don't exactly know how many bits to leave in the Timer counter
;* because I don't exactly know how long it is to the next interrupt.
;* But another interrupt *does* come.  (Otherwise lockchse.bin fails.)
;*

	and	[Timer],START_TIME	; clear interrupt flag
	mov	esi,offset TimerIntReg
	ret

;*
;* macro to clock the RIOT timer (after every instruction)
;*

ClockRIOT macro
local NoPF2

	movzx	edx,[RCycles]		; # of cycles for this instruction
	sub	[Timer],edx		; subtract from timer

	endm

;*
;* randomize RIOT timer
;*

RandomizeRIOTTimer:
	mov	eax,314159265			; *** this could be better ***
	and	eax,0ff00h
	shl	eax,2
	mov	[Timer],eax			;    see RIOT.ASM for details
	ret


