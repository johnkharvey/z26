;*
;* modex.asm -- z26 Mode-X support
;*

; mode setting code adapted from Michael Abrash's
; Graphics Programming Black Book, listing 47.1
; which itself is based on public-domain code by John Bridges

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

SC_INDEX =	03c4h		; sequence controller index
CRTC_INDEX =	03d4h		; CRT controller index
MISC_OUTPUT =	03c2h		; miscellaneous output register
SCREEN_SEG =	0a000h		; segment of display memory in mode X

.data

ModeXBufferSeg		dw	0	; segment adr of ModeX line buffer
ModeXBufferPointer	dw	0
ModeXDisplayPointer	dw	0
ModeX			db	0	; set if in modex
ModeXPage		db	0	; for telling if even or odd page (Frame not reliable)

MXDelayedClear		db	0	; 1 for frogpond, 2 for congbong
					; nobody else should notice
					; delayed clear (kludge -- see tia.asm)

Remap50Hz label byte		; remap 60Hz mode to 50Hz mode if PAL game
	db	10		; 0
	db	10		; 1
	db	11		; 2
	db	11		; 3
	db	10		; 4
	db	11		; 5
	db	12		; 6
	db	13		; 7
	db	14		; 8
	db	13		; 9
	db	10		; 10
	db	11		; 11
	db	12		; 12
	db	13		; 13
	db	14		; 14


MiscOutputTable label byte	; value of misc output register
	db	0		; 0  (mode 0-3 handled elsewhere)
	db	0		; 1
	db	0		; 2
	db	0		; 3
	db	0e3h		; 4
	db	0e7h		; 5
	db	0e7h		; 6
	db	0e7h		; 7
	db	0a7h		; 8
	db	0e7h		; 9
	db	0e3h		; 10
	db	0e7h		; 11
	db	0e7h		; 12
	db	0e7h		; 13
	db	0a7h		; 14

DoubleScanTable label byte	; if nonzero, mode doesn't do doublescan
	db	0		; 0
	db	0		; 1
	db	0		; 2
	db	0		; 3
	db	0		; 4
	db	0		; 5
	db	1		; 6
	db	1		; 7
	db	0		; 8
	db	1		; 9
	db	0		; 10
	db	0		; 11
	db	1		; 12
	db	1		; 13
	db	0		; 14

ScanLineTable label byte	; if nonzero, mode is a simulated scanline mode
	db	0		; 0
	db	0		; 1
	db	0		; 2
	db	0		; 3
	db	0		; 4
	db	0		; 5
	db	1		; 6
	db	0		; 7
	db	0		; 8
	db	0		; 9
	db	0		; 10
	db	0		; 11
	db	1		; 12
	db	0		; 13
	db	0		; 14

FlipTable label byte		; if nonzero, mode can do page flipping
	db	0		; 0
	db	0		; 1
	db	0		; 2
	db	0		; 3
	db	1		; 4
	db	1		; 5
	db	0		; 6
	db	0		; 7
	db	1		; 8
	db	0		; 9
	db	1		; 10
	db	1		; 11
	db	0		; 12
	db	0		; 13
	db	1		; 14

ALIGN 2

ParmTable label word
	dw	0		; 0
	dw	0		; 1
	dw	0		; 2
	dw	0		; 3
	dw	CRTParms	; 4
	dw	MX5Parms	; 5
	dw	MX5Parms	; 6
	dw	MX5Parms	; 7
	dw	MX8Parms	; 8
	dw	MX9Parms	; 9
	dw	MX10Parms	; 10
	dw	MX11Parms	; 11
	dw	MX11Parms	; 12
	dw	MX11Parms	; 13
	dw	MX14Parms	; 14

CopyTable label word
	dw	DoRegularCopy	; 0
	dw	DoRegularCopy	; 1
	dw	DoRegularCopy	; 2
	dw	DoRegularCopy	; 3
	dw	DoRegularCopy	; 4
	dw	DoRegularCopy	; 5
	dw	DoRegularCopy	; 6
	dw	MX7CopyLine	; 7
	dw	DoRegularCopy	; 8
	dw	MX7CopyLine	; 9
	dw	DoRegularCopy	; 10
	dw	DoRegularCopy	; 11
	dw	DoRegularCopy	; 12
	dw	MX7CopyLine	; 13
	dw	DoRegularCopy	; 14

MaxLineTable label word
	dw	200		; 0
	dw	200		; 1
	dw	200		; 2
	dw	204		; 3
	dw	240		; 4
	dw	240		; 5
	dw	240		; 6
	dw	480		; 7
	dw	240		; 8
	dw	480		; 9
	dw	256		; 10
	dw	256		; 11
	dw	256		; 12
	dw	512		; 13
	dw	256		; 14


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
	dw	-1


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
	dw	-1


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
	dw	-1


