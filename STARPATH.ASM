;*
;* Starpath Supercharger support for z26
;*

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

.data

SP_PulseDelay	dw	7		; # of cycles since last memory reference

; Starpath ROM Slices

SP_Scheme label word			; table of bankswitch schemes
	dw	2*800h,3*800h
	dw	0*800h,3*800h
	dw	2*800h,0*800h
	dw	0*800h,2*800h
	dw	2*800h,3*800h
	dw	1*800h,3*800h
	dw	2*800h,1*800h
	dw	1*800h,2*800h

SPSlice0	dw	0
SPSlice1	dw	3*800h

SP_PrevAdr	dw	0

SP_RamWord label word
SP_RamByte	db	0,0		; byte to write to RAM (pad to allow word write)

Starpath	db	0		; global Starpath flag
SP_Loads	db	0		; # of loads in memory
SP_WriteEnable	db	0		; SC RAM write enabled

star_msg db	'Starpath call ','$'

.code

;*
;* set bankswitch scheme from bx
;*

SP_SetScheme macro

	push	ax
	shr	bx,2
	setc	[SP_WriteEnable]
	and	bx,7
	shl	bx,2
	mov	ax,[SP_Scheme+bx]
	mov	[SPSlice0],ax
	mov	ax,[SP_Scheme+bx+2]
	mov	[SPSlice1],ax
	pop	ax

	endm

;*
;* Starpath initialization
;*

; <-- from init.asm

Init_Starpath:
	mov	[SPSlice0],0
	mov	[SPSlice1],3*800h
	mov	[Starpath],0
	mov	[SP_Loads],0
	mov	[SP_WriteEnable],0
	mov	[SP_RamByte],0
	mov	[SP_PulseDelay],7
	mov	[SP_PrevAdr],0
	ret

; <-- from banks.asm

SetStarpath4:				; 4 loads (max)
	mov	[SP_Loads],4
	jmp	SetStarpath

SetStarpath3:				; 3 loads
	mov	[SP_Loads],3
	jmp	SetStarpath

SetStarpath2:				; 2 loads
	mov	[SP_Loads],2
	jmp	SetStarpath

SetStarpath1:				; 1 load
	mov	[SP_Loads],1
	jmp	SetStarpath

SetStarpath:
	push	bx
	mov	[ReadBank], offset RBank_SP
	mov	[WriteBank], offset WBank_SP
	mov	[Starpath],1
;	mov	bx, word ptr [_CartRom + 02000h]; pick up start adr
;	mov	[reg_pc],bx			; tell CPU where to go
	mov	[_CartRom + 01800h],052h	; plant Starpath JAM at ROM entry point
	mov	bl,[_CartRom + 02002h]		; bank switch scheme at startup
	or	bl,040h
	mov	[RiotRam],bl			; Starpath loader does this I think
	
	SP_SetScheme

	pop	bx
	ret

;*
;* Starpath jam handler (game jumped to ROM)
;*

StarpathJAM:
	call	TIATextMode
	push	offset star_msg
	call	_put_str
	mov	al,'@'
	call	ConOut
	mov	ax,[reg_pc]
	call	ConWord		; display address

StarWaitEsc:
	test	[KeyTable+KeyEsc],128	; wait for ESC to be pressed
	jz	StarWaitEsc

	jmp	GoDOS

;*
;* Starpath bankswitch macros
;*

SP_MapSlice macro
	push	bx
	mov	bx,si
	and	bx,0fffh
	shr	bx,11			; slice # we're in
	shl	bx,1			; *2
	and	si,07ffh		; mask low order bits
	add	si,[SPSlice0 + bx]	; point to proper ROM slice
	add	si,offset _CartRom
	pop	bx
	endm

;*
;* write byte to ram
;*

SP_WriteRam macro
local done

	cmp	[SP_PulseDelay],5	; pulse delay in range?
	jne	done			;   no

	push	si
	SP_MapSlice
	mov	bl,[SP_RamByte]
	mov	[si],bl			; write byte to memory
	pop	si

	mov	[SP_PulseDelay],7	; cancel write in progress

	cmp	[_TraceCount],0
	jz	done

	pushad
	call	_ShowSCWrite
	popad

done:
	endm

;*
;* process current address
;*

SP_Q_Adr macro
local done, notbank, notrambyte, pulsedone

	push	bx

	and	si,01fffh
	cmp	[SP_PulseDelay],5	; write pending?
	ja	pulsedone		;   no
	cmp	si,[SP_PrevAdr]		; a new memory address?
	je	pulsedone		;   no, don't count it
	inc	[SP_PulseDelay]		;   yes, count it
	mov	[SP_PrevAdr],si		; remember address for next time...

pulsedone:
	cmp	si,01ff8h		; bankswitch request ?
	jne	notbank			;   no

	mov	bl,[SP_RamByte]		;   yes
	SP_SetScheme			; setup bankswitch scheme
	mov	[SP_PulseDelay],7	; cancel any pending writes

	jmp	done

notbank:
	test	si,01000h		; adr in ROM?
	jz	done			;   no
	cmp	[SP_PulseDelay],5	; write pending?
	jbe	notrambyte		;   yes, don't reset pulse delay
	cmp	si,010ffh		; triggering a RAM write?
	ja	notrambyte		;   no

	mov	[SP_RamWord],si		;   yes, adr is the byte to write
	mov	[SP_PulseDelay],0	; start up the pulse delay counter
	mov	[SP_PrevAdr],si		; set up prev address
	jmp	done

notrambyte:
	cmp	[SP_WriteEnable],0	; write enabled?
	jz	done			;   no

	SP_WriteRam			;   yes, write byte to memory

done:
	pop	bx

	endm

;*
;* actual bankswitch code
;*

TraceAddress macro
local done
	cmp	[_TraceCount],0
	jz	done

	push	bx
	mov	[_adr],si
	mov	bx,[SP_PulseDelay]
	mov	[_prevadr],bx
	pop	bx
	pushad
	call	_Showaddress
	popad
done:
	endm

RBank_SP:
	cmp	[debugflag],0		; ignore memory cycles from disassembler
	jnz	debugread
;	TraceAddress
	SP_Q_Adr
	test_hw_read
	SP_MapSlice
	ret

debugread:
	test_hw_read
	SP_MapSlice
	ret

WBank_SP:
;	TraceAddress
	SP_Q_Adr
	test_hw_write
	ret

