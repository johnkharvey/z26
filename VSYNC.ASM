;*
;* frame synchronization code for z26
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

CRTSTAT=	03dah			; CRT status register

.data

NDIWait			dd	132		; (94,132,321) ticklets of NDI for a sync

LastVsyncTime		dd	0		; when was last Vsync ?
FrameTime		dd	0
TicksPerSecond		dd	1193182		; 14318180/12
NominalFrameTime	dd	19886		; TicksPerSecond/60
PreGap			dd	19000		; don't look for vsync before this
PreFlip			dd	18000		; don't flip mode 8 page before this
VsyncBrokenTime		dd	20200*16	; 16 bad frames, vsync broken
CurrentTime		dd	0		; temp store for current time
ReSyncFlag		db	1		; force re-sync (happens in video mode change)


.code

;*
;* start off on the right foot -- initialize VSYNC time
;*

ReSync:
	cmp	[_NoRetrace],0			; did user specify a -r<n> param ?
	jnz	VSRet				;   yes, don't do this
	pushad

	call	_GetTime
	mov	[CurrentTime],eax		; this is for testing for broken vsync...
ReSyncLoop:
	sti
	mov	dx,CRTSTAT
	cli
	in	al,dx
	test	al,8
	jnz	RealSyncSeen
	call	_GetTime
	sub	eax,[CurrentTime]
	cmp	eax,[VsyncBrokenTime]
	jb	ReSyncLoop
	mov	[_NoRetrace],60			; vsync broken, fall back to timed frames
	jmp	PopRet

;*
;* wait until pre-gap time (before calling frame sync)
;*

VS_PreGap:
	pushad
VS_ThrottleLoop:
	call	_GetTime		; prevent false alarms if running in a fast refresh mode (mode 8)
	sub	eax,[LastVsyncTime]	; (see vsync.asm for LastVsyncTime and PreGap)
	cmp	eax,[PreFlip]		; at least 7/8 of a frame or so since last Vsync?
	jb	VS_ThrottleLoop		;   no, keep waiting
	popad
	ret



;*
;* frame synchronizer
;*

VSync:	cmp	[_NoRetrace],0ffh		; -r no param
	je	VSRet
	cmp	[_NoRetrace],1
	jae	FrameLimiter			; -r<n>, n >= 1

	pushad					; default code -- look for display enable off long enough

	and	dword ptr [hi_time],0ffffh 	; clear hi order bit in hi order time word
					   	; (so we don't have to worry about overflow...)
					   	; this means frame timer won't work beyond ~ 40 minutes
	cmp	[ReSyncFlag],0			; need to resync ?
	jz	DoSync				;   no
	call	ReSync				;   yes
	mov	[ReSyncFlag],0

DoSync:
	cmp	[_VideoMode],0
	je	SetPG0
	mov	[PreGap],19000
	mov	[PreFlip],18000
	jmp	NDLoop

SetPG0:	mov	[PreGap],16000
	mov	[PreFlip],16000

NDLoop:	sti
	mov	dx,CRTSTAT		; wait for display disable
	cli
	in	al,dx
	test	al,8
	jnz	RealSyncSeen		; fast exit for Vsync seen
	test	al,1
	jz	NDLoop

	call	_GetTime		; 32-bit hardware time (1.19 MHz)
	mov	ecx,eax			; start time
	add	ecx,[NDIWait]		; (120) end time (one VGA scan line ~ 37.7)

NDOff:	mov	dx,CRTSTAT		; time the off period
	in	al,dx
	test	al,8
	jnz	RealSyncSeen		; fast exit for Vsync seen
	test	al,1
	jz	NDLoop			; display enable came on, start over
	call	_GetTime
	cmp	eax,ecx			; blank long enough?
	jb	NDOff			;   no, keep waiting

RealSyncSeen:
	call	_GetTime
	mov	[LastVsyncTime],eax	; mark time of current VSync
PopRet:	sti
	popad
VSRet:	ret


;*
;* Timer based frame limiter
;*

FrameLimiter:
	pushad

	mov	eax,[TicksPerSecond]
	xor	edx,edx
	movzx	ecx,[_NoRetrace]	; pick up # of frames per second
	div	ecx			; eax = # of ticks per frame
	add	[FrameTime],eax		; make it next frame time

FrameLimitLoop:
	test	[_KeyTable+KeyEsc],128	; ESC pressed ?
	jnz	FLRet			;   yes

	call	_GetTime
	cmp	eax,[FrameTime]
	jb	FrameLimitLoop

	mov	[FrameTime],eax		; mark new frame time

FLRet:	popad
	ret
