; tiasnd.asm -- z26 sound generation routines
;               based on TIASound (c) 1996-1997 by Ron Fries
;		please see the end of this file for Ron's banner

; z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 04-08-98 -- first release
; 04-19-99 -- added sound queue
; 07-27-02 -- 32-bit
; 12-08-03 -- polynomials adapted to Adam Wozniak's description

.data

sreg	dd	1		; initialize shift register to non-zero val

; Initialze the bit patterns for the polynomials.

; The 4bit and 5bit patterns are the identical ones used in the tia chip.
; Though the patterns could be packed with 8 bits per byte, using only a
; single bit per byte keeps the math simple, which is important for
; efficient processing.

;Bit4    db      1,1,0,1,1,1,0,0,0,0,1,0,1,0,0
;Bit5    db      0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0,1,0,0,0,0,1
Bit4    db      0,1,1,0,0,1,0,1,0,0,0,0,1,1,1
Bit5    db      0,0,0,0,0,1,1,1,0,0,1,0,0,0,1,0,1,0,1,1,1,1,0,1,1,0,1,0,0,1,1

; 1 = toggle output in 5 bit poly - used when poly5 clocks other outputs
Bit5T   db      1,0,0,0,0,1,0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0

; The 'Div by 31' counter is treated as another polynomial because of
; the way it operates.  It does not have a 50% duty cycle, but instead
; has a 13:18 ratio (of course, 13+18 = 31).  This could also be
; implemented by using counters.

Div31   db      0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0

Div6    db      0,1,0,0,1,0

; The sample output is treated as another divide by N counter.
; For better accuracy, the Samp_n_cnt has a fixed binary decimal point
; which has 8 binary digits to the right of the decimal point.

Samp_n_cnt	dd	0
Samp_n_max	dd	0

TS_Start label byte			; <-- start clearing here

D6              db      0,0
P4              db      0,0
P5		db	0,0
AUDC		db	0,0
AUDF		db	0,0
AUDV		db	0,0
Outvol		db	0,0
Div_n_cnt 	db	0,0
Div_n_max 	db	0,0

TS_End label byte			; <-- finish clearing here

P9_sreg		dd	1,1


_new_val	dd	0

prev_sample	dd	0
next_sample	db	0


AUDC_Jumptab	label	dword	; HEX  D3 D2 D1 D0    Clock Source    Clock Modifier    Source Pattern
				; --- -------------  --------------  ----------------  ----------------
	dd	TSB_Ch0done	;  0    0  0  0  0    3.58 MHz/114 ->  none  (pure)  ->      none
	dd	TSB_Poly4	;  1    0  0  0  1    3.58 MHz/114 ->  none  (pure)  ->   4-bit poly
	dd	TSB_Div31_Poly4	;  2    0  0  1  0    3.58 MHz/114 ->  divide by 31  ->   4-bit poly
	dd	TSB_Poly5_Poly4	;  3    0  0  1  1    3.58 MHz/114 ->   5-bit poly   ->   4-bit poly
	dd	TSB_Pure	;  4    0  1  0  0    3.58 MHz/114 ->  none  (pure)  ->   pure  (~Q)
	dd	TSB_Pure	;  5    0  1  0  1    3.58 MHz/114 ->  none  (pure)  ->   pure  (~Q)
	dd	TSB_Div31_Pure	;  6    0  1  1  0    3.58 MHz/114 ->  divide by 31  ->   pure  (~Q)
;        dd      TSB_Poly5_Pure  ;  7    0  1  1  1    3.58 MHz/114 ->   5-bit poly   ->   pure  (~Q)
        dd      TSB_Poly5       ;  7    0  1  1  1    3.58 MHz/114 ->  none  (pure)  ->   5-bit poly
	dd	TSB_Poly9	;  8    1  0  0  0    3.58 MHz/114 ->  none  (pure)  ->   9-bit poly
	dd	TSB_Poly5	;  9    1  0  0  1    3.58 MHz/114 ->  none  (pure)  ->   5-bit poly
