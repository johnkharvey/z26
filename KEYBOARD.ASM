; *****************************************************************************
;
;		      Control key emulation for	VCS
;
;     This function is called once per frame to	check the keyboard state.
;
; *****************************************************************************


; April 11, 1998 -- Modified key assignments to match V-Stick

;*
;* a keyboard macro
;*

ifpress macro   op1,op2			; if key #1 pressed drop bit
        local   M1
        test    [KeyTable+op1],128	; #2 of ah (128,64,32...1)
        jz      M1
        and     ah,255-op2		; drop a bit
M1:
        endm

;control key definitions

KeyEsc	=		1		; ESC (Quit to DOS)

KeyF1	=		03Bh		; F1  (Reset)
KeyF2	=		03Ch		; F2  (Select)
KeyF3	=		03Dh		; F3  (B/W)
KeyF4	=		03Eh		; F4  (Color)
KeyF5	=		03Fh		; F5  (P0 easy)
KeyF6	=		040h		; F6  (P0 hard)
KeyF7	=		041h		; F7  (P1 easy)
KeyF8	=		042h		; F8  (P1 hard)
KeyF9	=		043h		; F9  (unassigned)
KeyF10	=		044h		; F10 (unassigned)

KeyLeft	=		04Bh		; Left arrow
KeyRight =		04Dh		; Right	arrow
KeyUp =			048h		; Up arrow
KeyDown	=		050h		; Down arrow

KeyCtrl = 		01dh		; Ctrl

;KeyZ =			02Ch		; Z (P2	left)
;KeyX =			02Dh		; X (P2	right)
;KeyC =			02Eh		; C (P2	down)
;KeyF =			021h		; F (P2	Up)
;KeyG =			022h		; G (P2	Fire)

KeyS =			01fh		; S (P2 left)
KeyF =			021h		; F (P2 right)
KeyE =			012h		; E (P2 up)
KeyD =			020h		; D (P2 down)
KeyN =			031h		; N (P2 fire)

KeyP =			019H		; P (pause game)
KeyEnter =		01CH		; Enter (resume game)

KeyEquals =		00Dh		; = (do a screen dump)
KeyMinus=		00Ch		; unassigned


; define control keys

P1Left = 	KeyLeft
P1Right = 	KeyRight
P1Up = 		KeyUp
P1Down = 	KeyDown
P1Fire = 	KeyCtrl

P2Left = 	KeyS
P2Right = 	KeyF
P2Up = 		KeyE
P2Down = 	KeyD
P2Fire = 	KeyN

ResetKey =	KeyF1
SelectKey =	KeyF2
BWKey =		KeyF3
ColorKey = 	KeyF4
P0Easy=		KeyF5
P0Hard=		KeyF6
P1Easy=		KeyF7
P1Hard=		KeyF8


Controls:
	mov	ah,[IOPortB]		; turn on Select and Reset bits
	or	ah,03h
	test	[KeyTable+ResetKey],128
	jz	Ctrl1			; F1 pressed (Reset) - drop bit 0 (1)
	and	ah,0FEh
Ctrl1:	test	[KeyTable+SelectKey],128
	jz	Ctrl1a			; (Select) - drop bit 1 (2)
	and	ah,0FDh
Ctrl1a:	test	[KeyTable+P0Easy],128	; (p0 easy) - drop bit 6 (64)
	jz	Ctrl1b
	and	ah,0BFh
Ctrl1b:	test	[KeyTable+P0Hard],128	; (p0 hard) - set bit 6 (64)
	jz	Ctrl1c
	or	ah,64
Ctrl1c:	test	[KeyTable+P1Easy],128	; (p1 easy) -- drop bit 7 (128)
	jz	Ctrl1d
	and	ah,07fh
Ctrl1d:	test	[KeyTable+P1Hard],128	; (p1 hard) -- set bit 7 (128)
	jz	Ctrl2
	or	ah,128
Ctrl2:	test	[KeyTable+BWKey],128
	jz	Ctrl2a			; (Black and white) drop bit 3 (8)
	and	ah,0F7h
Ctrl2a:	test	[KeyTable+ColorKey],128
	jz	Ctrl2b			; (Color) set bit 3 (8)
	or	ah,08h
