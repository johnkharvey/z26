; Memory space

.data

StartMemory	label	byte		; <- mark start of memory to be cleared

TIABuffer	db 256 dup (?)		; TIA information buffer
					; 128 just isn't big enough for some
					; trashed games.


KeyTable	db	128 dup (?)	; Key pressed table

RiotRam		db	128 dup (?)	; RIOT ram (must be initially zero)

db	0,0,0	; force PF0 onto a 4 byte boundary

TIA		db 	64 dup (?)	; TIA Registers (also should be zero)

PCXPalette 	db	128*3 dup (?)	; 384 -- generated palette goes here

TIADisplay	db	320 dup (?)	; Display as currently setup

_Ram		db	2048 dup (?)	; extra ram

Bit9		db	511 dup (?)	; for sound generation

ModeXBuffer	db	320+64 dup (?)	; for ModeX line rendering (a little extra here)

EndMemory	label	byte		; <- mark end of memory to be cleared

;PUBLIC _CartRom
;_CartRom	db	32768 dup (?)	; cartridge memory


