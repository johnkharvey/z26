;*
;* cpu memory and register handlers -- used by the CPU emulator
;*

;*
;* Hardware I/O address bits
;*
;* Dan Boris' 2600 schematics show the TIA and RIOT chips hooked up to the
;* CPU with the following address lines hooked up.
;*
;*   12 | 11  10  09  08 | 07  06  05  04 | 03  02  01  00 
;* 
;*    X                     X                                TIA
;*    X            X        X                                RIOT
;*
;* If the 2000h bit (bit 12) is set, it's a ROM access.  This is handled
;* in banks.asm and we'll never come here.
;*
;* Otherwise it's a hardware access.
;*
;* If the 200h bit is     set and the 80h bit is     set then it's a RIOT access.
;* If the 200h bit is not set and the 80h bit is     set then it's a RAM access.
;* If the 200h bit is not set and the 80h bit is not set then it's a TIA access.
;*

.data

;MagicNoise	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0fh,0fh		; old z26 does this
;MagicNoise	db 0,1,0,13h,1,1,1,1,8,0,0,0,0,0,0fh,0fh	; PCAE does this
;MagicNoise	db 0,1,2,3,4,5,6,0,7fh,7fh,7fh,7fh,7fh,7fh,0eh,0fh ; Stella 1.1 does this
MagicNoise	db 0,1,0,  0,1,1,1,1,8,0,0,0,0,0,0fh,0fh		; we do this...
								; congbong needs 0 at disp 3
								; berzerk is a little happier too...

RT_Reg	dw	0			; TIA reg to read (ReadCollision)

RetWd		db	0		; byte returned from hardware read
		db	0		; pad to a word

.code

; *****************************************************************************
;  Memory Mapping - Read - 
;  For non-rom areas, si contains the requested address. 
;  On exit ds:[si] points to the actual required data.
; *****************************************************************************

ReadHardware:
	test	si,0200h		; possible RIOT read?
	jnz	ReadRiotMaybe		;   yes

ReadHardwarePage0:
	test	si,080h			; RAM Read?
	jz	ReadTIA			;   no
	and	si,0ffh
	add	si,offset RiotRam-128
	ret

ReadRiotMaybe:
	test	si,080h
	jnz	ReadRIOT

ReadTIA:
	push	ax
	and	si,0fh
	mov	al,[MagicNoise+si]	; start out with the undocumented magical noise
	mov	[RetWd],al		; results get OR'd into this
	pop	ax
	cmp	si,08h			; reading collision registers ???
	jb	ReadCollision
	cmp	si,0Eh
	jb	ReadInputLatches

	mov	si,offset RetWd
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
	or	[RetWd],al		; save word for returning
	pop	cx

	RestoreCPUState

	mov	si,offset RetWd
	ret


ReadInputLatches:			; read the input latch
	cmp	si,0ch
	jb	ReadDumped
	and	si,1
	add	si,offset InputLatch
	push	ax
	mov	al,[si]
	or	[RetWd],al
	pop	ax
	mov	si,offset RetWd
	ret
	
ReadDumped:
	and	esi,3
	mov	edx,dword ptr [ChargeTrigger0 + esi*4]
	cmp	edx,dword ptr [ChargeCounter]	; this trigger expired ?
	jbe	TriggerExpired			;   yes
RetZero:or	[RetWd],0
	mov	si,offset RetWd
	ret

TriggerExpired:
	cmp	dword ptr [_PaddleGame],0	; if not a paddle game
	je	RetZero				;   always return zero (astrblst)
	or	[RetWd],080h
	mov	si,offset RetWd
	ret
	


; *****************************************************************************
;   Memory mapping - Write. 
;   On Entry , si contains the address and [WByte] the data.
; *****************************************************************************


WriteHardware:
	test	si,0200h		; possible RIOT write?
	jnz	WriteRiotMaybe		;   yes

WriteHardwarePage0:
	test	si,080h			; RAM write?
	jz	NewTIA			;   no
	and	si,0ffh
	mov	dl,[WByte]		; writing to RAM
	mov	[RiotRam-128 + si],dl
	ret

WriteRiotMaybe:
	test	si,080h
	jnz	WriteRIOT
	jmp	NewTIA