Ctrl2b: 
	mov	[IOPortB],ah

	mov	ah,0FFh			; now do the switches

	ifpress	P1Right,128
	ifpress	P1Left,64
	ifpress	P1Down,32
	ifpress	P1Up,16

	ifpress	P2Right,8
	ifpress	P2Left,4
	ifpress	P2Down,2
	ifpress	P2Up,1

	mov	[IOPortA],ah		; save the Port	A Switches

Ctrl5:	mov	[InputLatch],080h
	mov	[InputLatch+1],080h
CTLatching:

	test	[KeyTable+P1Fire],128
	jz	Ctrl3			; handle 'fire'	from p1
	mov	[InputLatch],0h
Ctrl3:	test	[KeyTable+P2Fire],128
	jz	Ctrl4			; handle 'fire'	from p2
	mov	[InputLatch+1],0h
Ctrl4:	test	[KeyTable+KeyP],128
	jz	Ctrl6
	mov	[GamePaused],1		; pause game
Ctrl6:	test	[KeyTable+KeyEnter],128
	jz	Ctrl7
	mov	[GamePaused],0		; resume game
Ctrl7:	test	[KeyTable+KeyEsc],128
	jz	CtrlPCX
	jmp	GoDOS			; ESC pressed -	exit

CtrlPCX:test	[KeyTable+KeyEquals],128
        jz      CtrlExit
        call    PCXWriteFile            ; = pressed - PCX screen dump

        ;kludge - make it think the key has already been released
        ; hope it doesn't make it write out PCX files constantly
        mov [KeyTable+KeyEquals],0

CtrlExit:
	test	[GamePaused],1		; game paused ?
	jnz	CtrlRet			;   yes, don't check joystick (sound off)	
	call	Joystick		; peaceful coesistance between
					; keyboard and joystick

	cmp	[_Joystick],2		; reversing joystick controls?
	jne	CtrlRet			;   no
	mov	al,[InputLatch]		;   yes
	mov	ah,[InputLatch+1]	; reverse buttons
	mov	[InputLatch+1],al
	mov	[InputLatch],ah
	mov	al,[IOPortA]		; reverse direction switches
	mov	bl,0fh
	and	bl,al			; isolate low nibble
	and	al,0f0h			; isolate hi nibble
	shr	al,4
	shl	bl,4			; swap nibbles
	add	al,bl			; combine
	mov	[IOPortA],al		
CtrlRet:
	ret
	

; *****************************************************************************
;
;	Alternative INT9 Handler,allows	us to check keyboard state.
;
; *****************************************************************************


;a rare free-range variable (must be in code segment)

datasegsave	dw	0		; get a	copy of	our data seg

SetNewInt9:
	push	es
	push	si
	push	bx
	push	ax
	mov	ax,ds
	mov	cs:datasegsave,ax	;save a	copy of	our dataseg
	cli
	mov	ax,3509h		; get old INT 9
	int	21h
	mov	si,OldInt9
	mov	[OldInt9],bx		; save offset
	mov	[OldInt9+2],es		; save segment
	push	ds
	push	cs
	pop	ds
	mov	ax,2509h		; set new INT 9
	mov	dx,offset NewInt9	; ds:dx	new interrupt vector
	int	21h
	pop	ds
	sti
	pop	ax
	pop	bx
	pop	si
	pop	es
	ret

SetOldInt9:
	push	ds
	cli
	mov	ax,2509h		; set new INT 9
	mov	dx,[OldInt9]		; load offset
	mov	ds,[OldInt9+2]		; load segment
	int	21h
	sti
	pop	ds
	ret


NewInt9:push	ax
	push	bx
	push	ds
	mov	ax,cs:datasegsave
	mov	ds,ax
	in	al,60h			; get the scan code

	mov	bl,al			; bx = offset into the table
	and	bl,07Fh
	xor	bh,bh
	and	al,080h			; isolate the on off bit
	xor	al,080h			; bit 7	0 if key pressed,reverse it
	mov	KeyTable[bx],al		; write	it into	the table

	mov	al,20h			; reset	something or other....
	out	20h,al
					; (bit 7 set if	pressed)
	pop	ds				        
	pop	bx
	pop	ax
	sti
	iret

