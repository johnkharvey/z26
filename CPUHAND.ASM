;*
;* cpu memory and register handlers -- used by the CPU emulator
;*

; z26 is Copyright 1997-2001 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

;*
;* Hardware I/O address bits
;*
;* Dan Boris' 2600 schematics show the TIA and RIOT chips hooked up to the
;* CPU with the following address lines hooked up.
;*
;*   12 | 11  10  09  08 | 07  06  05  04 | 03	02  01	00 
;* 
;*    X			    X				     TIA
;*    X		   X	    X				     RIOT
;*
;* If the 1000h bit (bit 12) is set, it's a ROM access.	 This is handled
;* in banks.asm and we'll never come here.
;*
;* Otherwise it's a hardware access.
;*
;* If the 200h bit is	  set and the 80h bit is     set then it's a RIOT access.
;* If the 200h bit is not set and the 80h bit is     set then it's a RAM access.
;* If the 200h bit is not set and the 80h bit is not set then it's a TIA access.
;*

.data

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
	jnz	ReadRiotMaybe		;	yes

ReadHardwarePage0:
	test	si,080h			; RAM Read?
	jz	ReadTIA			;	  no
	and	si,0ffh
	add	si,offset RiotRam-128
	ret

ReadRiotMaybe:
	test	si,080h
	jnz	ReadRIOT

ReadTIA:
	push	ax
        mov     al,[BusState]           ; set undefined bits depending
                                        ;   on the state of the data bus
        and     ax,03fh                 ; topmost two bits are always defined

ReadTIAZero:
        and     si,0fh
        mov	[RetWd],al		; results get OR'd into this
	pop	ax
	cmp	si,08h			; reading collision registers ???
	jb	ReadCollision
	cmp	si,0Eh
	jb	ReadInputLatches

	mov	si,offset RetWd		; return noisy word
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
	cmp	[_Lightgun],0		; *EST*
	je	RILnoLightgun
	push	ax
	mov	ax,[MLG_ShotLine]
	cmp	[ScanLine],ax
	jb	RILnoHit
	mov	al,[RClock]
	mov	ah,[MLG_ShotCycle]
	cmp	ah,[_LG_WrapLine]	; see mouse.asm
;	 cmp	 [MLG_ShotCycle],78	 ; 75-78
	jb	RILnoFix
	cmp	al,22
	ja	RILnoFix
	add	al,76
RILnoFix:
	cmp	al,[MLG_ShotCycle]

	jb	RILnoHit

	mov	[RetWd],07fh
	pop	ax
	mov	si,offset RetWd
	ret
RILnoHit:
	mov	[RetWd],0ffh
	pop	ax
	mov	si,offset RetWd
	ret	   

RILnoLightgun:
	and	si,1
	add	si,offset InputLatch
	push	ax
	mov	al,[si]
	
;        or      al,07fh                ; removed to fix Pigs in Space *EST*

	or	[RetWd],al
	pop	ax
	mov	si,offset RetWd
	ret
	
ReadDumped:
;        cmp     [_Checksum],072902h             ; duckshot.bin requires
;        je      RetZero                         ;   always zero *EST*
        cmp	[_MouseBase],0ffh		; use mouse as paddles ?
	jne	 RDump1				;   yes, check trigger
	cmp	dword ptr [_PaddleGame],0	; if not a paddle game
	je	RetDirect			;   get state directly *EST*
;	 je	 RetZero			 ;   always return zero (astrblst)
						; *EST*
RDump1:
	and	esi,3
	mov	edx,dword ptr [ChargeTrigger0 + esi*4]
	cmp	edx,dword ptr [ChargeCounter]	; this trigger expired ?
	jbe	TriggerExpired			;	  yes
RetZero:or	[RetWd],0
	mov	si,offset RetWd
	ret

TriggerExpired:
	or	[RetWd],080h
	mov	si,offset RetWd
	ret
	
RetDirect:
	and	si,3				; return state of dump port
	add	si,offset DumpPorts		;   directly (booster grip,
	push	ax				;   keypad etc) *EST*
	mov	al,[si]
	
;        or      al,07fh                ; removed to fix Pigs in Space *EST*

	or	[RetWd],al
	pop	ax
	mov	si,offset RetWd
	ret


; *****************************************************************************
;   Memory mapping - Write. 
;   On Entry , si contains the address and [WByte] the data.
; *****************************************************************************


WriteHardware:
	test	si,0200h		; possible RIOT write?
	jnz	WriteRiotMaybe		;	 yes

WriteHardwarePage0:
	test	si,080h			; RAM write?
	jz	NewTIA			;	 no
	and	si,0ffh
	mov	dl,[WByte]		; writing to RAM
	mov	[RiotRam-128 + si],dl
	ret

WriteRiotMaybe:
	test	si,080h
	jnz	WriteRIOT
	jmp	NewTIA



