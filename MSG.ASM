; msg.asm -- z26 messages


.CEND
.DATASEGMENT

; ShowCopyright messages (note: only last message is terminated)

msg01	db	10, 10, 'z26 -- An Atari 2600 emulator (1.13)', 10
msg02	db	'Copyright (C) 1997-1998 by John Saeger', 10
msg03	db	'Home Page:  http://www.whimsey.com/z26', 10, 10
msg04	db	'    F1 -- reset      F2 -- select     F3 -- B/W        F4 -- Color', 10
msg05	db	'    F5 -- P0 easy    F6 -- P0 hard    F7 -- P1 easy    F8 -- P1 hard', 10
msg05a	db	'     p -- pause   ENTER -- resume    ESC -- quit        = -- PCX screen capture', 10
msg05b	db	'  PgUp -- scroll screen up          PgDn -- scroll screen down', 10
msg05d	db	'  Home -- scroll screen to default position', 10, 10
msg06	db	'Player 0 controls: CTRL -- fire, Use arrow keys to move.', 10
msg07	db	'Player 1 controls:    n -- fire, s -- left, e -- up, f -- right, d -- down', 10, 10
msg08	db	'Command Line Switches (put before filename)', 10, 10
msg08a	db	' -0    -- player 0 hard, -1 -- player 1 hard', 10
msg10	db	' -r    -- run game at maximum speed', 10
msg10a	db	' -r<n> -- run game at <n> frames per second (<n> = 1 - 254 inclusive)', 10
msg11	db	' -q    -- quiet (no sound)', 10
msg15	db	' -v<n> -- video mode (0=70Hz, 1=60Hz, 2=60Hz narrow, 3=60Hz 204 scan lines)', 10
msg16	db	' -j<n> -- joystick (0=joystick off, 1=normal, 2=players reversed)', 10,10
msg18	db	'More options and credits may be found in readme.txt.', 10, '$'

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


.DEND
.CODESEGMENT

_ShowCopyright:
	push	offset msg01
	call	_put_str
	ret


_ShowChecksum:
	push	[_Checksum]
	call	_put_dhex
	ret

_ShowBlaster:
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
	push	offset msg401
	call	_put_str
	call	_PressKeyToContinue
	ret


_ShowBlasterNotFound:
	push	offset msg501
	call	_put_str
	call	_PressKeyToContinue
	ret


_ShowBlasterTooOld:
	push	offset msg601
	call	_put_str
	call	_ShowBlaster
	call	_PressKeyToContinue
	ret


_ShowBlasterDetected:
	push	offset msg701
	call	_put_str
	call	_ShowBlaster
	push	offset msg702
	call	_put_str
	push	BUF_SIZE		; DMA buffer size
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
	push	offset msg801
	call	_put_str
	ret

;*
;* bad command line switch seen (char is in cl)
;*

BadSwitch:
	push	cx			; save bad switch
	push	offset msg901
	call	_put_str
	pop	ax			; restore switch
	call	ConOut			; output it
	call	_crlf
	ret


;*
;* file not found
;*

FileNotFound:
	push	offset msg1001
	call	_put_str
	ret

;*
;* frames per second
;*

FramesPerSecond:

	mov	eax,[OriginalFrameExit]
	mov	ebx,119318200		; ticklets per second (14318180/12) * 100
	mul	ebx
	mov	ebx,[StopTicks]
	div	ebx
	push	ax
	call	_put_point

	push	offset fps
	call	_put_str

	ret
