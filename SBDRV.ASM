; sbdrv.asm -- assembly language portion of z26 sound drivers
;              based in part on Asteroids v3.02 (c) 1997 by Chris Pile

; Mar 27, 1998 -- first release


EXTRN _sbBaseIOPort:word
EXTRN _sbDMAChan8Bit:word
EXTRN _sbDSPVersion:word
EXTRN _sbIRQNumber:byte

EXTRN _DMABuf:word
EXTRN _gDMABufNowPlaying:byte
EXTRN _Sb_init:byte
EXTRN _gHighSpeed:byte

global _DmaISR
global _SetISR
global _sound_clear
global _RestoreISR
global _ResetDSP
global _DSPRead
global _DSPWrite
global _SilenceBuffer

EOI0		equ	020h
EOI1		equ	0A0h
PIC0		equ	021h
PIC1		equ	0A1h

_gDMABufSize	equ	256	; must match definition in z.c
RESET_FAIL	equ	0	; must match FAIL and SUCCESS in sb.c
RESET_SUCCESS	equ	1


.CEND
.DATASEGMENT

old_int_x	dd	0

doing_high_ints	db	0
irq_mask	db	0
dsp_irq		db	0
old_PIC0	db	0
old_PIC1	db	0

.DEND
.CODESEGMENT


;*
;* DmaISR() -- Sound Blaster interrupt handler
;*

_DmaISR	proc near

sound_int:
	push	ax
	push	dx
	push	ds
	mov	ax,[cs:datasegsave]	; set up by SetNewInt9 in keyboard.asm
	mov	ds,ax
	mov	dx,[_sbBaseIOPort]
	add	dx,14
	in	al,dx			; ACK the Sound Blaster
	xor	[_gDMABufNowPlaying],1
	mov	al,32			; EOI command
	cmp	[_sbIRQNumber],7
	jle	low_int_only
	mov	dx,EOI1
	out	dx,al			; signal EOI on slave PIC
low_int_only:
	mov	dx,EOI0
	out	dx,al			; signal EOI on master PIC
	pop	ds
	pop	dx
	pop	ax
	iret

_DmaISR	endp


;*
;* SetISR() -- set up interrupt handler
;*

_SetISR proc near

	mov	[doing_high_ints],0	;Turn OFF

	mov	al,11111110b		;Shifter for IRQ mask
	mov	bl,_sbIRQNumber		
	mov	cl,bl			;Get IRQ

	add	bl,8			;Calc INTERRUPT address (0-7)

	cmp	cl,7			;Doing INTs 0-7?
	jbe	low_ints		;Yes
	sub	cl,8			;Adjust for higher INTs
	sub	bl,16
	add	bl,70h			;Adjust for higher INTs

	mov	[doing_high_ints],bl	;Turn ON

low_ints:
	rol	al,cl			;Shift mask
	mov	[irq_mask],al		;Save it
	mov	[dsp_irq],bl		;Save it

;-----------------------------------------------------------------------------
;Next setup our IRQ interrupt handler, this is called when SB ends playing	
;-----------------------------------------------------------------------------

	push	es			;Save ES
	mov	ah,35h			;Get INT
	mov	al,[dsp_irq]		;Get IRQ Number
	push	ax			;Save IRQ number
	int	21h			;Get it
	mov	word ptr [old_int_x],bx   ;Save OLD INT x offset
	mov	word ptr [old_int_x+2],es ;Save OLD INT x segment

	mov	al,[dsp_irq]		;IRQ Number
	push	ds			; save DS
	push	cs
	pop	ds			; segment adr of ISR
	mov	dx,offset sound_int	;Point to our handler (DS:DX)

	mov	ah,25h			;Set INT x
	int	21h			;Set it

	pop	ds			; restore DS
	pop	ax			;Restore IRQ number
	pop	es			;Restore ES

	cmp	al,70h			;Doing Higher INT's?
	jb	set_low_PIC		;No, so set low PIC

	in	al,PIC1			;Get PIC1 contents
	mov	[old_PIC1],al		;Save it
	and	al,[irq_mask]		;CLEAR it (enables)
	out	PIC1,al			;Set SLAVE
	in	al,PIC0			;Get PIC0 contents
	mov	[old_PIC0],al		;Save it
	and	al,11111011b		;Set slave enable
	out	PIC0,al			;Enable high INT's
	jmp	INT_all_done		;Done

set_low_PIC:
	in	al,PIC0			;Get PIC0 contents
	mov	[old_PIC0],al		;Save it
	and	al,irq_mask		;PIC0 IRQ bit
	out	PIC0,al			;CLEAR it (enables)
	in	al,PIC1			;Get PIC1 contents
	mov	[old_PIC1],al		;Save it (easy switch off!!)

