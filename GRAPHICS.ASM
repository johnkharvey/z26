; *****************************************************************************
;
;			    Switch Graphics Mode
;
; *****************************************************************************

TIAGraphicMode:

;*
;* generate palette
;*
;*     we do non-linear interpolation between the bright and dim
;*     RGB triples to get the other 6 LUM values
;*
;*     we squeeze towards bright so that there are more LUM values 
;*     at bright end of scale
;*

GeneratePalette:
	mov	si,offset DefaultPaletteTable
	cmp	[PaletteNumber],0
	je	GPUseDefault
	cmp	[PaletteNumber],1
	je	GPUsePAL
	cmp	[CFirst],54
	jb	GPUseDefault

GPUsePAL:
	mov	si,offset PALPaletteTable
GPUseDefault:
	mov	di,offset PCXPalette
	mov	[PaletteCount],0	; do 16 colors
PaletteLoop:				; <-- for each color
	xor	ecx,ecx			; initialize 8 values of LUM
LUMLoop:
	mov	dx,3			; do 3 values of RGB
RGBLoop:
	movzx	ax,byte ptr 3[si]	; [RHi]
	movzx	bx,byte ptr 0[si]	; [RLo]
	sub	ax,bx			; al = RHi - RLo

	mov	bl,[LUMCoeff + ecx*2]
	mul	bl			; multiply by first coefficient
	mov	bl,[LUMCoeff + 1 + ecx*2]
	div	bl			; divide by second coefficient

	mov	bl,0[si]		; [RLo]
	add	al,bl			; compute color value
	shl	al,2
	mov	[di],al			; put it in palette
	inc	di			; next palette entry
	inc	si			; next RGB value
	dec	dx			; done all three RGB values ?
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

	call	TIAPalette		; set up the palette

	cmp	[_VideoMode],0		; doing offbeat video modes ?
	jz	GRRet			;   no

GRV1:	cmp	[_VideoMode],3		; doing Trixter 60Hz (mode 1, 2 or 3) ?
	ja	GRRet			;   no
	call	Trixter60Hz		;   yes
	mov	[_VideoMode],0		; pretend we're mode 13
	jmp	GRRet

GRRet:	mov	[_VideoMode],0		; any other mode, pretend mode 0	
	ret

;*
;* blank the remainder of the display each frame
;*

ALIGN_ENTRY

TIABlank:
	push	ax
	push	bx
	push	di
	xor	eax,eax
	mov	di,[DisplayPointer]
	cmp	di,30000
	jb	TIABRet
	mov	bx,[MaxLines]
	imul	bx,320
TIABLoop:
	cmp	di,bx		; (64000) reached end of display area?
	jae	TIABRet		;    yes, done
	mov	gs:[di],eax
	add	di,4
	jmp	TIABLoop

TIABRet:
	mov	[DisplayPointer],di
	pop	di
	pop	bx
	pop	ax
	ret


;*
;* return to text mode
;*

TIATextMode:
	mov	ah,0			; switch to 80x25 colour mode
	mov	al,3
	int	010h
	mov	ah,1			; turn cursor back on
	mov	cx,0B0Ch
	int	010h
	ret

;*
;* macro for programming VGA registers
;*

VidOut	macro	op1,op2,op3
	mov	dx,op1
	mov	al,op2
	out	dx,al
	inc	dx
	mov	al,op3
	out	dx,al
	endm

CRTC	equ	03d4h			; CRT controller
CRTMISC	equ	03c2h			; misc output
CRTSEQ	equ	03c4h			; sequencer
CRTGFX	equ	03ceh			; graphics

;*
;* setup a 60Hz 320 by 200 chained video mode
;* courtesy of Jim Leonard (Trixter / Hornet)
;*

Trixter60Hz:

	mov	dx,CRTSEQ
	mov	ax,0100h		; synchronous reset
	out	dx,ax			; asserted
	
	mov	dx,CRTMISC		; misc output

	cmp	[_VideoMode],1
	jne	Tr60a
	mov	al,063h			; mode 1 -- 63=squished maybe
	jmp	Tr60b			;           e3=squished definitely

