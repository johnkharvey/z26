;*
;* Pitfall 2 8K bankswitch scheme -- similar to standard F8
;*
;* 5-12-99 -- break ground
;*
;* Based in part on David Crane's U.S. Patent 4,644,495, Feb 17,1987.
;*

.data

; global Pitfall2 flag 

Pitfall2	db	0		; tell RIOT timer to clock the music

;P2_Flags	db	8 dup (?)	; \
;P2_Counters	db	16 dup (?)	;  \
;P2_Top		db	8 dup (?)	;   these are in memory.asm
;P2_Bottom	db	8 dup (?)	;  /
;P2_Enable	db	8 dup (?)	; /
;P2_Music_Top	dw	8 dup (?)
;P2_Music_Bottom dw	8 dup (?)
;P2_Music_Count	dw	8 dup (?)

P2_sreg		dw	1		; initialize shift register to non-zero val

P2_Rbyte	db	0		; return value for CPU read commands
P2_AUDV		db	0		; create an AUDV byte here

ALIGN 2

P2_Vectors label word

;*
;* read commands
;*

	dw	P2_Read_Random		; 00 -- Random # generator
	dw	P2_Read_Random		; 01 -- Random # generator
	dw	P2_Read_Random		; 02 -- Random # generator
	dw	P2_Read_Random		; 03 -- Random # generator
	dw	P2_Read_Sound		; 04 -- Sound value
	dw	P2_Read_Sound		; 05 -- Sound value
	dw	P2_Read_Sound		; 06 -- Sound value
	dw	P2_Read_Sound		; 07 -- Sound value
	dw	P2_Read_DF		; 08 -- DF0
	dw	P2_Read_DF		; 09 -- DF1
	dw	P2_Read_DF		; 0a -- DF2
	dw	P2_Read_DF		; 0b -- DF3
	dw	P2_Read_DF		; 0c -- DF4
	dw	P2_Read_DF		; 0d -- DF5
	dw	P2_Read_DF		; 0e -- DF6
	dw	P2_Read_DF		; 0f -- DF7
	dw	P2_Read_DF_Flag		; 10 -- DF0 AND flag
	dw	P2_Read_DF_Flag		; 11 -- DF1 AND flag
	dw	P2_Read_DF_Flag		; 12 -- DF2 AND flag
	dw	P2_Read_DF_Flag		; 13 -- DF3 AND flag
	dw	P2_Read_DF_Flag		; 14 -- DF4 AND flag
	dw	P2_Read_DF_Flag		; 15 -- DF5 AND flag
	dw	P2_Read_DF_Flag		; 16 -- DF6 AND flag
	dw	P2_Read_DF_Flag		; 17 -- DF7 AND flag
	dw	P2_NoIO			; 18 -- DF0 AND flag swapped
	dw	P2_NoIO			; 19 -- DF1 AND flag swapped
	dw	P2_NoIO			; 1a -- DF2 AND flag swapped
	dw	P2_NoIO			; 1b -- DF3 AND flag swapped
	dw	P2_NoIO			; 1c -- DF4 AND flag swapped
	dw	P2_NoIO			; 1d -- DF5 AND flag swapped
	dw	P2_NoIO			; 1e -- DF6 AND flag swapped
	dw	P2_NoIO			; 1f -- DF7 AND flag swapped
	dw	P2_NoIO			; 20 -- DF0 AND flag reversed
	dw	P2_NoIO			; 21 -- DF1 AND flag reversed
	dw	P2_NoIO			; 22 -- DF2 AND flag reversed
	dw	P2_NoIO			; 23 -- DF3 AND flag reversed
	dw	P2_NoIO			; 24 -- DF4 AND flag reversed
	dw	P2_NoIO			; 25 -- DF5 AND flag reversed
	dw	P2_NoIO			; 26 -- DF6 AND flag reversed
	dw	P2_NoIO			; 27 -- DF7 AND flag reversed
	dw	P2_NoIO			; 28 -- DF0 AND flag SHR 1
	dw	P2_NoIO			; 29 -- DF1 AND flag SHR 1
	dw	P2_NoIO			; 2a -- DF2 AND flag SHR 1
	dw	P2_NoIO			; 2b -- DF3 AND flag SHR 1
	dw	P2_NoIO			; 2c -- DF4 AND flag SHR 1
	dw	P2_NoIO			; 2d -- DF5 AND flag SHR 1
	dw	P2_NoIO			; 2e -- DF6 AND flag SHR 1
	dw	P2_NoIO			; 2f -- DF7 AND flag SHR 1
	dw	P2_NoIO			; 30 -- DF0 AND flag SHL 1
	dw	P2_NoIO			; 31 -- DF1 AND flag SHL 1
	dw	P2_NoIO			; 32 -- DF2 AND flag SHL 1
	dw	P2_NoIO			; 33 -- DF3 AND flag SHL 1
	dw	P2_NoIO			; 34 -- DF4 AND flag SHL 1
	dw	P2_NoIO			; 35 -- DF5 AND flag SHL 1
	dw	P2_NoIO			; 36 -- DF6 AND flag SHL 1
	dw	P2_NoIO			; 37 -- DF7 AND flag SHL 1
	dw	P2_ReadFlags		; 38 -- DF0 flag
	dw	P2_ReadFlags		; 39 -- DF1 flag
	dw	P2_ReadFlags		; 3a -- DF2 flag
	dw	P2_ReadFlags		; 3b -- DF3 flag
	dw	P2_ReadFlags		; 3c -- DF4 flag
	dw	P2_ReadFlags		; 3d -- DF5 flag
	dw	P2_ReadFlags		; 3e -- DF6 flag
	dw	P2_ReadFlags		; 3f -- DF7 flag

