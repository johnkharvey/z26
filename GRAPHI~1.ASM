; *****************************************************************************
;
;			    Switch Graphics Mode
;
; *****************************************************************************

TIAGraphicMode:

	jmp	GenerateLinearizedPalette

	mov	si,offset TIAVGATable	; convert "Classic" palette
	mov	cx,384
SetupPaletteLoop:
	mov	al,[si]
	shl	al,2			; shift entries left
	mov	[si],al
	inc	si
	loop	SetupPaletteLoop

;*
;* generate linearized palette
;*
GenerateLinearizedPalette:
	push	es			; save es
	push	ds
	pop	es			; point es at dataseg
	mov	si,offset TIAVGATable	; pointer to palette definitions
	mov	di,offset PCXPalette
	mov	[PaletteCount],0
LinearPaletteLoop:			; <-- for each color
	push	di
	mov	di,offset RLo		; point to RGB variable area
	mov	cx,6			; copy 6 variables
	rep	movsb
	pop	di
	mov	cx,0			; initialize 8 values of LUM

LUMLoop:	
	mov	al,[RHi]
	mov	bl,[RLo]
	sub	al,bl			; al = RHi - RLo
	mov	bl,7
	div	bl			; al = (RHi - RLo) / 7
	mul	cl			; al = cl * (RHi - RLo) / 7
	mov	bl,[RLo]
	add	al,bl			; compute color value
	shl	al,2
	mov	[di],al			; put it in palette
	inc	di

	mov	al,[GHi]
	mov	bl,[GLo]
	sub	al,bl			; al = GHi - GLo
	mov	bl,7
	div	bl			; al = (RHi - RLo) / 7
	mul	cl			; al = cl * (RHi - RLo) / 7
	mov	bl,[GLo]
	add	al,bl			; compute color value
	shl	al,2
	mov	[di],al			; put it in palette
	inc	di

	mov	al,[BHi]
	mov	bl,[BLo]
	sub	al,bl			; al = BHi - BLo
	mov	bl,7
	div	bl			; al = (RHi - RLo) / 7
	mul	cl			; al = cl * (RHi - RLo) / 7
	mov	bl,[BLo]
	add	al,bl			; compute color value
	shl	al,2
	mov	[di],al			; put it in palette
	inc	di
	
	inc	cx			; = 1 after first pass
	cmp	cx,8			; done eight LUM's yet ?
	jnz	LUMLoop			;   no
	inc	PaletteCount
	cmp	[PaletteCount],16
	jnz	LinearPaletteLoop
	
	pop	es			; restore es

; continue with hardware stuff

	mov	ah,1			; turn off the cursor
	mov	ch,020h
	int	010h
	mov	ah,0			; switch to 320x200 VGA	mode
	mov	al,013h
	int	010h
	call	TIAPalette		;  *** this one for now ***
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
        mov     bp,[TIAPalettePointer]
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

; * variables used in linearized palette generation

RLo	db	0
GLo	db	0
BLo	db	0
RHi	db	0
GHi	db	0
BHi	db	0

PaletteCount	dw	0


PCXPalette db 128*3 dup (0)	; 384

; My Palette

; Note: the bottom two bits of each of the following numbers
;       is ignored by the VGA controller

; 176 became 128
; 74 became 96

