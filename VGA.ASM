;*
;* z26 linear graphics modes and palette setup
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

newpalette = 1

.data

OldVideoMode	db	0

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
	cmp	[_PaletteNumber],0	; user specify palette 0 ?
	je	GPUseNTSC		;   yes, use NTSC
	cmp	[_PaletteNumber],1	; user specify palette 1 ?
	je	GPUsePAL		;   yes, use PAL
        cmp     [_PaletteNumber],2      ; user specify palette 2 ?
        je      GPUseSECAM              ;   yes, use SECAM
	cmp	[_DefaultCFirst],0ffffh	; is there a default starting line ?
	je	GPUseNTSC		;   no, use NTSC
	cmp	[_DefaultCFirst],50	; starting line < 50 ?
	jb	GPUseNTSC		;   no, use NTSC
	jmp	GPUseNTSC		; else use NTSC


GPUseSECAM:
	call	_SECAM_Palette
	jmp	HardwareStuff

GPUseNTSC:
	call	_NTSC_Palette
	jmp	HardwareStuff

GPUsePAL:
	call	_PAL_Palette
	jmp	HardwareStuff        
        

; continue with hardware stuff

HardwareStuff:
	call	TIAPalette		; set up the hardware palette

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