;*
;* write commands
;*

	dw	P2_WriteTop		; 40 -- DF0 top count
	dw	P2_WriteTop		; 41 -- DF1 top count
	dw	P2_WriteTop		; 42 -- DF2 top count
	dw	P2_WriteTop		; 43 -- DF3 top count
	dw	P2_WriteTop		; 44 -- DF4 top count
	dw	P2_WriteTop		; 45 -- DF5 top count
	dw	P2_WriteTop		; 46 -- DF6 top count
	dw	P2_WriteTop		; 47 -- DF7 top count
	dw	P2_WriteBottom		; 48 -- DF0 bottom count
	dw	P2_WriteBottom		; 49 -- DF1 bottom count
	dw	P2_WriteBottom		; 4a -- DF2 bottom count
	dw	P2_WriteBottom		; 4b -- DF3 bottom count
	dw	P2_WriteBottom		; 4c -- DF4 bottom count
	dw	P2_WriteBottom		; 4d -- DF5 bottom count
	dw	P2_WriteBottom		; 4e -- DF6 bottom count
	dw	P2_WriteBottom		; 4f -- DF7 bottom count
	dw	P2_WriteCounterLow	; 50 -- DF0 counter low
	dw	P2_WriteCounterLow	; 51 -- DF1 counter low
	dw	P2_WriteCounterLow	; 52 -- DF2 counter low
	dw	P2_WriteCounterLow	; 53 -- DF3 counter low
	dw	P2_WriteCounterLow	; 54 -- DF4 counter low
	dw	P2_WriteCounterLow	; 55 -- DF5 counter low
	dw	P2_WriteCounterLow	; 56 -- DF6 counter low
	dw	P2_WriteCounterLow	; 57 -- DF7 counter low
	dw	P2_WriteCounterHigh	; 58 -- DF0 counter high
	dw	P2_WriteCounterHigh	; 59 -- DF1 counter high
	dw	P2_WriteCounterHigh	; 5a -- DF2 counter high
	dw	P2_WriteCounterHigh	; 5b -- DF3 counter high
	dw	P2_WriteCounterHigh	; 5c -- DF4 counter high
	dw	P2_WriteCounterHigh	; 5d -- DF5 counter high AND music enable
	dw	P2_WriteCounterHigh	; 5e -- DF6 counter high AND music enable
	dw	P2_WriteCounterHigh	; 5f -- DF7 counter high AND music enable
	dw	P2_NoIO			; 60 -- not used (draw line movement)
	dw	P2_NoIO			; 61 -- not used (draw line movement)
	dw	P2_NoIO			; 62 -- not used (draw line movement)
	dw	P2_NoIO			; 63 -- not used (draw line movement)
	dw	P2_NoIO			; 64 -- not used (draw line movement)
	dw	P2_NoIO			; 65 -- not used (draw line movement)
	dw	P2_NoIO			; 66 -- not used (draw line movement)
	dw	P2_NoIO			; 67 -- not used (draw line movement)
	dw	P2_NoIO			; 68 -- not used
	dw	P2_NoIO			; 69 -- not used
	dw	P2_NoIO			; 6a -- not used
	dw	P2_NoIO			; 6b -- not used
	dw	P2_NoIO			; 6c -- not used
	dw	P2_NoIO			; 6d -- not used
	dw	P2_NoIO			; 6e -- not used
	dw	P2_NoIO			; 6f -- not used
	dw	P2_ResetRandom		; 70 -- random number generator reset
	dw	P2_ResetRandom		; 71 -- random number generator reset
	dw	P2_ResetRandom		; 72 -- random number generator reset
	dw	P2_ResetRandom		; 73 -- random number generator reset
	dw	P2_ResetRandom		; 74 -- random number generator reset
	dw	P2_ResetRandom		; 75 -- random number generator reset
	dw	P2_ResetRandom		; 76 -- random number generator reset
	dw	P2_ResetRandom		; 77 -- random number generator reset
	dw	P2_NoIO			; 78 -- not used
	dw	P2_NoIO			; 79 -- not used
	dw	P2_NoIO			; 7a -- not used
	dw	P2_NoIO			; 7b -- not used
	dw	P2_NoIO			; 7c -- not used
	dw	P2_NoIO			; 7d -- not used
	dw	P2_NoIO			; 7e -- not used
	dw	P2_NoIO			; 7f -- not used