;        dd      TSB_Div31_Poly5 ;  A    1  0  1  0    3.58 MHz/114 ->  divide by 31  ->   5-bit poly
        dd      TSB_Div31_Pure  ;  A    1  0  1  0    3.58 MHz/114 ->  divide by 31  ->   pure  (~Q)
	dd	TSB_Poly5_Poly5	;  B    1  0  1  1    3.58 MHz/114 ->   5-bit poly   ->   5-bit poly
        dd      TSB_Div6_Pure   ;  C    1  1  0  0    3.58 MHz/114 ->  divide by 6   ->   pure  (~Q)
        dd      TSB_Div6_Pure   ;  D    1  1  0  1    3.58 MHz/114 ->  divide by 6   ->   pure  (~Q)
        dd      TSB_Div31_Div6  ;  E    1  1  1  0    3.58 MHz/114 ->  divide by 31  ->   divide by 6
        dd      TSB_Poly5_Div6  ;  F    1  1  1  1    3.58 MHz/114 ->   5-bit poly   ->   divide by 6

.code
;*
;* handle the power-up initialization functions
;* these functions should only be executed on a cold-restart
;*

Init_Tiasnd:

; calculate the sample 'divide by N' value based on the playback freq

	mov	eax,31400
	shl	eax,8
	mov	ebx,31400
	xor	edx,edx
	div	ebx			; ax = (_sample_freq<<8)/_playback_freq
	mov	[Samp_n_max],eax
	mov	[Samp_n_cnt],0

	clear_mem TS_Start, TS_End

	mov	[P9_sreg],1
	mov	[P9_sreg+4],1

	ret	


;*
;* routine to get kid-vid sound byte
;*

KidVid_Sound_Byte:

        test    [_KidVid],0ffH
        jz      NoSamplePlay

	pushad
        call    _kv_GetNextSampleByte
	popad
	movzx	eax,[_SampleByte]

NoSamplePlay:

	ret


;*
;* generate a sequence of pseudo-random bits 511 bits long
;* by emulating a 9-bit shift register with feedback taps at
;* positions 5 and 9.
;*

ShiftRegister9:
	mov	eax,[sreg]
	mov	edx,eax
	and	eax,1		; bit 9 (register output & return val)
	and	edx,16
	shr	edx,4		; position bit 5 at bottom
	xor	edx,eax		; xor with bit 9 = new bit 1
	shr	[sreg],1	; shift the register
	shl	edx,8		; position the feedback bit
	or	[sreg],edx	; or it in
	ret	

;*
;* update TIA sound registers
;*

H_AUDC0:
	mov	al,[WByte]
	and	al,15
	mov	[AUDC],al
	jmp	UTS_Chan0

H_AUDC1:
	mov	al,[WByte]
	and	al,15
	mov	[AUDC+1],al
	jmp	UTS_Chan1

H_AUDF0:
	mov	al,[WByte]
	and	al,31
	mov	[AUDF],al
	jmp	UTS_Chan0

H_AUDF1:
	mov	al,[WByte]
	and	al,31
	mov	[AUDF+1],al
	jmp	UTS_Chan1

H_AUDV0:
	mov	al,[WByte]
	and	al,15
	shl	al,3
	mov	[AUDV],al

UTS_Chan0:
	xor	ebx,ebx
	jmp	UTS_RegSet

H_AUDV1:
	mov	al,[WByte]
	and	al,15
	shl	al,3
	mov	[AUDV+1],al

UTS_Chan1:
	mov	ebx,1

; the output value has changed

UTS_RegSet:
	cmp	AUDC[ebx],0		; AUDC value of zero is a special case
	jne	UTS_rs1
	mov	[_new_val],0		; indicate clock is zero so ...
	mov	al,AUDV[ebx]		; ... no processing will occur
	mov	Outvol[ebx],al		; and set output to selected volume

	jmp	UTS_rs2

UTS_rs1:
	movzx	eax,AUDF[ebx]		; calc the 'div by N' value
	inc	eax
	mov	[_new_val],eax
;        mov     al,AUDC[ebx]
;        and     al,12
;        cmp     al,12
;        jne     UTS_rs2                 ; if bits 2 and 3 are set ...
;        mov     eax,[_new_val]          ; ... multiply by three
;        add     eax,eax
;        add     [_new_val],eax

