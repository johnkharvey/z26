;*
;* z26 mouse code
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 09-07-02 -- 32-bit

.data
MouseAvail		db	0

MJ_Cnt		db	0
MJ_Last_IOPortA	db	0
MJ_Horiz		dd	0
MJ_Vert		dd	0

_Threshold		dd	2

MLG_mouseX		dd	320
MLG_mouseY		dd	200

MLG_Xpos		dd	1	; horizontal and vetical coordinates
MLG_Ypos		dd	1	;   for LG marker dispaly
MLG_Colour		db	0	; colour cycling the marker

MLG_ShotCycle	db	0	; cycle and line of hit - gets
MLG_ShotLine	dd	0	;   checked in cpuhand.asm

;LG_WrapLine	db	78	; for sentinel & shooting arcade
					;   75 for guntest4

MindlinkPos      dd	02800h  ; position value in Mindlink controller
                                        ; gets transferred bitwise (16 bits)
MindlinkPos1     dd	02800h  ; position for player 1
MindlinkPos2     dd	01000h  ; position for player 2
MindlinkShift    dd	1       ; which bit to transfer next
MindlinkAND      db	03fh    ; clear Mindlink-connected bit
MindlinkOR       db	080h    ; set data bit
MindlinkTEST     db	010h    ; test next out-bit signal

.code


;*
;* initialize the mouse
;*

MouseInit:
	call	_init_mouse
	cmp	eax,-1			; got mouse?
	jne	MIend			;   no
	mov	[MouseAvail],1		;   yes, mark it as available	  
	mov	[MJ_Cnt],0		; clear the repeat counter
        test    [_Mindlink],1           ; Mindlink in right port
        jz      MIend                   ;   no, manipulate different bits
        mov     [MindlinkAND],0f3h
        mov     [MindlinkOR],008h
        mov     [MindlinkTEST],001h
MIend:
	ret

;*
;* get absolute value of mouse coordinates
;*

GetAbs:	test	ecx,ecx
	jns	MJ_abs1
	neg	ecx
MJ_abs1:test	edx,edx
	jns	MJ_abs2
	neg	edx
MJ_abs2:ret


;*
;* see if horizontal or vertical motion is dominant
;*

TestDominant:
	mov	ecx,[MJ_Horiz]
	mov	edx,[MJ_Vert]
	call	GetAbs
	cmp	ecx,edx			; horiz > vert?
	ja	TD_horiz_bigger		;	 yes
	shr	edx,1			; vert bigger -- shrink it
	cmp	edx,ecx			; still bigger?
	jb	TD_Ret			;	 no
	mov	[MJ_Horiz],0		;   yes, vertical dominates, kill horizontal
	jmp	TD_Ret

TD_horiz_bigger:
	shr	ecx,1			; horiz bigger -- shrink it
	cmp	ecx,edx			; still bigger?
	jb	TD_Ret			;	 no
	mov	[MJ_Vert],0		;   yes, horizontal dominates, kill vertical
TD_Ret:	ret


;*
;* enforce a slight threshold if changing mouse direction
;* otherwise quadrun is very difficult to control
;*

TestThreshold:
	mov	ah,[_IOPortA]
	call	MJTestDirections
	cmp	ah,[MJ_Last_IOPortA]	; current direction match previous direction?
	jne	EnforceThreshold	;	  no, enforce threshold
	ret				;   yes, be sensitive

EnforceThreshold:
	mov	ecx,[MJ_Horiz]
	mov	edx,[MJ_Vert]
	call	GetAbs
	cmp	ecx,[_Threshold]	; horizontal displacement above threshold?
	jae	TT1			;   yes
	mov	[MJ_Horiz],0		;   no, kill it
TT1:	cmp	edx,[_Threshold]	; vertical displacement above threshold?
	jae	TT_Ret			;	  yes
	mov	[MJ_Vert],0		;   no, kill it
TT_Ret:	ret


;*
;* get mouse coordinates and do some processing on them
;*

GetMickeys:
	call	_get_mouse_movement
	mov	[MJ_Horiz],ecx
	mov	[MJ_Vert],edx
	call	TestDominant
	call	TestThreshold
	ret
	
