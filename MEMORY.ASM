; Memory space

RiotRam		db 128 dup (0)		; RIOT ram		


ALIGN 4

CartRom		db 0a5h			; cartridge ROM (colour.bin)
 db 081h,085h,00fh,0a9h,003h,085h,00ah,0a9h,057h,085h,007h,0a0h,000h,088h,085h,002h,085h,001h,085h,000h,0a9h,02ah,08dh,095h,002h,0ach,084h,002h,0d0h,0fbh,084h
 db 002h,084h,000h,0a9h,024h,08dh,096h,002h,0adh,082h,002h,029h,001h,0d0h,001h,000h,0e6h,080h,0d0h,00ah,0a9h,0e0h,085h,080h,0e6h,081h,0a5h,081h,085h,006h,0ach,084h
 db 002h,0d0h,0fbh,084h,002h,084h,001h,0a2h,0e4h,084h,002h,086h,00eh,086h,007h,0cah,0d0h,0f7h,04ch,000h,0f0h,0e0h,085h,080h,0e6h,081h,0a5h,081h,085h,006h,0ach,084h
 
ALIGN 4
 
IFNDEF comfile
		db 	16384 dup (0)	;reserve space for cartridge
		db 	1024 dup (0)	;reserve space for stack
mystack		db	0		;top of	stack
ENDIF
