;*
;* z26 RIOT timer emu
;*
;* eventually may want to correct for # of cycles in timer read and write instructions...
;*


.CEND
.DATASEGMENT

Timer		dw	0		; the RIOT Timer
TRate		dw	0		; Number of cycles per timer count

PreScaler	dw	0

TimerVec	dw	 Timer0		; timer vector -- Timer1 for starmaster
					;			 and solaris

TimerCount	dw	8,64,1024	; count values for the RIOT

.DEND
.CODESEGMENT


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

SetTimer:
	push	ax			; set the timer
	movzx	ax,[WByte]		; get the value to write
	mov	[Timer],ax		; and write it !
	pop	ax
	cmp	si,0294h		; is it the 1 clock timer
	je	SetMode1		; if so,go to mode 1

	push	ax			; it is the Mode n timer
	push	bx
	mov	bx,si			; work out the offset
	sub	bx,0295h
	add	bx,bx
	mov	ax,TimerCount[bx]	; get the counting value
	mov	[TRate],ax		; set the tick rate
	mov	[TimerVec],offset NewTimer
	mov	[PreScaler],0
	
	pop	bx
	pop	ax
	ret

SetMode1:				; set vector to call the Timer1 routine
	mov	[TimerVec],offset Timer1
	ret


;*
;* CPU wants to read the RIOT timer
;*
;* return with si pointing to value to read from $284 (INTIM)
;*

ReadTimer:
	mov	si,offset Timer		; make si point to the timer
	ret


;*
;* Process the timer (after every instruction)
;*
;* TimerVec points to one of these routines...
;*

NewTimer:
	cmp	[PreScaler],0
	je	NewTimerTick
	dec	[PreScaler]
	jmp	NewTimerNextCycle

NewTimerTick:
	dec	[Timer]
	cmp	[Timer],0ffffh
	jne	NewTimerSameRate
	dec	[RCycles]
	mov	[TimerVec], offset Timer1
	jmp	Timer1

NewTimerSameRate:
	mov	dx,[TRate]
	mov	[PreScaler],dx
	dec	[PreScaler]

NewTimerNextCycle:
	dec	[RCycles]
	jnz	NewTimer
	ret
	

Timer1: movzx	dx,[RCycles]		; normal timer, decrements at 1 per
	sub	[Timer],dx		; processor cycle
Timer0:
	ret

