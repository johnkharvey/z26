;*
;* init.asm -- initialize all data in z26 asm modules
;*

;*
;* routine to do rep stosb to data segment
;*

rep_stosb:
	cmp	ecx,0
	jz near rs_done

rs_loop:
 	mov	byte [edi],al
	inc	edi
	dec	ecx
	jnz near rs_loop

rs_done:
	ret

;*
;* macro to clear memory
;*

%macro clear_mem 2

	mov	edi, %1
	mov	ecx, %2
	sub	ecx,edi  ;  # of bytes to clear
	xor	al,al
	call	rep_stosb  ;  clear memory

%endmacro

;*
;* initialize data
;*

InitData:
	call	InitCVars
	call	Init_CPU
	call	Init_CPUhand
	call	Init_TIA
	call	Init_Riot
	call	Init_P2
	call	Init_Starpath
	call	Init_Tiasnd
	call	Init_SoundQ
	
	call	RandomizeRIOTTimer

	ret

; z26 is Copyright 1997-2011 by John Saeger and contributors.  
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.
