;*
;* z26 joystick code
;*

;*
;* call this routine at start of game
;* we assume joystick is centered at start
;*

JoyCenter:
	pushad
	cmp	[_Joystick],0		; doing joystick
	jz	NoJoy			;   no
	call	JoyRead

	test	si,si			; reality check
	jz	NoJoy
	test	di,di
	jz	NoJoy

	mov	bx,16			; read center position 16 times

JoyInitLoop:				; get a good reading of center
	call	JoyRead			; call JoyRead Direct
	add	[JoyHorizontalCenter],si
	add	[JoyVerticalCenter],di
	dec	bx
	jnz	JoyInitLoop

	shr	[JoyHorizontalCenter],4	; divide by 16
	shr	[JoyVerticalCenter],4	; we have the average values

	mov	ax,[JoyHorizontalCenter]
	shr	ax,1
	mov	[JoyHorizontalMinimum],ax ; min value = 1/2 of center
	add	ax,[JoyHorizontalCenter]
	mov	[JoyHorizontalMaximum],ax ; max value = 3/2 of center

	mov	ax,[JoyVerticalCenter]
	shr	ax,1
	mov	[JoyVerticalMinimum],ax
	add	ax,[JoyVerticalCenter]
	mov	[JoyVerticalMaximum],ax

	cmp	ax,[JoyHorizontalMaximum] ; which is bigger, horiz or vert ?
	ja	JoyVertBigger		;     vert is bigger
	mov	ax,[JoyHorizontalMaximum]
JoyVertBigger:
	mov	[JoyMaximum],ax

	mov	si,[JoyHorizontalCenter] ; use the average center value
	mov	di,[JoyVerticalCenter]

	call	JoyStabilizeInit	; initialize stabilization routine

	mov	[JoyLeft],si		; center position of stick
	mov	[JoyRight],si
	mov	[JoyUp],di
	mov	[JoyDown],di

;	shr	si,3			; compute guard band
;	mov	ax,si			; 3/8 * center value
;	add	si,ax
;	add	si,ax

;	shr	di,3
;	mov	ax,di
;	add	di,ax
;	add	di,ax

	imul	si,3			; compute guard band
	shr	si,3			; 3/8 * center value

	imul	di,3
	shr	di,3

	test	si,si			; reality check
	jz	NoJoy
	test	di,di
	jz	NoJoy

	sub	[JoyLeft],si		; save threshold values
	add	[JoyRight],si
	sub	[JoyUp],di
	add	[JoyDown],di
	popad
	ret

NoJoy:	mov	[_Joystick],0		; turn off the joystick
	popad
	ret


;*
;* read the joystick and give the emulator a clue
;* call after calling keyboard routine 
;* (which presets IOPortA and InputLatch)
;*


Joystick:
	pushad
	cmp	[_Joystick],0
	jz	NoJoy
	call	_Fillbuffer		; fill sound buffer
	call	FastJoyRead
	call	JoyStabilize

	mov	ah,[IOPortA]
	cmp	[JoyLeft],si
	ja	AtariLeft

JoyTestRight:
	cmp	[JoyRight],si
	jb	AtariRight

JoyTestUp:
	cmp	[JoyUp],di
	ja	AtariUp

JoyTestDown:
	cmp	[JoyDown],di
	jb	AtariDown

JoyTestButtons:
	mov	[IOPortA],ah
	mov	dx,0201h		; joystick port

; Why do we do this three times ?
; A fair question.
; Apparently once is not enough.
; If you only do it once, the emulator crashes sometimes.
; Twice is probably enough.
; But three seems to be enough too.

	in	al,dx
	test	al,010h			; button one pressed ?
	jnz	JoyDone			;   no

	in	al,dx
	test	al,010h			; button one pressed ?
	jnz	JoyDone			;   no

	in	al,dx
	test	al,010h			; button one pressed ?
	jnz	JoyDone			;   no

	mov	[InputLatch],0

JoyDone:	
	call	_Fillbuffer
	popad
	ret


AtariLeft:				; stick is to the left
	and	ah,0ffh-64
	jmp	JoyTestUp		; can't be to the right

