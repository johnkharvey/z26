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
	dw	0ac11h	; (ac) v sync end and protect cr0-cr7
	dw	0df12h	; vertical displayed
	dw	0e715h	; vblank start
	dw	00616h	; vblank end
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
	dw	0ac11h	; (ac) v sync end and protect cr0-cr7
	dw	0df12h	; vertical displayed
	dw	0e715h	; vblank start
	dw	00616h	; vblank end
MX5_PARM_LENGTH = (($-MX5Parms)/2)

MX8Parms label word
	dw	06c00h	; horizontal total
	dw	04f01h	; horizontal display enable end
	dw	05002h	; horizontal blanking start
	dw	08203h	; horizontal blanking end
	dw	05b04h	; horizontal retrace start
	dw	08705h	; horizontal retrace end

	dw	00506h	; vertical total
	dw	01107h	; overflow (bit 8 of vertical counts)
	dw	04009h	; cell height (2 to double scan)
	dw	0f310h	; v sync start
	dw	0a511h	; (ac) v sync end and protect cr0-cr7
	dw	0ef12h	; vertical displayed
	dw	0f015h	; vblank start
	dw	00516h	; vblank end
MX8_PARM_LENGTH = (($-MX8Parms)/2)

.DEND
.CODESEGMENT

;*
;* initialize mode x
;*

ModeXInit:
	pusha
	push	es

	cmp	[_VideoMode],8		; doing mode 7 or less ?
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

	cli

	mov	dx,SC_INDEX
	mov	ax,0604h
	out	dx,ax			; disable chain4 mode

	mov	dx,CRTC_INDEX
	mov	ax,0e317h
	out	dx,ax			; disable word mode

	mov	ax,000014h
	out	dx,ax			; disable doubleword mode

	mov	[MXDelayedClear],1	; have TIA clear mem later
					; (don't know why clearing now doesn't work)

	mov	ax,0100h
	out	dx,ax			; synchronous reset while setting misc output
					; for safety, even though clock unchanged

	cmp	[_VideoMode],4		; doing tweaked ModeX ?
	jne	MX5a			;   yes
	mov	al,0e3h			;   no,  select 25MHz dot clock & 60Hz scanning rate
	jmp	MX4a

MX5a:	cmp	[_VideoMode],8		; mode 8 ?
	jb	MX6a			;   no
	mov	al,0a7h			;   yes, misc output for mode 8 (28 Mhz clock)
	jmp	MX4a

MX6a:	mov	al,0e7h			; select 28MHz dot clock & 60Hz scanning rate
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

MX5b:	cmp	[_VideoMode],8
	jb	MX6b
	mov	si,offset MX8Parms
	mov	cx,MX8_PARM_LENGTH
	jmp	MX4b
	
MX6b:	mov	si,offset MX5Parms	;   yes, point to tweaked CRT parameter table
	mov	cx,MX5_PARM_LENGTH
MX4b:

SetCRTParmsLoop:
	lodsw				; get the next CRT index/data pair
	out	dx,ax			; set the next CRT index/data pair
	loop	SetCRTParmsLoop

	sti

	cmp	[_VideoMode],6		; doing mode 6 or 7 (scanline) ?
	jb	MXPRet			;   no

	mov	dx,CRTC_INDEX		;   yes, turn off doublescan mode
	mov	al,9			; cell height
	out	dx,al
	inc	dx
	in	al,dx
	and	al, not 1fh
	out	dx,al			; turn off doublescan mode

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

	mov	ax,SCREEN_SEG		; now clear memory ...
	mov	es,ax			; ... 4 pixels at a time
	sub	di,di			; point es:di to display memory
	sub	ax,ax			; clear to zero-value pixels
	mov	cx,0ffffh		; # of dwords to clear 
	rep	stosb

	pop	es
	popad

MXRet:	ret

;*
;* Flip ModeX page
;*

