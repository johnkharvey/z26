; sbdrv.asm -- z26 sound drivers
;              based on Asteroids v3.02 (c) 1997 by Chris Pile

; Mar 27, 1998 -- first release
;
; Apr  4, 1998 -- major overhaul, most functions that were in sb.c are now here
; (0.97)


;-----------------------------------------------------------------------------
;DMA equates
;-----------------------------------------------------------------------------

dma_mask	equ	0Ah
dma_mode	equ	0Bh
dma_flipflop	equ	0Ch
PIC0		equ	021h
PIC1		equ	0A1h
EOI0		equ	020h
EOI1		equ	0A0h

BUF_SIZE	equ	256	; DMA buffer size  (256 is maximum)

				;(8   gives an interrupt frequency of 31400/4  = 7850       hz)
				;(note:  8 is not recommended -- Cyrix 6x86 PR166 clogs here )
				;(       4 pretty much locks up the system all together )

				;(16  gives an interrupt frequency of 31400/8   = 3925      hz)
				;(32  gives an interrupt frequency of 31400/16  = 1962.5    hz)
				;(64  gives an interrupt frequency of 31400/32  =  981.25   hz)  
				;(128 gives an interrupt frequency of 31400/64  =  490.625  hz)
				;(256 gives an interrupt frequency of 31400/128 =  245.3125 hz)

FAIL		equ	0
SUCCESS		equ	1
SB_EXIT		equ	2


.CEND
.DATASEGMENT

_Sb_init	db	0	; mark Sound Blaster currently not in use
_sbBaseIOPort	dw	0
_sbDMAChan8Bit	db	0
_sbDSPVersion	dw	0
_sbIRQNumber	db	0
_sbTimeConstant	db	0

_DMABuf		   dw	0
_gDMABufNowPlaying dw	0
_DMABufToLoad	   dw	0

_sbDMAPage	db	0
_sbDMAOffset	dw	0

HiSpeedDMA	db	0	; use High Speed DMA (DSP 2.0+ & 3.xx)

old_int_x	dd	0

dsp_irq		db	0	;IRQ + 8 (or IRQ - 8 + 70h)
irq_mask	db	0	;Bit position of IRQ number
old_PIC0	db	0	;Save PIC0 contents
old_PIC1	db	0	;Save PIC1 contents

b_string	db	'BLASTER='

dma_address	dw	0
dma_length	dw	0
dma_page	dw	0


;-----------------------------------------------------------------------------
;DMA page port value tables
;-----------------------------------------------------------------------------

dma_0	db	87h
dma_1	db	83h
dma_2	db	81h
dma_3	db	82h


.DEND
.CODESEGMENT

sbDataSegSave	dw	0		; gets copy of DS (set by SetISR)


;*
;* DmaISR() -- Sound Blaster interrupt handler
;*

_DmaISR:

sound_int:
	push	ax
	push	dx
	push	ds

	mov	ax,[cs:sbDataSegSave]	; set up by SetISR
	mov	ds,ax
	mov	dx,[_sbBaseIOPort]
	add	dx,14
	in	al,dx			; ACK the Sound Blaster
	xor	[_gDMABufNowPlaying],BUF_SIZE/2

	mov	ax,[_DMABufToLoad]
	cmp	ax,[_gDMABufNowPlaying]	; buffer ready for filling ?
	je	xFB_Done		;   no

	pushad
	
	call	_GetTime		; keep time up to date

	call	_Tia_process		; fill buffer
	xor	[_DMABufToLoad],BUF_SIZE/2

	popad

xFB_Done:
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


;*
;* SetISR() -- set up interrupt handler
;*

_SetISR:

	pushf				;save INTs
	cli

	mov	ax,ds
	mov	[cs:sbDataSegSave],ax	; save DS where ISR can find it

	mov	al,11111110b		;Shifter for IRQ mask
	mov	bl,_sbIRQNumber		
	mov	cl,bl			;Get IRQ

	add	bl,8			;Calc INTERRUPT address (0-7)

	cmp	cl,7			;Doing INTs 0-7?
	jbe	low_ints		;Yes
	sub	cl,8			;Adjust for higher INTs
	sub	bl,16
	add	bl,70h			;Adjust for higher INTs ;-)

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
	popf				; restore INTs
	ret