PCXPaletteDef	db 0,    0,    0	; 0 0 0 0 -- 0 (grey)
		db 63*4, 63*4, 63*4	; 0 0 0 0 -- 7

		db 23*4, 8*4,  1*4 	; 0 0 0 1 -- 0 (gold)
		db 63*4, 63*4, 38*4	; 0 0 0 1 -- 7

		db 28*4, 7*4,  4*4	; 0 0 1 0 -- 0 (orange)
		db 63*4, 57*4, 40*4	; 0 0 1 0 -- 7

		db 31*4, 6*4,  3*4	; 0 0 1 1 -- 0 (bright orange)
		db 63*4, 49*4, 51*4	; 0 0 1 1 -- 7

		db 96,   0,    16	; 0 1 0 0 -- 0 (pink <red?>)
		db 255,  128,  176	; 0 1 0 0 -- 7

		db 80,   0,    96	; 0 1 0 1 -- 0 (purple)
		db 240,  128,  255	; 0 1 0 1 -- 7

		db 64,   0,    96	; 0 1 1 0 -- 0 (purple-blue)
		db 224,  128,  255	; 0 1 1 0 -- 7

		db 16,   0,    96	; 0 1 1 1 -- 0 (blue)
		db 176,  128,  255	; 0 1 1 1 -- 7

		db 0,    16,   96	; 1 0 0 0 -- 0 (blue)
		db 128,  176,  255	; 1 0 0 0 -- 7

		db 0,    64,   96	; 1 0 0 1 -- 0 (light blue)
		db 128,  224,  255	; 1 0 0 1 -- 7

		db 0,    80,   80	; 1 0 1 0 -- 0 (turquoise)
		db 128,  240,  240	; 1 0 1 0 -- 7

		db 0,    96,   64	; 1 0 1 1 -- 0 (green-blue)
		db 128,  255,  224	; 1 0 1 1 -- 7

		db 0,    96,   0	; 1 1 0 0 -- 0 (green)
		db 128,  255,  128	; 1 1 0 0 -- 7

		db 64,   96,   0	; 1 1 0 1 -- 0 (yellow-green)
		db 224,  255,  128	; 1 1 0 1 -- 7

		db 80,   80,   0	; 1 1 1 0 -- 0 (orange-green)
		db 240,  240,  128	; 1 1 1 0 -- 7

		db 96,   80,   0	; 1 1 1 1 -- 0 (light-orange)
		db 255,  240,  128	; 1 1 1 1 -- 7

; * Paul Robson's original Palette *
; * these 8-bit triples are shifted right 2 bits *

TIAVGATable db 7,7,7	; 1c1c1c
      db 63,63,63	; ffffff	8/8 (grey)
      db 23,8,1		; 5e2304
      db 63,63,38	; ffff98	8/8 (gold)
      db 28,7,4		; 721e11
      db 63,57,40	; ffe4a1	8/8 (orange)
      db 31,6,3		; 7e1a0d
      db 63,49,51	; ffc7ce	8/8 (brite orange)
      db 14,4,27	; 3b136d
      db 63,41,63	; ffa4ff	8/8 (pink)
      db 16,2,33	; 400984
      db 63,42,63	; feabff	8/8 (purple)
      db 16,2,43	; 420aad
      db 55,42,63	; dfaaff	8/8 (purple-blue)
      db 1,9,41		; 626a5
      db 48,50,63	; c0cbff	8/8 (blue)
      db 8,6,40		; 2218a0
      db 48,48,63	; c0c2ff	8/8 (blue)
      db 7,14,29	; 1d3876
      db 48,58,63	; c3e9ff	8/8 (light blue)
      db 14,20,0	; 395202
      db 43,63,45	; adffb6	8/8 (turquoise)
      db 3,21,2		; d540a
      db 44,63,38	; b2ff9a	8/8 (green-blue)
      db 1,20,3		; 5530e
      db 55,63,32	; dcff81	8/8 (green)
      db 1,15,5		; 73f15
      db 60,63,20	; f2ff53	8/8 (yellow-green)
      db 9,14,0		; 243803
      db 62,63,31	; fbff7d	8/8 (orange-green)
      db 22,7,1		; 581f05
      db 63,50,32	; ffcb83	8/8 (light orange)
;


