page 66,132

; z26core.asm -- Atari 2600 emulator ASM core functions

; z26 is Copyright 1997-2001 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; Based on A26 version 0.15 by Paul Robson.

; assembly time definitions

TRACE = 1
showdeep = 1
CHEATS = 1

.model large				; if large module define ModuleReturnAdr -- dword
.386					; allow 32-bit instructions

	include extern.asm		; external to ASM, internal to C
	include defs.asm		; our definitions

	include init.asm		; initialized data
	include banks.asm		; bank switch code
	include pitfall2.asm		; Pitfall II bank switch code
	include starpath.asm		; Starpath Supercharger bank switch code

	include console.asm		; console output
	include msg.asm			; messages
;	include special.asm		; process special cartridges

	include vga.asm			; VGA graphics initialization
	include	modex.asm		; Mode-X support
	include vsync.asm		; vertical synchronization
	include trace.asm		; trace buffer stuff
	include	riot.asm		; RIOT emu

	include cpu.asm			; 6502 opcodes, macros and support routines
	include cpujam.asm		; jam handler

	include tiatab.asm
	include tiawrite.asm
	include tialine.asm

	include cpuhand.asm		; cpu memory & register handlers

	include main.asm		; <-- the main machine -- * start here *

	include tiasnd.asm		; asm version of Ron Fries' TIASound
	include time.asm		; z26 timing functions

	include sbdrv.asm		; sound blaster assembly code
	include paddle.asm		; paddle support code
	include keyboard.asm		; convert keyboard into Atari joystick
	include joy.asm			; joystick routines
	include sound.asm		; PC speaker support
;        include pcx.asm                 ; Ronnie Greene's PCX file dumper

	include memory.asm		; RIOT ram, cart ROM, & optional stack

	include mouse.asm

	END	start
