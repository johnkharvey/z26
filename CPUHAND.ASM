; cpu memory and register handlers -- used by the CPU emulator

; *****************************************************************************
;     Memory Mapping - Read - For non-rom areas, si contains the requested
;	address. On exit ds:[si] points to the actual required data
; *****************************************************************************

ReadHardware:
	cmp	si,0200h		; is it the RIOT ???
	jge	ReadRIOT
ReadHardwarePage0:
	and	si,0FFh			; it must be the TIA or RAM
	cmp	si,080h			; is it the TIA ???
	jl	ReadTIA
	add	si,offset RiotRam-128	; point si to the riotram area
	ret
					        

ReadTIA:and	si,0Fh
	cmp	si,08h			; reading collision registers ???
	jl	ReadCollision
	cmp	si,0Eh
	jl	ReadInputLatches
	mov	si,offset Ret0F		; read the TIA (default)
	ret
        

ReadCollision:				; read the collision latch
	push	ax
	push	cx

	mov	ax,[TIACollide]
	mov	cx,si			; cx = address
	add	cl,cl			; shift it right 2 x address
	shr	ax,cl			; and do it....
	and	ax,3			; ax is now the 7,6 collide bits
	shl	al,6			; put them back in bits 7 and 6
	mov	[RetWd],al		; save word for returning

	pop	cx
	pop	ax
	mov	si,offset RetWd
	ret


ReadInputLatches:			; read the input latch
;	 call	 CheckPaddleLatches	; check the paddle latches
	add	si,offset DumpPorts-8
	ret
        


; *****************************************************************************
;   Memory mapping - Write. On Entry , si contains the address and [WByte]
;   the data. WSYNC and VSYNC are handled here as they affect the CPU timing
; *****************************************************************************


WriteHardware:
	cmp	si,0400h		; if > 400h don't write (ROM there)
	jge	WHret
	cmp	si,0200h		; writing to the RIOT ?
	jge	WriteRIOT
WriteHardwarePage0:
	and	si,0FFh
	cmp	si,080h			; writing to the TIA ?
	jl	WriteTIA		;   yes
	mov	dl,[WByte]		; writing to RAM
	mov	[RiotRam-128 + si],dl
WHret:	ret


WriteTIA:
	and	si,03Fh
	cmp	si,04h			; writing to a sync register
	jl	WrTiaImmediate		;   yes, handle immediately
	cmp	si,02ch			; check range
	jg	XTRet			;  all other TIA commands are written to a

	push	bx			; 'TIA change' buffer which records
	push	ax
	mov	al,[RClock]
	add	al,al
	add	al,[RClock]		; clock * 3
	sub	al,CycleOffset[si]	; - 68 or so (HBlank position)
	ja	XTIANotHBlank		; if < 0 its in HBlank area, ret 0
	xor	al,al			; (needed for nearly everything -- why?)
XTIANotHBlank:
	cmp	al,159			; must be < 160
	jb	XTIAOffRHS		; (needed for enduro -- but why?)
	mov	al,159
XTIAOffRHS:
	call	FindInsert		; do insertion in clock order
	mov	bx,[TIAWritePointer]
	mov	TIAClock[bx],al
	mov	al,[WByte]	        
	mov	TIAVal[bx],al
	mov	ax,si
	mov	TIAReg[bx],al
	pop	ax
	pop	bx
XTRet:	ret


WrTiaImmediate:
	shl	si,1
	jmp	[WrTiaImmediateVector + si]


; WSync -- wait for leading edge of horizontal blank

WrTiaWSync:
	cmp	[WrapWsync],0
	je	WrTiaWsyncSimple
	cmp	[RClock],CyclesPerScanLine
	ja	WrTiaSetSkip		; breaks yars, swarcade, sttagpro, surf_fix, smurfres
					; needed for crosfrce, astroidc, astroids

WrTiaWsyncSimple:
	mov	dl,CyclesPerScanLine
	sub	dl,[RClock]		; # of cycles left in line
	add	[RCycles],dl		; adjust instruction length
	add	[RClock],dl		; = CyclesPerScanLine
WSret:	ret

; WSync is actually at beginning of next line
; adjust timer and force ScanFrame to do next line with no CPU cycles

WrTiaSetSkip:
	sub	[RClock],CyclesPerScanLine
	mov	dl,CyclesPerScanLine
	sub	dl,[RClock]		; # of cycles left in next line
	add	[RCycles],dl		; adjust instruction length
	add	[RClock],dl		; = CyclesPerScanLine
	add	[RClock],dl		; = CyclesPerScanLine * 2
	ret


; VSync -- vertical sync set-clear

WrTiaVSync:
	test	[WByte],2		; if d1 is set then ....
	jz	ZRET
	mov	[ScanLine],1		; back to screen top
	inc	[Frame]			; new frame.
	mov	dx,[CFirst]
	cmp	dx,0			; forcing first line ?
	jz	ZRET			;   no, let vblank take care of it
	mov	[TopLine],dx
	add	dx,[MaxLines]
	mov	[BottomLine],dx
ZRET: 	Ret


; VBlank -- vertical blank set-clear

WrTiaVBlank:
	mov	dl,[WByte]
	mov	[VBlank],dl
	test	dl,2			; setting or clearing ?
	jz	WVBClear		;   clearing
	cmp	[CFirst],0		; VBlank triggering new frame ?
	je	WTB_1			;   yes, don't mess with VBlanking
	mov	[VBlanking],0
	ret

WTB_1:
	mov	[TopLine],65535		;   setting -- turn off Tia
	call	TIABlank		; clear rest of screen
	jmp	WVBRet

WVBClear:
	cmp	[CFirst],0		; VBlank triggering new frame ?
	je	WTB_2			;   yes, don't mess with VBlanking
	mov	[VBlanking],-1
	ret

WTB_2:
	mov	dx,[ScanLine]
	cmp	dx,[CFirst]
	jae	WVBPastMin
	mov	dx,[CFirst]
WVBPastMin:
	inc	dx
	mov	[TopLine],dx
	add	dx,[MaxLines]
	mov	[BottomLine],dx
WVBRet:	ret      

