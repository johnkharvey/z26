; z26 cpu jam handlers

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

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

WaitEsc:test	[_KeyTable+KeyEsc],128	; wait for ESC to be pressed
	jz	WaitEsc

	jmp	GoDOS


