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

	cmp	[_VideoMode],0		; doing ModeX ?
	jz	GRRet			;   no

GRV1:	cmp	[_VideoMode],3		; doing Trixter 60Hz (mode 1, 2 or 3) ?
	ja	GRRet			;   no
	call	Trixter60Hz		;   yes
	mov	[_VideoMode],0		; pretend we're mode 13
	jmp	GRRet

GRRet:	mov	[_VideoMode],0		; any other mode, pretend mode 0	
	ret

TIATextMode:
	mov	ah,0			; switch to 80x25 colour mode
	mov	al,3
	int	010h
	mov	ah,1			; turn cursor back on
	mov	cx,0B0Ch
	int	010h
	ret

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


; setup a 60Hz 320 by 200 chained video mode
; courtesy of Jim Leonard (Trixter / Hornet)

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

					; atlantis blue blinker
		db   11,    8,   33	; 0 1 1 1 -- 0 (blue <slightly purplish>)
		db   45,   45,   60	; 0 1 1 1 -- 7 (was 40,45,60 for atlantis)
;		db   55,   40,   63	; 0 1 1 1 -- 7 (was 55,40,63 for atlantis)

		db    8,    8,   35	; 1 0 0 0 -- 0 (blue)
		db   35,   45,   63	; 1 0 0 0 -- 7 (was 45, 45, 63 for polepos)

		db    6,    6,   25	; 1 0 0 1 -- 0 (light blue)
		db   40,   50,   63	; 1 0 0 1 -- 7 (was 50, 50, 63 for polepos)

		db    0,   10,   18	; 1 0 1 0 -- 0 (turquoise)(0,8,20 for atlantis)
		db   40,   55,   63	; 1 0 1 0 -- 7

		db    0,   12,    8	; 1 0 1 1 -- 0 (green-blue)
		db   40,   63,   55	; 1 0 1 1 -- 7

					; atlantis light green (2nd from bottom)
		db    4,   12,    4	; 1 1 0 0 -- 0 (green)
		db   30,   63,   30	; 1 1 0 0 -- 7 (was 50,63,50 for atlantis)
;		db   50,   63,   50	; 1 1 0 0 -- 7 (was 40,60,60 for atlantis)

		db   10,   15,    0	; 1 1 0 1 -- 0 (yellow-green)
		db   50,   63,   35	; 1 1 0 1 -- 7

		db   15,   25,    0	; 1 1 1 0 -- 0 (orange-green)
		db   55,   63,   30	; 1 1 1 0 -- 7

		db   20,   10,    0	; 1 1 1 1 -- 0 (light-orange)
		db   63,   50,   30	; 1 1 1 1 -- 7


.DEND
.CODESEGMENT
