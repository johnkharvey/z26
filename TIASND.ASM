; tiasnd.asm -- z26 sound generation routines
;               based on TIASound (c) 1996-1997 by Ron Fries

; April 8, 1998 -- first release


; This library is free software; you can redistribute it and/or modify it
; under the terms of version 2 of the GNU Library General Public License.


;*
;* generate a sequence of pseudo-random bits 511 bits long
;* by emulating a 9-bit shift register with feedback taps at
;* positions 5 and 9.
;*

; Reference: The Art of Electronics by Horowitz and Hill (1st ed.)
;            pages 438-441

_ShiftRegister9	proc	near
	mov	ax,[sreg]
	and	ax,1		; bit 9 (register output & return val)
	mov	dx,[sreg]
	and	dx,16
	shr	dx,4		; position bit 5 at bottom
	xor	dx,ax		; xor with bit 9 = new bit 1
	shr	[sreg],1	; shift the register
	shl	dx,8		; position the feedback bit
	or	[sreg],dx	; or it in
	ret	
_ShiftRegister9	endp

.CEND
.DATASEGMENT

sreg	dw	1		; initialize shift register to non-zero val

.DEND
.CODESEGMENT

;*
;* handle the power-up initialization functions
;* these functions should only be executed on a cold-restart
;*

_Tia_sound_init	proc	near
	push	bp
	mov	bp,sp
	mov	ax,[bp+4]
	mov	[_sample_freq],ax
	mov	ax,[bp+6]
	mov	[_playback_freq],ax

; fill the 9-bit poly with random bits

	xor	bx,bx
TSI_1:	call	_ShiftRegister9
	mov	Bit9[bx],al
	inc	bx
	cmp	bx,511
	jb	TSI_1

; calculate the sample 'divide by N' value based on the playback freq

	movzx	eax,[_sample_freq]
	shl	eax,8
	movzx	ebx,[_playback_freq]
	xor	edx,edx
	div	ebx			; ax = (_sample_freq<<8)/_playback_freq
	mov	[Samp_n_max],ax
	mov	[Samp_n_cnt],0

;	xor	eax,eax			; initialize the local globals
;	mov	word ptr  Outvol,ax
;	mov	word ptr  Div_n_cnt,ax
;	mov	word ptr  Div_n_max,ax
;	mov	word ptr  AUDC,ax
;	mov	word ptr  AUDF,ax
;	mov	word ptr  AUDV,ax
;	mov	word ptr  P4,ax
;	mov	word ptr  P5,ax
;	mov	dword ptr P9,eax

	pop	bp
	ret	
_Tia_sound_init	endp

.CEND
.DATASEGMENT

_new_val	dw	0

prev_sample	dw	0
next_sample	db	0

.DEND
.CODESEGMENT

ALIGN_ENTRY

;*
;* update TIA sound registers
;*

_Update_tia_sound	proc	near
	push	bp
	mov	bp,sp
	mov	bx,[bp+4]	; addr
	mov	al,[bp+6]	; val
	sub	bx,21		; offset to AUDC
	cmp	bx,5
	ja	UTS_Done	; not an audio register
	shl	bx,1
	jmp	cs:UTS_Jumptab[bx] ; see which channel has changed
				   ; and update the register

UTS_Jumptab	label	word
	dw	UTS_J0
	dw	UTS_J1
	dw	UTS_J2
	dw	UTS_J3
	dw	UTS_J4
	dw	UTS_J5

UTS_J0:	and	al,15
	mov	[AUDC],al
	jmp	UTS_Chan0

UTS_J1:	and	al,15
	mov	[AUDC+1],al
	jmp	UTS_Chan1

UTS_J2:	and	al,31
	mov	[AUDF],al
	jmp	UTS_Chan0

UTS_J3:	and	al,31
	mov	[AUDF+1],al
	jmp	UTS_Chan1

UTS_J4:	and	al,15
	shl	al,3
	mov	[AUDV],al

UTS_Chan0:
	mov	bx,0
	jmp	UTS_RegSet