ModeXFlipPage:
	cmp	[ModeX],0		; in ModeX ?
	jz	MXRet			;   no, ignore call
	mov	[ModeXDisplayPointer],0	; assume even frame or no flipping
	cmp	[_VideoMode],4		; modes 4, 5 and 8 can do page flipping
	je	DoFlipping
	cmp	[_VideoMode],5
	je	DoFlipping
	cmp	[_VideoMode],8
	jne	NoFlipping


FlipThrottleLoop:
	call	_GetTime		; prevent false alarms if running in a fast refresh mode (mode 8)
	sub	eax,[LastVsyncTime]	; (see vsync.asm for LastVsyncTime and PreGap)
	cmp	eax,[PreGap]		; at least 7/8 of a frame or so since last Vsync?
	jb	FlipThrottleLoop	;   no, keep waiting

DoFlipping:
	mov	ah,080h
	test	[Frame],1
	jz	DoFlip
	mov	ah,0
	mov	[ModeXDisplayPointer],08000h

DoFlip:
	mov	dx,CRTC_INDEX
	mov	al,00ch
	out	dx,al			; select upper byte of display page adr
	mov	al,ah
	inc	dx
	out	dx,al
	mov	dx,CRTC_INDEX
	mov	al,00dh
	out	dx,al			; select low byte of display page adr
	xor	al,al
	inc	dx
	out	dx,al			; lower byte of display page is always zero
	
NoFlipping:
	cmp	[MaxLines],220		; doing partial screen
	ja	MXRet			;   no
	add	[ModeXDisplayPointer],800 ; yes, start 10 lines down
	ret


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
	mov	bl,[si+op1+4]
	mov	es:[di],al
	mov	es:[di+1],bl
	mov	al,[si+op1+8]
	mov	bl,[si+op1+12]
	mov	es:[di+2],al
	mov	es:[di+3],bl
	add	si,16
	add	di,4

	endm

ModeXCopyLine:
	cmp	[ModeX],0		; in ModeX ?
	jz	MXRet			;   no, ignore call
	pusha
	push	es

	mov	ax,0a000h
	mov	es,ax			; dest segment is VGA area

	cmp	[_VideoMode],8		; doing mode 8
	je	DoRegularCopy		;   yes, regular
	cmp	[_VideoMode],6		; doing video mode 4, 5 or 6
	ja	MX7CopyLine		;   no

DoRegularCopy:
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

MX7Move4 macro op1

	mov	al,[si+op1]
	mov	bl,[si+op1+8]
	mov	es:[di],al
	mov	es:[di+1],bl
	mov	al,[si+op1+16]
	mov	bl,[si+op1+24]
	mov	es:[di+2],al
	mov	es:[di+3],bl
	add	si,32
	add	di,4

	endm

MX7CopyLine:

	add	[ModeXDisplayPointer],20

	mov	cx,10
	mov	si,[ModeXBufferPointer]
	mov	di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0102h
	out	dx,ax			; enable plane 0 for these pixels

MX7Loop0:
	MX7Move4 0
	dec	cx
	jnz	MX7Loop0

	mov	cx,10
	mov	si,[ModeXBufferPointer]
	mov	di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0202h
	out	dx,ax			; enable plane 1 for these pixels

MX7Loop1:
	MX7Move4 2
	dec	cx
	jnz	MX7Loop1

	mov	cx,10
	mov	si,[ModeXBufferPointer]
	mov	di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0402h
	out	dx,ax			; enable plane 2 for these pixels

MX7Loop2:
	MX7Move4 4
	dec	cx
	jnz	MX7Loop2

	mov	cx,10
	mov	si,[ModeXBufferPointer]
	mov	di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0802h
	out	dx,ax			; enable plane 3 for these pixels

MX7Loop3:
	MX7Move4 6
	dec	cx
	jnz	MX7Loop3

	add	[ModeXDisplayPointer],60

	jmp	MXCRet