MX9Parms label word	; 360x480
	dw	06b00h	; horz total
	dw	05901h	; horz displ
	dw	05a02h	; start horz blnk
	dw	08e03h	; end horz blnk
	dw	05e04h	; start h sync
	dw	08a05h	; end h sync

	dw	00d06h	; vert tot
	dw	03e07h	; overflow
	dw	04009h	; cell ht
	dw	0ea10h	; vsync strt
	dw	0ac11h	; vsync end
	dw	0df12h	; vert displayed
	dw	02d13h	;* offset
	dw	00014h	;* turn off dword mode
	dw	0e715h	; vblank start
	dw	00616h	; vblank end
	dw	0e317h	;* turn on byte mode
	dw	-1


MX10Parms label word	; 320x240 50Hz
	dw	05f00h
	dw	04f01h
	dw	05002h
	dw	08203h
	dw	05404h
	dw	08005h

	dw	06f06h
	dw	0ba07h
	dw	00008h
	dw	04109h

	dw	02710h
	dw	00911h
	dw	0fe12h
	dw	02813h
	dw	00014h
	dw	0ff15h
	dw	01016h
	dw	0e317h
	dw	-1


MX11Parms label word	; 320x240 50Hz (squished)
	dw	06c00h	; horizontal total
	dw	04f01h	; horizontal display enable end
	dw	05002h	; horizontal blanking start
	dw	08203h	; horizontal blanking end
	dw	05b04h	; horizontal retrace start
	dw	08705h	; horizontal retrace end

	dw	06f06h
	dw	0ba07h
	dw	00008h
	dw	04109h

	dw	02710h
	dw	00911h
	dw	0fe12h
	dw	02813h
	dw	00014h
	dw	0ff15h
	dw	01016h
	dw	0e317h
	dw	-1

MX14Parms label word
	dw	06c00h	; horizontal total
	dw	04f01h	; horizontal display enable end
	dw	05002h	; horizontal blanking start
	dw	08203h	; horizontal blanking end
	dw	05b04h	; horizontal retrace start
	dw	08705h	; horizontal retrace end

	dw	03506h	; vertical total
	dw	01d07h	; overflow (bit 8 of vertical counts)
	dw	04009h	; cell height (2 to double scan)
	dw	01310h	; v sync start
	dw	0a511h	; (ac) v sync end and protect cr0-cr7
	dw	0ff12h	; vertical displayed
	dw	00015h	; vblank start
	dw	00516h	; vblank end
	dw	-1



.code

;*
;* initialize mode x
;*

ModeXInit:
	pusha
	push	es

	cmp	[_VideoMode],14		; doing a valid mode ?
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

	mov	ax,0100h
	out	dx,ax			; synchronous reset while setting misc output

	movzx	si,[_VideoMode]
	mov	al,[MiscOutputTable + si]

	mov	dx,MISC_OUTPUT
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

	movzx	si,[_VideoMode]
	shl	si,1
	mov	si,[ParmTable + si]

SetCRTParmsLoop:
	lodsw				; get the next CRT index/data pair
	cmp	ax,-1
	je	SetCRTParmsDone
	out	dx,ax			; set the next CRT index/data pair
	jmp	SetCRTParmsLoop

SetCRTParmsDone:
	movzx	si,[_VideoMode]
	cmp	[DoubleScanTable + si],0 ; doing doublescan?
	jz	MXPRet			;   yes
	mov	dx,CRTC_INDEX		;   no, turn off doublescan mode
	mov	al,9			; cell height
	out	dx,al
	inc	dx
	in	al,dx
	and	al, not 1fh
	out	dx,al			; turn off doublescan mode

MXPRet:
	sti
	call	MXClearMem		; clear mem now...

	pop	es
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

	push	si
	movzx	si,[_VideoMode]
	cmp	[FlipTable + si],0
	pop	si
	jz	NoFlipping

FlipThrottleLoop:
	call	_GetTime		; prevent false alarms if running in a fast refresh mode (mode 8)
	sub	eax,dword ptr [LastVsyncTime]	; (see vsync.asm for LastVsyncTime and PreGap)
	cmp	eax,dword ptr [PreFlip]		; at least 7/8 of a frame or so since last Vsync?	
	jb	FlipThrottleLoop	;   no, keep waiting

DoFlipping:
	inc	[ModeXPage]
	mov	ah,080h
	test	[ModeXPage],1
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
	cmp	[_VideoMode],9
	jne	MXRet
	add	[ModeXDisplayPointer],100
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

	movzx	si,[_VideoMode]
	shl	si,1
	jmp	[CopyTable + si]

;*
;* normal copy line
;*

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

	push	si
	movzx	si,[_VideoMode]
	cmp	[ScanLineTable + si],0	; a scanline mode?
	pop	si
	jz	MXCRet			;  no

	add	[ModeXDisplayPointer],80 ;  yes, skip a line
	
MXCRet:	pop	es
	popa
	ret


;*
;* mode 7 and 9 line copy
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
	cmp	[_VideoMode],9
	je	MX7CopyContinue

	add	[ModeXDisplayPointer],20	; move mode 7 toward middle

MX7CopyContinue:
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
	cmp	[_VideoMode],9
	jne	MXCRet			; if mode 7 we've added enough offset
	add	[ModeXDisplayPointer],20
	add	[ModeXDisplayPointer],10

	jmp	MXCRet