Tr60a:	mov	al,0e7h			; mode 2 or 3 -- 28 Mhz clock
Tr60b:	out	dx,al

	mov	dx,CRTSEQ
	mov	ax,0300h		; restart sequencer
	out	dx,ax			; running again

	mov	dx,CRTC
	mov	al,011h			; vertical retrace end
	out	dx,al
	inc	dx
	in	al,dx
	and	al,07fh
	out	dx,al

	cmp	[_VideoMode],1
	jne	Tr60c
					; * mode 1 *
	VidOut	CRTC,   000h, 05fh	; horizontal total
	VidOut	CRTC,   004h, 054h	; horizontal retrace start
	VidOut	CRTC,   005h, 080h	; horizontal retrace end
	jmp	Tr60d
					; * mode 2 or 3 *
Tr60c:	VidOut	CRTC,   000h, 06ch	; horizontal total
	VidOut	CRTC,   004h, 05bh	; horizontal retrace start
	VidOut	CRTC,   005h, 087h	; horizontal retrace end

Tr60d:	cmp	[_VideoMode],3
	je	Tr60e
					; * mode 1 or 2 *
	VidOut	CRTC,   012h, 08fh	; <8f> vertical display enable end
	VidOut	CRTC,   015h, 090h	; <90> vertical blanking start
	jmp	Tr60f

Tr60e:					; * mode 3 *
	VidOut	CRTC,   012h, 097h	; <8f> vertical display enable end
	VidOut	CRTC,   015h, 098h	; <90> vertical blanking start
	mov	[MaxLines],204		; set up max scan lines

Tr60f:	VidOut	CRTC,   001h, 04fh	; horizontal display enable end
	VidOut	CRTC,   002h, 050h	; horizontal blanking start
	VidOut	CRTC,   003h, 082h	; horizontal blanking end
	VidOut	CRTC,   006h, 00ah	; vertical total
	VidOut	CRTC,   007h, 03eh	; overflow
	VidOut	CRTC,   008h, 000h	; preset row scan
	VidOut	CRTC,   009h, 041h	; maximum scan line
	VidOut	CRTC,   010h, 0c2h	; (ba) vertical retrace start
	VidOut	CRTC,   011h, 094h	; (8c) vertical retrace end
	VidOut	CRTC,   013h, 028h	; offset (logical line width)
	VidOut	CRTC,   014h, 040h	; underline location
	VidOut	CRTC,   016h, 008h	; vertical blanking end
	VidOut	CRTC,   017h, 0a3h	; mode control

	VidOut	CRTSEQ, 001h, 001h	; clocking mode
	VidOut	CRTSEQ, 003h, 000h	; map select
	VidOut	CRTSEQ, 004h, 00eh	; memory mode

	VidOut	CRTGFX, 005h, 040h	; graphics mode
	VidOut	CRTGFX, 006h, 005h	; miscellaneous

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

PaletteNumber	db	0ffh	; gets set by cmdline.asm

PaletteCount	db	0

;*
;* palette coefficients
;* 
;* these numbers define relative brightness of the LUM values
;*

LUMCoeff db	0,	56	; LUM 0
	db	8,	56
	db	16,	56
	db	24,	56
	db	32,	56
	db	40,	56
	db	48,	56
	db	56,	56	; LUM 7

;*
;* definitions for unsaturated colors
;*

R = 36		; main RGB values
G = 18
B = 38

MIX1 = 98	; mixing coefficients (*100)
MIX2 = 94
MIX3 = 86
MIX4 = 70
MIX5 = 50
MIX6 = 30
MIX7 = 15

VG = R*MIX5/MIX2	; virtual green (force gold)
VR = G*MIX5/MIX5	; virtual red (force orange-green)

;*
;* definitions for saturated colors
;*

H  = 63		; Hi levels
H2 = H*59/63
H3 = H*54/63

L  = H*42/63	; Lo levels
L0 = L*106/100	; extra fading for pure colors
L1 = L*95/100	; less fading for yellow-green
L2 = L*90/100	; less fading for orange-green
L3 = L*80/100	; less fading for light-orange
L4 = L*60/100	; less fading for bright orange
L5 = L*40/100	; less fading for yellow orange
L6 = L*20/100	; least fading for gold

