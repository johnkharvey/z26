; *****************************************************************************
;
;		      Control key emulation for	VCS
;
;     This function is called once per frame to	check the keyboard state.
;
; *****************************************************************************

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

.data

; *** keyboard.asm ***

OldInt9		dw	0,0	; old vector for int9

CtrlSkipFlag	db	0	; skip this control key test

; *EST* data
DCCLeft         db      0       ; driving controller counter left
DCCRight        db      0       ; driving controller counter right

DCTable         db      00Fh,00Dh,0,00Eh ; 2bit quadrature counter

.code

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
KeyF11	=		057h		; F11 (trace on)
KeyF12	=		058h		; F12 (trace off)

Key0 =			00bh
Key1 =			002h
Key2 =			003h
Key3 =			004h
Key4 =			005h
Key5 =			006h
Key6 =			007h
Key7 =			008h
Key8 =			009h
Key9 =			00ah

KeyQ =                  010h
KeyW =                  011h
KeyA =                  01Eh
KeyZ =                  02Ch
KeyX =                  02Dh
KeyC =                  02Eh
KeyU =                  016h
KeyI =                  017h
KeyO =                  018h
KeyJ =                  024h
KeyK =                  025h
KeyL =                  026h
KeyM =                  032h
KeyComma =              033h            ; ,
KeyDot =                034h            ; .

KeyLeft	=		04Bh		; Left arrow
KeyRight =		04Dh		; Right	arrow
KeyUp =			048h		; Up arrow
KeyDown	=		050h		; Down arrow

KeyCtrl = 		01dh		; Ctrl
KeyRShift =		036h
KeySlash =              035h            ; /

KeyLShift =		02ah
KeyAlt =                038h

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
KeyB =                  030h            ; B (P2 booster grip - trigger)
KeyV =                  02Fh            ; V (P2 booster grip - booster)

KeyP =			019H		; P (pause game)
KeyEnter =		01CH		; Enter (resume game)

KeyEquals =		00Dh		; = (do a screen dump)
KeyMinus=		00Ch		; unassigned

KeyPgUp=		0049h		; scroll up
KeyPgDn=		0051h		; scroll down
KeyHome=		0047h		; back to default screen position


; define control keys

P1Left = 	KeyLeft
P1Right = 	KeyRight
P1Up = 		KeyUp
P1Down = 	KeyDown
P1Fire = 	KeyCtrl
P1TriggerBG =   KeySlash
P1BoosterBG =   KeyRShift

P2Left = 	KeyS
P2Right = 	KeyF
P2Up = 		KeyE
P2Down = 	KeyD
P2Fire = 	KeyN
P2TriggerBG =   KeyB
P2BoosterBG =   KeyV

P1Pad1 =        Key7
P1Pad2 =        Key8
P1Pad3 =        Key9
P1Pad4 =        KeyU
P1Pad5 =        KeyI
P1Pad6 =        KeyO
P1Pad7 =        KeyJ
P1Pad8 =        KeyK
P1Pad9 =        KeyL
P1PadStar =     KeyM                    ; *
P1Pad0 =        KeyComma
P1PadPound =    KeyDot                  ; #

P2Pad1 =        Key1
P2Pad2 =        Key2
P2Pad3 =        Key3
P2Pad4 =        KeyQ
P2Pad5 =        KeyW
P2Pad6 =        KeyE
P2Pad7 =        KeyA
P2Pad8 =        KeyS
P2Pad9 =        KeyD
P2PadStar =     KeyZ                    ; *
P2Pad0 =        KeyX
P2PadPound =    KeyC                    ; #

ResetKey =	KeyF1
SelectKey =	KeyF2
BWKey =		KeyF3
ColorKey = 	KeyF4
P0Easy=		KeyF5
P0Hard=		KeyF6
P1Easy=		KeyF7
P1Hard=		KeyF8


Controls proc near

	mov	ah,[_IOPortB]		; turn on Select and Reset bits
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
	mov	[_IOPortB],ah

;        mov     ah,0FFh                 ; now do the switches
        mov     ah,[_IOPortA]
