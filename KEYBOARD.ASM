; *****************************************************************************
;
;		      Control key emulation for	VCS
;
;     This function is called once per frame to	check the keyboard state.
;
; *****************************************************************************

Controls:
	mov	ah,[IOPortB]		; set all the switches on IOPort B
	or	ah,03Fh			; to on.
	test	[KeyTable+KeyF1],128
	jz	Ctrl1			; F1 pressed - drop bit	0
	and	ah,0FEh
Ctrl1:	test	[KeyTable+KeyF2],128
	jz	Ctrl2			; F2 pressed - drop bit	1
	and	ah,0FDh
Ctrl2:  
	mov	[IOPortB],ah

	mov	ah,0FFh			; now do the switches

	ifpress	KeyRight,128
	ifpress	KeyLeft,64
	ifpress	KeyDown,32
	ifpress	KeyUp,16

	ifpress	KeyX,8
	ifpress	KeyZ,4
	ifpress	KeyC,2
	ifpress	KeyF,1

	mov	[IOPortA],ah		; save the Port	A Switches

Ctrl5:	mov	[InputLatch],080h
	mov	[InputLatch+1],080h
CTLatching:

	test	[KeyTable+KeyRAlt],128
	jz	Ctrl3			; handle 'fire'	from p1
	mov	[InputLatch],0h
Ctrl3:	test	[KeyTable+KeyG],128
	jz	Ctrl4			; handle 'fire'	from p2
	mov	[InputLatch+1],0h
Ctrl4:
	test	[KeyTable+KeyEsc],128
	jz	CtrlExit
	jmp	GoDOS			; ESC pressed -	exit
CtrlExit:
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

