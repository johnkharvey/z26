
EXTRN _Fillbuffer:near		; sound buffer filling routine

; macro to double two pixels and store them

DoubleDoublePixel macro op1
	mov	al,gs:op1[si]
	mov	ah,gs:op1[si]
	mov	bl,gs:op1+1[si]
	mov	bh,gs:op1+1[si]
	mov	es:2*op1[di],ax
	mov	es:2*op1+2[di],bx
	endm


;*
;* ModeX init routine -- don't forget to set _VideoWidth, 
;*                                           _VideoHeight, and
;*                                           _VideoPixels  if necessary
;*

ALIGN_ENTRY

ModeXInit:
	ret

;*
;* ModeX drawing routine
;*

ALIGN_ENTRY

EriksVideo:
	cmp	[_VideoMode],1
	jne	EriksRet

; video mode 1
; do conversion for VGA mode 13

	pushad
	push	es
	call	_Fillbuffer		; make sure sound buffer full

	mov	ax,0a000h
	mov	es,ax			; point ES to VGA area

	xor	si,si
	xor	di,di			; point at beginning of buffers
	mov	cx,[_VideoPixels]	; # of bytes to convert
	shr	cx,2			; I hope it's divisable by 32
	mov	dx,4

Mode1Loop:
	DoubleDoublePixel 0
	DoubleDoublePixel 2
	DoubleDoublePixel 4
	DoubleDoublePixel 6
	add	si,8
	add	di,16
	sub	cx,8			; done converting partial buffer ?
	jnz	Mode1Loop		;   not yet

	pusha
	call	_Fillbuffer		; make sure sound buffer full
	popa
	mov	cx,[_VideoPixels]
	shr	cx,2
	dec	dx			; done converting entire buffer ?
	jnz	Mode1Loop		;   nope
	
	pop	es
	popad

EriksRet:
	ret

.CEND
.DATASEGMENT

;*
;* these should be set by init routine to values appropriate to the mode
;*

; currently VideoWidth  may be 160 or 180
;           VideoHeight may be 200 or 240

_VideoWidth	dw	160		; width of current mode in pixels
_VideoHeight	dw	200		; height of current mode in pixels
_VideoPixels	dw	160*200		; total # of pixels in current mode

.DEND
.CODESEGMENT