StickL:
        test    [_KeyPad],1             ; no stick if keypad left *EST*
        jnz     StickR
        or      ah,0F0h
	ifpress	P1Right,128
	ifpress	P1Left,64
	ifpress	P1Down,32
	ifpress	P1Up,16
        mov     [InputLatch],080h
        mov     [DumpPorts],0h        
        mov     [DumpPorts+1],0h

        test	[KeyTable+P1Fire],128
	jz	Ctrl3			; handle 'fire'	from p1
	mov	[InputLatch],0h
Ctrl3:
        test    [KeyTable+P1TriggerBG],128
        jz      Ctrl3a                  ; check for booster grip *EST*
        mov     [DumpPorts],080h
Ctrl3a: test    [KeyTable+P1BoosterBG],128
        jz      StickR                  ; check for booster grip *EST*
        mov     [DumpPorts+1],080h

StickR:
        test    [_KeyPad],2             ; no stick if keypad right *EST*
        jnz     StickEnd
        or      ah,00Fh
	ifpress	P2Right,8
	ifpress	P2Left,4
	ifpress	P2Down,2
	ifpress	P2Up,1
	mov	[InputLatch+1],080h
        mov     [DumpPorts+2],0h
        mov     [DumpPorts+3],0h

        test    [KeyTable+P2Fire],128
        jz      Ctrl3b                  ; handle 'fire' from p2
	mov	[InputLatch+1],0h
Ctrl3b: test    [KeyTable+P2TriggerBG],128
        jz      Ctrl3c                  ; check for booster grip *EST*
        mov     [DumpPorts+2],080h
Ctrl3c: test    [KeyTable+P2BoosterBG],128
        jz      StickEnd                ; check for booster grip *EST*
        mov     [DumpPorts+3],080h

StickEnd:
	mov	[_IOPortA],ah		; save the Port	A Switches

;CTLNoJoy:
Ctrl4:	test	[KeyTable+KeyP],128
	jz	Ctrl6
	mov	[GamePaused],1		; pause game
Ctrl6:	test	[KeyTable+KeyEnter],128
	jz	Ctrl7
	mov	[GamePaused],0		; resume game

;*
;* test for escape key
;*


Ctrl7:	test	[KeyTable+KeyEsc],128
;	jz	Ctrl8
;	jmp	GoDOS			; ESC pressed -	exit

Ctrl8:	test	[KeyTable+KeyPgUp],128	; scroll up ?
	jz	Ctrl9			;   no
	cmp	[_CFirst],0		;   yes, scrolling disabled ?
	je	CtrlPCX			;          yes, skip scrolling
	cmp	[CtrlSkipFlag],0	; skipping this test ?
	jne	CtrlPCX			;   yes
	mov	[CtrlSkipFlag],4	; no set skip count
	cmp	[_CFirst],1		; already at top ?
	je	CtrlPCX			;   yes
	dec	[_CFirst]		;   no, scroll up


Ctrl9:	test	[KeyTable+KeyPgDn],128	; scroll down ?
	jz	CtrlPCX			;   no
	cmp	[_CFirst],0		;   yes, scrolling disabled ?
	je	CtrlPCX			;          yes, skip scrolling
	cmp	[CtrlSkipFlag],0	; skipping this test ?
	jne	CtrlPCX			;   yes
	mov	[CtrlSkipFlag],4	; no set skip count
	cmp	[_CFirst],99		; already at bottom ?
	jae	CtrlPCX			;   yes
	inc	[_CFirst]		;   no, scroll down


CtrlPCX:cmp	[CtrlSkipFlag],0	; skip flag already zero ?
	jz	CtrlPCX1		;   yes
	dec	[CtrlSkipFlag]		;   no, decrement it
CtrlPCX1:
	test	[KeyTable+KeyHome],128	; home key pressed ?
	jz	CtrlPCX3		;   no
	cmp	[OldCFirst],0		; is OldCFirst zero ?
	jz	CtrlPCX3		;   yes, don't home the display
	mov	dx,[OldCFirst]
	mov	[_CFirst],dx
