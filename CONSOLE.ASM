;Here's the original integer output routine from TECO for a PDP-10 by RC CLEMENTS

;The original PDP-10 version is dated 1970.  
;But I suspect the algorithm is much older.


;ROUTINE TO OUTPUT DECIMAL (OCTAL IF S.OCTL IS ON) INTEGER
;CALL	MOVE B,INTEGER
;	MOVEI A,ADDRESS OF OUTPUT ROUTINE
;	PUSHJ P,DPT
;	RETURN

;DPT:	MOVEM	A,LISTF5
;	JUMPGE	B,DPT1		;NUMBER > 0?
;	MOVEI	CH,"-"		;NO. OUTPUT -
;	PUSHJ	P,@LISTF5
;	MOVMS	B		;B:=ABSOLUTE VALUE OF B
;DPT1:	MOVEI	A,12		;RADIX 10
;	TXZE	F2,S.OCTL	;[323] OCTAL RADIX?
;	MOVEI	A,10		;YES, CHANGE TO RADIX 8
;	IDIVI	B,(A)		;E:=DIGIT
;	HRLM	E,(P)		;PUT DIGIT ON LEFT HALF OF TOP OF PUSH DOWN LIST
;	JUMPE	B,.+2		;DONE?
;	PUSHJ	P,.-3		;NO. PUSH THIS DIGIT AND PRINT RETURN ADDRESS.
;	HLRZ	CH,(P)		;YES. CH:=DIGIT
;	ADDI	CH,"0"		;CONVERT IT TO ASCII.
;	JRST	@LISTF5		;PRINT IT


; Here it is for a PC :)

;*
;* routine to output integer in eax (decimal radix)
;*

DPT:	xor	edx,edx		; clear hi-order doubleword
	mov	ebx,10
	div	ebx		; divide eax by 10
	push	edx		; push the remainder
	test	eax,eax
	jz	DPTPR		;   eax zero, done
	call	DPT		; do next digit
DPTPR:	pop	eax		; get top digit
	add	eax,'0'		; convert it to ascii
	jmp	ConOut		; print it

; *****************************************************************************
;			   Output Hex Word in AX
; *****************************************************************************

ConWord:push	ax
	mov	al,ah
	call	ConHex
	pop	ax
	call	ConHex
	ret

;*
;* output hex long in eax
;*

ConLong:push	eax
	shr	eax,16
	call	ConWord
	pop	eax
	Call	ConWord
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