AtariRight:				; stick is to the right
	and	ah,0ffh-128
	jmp	JoyTestUp

AtariUp:				; stick is up
	and	ah,0ffh-16
	jmp	JoyTestButtons		; can't be to the bottom

AtariDown:				; stick is down
	and	ah,0ffh-32
	jmp	JoyTestButtons



;*
;* do the actual joystick read
;*
;* adapted from The Art of Assembly Language Programming
;*              by Randall Hyde
;*
;* si gets horizontal reading
;* di gets vertical reading
;*

JoyRead:
	mov	cx,1000h	;Max times through loop
	xor	si,si		;We’ll put readings in SI and
	xor	di,di		; di.
	xor	ax,ax		;Set AH to zero.
	mov	dx,201h		;Point at joystick port.
	out	dx,al		;Trigger the timer chip.

JoyLoop:
	in	al,dx		;Read joystick port.
	and	al,11b		;Strip unwanted bits.
	jz	JoyReadDone
	shr	ax,1		;Put pot 0 value into carry.
	adc	si,0		;Bump pot 0 value if still active.
	add	di,ax		;Bump pot 1 value if pot 1 active.
	loop	JoyLoop		;Repeat while high.
	and	si,0FFFh	;If time-out, force the register(s)
	and	di,0FFFh	; containing 1000h to zero.
JoyReadDone:
	ret

;*
;* fast version of above
;*

FastJoyRead:
	mov	cx,[JoyMaximum]	;Max times through loop
	xor	si,si		;We’ll put readings in SI and
	xor	di,di		; di.
	xor	ax,ax		;Set AH to zero.
	mov	dx,201h		;Point at joystick port.
	out	dx,al		;Trigger the timer chip.

FastJoyLoop:
	in	al,dx		;Read joystick port.
	and	al,11b		;Strip unwanted bits.
	jz	FastJoyReadDone
	shr	ax,1		;Put pot 0 value into carry.
	adc	si,0		;Bump pot 0 value if still active.
	add	di,ax		;Bump pot 1 value if pot 1 active.
	loop	FastJoyLoop	;Repeat while high.
	cmp	si,[JoyHorizontalMinimum]
	ja	FastJoyVert
	mov	si,[JoyHorizontalMinimum]
FastJoyVert:
	cmp	di,[JoyVerticalMinimum]
	ja	FastJoyReadDone
	mov	di,[JoyVerticalMinimum]
FastJoyReadDone:
	ret


;*
;* stabilize the joystick reading
;*

JoyStabilize:

	mov	ax,[JH1]	; do a moving average of 3 values
	add	ax,[JH2]
	shr	ax,1
	mov	[JH1],ax
	add	ax,[JH3]
	shr	ax,1
	mov	[JH2],ax

	add	ax,si
	shr	ax,1
	mov	[JH3],ax

	mov	ax,[JV1]
	add	ax,[JV2]
	shr	ax,1
	mov	[JV1],ax
	add	ax,[JV3]
	shr	ax,1
	mov	[JV2],ax

	add	ax,di
	shr	ax,1
	mov	[JV3],ax

	mov	si,[JH2]	; then a straight average of the last two
	add	si,[JH3]
	shr	si,1

	mov	di,[JV2]
	add	di,[JV3]
	shr	di,1

	ret


JoyStabilizeInit:
	mov	[JH1],si
	mov	[JH2],si
	mov	[JH3],si

	mov	[JV1],di
	mov	[JV2],di
	mov	[JV3],di

	ret


.CEND
.DATASEGMENT

JH1			dw	0
JH2			dw	0
JH3			dw	0

JV1			dw	0
JV2			dw	0
JV3			dw	0

JoyHorizontalCenter	dw	0
JoyVerticalCenter	dw	0

JoyHorizontalMinimum	dw	0
JoyHorizontalMaximum	dw	0
JoyVerticalMinimum	dw	0
JoyVerticalMaximum	dw	0

JoyMaximum		dw	0

JoyLeft			dw	0
JoyRight		dw	0
JoyUp			dw	0
JoyDown			dw	0


.DEND
.CODESEGMENT