CtrlPCX3:
	test	[KeyTable+KeyEquals],128
        jz      CtrlVid
        call    PCXWriteFile            ; = pressed - PCX screen dump

        ;kludge - make it think the key has already been released
        ; hope it doesn't make it write out PCX files constantly

        mov [KeyTable+KeyEquals],0


CtrlVid:
        test    [KeyTable+KeyAlt],128   ; change video mode only when Alt
        jz      CtrlVidDone             ;   key is pressed *EST*

CtrlVid0:
	test	[KeyTable+Key0],128	; video mode 0 ?
	jz	CtrlVid1
	mov	[_VideoMode],0
	call	TIAGraphicMode
	mov	[KeyTable+Key0],0

CtrlVid1:
	test	[KeyTable+Key1],128	; video mode 1 ?
	jz	CtrlVid2
	mov	[_VideoMode],1
	call	TIAGraphicMode
	mov	[KeyTable+Key1],0

CtrlVid2:
	test	[KeyTable+Key2],128	; video mode 2 ?
	jz	CtrlVid3
	mov	[_VideoMode],2
	call	TIAGraphicMode
	mov	[KeyTable+Key2],0

CtrlVid3:
	test	[KeyTable+Key3],128	; video mode 3 ?
	jz	CtrlVid4
	mov	[_VideoMode],3
	call	TIAGraphicMode
	mov	[KeyTable+Key3],0

CtrlVid4:
	test	[KeyTable+Key4],128	; video mode 4 ?
	jz	CtrlVid5
	mov	[_VideoMode],4
	call	TIAGraphicMode
	mov	[KeyTable+Key4],0

CtrlVid5:
	test	[KeyTable+Key5],128	; video mode 5 ?
	jz	CtrlVid6
	mov	[_VideoMode],5
	call	TIAGraphicMode
	mov	[KeyTable+Key5],0

CtrlVid6:
	test	[KeyTable+Key6],128	; video mode 6 ?
	jz	CtrlVid7
	mov	[_VideoMode],6
	call	TIAGraphicMode
	mov	[KeyTable+Key6],0

CtrlVid7:
	test	[KeyTable+Key7],128	; video mode 7 ?
	jz	CtrlVid8
	mov	[_VideoMode],7
	call	TIAGraphicMode
	mov	[KeyTable+Key7],0

CtrlVid8:
	test	[KeyTable+Key8],128	; video mode 8 ?
	jz	CtrlVid9
	mov	[_VideoMode],8
	call	TIAGraphicMode
	mov	[KeyTable+Key8],0

CtrlVid9:
	test	[KeyTable+Key9],128	; video mode 8 ?
	jz	CtrlVidDone
	mov	[_VideoMode],9
	call	TIAGraphicMode
	mov	[KeyTable+Key8],0

CtrlVidDone:
	test	[KeyTable+KeyF11],128	; turn on trace?
	jz	CtrlTraceOff		;   no
	cmp	[_TraceEnabled],0	; trace enabled?
	jz	CtrlTraceDone		;   no
	mov	al,[_OldTraceCount]
	mov	[_TraceCount],al

	jmp	CtrlTraceDone

CtrlTraceOff:
	test	[KeyTable+KeyF12],128	; turn off trace?
	jz	CtrlTraceDone		;   no
	cmp	[_TraceEnabled],0	; trace enabled?
	jz	CtrlTraceDone		;   no
	mov	[_TraceCount],0

	jmp	CtrlTraceDone


CtrlTraceDone:

	

CtrlExit:
	test	[GamePaused],1		; game paused ?
	jnz	CtrlPaddles		;   yes, don't check joystick (sound off)	
	call	Joystick		; peaceful coesistance between
					; keyboard and joystick

DrivingController:
        test    [_Driving],1            ; *EST*
        jz      DCEnd

        mov     bh,0
        mov     bl,[DCCLeft]
DC1L:
        test    [_IOPortA],64
        jnz     DC1R
        dec     bl
