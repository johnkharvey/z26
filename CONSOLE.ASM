; *****************************************************************************
;			   Output Hex Word in AX
; *****************************************************************************

ConWord:push	ax
	mov	al,ah
	call	ConHex
	pop	ax
	call	ConHex
	ret
        
; *****************************************************************************
;			     Output Hex	Byte in	AL
; *****************************************************************************

ConHex:	push	ax			; save ax
	push	ax			; save for low byte
	shr	ax,4			; high byte
	call	ConHex2
	pop	ax			; low byte
	call	ConHex2
	pop	ax
	ret
ConHex2:push	ax
	and	ax,15			; print	NIBL in	hex
	cmp	ax,10
	jl	NotHexC
	add	ax,7
NotHexC:add	ax,'0'
	call	ConOut
	pop	ax
	ret
        
; *****************************************************************************
;			Input of Character into	AL
; *****************************************************************************

ConIn:	push bx
	push cx
	push dx
	mov  ah,8			; Read char from console (MS-DOS)
	int  MSDOS			; its now in AL
	cmp  al,0			; extended ?
	jnz  CINotX
	mov  ah,8			; read next & set bit 7
	int  MSDOS
	or   al,080h			; set bit 7
CINotX:	pop  dx				;  dx, cx, bx
	pop  cx
	pop  bx
	ret
	
; *****************************************************************************
;			  Output character in AL
; *****************************************************************************

ConOut:	push	ax
	push	bx
	push	cx
	push	dx
        
	cmp  al,0			; ignore NULL
	je   CXOut
	mov  dl,al
	cmp  dl,13			; special code for CR
	jne  NotCR
	mov  al,10			; print	CR & LF
	Call ConOut
	mov  dl,13
NotCR:	mov  ah,6			;output to STDOUT
	int  MSDOS
CXOut:  
	pop	dx
	pop	cx
	pop	bx
	pop	ax
        ret