UTS_rs2:movzx	eax,Div_n_max[ebx] 	; only reset channels that have changed
	cmp	eax,[_new_val]
	je	UTS_Done
	mov	al,byte ptr _new_val
	mov	Div_n_max[ebx],al 	; reset 'div by N' counters
	cmp	Div_n_cnt[ebx],0
	je	UTS_rs3			; if channel is now volume only ...
	cmp	[_new_val],0
	jne	UTS_Done		; ... or was volume only ...

UTS_rs3:mov	al,byte ptr _new_val
	mov	Div_n_cnt[ebx],al 	; ... reset the counter 
				 	;     (otherwise complete previous)

UTS_Done:
	ret	

;*
;* generate a sound byte based on the TIA chip parameters
;*

inc_mod macro	op1,op2
local done

	inc	[op1]
	cmp	[op1],op2
	jne	done
	mov	[op1],0
done:
	endm


TIA_Sound_Byte:

TSB_ProcessLoop:

	xor	edi,edi			; process channel 0 first

	cmp	[Pitfall2],0		; doing Pitfall2?
	jz	TSB_ProcessChannel	;   no
	inc	edi			;   yes, only do channel 1

TSB_ProcessChannel:
	cmp	[Div_n_cnt + edi],1	; if div by N counter can count down ...
	jb	TSB_Ch0done		;   zero is special case, means AUDC==0 -- fast exit
	je	TSB_1
	dec	[Div_n_cnt + edi]	; ... decrement ...
	jmp	TSB_Ch0done		; ... and do next channel

TSB_1:	mov	al,[Div_n_max + edi]	; otherwise reset the counter and process this channel
	mov	[Div_n_cnt + edi],al

	movzx	esi,[AUDC + edi]	; AUDC = index into branch table

	inc_mod	P5+edi,31		; P5 channel has multiple uses (Div31 & P5), inc it here
	movzx	ebx,[P5 + edi]

	jmp	[AUDC_Jumptab + esi*4] ; process sound changes based on AUDC


TSB_Div6_Pure:
        inc_mod D6+edi,6                ; inc Div6 counter
        movzx   ebx,[D6 + edi]
        cmp     Div6[ebx],0             ; if div 6 bit set ...
	jnz	TSB_Pure		; ... do pure
	jmp	TSB_Ch0done

TSB_Div31_Div6:
	cmp	Div31[ebx],0		; if div 31 bit set ...
        jnz     TSB_Div6_Pure           ; ... do div 6
        jmp     TSB_Ch0done

TSB_Div31_Pure:
	cmp	Div31[ebx],0		; if div 31 bit set ...
	jnz	TSB_Pure		; ... do pure
	jmp	TSB_Ch0done

;TSB_Poly5_Pure:
;        cmp     Bit5[ebx],0             ; if div 5 bit set ...
;        jz      TSB_Ch0done             ; ... do pure

TSB_Pure:
	cmp	[Outvol + edi],0	; toggle the output
	je	TSB_VolumeOn
	jmp	TSB_VolumeOff


TSB_Poly9:	
	mov	edx,[P9_sreg+4*edi]
	mov	[sreg],edx		; set shift reg to this channel's shift reg
	call	ShiftRegister9		; calculate next bit
	mov	edx,[sreg]		; save shift reg to our channel
	mov	[P9_sreg+4*edi],edx
	test	al,1			; shift reg bit on?
	je	TSB_VolumeOff		;   no
	jmp	TSB_VolumeOn		;   yes


;TSB_Div31_Poly5:
;        cmp     Div31[ebx],0            ; if div 31 bit set ...
;        jnz     TSB_Poly5               ; ... do Poly5
;        jmp     TSB_Ch0done

TSB_Poly5_Div6:
        cmp     Bit5T[ebx],0            ; if Bit5 output changed ...
        jnz     TSB_Div6_Pure           ; ... do Div 6
	jmp	TSB_Ch0done

