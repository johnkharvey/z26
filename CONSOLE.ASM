; console.asm -- z26 console output routines

;Here's the integer output routine from TECO for a PDP-10 by RC CLEMENTS
;This version is dated 1970.


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
;* recursive routine to output integer in eax (decimal radix)
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

; *****************************************************************************
;			    Output Hex Byte in AL
; *****************************************************************************

ConHex:	push	ax		; save ax
	push	ax		; save for low byte
	shr	ax,4		; high byte
	call	HexNybble
	pop	ax		; low byte
	call	HexNybble
	pop	ax
	ret

; *****************************************************************************
;                    Output nybble in bottom of AL in hex
; *****************************************************************************

HexNybble:
	push	ax
	and	ax,15
	cmp	ax,10
	jl	NotHexC
	add	ax,7
NotHexC:add	ax,'0'
	call	ConOut
	pop	ax
	ret
        
; *****************************************************************************
;			  Output character in AL
; *****************************************************************************

ConOut:	pushad
	mov	dl,al
	mov	ah,6
	int	MSDOS
	popad
	ret


;*
;* output decimal word on stack
;*

_put_dec:
	xor	eax,eax
	pop	cx		; return adr
	pop	ax		; val
	push	ax
	push	cx		; restore stack

	call	DPT		; output it

	ret

;*
;* output hex word on stack
;*

_put_hex:
	pop	cx		; return adr
	pop	ax		; val
	push	ax
	push	cx		; restore stack

	call	ConWord		; output it

	ret


;*
;* output string pointed to by stack
;*

_put_str:
	pop	cx		; return adr
	pop	bx		; pointer to message
	push	bx
	push	cx		; restore stack

psloop:	mov	al,[bx]
	inc	bx
	test	al,al		; null terminator ?
	jz	psret		;   yes, done
	cmp	al,'$'		; old style terminator?
	jz	psret		;   yes, done
	cmp	al,10		; an 'LF' ?
	jne	psnolf		;   no
	mov	al,13		;   yes, output 'CR' first
	call	ConOut
	mov	al,10		; then the 'LF'
psnolf:	call	ConOut
	jmp	psloop

psret:	ret


;*
;* output <CR><LF>
;*

_crlf:
	mov	al,13
	call	ConOut
	mov	al,10
	call	ConOut
	ret


;*
;* int kb_hit()
;*

_kb_hit:
	mov	ah,1
	int	16h		; check keyboard buffer
	jz	NoChar		;   nothing there
	mov	ax,1		; char available
	ret

NoChar:	mov	ax,0
	ret


;*
;* int get_char()
;*

_get_char:
	mov	ah,0
	int	16h		; get char from buffer
	xor	ah,ah
	ret

