;*
;* vertical synchronization code
;*

; Mar 18, 1998  (0.96) added timeout code

WaitForDisplayEnable macro
local	enwait

	xor	bx,bx
enwait:	in	al,dx			; wait for display enable
	inc	bx
	jz	vsync_timeout
	test	al,1
	jnz	enwait
	endm

WaitForDisplayDisable macro
local	diswait

	xor	bx,bx
diswait:in	al,dx			; wait for display disable
	inc	bx
	jz	vsync_timeout
	test	al,1
	jz	diswait
	endm

LoopUntilDisplayEnable macro
local	actwait

	xor	bx,bx
actwait:in	al,dx			; loop until display enable becomes active
	inc	bx
	jz	vsync_timeout
	test	al,1
	loopnz	actwait
	endm

;*
;* if any of the above loops times out, default to old video mode
;*

vsync_timeout:
	mov	[NoRetrace],1
	pop	es
	ret	



EXTRN _Fillbuffer:near

segVDDA		equ	040h		;bios video display data area segment
addr6845	equ	063h		;CRTC i/o address

ALIGN_ENTRY

VSyncInit:
	push	es
	mov	ax,segVDDA
	mov	es,ax
	mov	dx,es:[addr6845]
	add	dx,6			; status register i/o address

vswait:	in	al,dx			; wait for vertical retrace
	test	al,8
	jz	vswait

	mov	cx,0ffffh		; init loop counter

	WaitForDisplayEnable
	cli
	WaitForDisplayDisable
	LoopUntilDisplayEnable		; time horizontal retrace
	sti

	neg	cx			; cx now has # of loops in horizontal retrace
	imul	cx,2			; multiply by 2 for safety
	mov	[NDILoops],cx		; save for NDI wait routine

	pop	es
	ret


ALIGN_ENTRY

VSync:
	cmp	[NoRetrace],1		; -r1
	jz	OldVSync
	cmp	[NoRetrace],0ffh	; -r no param
	jz	VSRet
	push	es
	mov	ax,segVDDA
	mov	es,ax
	mov	dx,es:[addr6845]
	add	dx,6			; status register i/o address

	WaitForDisplayEnable

VSLoop:	pusha
	call	_Fillbuffer		; fill sound buffer
	popa

	mov	cx,[NDILoops]
	
	WaitForDisplayDisable
	LoopUntilDisplayEnable

	jz	VSLoop			; jump if display enable detected

	pop	es
	ret

OldVSync:
	mov	dx,03dah		; wait for vertical retrace
WaitForVSync:
	in	al,dx
	test	al,8
	jnz	VSRet
	call	_Fillbuffer
	jmp	WaitForVSync
VSRet:
	ret


.CEND
.DATASEGMENT

NDILoops	dw	0		; holds length of NDI * 2

.DEND
.CODESEGMENT