; tiasnd.asm -- z26 sound generation routines
;               based on TIASound (c) 1996-1997 by Ron Fries

; 04-08-98 -- first release
; 04-19-99 -- added sound queue

;*
;* generate a sequence of pseudo-random bits 511 bits long
;* by emulating a 9-bit shift register with feedback taps at
;* positions 5 and 9.
;*

; Reference: The Art of Electronics by Horowitz and Hill (1st ed.)
;            pages 438-441

; note:  bits are numbered left to right with bit 9 being the lsb

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

.data

sreg	dw	1		; initialize shift register to non-zero val

.data

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

SoundPointer	dw	0
SoundByte	db	0,0		; pad to word just in case

P4		db	2 dup (0)
P5		db	2 dup (0)
P9		dw	2 dup (0)
AUDC		db	2 dup (0)
AUDF		db	2 dup (0)
AUDV		db	2 dup (0)
Outvol		db	2 dup (0)
Div_n_cnt 	db	2 dup (0)
Div_n_max 	db	2 dup (0)


SQ_MAX = 1024

;SoundQ		db	(SQ_MAX + 2) dup (?)
SQ_Input	dw	offset SoundQ	; point to next avail byte for storing
SQ_Output	dw	offset SoundQ	; point to next avail byte for fetching
SQ_Count	dw	0

SQ_Top		dw	offset SoundQ + SQ_MAX + 1

_sample_freq	dw	0
_playback_freq	dw	0

_new_val	dw	0

prev_sample	dw	0
next_sample	db	0


.code


;*
;* handle the power-up initialization functions
;* these functions should only be executed on a cold-restart
;*

_Tia_sound_init	proc	near

	xor	bx,bx			; fill the 9-bit poly with random bits
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

	xor	eax,eax			; initialize the local globals
	mov	word ptr  Outvol,ax
	mov	word ptr  Div_n_cnt,ax
	mov	word ptr  Div_n_max,ax
	mov	word ptr  AUDC,ax
	mov	word ptr  AUDF,ax
	mov	word ptr  AUDV,ax
	mov	word ptr  P4,ax
	mov	word ptr  P5,ax
	mov	dword ptr P9,eax

	mov	[SQ_Input],offset SoundQ
	mov	[SQ_Output],offset SoundQ
	mov	[SQ_Count],0
	mov	[SQ_Top],offset SoundQ + SQ_MAX + 1

	ret	

_Tia_sound_init	endp


;*
;* update TIA sound registers
;*

_Update_tia_sound	proc	near

	pushf
	cli

	jmp	cs:[UTS_Jumptab - 42 + 2*esi]	; and update the register
						; note: base register offset is 21 within TIA

UTS_Jumptab	label	word
	dw	UTS_AUDC0
	dw	UTS_AUDC1
	dw	UTS_AUDF0
	dw	UTS_AUDF1
	dw	UTS_AUDV0
	dw	UTS_AUDV1

UTS_AUDC0:
	and	al,15
	mov	[AUDC],al
	jmp	UTS_Chan0

UTS_AUDC1:
	and	al,15
	mov	[AUDC+1],al
	jmp	UTS_Chan1

UTS_AUDF0:
	and	al,31
	mov	[AUDF],al
	jmp	UTS_Chan0

UTS_AUDF1:
	and	al,31
	mov	[AUDF+1],al
	jmp	UTS_Chan1

UTS_AUDV0:
	and	al,15
	shl	al,3
	mov	[AUDV],al

UTS_Chan0:
	xor	bx,bx
	jmp	UTS_RegSet

UTS_AUDV1:
	and	al,15
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

UTS_rs1:
	movzx	ax,AUDF[bx]		; calc the 'div by N' value
	inc	ax
	mov	[_new_val],ax
	mov	al,AUDC[bx]
	and	al,12
	cmp	al,12
	jne	UTS_rs2			; if bits 2 and 3 are set ...
	mov	ax,[_new_val]		; ... multiply by three
	add	ax,ax
	add	[_new_val],ax

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
	popf
	ret	

_Update_tia_sound	endp


;*
;* macro to put byte in al in the sound queue
;* always make sure SQ_Count < SQ_MAX before calling
;*

SQ_Store macro
local done

	mov	si,[SQ_Input]
	mov	[si],al
	inc	si
	inc	[SQ_Count]
	cmp	si,[SQ_Top]
	jb	done
	mov	si,offset SoundQ
done:
	mov	[SQ_Input],si

	endm

;*
;* macro to fetch byte from sound queue into al
;* always make sure SQ_Count nonzero before calling
;*

SQ_Fetch macro
local done

	dec	[SQ_Count]
	mov	si,[SQ_Output]
	mov	al,[si]
	inc	si
	cmp	si,[SQ_Top]
	jb	done
	mov	si,offset SoundQ
