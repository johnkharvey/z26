.data

_StartLineTable label dword
        dd      28, 28, 28      ; 400x300
        dd      22, 42, 42      ; 320x240
        dd      42, 58, 58      ; 320x200
        dd      28, 28, 28      ; 800x600
        dd      22, 42, 42      ; 640x480
        dd      42, 58, 58      ; 640x400
        dd      28, 28, 28      ; 800x600
        dd      22, 42, 42      ; 640x480
        dd      42, 58, 58      ; 640x400

;              NTSC PAL SECAM

_MaxLineTable label dword
        dd      266
        dd      240
        dd      200
        dd      266
        dd      240
        dd      200
        dd      266
        dd      240
        dd      200

.code


_position_game:

;*
;* set up max # of lines to display based on video mode
;*

	movzx	esi,[_VideoMode]
	mov	esi,[_MaxLineTable + esi*4]
        cmp     esi,[_MaxLines]         ; did user specify a screen height?
        ja      UserSetHeight           ;   yes, don't override
	mov	[_MaxLines],esi
UserSetHeight:

;*
;* set up CFirst (first line to display)
;*

	mov	edx,[_UserCFirst]
	mov	[_CFirst],edx
	cmp	[_UserCFirst],0ffffh	; did user specify a line number?
	jne	TGM_TestUltimate	;   yes, don't override
	mov	edx,[_DefaultCFirst]
	mov	[_CFirst],edx
	cmp	[_DefaultCFirst],0ffffh	; does game have a recommended starting line?
	jne	TGM_TestUltimate	;   yes, use it

        movzx   esi,[_PaletteNumber]
        cmp     esi,3                   ; if not NTSC, PAL or SECAM (0, 1, 2)
        jb      ValidPaletteNumber
        mov     esi,0                   ;   then position for NTSC game
ValidPaletteNumber:
        movzx   edx,[_VideoMode]
        imul    edx,3                   ; 3 palettes per video mode
        add     esi,edx
	mov	esi,[_StartLineTable + esi*4]
	mov	[_CFirst],esi		; use the standard default

;*
;* adjust CFirst based on game size
;*

TGM_TestUltimate:
	cmp	[_MaxLines],400		; in a very tall video mode?
	jb	TGM_Done		;   no
	cmp	[_CFirst],0		; frogpond or pharhcrs ?
	jz	TGM_Done		;   yes
	mov	[_CFirst],1		;   no, this is ultimate reality mode

TGM_Done:
	mov	edx,[_CFirst]
	mov	[OldCFirst],edx		; remember starting line for homing the display
	mov	[TopLine],edx		; set up some things in case there's no vsync
	add	edx,[_MaxLines]		; (like bowlg_tw.bin)
	mov	[BottomLine],edx

	ret
