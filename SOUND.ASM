
; *****************************************************************************
;
;			 A26 Sound Handler routine
;
; *****************************************************************************

; *****************************************************************************
;
;	On entry,BL is the sound register,BH is	the data written there
;
; *****************************************************************************

Sound:  
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
	call	[SVector]		; do the sound update
SoundExit:
	pop	bx
	pop	ax
        
	ret

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
	cmp	bh,[MinVol]		; if sound is on...
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

SoundOff:
	xor	ax,ax			; all values to	zero
	xor	bx,bx
	call	[SVector]
	inc	bl
	jmp	[SVector]
	
