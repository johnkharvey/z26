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

ALIGN_ENTRY

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

ALIGN_ENTRY

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

	mov	word ptr [TIAWritePointer],offset TIABuffer	; invalidate write pointer
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

;*
;* macro to find insertion point and make space for new object in TIA buffer
;*

FindInsertionPoint macro
local FindInsert, CarryForward, InsertDone

	push	bx
	push	cx

FindInsert:
	mov	ebx,[bp]
	add	bp,4
	cmp	bl,TIAInvalid		; skip invalid entrys
	je	FindInsert
	cmp	al,bl			; try next if clock < insert clock
	jae	FindInsert		; was jae

	sub	bp,4
	push	bp			; save insertion point

CarryForward:
	add	bp,4
	mov	ecx,[bp]		; next to carry forward
	mov	[bp],ebx		; save what was carried forward
	cmp	bl,TIAEnd		; was the end marker carried forward
	je	InsertDone
	mov	ebx,ecx			; update the carry forward registers
	jmp	CarryForward

InsertDone:
	pop	bp			; restore insertion point
	pop	cx
	pop	bx

	endm

;*
;* find insertion point and make space for new record (used by WriteTIA)
;* new insertion clock is in al
;*

ALIGN_ENTRY

FindInsert:
	push	bp
	mov	bp,[TIAWritePointer]	; we assume insertions from WriteTIA happen in order
;	mov	bp,offset TIABuffer

	FindInsertionPoint

	mov	[TIAWritePointer],bp	; mark location of new insertion
	pop	bp
	ret



; *****************************************************************************
;
;	     Insert a record in the TIA Buffer (pointed to by BP)
;		    AL = Clock Value, AH = Register value
;
; *****************************************************************************

ALIGN_ENTRY

TIAInsert:
	push	bp

	FindInsertionPoint

	mov	[bp],ax			; clock = al, reg = ah
	mov	byte ptr TIAVal[bp],0	; zero out the value field

	pop	bp
	ret


; *****************************************************************************
;
;	look for the first item in TIABuffer (BP) where Register = al
;	and mark it invalid
;
; *****************************************************************************

ALIGN_ENTRY

TIAInvalidate:
	push	bp
TIAILoop:	
	cmp	byte ptr TIAClock[bp],TIAEnd	; check if finished
	je	TIAIDone
	cmp	al,TIAReg[bp]		; if found, mark it
	je	TIAIMark
	add	bp,4			; do next until end
	jmp	TIAILoop

TIAIMark:				; mark it invalid.
	mov	byte ptr TIAClock[bp],TIAInvalid
TIAIDone:
	pop	bp
	ret