.code

;*
;* Pitfall 2 initialization
;*

Init_P2:				; <-- from init.asm
	mov	[P2_sreg],1		; random # generator (must be non-zero)
	ret

SetPitfallII:				; <-- from banks.asm
	mov	[ReadBank], offset RBank8P2
	mov	[WriteBank], offset WBank8P2
	mov	[RomBank],01000h	; don't know if this is needed...
	mov	[Pitfall2],1		; tell RIOT to clock the music
	ret

;*
;* bankswitch entry points
;*

RBank8P2:
	test_hw_read
	cmp	si,107fh
	jbe	R_P2
	SetBank_8			; F8 macro
	MapRomBank
	ret


WBank8P2:
	test_hw_write
	cmp	si,107fh
	jbe	W_P2
	SetBank_8			; F8 macro
	ret

;*
;* read Pitfall 2 register
;*

R_P2:
	cmp	si,1040h		; read in range?
	jae	P2_NoIO			;   no
	and	esi,07fh
	jmp	[P2_Vectors+esi*2]

;*
;* write Pitfall 2 register
;*

W_P2:
	cmp	si,1040h		; write in range?
	jb	P2_NoIO			;   no
	and	esi,07fh
	jmp	[P2_Vectors+esi*2]

;*
;* Pitfall 2 register handlers
;*

;*
;* null register read/write
;*

P2_NoIO:
	ret


;*
;* macro to tune the pitch of the music
;*
;* We use this to match the Pitfall II music clock to the TIA music clock.
;*
;* Due to the discrete nature of this stuff, since the two clocks are not 
;* integer multiples of one another, adjustments of the ratio can affect the
;* relative pitch of notes in a chord as well as the overall pitch.  So you 
;* need to make sure that the important chords sound *nice*.
;*

Tune_Music macro

	push	ax
	push	cx
	mov	al,dl
	xor	dx,dx
	mov	cl,129
	mul	cl
	mov	cx,79
	div	cx
	mov	dx,ax
	pop	cx
	pop	ax

	endm

;*
;* write top register
;*

P2_WriteTop:
	and	esi,7
	mov	dl,[WByte]		; pick up byte to write
	mov	[P2_Top + si],dl	; save in TOP
	cmp	si,5
	jb	P2_WriteDone
	Tune_Music
	mov	[P2_Music_Top + esi*2],dx

P2_WriteDone:
	ret

;*
;* write bottom register
;*

P2_WriteBottom:
	and	esi,7
	mov	dl,[WByte]		; pick up byte to write
	mov	[P2_Bottom + si],dl	; save in BOTTOM
	cmp	si,5
	jb	P2_WriteDone
	Tune_Music
	mov	[P2_Music_Bottom + esi*2],dx
	ret

;*
;* write counter low
;*

P2_WriteCounterLow:
	and	esi,7
	mov	dl,[WByte]		; pick up byte to write
	mov	[P2_Counters + esi*2],dl ; save in LOW counter byte
	cmp	si,5
	jb	P2_WriteDone
	Tune_Music
	mov	[P2_Music_Count + esi*2],dx
	ret

;*
;* write counter high AND music enable
;*

P2_WriteCounterHigh:
	and	esi,7
	mov	dl,[WByte]		; pick up byte to write
	mov	[P2_Enable + si],dl	; save whole thing in enable
	and	dl,7			; mask bottom 3 bits for a total of 11
	mov	[P2_Counters + esi*2 + 1],dl ; save in HIGH counter byte
	mov	[P2_Flags + si],0	; this also clears the FLAG
	ret

;*
;* reset the random number generator
;*

P2_ResetRandom:
	mov	[P2_sreg],1
	ret

;*
;* read flags
;*

P2_ReadFlags:
	and	si,7
	add	si,offset P2_Flags
	ret

;*
;* macro to read data via data fetcher
;*

