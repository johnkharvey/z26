;*
;* cpu memory and register handlers -- used by the CPU emulator
;*

.data

RT_Reg	dw	0			; TIA reg to read (ReadCollision)
RetWd	db	0
Ret0F	db	0fh
		        
.code

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
WSret:	ret
					        

ReadTIA:
;	and	si,01fh
;	cmp	si,018h
;	jb	ReturnAddress		; the warlords thingy...
					; has something to do with moonswep too...

	and	si,0Fh
	cmp	si,08h			; reading collision registers ???
	jl	ReadCollision
	cmp	si,0Eh
	jl	ReadInputLatches
	mov	si,offset Ret0F		; read the TIA (default)
	ret

ReturnAddress:
	cmp	si,0fh
	jae	RetAdrHi
	mov	si,offset Ret0F
	ret

RetAdrHi:
	push	ax
	mov	ax,si
	mov	[RetWd],al
	mov	si,offset RetWd
	pop	ax
	ret        

;*
;* read collision routine
;*

ReadCollision:				; read the collision latch

	mov	[RT_Reg],si
	SaveCPUState
	mov	dl,0
	call	CatchUpPixels		; render pixels up to the write clock

	push	cx
	mov	ax,[TIACollide]
	mov	cx,[RT_Reg]		; cx = address
	add	cl,cl			; shift it right 2 x address
	shr	ax,cl			; and do it....
	and	ax,3			; ax is now the 7,6 collide bits
	shl	al,6			; put them back in bits 7 and 6
	mov	[RetWd],al		; save word for returning
	pop	cx

	RestoreCPUState

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
	mov	edx,dword ptr [ChargeTrigger0 + esi*4]
	cmp	edx,dword ptr [ChargeCounter]	; this trigger expired ?
	jbe	TriggerExpired		;   yes
RetZero:mov	[RetWd],0
	mov	si,offset RetWd
	ret

TriggerExpired:
	cmp	dword ptr [_PaddleGame],0 ; if not a paddle game
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
	jb	NewTIA			;   yes
	mov	dl,[WByte]		; writing to RAM
	mov	[RiotRam-128 + si],dl
WHret:	ret

