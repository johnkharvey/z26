;*
;* paddle.asm -- z26 paddle support
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 09-07-02 -- 32-bit

.data

TRIGMAX =	240			; (guardian)  max val for charge triggers
TRIGMIN =	1;22			; (solrstrm)  min val for charge triggers

ChargeCounter	dd	-1		; # of lines capacitors have been charging

ChargeTrigger0	dd	TRIGMAX / 2	; ChargeCounter val to trigger dumped input
ChargeTrigger1	dd	TRIGMAX / 2
ChargeTrigger2	dd	TRIGMAX / 2
ChargeTrigger3	dd	TRIGMAX / 2

PaddleRepeat	dd	0
PrevPaddleFrame	dd	0

PaddleBits	db	080h,040h, 8, 4
; *EST* was PaddleBits	    db	    080h, 040h, 2, 4

.code

;*
;* paddle acceleration
;*
;* allows fine adjustments if quick hits, speeds up as keys are held down
;*

CalcPaddleAcceleration:
	mov	edx,[Frame]
	sub	edx,[PrevPaddleFrame]
	cmp	edx,1			; key being held down ?
	jne	NewPaddleRepeat		;	  no, fresh hit
	inc	[PaddleRepeat]		;	 yes, increment repeat count
	mov	edx,[_PaddleGame]
	cmp	edx,[PaddleRepeat]	; repeat count hit max sensitivity ?
	ja	PaddleInRange		;   yes
	mov	[PaddleRepeat],edx	;   no, store new value
	jmp	PaddleInRange

NewPaddleRepeat:	
	mov	[PaddleRepeat],2	; fresh hit, start counting at 1 (gets shifted right below)
PaddleInRange:
	mov	edx,[Frame]
	mov	[PrevPaddleFrame],edx	; save last frame with key hit
	ret

;*
;* decrement paddle trigger
;*

PaddleTriggerDown0:
	call	CalcPaddleAcceleration
	push	esi
	movzx	esi,[_KeyBase]		; trigger to modify
	mov	edx,[PaddleRepeat]
	shr	edx,1
;	cmp	[ChargeTrigger0 + esi*4],TRIGMIN
;	jb	PTRet
;	sub	[ChargeTrigger0 + 4*esi],edx

	sub	[ChargeTrigger0 + 4*esi],edx
	jge	PTRet
	add	[ChargeTrigger0 + 4*esi],edx

PTRet:	pop	esi
	ret

;*
;* increment paddle trigger
;*

PaddleTriggerUp0:
	call	CalcPaddleAcceleration
	push	esi
	movzx	esi,[_KeyBase]		; trigger to modify
	mov	edx,[PaddleRepeat]
	shr	edx,1
	cmp	[ChargeTrigger0 + 4*esi],TRIGMAX
	ja	PTRet
	add	[ChargeTrigger0 + 4*esi],edx
	pop	esi
	ret

;*
;* handle paddle button press
;*

PaddleButton0:
	push	esi
	movzx	esi,[_KeyBase]		; which button pressed
	mov	dl,PaddleBits[esi]	; convert to proper bit
	not	dl
	and	[_IOPortA],dl		; clear bit in IOPortA
	pop	esi
	ret
