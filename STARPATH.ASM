;*
;* Starpath Supercharger support for z26
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-04-02 -- 32-bit

.data

; Starpath ROM Slices

SP_Scheme label dword			; table of bankswitch schemes
	dd	2*800h,3*800h
	dd	0*800h,3*800h
	dd	2*800h,0*800h
	dd	0*800h,2*800h
	dd	2*800h,3*800h
	dd	1*800h,3*800h
	dd	2*800h,1*800h
	dd	1*800h,2*800h

SPSlice0	dd	0
SPSlice1	dd	3*800h

SP_PrevAdr	dd	0

SP_RamWord label dword
SP_RamByte	db	0,0,0,0		; byte to write to RAM (pad to allow dword write)

Starpath	db	0		; global Starpath flag
SP_WriteEnable	db	0		; SC RAM write enabled

SP_PulseDelay	db	7		; # of cycles since last memory reference


.code

;*
;* set bankswitch scheme from bx
;*

SP_SetScheme macro

	push	eax
	shr	ebx,2
	setc	[SP_WriteEnable]
	and	ebx,7
	shl	ebx,3
	mov	eax,[SP_Scheme+ebx]
	mov	[SPSlice0],eax
	mov	eax,[SP_Scheme+ebx+4]
	mov	[SPSlice1],eax
	pop	eax

	endm

;*
;* Starpath initialization
;*

; <-- from init.asm

Init_Starpath:
	mov	[SPSlice0],0
	mov	[SPSlice1],3*800h
	mov	[Starpath],0
	mov	[SP_WriteEnable],0
	mov	[SP_RamByte],0
	mov	[SP_PulseDelay],7
	mov	[SP_PrevAdr],0
	ret

; <-- from banks.asm

SetStarpath:
	push	ebx
	mov	[_BSType],15
	mov	[Starpath],1
	mov	bl,0
	or	bl,040h
	mov	[RiotRam],bl			; Starpath loader does this I think
	
	SP_SetScheme

	pop	ebx
	ret

;*
;* Starpath exit routines
;*

StarpathLoadNotFound:
	popad
	mov	[_MessageCode],1	; Unable to find load
;	call	_ShowMessage
	jmp	GoDOS

StarpathRealJAM:
	popad
	mov	eax,[reg_pc]
	mov	[_cpu_pc],eax
	mov	[_MessageCode],2	; Starpath call @
;	call	_ShowMessage
	jmp	GoDOS

;*
;* Starpath jam handler (game jumped to ROM)
;*

StarpathJAM:
	pushad
	mov	eax,[reg_pc]
	and	eax,01fffh
	cmp	eax,01ff0h
	jne	SPJ1
	push	esi
	mov	esi,000faH
	and	esi,0ffffh

	mov	[debugflag],1
	call	ReadHardware
	mov	[debugflag],0

	mov	al,[esi]
	pop	esi
	mov	[_SC_ControlByte],al

	call	_cli_LoadNextStarpath

	mov	eax,[_SC_StartAddress]
	test	eax,eax
	je	StarpathLoadNotFound
	mov	[reg_pc],eax
	mov	bl,[_SC_ControlByte]		; bank switch scheme at startup
	or	bl,040h
	mov	[RiotRam],bl			; Starpath loader does this I think
	
	SP_SetScheme

	popad
	ret

SPJ1:
	cmp	eax,01ff1h
	jne	StarpathRealJAM

	call	_cli_ReloadStarpath

	mov	eax,[_SC_StartAddress]
	test	eax,eax
	je	StarpathLoadNotFound
	mov	[reg_pc],eax
	mov	bl,[_SC_ControlByte]		; bank switch scheme at startup
	or	bl,040h
	mov	[RiotRam],bl			; Starpath loader does this I think
	
	SP_SetScheme

	popad
	ret

;*
;* Starpath bankswitch macros
;*

SP_MapSlice macro
	push	ebx
	mov	ebx,esi
	and	ebx,0800h
	shr	ebx,9			; slice # we're in *4
	and	esi,07ffh		; mask low order bits
	add	esi,[SPSlice0 + ebx]	; point to proper ROM slice
	add	esi,offset _CartRom
	pop	ebx
	endm

;*
;* write byte to ram
;*

SP_WriteRam macro
local done

	cmp	[SP_PulseDelay],5	; pulse delay in range?
	jne	done			;	no

	push	esi
	SP_MapSlice
	mov	bl,[SP_RamByte]
	mov	[esi],bl		; write byte to memory
	pop	esi

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

	push	ebx

	and	esi,01fffh
	cmp	[SP_PulseDelay],5	; write pending?
	ja	pulsedone		;   no
	cmp	esi,[SP_PrevAdr]	; a new memory address?
	je	pulsedone		;   no, don't count it
	inc	[SP_PulseDelay]		;   yes, count it
	mov	[SP_PrevAdr],esi	; remember address for next time...

pulsedone:
	cmp	esi,01ff8h		; bankswitch request ?
	jne	notbank			;   no

	mov	bl,[SP_RamByte]		;   yes
	SP_SetScheme			; setup bankswitch scheme
	mov	[SP_PulseDelay],7	; cancel any pending writes

	jmp	done

notbank:
	test	esi,01000h		; adr in ROM?
	jz	done			;   no
	cmp	[SP_PulseDelay],5	; write pending?
	jbe	notrambyte		;   yes, don't reset pulse delay
	cmp	esi,010ffh		; triggering a RAM write?
	ja	notrambyte		;   no

	mov	[SP_RamWord],esi	;   yes, adr is the byte to write
	mov	[SP_PulseDelay],0	; start up the pulse delay counter
	mov	[SP_PrevAdr],esi	; set up prev address
	jmp	done

notrambyte:
	cmp	[SP_WriteEnable],0	; write enabled?
	jz	done			;   no

	SP_WriteRam			;   yes, write byte to memory

done:
	pop	ebx

	endm

;*
;* actual bankswitch code
;*

RBank_SP:
	cmp	[debugflag],0		; ignore memory cycles from disassembler
	jnz	debugread
	SP_Q_Adr
	test_hw_read
	SP_MapSlice
	ret

debugread:
	test_hw_read
	SP_MapSlice
	ret

WBank_SP:
	SP_Q_Adr
	test_hw_write
	ret

