;*
;* z26 mouse code
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

.data
MouseAvail		db	0
MPdirection		db	0	; gets changed in keyboard.asm

MJ_Cnt			db	0
MJ_Last_IOPortA		db	0
MJ_Horiz		dw	0
MJ_Vert			dw	0

_Threshold		dw	2

MLG_mouseX		dw	320
MLG_mouseY		dw	200

MLG_Xpos		dw	0	; horizontal and vetical coordinates
MLG_Ypos		dw	0	;   for LG marker dispaly
MLG_Colour		db	0	; colour cycling the marker

MLG_ShotCycle		db	0	; cycle and line of hit - gets
MLG_ShotLine		dw	0	;   checked in cpuhand.asm

LG_WrapLine		db	78	; for sentinel & shooting arcade
					;   75 for guntest4

.code

;*
;* initialize the mouse
;*

MouseInit:
	mov	ax,0			; reset mouse driver
	int	33H
	cmp	ax,0ffffH		; got mouse?
	jne	MIend			;   no
	mov	[MouseAvail],1		;   yes, mark it as available	  
	mov	[MJ_Cnt],0		; clear the repeat counter
MIend:
	ret

;*
;* get absolute value of mouse coordinates
;*

GetAbs:	test	cx,cx
	jns	MJ_abs1
	neg	cx
MJ_abs1:test	dx,dx
	jns	MJ_abs2
	neg	dx
MJ_abs2:ret


;*
;* see if horizontal or vertical motion is dominant
;*

TestDominant:
	mov	cx,[MJ_Horiz]
	mov	dx,[MJ_Vert]
	call	GetAbs
	cmp	cx,dx			; horiz > vert?
	ja	TD_horiz_bigger		;	 yes
	shr	dx,1			; vert bigger -- shrink it
	cmp	dx,cx			; still bigger?
	jb	TD_Ret			;	 no
	mov	[MJ_Horiz],0		;   yes, vertical dominates, kill horizontal
	jmp	TD_Ret

TD_horiz_bigger:
	shr	cx,1			; horiz bigger -- shrink it
	cmp	cx,dx			; still bigger?
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
	mov	cx,[MJ_Horiz]
	mov	dx,[MJ_Vert]
	call	GetAbs
	cmp	cx,[_Threshold]		; horizontal displacement above threshold?
	jae	TT1			;   yes
	mov	[MJ_Horiz],0		;   no, kill it
TT1:	cmp	dx,[_Threshold]		; vertical displacement above threshold?
	jae	TT_Ret			;	  yes
	mov	[MJ_Vert],0		;   no, kill it
TT_Ret:	ret


;*
;* get mouse coordinates and do some processing on them
;*

GetMickeys:
	mov	ax,11
	int	33h
	mov	[MJ_Horiz],cx
	mov	[MJ_Vert],dx
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

	test	cx,cx			; any mickeys?
	jnz	MJDoTest		;   yes
	test	dx,dx
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
	mov	ax,03H			; read mouse position and button status
	int	33H
	test	bx,7
	jz	MJret
	mov	[InputLatch],0
MJret:
	ret


;*
;* see what direction of joystick movement mouse displacement is
;*

MJTestDirections:
	mov	cx,[MJ_Horiz]
	test	cx,cx
	jns	MJright
	and	ah,0ffh-64
	jmp	MJvert

MJright:
	test	cx,cx				 
	jz	MJvert
	and	ah,0ffh-128

MJvert:
	mov	dx,[MJ_Vert]
	test	dx,dx
	jns	MJdown
	and	ah,0ffh-16
	ret

MJdown:
	test	dx,dx
	jz	MJret
	and	ah,0ffh-32
	ret

;*
;* use mouse to emulate paddle
;*

MouseAsPaddle:
	test	[MouseAvail],1
	jz	MPret

	mov	ax,0bH			; # of mickeys since last call
	int	33H

	push	esi
	movzx	esi,[_MouseBase]
	mov	ebx,[ChargeTrigger0 + esi*4]
	test	[MPdirection],1
	jz	MP0
	mov	cx,dx
MP0:
	test	[MPdirection],2
	jz	MP0a
	add	bx,cx
	jmp	MP0b
MP0a:
	sub	bx,cx
MP0b:
	cmp	bx,TRIGMIN
	jg	MP1a
	mov	bx,TRIGMIN
MP1a:
	cmp	bx ,TRIGMAX
	jna	MP1b
	mov	bx,TRIGMAX
MP1b:
	mov	[ChargeTrigger0 + esi*4],ebx
	mov	ax,03H
	int	33H
	test	bx,7
	jz	MP1
	mov	dl,PaddleBits[esi]
	not	dl
	and	[_IOPortA],dl
MP1:
	pop	esi
MPret:
	ret

MouseAsLightgun:
	mov	ax,0bH
	int	33H

	add	dx,[MLG_mouseY]

	cmp	dx,0f000h
	jb	MLG1
	mov	dx,0
MLG1:
	cmp	dx,480
	jb	MLG1a
	mov	dx,479
MLG1a:
	mov	[MLG_mouseY],dx

	shr	dx,1
	add	dx,[_CFirst]
	mov	[MLG_Ypos],dx	        

	add	dx,4
	sub	dx,[_LGadjust]
	mov	[MLG_ShotLine],dx

	add	cx,[MLG_mouseX]

	cmp	cx,0f000h
	jb	MLG2
	mov	cx,0
MLG2:
	cmp	cx,637
	jb	MLG2a
	mov	cx,636
MLG2a:
	mov	[MLG_mouseX],cx

	shr	cx,1
	and	cx,0fffeh
	mov	[MLG_Xpos],cx
	shr	cx,1
	mov	ax,cx
	mov	cl,3
	div	cl
	add	al,23
	add	al,[_Lightgun]
	cmp	al,76
	jb	MLG3
	inc	[MLG_ShotLine]
MLG3:
	mov	[MLG_ShotCycle],al

	mov	ax,03H
	int	33H

	test	bx,7
	jz	MLGret
	and	[_IOPortA],0efh

MLGret:
	ret

; <--- from tialine.asm

ShowLightgun0:
	inc	[MLG_Colour]
	and	[MLG_Colour],007h

ShowLightgun2:
	push	di

	mov	di,[DisplayPointer]
	sub	di,320
	add	di,[MLG_Xpos]
	mov	al,[MLG_Colour]

	mov	gs:[di],al
	mov	gs:[di+1],al

	pop	di
SLGret:
	ret



ShowLightgun1:
	push	di

	mov	di,[DisplayPointer]
	sub	di,320
	add	di,[MLG_Xpos]
	mov	al,[MLG_Colour]

	mov	gs:[di-2],al
	mov	gs:[di-1],al
	mov	gs:[di+2],al
	mov	gs:[di+3],al

	pop	di
	ret
