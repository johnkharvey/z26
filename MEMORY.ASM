; Memory space

ALIGN 4

RiotRam		db	128 dup (0)	; RIOT ram (must be initially zero) why??
TIA		db 	64 dup (0)	; TIA Registers (also should be zero)
		
TIADisplay	db	320 dup (?)	; Display as currently setup
CartRom		db	16384 dup (?)	; space for cartridge	

IFNDEF comfile
		db 	2048 dup (?)	;reserve space for stack
mystack		db	?		;top of	stack
ENDIF
