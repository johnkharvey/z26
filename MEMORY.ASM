; Memory space

ALIGN 4

RiotRam		db	128 dup (0)	; RIOT ram (must be initially zero) why??

db	0,0,0	; force PF0 onto a 4 byte boundary

TIA		db 	64 dup (0)	; TIA Registers (also should be zero)

.DEND
.DATASEGMENT

ALIGN 4
		
TIADisplay	db	320 dup (?)	; Display as currently setup

IFNDEF module
_CartRom	db	16384 dup (?)	; space for cartridge	
ENDIF

IFDEF exefile
		db 	2048 dup (?)	;reserve space for stack
mystack		db	?		;top of	stack
ENDIF

.DEND
.DATASEGMENT
