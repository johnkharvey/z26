; *****************************************************************************
;
;			    Switch Graphics Mode
;
; *****************************************************************************

TIAGraphicMode:

;*
;* generate palette
;*
;*     currently we do linear interpolation between
;*     the bright and dim RGB triples to get the
;*     other 6 LUM values
;*
;*     eventually we may want to squeeze towards bright
;*     (more LUM values at bright end of scale)
;*

GeneratePalette:
	mov	si,offset DefaultPaletteTable
	mov	di,offset PCXPalette
	mov	[PaletteCount],0	; do 16 colors
PaletteLoop:				; <-- for each color
	mov	cx,0			; initialize 8 values of LUM
LUMLoop:
	mov	dx,3			; do 3 values of RGB
RGBLoop:
	mov	al,3[si]		; [RHi]
	mov	bl,0[si]		; [RLo]
	sub	al,bl			; al = RHi - RLo
	mov	bl,7
	div	bl			; al = (RHi - RLo) / 7
	mul	cl			; al = cl * (RHi - RLo) / 7
	mov	bl,0[si]		; [RLo]
	add	al,bl			; compute color value
	shl	al,2
	mov	[di],al			; put it in palette
	inc	di			; next palette entry
	inc	si			; next RGB value
	dec	dx			; done all three RGB values
	jnz	RGBLoop			;   not yet

	sub	si,3			; back at beginning of this RGB set
	inc	cx
	cmp	cx,8			; done eight LUM's yet ?
	jnz	LUMLoop			;   no
	add	si,6			;   yes, to next RGB set (color)
	inc	PaletteCount
	cmp	[PaletteCount],16	; done 16 colors yet ?
	jnz	PaletteLoop		;   not yet
	
; continue with hardware stuff

	mov	ah,1			; turn off the cursor
	mov	ch,020h
	int	010h
	mov	ah,0			; switch to 320x200 VGA	mode
	mov	al,013h
	int	010h
	call	TIAPalette
	ret

TIATextMode:
	mov	ah,0			; switch to 80x25 colour mode
	mov	al,3
	int	010h
	mov	ah,1			; turn cursor back on
	mov	cx,0B0Ch
	int	010h
	ret

; *****************************************************************************
;
;		       Set the VGA Palette up
;
; *****************************************************************************

TIAPalette:
        mov     bp,offset PCXPalette
        mov     cl,0
TIAPalLoop:
        mov     al,255
        mov     dx,03c6h
        out     dx,al
        add     dx,2
        mov     al,cl
        out     dx,al
        inc     dx
        mov     al,0[bp]
	shr	al,2
        out     dx,al
        mov     al,1[bp]
	shr	al,2
        out     dx,al
        mov     al,2[bp]
	shr	al,2
        out     dx,al
        add     bp,3
        inc     cl
        cmp     cl,128
        jne     TIAPalLoop
        ret

.CEND
.DATASEGMENT

; * variables used in palette generation

PaletteCount	dw	0

PCXPalette db 128*3 dup (0)	; 384 -- generated palette goes here

; * Default palette, based on Paul Robson's *

DefaultPaletteTable db 0,0,0 	; was 7,7,7
	      db 63,63,63	; 		(grey)

	      db 16,12,1	; was 23,8,1
	      db 63,63,45	; was 63,63,38 	(gold)

	      db 25,10,5	; was 28,7,4 
	      db 63,57,35	; was 63,57,40	(orange)

	      db 31,6,3		;
	      db 63,49,51	; 		(brite orange)

	      db 30,5,5		; was 14,4,27
	      db 63,50,50	; was 63,41,63	(pink)

	      db 16,2,33	;
	      db 63,42,63	; 		(purple)

	      db 16,2,43	;
	      db 55,42,63	;		(purple-blue)

	      db 5,10,35	; was 1 9 41
	      db 48,50,63	; 		(blue)

	      db 5,10,35	; was 8,6,40
	      db 36,48,63	; 		(blue)

	      db 10,10,30	; was 7,14,29 
	      db 50,50,63	; 		(light blue)

	      db 5,12,20	; was 14,20,0
	      db 43,58,63	; was 42,63,45	(turquoise)

	      db 5,12,8		; was 3,21,2
	      db 40,63,58	; was 44,63,38	(green-blue)

	      db 8,12,8		; was 1,20,3
	      db 40,63,40	; was 55,63,32	(green)

	      db 10,15,5	; was 1,15,5
	      db 50,63,35	; was 60,63,20	(yellow-green)

	      db 9,14,0		; was 9,14,0
	      db 62,63,31	; 		(orange-green)

	      db 22,7,1		; 
	      db 63,50,32	;		(light orange)

.DEND
.CODESEGMENT