DefaultPaletteTable db	0,		0,		0		; 00 -- (grey)
		db	H2,		H2,		H2		; 0E

		db	R*MIX5/100,	VG*MIX2/100,	0		; 10 -- (gold)
		db	H,		H,		L6		; 1E

		db	R*MIX3/100,	VG*MIX5/100,	0		; 20 -- (yellow orange)
		db	H,		H2,		L5		; 2E

		db	R*MIX1/100,	VG*MIX6/100,	0		; 30 -- (yars' bright orange)
		db	H,		H3,		L4		; 3E

		db	R,		0,		0 		; 40 -- *(pink)
		db	H,		L0,		L0		; 4E

		db	R*MIX2/100,	0,		B*MIX5/100	; 50 -- (purple)
		db	H,		L,		H2		; 5E

		db	R*MIX4/100,	0,		B*MIX3/100	; 60 -- (purple-blue)
		db	H2,		L,		H		; 6E

		db	R*MIX6/100,	0,		B*MIX1/100	; 70 -- (atlantis right blinker blue)
		db	H3,		L,		H		; 7E

		db	0,		0,		B		; 80 -- *(blue)
		db	L0,		L0,		H		; 8E

		db	0,		G*MIX7/100,	B*MIX2/100	; 90 -- (light blue)
		db	L1,		H3,		H		; 9E

		db	0,		G*MIX5/100,	B*MIX4/100	; A0 -- (atlantis turquoise)
		db	L1,		H2,		H		; AE

		db	0,		G*MIX2/100,	B*MIX6/100	; B0 -- (green-blue)
		db	L1,		H,		H2		; BE

		db	0,		G,		0		; C0 -- *(light green)
		db	L0,		H,		L0		; CE

		db	VR*MIX6/100,	G*MIX2/100,	0		; D0 -- (yellow-green)
		db	H3,		H,		L1		; DE

		db	VR*MIX5/100,	G*MIX5/100,	0		; E0 -- (orange-green)
		db	H,		H,		L2		; EE

		db	VR*MIX2/100,	G*MIX5/100,	0		; F0 -- (light-orange)
		db	H,		H2,		L3		; FE


;   Eckhard Stolberg describes the PAL palette as follows...

;   This is not in the programmer's guide. PAL systems use a different form
;   of colour encoding than NTSC ones do. The TIA chip seems to be the same
;   on both systems, which leads to two totally different palettes. Based
;   on Ed's SoundX source code for NTSC and on my own observation for PAL
;   they are:

;   NTSC                 PAL

;   grey                 grey
;   gold                 grey
;   orange               gold
;   red orange           yellow green
;   pink                 orange brown
;   purple               green
;   blue purple          pink - red
;   blue                 blue green
;   blue2                purple
;   light blue           turquoise
;   turquoise            lilac 
;   green blue           light blue
;   green                purple blue  
;   yellow green         blue
;   orange green         grey
;   light orange         grey


; We do what we can ;-)

PG = (R+G)/2	; make PAL green brighter


PALPaletteTable db	0,		0,		0		; 00 -- (grey)
		db	H2,		H2,		H2		; 0E

		db	0,		0,		0		; 10 -- (grey)
		db	H2,		H2,		H2		; 1E

		db	R*MIX2/100,	PG*MIX2/100,	0		; 20 -- (gold)
		db	H,		H,		L4		; 2E

		db	R*MIX5/100,	PG*MIX2/100,	0		; 30 -- (yellow green)
		db	H3,		H,		L3		; 3E

		db	R*MIX5/100,	PG*MIX5/100,	0		; 40 -- (orange brown)
		db	H,		H,		L2		; 4E

		db	0,		PG,		0		; 50 -- (light green)
		db	L0,		H,		L0		; 5E

		db	R,		0,		0 		; 60 -- (pink)
		db	H,		L0,		L0		; 6E

		db	0,		PG*MIX2/100,	B*MIX4/100	; 70 -- (blue green)
		db	L,		H2,		H3		; 7E

		db	R*MIX2/100,	0,		B*MIX4/100	; 80 -- (purple)
		db	H,		L,		H2		; 8E

		db	0,		PG*MIX5/100,	B*MIX3/100	; 90 -- (turquoise)
		db	L1,		H2,		H		; 9E

		db	R*MIX4/100,	0,		B*MIX3/100	; A0 -- (lilac)
		db	H2,		L,		H		; AE

		db	0,		PG*MIX7/100,	B*MIX3/100	; B0 -- (light blue)
		db	L1,		H3,		H		; BE

		db	R*MIX5/100,	0,		B*MIX2/100	; C0 -- (purple-blue)
		db	H3,		L,		H		; CE

		db	0,		0,		B		; D0 -- *(blue)
		db	L0,		L0,		H		; DE

		db	0,		0,		0		; E0 -- (grey)
		db	H2,		H2,		H2		; EE

		db	0,		0,		0		; F0 -- (grey)
		db	H2,		H2,		H2		; FE


.DEND
.CODESEGMENT
