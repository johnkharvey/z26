; msg.asm -- z26 messages

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

.data

; ShowBlaster messages

msg201	db	'           I/O port: ', '$'
msg202	db	'          DMA 8-bit: ', '$'
msg203	db	'                IRQ: ', '$'
msg204	db	'        DSP Version: ', '$'

; PressKeyToContinue message

msg301	db	10, 'Press a key to continue, <esc> to exit...', 10, '$'

; ShowBlasterEnvBad message

msg401	db	'Problem with Sound Blaster environment string.', 10, '$'

; ShowBlasterNotFound message

msg501	db	'Sound Blaster not found.', 10, '$'

; ShowBlasterTooOld message

msg601	db	'Sound Blaster too old!', 10, 10, '$'

; ShowBlasterDetected messages

msg701	db	10, 'Sound Blaster detected.', 10, 10, '$'
msg702	db	'        Buffer Size: ', '$'
msg703	db	' Playback Frequency: ', '$'
msg704	db	'      Time Constant: ', '$'

; ShowBlasterWaiting message (note: only last message is terminated)

msg801	db	10, 'Waiting for Sound Blaster...', 10, 10
msg802	db	'Press <esc> to exit, any other key to continue with PC speaker sound.', 10, '$'

; BadSwitch message

msg901	db	10, 'Bad command line switch seen: -', '$'

; FileNotFound message

msg1001	db	10, 'File not found.', 10, '$'

; FramesPerSecond messages

fps		db	' fps',13,10,'$'


.code

_ShowBlaster:
	call	TIATextMode
	push	offset msg201		; aren't you glad I wrote this in asm ?
	call	_put_str
	push	[_sbBaseIOPort]
	call	_put_hex
	call	_crlf

	push	offset msg202
	call	_put_str
	movzx	ax,[_sbDMAChan8Bit]
	push	ax
	call	_put_dec
	call	_crlf

	push	offset msg203
	call	_put_str
	movzx	ax,[_sbIRQNumber]
	push	ax
	call	_put_dec
	call	_crlf

	push	offset msg204
	call	_put_str
	mov	ax,[_sbDSPVersion]
	shr	ax,8
	xor	ah,ah
	push	ax
	call	_put_dec

	mov	al,'.'
	call	ConOut

	mov	ax,[_sbDSPVersion]
	xor	ah,ah
	cmp	al,10
	jae	SB1

	mov	al,'0'
	call	ConOut

SB1:	mov	ax,[_sbDSPVersion]
	xor	ah,ah
	push	ax
	call	_put_dec
	call	_crlf
	ret


_PressKeyToContinue:
	call	TIATextMode
	push	offset msg301
	call	_put_str
	call	_get_char
	cmp	al,27
	je	PK_Exit
	ret

PK_Exit:
	mov	ah,04Ch			; return to MSDOS
	int	MSDOS


_ShowBlasterEnvBad:
	call	TIATextMode
	push	offset msg401
	call	_put_str
	call	_PressKeyToContinue
	ret


_ShowBlasterNotFound:
	call	TIATextMode
	push	offset msg501
	call	_put_str
	call	_PressKeyToContinue
	ret


_ShowBlasterTooOld:
	call	TIATextMode
	push	offset msg601
	call	_put_str
	call	_ShowBlaster
	call	_PressKeyToContinue
	ret


_ShowBlasterDetected:
	call	TIATextMode
	push	offset msg701
	call	_put_str
	call	_ShowBlaster
	push	offset msg702
	call	_put_str

	mov	ax,BUF_SIZE
	push    ax		; DMA buffer size

	call	_put_dec
	call	_crlf
	push	offset msg703
	call	_put_str
	push	[_playback_freq]
	call	_put_dec
	call	_crlf
	push	offset msg704
	call	_put_str
	movzx	ax,[_sbTimeConstant]
	push	ax
	call	_put_dec
	call	_crlf
	call	_PressKeyToContinue
	ret


_ShowBlasterWaiting:
	call	TIATextMode
	push	offset msg801
	call	_put_str
	ret


;*
;* frames per second
;*

FramesPerSecond:
	call	TIATextMode

	mov	eax,[OriginalFrameExit]
	mov	ebx,119318166		;119318200 ticklets per second (14318180/12) * 100
	mul	ebx
	mov	ebx,[StopTicks]
	div	ebx
	push	ax
	call	_put_point

	push	offset fps
	call	_put_str

	ret