done:
	mov	[SQ_Output],si

	endm


;*
;* Process a sound interrupt
;*

_Tia_process	proc	near

	pushf
	cli

	mov	cx,BUF_SIZE/2		; # of bytes

	mov	si,[_DMABuf]
	add	si,[_DMABufToLoad]	; address of buffer to fill
	mov	[SoundPointer],si

SoundFillLoop:
	cmp	[SQ_Count],0		; anything in the sound queue?
	jz	RemainingSoundBytes	;   no, go generate
	SQ_Fetch			;   yes, get a byte
	mov	si,[SoundPointer]	
	mov	[si],al			; put it in soundblaster buffer
	inc	[SoundPointer]
	dec	cx			; more room in soundblaster buffer?
	jz	SoundBufferFull		;   no, we're done
	jmp	SoundFillLoop		;   yes, see if more bytes in queue

RemainingSoundBytes:
	call	_FillSoundBuffer	; generate sound into the soundblaster buffer

SoundBufferFull:
	popf
	ret

_Tia_process endp


;*
;* put a byte in the sound queue
;*

_QueueSoundByte proc near

	cmp	[_quiet],0		; doing sound at all?
	jnz	DontQueueAnything	;   no
	cmp	[_Sb_init],0		; SoundBlaster initialized ?
	jz	DontQueueAnything	;   no
	cmp	[_SoundMode],2		; forcing slow speed ?
	jne	QueueIt			;   no
	test	[ScanLine],1		; on an odd scan line?
	jz	DontQueueAnything	;   no, skip this line

QueueIt:
	pushf				;   yes, save state of interrupts
	cli

	cmp	[SQ_Count],SQ_MAX	; sound queue already full?
	jae	SoundQueueFull		;   yes, don't queue anything
	mov	cx,1
	mov	[SoundPointer],offset SoundByte
	call	_FillSoundBuffer	;   no, generate a single sound byte
	mov	al,[SoundByte]
	SQ_Store			; put it in the sound queue

SoundQueueFull:
	popf				; restore state of interrupts

DontQueueAnything:
	ret

_QueueSoundByte endp


;*
;* Fill the output buffer with the sound output based on the TIA chip parameters.
;*

inc_mod macro	op1,op2
local done

	inc	[op1]
	cmp	[op1],op2
	jne	done
	mov	[op1],0
done:
	endm


_FillSoundBuffer proc near
	pushf
	cli

	movzx	dx,[_dsp]		; do digital signal processing flag

TP_ProcessLoop:

	xor	edi,edi			; process channel 0 first

TP_ProcessChannel:
	cmp	[Div_n_cnt + di],1	; if div by N counter can count down ...
	jb	TP_Ch0done		;   zero is special case, means AUDC==0 -- fast exit
	je	TP_1
	dec	[Div_n_cnt + di]	; ... decrement ...
	jmp	TP_Ch0done		; ... and do next channel

TP_1:	mov	al,[Div_n_max + di]	; otherwise reset the counter and process this channel
	mov	[Div_n_cnt + di],al

	movzx	esi,[AUDC + di]		; AUDC = index into branch table

	inc_mod	P5+di,31		; P5 channel has multiple uses (Div31 & P5), inc it here
	movzx	bx,[P5 + di]

	jmp	cs:[AUDC_Jumptab + esi*2] ; process sound changes based on AUDC

AUDC_Jumptab	label	word	; HEX  D3 D2 D1 D0    Clock Source    Clock Modifier    Source Pattern
				; --- -------------  --------------  ----------------  ----------------
	dw	TP_Ch0done	;  0    0  0  0  0    3.58 MHz/114 ->  none  (pure)  ->      none
	dw	TP_Poly4	;  1    0  0  0  1    3.58 MHz/114 ->  none  (pure)  ->   4-bit poly
	dw	TP_Div31_Poly4	;  2    0  0  1  0    3.58 MHz/114 ->  divide by 31  ->   4-bit poly
	dw	TP_Poly5_Poly4	;  3    0  0  1  1    3.58 MHz/114 ->   5-bit poly   ->   4-bit poly
	dw	TP_Pure		;  4    0  1  0  0    3.58 MHz/114 ->  none  (pure)  ->   pure  (~Q)
	dw	TP_Pure		;  5    0  1  0  1    3.58 MHz/114 ->  none  (pure)  ->   pure  (~Q)
	dw	TP_Div31_Pure	;  6    0  1  1  0    3.58 MHz/114 ->  divide by 31  ->   pure  (~Q)
	dw	TP_Poly5_Pure	;  7    0  1  1  1    3.58 MHz/114 ->   5-bit poly   ->   pure  (~Q)
	dw	TP_Poly9	;  8    1  0  0  0    3.58 MHz/114 ->  none  (pure)  ->   9-bit poly
	dw	TP_Poly5	;  9    1  0  0  1    3.58 MHz/114 ->  none  (pure)  ->   5-bit poly
	dw	TP_Div31_Poly5	;  A    1  0  1  0    3.58 MHz/114 ->  divide by 31  ->   5-bit poly
	dw	TP_Poly5_Poly5	;  B    1  0  1  1    3.58 MHz/114 ->   5-bit poly   ->   5-bit poly
	dw	TP_Pure		;  C    1  1  0  0    1.19 MHz/114 ->  none  (pure)  ->   pure  (~Q)
	dw	TP_Pure		;  D    1  1  0  1    1.19 MHz/114 ->  none  (pure)  ->   pure  (~Q)
	dw	TP_Div31_Pure	;  E    1  1  1  0    1.19 MHz/114 ->  divide by 31  ->   pure  (~Q)
	dw	TP_Poly5_Pure	;  F    1  1  1  1    1.19 MHz/114 ->   5-bit poly   ->   pure  (~Q)


