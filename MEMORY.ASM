; Memory space

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

.data

StartMemory	label	byte		; <- mark start of memory to be cleared

KeyTable	db	128 dup (?)	; Key pressed table

RiotRam		db	128 dup (?)	; RIOT ram (must be initially zero)

db	0,0,0	; force PF0 onto a 4 byte boundary

TIA		db 	64 dup (?)	; TIA Registers (also should be zero)

;PCXPalette      db      128*3 dup (?)   ; 384 -- generated palette goes here

;TIADisplay	db	320 dup (?)	; Display as currently setup

_Ram		db	2048 dup (?)	; extra ram

Bit9		db	511 dup (?)	; for sound generation
SoundQ		db	(SQ_MAX + 2) dup (?)
_BaseDMABuf	db	BUF_SIZE*2+2 dup (?)	; Sound Blaster DMA buffer

;ModeXBuffer     db      320+64 dup (?)  ; for ModeX line rendering (a little extra here)

P2_Flags	db	8 dup (?)
P2_Counters	db	16 dup (?)
P2_Top		db	8 dup (?)
P2_Bottom	db	8 dup (?)
P2_Enable	db	8 dup (?)
P2_Music_Top	dw	8 dup (?)
P2_Music_Bottom	dw	8 dup (?)
P2_Music_Count	dw	8 dup (?)


EndMemory	label	byte		; <- mark end of memory to be cleared

;PUBLIC _CartRom
;_CartRom	db	32768 dup (?)	; cartridge memory


