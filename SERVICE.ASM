; service.asm -- I/O and other services for z26 core

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 07-27-02 -- break ground


;*
;* sprite table support
;*

AddTablePointer macro arg1
	add	esi,[arg1&_Table]		;32-bit -- add in table offset
	endm


;*
;* routine to do rep stosw to graphics segment
;*

gs_rep_stosw macro
	rep	stosw
	endm

;*
;* routine to store to graphics segment
;*

gs_store macro arg1, arg2
	mov	&arg1, arg2
	endm


;*
;* initialize services
;*

Init_Service:
	call	_SetupSoundBlaster
	call	_TIAGraphicMode		; Switch into VGA mode
	call	MouseInit		; *EST*
	ret

;*
;* end of program (escape pressed or bad opcode)
;*

GoDOS:
	call	_kv_CloseSampleFile	; close file if opened
	call	_sound_clear		; turn sound off (Soundblaster)
	call	_TIARestoreVideoMode

	jmp	ModuleReturn

;*
;* mouse services
;*

_init_mouse:
	mov	eax,-1			; mark mouse present
	ret

_get_mouse_button_status:
	pushad
	call	_srv_get_mouse_button_status
	popad
	mov	ebx,[_srv_mouse_button]
	ret

_get_mouse_movement:
	pushad
	call	_srv_get_mouse_movement
	popad
	mov	ecx,[_srv_micky_x]
	mov	edx,[_srv_micky_y]
	ret

;*
;* exit if escape seen
;*

_TestEscExit:
	test	[_KeyTable+KeyEsc],128	; ESC pressed ?
	jnz	GoDOS			;   yes
	test	[_KeyTable+KeyBackSlash],128
	jnz	GoDOS
	ret

;*
;* soundblaster entry points
;*

_SetupSoundBlaster:
	call	_srv_sound_on
	ret

_sound_clear:
	call	_srv_sound_off
	ret


;*
;* frame synchronizer
;*

_VSync:	
	pushad

	call	_srv_Events
	cmp	[_srv_done],0
	jnz	GoDOS

	call	_srv_Flip

	popad
	ret


;*
;* z26 linear graphics modes and palette setup
;*

_TIARestoreVideoMode:
	pushad
	call	_srv_DestroyScreen	; destroy the screen
	popad
	ret

;*
;* turn on graphics mode
;*

_TIAGraphicMode:
	pushad
        cmp     [_VideoMode],8          ; did user specify a valid (0-8) video mode
        jna     UserVideoMode           ;    yes, don't override
        mov     [_VideoMode],0          ; set default mode
UserVideoMode:
	call	_position_game		; set game vertical positionn
;	call	_GeneratePalette	; calculate palette colors
	call	_srv_CreateScreen	; set up the screen
        call    _ClearScreenBuffers     ; clear the 4 buffers for screen comparing
	popad
	ret

;*
;* switch windowed mode
;*

_TIAWindowMode:
	pushad
	call	_srv_WindowScreen
	popad
	ret

;*
;* copy frame buffer to screen
;*

_ModeXCopyScreen:
	pushad
	call	_srv_CopyScreen
	popad
	ret


;*
;* routine to blank the remains of the screen buffer, if not all of the
;* displayed data gets filled by the rendering routine
;* gets called from MAIN.ASM
;*

BlankBufferEnd:
        pushad
	mov	eax,[_MaxLines]
	lea	eax,[eax+eax*4]
	shl	eax,5			; *160

	add	eax,[_ScreenBuffer]

	cmp	[DisplayPointer],eax	; render pointer past end of displayable?
        jae     BBEret                  ;        yes, don't blank unfilled buffer

        mov     esi,[DisplayPointer]
        sub     eax,esi                 ; max. buffer size - current buffer position
        mov     ebx,0
BBEdo:
        mov     [esi],ebx               ; fill unused buffer space with black
        add     esi,4
        sub     eax,4
        jnz     BBEdo
BBEret:
        popad
        ret
