; time.asm -- z26 timing functions

; 8253 system timer I/O addresses

	TIMER0=		040h
	TIMER_CTL=	043h

;*
;* GetTime -- return 32-bit hardware time in eax
;*            must call at least 18 times per second or will fail (54 ms)
;*
;*	      rolls over approx every 40 minutes (because VSync strips top bit)

_GetTime:

	xor	al,al
	out	TIMER_CTL,al		; latch the timer count
	in	al,TIMER0		; read lo-order byte
	mov	ah,al			; save
	in	al,TIMER0		; read hi-order byte

	xchg	al,ah			; position properly
	neg	ax			; convert from down counter to up counter
	cmp	ax,[low_time]		; time run backward ?
	ja	gt_fwd			;   no
	inc	[hi_time]		;   yes, inc hi-order time value
gt_fwd:	mov	[low_time],ax		; we have a new lo-order time value
	mov	eax,dword ptr [low_time]

	ret

;*
;* Delay by amount in eax register
;*

_Delay:

	mov	[DelayTime],eax		; save delay time
	call	_GetTime		; get start time
	mov	[DelayStart],eax

DelayLoop:
	call	_GetTime		; elapsed time
	sub	eax,[DelayStart]
	cmp	eax,[DelayTime]		; been enough ?
	jb	DelayLoop		;   not yet

	ret


;*
;* SetupTimer -- put the system timer in Mode 2 (divide by N)
;*

_SetupTimer:

	cli
	mov	al,034h
	out	TIMER_CTL,al
	xor	al,al
	out	TIMER0,al		; divide by 65536
	out	TIMER0,al
	sti

	ret

;*
;* RestoreTimer -- put the system timer back in Mode 3 (default square wave)
;*

_RestoreTimer:

	cli
	mov	al,036h
	out	TIMER_CTL,al
	xor	al,al
	out	TIMER0,al		; divide by 65536
	out	TIMER0,al
	sti

	ret

.CEND
.DATASEGMENT

DelayTime	dd	0
DelayStart	dd	0

low_time	dw	0
hi_time		dw	0

.DEND
.CODESEGMENT
