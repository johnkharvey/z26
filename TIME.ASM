; time.asm -- z26 timing functions

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 8253 system timer I/O addresses

	TIMER0=		040h
	TIMER_CTL=	043h

.data

DelayTime	dd	0
DelayStart	dd	0

hi_time		dd	0
low_time	dw	0

.code

;*
;* GetTime -- return 32-bit hardware time in eax
;*            must call at least 36 times per second or will fail (27 ms)
;*
;*	      rolls over approx every 40 minutes (because VSync strips top bit)

_GetTime:

	pushf
	cli
	xor	al,al
	out	TIMER_CTL,al		; latch the timer count
	in	al,TIMER0		; read lo-order byte
	mov	ah,al			; save
	in	al,TIMER0		; read hi-order byte

	xchg	al,ah			; position properly
	neg	ax			; convert from down counter to up counter

	test	[low_time],04000h	; was top bit of lo-order time set?
	jz	gt_fwd			;   no, can't run backward
	test	ax,08000h		; top bit of new result set?
	jnz	gt_fwd			;   yes, counter hasn't flipped yet
	inc	[hi_time]		;   no, inc hi-order time value
gt_fwd:	shr	ax,1			; cut rate in half
	mov	[low_time],ax		; we have a new lo-order time value
	mov	eax,[hi_time]
	shl	eax,15
	or	ax,[low_time]
	popf
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
;* C function entry point for long delays
;* set _DelayTime before calling
;*

public _LongDelay
_LongDelay proc far
	pushad
	call	_SetupTimer
	mov	eax,[_DelayTime]
	call	_Delay
	popad
	ret
_LongDelay endp

;*
;* SetupTimer -- put the system timer in Mode 3 (was mode 2 -- divide by N)
;*

_SetupTimer:

	cli
	mov	al,036h			; was 034h
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

;	cli
;	mov	al,036h
;	out	TIMER_CTL,al
;	xor	al,al
;	out	TIMER0,al		; divide by 65536
;	out	TIMER0,al
;	sti

	ret