Read_DF macro
local P2_FlagOne, P2_FlagZero, P2_Cont
	and	esi,7
	push	bx
	mov	dl,[P2_Counters + esi*2]	; use old counter value for flag test
	dec	word ptr [P2_Counters + esi*2]	; decrement for current fetch
	cmp	dl,[P2_Top + si]		; equal to top value?
	je	P2_FlagOne			;   yes, set flag
	cmp	dl,[P2_Bottom + si]		; equal to bottom value?
	je	P2_FlagZero			;   yes, clear flag
	jmp	P2_Cont

P2_FlagOne:
	mov	[P2_Flags + si],0ffh		; set flag
	jmp	P2_Cont

P2_FlagZero:
	mov	[P2_Flags + si],0		; clear flag

P2_Cont:
	mov	bx,word ptr [P2_Counters + esi*2] ; get current counter
	neg	bx				; fetch data
	mov	dl,[_CartRom + 027feh + bx]	; yes it *is* magic
	mov	[P2_Rbyte],dl			; save data
	pop	bx
	endm

;*
;* read data via data fetcher
;*

P2_Read_DF:
	Read_DF
	mov	si,offset P2_Rbyte		; pointer for CPU
	ret

;*
;* read data via data fetcher ANDed with flag
;*

P2_Read_DF_Flag:
	Read_DF
	mov	dl,[P2_Flags + si]		; pick up flag
	and	[P2_Rbyte],dl			; AND data
	mov	si,offset P2_Rbyte		; restore pointer for CPU
	ret

;*
;* Generate a sequence of pseudo-random numbers 511 numbers long
;* by emulating a 9-bit shift register with feedback taps at
;* positions 5 and 9.  (Code from tiasnd.asm).
;*
;* It should really be a 255 number sequence, but it will do for now.
;*

P2_Read_Random:
	push	ax
	mov	ax,[P2_sreg]
	and	ax,1				; bit 9 (register output & return val)
	mov	dx,[P2_sreg]
	and	dx,16
	shr	dx,4				; position bit 5 at bottom
	xor	dx,ax				; xor with bit 9 = new bit 1
	shr	[P2_sreg],1			; shift the register
	shl	dx,8				; position the feedback bit
	or	[P2_sreg],dx			; or it in
	mov	dl,byte ptr [P2_sreg]
	mov	[P2_Rbyte],dl
	mov	si,offset P2_Rbyte
	pop	ax
	ret	


;*
;* read sound stuff
;*

;*
;* read sound entry point
;*
;* This is just for show -- Pitfall 2 short-circuits AUDV.
;*

P2_Read_Sound:
	mov	si,offset P2_AUDV
	ret


;*
;* clock a music channel
;*

Clock_Channel macro %1
local MusicZero, ChannelDone

	test	[P2_Enable + %1],010h		; channel enabled?
	jz	ChannelDone			;   no
	mov	dx,[P2_Music_Count + %1*2]	; use old counter value for flag test
	dec	word ptr [P2_Music_Count + %1*2]; decrement for current fetch
	cmp	dx,[P2_Music_Bottom + %1*2]	; equal to bottom value?
	je	MusicZero			;   yes, clear flag
	cmp	dx,-1				; time to reset?
	jnz	ChannelDone			;   no
	mov	dx,[P2_Music_Top + %1*2]	;   yes, reset counter
	mov	word ptr [P2_Music_Count + %1*2],dx
	mov	[P2_Flags + %1],0ffh		; set flag
	jmp	ChannelDone

MusicZero:
	mov	[P2_Flags + %1],0		; clear flag

ChannelDone:
	endm


;*
;* clock music -- clock all channels
;*

Clock_Music macro
	Clock_Channel 5
	Clock_Channel 6
	Clock_Channel 7
	endm

;*
;* build AUDV byte
;*

.data

;*
;* sound mixing table
;* convert 3 sound channel bits into an AUDV value
;*

Mix_AUDV db 0, 6, 5, 0bh, 4, 0ah, 9, 0fh

.code

Build_AUDV macro
	movzx	bx,byte ptr [P2_Flags + 5]
	mov	dl,byte ptr [P2_Flags + 6]
	mov	dh,byte ptr [P2_Flags + 7]
	and	bl,1
	and	dl,2
	and	dh,4
	or	bl,dl
	or	bl,dh
	mov	dl,[Mix_AUDV + bx]
	mov	[P2_AUDV],dl
	endm

;*
;* clock Pitfall 2 from TIA sound
;*


Clock_Pitfall2:
	push	ebx
	push	dx

	Clock_Music			;   yes, clock P2
	cmp	[_SoundMode],2		; forcing slow speed ?
	jne	ClockP2Done		;   no
	Clock_Music			;   yes, double clock

ClockP2Done:
	Build_AUDV			; build the AUDV byte

ClockP2NoClock:
	pop	dx
	pop	ebx
	ret

