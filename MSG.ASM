; msg.asm -- z26 messages


.CEND
.DATASEGMENT

; ShowCopyright messages (note: only last message is terminated)

msg01	db	10, 10, 'z26 -- An Atari 2600 emulator (1.00)', 10
msg02	db	'Copyright (C) 1997-1998 by John Saeger', 10
msg03	db	'Home Page:  http://www.whimsey.com/z26', 10, 10
msg04	db	'    F1 -- reset      F2 -- select     F3 -- B/W        F4 -- Color', 10
msg05	db	'    F5 -- P0 easy    F6 -- P0 hard    F7 -- P1 easy    F8 -- P1 hard', 10
msg05a	db	'     p -- pause   ENTER -- resume    ESC -- quit        = -- PCX screen capture', 10, 10
msg06	db	'Player 0 controls: CTRL -- fire, Use arrow keys to move.', 10
msg07	db	'Player 1 controls:    n -- fire, s -- left, e -- up, f -- right, d -- down', 10, 10
msg08	db	'Command Line Switches (put before filename)', 10, 10
msg08a	db	' -0    -- player 0 hard, -1 -- player 1 hard', 10
msg10	db	' -r    -- do not wait for VGA retrace (full speed) ', 10
msg10a	db	' -r1   -- use old vertical sync code (if your system seems to hang)', 10
msg11	db	' -q    -- quiet (no sound)', 10
msg12	db	' -s    -- show sound diagnostic messages', 10
msg13	db	' -f<n> -- run emulator for <n> frames and display timing results', 10
msg14	db	' -d<n> -- use digital signal processing on sound (1=low, 2=high)', 10
msg15	db	' -v<n> -- video mode (0=70Hz, 1=60Hz, 2=60Hz narrow, 3=60Hz 204 scan lines)', 10
msg16	db	' -j<n> -- joystick (0=joystick off)', 10
msg17	db	' -c    -- show credits (please do!)', 10,'$'

; ShowCredits messages (note: only last message is terminated)

msg101	db	10, 'z26 is based on A26 version 0.15 (C) 1996 by Paul Robson (autismuk@aol.com).', 10, 10
msg102	db	'PCX screen capture is (C) 1997 by Ronnie Greene (ender@abts.net).', 10, 10
msg103	db	'Atari 2600 sound emulation is based on TIASound.', 10
msg103a	db	'(C) 1996 by Ron Fries (rfries@tcmail.frco.com).', 10, 10
msg104	db	'60Hz chained video modes courtesy of Jim Leonard (Trixter / Hornet).', 10
msg105	db	'                                                 (trixter@hornet.org)', 10, 10
msg106	db	'Sound drivers are based on Asteroids v3.02.', 10
msg107	db	'(C) 1997 by Chris Pile (pegasus@enterprise.net)', 10, 10
msg108	db	'z26 is provided without any warranty of any kind, either express or implied.', 10
msg109	db	'Neither John Saeger, nor anyone who has worked on the code, may be held', 10
msg110	db	'responsible for any damages caused by the use of z26.', 10, 10
msg111	db	'z26 is freeware and may not be sold.', 10, 10, 10, 10, 10, 10, '$'

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


.DEND
.CODESEGMENT

_ShowCopyright:
	push	offset msg01
	call	_put_str
	pop	cx
	ret


_ShowCredits:
	push	offset msg101
	call	_put_str
	pop	cx
	ret


_ShowChecksum:
	push	[_Checksum]
	call	_put_hex
	pop	cx
	ret

_ShowBlaster:
	push	offset msg201		; aren't you glad I wrote this in asm ?
	call	_put_str
	pop	cx
	push	[_sbBaseIOPort]
	call	_put_hex
	pop	cx
	call	_crlf

	push	offset msg202
	call	_put_str
	pop	cx
	movzx	ax,[_sbDMAChan8Bit]
	push	ax
	call	_put_dec
	pop	cx
	call	_crlf

	push	offset msg203
	call	_put_str
	pop	cx
	movzx	ax,[_sbIRQNumber]
	push	ax
	call	_put_dec
	pop	cx
	call	_crlf

	push	offset msg204
	call	_put_str
	pop	cx
	mov	ax,[_sbDSPVersion]
	shr	ax,8
	xor	ah,ah
	push	ax
	call	_put_dec
	pop	cx

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
	pop	cx
	call	_crlf
	ret


_PressKeyToContinue:
	push	offset msg301
	call	_put_str
	pop	cx
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
	pop	cx
	call	_PressKeyToContinue
	ret


_ShowBlasterNotFound:
	push	offset msg501
	call	_put_str
	pop	cx
	call	_PressKeyToContinue
	ret


_ShowBlasterTooOld:
	push	offset msg601
	call	_put_str
	pop	cx
	call	_ShowBlaster
	call	_PressKeyToContinue
	ret


_ShowBlasterDetected:
	push	offset msg701
	call	_put_str
	pop	cx
	call	_ShowBlaster
	push	offset msg702
	call	_put_str
	pop	cx
	push	_gDMABufSize		; DMA buffer size
	call	_put_dec
	pop	cx
	call	_crlf
	push	offset msg703
	call	_put_str
	pop	cx
	push	[_playback_freq]
	call	_put_dec
	pop	cx
	call	_crlf
	push	offset msg704
	call	_put_str
	pop	cx
	movzx	ax,[_sbTimeConstant]
	push	ax
	call	_put_dec
	pop	cx
	call	_crlf
	call	_PressKeyToContinue
	ret


_ShowBlasterWaiting:
	push	offset msg801
	call	_put_str
	pop	cx
	ret

;*
;* bad command line switch seen (char is in cl)
;*

BadSwitch:
	push	cx			; save bad switch
	push	offset msg901
	call	_put_str
	pop	cx
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
	pop	cx
	ret