;*
;* turn off the Sound Blaster
;*

_sound_clear:

	mov	al,[_Sb_init]
	test	al,al
	jz	was_no_sound

	pushf				;save INTs
	cli
	cmp	[HiSpeedDMA],0		; Hi-Speed DMA
	je	LowSpeedClear		;   no
	call	_ResetDSP		;   yes, Reset to stop DMA
	mov	ah,0D3h			;Speaker off
	call	send_dsp
	jmp	FinishClear
	

LowSpeedClear:
	mov	ah,0D3h			;Speaker off
	call	send_dsp
	mov	ah,0D0h			;Halt DMA
	call	send_dsp
	mov	ah,0DAh			;Exit AUTO-INIT
	call	send_dsp
	mov	ah,0D0h			;Halt DMA
	call	send_dsp

FinishClear:
	call	_ResetDSP		;restore DSP to default state

	popf				;restore INTs
	ret


;*
;* RestoreISR() -- restore old interrupt handler
;*

_RestoreISR:

	mov	al,[_Sb_init]
	test	al,al
	jz	was_no_sound

	call	_sound_clear		; turn off the Sound Blaster (again)
					; in case TIA missed it

; Hopefully by now, any pending interrupts have occured and have been ack'd.

	pushf				;save INTs
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
	popf				; restore INTs

was_no_sound:
	ret				;Done


;*
;* short int ResetDSP()
;*

_ResetDSP:

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
	mov	ax,FAIL			;Signal SB failed to init
;	popf				;Restore INTS
	ret				;Done

dsp_is_ready:
	sub	dx,4			;Point to READ port
	in	al,dx			;Read byte
	cmp	al,0AAh			;Is it this?
	jnz	dsp_fail		;No, so RESET failed
	mov	ax,SUCCESS
;	popf
	ret


;*
;* short int DSPRead()
;*

_DSPRead:

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


;*
;* DSPWrite(short int val)
;*

_DSPWrite:

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


;*
;* GetBlastEnv() -- parse BLASTER environment string
;*

_GetBlastEnv:

	call	get_blaster
	jz	GetBlastFail
	cmp	cl,7			; got all components
	jne	GetBlastFail		;   no
	cmp	bl,15			; IRQ > 15 ?
	ja	GetBlastFail		;   not allowed!
	cmp	bh,3			; DMA > 3 ?
	ja	GetBlastFail		;   not allowed!
	

	mov	[_sbBaseIOPort],dx
	mov	[_sbDMAChan8Bit],bh
	mov	[_sbIRQNumber],bl
	mov	ax,SUCCESS
	ret

GetBlastFail:
	mov	ax,FAIL
	ret


;-----------------------------------------------------------------------------
;Routine:  get_blaster
;Job:      Gets information from the BLASTER= environment variable
;Args:     None
;Returns:  Z=variable not found, NZ=found and DX=A var, BH=D var, BL=I var
;-----------------------------------------------------------------------------

get_blaster:

	push	ds			;Save
	push	es			;Save

	push	ds
	pop	es			; Make ES=DS

IFNDEF comfile
	mov	ax,psp
	mov	ds,ax			; DS points to psp
ENDIF

	mov	ax,ds:[2Ch]		; my assembler likes this segment override!
	mov	ds,ax			;Get pointer to environment string

	xor	si,si			;Zero environment offset
next_string:
	mov	di,offset b_string	;Point to our BLASTER string
	mov	cx,8			;Eight chars to compare
get_blast:
	mov	al,[si]			;Get char
	cmp	al,' '			;Space?
	jnz	got_first		;No, so continue
	inc	si			;Skip space
	jmp	get_blast		;Next char

got_first:
	test	al,al			;Zero?
	jnz	check_string		;No, so continue
	inc	si			;Skip zero
	mov	al,[si]			;Get char
	test	al,al			;Zero?
	jnz	next_string		;No, so continue with next string
	pop	es			;Restore
	pop	ds			;Restore
	ret				;Return ZERO, variable not found

