
; *****************************************************************************
;
;			 A26 Sound Handler routine
;
; *****************************************************************************

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

.data

Frequency dw 39 ; 30000.00 Hz
 dw 79 ; 15000.00 Hz
 dw 119 ; 10000.00 Hz
 dw 159 ; 7500.00 Hz
 dw 198 ; 6000.00 Hz
 dw 238 ; 5000.00 Hz
 dw 278 ; 4285.71 Hz
 dw 318 ; 3750.00 Hz
 dw 357 ; 3333.33 Hz
 dw 397 ; 3000.00 Hz
 dw 437 ; 2727.27 Hz
 dw 477 ; 2500.00 Hz
 dw 517 ; 2307.69 Hz
 dw 556 ; 2142.86 Hz
 dw 596 ; 2000.00 Hz
 dw 636 ; 1875.00 Hz
 dw 676 ; 1764.71 Hz
 dw 715 ; 1666.67 Hz
 dw 755 ; 1578.95 Hz
 dw 795 ; 1500.00 Hz
 dw 835 ; 1428.57 Hz
 dw 875 ; 1363.64 Hz
 dw 914 ; 1304.35 Hz
 dw 954 ; 1250.00 Hz
 dw 994 ; 1200.00 Hz
 dw 1034 ; 1153.85 Hz
 dw 1073 ; 1111.11 Hz
 dw 1113 ; 1071.43 Hz
 dw 1153 ; 1034.48 Hz
 dw 1193 ; 1000.00 Hz
 dw 1233 ; 967.74 Hz
 dw 1272 ; 937.50 Hz
;

AudC0	db	-1			; Sound registers
AudC1	db	-1
AudF0	db	-1
AudF1	db	-1
AudV0	db	-1
AudV1	db	-1

AudMask db	15,15,31,31,15,15	; bitmask for the registers

SDMPX	db	2			; 0 = ch1,1 = ch2,2 = both,-1 = quiet
;MinVol	db	8			; minimum volume for PC Speaker


.code

; *****************************************************************************
;
;	On entry,BL is the sound register,BH is	the data written there
;
; *****************************************************************************

Sound proc near
	push	ax
	push	bx

	mov	al,bh			; data in al
	xor	bh,bh			; bx = offset to Audio registers
	sub	bx,015h
	and	al,AudMask[bx]		; and it with the bitmask
	cmp	al,AudC0[bx]		; has it changed ....
	je	SoundExit		; yes,exit
	mov	AudC0[bx],al		; update it
	and	bx,1			; 0 if channel 0,1 if channel 1
	mov	al,AudC0[bx]		; al is	the control
	mov	ah,AudF0[bx]		; ah is	the frequency
	mov	bh,AudV0[bx]		; bh is	the volume
	call	PCSound			; do the sound update
SoundExit:
	pop	bx
	pop	ax
        
	ret

Sound endp

; *****************************************************************************
;
;     Update sound system. AL Control AH Frequency BH Volume BL	Channel
;
; *****************************************************************************

PCSound:
	push	ax
	push	cx
        
	cmp	bl,[SDMPX]		; pc sound only	on 1 channel ??
	je	PCSoundExit
	mov	cl,[SDMPX]		; exit if CL = 255
	cmp	cl,255
	je	PCSoundExit

	movzx	ecx,ah			; get frequency from table
	mov	cx,Frequency[ecx*2]
	call	CtrlDivide		; cx adjusted by al (control)
	mov	al,182
	out	67,al			; out 67,182
	mov	al,cl
	out	66,al			; out 68,lobyte(freq)
	mov	al,ch
	out	66,al			; out 68,hibyte(freq)
        
	in	al,97			; read the speaker port
	and	al,0FCh			; bits 1 & 0 set to zero.
	cmp	bh,[_MinVol]		; if sound is on...
	jle	PCSwitch
	or	al,3			; set bits 0 & 1 on PC Speaker
PCSwitch:
	out	97,al			; update the speaker port control
PCSoundExit:
	pop	cx
	pop	ax
	ret

; *****************************************************************************
;
;	Divide frequency value in CX according to Control in DL
;
;	Note that CX is	actually multiplied as its a wavelength
;
; *****************************************************************************

CtrlDivide:
	cmp	al,4			; 4,5,7	div 2
	je	CD2
	cmp	al,5
	je	CD2
	cmp	al,6			; 6,10 is div 31
	je	CD31
	cmp	al,10
	je	CD31
	cmp	al,12			; 12,13,15 div 6
	je	CD6
	cmp	al,13
	je	CD6
	cmp	al,14			; 14 div 93
	je	CD93
	ret
		
CD2:	shl	cx,1			; divide by 2 easy
	ret
	
CD15:	imul	cx,15
	ret
	
CD31:	imul	cx,31
	ret
	
CD6:	imul	cx,6
	ret
	
CD93:	imul	cx,93
	ret

; *****************************************************************************
;
;			  Turn the sound off.
;
; *****************************************************************************

SoundOff proc near
	xor	ax,ax			; all values to	zero
	xor	bx,bx
	call	PCSound
	inc	bl
	call	PCSound
	ret

SoundOff endp

