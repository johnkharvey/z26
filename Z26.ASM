PAGE 66,132

; z26 -- Atari 2600 emulator
; Copyright (C) 1997-1998 by John Saeger

; Based on A26 version 0.15 by Paul Robson.

; assembly time definitions

; choose one of these:

;comfile =		1		; build a COM file
;exefile =		1		; build an EXE file
;module =		1		; build a C linkable module


	include defs.asm		; our definitions
	include	macros.asm		; our macros

	
IFDEF exefile				; .EXE files get a stack segment
Stack SEGMENT PARA STACK 'STACK'
	DB 512 DUP (?)
Stack ENDS
ENDIF

.386					; allow 32-bit instructions

.CODESEGMENT

IFDEF comfile				; .COM files get program origin
	org	0100h			; remember CP/M
ENDIF   

entry:	jmp	start			; jump around our data

.CEND

.DATASEGMENT

	include data.asm		; da data

.DEND

.CODESEGMENT
	
	include cmdline.asm		; command line interpreter
	include special.asm		; process special cartridges
	include graphics.asm		; VGA graphics initialization
	include vsync.asm		; vertical synchronization

	include trace.asm		; trace buffer stuff
	include banks.asm		; bank switch code
	include cpu.asm			; 6502 opcodes, macros and support routines
	include cpuhand.asm		; cpu memory & register handlers
	include tia.asm			; <-- the main machine -- * start here *
	include tiahand.asm		; TIA register handlers
	include tiabuf.asm		; TIA buffer management stuff
	include tiasnd.asm		; asm version of Ron Fries' TIASound
	include time.asm		; z26 timing functions

	include sbdrv.asm		; sound blaster assembly code
	include keyboard.asm		; convert keyboard into Atari joystick
	include joy.asm			; joystick routines
	include sound.asm		; PC speaker support
	include Pcxwrite.asm		; Ronnie Greene's PCX file dumper
	include console.asm		; console output (for debugging)
	include msg.asm			; messages

.CEND

	include memory.asm		; RIOT ram, cart ROM, & optional stack


	END	entry   
