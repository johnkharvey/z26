;*
;* modex.asm -- z26 Mode-X support
;*

; mode setting code adapted from Michael Abrash's
; Graphics Programming Black Book, listing 47.1
; which itself is based on public-domain code by John Bridges


SC_INDEX =	03c4h		; sequence controller index
CRTC_INDEX =	03d4h		; CRT controller index
MISC_OUTPUT =	03c2h		; miscellaneous output register
SCREEN_SEG =	0a000h		; segment of display memory in mode X


.CEND
.DATASEGMENT

ModeXBufferSeg		dw	0	; segment adr of ModeX line buffer
ModeXBufferPointer	dw	0
ModeXDisplayPointer	dw	0
ModeX			db	0	; set if in modex

MXDelayedClear		db	0	; delayed clear (kludge -- see tia.asm)

ALIGN 2

; index data pairs for CRT controller registers that differ between mode 13 and mode X

CRTParms label word
	dw	00d06h	; vertical total
	dw	03e07h	; overflow (bit 8 of vertical counts)
	dw	04109h	; cell height (2 to double scan)
	dw	0ea10h	; v sync start
	dw	0ac11h	; v sync end and protect cr0-cr7
	dw	0df12h	; vertical displayed
	dw	00014h	; turn off dword mode
	dw	0e715h	; vblank start
	dw	00616h	; vblank end
	dw	0e317h	; turn on byte mode
CRT_PARM_LENGTH = (($-CRTParms)/2)

MX5Parms label word

	dw	06c00h	; horizontal total
	dw	04f01h	; horizontal display enable end
	dw	05002h	; horizontal blanking start
	dw	08203h	; horizontal blanking end
	dw	05b04h	; horizontal retrace start
	dw	08705h	; horizontal retrace end

	dw	00d06h	; vertical total
	dw	03e07h	; overflow (bit 8 of vertical counts)
	dw	04109h	; cell height (2 to double scan)
	dw	0ea10h	; v sync start
	dw	0ac11h	; v sync end and protect cr0-cr7
	dw	0df12h	; vertical displayed
	dw	00014h	; turn off dword mode
	dw	0e715h	; vblank start
	dw	00616h	; vblank end
	dw	0e317h	; turn on byte mode
MX5_PARM_LENGTH = (($-MX5Parms)/2)

.DEND
.CODESEGMENT

;*
;* initialize mode x
;*

ModeXInit:
	pusha
	push	es

	cmp	[_VideoMode],7		; doing mode 7 or less ?
	ja	MXPRet			;   no, ret for now

	mov	[ModeX],1


	mov	ax,offset ModeXBuffer	; address within data segment
	shr	ax,4			; paragraph
	inc	ax			; just in case... make sure we point inside buffer
	mov	dx,ds
	add	dx,ax
	mov	[ModeXBufferSeg],dx	; save segment pointer
	mov	gs,dx			; and set graphics segment to render into buffer
	shl	ax,4
	mov	[ModeXBufferPointer],ax	; save rounded buffer pointer