;TIAVGATable db 7,7,7	; 1c1c1c
;      db 22,22,22	; 595959
;      db 36,36,36	; 929292
;      db 47,47,47	; bcbcbc
;      db 54,54,54	; d9d9d9
;      db 59,59,59 	; ececec
;      db 62,62,62	; f8f8f8
;      db 63,63,63	; ffffff	8/8 (grey)
;      db 23,8,1	; 5e2304
;      db 41,17,5	; a54716
;      db 56,30,8	; e37820
;      db 63,42,7	; ffab1d
;      db 63,51,13	; ffce34
;      db 63,57,20	; ffe651
;      db 63,62,29	; fff977
;      db 63,63,38	; ffff98	8/8 (gold)
;      db 28,7,4	; 721e11
;      db 44,14,8	; b33a20
;      db 56,26,8	; e36920
;      db 63,35,9	; ff8c25
;      db 63,43,14	; ffae38
;      db 63,49,22	; ffc559
;      db 63,53,33	; ffd587
;      db 63,57,40	; ffe4a1	8/8 (orange)
;      db 31,6,3	; 7e1a0d
;      db 50,8,6	; c82119
;      db 59,14,14	; ec3b38
;      db 63,24,24	; fc6161
;      db 63,31,31	; ff7f7e
;      db 63,39,39	; ff9d9e
;      db 63,46,47	; ffb9bd
;      db 63,49,51	; ffc7ce	8/8 (brite orange)
;      db 14,4,27	; 3b136d
;      db 34,10,35	; 8b2a8c
;      db 46,14,46	; b938ba
;      db 54,17,55	; db47dd
;      db 61,23,61	; f45ff5
;      db 63,30,63	; fe7afd
;      db 63,37,63	; ff95fd
;      db 63,41,63	; ffa4ff	8/8 (pink)
;      db 16,2,33	; 400984
;      db 28,9,39	; 70249d
;      db 41,16,48	; a441c3
;      db 52,21,59	; d054ed
;      db 58,27,63	; e96dff
;      db 62,34,63	; f88aff
;      db 63,40,63	; fea1ff
;      db 63,42,63	; feabff	8/8 (purple)
;      db 16,2,43	; 420aad
;      db 25,10,52	; 6428d0
;      db 35,18,53	; 8d4bd4
;      db 44,22,59	; b058ec
;      db 49,26,63	; c56bff
;      db 52,32,63	; d183ff
;      db 54,39,63	; db9dff
;      db 55,42,63	; dfaaff	8/8 (purple-blue)
;      db 1,9,41	; 626a5
;      db 9,15,53	; 263dd4
;      db 19,22,59	; 4f5aee
;      db 25,29,63	; 6575ff
;      db 32,36,63	; 8091ff
;      db 37,42,63	; 97a9ff
;      db 43,47,63	; afbeff
;      db 48,50,63	; c0cbff	8/8 (blue)
;      db 8,6,40	; 2218a0
;      db 18,15,49	; 483ec7
;      db 24,22,59	; 6159ec
;      db 30,29,63	; 7a74ff
;      db 36,35,63	; 918eff
;      db 41,40,63	; a5a3ff
;      db 46,46,63	; b8b8ff
;      db 48,48,63	; c0c2ff	8/8 (blue)
;      db 7,14,29	; 1d3876
;      db 7,23,43	; 1c5cac
;      db 12,33,51	; 3286cf
;      db 19,42,59	; 4ea8ec
;      db 28,49,63	; 70c7ff
;      db 36,54,63	; 93dbff
;      db 43,57,63	; afe4ff
;      db 48,58,63	; c3e9ff	8/8 (light blue)
;      db 14,20,0	; 395202
;      db 16,30,4	; 417a12
;      db 18,39,11	; 4a9f2e
;      db 23,47,21	; 5cbd55
;      db 26,56,30	; 69e27a
;      db 31,62,35	; 7cfa8d
;      db 38,63,41	; 9affa6
;      db 43,63,45	; adffb6	8/8 (turquoise)
;      db 3,21,2	; d540a
;      db 4,31,3	; 137d0f
;      db 6,41,5	; 19a514
;      db 7,50,6	; 1ec919
;      db 17,57,11	; 47e42d
;      db 30,61,19	; 78f74d
;      db 38,63,30	; 9aff7a
;      db 44,63,38	; b2ff9a	8/8 (green-blue)
;      db 1,20,3	; 5530e
;      db 1,29,5	; 77714
;      db 2,38,6	; 99b1a
;      db 18,49,7	; 48c41f
;      db 35,58,9	; 8fe924
;      db 42,63,16	; a8fc41
;      db 50,63,27	; c9ff6e
;      db 55,63,32	; dcff81	8/8 (green)
;      db 1,15,5	; 73f15
;      db 11,23,7	; 2d5f1e
;      db 22,32,9	; 598324
;      db 32,40,11	; 82a12e
;      db 42,48,14	; a9c13a
;      db 49,54,17	; c4d945
;      db 57,60,19	; e4f04e
;      db 60,63,20	; f2ff53	8/8 (yellow-green)
;      db 9,14,0	; 243803
;      db 20,21,6	; 51541b
;      db 37,32,13	; 978135
;      db 48,41,15	; c2a73e
;      db 54,48,15	; dbc03d
;      db 56,54,13	; e2d836
;      db 59,60,22	; eff258
;      db 62,63,31	; fbff7d	8/8 (orange-green)
;      db 22,7,1	; 581f05
;      db 35,14,4	; 8d3a13
;      db 45,25,9	; b56427
;      db 52,33,14	; d0853a
;      db 59,40,19	; eda04e
;      db 63,45,23	; fcb75c
;      db 63,49,28	; ffc671
;      db 63,50,32	; ffcb83	8/8 (light orange)

