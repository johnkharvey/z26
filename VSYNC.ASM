;*
;* vertical synchronization code
;*

; Mar 18, 1998  (0.96)  added timeout code
; Apr 24, 1998  (1.00x) added sync that does VSync with a timeout (currently default mode)
;                       removed timeout from NDI code (mode 2)
;
; Apr 29, 1998          extreme simplification, do timing with hardware clock


CRTSTAT=	03dah			; CRT status register


ALIGN_ENTRY

VSync:
	cmp	[NoRetrace],1		; -r1
	je	OldVsync
	cmp	[NoRetrace],0ffh	; -r no param
	je	VSRet

;*
;* the default Vsync code -- look for non-display interval
;*

	and	[hi_time],07fffh	; clear hi order bit in hi order time word
					; (so we don't have to worry about overflow...)
					; this means frame timer won't work beyond ~ 40 minutes
NDLoop:	sti
	mov	dx,CRTSTAT		; wait for display disable
	cli
	in	al,dx
	test	al,8
	jnz	NDRet			; fast exit for Vsync seen
	test	al,1
	jz	NDLoop

	call	_GetTime		; 32-bit hardware time (1.19 MHz)
	mov	ecx,eax			; start time
	add	ecx,120			; end time

NDOff:	mov	dx,CRTSTAT		; time the off period
	in	al,dx
	test	al,8
	jnz	NDRet			; fast exit for Vsync seen
	test	al,1
	jz	NDLoop			; display enable came on, start over
	call	_GetTime
	cmp	eax,ecx			; blank long enough?
	jb	NDOff			;   no, keep waiting

NDRet:	sti
	ret				;   yes, we're done


;*
;* Old vsync -- just wait for vsync pulse
;*

OldVsync:
	mov	dx,CRTSTAT		; wait for vertical retrace
WaitForVSync:
	in	al,dx
	test	al,8
	jz	WaitForVSync
VSRet:	ret

