; z26 cpu jam handlers

; z26 is Copyright 1997-2011 by John Saeger and contributors.  
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-04-02 -- 32-bit

[section .code]

;*
;* jam handler 
;*

jam: dec	dword [reg_pc] ; point at jam instruction
 	read  al,dword [reg_pc]
	cmp	al,052h		 ;  starpath jam?
	je near StarpathJAM
	
	ret

 	read  al,dword [reg_pc]
 	mov	byte [cpu_a],al ; hand over opcode to C display routine
 	mov	eax,dword [reg_pc]
 	mov	dword [cpu_pc],eax
 	mov	byte [MessageCode],3 ; Jam instruction $xx @ $xxxx
	jmp	GoAway