; * Ronnie Greene's palette *
; * these are unshifted 8 bit RGB triples *

;PCXPalette	db 000h, 000h, 000h	; 0 0 0 0 -- 0 (grey)
;		db 024h, 024h, 024h	; 0 0 0 0 -- 1
;		db 048h, 048h, 048h	; 0 0 0 0 -- 2
;		db 06Dh, 06Dh, 06Dh	; 0 0 0 0 -- 3
;		db 091h, 091h, 091h	; 0 0 0 0 -- 4
;		db 0B6h, 0B6h, 0B6h	; 0 0 0 0 -- 5
;		db 0DAh, 0DAh, 0DAh	; 0 0 0 0 -- 6
;		db 0FFh, 0FFh, 0FFh	; 0 0 0 0 -- 7
;
;		db 04Ah, 03Fh, 000h	; 0 0 0 1 -- 0 (gold)
;		db 070h, 061h, 00Fh	; 0 0 0 1 -- 1
;		db 08Ch, 07Ch, 021h	; 0 0 0 1 -- 2
;		db 0A6h, 095h, 038h	; 0 0 0 1 -- 3
;		db 0BEh, 0ADh, 051h	; 0 0 0 1 -- 4
;		db 0D4h, 0C5h, 06Eh	; 0 0 0 1 -- 5
;		db 0EAh, 0DCh, 08Eh	; 0 0 0 1 -- 6
;		db 0FFh, 0F3h, 0B0h	; 0 0 0 1 -- 7
;
;		db 04Ah, 017h, 000h	; 0 0 1 0 -- 0 (orange)
;		db 070h, 02Dh, 00Fh	; 0 0 1 0 -- 1
;		db 08Ch, 042h, 021h	; 0 0 1 0 -- 2
;		db 0A6h, 05Ah, 038h	; 0 0 1 0 -- 3
;		db 0BEh, 073h, 051h	; 0 0 1 0 -- 4
;		db 0D4h, 08Eh, 06Eh	; 0 0 1 0 -- 5
;		db 0EAh, 0AAh, 08Eh	; 0 0 1 0 -- 6
;		db 0FFh, 0C8h, 0B0h	; 0 0 1 0 -- 7
;
;		db 04Ah, 001h, 000h	; 0 0 1 1 -- 0 (bright orange)
;		db 070h, 010h, 00Fh	; 0 0 1 1 -- 1
;		db 08Ch, 023h, 021h	; 0 0 1 1 -- 2
;		db 0A6h, 039h, 038h	; 0 0 1 1 -- 3
;		db 0BEh, 053h, 051h	; 0 0 1 1 -- 4
;		db 0D4h, 06Fh, 06Eh	; 0 0 1 1 -- 5
;		db 0EAh, 08Fh, 08Eh	; 0 0 1 1 -- 6
;		db 0FFh, 0B1h, 0B0h	; 0 0 1 1 -- 7
;
;		db 04Ah, 000h, 013h	; 0 1 0 0 -- 0 (pink)
;		db 070h, 013h, 02Bh	; 0 1 0 0 -- 1
;		db 08Ch, 02Ah, 044h	; 0 1 0 0 -- 2
;		db 0A6h, 046h, 05Fh	; 0 1 0 0 -- 3
;		db 0BEh, 067h, 07Dh	; 0 1 0 0 -- 4
;		db 0D4h, 08Bh, 09Eh	; 0 1 0 0 -- 5
;		db 0EAh, 0B3h, 0C1h	; 0 1 0 0 -- 6
;		db 0FFh, 0DEh, 0E7h	; 0 1 0 0 -- 7
;
;		db 04Ah, 000h, 038h	; 0 1 0 1 -- 0 (purple)
;		db 070h, 00Fh, 058h	; 0 1 0 1 -- 1
;		db 08Ch, 021h, 072h	; 0 1 0 1 -- 2
;		db 0A6h, 038h, 08Bh	; 0 1 0 1 -- 3
;		db 0BEh, 051h, 0A3h	; 0 1 0 1 -- 4
;		db 0D4h, 06Eh, 0BBh	; 0 1 0 1 -- 5
;		db 0EAh, 08Eh, 0D3h	; 0 1 0 1 -- 6
;		db 0FFh, 0B0h, 0ECh	; 0 1 0 1 -- 7
;
;		db 027h, 000h, 04Ah	; 0 1 1 0 -- 0 (purple-blue)
;		db 043h, 00Fh, 070h	; 0 1 1 0 -- 1
;		db 05Ah, 021h, 08Ch	; 0 1 1 0 -- 2
;		db 072h, 038h, 0A6h	; 0 1 1 0 -- 3
;		db 08Bh, 051h, 0BEh	; 0 1 1 0 -- 4
;		db 0A4h, 06Eh, 0D4h	; 0 1 1 0 -- 5
;		db 0BFh, 08Eh, 0EAh	; 0 1 1 0 -- 6
;		db 0DAh, 0B0h, 0FFh	; 0 1 1 0 -- 7
;
;		db 00Bh, 000h, 04Ah	; 0 1 1 1 -- 0 (blue)
;		db 01Dh, 00Fh, 070h	; 0 1 1 1 -- 1
;		db 031h, 021h, 08Ch	; 0 1 1 1 -- 2
;		db 047h, 038h, 0A6h	; 0 1 1 1 -- 3
;		db 061h, 051h, 0BEh	; 0 1 1 1 -- 4
;		db 07Dh, 06Eh, 0D4h	; 0 1 1 1 -- 5
;		db 09Bh, 08Eh, 0EAh	; 0 1 1 1 -- 6
;		db 0BBh, 0B0h, 0FFh	; 0 1 1 1 -- 7
;
;		db 000h, 008h, 04Ah	; 1 0 0 0 -- 0 (blue)
;		db 00Fh, 019h, 070h	; 1 0 0 0 -- 1
;		db 021h, 02Dh, 08Ch	; 1 0 0 0 -- 2
;		db 038h, 044h, 0A6h	; 1 0 0 0 -- 3
;		db 051h, 05Dh, 0BEh	; 1 0 0 0 -- 4
;		db 06Eh, 079h, 0D4h	; 1 0 0 0 -- 5
;		db 08Eh, 098h, 0EAh	; 1 0 0 0 -- 6
;		db 0B0h, 0B8h, 0FFh	; 1 0 0 0 -- 7
;
;		db 000h, 023h, 04Ah	; 1 0 0 1 -- 0 (light blue)
;		db 00Fh, 03Ch, 070h	; 1 0 0 1 -- 1
;		db 021h, 054h, 08Ch	; 1 0 0 1 -- 2
;		db 038h, 06Bh, 0A6h	; 1 0 0 1 -- 3
;		db 051h, 084h, 0BEh	; 1 0 0 1 -- 4
;		db 06Eh, 09Eh, 0D4h	; 1 0 0 1 -- 5
;		db 08Eh, 0B9h, 0EAh	; 1 0 0 1 -- 6
;		db 0B0h, 0D5h, 0FFh	; 1 0 0 1 -- 7
;
;		db 000h, 04Ah, 03Fh	; 1 0 1 0 -- 0 (turquoise)
;		db 00Fh, 070h, 061h	; 1 0 1 0 -- 1
;		db 021h, 08Ch, 07Ch	; 1 0 1 0 -- 2
;		db 038h, 0A6h, 095h	; 1 0 1 0 -- 3
;		db 051h, 0BEh, 0ADh	; 1 0 1 0 -- 4
;		db 06Eh, 0D4h, 0C5h	; 1 0 1 0 -- 5
;		db 08Eh, 0EAh, 0DCh	; 1 0 1 0 -- 6
;		db 0B0h, 0FFh, 0F3h	; 1 0 1 0 -- 7
;
;		db 000h, 04Ah, 017h	; 1 0 1 1 -- 0 (green-blue)
;		db 00Fh, 070h, 02Dh	; 1 0 1 1 -- 1
;		db 021h, 08Ch, 042h	; 1 0 1 1 -- 2
;		db 038h, 0A6h, 05Ah	; 1 0 1 1 -- 3
;		db 051h, 0BEh, 073h	; 1 0 1 1 -- 4
;		db 06Eh, 0D4h, 08Eh	; 1 0 1 1 -- 5
;		db 08Eh, 0EAh, 0AAh	; 1 0 1 1 -- 6
;		db 0B0h, 0FFh, 0C8h	; 1 0 1 1 -- 7
;
;		db 000h, 04Ah, 001h	; 1 1 0 0 -- 0 (green)
;		db 00Fh, 070h, 010h	; 1 1 0 0 -- 1
;		db 021h, 08Ch, 023h	; 1 1 0 0 -- 2
;		db 038h, 0A6h, 039h	; 1 1 0 0 -- 3
;		db 051h, 0BEh, 053h	; 1 1 0 0 -- 4
;		db 06Eh, 0D4h, 06Fh	; 1 1 0 0 -- 5
;		db 08Eh, 0EAh, 08Fh	; 1 1 0 0 -- 6
;		db 0B0h, 0FFh, 0B1h	; 1 1 0 0 -- 7
;
;		db 013h, 04Ah, 000h	; 1 1 0 1 -- 0 (yellow-green)
;		db 028h, 070h, 00Fh	; 1 1 0 1 -- 1
;		db 03Eh, 08Ch, 021h	; 1 1 0 1 -- 2
;		db 055h, 0A6h, 038h	; 1 1 0 1 -- 3
;		db 06Eh, 0BEh, 051h	; 1 1 0 1 -- 4
;		db 089h, 0D4h, 06Eh	; 1 1 0 1 -- 5
;		db 0A6h, 0EAh, 08Eh	; 1 1 0 1 -- 6
;		db 0C5h, 0FFh, 0B0h	; 1 1 0 1 -- 7
;
;		db 038h, 04Ah, 000h	; 1 1 1 0 -- 0 (orange-green)
;		db 058h, 070h, 00Fh	; 1 1 1 0 -- 1
;		db 072h, 08Ch, 021h	; 1 1 1 0 -- 2
;		db 08Bh, 0A6h, 038h	; 1 1 1 0 -- 3
;		db 0A3h, 0BEh, 051h	; 1 1 1 0 -- 4
;		db 0BBh, 0D4h, 06Eh	; 1 1 1 0 -- 5
;		db 0D3h, 0EAh, 08Eh	; 1 1 1 0 -- 6
;		db 0ECh, 0FFh, 0B0h	; 1 1 1 0 -- 7
;
;		db 04Ah, 027h, 000h	; 1 1 1 1 -- 0 (light-orange)
;		db 070h, 043h, 00Fh	; 1 1 1 1 -- 1
;		db 08Ch, 05Ah, 021h	; 1 1 1 1 -- 2
;		db 0A6h, 072h, 038h	; 1 1 1 1 -- 3
;		db 0BEh, 08Bh, 051h	; 1 1 1 1 -- 4
;		db 0D4h, 0A4h, 06Eh	; 1 1 1 1 -- 5
;		db 0EAh, 0BFh, 08Eh	; 1 1 1 1 -- 6
;		db 0FFh, 0DAh, 0B0h	; 1 1 1 1 -- 7


.DEND
.CODESEGMENT
