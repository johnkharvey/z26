;*
;* vertical synchronization code
;*

; Mar 18, 1998  (0.96)  added timeout code
; Apr 24, 1998  (1.00x) added sync that does VSync with a timeout (currently default mode)
;                       removed timeout from NDI code (mode 2)
;
; Apr 29, 1998          extreme simplification, do timing with hardware clock
; Jul 14, 1998	(1.08)	variable game speed


CRTSTAT=	03dah			; CRT status register

VSync:	cmp	[NoRetrace],0ffh	; -r no param
	je	VSRet
	cmp	[NoRetrace],1
	jae	FrameLimiter		; -r<n>, n >= 1

;*
;* the default Vsync code -- look for non-display interval
;*

	and	dword ptr [hi_time],0ffffh ; clear hi order bit in hi order time word
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
VSRet:	ret				;   yes, we're done


;*
;* Timer based frame limiter
;*

.CEND
.DATASEGMENT

FrameTime	dd	0
TicksPerSecond	dd	1193182			; 14318180/12

.DEND
.CODESEGMENT

FrameLimiter:
	pushad

	mov	eax,[TicksPerSecond]
	xor	edx,edx
	movzx	ecx,[NoRetrace]		; pick up # of frames per second
	div	ecx			; eax = # of ticks per frame
	add	[FrameTime],eax		; make it next frame time

FrameLimitLoop:
	test	[KeyTable+KeyEsc],128	; ESC pressed ?
	jnz	FLRet			;   yes

	call	_GetTime
	cmp	eax,[FrameTime]
	jb	FrameLimitLoop

	mov	[FrameTime],eax		; mark new frame time

FLRet:	popad
	ret
