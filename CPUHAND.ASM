;*
;* cpu memory and register handlers -- used by the CPU emulator
;*

.CEND
.DATASEGMENT

VBlanking	dd	-1		; 0 if vblanking, -1 otherwise
VBlank		db	0		; VBlank flag
VSyncFlag	db	0		; VSync flag

Ret0F		db	0Fh
RetWd		db	0		; byte returned from collision read

;*** keep these in order ***

DumpPorts	db	0,0,0,0		; Input ports (inp0..3)

InputLatch	db	080h		; Input latch (inp4)
		db	080h		; Input latch (inp5)
	   
.DEND
.CODESEGMENT


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
					        

ReadTIA:
	and	si,0Fh
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
	cmp	si,0ch
	jb	ReadDumped
	and	si,1
	add	si,offset InputLatch
	ret
	
ReadDumped:
	and	esi,3
	mov	edx,[ChargeTrigger0 + esi*4]
	cmp	edx,[ChargeCounter]	; this trigger expired ?
	jbe	TriggerExpired		;   yes
RetZero:mov	[RetWd],0
	mov	si,offset RetWd
	ret

TriggerExpired:
	cmp	dword ptr [PaddleGame],0; if not a paddle game
	je	RetZero			;   always return zero (astrblst)
	mov	[RetWd],080h
	mov	si,offset RetWd
	ret
	


; *****************************************************************************
;   Memory mapping - Write. On Entry , si contains the address and [WByte]
;   the data. WSYNC and VSYNC are handled here as they affect the CPU timing
; *****************************************************************************


WriteHardware:
	cmp	si,0400h		; if > 400h don't write (ROM there)
	jae	WHret
	cmp	si,0200h		; writing to the RIOT ?
	jae	WriteRIOT
WriteHardwarePage0:
	and	si,0FFh
	cmp	si,080h			; writing to the TIA ?
	jb	WriteTIA		;   yes
	mov	dl,[WByte]		; writing to RAM
	mov	[RiotRam-128 + si],dl
WHret:	ret


WriteTIA:
	and	si,03Fh
	cmp	si,04h			; writing to a sync register
	jb	WrTiaImmediate		;   yes, handle immediately
	cmp	si,02ch			; check range
	ja	XTRet			;  all other TIA commands are written to a
	push	bx			; 'TIA change' buffer which records them
	push	ax

;	jmp	TIARegular

	cmp	si,014h			; RESxx ?
	ja	TIARegular		;   no
	cmp	si,010h
	jb	TIARegular		;   no

	cmp	[RClock],22		; cycle 22 or greater ?
	jae	TIARegular		;   yes
	mov	al,22*3			;   no, treat as cycle 22
	jmp	TIAComputeOffset

TIARegular:
	mov	al,[RClock]
	add	al,al
	add	al,[RClock]		; clock * 3
TIAComputeOffset:
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
	test	[VSyncFlag],2		; somebody hitting Vsync more than necessary?
	jnz	VSyncAlreadySet		;   yep
	mov	[ScanLine],1		; back to screen top
	inc	[Frame]			; new frame.
VSyncAlreadySet:
	mov	dx,[CFirst]
	cmp	dx,0			; forcing first line ?
	jz	ZRET			;   no, let vblank take care of it
	mov	[TopLine],dx
	add	dx,[MaxLines]
	mov	[BottomLine],dx
ZRET:	mov	dl,[WByte]
	mov	[VSyncFlag],dl	
 	Ret

;*
;* VBlank -- vertical blank set-clear
;*

WrTiaVBlank:
	mov	dl,[WByte]
	mov	[VBlank],dl
	test	dl,2			; setting or clearing ?
	jz	WVBClear		;   clearing
	cmp	[CFirst],0		; VBlank triggering new frame ?
	je	WTB_1			;   yes, don't mess with VBlanking
	mov	[VBlanking],0
	jmp	HandleDumpedInputs

WTB_1:
	mov	[TopLine],65535		;   setting -- turn off Tia
	call	TIABlank		; clear rest of screen
	jmp	HandleDumpedInputs

WVBClear:
	cmp	[CFirst],0		; VBlank triggering new frame ?
	je	WTB_2			;   yes, don't mess with VBlanking
	mov	[VBlanking],-1
	jmp	HandleDumpedInputs

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
	jmp	HandleDumpedInputs  


HandleDumpedInputs:
	test	[VBlank],080h		; discharging capacitors ?
	jz	HandleLatchedInputs	;   no
	mov	dword ptr [ChargeCounter],0 ;   yes, zero the line counter

HandleLatchedInputs:
	ret

