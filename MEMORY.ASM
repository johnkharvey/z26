; Memory space



.DATASEGMENT

ALIGN 4

StartMemory	label	byte		; <- mark start of memory to be cleared

KeyTable	db	128 dup (?)	; Key pressed table

RiotRam		db	128 dup (?)	; RIOT ram (must be initially zero)

db	0,0,0	; force PF0 onto a 4 byte boundary

TIA		db 	64 dup (?)	; TIA Registers (also should be zero)
_Ram		db	256 dup (?)	; extra ram


TIADisplay	db	320 dup (?)	; Display as currently setup
_CartRom	db	16384 dup (?)	; cartridge memory
_BaseDMABuf	db	514 dup (?)	; Sound Blaster DMA buffer
_TraceBuffer	db	8192 dup (?)	; trace buffer

Bit9		db	511 dup (?)	

EndMemory	label	byte		; <- mark end of memory to be cleared

ALIGN 4

IFDEF exefile
		db 	2048 dup (?)	;reserve space for stack
mystack		db	?		;top of	stack
ENDIF

.DEND