skip_to_upper:
	mov	al,[si]			;Get char
	cmp	al,' '			;Space?
	jnz	to_upper		;No, so continue
skip_inc_toupper:
	inc	si			;Skip space
	jmp	skip_to_upper		;Repeat check
to_upper:
	cmp	al,'a'
	jb	no_convert		;Below 'a' no uppercase conversion
	cmp	al,'z'
	ja	no_convert		;Above 'z' no uppercase conversion
	and	al,223			;Convert lower to uppercase
no_convert:
	test	al,al			;Set zero if end of string
	ret				;Done

check_string:
	call	skip_to_upper		;Skip spaces and convert uppercase
	cmp	al,es:[di]		;Same as char in our string?
	jz	chars_match		;Yes, so continue
to_zero:
	mov	al,[si]			;Get char
	test	al,al			;Zero?
	jz	next_string		;Yes, so check next string
	inc	si			;Next char
	jmp	to_zero			;Repeat check
chars_match:
	inc	si			;Next char
	inc	di			;Next char
	loop	check_string		;Loop for 8 characters
;-----------------------------------------------------------------------------
;Now get the A, D and I components
;-----------------------------------------------------------------------------
get_components:
	cmp	cl,7			;Got all components?
	jnz	more_components		;Not yet!
	jmp	got_all			;Yes!

more_components:
	call	skip_to_upper		;Get component
	jz	end_of_variable		;End of string

	cmp	al,'A'			;Address?
	jnz	not_address		;No
	or	cl,2			;Signal A
	call	skip_inc_toupper	;Skip any spaces
	jz	end_of_variable		;End of string
;-----------------------------------------------------------------------------
;Convert HEX ASCII pointed to by SI into DX
;-----------------------------------------------------------------------------
	xor	dx,dx			;Zero total
hex_loop:
	mov	al,[si]			;Get digit
	cmp	al,'0'
	jb	get_components		;Below 0 so number ends
	cmp	al,'9'
	jbe	hex_num
	call	to_upper		;Above 9 so check for A-F
	cmp	al,'A'
	jb	get_components		;Below A so number ends
	cmp	al,'F'
	ja	get_components		;Above F so number ends
	sub	al,7			;Sub differene
hex_num:
	sub	al,'0'			;Sub ASCII code
	shl	dx,4			;Last val * 16
	add	dl,al
	adc	dh,0			;Add in new value
	inc	si			;Next ASCII digit
	jmp	hex_loop		;Do it


;-----------------------------------------------------------------------------
;Convert the ASCII decimal number pointed to by SI into AH (only 8 bit)
;-----------------------------------------------------------------------------
get_decimal:
	xor	ah,ah			;Zero total
decimal_loop:
	mov	al,[si]			;Get digit
	cmp	al,'0'
	jb	decimal_done		;Below 0 so number ends
	cmp	al,'9'
	ja	decimal_done		;Above 9 so number ends
	sub	al,'0'			;Sub ASCII code
	add	ah,ah			;Last val*2
	mov	ch,ah			;Save it
	add	ah,ah
	add	ah,ah			;Last val*8
	add	ah,ch			;Last val*10
	add	ah,al			;Plus new digit
	inc	si			;Next ASCII digit
	jmp	decimal_loop		;Do it
decimal_done:
	ret


end_of_variable:
	mov	cl,1			;Signal components missing
got_all:
	test	cl,cl			;NZ=Found!
	pop	es			;Restore
	pop	ds			;Restore
	ret

not_address:
	cmp	al,'D'			;DMA?
	jnz	not_dma			;No
	or	cl,1			;Signal D
	call	skip_inc_toupper	;Skip any spaces
	jz	end_of_variable		;End of string
	call	get_decimal		;Get the DMA number
	mov	bh,ah			;Save it
	jmp	get_components		;Next component

not_dma:
	cmp	al,'I'			;IRQ?
	jz	get_irq			;Yes
	inc	si			;Skip this char
	jmp	get_components
get_irq:
	or	cl,4			;Signal I
	call	skip_inc_toupper	;Skip any spaces
	jz	end_of_variable		;End of string
	call	get_decimal		;Get the IRQ number
	mov	bl,ah			;Save it
	jmp	get_components


