; z26 cpu jam handlers

.data

jam_msg	db	'Halt ','$'

.code


;*
;* jam handler 
;*

jam:
	dec	[reg_pc]	; point at jam instruction
	read	al,[reg_pc]
	cmp	al,052h		; starpath jam?
	je	StarpathJAM

	call	TIATextMode
	push	offset jam_msg
	call	_put_str
	read	al,[reg_pc]
	call	ConHex		; display it
	mov	al,'@'
	call	ConOut
	mov	ax,[reg_pc]
	call	ConWord		; display address

WaitEsc:test	[KeyTable+KeyEsc],128	; wait for ESC to be pressed
	jz	WaitEsc

	jmp	GoDOS