UTS_J5:	and	al,15
	shl	al,3
	mov	[AUDV+1],al

UTS_Chan1:
	mov	bx,1

; the output value has changed

UTS_RegSet:
	cmp	AUDC[bx],0		; AUDC value of zero is a special case
	jne	UTS_rs1
	mov	[_new_val],0		; indicate clock is zero so ...
	mov	al,AUDV[bx]		; ... no processing will occur
	mov	Outvol[bx],al		; and set output to selected volume
	jmp	UTS_rs2

UTS_rs1:movzx	ax,AUDF[bx]		; otherwise calc the 'div by N' value
	inc	ax
	mov	[_new_val],ax
	movzx	ax,AUDC[bx]
	and	ax,12
	cmp	ax,12
	jne	UTS_rs2			; if bits 2 and 3 are set ...
	mov	ax,[_new_val]		; ... multiply by three
	imul	ax,3
	mov	[_new_val],ax

UTS_rs2:movzx	ax,Div_n_max[bx] 	; only reset channels that have changed
	cmp	ax,[_new_val]
	je	UTS_Done
	mov	al,byte ptr _new_val
	mov	Div_n_max[bx],al 	; reset 'div by N' counters
	cmp	Div_n_cnt[bx],0
	je	UTS_rs3			; if channel is now volume only ...
	cmp	[_new_val],0
	jne	UTS_Done		; ... or was volume only ...

UTS_rs3:mov	al,byte ptr _new_val
	mov	Div_n_cnt[bx],al 	; ... reset the counter 
				 	;     (otherwise complete previous)

UTS_Done:
	pop	bp
	ret	

_Update_tia_sound	endp


;*
;* Fill the output buffer with the sound output based on the tia chip parameters.
;*

ALIGN_ENTRY

_Tia_process	proc	near
	push	bp
	mov	bp,sp
	mov	ax,[bp+4]
	mov	[buffer],ax
	mov	ax,[bp+6]
	mov	[n],ax
;	mov	[prev_sample],0
;	mov	[next_sample],0

TP_ProcessLoop:

	xor	ebp,ebp			; process channel 0 first

TP_ProcessChannel:

audc=	cl	; define a register var

	mov	audc,[AUDC + bp]

	cmp	[Div_n_cnt + bp],1	; if div by N counter can count down ...
	jbe	TP_1
	dec	[Div_n_cnt + bp]	; ... decrement ...
	jmp	TP_Ch0done		; ... and do next channel

TP_1:	cmp	[Div_n_cnt + bp],1	; otherwise if at bottom ...
	jne	TP_Ch0done
	mov	al,[Div_n_max + bp]	; ... reset the counter
	mov	[Div_n_cnt + bp],al

	inc	[P5 + bp]		; P5 channel has multiple uses ...
	cmp	[P5 + bp],31		; ... so we inc it here
	jne	TP_2
	mov	[P5 + bp],0

; check clock modifier for a clock tick

TP_2:	test	audc,2			; if we're using pure tones ...
	je	TP_4
	test	audc,1			; ... or we're using Div31 ...
	jne	TP_3
	movzx	bx,[P5 + bp]
	cmp	Div31[bx],0		; ... and the Div31 bit is set ...
	jne	TP_4
TP_3:	test	audc,1			; ... or were using poly5 ...
	je	TP_Ch0done
	movzx	bx,[P5 + bp]
	cmp	Bit5[bx],0		; ... and the poly5 bit is set
	je	TP_Ch0done

TP_4:	test	audc,4			; if pure modified clock selected ...
	je	TP_6
	cmp	[Outvol + bp],0		; ... toggle the output
	je	TP_VolumeOn
	jmp	TP_VolumeOff

TP_6:	test	audc,8			; check for p5/p9
	je	TP_11
	cmp	audc,8			; if p9 ...
	jne	TP_9
	inc	[P9 + 2*ebp]		; ... inc the p9 counter ...
	cmp	[P9 + 2*ebp],511
	jne	TP_7
	mov	[P9 + 2*ebp],0