;*
;* ProgramDSP() -- SB DSP oriented startup code
;*

_ProgramDSP:

	cmp	[_Sb_init],0		; using SoundBlaster?
	jz	NoProgramDSP		;   no

	pushf
	cli

	mov	ah,0D1h			;Speaker on
	call	send_dsp		;Send it
	mov	ah,40h			;Set time constant
	call	send_dsp		;Send it
	mov	ah,[_sbTimeConstant]	;256-(1000000 / playback_freq)
	call	send_dsp		;Send it

	mov	ah,48h			;Set buffer size (256 / 2) - 1
	call	send_dsp		;Send it
	mov	ah,BUF_SIZE/2 - 1	;Low
	call	send_dsp		;Send it
	mov	ah,0			;Hi
	call	send_dsp		;Send it

	mov	ah,1Ch			; assume normal AUTO-INIT mode
	cmp	[HiSpeedDMA],0		; hi-speed DMA ?
	je	SendDSPCommand		;   no, use normal AUTO-INIT
	mov	ah,090h			;   yes, use Hi-Speed AUTO-INIT

SendDSPCommand:
	call	send_dsp		;Send it

	popf

NoProgramDSP:
	ret				;Done


;*
;* SetupDMABuffer() -- do page change check
;*

_SetupDMABuffer:

	mov	ecx,offset _BaseDMABuf	; buffer offset
	xor	eax,eax
	mov	ax,ds			; buffer segment
	shl	eax,4
	add	eax,ecx			; physical address of DMA buffer
	mov	ebx,eax
	clc
	add	bx,BUF_SIZE - 1		; is end of buffer ...
	jnc	BaseOk			; ... in same page as start ?
	add	eax,BUF_SIZE		;   no, use next half of buffer
	add	cx,BUF_SIZE
BaseOk:	mov	[_sbDMAOffset],ax
	shr	eax,16
	mov	[_sbDMAPage],al
	mov	[_DMABuf],cx
	ret
	

;*
;* ProgramDMA() -- DMA controller oriented startup code
;*

_ProgramDMA:

	pushf
	cli

	mov	ch,[_sbDMAChan8Bit]	;preset DMA channel

; compute I/O addresses

	mov	al,ch			;Channel
	add	al,al			;Double for address port
	cbw				;Zero AH

	mov	[dma_address],ax	; Save it
	inc	al			;Up one for length port
	mov	[dma_length],ax		; Save it

	mov	bl,ch			;Channel
	xor	bh,bh			;Zero hi
	add	bx,offset dma_0		;Point to page value
	mov	al,[bx]			;Grab it
	mov	[dma_page],ax		; Save it

; program DMA controller

	mov	al,ch			;Channel
	or	al,4			; 4 + Channel
	out	dma_mask,al		;disable DMA

	xor	al,al
	out	dma_flipflop,al		;Clear flip-flop

	mov	al,ch			;Channel
	add	al,058h			; 58h + Channel
	out	dma_mode,al		;Set AUTO-INIT mode

	mov	dx,[dma_address]	; Point to dma_port
	mov	ax,[_sbDMAOffset]
	out	dx,al			;Buffer Lo
	mov	al,ah
	out	dx,al			;Buffer Hi

	mov	dx,[dma_page]		; Point to page port
	mov	al,[_sbDMAPage]		;Page
	out	dx,al

	mov	dx,[dma_length]		; Point to length port
	mov	al,BUF_SIZE - 1		;Low
	out	dx,al
	mov	al,0			;Hi    (256 byte buffer)
	out	dx,al

	mov	al,ch			;Channel
	out	dma_mask,al		;re-enable DMA

	popf

	ret


;*
;* int GetDSPVersion() -- get SB DSP version
;*

_GetDSPVersion:

	mov	ah,0e1h			; get DSP Version
	call	send_dsp
	call	_DSPRead		; major #
	push	ax
	call	_DSPRead		; minor #
	pop	bx
	mov	ah,bl			; combine
	ret