; here comes the real stuff...

	mov	eax,50000
	call	_Delay			; a 1/20th of a second delay...
	call	VSync
	mov	eax,8000
	call	_Delay			; about a half of a frame past VSync
					; so we don't straddle a vsync during init
					; (don't ask why)

	cli

	mov	dx,SC_INDEX
	mov	ax,0604h
	out	dx,ax			; disable chain4 mode
	mov	ax,0100h
	out	dx,ax			; syncronous reset while setting misc output
					; for safety, even though clock unchanged

	cmp	[_VideoMode],4		; doing tweaked ModeX ?
	jne	MX5a
	mov	al,0e3h			;   no,  select 25MHz dot clock & 60Hz scanning rate
	jmp	MX4a

MX5a:	mov	al,0e7h			;   yes, select 28MHz dot clock & 60Hz scanning rate
MX4a:	mov	dx,MISC_OUTPUT
	out	dx,al

	mov	dx,SC_INDEX
	mov	ax,0300h
	out	dx,al			; undo reset (restart sequencer)

	mov	dx,CRTC_INDEX		; reprogram the CRT controller
	mov	al,11h			; vsync end reg contains register ...
	out	dx,al			; ... write protect bit
	inc	dx			; CRT controller data register
	in	al,dx			; get current vsync end register setting
	and	al,07fh			; remove write protect on various ...
	out	dx,al			; ... CRTC registers
	dec	dx			; CRT controller index
	cld

	cmp	[_VideoMode],4		; doing tweaked ModeX ?
	jne	MX5b

	mov	si,offset CRTParms	;   no, point to CRT parameter table
	mov	cx,CRT_PARM_LENGTH	;       # of table entries
	jmp	MX4b

MX5b:	mov	si,offset MX5Parms	;   yes, point to tweaked CRT parameter table
	mov	cx,MX5_PARM_LENGTH
MX4b:

SetCRTParmsLoop:
	lodsw				; get the next CRT index/data pair
	out	dx,ax			; set the next CRT index/data pair
	loop	SetCRTParmsLoop

	sti

	call	MXClearMem

	cmp	[_VideoMode],6		; doing mode 6 or 7 (scanline) ?
	jb	MXPRet			;   no

	mov	dx,CRTC_INDEX		;   yes, turn off doublescan mode
	mov	al,9			; cell height
	out	dx,al
	inc	dx
	in	al,dx
	and	al, not 1fh
	out	dx,al			; turn off doublescan mode

	cmp	[_VideoMode],7		; mode 7 (tiny)
	jne	MXPRet			;   no

	cmp	[CFirst],0		; frogpond or pharhcrs ?
	jz	JustDoMaxLines		;   yes

	mov	[CFirst],1		; this is ultimate reality mode
	mov	[OldCFirst],1

JustDoMaxLines:
	mov	[MaxLines],480

MXPRet:	pop	es
	popa
	ret

;*
;* clear VGA memory
;*

MXClearMem:
	cmp	[ModeX],0		; in ModeX ?
	jz	MXRet			;   no, ignore call

	pushad
	push	es

	mov	dx,SC_INDEX
	mov	ax,0f02h
	out	dx,ax			; enable writes to all four planes

	mov	ax,SCREEN_SEG		; now clear ALL memory ...
	mov	es,ax			; ... 8 pixels at a time
	sub	di,di			; point es:di to display memory
	sub	ax,ax			; clear to zero-value pixels
	mov	cx,08000h		; # of words in display memory
	rep	stosw			; clear all of memory

	pop	es
	popad

	ret

;*
;* set up to do next modex frame
;*

ModeXNewFrame:
	cmp	[ModeX],0		; in ModeX ?
	jz	MXRet			;   no, ignore call
	cmp	[MaxLines],220		; doing partial screen
	ja	MXStartAtZero		;   no
	mov	[ModeXDisplayPointer],800 ; yes, start 10 lines down
	ret

MXStartAtZero:
	mov	[ModeXDisplayPointer],0	; reset output pointer
MXRet:	ret

;*
;* set up to do next modex scan line
;*

ModeXNewLine:
	cmp	[ModeX],0		; in ModeX ?
	jz	MXRet			;   no, ignore call
	mov	[DisplayPointer],0	; point rendering pointer at start of buffer
	ret

;*
;* copy line to modex display
;*

MXMove4 macro op1

	mov	al,[si+op1]
	mov	ah,[si+op1+4]
	mov	bl,[si+op1+8]
	mov	es:[di],ax
	mov	bh,[si+op1+12]
	add	si,16
	mov	es:[di+2],bx
	add	di,4

	endm

ModeXCopyLine:
	cmp	[ModeX],0		; in ModeX ?
	jz	MXRet			;   no, ignore call
	pusha
	push	es

	mov	ax,0a000h
	mov	es,ax			; dest segment is VGA area

	cmp	[_VideoMode],6		; doing video mode 4, 5 or 6
	ja	MX6CopyLine		;   no

	mov	cx,20
	mov	si,[ModeXBufferPointer]
	mov	di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0302h
	out	dx,ax			; enable planes 0,1 for even pixels

MXEvenLoop:
	MXMove4	0
	dec	cx
	jnz	MXEvenLoop

	mov	cx,20
	mov	si,[ModeXBufferPointer]
	mov	di,[ModeXDisplayPointer]
	mov	ax,0c02h
	out	dx,ax			; enable planes 2,3 for odd pixels

MXOddLoop:
	MXMove4	2
	dec	cx
	jnz	MXOddLoop
	
	add	[ModeXDisplayPointer],80
	cmp	[_VideoMode],6		; doing scanline mode?
	jne	MXCRet			;   no

	add	[ModeXDisplayPointer],80 ;  yes, skip a line
	
MXCRet:	pop	es
	popa
	ret


;*
;* mode 7 line copy
;*

MX6Move4 macro op1

	mov	al,[si+op1]
	mov	ah,[si+op1+8]
	mov	bl,[si+op1+16]
	mov	es:[di],ax
	mov	bh,[si+op1+24]
	add	si,32
	mov	es:[di+2],bx
	add	di,4

	endm

MX6CopyLine:

	add	[ModeXDisplayPointer],20

	mov	cx,10
	mov	si,[ModeXBufferPointer]
	mov	di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0102h
	out	dx,ax			; enable plane 0 for these pixels

MX6Loop0:
	MX6Move4 0
	dec	cx
	jnz	MX6Loop0

	mov	cx,10
	mov	si,[ModeXBufferPointer]
	mov	di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0202h
	out	dx,ax			; enable plane 1 for these pixels

MX6Loop1:
	MX6Move4 2
	dec	cx
	jnz	MX6Loop1

	mov	cx,10
	mov	si,[ModeXBufferPointer]
	mov	di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0402h
	out	dx,ax			; enable plane 2 for these pixels

MX6Loop2:
	MX6Move4 4
	dec	cx
	jnz	MX6Loop2

	mov	cx,10
	mov	si,[ModeXBufferPointer]
	mov	di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0802h
	out	dx,ax			; enable plane 3 for these pixels

MX6Loop3:
	MX6Move4 6
	dec	cx
	jnz	MX6Loop3

	add	[ModeXDisplayPointer],60

	jmp	MXCRet