TP_7:	mov	bx,[P9 + 2*ebp]
	cmp	Bit9[bx],0		; ... and set the output bit
	je	TP_VolumeOff
	jmp	TP_VolumeOn

TP_9:	movzx	bx,[P5 + bp]		; not p9, must be p5 ...
	cmp	Bit5[bx],0		; ... set the output bit
	je	TP_VolumeOff
	jmp	TP_VolumeOn

TP_11:	inc	[P4 + bp]		; must be p4, inc p4 counter ...
	cmp	[P4 + bp],15
	jne	TP_12
	mov	[P4 + bp],0
TP_12:
	movzx	bx,[P4 + bp]
	cmp	Bit4[bx],0		; ... and set the output bit
	je	TP_VolumeOff

TP_VolumeOn:
	mov	al,[AUDV + bp]
	mov	[Outvol + bp],al
	jmp	TP_Ch0done

TP_VolumeOff:
	mov	[Outvol + bp],0

TP_Ch0done:
	
	cmp	bp,1			; done both channels?
	je	TP_ChannelsDone		;   yes
	mov	bp,1
	jmp	TP_ProcessChannel	;   no, do channel 1 now

TP_ChannelsDone:

	sub	[Samp_n_cnt],256	; decrement sample count
					; (256 since lower byte is 
					;  fractional part)
	cmp	[Samp_n_cnt],256	; if count has reached zero ...
	jae	TP_ProcessLoop
	mov	ax,[Samp_n_max]		; ... adjust the sample counter
	add	[Samp_n_cnt],ax

	mov	al,[Outvol+0]
	add	al,[Outvol+1]		; sum the channels

	cmp	[_dsp],0		; doing digital signal processing ?
	je	TP_ProcessDone		;   no, just store it
	mov	[next_sample],al	;   yes, take edge off square wave
	xor	ah,ah
	add	ax,[prev_sample]
	shr	ax,1
	mov	[prev_sample],ax	; dsp=2, scaled moving average
	cmp	[_dsp],1
	jne	TP_ProcessDone
	movzx	dx,[next_sample]	; dsp=1, simple moving average
	mov	[prev_sample],dx

TP_ProcessDone:
	mov	bx,[buffer]
	mov	[bx],al			; put byte in the buffer
	inc	[buffer]		; bump buffer pointer

	dec	[n]			; one less byte to do
;	cmp	[n],0
	jnz	TP_ProcessLoop

	pop	bp
	ret	
_Tia_process	endp

.CEND
.DATASEGMENT

; Initialze the bit patterns for the polynomials.

; The 4bit and 5bit patterns are the identical ones used in the tia chip.
; Though the patterns could be packed with 8 bits per byte, using only a
; single bit per byte keeps the math simple, which is important for
; efficient processing.

Bit4	db	1,1,0,1,1,1,0,0,0,0,1,0,1,0,0
Bit5	db	0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0,1,0,0,0,0,1

; The 'Div by 31' counter is treated as another polynomial because of
; the way it operates.  It does not have a 50% duty cycle, but instead
; has a 13:18 ratio (of course, 13+18 = 31).  This could also be
; implemented by using counters.

Div31	db	0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0

; Rather than have a table with 511 entries, we use a pseudo-random number
; generator.

;Bit9		db	511 dup (?)	;* moved to memory.asm

; The sample output is treated as another divide by N counter.
; For better accuracy, the Samp_n_cnt has a fixed binary decimal point
; which has 8 binary digits to the right of the decimal point.

Samp_n_cnt	dw	0
Samp_n_max	dw	0

P4		db	2 dup (0)
P5		db	2 dup (0)
P9		dw	2 dup (0)
AUDC		db	2 dup (0)
AUDF		db	2 dup (0)
AUDV		db	2 dup (0)
n		dw	0
val		db	0
chan		db	0
addr		dw	0
Outvol		db	2 dup (0)
buffer		dw	0
Div_n_cnt 	db	2 dup (0)
Div_n_max 	db	2 dup (0)
_sample_freq	dw	0
_playback_freq	dw	0


.DEND
.CODESEGMENT
