; *****************************************************************************
;
;		       Missile handling code
;
;	On entry	BP Points to the missile record (clock/addr/data/0)
;
; *****************************************************************************

ALIGN_ENTRY

TRMiss:					; ok , we've found a missile draw....
	mov	bl,TIAReg[bp]		; bx = 0 if m0,bx = 1 if m1
	and	bx,1

	mov	al,TIA+TIAResmp0[bx]	; if its locked to the player
	test	al,2			; don't do anything at all !
	jnz	TNret

	mov	al,TIA+TIAEnam0[bx]	; get the enable flag
	test	al,2			; if zero,don't draw
	jz	TRMNoDraw

	mov	al,TIA+TIANuSiz0[bx]	; get the missile size
	mov	ah,TGMissile0		; and the pixel to set
	cmp	bl,0			; which is different for the missiles !
	jz	TGMCDraw
	mov	ah,TGMissile1

TGMCDraw:
	push	bx
	push	si

	mov	bl,TIAClock[bp]		; get clock value (bh already 0)
	add	bx,offset TIADisplay	; bx points to ball start in line

	call	TIAMissileObject	; draw the object .....

	pop	si
	pop	bx

TRMNoDraw:
	mov	al,TIAReg[bp]		; if its a copy draw....
	test	al,64			; (e.g. bit 6 is set)
	jnz	TRMNoSetRes		; don't set RESP# from the clock

	mov	al,TIAClock[bp]		; update RESm# counter with clock
	mov	TIA+TIAResm0[bx],al	; so its drawn on the next line

TRMNoSetRes:
	mov	al,TIAReg[bp]		; register that was written....
	test	al,128			; if bit 7 is clear (new Res...)
	jnz	TGret
	or	al,128
	call	TIAInvalidate		; invalidate old copies
TGret:	ret



ALIGN_ENTRY

TIAMissileObject:
	push	ax
	call	TIASolidObject		; draw the first missile
	mov	al,TIAReg[bp]		; if its a copy draw....
	test	al,64			; (e.g. bit 6 is set)
	pop	ax
	jnz	TGret			; don't queue up multiples

	push	cx
	push	bp
	and	al,7			; isolate size/copies bits
	movzx	esi,al
	call	[offset TMODiffTab + esi*2] ; branch to appropriate routine
	pop	bp
	pop	cx

	ret

TMORegular:
TMO2Width:
TMO4Width:
	ret

ALIGN_ENTRY

TMO2Close:
	mov	ax,[bp]			; al = clock, ah = reg
	add	al,16
	or	ah,64
	call	TIAInsert
	ret

ALIGN_ENTRY

TMO2Medium:
	mov	ax,[bp]			; al = clock, ah = reg
	add	al,32
	or	ah,64
	call	TIAInsert
	ret

ALIGN_ENTRY

TMO3Close:
	mov	ax,[bp]			; al = clock, ah = reg
	mov	cx,ax
	add	al,16
	or	ah,64
	call	TIAInsert
	mov	ax,cx
	add	al,32
	or	ah,64
	call	TIAInsert
	ret

ALIGN_ENTRY

TMO2Far:
	mov	ax,[bp]			; al = clock, ah = reg
	add	al,64
	or	ah,64
	call	TIAInsert
	ret

ALIGN_ENTRY

TMO3Medium:
	mov	ax,[bp]			; al = clock, ah = reg
	mov	cx,ax
	add	al,32
	or	ah,64
	call	TIAInsert
	mov	ax,cx
	add	al,64
	or	ah,64
	call	TIAInsert
	ret



.CEND
.DATASEGMENT
TMODiffTab	dw	TMORegular	; 0
		dw	TMO2Close	; 1
		dw	TMO2Medium	; 2
		dw	TMO3Close	; 3
		dw	TMO2Far		; 4
		dw	TMO2Width	; 5
		dw	TMO3Medium	; 6
		dw	TMO4Width	; 7
.DEND
.CODESEGMENT