;*
;* use mouse to emulate trackball -- that is, use it as a joystick
;*

MouseAsJoystick:
	test	[MouseAvail],1
	jz	MJret

	call	GetMickeys

	test	ecx,ecx			; any mickeys?
	jnz	MJDoTest		;   yes
	test	edx,edx
	jnz	MJDoTest		;   yes

	cmp	[MJ_Cnt],0		; shall we repeat?
	jz	MJTestButton		;   no

	dec	[MJ_Cnt]		;   yes
	mov	ah,[MJ_Last_IOPortA]
	mov	[_IOPortA],ah
	jmp	MJTestButton

MJDoTest:
	mov	[MJ_Cnt],1		; doing mouse read, reset counter
	mov	ah,[_IOPortA]
	call	MJTestDirections
	mov	[_IOPortA],ah
	mov	[MJ_Last_IOPortA],ah

MJTestButton:
	call	_get_mouse_button_status
	test	ebx,7
	jz	MJret
	mov	[InputLatch],0
MJret:
	ret


;*
;* see what direction of joystick movement mouse displacement is
;*

MJTestDirections:
	mov	ecx,[MJ_Horiz]
	test	ecx,ecx
	jns	MJright
	and	ah,0ffh-64
	jmp	MJvert

MJright:
	test	ecx,ecx				 
	jz	MJvert
	and	ah,0ffh-128

MJvert:
	mov	edx,[MJ_Vert]
	test	edx,edx
	jns	MJdown
	and	ah,0ffh-16
	ret

MJdown:
	test	edx,edx
	jz	MJret
	and	ah,0ffh-32
	ret

;*
;* use mouse to emulate paddle
;*

MouseAsPaddle:
	test	[MouseAvail],1
	jz	MPret

	call	_get_mouse_movement

        test    [_MouseBase],080H
        jnz     MouseAsDoublePaddle

	push	esi
	movzx	esi,[_MouseBase]
	mov	ebx,[ChargeTrigger0 + esi*4]
	test	[_MPdirection],1
	jz	MP0
	mov	ecx,edx
MP0:
	test	[_MPdirection],2
	jz	MP0a
	add	ebx,ecx
	jmp	MP0b
MP0a:
	sub	ebx,ecx
MP0b:
	cmp	ebx,TRIGMIN
	jg	MP1a
	mov	ebx,TRIGMIN
MP1a:
	cmp	ebx,TRIGMAX
	jna	MP1b
	mov	ebx,TRIGMAX
MP1b:
	mov	[ChargeTrigger0 + esi*4],ebx
	call	_get_mouse_button_status
	test	bx,7
	jz	MP1
	mov	dl,PaddleBits[esi]
	not	dl
	and	[_IOPortA],dl
MP1:
	pop	esi
MPret:
	ret

MouseAsDoublePaddle:
	push	esi
        movzx   esi,[_MouseBase]
        and     esi,3

	mov	ebx,[ChargeTrigger0 + esi*4]
        test    [_MPdirection],1
        jz      MDP0a
        add     ebx,edx
        jmp     MDP0b
MDP0a:
        sub     ebx,edx
MDP0b:
	cmp	ebx,TRIGMIN
        jg      MDP1a
	mov	ebx,TRIGMIN
MDP1a:
	cmp	ebx,TRIGMAX
        jna     MDP1b
	mov	ebx,TRIGMAX
MDP1b:
	mov	[ChargeTrigger0 + esi*4],ebx

        movzx   esi,[_MouseBase]
        shr     esi,2
        and     esi,3

	mov	ebx,[ChargeTrigger0 + esi*4]
        test    [_MPdirection],2
        jz      MDP1c
        add     ebx,ecx
        jmp     MDP1d
MDP1c:
        sub     ebx,ecx
MDP1d:
	cmp	ebx,TRIGMIN
        jg      MDP2a
	mov	ebx,TRIGMIN
MDP2a:
	cmp	ebx,TRIGMAX
        jna     MDP2b
	mov	ebx,TRIGMAX