TSB_Poly5_Poly5:
	cmp	Bit5[ebx],0		; if Poly5 bit set ...
	jz	TSB_Ch0done		; ... do Poly5

TSB_Poly5:
	movzx	ebx,[P5 + edi]		; set the output bit
	cmp	Bit5[ebx],0
	je	TSB_VolumeOff
	jmp	TSB_VolumeOn


TSB_Div31_Poly4:
	cmp	Div31[ebx],0		; if div 31 bit set ...
	jnz	TSB_Poly4		; ... do Poly4
	jmp	TSB_Ch0done

TSB_Poly5_Poly4:                        ; changed from Bit5 to Bit5T *EST*
        cmp     Bit5T[ebx],0            ; if Poly5 bit set ...
	jz	TSB_Ch0done		; ... do Poly4

TSB_Poly4:
	inc_mod	P4+edi,15		; inc P4 counter
	movzx	ebx,[P4 + edi]

	cmp	Bit4[ebx],0		; and set the output bit
	je	TSB_VolumeOff

TSB_VolumeOn:
	mov	al,[AUDV + edi]
	mov	[Outvol + edi],al
	jmp	TSB_Ch0done

TSB_VolumeOff:
	mov	[Outvol + edi],0

TSB_Ch0done:
	inc	edi			; to next channel
	cmp	edi,1			; done ?
	jbe	TSB_ProcessChannel	;   not yet

	sub	[Samp_n_cnt],256	; decrement sample count
					; (256 since lower byte is 
					;  fractional part)
	cmp	[Samp_n_cnt],256	; if count has reached zero ...
	jae	TSB_ProcessLoop
	mov	eax,[Samp_n_max]	; ... adjust the sample counter
	add	[Samp_n_cnt],eax

	cmp	[Pitfall2],0		; running Pitfall 2?
	jz	TSB_NotPitfall2		;   no

	call	Clock_Pitfall2		;   yes, clock P2 music clock (and build AUDV)
	mov	al,[Outvol+1]		; channel 1
	mov	ah,[P2_AUDV]
	and	ah,15
	shl	ah,3
	add	al,ah			; add in Pitfall 2 AUDV byte
	jmp	TSB_Pitfall2_Done

TSB_NotPitfall2:
	mov	al,[Outvol+0]		; not Pitfall 2, do normal mixing
	add	al,[Outvol+1]		; sum the channels

TSB_Pitfall2_Done:
	cmp	[_GamePaused],0		; if game paused
	jz	TSB_NoSilence
	mov	al,080h			; fill buffer with silence
TSB_NoSilence:

	test	[_dsp],0ffh		; doing digital signal processing ?
	jz	TSB_ProcessDone		;   no, just store it
	mov	[next_sample],al	;   yes, take edge off square wave
	xor	eax,eax
	mov	al,[next_sample]
	add	eax,[prev_sample]
	shr	eax,1
	mov	[prev_sample],eax	; dsp=2, scaled moving average

	cmp	[_dsp],1
	jne	TSB_ProcessDone
	movzx	esi,[next_sample]	; dsp=1, simple moving average
	mov	[prev_sample],esi

TSB_ProcessDone:
	and	eax,0ffh		; return 32-bit sample
	ret	

; /*****************************************************************************/
; /*                                                                           */
; /*                 License Information and Copyright Notice                  */
; /*                 ========================================                  */
; /*                                                                           */
; /* TiaSound is Copyright(c) 1996 by Ron Fries                                */
; /*                                                                           */
; /* This library is free software; you can redistribute it and/or modify it   */
; /* under the terms of version 2 of the GNU Library General Public License    */
; /* as published by the Free Software Foundation.                             */
; /*                                                                           */
; /* This library is distributed in the hope that it will be useful, but       */
; /* WITHOUT ANY WARRANTY; without even the implied warranty of                */
; /* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library */
; /* General Public License for more details.                                  */
; /* To obtain a copy of the GNU Library General Public License, write to the  */
; /* Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.   */
; /*                                                                           */
; /* Any permitted reproduction of these routines, in whole or in part, must   */
; /* bear this legend.                                                         */
; /*                                                                           */
; /*****************************************************************************/


