;*
;* TIA buffer management routines
;*


; *****************************************************************************
;
;     Insert all the objects (bl,p0,m0,p1,m1) from the last line at their
;     current positions as records <lastclock> <reg+128> 0 0. This will
;     cause them to be redrawn on the next line at the same position.
;     If an object is redrawn before they are reached they are invalidated.
;
; *****************************************************************************

TIAInsertObjects:
	mov	bx,TIAResp0		; bx - offset into TIA
TIAIOLoop:
	mov	al,TIA[bx]		; al is the clock value.
	mov	ah,bl			; bl is the register to write
	or	ah,128			; set bit 7,its a copied write
	call	TIAInsert		; insert the object.
	inc	bx			; go to the next object
	cmp	bx,TIAResbl		; Resbl is the last one.
	jle	TIAIOLoop
	ret

; *****************************************************************************
;
;		  Sort the TIA Buffer into Clock Order ....
;
; *****************************************************************************

TIASortBuffer:
	push	ax
	push	bx
	push	cx
	push	dx
	mov	al,TIAClock[bp]		; don't sort if 0 or 1 items
	cmp	al,TIAEnd
	je	TIASortExit
	mov	al,TIAClock+4[bp]
	cmp	al,TIAEnd
	je	TIASortExit
TIASortMain:
	mov	cl,0			; bl is set if any swaps this pass
	mov	bx,bp			; bx points into the table
TIASortLoop:
	mov	al,TIAClock[bx]		; get clocks of next 2 writes
	mov	ah,TIAClock+4[bx]
	cmp	al,ah			; if [first] <= [second] skip swap
	jbe	TIANoSwap

	mov	edx,[bx]		;do the swap
	mov	eax,4[bx]
	mov	[bx],eax
	mov	4[bx],edx

	inc	cl			; we've done a swap this pass.
TIANoSwap:
	add	bx,4			; go to next pair of writes
	mov	ah,TIAClock+4[bx]	; if there is one to swap with next...
	cmp	ah,TIAEnd
	jne	TIASortLoop		; then jump back

	cmp	cl,0			; have we swapped this time round
	jnz	TIASortMain		; yes,go back and sort again

TIASortExit:
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret


; *****************************************************************************
;
;	     Insert a record in the TIA Buffer (pointed to by BP)
;		    AL = Clock Value, AH = Register value
;
; *****************************************************************************

TIAInsert:
	push	bx
	push	cx
	push	bp
	push	ax			; this must be last...
        
TIAFindInsert:
	mov	bl,TIAClock[bp]		; bl is clock here
	add	bp,4
	cmp	al,bl			; try next if clock < insert clock
	jae	TIAFindInsert

	sub	bp,4
	push	bp			; save where the results go

	mov	ebx,[bp]		; 1st to carry forward
TIACarryForward:
	add	bp,4
	mov	ecx,[bp]		; next to carry forward
	mov	[bp],ebx		; save what was carried forward
	mov	bl,TIAClock[bp]
	cmp	bl,TIAEnd		; was the end marker carried forward
	je	TIAInsert2
	mov	ebx,ecx			; update the carry forward registers
	jmp	TIACarryForward

TIAInsert2:
	pop	bp
	pop	ax			; restore the data and address
	mov	TIAClock[bp],al
	mov	TIAReg[bp],ah
	xor	bl,bl
	mov	TIAVal[bp],bl		; zero out the value field

	pop	bp
	pop	cx
	pop	bx
        
	ret


; *****************************************************************************
;
;	look for the first item in TIABuffer (BP) where Register = al
;	and mark it invalid
;
; *****************************************************************************

TIAInvalidate:
	push	bp
TIAI1:	mov	ah,TIAClock[bp]		; check if finished
	cmp	ah,TIAEnd
	je	TIAI2
	cmp	al,TIAReg[bp]		; if found, mark it
	je	TIAIMark
	add	bp,4			; do next until end
	jmp	TIAI1
TIAIMark:				; mark it invalid.
	mov	byte ptr TIAClock[bp],TIAInvalid
TIAI2:
	pop	bp
	ret