INT_all_done:
	ret

_SetISR endp


;*
;* turn off the Sound Blaster
;*

_sound_clear proc near

	mov	al,[_Sb_init]
	test	al,al
	jz	was_no_sound

	mov	al,[_gHighSpeed]
	test	al,al			; hi-speed DMA ?
	jz	Old_Clear		;   no
	call	_ResetDSP		;   yes, turn it off
	mov	ah,0D3h			;Speaker off
	call	send_dsp
	jmp	Finish_Clear

Old_Clear:
	mov	ah,0D3h			;Speaker off
	call	send_dsp
	mov	ah,0D0h			;Halt DMA
	call	send_dsp
	mov	ah,0DAh			;Exit AUTO-INIT
	call	send_dsp
	mov	ah,0D0h			;Halt DMA
	call	send_dsp

Finish_Clear:
	call	_ResetDSP		; restore DSP to default state
	call	_ResetDSP		; again for good luck
	ret

_sound_clear endp


;*
;* RestoreISR() -- restore old interrupt handler
;*

_RestoreISR proc near

	mov	al,[_Sb_init]
	test	al,al
	jz	was_no_sound

	call	_sound_clear		; turn off the Sound Blaster (again)
					; in case TIA missed it

; Hopefully by now, any pending interrupts have occured and have been ack'd.

	cli				;INT's OFF
	mov	al,[old_PIC0]		;Get original PIC0 mask
	out	PIC0,al			;Restore it
	mov	al,[old_PIC1]		;Get original PIC1 mask
	out	PIC1,al			;Restore it

	mov	ah,25h			;Set INT x
	mov	al,[dsp_irq]		;IRQ number
	push	ds			; save DS
	lds	dx,[old_int_x]		;Get old handler in DS:DX
	int	21h			;Set it
	pop	ds			; restore DS
	sti

was_no_sound:
	ret				;Done

_RestoreISR endp


;*
;* short int ResetDSP()
;*

_ResetDSP proc near

	mov	dx,[_sbBaseIOPort]
	add	dx,6			;Point to SB RESET port
sound_init:
	pushf				;Save INT status
	cli				;INTs off
	mov	al,1			;RESET request
	out	dx,al			;Send it
	mov	cx,10			;Short wait
init_wait:
	in	al,dx			;Wait
	loop	init_wait		;Another
	mov	ax,cx			;Clear RESET request
	out	dx,al			;Send it

	popf				; restore INTS
					; must do this here or we get odd
					; behavior of Win95 sound if it 
					; turns out that Win95 isn't finished
					; playing sound when we call this

	mov	dx,[_sbBaseIOPort]
	add	dx,0Eh			;Point to READY port
wait_for_dsp_ok:
	in	al,dx			;Read it
	test	al,al			;Ready yet?
	js	dsp_is_ready		;YES!
	loop	wait_for_dsp_ok		;No so try again
dsp_fail:
	mov	ax,RESET_FAIL		;Signal SB failed to init
;	popf				;Restore INTS
	ret				;Done

dsp_is_ready:
	sub	dx,4			;Point to READ port
	in	al,dx			;Read byte
	cmp	al,0AAh			;Is it this?
	jnz	dsp_fail		;No, so RESET failed
	mov	ax,RESET_SUCCESS
;	popf
	ret

_ResetDSP endp


;*
;* short int DSPRead()
;*

_DSPRead proc near

	mov	dx,[_sbBaseIOPort]
	add	dx,0Eh			; point at read-buffer status port
	xor	ah,ah
ReadDSPBusy:
	in	al,dx
	test	al,al			; data available ?
	jns	ReadDSPBusy		; bit 7 clear, so try again
	sub	dx,4			; point at read data port
	in	al,dx			; read the data
	ret


_DSPRead endp


;*
;* DSPWrite(short int val)
;*

_DSPWrite proc near

	pop	cx			; return adr
	pop	ax			; val
	push	ax			; restore stack
	push	cx
	mov	ah,al

send_dsp:
	mov	dx,[_sbBaseIOPort]
	add	dx,0Ch			; write-buffer status port
WriteDSPBusy:
	in	al,dx
	test	al,al			; ready for a write ?
	js	WriteDSPBusy		; bit 7 set, so try again
	mov	al,ah			; get data to write
	out	dx,al			; send the data
	ret

_DSPWrite endp


;*
;* SilenceBuffer()
;*

_SilenceBuffer proc near

	mov	cx,_gDMABufSize		; buffer size
	mov	al,080h			; Silence
	mov	di,[_DMABuf]
	rep	stosb			; Fill buffer
	ret

_SilenceBuffer endp