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

DefaultPaletteTable db 0,   0,    0	; 0 0 0 0 -- 0 (grey)
		db    63,  63,   63	; 0 0 0 0 -- 7

		db   15,   12,    5	; 0 0 0 1 -- 0 (gold)
		db   63,   63,   45	; 0 0 0 1 -- 7 (63,63,50)

		db   25,   10,    5	; 0 0 1 0 -- 0 (orange)
		db   60,   54,   30	; 0 0 1 0 -- 7 (55,55,30)

		db   30,    5,    0	; 0 0 1 1 -- 0 (bright orange)
		db   63,   52,   30	; 0 0 1 1 -- 7

		db   25,    5,    5	; 0 1 0 0 -- 0 (pink)
		db   63,   46,   47	; 0 1 0 0 -- 7 

		db   22,    8,   20	; 0 1 0 1 -- 0 (purple)
		db   63,   40,   63	; 0 1 0 1 -- 7 

		db   20,    8,   24	; 0 1 1 0 -- 0 (purple-blue)
		db   52,   40,   63	; 0 1 1 0 -- 7

		db   11,    8,   33	; 0 1 1 1 -- 0 (blue <slightly purplish>)
		db   55,   48,   63	; 0 1 1 1 -- 7 (was 55,40,63 for atlantis)

		db    8,    8,   35	; 1 0 0 0 -- 0 (blue)
		db   45,   45,   63	; 1 0 0 0 -- 7

		db    6,    6,   25	; 1 0 0 1 -- 0 (light blue)
		db   50,   50,   63	; 1 0 0 1 -- 7

		db    0,    8,   20	; 1 0 1 0 -- 0 (turquoise)
		db   40,   55,   63	; 1 0 1 0 -- 7

		db    0,   12,    8	; 1 0 1 1 -- 0 (green-blue)
		db   40,   63,   55	; 1 0 1 1 -- 7

		db    4,   12,    4	; 1 1 0 0 -- 0 (green)
		db   50,   63,   50	; 1 1 0 0 -- 7 (was 40,60,60 for atlantis)

		db   10,   15,    0	; 1 1 0 1 -- 0 (yellow-green)
		db   50,   63,   35	; 1 1 0 1 -- 7

		db   15,   25,    0	; 1 1 1 0 -- 0 (orange-green)
		db   55,   63,   30	; 1 1 1 0 -- 7

		db   20,   10,    0	; 1 1 1 1 -- 0 (light-orange)
		db   63,   50,   30	; 1 1 1 1 -- 7


.DEND
.CODESEGMENT