DC1R:
        test    [_IOPortA],128
        jnz     DC1Turn
        inc     bl
DC1Turn:
        and     bl,0Fh
        mov     [DCCLeft],bl
        shr     bl,2
        mov     ah,[DCTable + bx]
        shl     ah,4

        mov     bl,[DCCRight]
DC2L:
        test    [_IOPortA],4
        jnz     DC2R
        dec     bl
DC2R:
        test    [_IOPortA],8
        jnz     DC2Turn
        inc     bl
DC2Turn:
        and     bl,00Fh
        mov     [DCCRight],bl
        shr     bl,2
        or      ah,[DCTable + bx]
        mov     [_IOPortA],ah
DCEnd:
	cmp	[_Joystick],2		; reversing joystick controls?
	jne	CtrlPaddles		;   no
	mov	al,[InputLatch]		;   yes
	mov	ah,[InputLatch+1]	; reverse buttons
	mov	[InputLatch+1],al
	mov	[InputLatch],ah
        mov     al,[DumpPorts]          ; *EST*
        mov     ah,[DumpPorts+2]        ; reverse booster grip triggers
        mov     [DumpPorts+2],al
        mov     [DumpPorts],ah
        mov     al,[DumpPorts+1]        ; *EST*
        mov     ah,[DumpPorts+3]        ; reverse booster grip boosters
        mov     [DumpPorts+3],al
        mov     [DumpPorts+1],ah
	mov	al,[_IOPortA]		; reverse direction switches
	mov	bl,0fh
	and	bl,al			; isolate low nibble
	and	al,0f0h			; isolate hi nibble
	shr	al,4
	shl	bl,4			; swap nibbles
	add	al,bl			; combine
	mov	[_IOPortA],al

CtrlPaddles:
	cmp	[_KeyBase],0ffh		; emulating a paddle with the keyboard ?
	je	CtrlRet			;   no

CtrlPad0:
	test	[_IOPortA],080h		; P1 right ?
	jnz	CtrlPad1		;   no
	call	PaddleTriggerDown0	;   yes
CtrlPad1:
	test	[_IOPortA],040h		; P1 left ?
	jnz	CtrlPad2		;   no
	call	PaddleTriggerUp0	;   yes
CtrlPad2:
	test	[_IOPortA],020h		; P1 down ?
	jnz	CtrlPad3		;   no
	call	PaddleTriggerUp0	;   yes
CtrlPad3:
	test	[_IOPortA],010h		; P1 up ?
	jnz	CtrlPad4		;   no
	call	PaddleTriggerDown0	;   yes
CtrlPad4:

	mov	[_IOPortA],0ffh		
	cmp	[InputLatch],0		; P1 fire pressed ?
	jne	CtrlPad9		;   no
	call	PaddleButton0
	mov	[InputLatch],080h
CtrlPad9:

CtrlRet:
        ret

Controls endp

; *****************************************************************************
;
;  this function handles the keypad controllers
;  it gets called every time something gets written to SWCHA
;  *EST*
;
; *****************************************************************************

HandleKeyPad:
CheckPad1:
        test    [_KeyPad],1
        jz      CheckPad2
        mov     [InputLatch],080h
        mov     [DumpPorts],080h
        mov     [DumpPorts+1],080h
CP1Row10:
        test    [_IOPortA],128
        jnz     CP1Row20
CP1Row11:
        test    [KeyTable+P1PadPound],128
        jz      CP1Row12
        mov     [InputLatch],0h
CP1Row12:
        test    [KeyTable+P1Pad0],128
        jz      CP1Row13
        mov     [DumpPorts+1],0h
CP1Row13:
        test    [KeyTable+P1PadStar],128
        jz      CP1Row20
        mov     [DumpPorts],0h
CP1Row20:
        test    [_IOPortA],64 
        jnz     CP1Row30
CP1Row21:
        test    [KeyTable+P1Pad9],128
        jz      CP1Row22
        mov     [InputLatch],0h
CP1Row22:
        test    [KeyTable+P1Pad8],128
        jz      CP1Row23
        mov     [DumpPorts+1],0h