TP_Div31_Pure:
	cmp	Div31[bx],0		; if div 31 bit set ...
	jnz	TP_Pure			; ... do pure
	jmp	TP_Ch0done

TP_Poly5_Pure:
	cmp	Bit5[bx],0		; if div 5 bit set ...
	jz	TP_Ch0done		; ... do pure

TP_Pure:
	cmp	[Outvol + di],0		; toggle the output
	je	TP_VolumeOn
	jmp	TP_VolumeOff


TP_Poly9:	
	inc_mod	P9+2*edi,511		; inc the P9 counter
	mov	bx,[P9 + 2*edi]

	cmp	Bit9[bx],0		; and set the output bit
	je	TP_VolumeOff
	jmp	TP_VolumeOn


TP_Div31_Poly5:
	cmp	Div31[bx],0		; if div 31 bit set ...
	jnz	TP_Poly5		; ... do Poly5
	jmp	TP_Ch0done

TP_Poly5_Poly5:
	cmp	Bit5[bx],0		; if Poly5 bit set ...
	jz	TP_Ch0done		; ... do Poly5

TP_Poly5:
	movzx	bx,[P5 + di]		; set the output bit
	cmp	Bit5[bx],0
	je	TP_VolumeOff
	jmp	TP_VolumeOn


TP_Div31_Poly4:
	cmp	Div31[bx],0		; if div 31 bit set ...
	jnz	TP_Poly4		; ... do Poly4
	jmp	TP_Ch0done

TP_Poly5_Poly4:
	cmp	Bit5[bx],0		; if Poly5 bit set ...
	jz	TP_Ch0done		; ... do Poly4

TP_Poly4:
	inc_mod	P4+di,15		; inc P4 counter
	movzx	bx,[P4 + di]

	cmp	Bit4[bx],0		; and set the output bit
	je	TP_VolumeOff

TP_VolumeOn:
	mov	al,[AUDV + di]
	mov	[Outvol + di],al
	jmp	TP_Ch0done

TP_VolumeOff:
	mov	[Outvol + di],0

TP_Ch0done:
	inc	di			; to next channel
	cmp	di,1			; done ?
	jbe	TP_ProcessChannel	;   not yet

	sub	[Samp_n_cnt],256	; decrement sample count
					; (256 since lower byte is 
					;  fractional part)
	cmp	[Samp_n_cnt],256	; if count has reached zero ...
	jae	TP_ProcessLoop
	mov	ax,[Samp_n_max]		; ... adjust the sample counter
	add	[Samp_n_cnt],ax

	mov	al,[Outvol+0]
	add	al,[Outvol+1]		; sum the channels

	cmp	[GamePaused],0		; if game paused
	jz	TP_NoSilence
	mov	al,080h			; fill buffer with silence
TP_NoSilence:

	test	dx,dx			; doing digital signal processing ?
	jz	TP_ProcessDone		;   no, just store it
	mov	[next_sample],al	;   yes, take edge off square wave
	xor	ah,ah
	add	ax,[prev_sample]
	shr	ax,1
	mov	[prev_sample],ax	; dsp=2, scaled moving average

	cmp	dx,1
	jne	TP_ProcessDone
	movzx	si,[next_sample]	; dsp=1, simple moving average
	mov	[prev_sample],si

TP_ProcessDone:
	mov	si,[SoundPointer]
	inc	[SoundPointer]
	mov	[si],al			; put byte in buffer

	dec	cx			; one less byte to do
	jnz	TP_ProcessLoop

	popf
	ret	

_FillSoundBuffer endp


