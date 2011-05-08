; service.asm -- I/O and other services for z26 core

; 07-27-02 -- break ground

;*
;* sprite table support
;*

%macro AddTablePointer 1
 	add	esi,dword [%1_Table] ; 32-bit -- add in table offset
%endmacro


;*
;* routine to do rep stosw to graphics segment
;*

%macro gs_rep_stosw 0
	rep	stosw
%endmacro


;*
;* routine to store to graphics segment
;*

%macro gs_store 2
	mov	byte %1, %2
%endmacro


;*
;* initialize services
;*

Init_Service:
	pushad
	call	srv_sound_on
	call	srv_SetVideoMode	;  Switch into VGA mode
;	call	MouseInit		; *EST*
	popad
	ret


;*
;* end of program (escape pressed or bad opcode)
;*

GoAway:
	pushad
	call	kv_CloseSampleFile	 ;  close file if opened
;	call	srv_sound_off		 ;  turn sound off (Soundblaster)
;	call	srv_DestroyScreen
	popad

	jmp	ModuleReturn
	
;*
;* escape polling routine
;*

TestEscExit:
 	test	byte [ExitEmulator],128 ; ESC or backslash pressed?
	jnz near GoAway
	ret


;*
;* frame synchronizer
;*

VSync:	
	pushad

	call	srv_Events
 	cmp	byte [srv_done],0
	jnz near GoAway

	call	srv_Flip

	popad
	ret


;*
;* routine to blank the remains of the screen buffer, if not all of the
;* displayed data gets filled by the rendering routine
;* gets called from MAIN.ASM
;*

BlankBufferEnd:
        pushad
 	mov	eax,dword [MaxLines]
 	lea	eax, [eax+eax*4]
	shl	eax,6			 ;  *160

 	add	eax,dword [ScreenBuffer]

 	cmp	dword [DisplayPointer],eax ; render pointer past end of displayable?
        jae near BBEret			;      yes, don't blank unfilled buffer

	mov     esi,dword [DisplayPointer]
        sub     eax,esi			;  max. buffer size - current buffer position
        mov     ebx,0
BBEdo:
	mov     dword [esi],ebx 	; fill unused buffer space with black
        add     esi,4
        sub     eax,4
        jnz near BBEdo
BBEret:
        popad
        ret


; z26 is Copyright 1997-2011 by John Saeger and contributors.  
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.
