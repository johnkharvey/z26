PAGE 66,132

; z26 -- Atari 2600 emulator
; portions copyright 1996 by Paul Robson
; portions copyright 1997 by John Saeger

; 01-09-97  --	first version
;		(ported from version 0.15 of Paul Robson's A26)

; 08-28-97  --  (0.8) first released version


; assembly time definitions

comfile =		1		; build a COM file 
memcheats =		1		; cheat	on 16-bit reads
dotiming =		1		; generate timing blips


	include defs.asm		; our definitions
	include	macros.asm		; our macros

	
IFNDEF comfile				; .EXE files get a stack segment
Stack SEGMENT PARA STACK 'STACK'
	DB 512 DUP (?)
Stack ENDS
ENDIF

.386					; yes!

.CODESEGMENT
IFDEF comfile
	org	0100h			; remember CP/M?
ENDIF   
entry:	jmp	start			; jump around our data
.CEND

.DATASEGMENT

	include data.asm		; da data

.DEND

.CODESEGMENT
	
	include cmdline.asm		; command line interpreter
	include console.asm		; console output (for debugging)
	include keyboard.asm		; convert keyboard into Atari joystick
	include sound.asm		; PC speaker support
	include graphics.asm		; VGA graphics initialization
	include cpu.asm			; 6502 opcodes and support routines
	include tia.asm			; <-- the main machine -- * start here *

.CEND

.DATASEGMENT

	include memory.asm		; RIOT ram, cart ROM, & optional stack

.DEND

	END	entry   