MDP2b:
	mov	[ChargeTrigger0 + esi*4],ebx

	call	_get_mouse_button_status
        test    ebx,2
        jz      MDP3
        mov     dl,PaddleBits[esi]
	not	dl
	and	[_IOPortA],dl
MDP3:
        test    ebx,1
        jz      MDP4
        movzx   esi,[_MouseBase]
        and     esi,3
        mov     dl,PaddleBits[esi]
	not	dl
	and	[_IOPortA],dl
MDP4:
	pop	esi
	ret


MouseAsLightgun:
	call	_get_mouse_movement

	add	edx,[MLG_mouseY]

	cmp	edx,0f000h	;0f000h
	jb	MLG1
	mov	edx,0
MLG1:
        cmp     edx,480
	jb	MLG1a
        mov     edx,479
MLG1a:
	mov	[MLG_mouseY],edx

	shr	edx,1
	mov	[MLG_Ypos],edx

        add     edx,[_CFirst]
	add	edx,4
	sub	edx,[_LGadjust]
;	and	edx,0ffffh
	mov	[MLG_ShotLine],edx

	add	ecx,[MLG_mouseX]

	cmp	ecx,0f000h	;0f00h
	jb	MLG2
	mov	ecx,0
MLG2:
	cmp	ecx,637
	jb	MLG2a
	mov	ecx,636
MLG2a:
	mov	[MLG_mouseX],ecx

        shr     ecx,2
	mov	[MLG_Xpos],ecx
	mov	eax,ecx
	mov	cl,3
	div	cl
	add	al,23
	add	al,[_Lightgun]
	cmp	al,76
	jb	MLG3
	inc	[MLG_ShotLine]
MLG3:
	mov	[MLG_ShotCycle],al

	inc	[MLG_Colour]
	and	[MLG_Colour],007h
        mov     eax,[MLG_Ypos]
        imul    eax,160
        mov     edi,eax
	mov	eax,[_ScreenBuffer]
	add	edi,eax
        add     edi,[MLG_Xpos]
        mov     al,[MLG_Colour]

	mov	edx,edi
	sub	edx,160
	cmp	edx,[_ScreenBuffer]	; there are better ways...
	jbe	MLG_NoPaint

        gs_store [edi-160],al

MLG_NoPaint:
        gs_store [edi-1],al
        gs_store [edi+1],al
        gs_store [edi+160],al

	call	_get_mouse_button_status

	test	ebx,7
	jz	MLGret
	and	[_IOPortA],0efh

MLGret:
	ret


MouseAsMindlink:
	test	[MouseAvail],1
        jz      MMret

	call	_get_mouse_movement

        mov     ebx,[MindlinkPos1]
        test    [_MPdirection],1
        jz      MM1
        mov     ebx,[MindlinkPos2]
        add     ebx,01800h
MM1:
        and     ebx,03fffffffh
        shl     ecx,3
        add     ebx,ecx

        cmp     ebx,02800h
        ja      MM1a
        mov     ebx,02800h
MM1a:
        cmp     ebx,03900h
        jb      MM1b
        mov     ebx,03800h
MM1b:
        test    [_MPdirection],1
        jz      MM2
        sub     ebx,01800h
        mov     [MindlinkPos2],ebx
        jmp     MM3
MM2:
        mov     [MindlinkPos1],ebx
MM3:
        mov     [MindlinkPos],ebx
        mov     [MindlinkShift],1
        call    NextMindlinkBit
	call	_get_mouse_button_status
	test	bx,7
        jz      MMret
        or      [MindlinkPos],04000h    ; this bit starts a game
MMret:
        ret

; <-- from riot.asm

NextMindlinkBit:
        push    eax
        push    ebx
        mov     bl,[_IOPortA]
        and     bl,[MindlinkAND]        ; clear the Mindlink-connected bit
        mov     eax,[MindlinkShift]      ; find current bit
        test    [MindlinkPos],eax        ; is it set?
        jz      NMB1
        or      bl,[MindlinkOR]         ;   yes, set out-bit
NMB1:
        mov     [_IOPortA],bl
        pop     ebx
        pop     eax
        shl     [MindlinkShift],1       ; use a different bit on next call
        ret
