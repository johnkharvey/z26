page 66,132

; z26core.asm -- Atari 2600 emulator ASM core functions

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; Based on A26 version 0.15 by Paul Robson.

	include head.asm		; (32) asm time definitions

	include extern.asm		; (32) external to ASM, internal to C
	include defs.asm		; (32) our definitions
	include init.asm		; (32) initialized data

	include simplex5.asm		; large font
	include tiny5.asm		; small font

	include service.asm		; I/O and other services for emulation core
	include soundq.asm		; (32) sound queue stuff
	include lincopy.asm		; (32) video copy support
	include position.asm		; (32) position game vertically

;*
;* controller interpretation files
;*

; these are handled in CONTROLS.C now

;	include paddle.asm		; (32) paddle support code
;	include keyboard.asm		; (32) convert keyboard into Atari joystick
;	include mouse.asm		; (32) convert mouse into a variety of controllers

;*
;* emulator core files
;*

	include main.asm		; (32) <-- the main machine

	include banks.asm		; (32) bank switch code
	include pitfall2.asm		; (32) Pitfall II bank switch code
	include starpath.asm		; (32) Starpath Supercharger bank switch code

	include riot.asm		; (32) RIOT emu
	include cpu.asm			; (32) 6502 opcodes, macros and support routines
	include cpujam.asm		; (32) jam handler
	include cpuhand.asm		; (32) cpu memory & register handlers
	include trace.asm		; (32) trace buffer stuff
	include tiatab.asm		; (32) various tables for TIA graphics emulation
	include tiawrite.asm		; (32) handle writes to TIA registers
	include tialine.asm		; (32) TIA graphics generation
	include tiasnd.asm		; (32) asm version of Ron Fries' TIASound

	include tail.asm		; (32) the END