CP1Row23:
        test    [KeyTable+P1Pad7],128
        jz      CP1Row30
        mov     [DumpPorts],0h
CP1Row30:
        test    [_IOPortA],32 
        jnz     CP1Row40
CP1Row31:
        test    [KeyTable+P1Pad6],128
        jz      CP1Row32
        mov     [InputLatch],0h
CP1Row32:
        test    [KeyTable+P1Pad5],128
        jz      CP1Row33
        mov     [DumpPorts+1],0h
CP1Row33:
        test    [KeyTable+P1Pad4],128
        jz      CP1Row40
        mov     [DumpPorts],0h
CP1Row40:
        test    [_IOPortA],16 
        jnz     CheckPad2
CP1Row41:
        test    [KeyTable+P1Pad3],128
        jz      CP1Row42
        mov     [InputLatch],0h
CP1Row42:
        test    [KeyTable+P1Pad2],128
        jz      CP1Row43
        mov     [DumpPorts+1],0h
CP1Row43:
        test    [KeyTable+P1Pad1],128
        jz      CheckPad2
        mov     [DumpPorts],0h

CheckPad2:
        test    [_KeyPad],2
        jz      HKPEnd
	mov	[InputLatch+1],080h
        mov     [DumpPorts+2],080h
        mov     [DumpPorts+3],080h
CP2Row10:
        test    [_IOPortA],8
        jnz     CP2Row20
CP2Row11:
        test    [KeyTable+P2PadPound],128
        jz      CP2Row12
        mov     [InputLatch+1],0h
CP2Row12:
        test    [KeyTable+P2Pad0],128
        jz      CP2Row13
        mov     [DumpPorts+3],0h
CP2Row13:
        test    [KeyTable+P2PadStar],128
        jz      CP2Row20
        mov     [DumpPorts+2],0h
CP2Row20:
        test    [_IOPortA],4 
        jnz     CP2Row30
CP2Row21:
        test    [KeyTable+P2Pad9],128
        jz      CP2Row22
        mov     [InputLatch+1],0h
CP2Row22:
        test    [KeyTable+P2Pad8],128
        jz      CP2Row23
        mov     [DumpPorts+3],0h
CP2Row23:
        test    [KeyTable+P2Pad7],128
        jz      CP2Row30
        mov     [DumpPorts+2],0h
CP2Row30:
        test    [_IOPortA],2 
        jnz     CP2Row40
CP2Row31:
        test    [KeyTable+P2Pad6],128
        jz      CP2Row32
        mov     [InputLatch+1],0h
CP2Row32:
        test    [KeyTable+P2Pad5],128
        jz      CP2Row33
        mov     [DumpPorts+3],0h
CP2Row33:
        test    [KeyTable+P2Pad4],128
        jz      CP2Row40
        mov     [DumpPorts+2],0h
CP2Row40:
        test    [_IOPortA],1 
        jnz     HKPEnd   
CP2Row41:
        test    [KeyTable+P2Pad3],128
        jz      CP2Row42
        mov     [InputLatch+1],0h
CP2Row42:
        test    [KeyTable+P2Pad2],128
        jz      CP2Row43
        mov     [DumpPorts+3],0h
CP2Row43:
        test    [KeyTable+P2Pad1],128
        jz      HKPEnd   
        mov     [DumpPorts+2],0h

HKPEnd:
        ret

; *****************************************************************************
;
;	Alternative INT9 Handler,allows	us to check keyboard state.
;
; *****************************************************************************


;a rare free-range variable (must be in code segment)

datasegsave	dw	0		; get a	copy of	our data seg

SetNewInt9 proc near

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

SetNewInt9 endp

SetOldInt9 proc near

	push	ds
	cli
	mov	ax,2509h		; set new INT 9
	mov	dx,[OldInt9]		; load offset
	mov	ds,[OldInt9+2]		; load segment
	int	21h
	sti
	pop	ds
	ret

SetOldInt9 endp


NewInt9 proc near

	push	ax
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

NewInt9 endp


