; z26 cpu jam handlers

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-04-02 -- 32-bit

.code

;*
;* jam handler 
;*

jam:	dec	[reg_pc]		; point at jam instruction
	read	al,[reg_pc]
	cmp	al,052h		; starpath jam?
	je	StarpathJAM

	read	al,[reg_pc]
	mov	[_cpu_a],al		; hand over opcode to C display routine
	mov	eax,[reg_pc]
	mov	[_cpu_pc],eax
	mov	[_MessageCode],3	; Jam instruction $xx @ $xxxx
	jmp	GoDOS

