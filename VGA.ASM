;*
;* z26 linear graphics modes and palette setup
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; newpalette = 1

.data

OldVideoMode	db	0
PaletteCount	db	0

;*
;* palette coefficients
;* 
;* these numbers define relative brightness of the LUM values
;*

LUMGray db      0,      76      ; LUM 0
        db      21,     76
	db	35,	76
	db	47,	76
	db	57,	76
	db	65,	76
	db	71,	76
	db	76,	76	; LUM 7

LUMCoeff db      0,      92      ; LUM 0
	db	17,	92
	db	32,	92
	db	46,	92
	db	59,	92
	db	71,	92
	db	82,	92
	db	92,	92	; LUM 7
	
;*
;* definitions for unsaturated colors
;*

R = 34          ; main RGB values
G = 34          ; 
B = 34          ; 

;*
;* definitions for saturated colors
;*

H  = 63         ; Hi levels
L  = 44         ; Lo levels

NTSCPaletteTable label byte
IFNDEF newpalette

		db	0,		0,		0		; 00 -- (grey)
		db	H*95/100,	H*95/100,	H*95/100	; 0E

		db	R*50/100,	G*50/100,	0		; 10 -- (gold)
		db	H,		H,		L*60/100	; 1E

		db	R*85/100,	G*30/100,	0		; 20 -- (yellow orange)
		db	H*95/100,	H*80/100,	L*70/100	; 2E

		db	R*98/100,	G*20/100,	0		; 30 -- (yars' bright orange)
		db	H,		H*75/100,	L*85/100	; 3E

		db	R,		0,		0 		; 40 -- *(pink)
		db	H,		L*103/100,	L*103/100	; 4E

		db	R*90/100,	0,		B*70/100	; 50 -- (purple)
		db	H*95/100,	L,		H*90/100	; 5E

		db	R*55/100,	0,		B*90/100	; 60 -- (purple-blue)
		db	H*85/100,	L,		H		; 6E

		db	R*15/100,	0,		B*98/100	; 70 -- (atlantis right blinker blue)
		db	H*75/100,	L*103/100,	H		; 7E

		db	0,		0,		B		; 80 -- *(blue)
		db	L*95/100,	L*105/100,	H		; 8E

		db	0,		G*20/100,	B*93/100	; 90 -- (light blue)
		db	L*95/100,	H*80/100,	H		; 9E

		db	0,		G*35/100,	B*70/100	; A0 -- (atlantis turquoise)
		db	L*95/100,	H*90/100,	H		; AE

		db	0,		G*45/100,	B*35/100	; B0 -- (green-blue)
		db	L*95/100,	H,		H*85/100	; BE

		db	0,		G*47/100,	0		; C0 -- *(light green)
		db	L*105/100,	H,		L*105/100	; CE

		db	R*15/100,	G*42/100,	0		; D0 -- (yellow-green)
		db	H*80/100,	H,		L*95/100	; DE

		db	R*35/100,	G*38/100,	0		; E0 -- (orange-green)
		db	H*90/100,	H*95/100,	L*90/100	; EE

		db	R*50/100,	G*30/100,	0		; F0 -- (light-orange)
		db	H,		H*90/100,	L*80/100	; FE

ENDIF

PALPaletteTable db	0,		0,		0		; 00 -- (grey)
		db	H*95/100,	H*95/100,	H*95/100	; 0E

		db	0,		0,		0		; 10 -- (grey)
		db	H*95/100,	H*95/100,	H*95/100	; 1E

		db	R*95/100,	G*65/100,	0		; 20 -- (gold)
		db	H,		H*90/100,	L		; 2E

		db	R*50/100,	G*70/100,	0		; 30 -- (yellow green)
		db	H*85/100,	H,		L		; 3E

		db	R*85/100,	G*40/100,	0		; 40 -- (orange brown)
		db	H,		H*85/100,	L		; 4E

		db	0,		G*75/100,	B*15/100	; 50 -- (light green)
		db	L,		H,		H*80/100	; 5E

		db	R*85/100,	0,		B*15/100	; 60 -- (pink)
		db	H,		L,		H*80/100	; 6E

		db	0,		G*70/100,	B*70/100	; 70 -- (blue green)
		db	L,		H*95/100,	H*95/100	; 7E

		db	R*85/100,	0,		B*70/100	; 80 -- (purple)
		db	H*90/100,	L,		H*90/100	; 8E

		db	0,		G*45/100,	B*85/100	; 90 -- (turquoise)
		db	L*95/100,	H*90/100,	H		; 9E

		db	R*65/100,	0,		B*85/100	; A0 -- (lilac)
		db	H*85/100,	L,		H		; AE

		db	0,		G*25/100,	B*85/100	; B0 -- (light blue)
		db	L*95/100,	H*80/100,	H		; BE

		db	R*45/100,	0,		B*95/100	; C0 -- (purple-blue)
		db	H*80/100,	L,		H		; CE

		db	0,		0,		B		; D0 -- *(blue)
		db	L,		L,		H		; DE

		db	0,		0,		0		; E0 -- (grey)
		db	H*95/100,	H*95/100,	H*95/100	; EE

		db	0,		0,		0		; F0 -- (grey)
		db	H*95/100,	H*95/100,	H*95/100	; FE


SECAMPaletteTable db      0,   0,   0           ; black
                  db     33,  33, 255           ; blue
                  db    240,  60, 121           ; red
                  db    255,  60, 255           ; magenta
                  db    127, 255,   0           ; green
                  db    127, 255, 255           ; cyan
                  db    255, 255,  63           ; yellow
                  db    255, 255, 255           ; white
;                         R    G    B



;*
;* NTSC palette -- taken from blur_x_14_22_18_16.bmp
;*

_Accu_NTSC label byte

IFDEF newpalette			; *** <<< remove if we ever get enough space

	db	  0,   0,   0	; 24,  24,  24	; (00) -- grey
	db	 49,  49,  49
	db	 72,  72,  72
	db	 98,  98,  98
	db	121, 121, 121
	db	146, 146, 146
	db	171, 171, 171
	db	197, 197, 197
		
	db	 69,  92,   5	; (10) -- gold
	db	 82, 107,   8
	db	100, 124,  15
	db	116, 136,  24
	db	130, 147,  30
	db	144, 161,  38
	db	161, 176,  41
	db	176, 192,  45
	
	db	114,  64,   4	; (20) -- yellow orange
	db	127,  78,  11	
	db	143,  93,  19
	db	153, 112,  29
	db	167, 127,  41
	db	177, 138,  47
	db	192, 153,  52
	db	206, 172,  58
	
	db	144,  46,  22	; (30) -- yars' bright orange
	db	155,  60,  32
	db	167,  74,  45
	db	176,  91,  58
	db	186, 105,  72
	db	197, 117,  83
	db	212, 136,  96
	db	223, 149, 102
	
	db	148,  35,  58	; (40) -- pink
	db	162,  47,  71
	db	172,  61,  91
	db	180,  77, 105
	db	191,  92, 125
	db	203, 106, 141
	db	217, 120, 159
	db	229, 135, 174
	
	db	135,  29, 123	; (50) -- purple
	db	151,  42, 134
	db	163,  56, 151
	db	173,  70, 161
	db	184,  86, 174
	db	197, 101, 188
	db	211, 113, 203
	db	225, 128, 217
	
	db	106,  29, 172	; (60) -- blue purple
	db	122,  42, 182
	db	137,  56, 190
	db	153,  70, 197
	db	166,  88, 209
	db	183, 103, 219
	db	197, 119, 233
	db	212, 133, 241
	
	db	 65,  35, 195	; (70) -- atlantis right blinker blue
	db	 81,  48, 204
	db	 98,  63, 210
	db	117,  79, 216
	db	135,  95, 225
	db	154, 112, 235
	db	172, 129, 246
	db	190, 147, 254
	
	db	 38,  43, 186	; (80) -- blue
	db	 51,  57, 194
	db	 66,  72, 202
	db	 83,  90, 210
	db	101, 109, 219
	db	121, 131, 232
	db	140, 151, 242
	db	159, 168, 252
	
	db	 22,  55, 148	; (90) -- light blue
	db	 35,  68, 165
	db	 47,  86, 175
	db	 64, 104, 190
	db	 80, 127, 200
	db	 99, 151, 216
	db	115, 169, 229
	db	134, 186, 240
	
	db	 14,  70,  88	; (a0) -- atlantis turquoise
	db	 24,  84, 106
	db	 37, 103, 121
	db	 51, 122, 144
	db	 67, 145, 163
	db	 86, 167, 184
	db	103, 185, 199
	db	122, 200, 215
	
	db	 12,  79,  41	; (b0) -- green blue
	db	 22,  93,  56
	db	 34, 113,  70
	db	 48, 132,  89
	db	 64, 156, 111
	db	 83, 176, 139
	db	102, 194, 162
	db	121, 210, 181
	
	db	 15,  80,  13	; (c0) -- light green
	db	 24,  95,  24
	db	 39, 113,  38
	db	 54, 134,  53
	db	 70, 159,  69
	db	 91, 181,  89
	db	114, 198, 112
	db	134, 214, 133
	
	db	 21,  73,   2	; (d0) -- yellow green
	db	 34,  89,   8
	db	 48, 106,  19
	db	 65, 130,  31
	db	 85, 153,  45
	db	110, 178,  63
	db	135, 196,  81
	db	156, 212,  99
	
	db	 30,  56,   1	; (e0) -- orange green
	db	 45,  72,   5
	db	 62,  91,  14
	db	 84, 115,  26
	db	109, 141,  40
	db	135, 167,  57
	db	162, 188,  76
	db	184, 207,  97
	
	db	 46,  46,   1	; (f0) -- light orange
	db	 62,  62,   6
	db	 80,  79,  16
	db	104, 105,  27
	db	129, 127,  41
	db	156, 157,  59
	db	181, 181,  79
	db	199, 200,  99

ENDIF				; *** <<< remove if we ever get enough space
	

.code

TIASaveVideoMode:
	pushad
	mov	ah,0fh
	int	10h
	mov	[OldVideoMode],al
	popad
	ret

TIARestoreVideoMode:
	pushad
	mov	ah,0
	mov	al,[OldVideoMode]
	int	10h
	popad
	ret

;*
;* turn on graphics mode
;*

TIAGraphicMode:
	pushad
	mov	[_InTextMode],0

	mov	ax,013h			; switch to 320x200 VGA mode
	int	010h

	mov	[ReSyncFlag],1		; need to re-sync
	mov	[ModeX],0		; assume we're not in modex

;*
;* first choose a video mode if necessary
;*

	cmp	[_VideoMode],0ffh	; did user specify a video mode?
	jne	TGM_RemapVideo		;   yes, don't use defaults

;	cmp	[_MaxLines],204		; is _MaxLines above what mode 3 can handle?
;	ja	TGM_SetMX5		;   yes, use mode 5
;	mov	[_VideoMode],3		;   no,  use mode 3
;	jmp	TGM_RemapVideo
;
;TGM_SetMX5:	

	mov	[_VideoMode],5

;*
;* now remap video mode for PAL games if allowed
;*

TGM_RemapVideo:
	cmp	[_Use50Hz],0			; PAL modes allowed?
	jz	TGM_SetMaxLines			;   no

        cmp     [_PaletteNumber],2              ; SECAM mode ?
        je      TGM_RealRemapVideo              ;   yes
	cmp	[_PaletteNumber],1		; PAL mode ?
	jne	TGM_SetMaxLines			;   no

TGM_RealRemapVideo:
	movzx	si,[_VideoMode]
	mov	al,[Remap50Hz + si]
	mov	[_VideoMode],al

;*
;* set up max # of lines to display based on video mode
;*

TGM_SetMaxLines:
	movzx	si,[_VideoMode]
	cmp	si,3				; a linear video mode ?
	ja	RegularMaxLines			;   no
	test	[_HalfScreen],1			; half-screen mode ?
	jz	RegularMaxLines			;   no
	mov	[_MaxLines],256			;   yes, force 256 lines
	jmp	SetupCFirst
	
RegularMaxLines:	
	shl	si,1
	mov	si,[MaxLineTable + si]
	mov	[_MaxLines],si

;*
;* set up CFirst (first line to display)
;*

SetupCFirst:
	mov	dx,[_UserCFirst]
	mov	[_CFirst],dx
	cmp	[_UserCFirst],0ffffh		; did user specify a line number?
	jne	TGM_TestUltimate		;   yes, don't override
	mov	dx,[_DefaultCFirst]
	mov	[_CFirst],dx
	cmp	[_DefaultCFirst],0ffffh		; does game have a recommended starting line?
	jne	TGM_TestUltimate		;   yes, use it

	movzx	si,[_VideoMode]
        cmp     [_PaletteNumber],2              ; SECAM mode ?
        je      RemapStartLine                  ;   yes
        cmp     [_PaletteNumber],1              ; PAL mode ?
        jne     DontRemapStartLine              ;   no
RemapStartLine:
	movzx	si,[Remap50Hz + si]		;   yes, remap in case PAL in NTSC mode
DontRemapStartLine:
	shl	si,1
	mov	si,[StartLineTable + si]

        cmp     [_PaletteNumber],0              ; NTSC game ?
        je      DontAdjust60Hz                  ;   yes, don't shift screen
        cmp     [_PaletteNumber],0ffh            ; no palette specified (NTSC is default)
        je      DontAdjust60Hz                  ;   yes, don't shift screen
        cmp     [_Use50Hz],1                    ; 50Hz modes are larger
        je      DontAdjust60Hz                  ;   so adjust screen postion
        add     si,7                            ;   for 60Hz modes
DontAdjust60Hz:
	mov	[_CFirst],si			; use the standard default

;*
;* adjust CFirst based on game size
;*

TGM_TestUltimate:
;        cmp     [_MaxLines],480                 ; in a very tall video mode?
        cmp     [_MaxLines],400                 ; in a very tall video mode?
	jb	TGM_Done			;   no
	cmp	[_CFirst],0			; frogpond or pharhcrs ?
	jz	TGM_Done			;   yes
	mov	[_CFirst],1			;   no, this is ultimate reality mode

TGM_Done:
	mov	dx,[_CFirst]
	mov	[OldCFirst],dx			; remember starting line for homing the display

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
	mov	si,offset NTSCPaletteTable
	cmp	[_PaletteNumber],0	; user specify palette 0 ?
	je	GPUseNTSC		;   yes, use NTSC
	cmp	[_PaletteNumber],1	; user specify palette 1 ?
	je	GPUsePAL		;   yes, use PAL
        cmp     [_PaletteNumber],2      ; user specify palette 2 ?
        je      GPUseSECAM              ;   yes, use SECAM
        cmp     [_PaletteNumber],9
        je      xGPUseNTSC              ; palette 9 is the *classic* NTSC
	cmp	[_DefaultCFirst],0ffffh	; is there a default starting line ?
	je	GPUseNTSC		;   no, use NTSC
	cmp	[_DefaultCFirst],50	; starting line < 50 ?
	jb	GPUseNTSC		;   no, use NTSC

GPUsePAL:
	mov	si,offset PALPaletteTable
	mov	[_PaletteNumber],1	; mark PAL mode
xGPUseNTSC:
        mov     di,offset _PCXPalette
	mov	[PaletteCount],0	; do 16 colors
PaletteLoop:				; <-- for each color
	xor	ecx,ecx			; initialize 8 values of LUM
LUMLoop:
	mov	dx,3			; do 3 values of RGB
RGBLoop:
	movzx	ax,byte ptr 3[si]	; [RHi]
	movzx	bx,byte ptr 0[si]	; [RLo]
	sub	ax,bx			; al = RHi - RLo

	cmp	[_PaletteNumber],1
	je	doLUMNormal
	cmp	[PaletteCount],0
	jz	doLUMGray

doLUMNormal:
	mov	bl,[LUMCoeff + ecx*2]
	mul	bl			; multiply by first coefficient
	mov	bl,[LUMCoeff + 1 + ecx*2]
	div	bl			; divide by second coefficient
	jmp	LUMDone

doLUMGray:
	mov	bl,[LUMGray + ecx*2]
	mul	bl			; multiply by first coefficient
	mov	bl,[LUMGray + 1 + ecx*2]
	div	bl			; divide by second coefficient

LUMDone:
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
	add	si,6			;	yes, to next RGB set (color)
	inc	PaletteCount
	cmp	[PaletteCount],16	; done 16 colors yet ?
	jnz	PaletteLoop		;   not yet

        jz      HardwareStuff
GPUseSECAM:
        mov     di,offset _PCXPalette
        mov     dx, 16                  ; do 16 colours
SLoop1:
        mov     bx,0                    
SLoop2:
        mov     al,SECAMPaletteTable[bx] ; copy RGB values directly
        mov     [di],al
        inc     di
        inc     bx
        cmp     bx,24                   ; done 8 lums * 3 RGB bytes yet
        jne     SLoop2                  ;   not yet
        dec     dx                      ; done 16 colours yet ?
        jnz     SLoop1                  ;   not yet
        jmp	HardwareStuff
        

;*
;* set up the accurate NTSC palette
;*

GPUseNTSC:

IFNDEF newpalette
	jmp	xGPUseNTSC		; *** <<< remove if we ever get enough space
ENDIF
	mov	si,offset _Accu_NTSC
GPdopalette:
        mov     di,offset _PCXPalette
        mov	cx,16*8*3
AccuLoop:
	mov	al,[si]
	mov	[di],al
	inc	si
	inc	di
	dec	cx
	jnz	AccuLoop
        
        

HardwareStuff:

; continue with hardware stuff

	call	TIAPalette		; set up the palette

;        mov     ax,0a000h
        mov     ax,[_ScreenSeg]
	mov	gs,ax			; point GS to VGA area

        cmp     [_VideoMode],0          ; doing offbeat video modes ?
        jnz     RegularOffBeat          ;        yes
        popad
        ret

RegularOffBeat:
	cmp	[_VideoMode],3		; doing Trixter 60Hz (mode 1, 2 or 3) ?
	jbe	DoTrixter60Hz		;	yes
	call	ModeXInit		;   no, do modex
	popad
	ret

DoTrixter60Hz:
	call	Trixter60Hz
	popad
	ret


;*
;* blank the remainder of the display each frame
;*

TIABlank:
	push	ax
	push	bx
	push	di
        push    gs
        mov     ax,[_ScreenSeg]
        mov     gs,ax
	xor	eax,eax
        mov     di,[DisplayPointer]
	cmp	di,30000
	jb	TIABRet
	mov	bx,[_MaxLines]
;        imul    bx,320
        imul    bx,160
TIABLoop:
	cmp	di,bx			; (64000) reached end of display area?
	jae	TIABRet			;	   yes, done
	mov	gs:[di],eax
	add	di,4
	jmp	TIABLoop

TIABRet:
        mov     [DisplayPointer],di
        pop     gs
        pop	di
	pop	bx
	pop	ax
TBRet:	ret


;*
;* return to text mode
;*

TIATextMode:
	cmp	[_InTextMode],0
	jz	TIATextDoIt
	ret

TIATextDoIt:
	mov	[_InTextMode],1
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

	cli

	mov	dx,CRTSEQ
	mov	ax,0100h		; synchronous reset
	out	dx,ax			; asserted
	
	mov	dx,CRTMISC		; misc output

	cmp	[_VideoMode],1
	jne	Tr60a
	mov	al,063h			; mode 1 -- 63=squished maybe
	jmp	Tr60b			;		 e3=squished definitely

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
	VidOut	CRTC,	000h, 05fh	; horizontal total
	VidOut	CRTC,	004h, 054h	; horizontal retrace start
	VidOut	CRTC,	005h, 080h	; horizontal retrace end
	jmp	Tr60d
					; * mode 2 or 3 *
Tr60c:	VidOut	CRTC,   000h, 06ch	; horizontal total
	VidOut	CRTC,	004h, 05bh	; horizontal retrace start
	VidOut	CRTC,	005h, 087h	; horizontal retrace end

Tr60d:	cmp	[_VideoMode],3
	je	Tr60e
					; * mode 1 or 2 *
	VidOut	CRTC,	012h, 08fh	; <8f> vertical display enable end
	VidOut	CRTC,	015h, 090h	; <90> vertical blanking start
	jmp	Tr60f

Tr60e:					; * mode 3 *
	VidOut	CRTC,	012h, 097h	; <8f> vertical display enable end
	VidOut	CRTC,	015h, 098h	; <90> vertical blanking start

Tr60f:	VidOut	CRTC,   001h, 04fh	; horizontal display enable end
	VidOut	CRTC,	002h, 050h	; horizontal blanking start
	VidOut	CRTC,	003h, 082h	; horizontal blanking end
	VidOut	CRTC,	006h, 00ah	; vertical total
	VidOut	CRTC,	007h, 03eh	; overflow
	VidOut	CRTC,	008h, 000h	; preset row scan
	VidOut	CRTC,	009h, 041h	; maximum scan line
	VidOut	CRTC,	010h, 0c2h	; (ba) vertical retrace start
	VidOut	CRTC,	011h, 084h	; (8c) vertical retrace end
	VidOut	CRTC,	013h, 028h	; offset (logical line width)
	VidOut	CRTC,	014h, 040h	; underline location
	VidOut	CRTC,	016h, 008h	; vertical blanking end
	VidOut	CRTC,	017h, 0a3h	; mode control

	VidOut	CRTSEQ, 001h, 001h	; clocking mode
	VidOut	CRTSEQ, 003h, 000h	; map select
	VidOut	CRTSEQ, 004h, 00eh	; memory mode

	VidOut	CRTGFX, 005h, 040h	; graphics mode
	VidOut	CRTGFX, 006h, 005h	; miscellaneous

	sti

	ret

; *****************************************************************************
;
;			  Set the VGA Palette up
;
; *****************************************************************************

TIAPalette:
        mov     di,offset _PCXPalette
	mov	cl,0
TIAPalLoop:
	mov	al,255
	mov	dx,03c6h
	out	dx,al
	add	dx,2
	mov	al,cl
	out	dx,al
	inc	dx
	mov	al,0[di]
	shr	al,2
	out	dx,al
	mov	al,1[di]
	shr	al,2
	out	dx,al
	mov	al,2[di]
	shr	al,2
	out	dx,al
	add	di,3
	inc	cl
	cmp	cl,128
	jne	TIAPalLoop
	ret


