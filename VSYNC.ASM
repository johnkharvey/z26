;*
;* vertical synchronization code for z26
;*


CRTSTAT=	03dah			; CRT status register

.CEND
.DATASEGMENT

TimeLimit		dd	0		; how long before we decide we've seen NDI

LastVsyncTime		dd	0		; when was last Vsync ?

FrameTime		dd	0
TicksPerSecond		dd	1193182		; 14318180/12

NominalFrameTime	dd	19886		; TicksPerSecond/60
HuntForLockTime		dd	19886		; NominalFrameTime
PreGap			dd	17401		; (7/8)*NominalFrameTime
PostGap			dd	22372		; (9/8)*NominalFrameTime

.DEND
.CODESEGMENT


VSync:	cmp	[NoRetrace],0ffh	; -r no param
	je	VSRet
	cmp	[NoRetrace],1
	jae	FrameLimiter		; -r<n>, n >= 1

;*
;* the default Vsync code -- look for non-display interval
;*
	pushad

	and	dword ptr [hi_time],0ffffh ; clear hi order bit in hi order time word
					   ; (so we don't have to worry about overflow...)
					   ; this means frame timer won't work beyond ~ 40 minutes

	mov	[TimeLimit],132		; normal delay time (3.5 VGA scanlines)
	cmp	[_VideoMode],8
	jne	NDLoop
	mov	[TimeLimit],94		; a little shorter for mode 8 (2.5 VGA scanlines)

NDLoop:	sti
	mov	dx,CRTSTAT		; wait for display disable
	cli
	in	al,dx
	test	al,8
	jnz	RealSyncSeen		;   fast exit for Vsync seen
	test	al,1
	jz	NDLoop

	call	_GetTime		; 32-bit hardware time (1.19 MHz)
	mov	ecx,eax			; start time
	add	ecx,[TimeLimit]		; end time (one VGA scan line ~ 37.7)
	mov	ebx,[LastVsyncTime]
	add	ebx,[PostGap]		; max time to wait for vsync	

NDOff:	mov	dx,CRTSTAT		; time the off period
	in	al,dx
	test	al,8
	jnz	RealSyncSeen		;   fast exit for Vsync seen
	test	al,1
	jz	NDLoop			; display enable came on, start over
	call	_GetTime
	cmp	eax,ecx			; blank long enough?
	jae	NDISeen			;   yes

	cmp	eax,ebx			; been waiting too long ?
	jb	NDOff			;   no, keep waiting

DontRecord:
	mov	eax,[HuntForLockTime]	;   yes, pretend we saw NDI ...
	add	[LastVsyncTime],eax	;        ... one frame time after last one ...
	jmp	NDRet			;        ... and exit

RealSyncSeen:
	call	_GetTime
	mov	[LastVsyncTime],eax
	jmp	NDRet

NDISeen:
	mov	edx,ecx
	add	edx,20
	cmp	eax,edx			; is this a Windows interruption ?
	ja	DontRecord		;   maybe, don't record this vsync
	mov	[LastVsyncTime],eax	; remember time of this vsync

NDRet:	sti
	popad

VSRet:	ret				;   yes, we're done


;*
;* Timer based frame limiter
;*

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