;*
;* int CheckBlaster() -- see if we have a blaster
;*                       if not, wait (keep trying reset)
;*

_CheckBlaster:

	call	_ShowBlasterWaiting	; output a message

CheckBlasterLoop:
	call	_ResetDSP		; knock-knock
	test	ax,ax
	jnz	CheckBlasterSuccess	;   Sound Blaster there!
	call	_kb_hit			; any keys pressed ?
	test	ax,ax
	jz	CheckBlasterLoop	;   no
	call	_get_char		;   yes, read it
	cmp	al,27			; an escape ?
	jne	CheckBlasterFail	;   no, just fail
	mov	ax,SB_EXIT
	ret
	
CheckBlasterFail:
	mov	ax,FAIL
	ret	

CheckBlasterSuccess:
	mov	ax,SUCCESS
	ret


;*
;* SetupSoundBlaster() -- the main startup routine
;*                        does everything needed to start up sound
;*			  except turning on DMA
;*

_SetupSoundBlaster:

	call	_GetBlastEnv		; parse environment string
	test	ax,ax			; 
	jz	SSB_Err1		;   error
	call	_CheckBlaster		; see if we have a Sound Blaster
	cmp	ax,SUCCESS
	jne	SSB_Err2		;   no

	call	_GetDSPVersion		; get DSP version
	mov	[_sbDSPVersion],ax	; save it
	cmp	ax,0200h		; DSP version >= 2.00?
	jb	SSB_Err3		;   no

	mov	[HiSpeedDMA],0		; assume normal DMA
	mov	bx,15700		; assume slowest playback speed
	cmp	ax,0200h		; DSP == 2.00 ?
	je	SSB_SetPlayback		;   yes, use slow speed
	cmp	[SoundMode],2		; forcing slow speed ?
	je	SSB_SetPlayback		;   yes
	mov	bx,31400		; assume faster playback freq
	cmp	ax,0400h		; DSP version >= 4.00?
	jge	SSB_SetPlayback		;   yes, normal DMA O.K.
	mov	[HiSpeedDMA],1		; DSP == 3.xx -- need Hi-Speed DMA
	mov	dx,[_sbBaseIOPort]
	add	dx,4
	mov	al,0eh			; select output filter register
	out	dx,al
	inc	dx			; point to mixer data port
	xor	al,al
	out	dx,al			; turn on output filter
SSB_SetPlayback:
	mov	[_playback_freq],bx
	mov	[_sample_freq],31400

	call	_Tia_sound_init		; init the Ron Fries code

	mov	al,193			; time constant for 15700 playback
	cmp	[_playback_freq],31400
	jne	SSB_Slow
	mov	al,225			; time constant for 31400 playback
SSB_Slow:
	mov	[_sbTimeConstant],al	; save

	cmp	[SoundMode],0
	jne	SSB_NoMsg
	call	_ShowBlasterDetected	; if verbose, show message

SSB_NoMsg:
	call	_SetupDMABuffer		; setup DMA buffer (page change check)

	mov	[_DMABufToLoad],BUF_SIZE/2	; init buffer flags
	mov	[_gDMABufNowPlaying],0


	call	_SetISR			; set up the interrupt vector
	call	_ProgramDMA		; program the DMA controller

					; do _ProgramDSP (turn on DMA) at last minute


	mov	[_Sb_init],1		; mark Sound Blaster in use
SSB_Done:
	xor	ax,ax			; normal return
	ret	

SSB_Exit:
	mov	ax,1			; signal program should exit
	ret

SSB_Err1:
	cmp	[SoundMode],0
	jne	SSB_Done
	call	_ShowBlasterEnvBad	; if verbose, show message
	jmp	SSB_Done

SSB_Err2:
	cmp	ax,SB_EXIT		; did user press escape
	je	SSB_Exit		;   yes
	cmp	[SoundMode],0
	jne	SSB_Done
	call	_ShowBlasterNotFound	; if verbose, show message
	jmp	SSB_Done

SSB_Err3:
	cmp	[SoundMode],0
	jne	SSB_Done
	call	_ShowBlasterTooOld	; if verbose, show message
	jmp	SSB_Done

