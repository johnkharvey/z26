;*
;* frame synchronization code for z26
;*


CRTSTAT=	03dah			; CRT status register

.CEND
.DATASEGMENT

LastVsyncTime		dd	0		; when was last Vsync ?
FrameTime		dd	0
TicksPerSecond		dd	1193182		; 14318180/12
NominalFrameTime	dd	19886		; TicksPerSecond/60
PreGap			dd	12000		; more than half a frame...
PostGap			dd	20600		; a frame and a little gap
VsyncBrokenTime		dd	20200*16	; 16 bad frames, vsync broken
CurrentTime		dd	0		; temp store for current time
ReSyncFlag		db	1		; force re-sync (happens in video mode change)
BlindCount		db	0		; # of frames since last real vsync


; Nominal frame times for the various video modes for flying blind.
; These values are fairly precise.  
; We hardly ever need to see a real vsync.

VideoRateTable		dd	17104		; 0 -- 69.76 fps
			dd	19960		; 1 -- 59.78 fps
			dd	20050		; 2 -- 59.51 fps
			dd	20050		; 3 -- 59.51 fps
			dd	20074		; 4 -- 59.44 fps
			dd	20165		; 5 -- 59.17 fps
			dd	20165		; 6 -- 59.17 fps
			dd	20165		; 7 -- 59.17 fps
			dd	20128		; 8 -- 59.28 fps
			dd	20165		; 9 -- 59.17 fps (soft scan line -- not implemented yet)


.DEND
.CODESEGMENT

;*
;* start off on the right foot -- initialize VSYNC time
;*

ReSync:
	cmp	[NoRetrace],0			; did user specify a -r<n> param ?
	jnz	VSRet				;   yes, don't do this
	pushad
	movzx	eax,[_VideoMode]
	mov	eax,[VideoRateTable + eax*4]
	mov	[NominalFrameTime],eax		; put in frame time adjusted for video mode
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
	mov	[NoRetrace],60			; vsync broken, fall back to timed frames
	jmp	PopRet

;*
;* frame synchronizer
;*

VSync:	cmp	[NoRetrace],0ffh		; -r no param
	je	VSRet
	cmp	[NoRetrace],1
	jae	FrameLimiter			; -r<n>, n >= 1

	pushad					; default code -- look for Vsync pulse with a timeout

	and	dword ptr [hi_time],0ffffh 	; clear hi order bit in hi order time word
					   	; (so we don't have to worry about overflow...)
					   	; this means frame timer won't work beyond ~ 40 minutes
	cmp	[ReSyncFlag],0			; need to resync ?
	jz	RealVsyncLoop			;   no
	call	ReSync				;   yes
	mov	[ReSyncFlag],0
RealVsyncLoop:
	sti
	mov	dx,CRTSTAT
	cli
	in	al,dx
	test	al,8				; Vsync pulse on ?
	jnz	RealSyncSeen			;   yes
	call	_GetTime
	mov	[CurrentTime],eax
	sub	eax,[LastVsyncTime]
	cmp	eax,[PostGap]			; timed out ?
	jb	RealVsyncLoop			;   no, keep looking
VsyncAdjustLoop:
	mov	eax,[NominalFrameTime]		; we missed a Vsync, flying blind...
	add	[LastVsyncTime],eax		; adjust position of last vsync as if we've seen one
	mov	eax,[LastVsyncTime]
	cmp	eax,[CurrentTime]		; gone beyond current time?
	jbe	VsyncAdjustLoop			;   no, keep adjusting
	mov	eax,[NominalFrameTime]		;   yes, back off by one frame time
	sub	[LastVsyncTime],eax
	inc	[BlindCount]
	cmp	[BlindCount],60			; too many frames without a real vsync?
	jb	PopRet				;   no
	call	ReSync				;   yes, do a resync (should almost never happen)

PopRet:	
	sti
	popad
VSRet:	ret

RealSyncSeen:
	mov	[BlindCount],0
	call	_GetTime
	mov	[LastVsyncTime],eax		; mark time of current VSync
	sti
	popad
	ret

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
