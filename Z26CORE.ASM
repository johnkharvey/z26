page 66,132

; z26core.asm -- Atari 2600 emulator ASM core functions
; Copyright (C) 1997-1999 by John Saeger

; Based on A26 version 0.15 by Paul Robson.

; assembly time definitions

TRACE = 1
showdeep = 1

NEWTIA = 1

.model large				; if large module define ModuleReturnAdr -- dword
.386					; allow 32-bit instructions

	include extern.asm		; external to ASM, internal to C
	include defs.asm		; our definitions
	include init.asm		; initialized data

	include console.asm		; console output
	include msg.asm			; messages
	include special.asm		; process special cartridges
	include vga.asm			; VGA graphics initialization
	include	modex.asm		; Mode-X support
	include vsync.asm		; vertical synchronization
	include trace.asm		; trace buffer stuff
	include banks.asm		; bank switch code
	include	riot.asm		; RIOT emu

	include cpu.asm			; 6502 opcodes, macros and support routines

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
	include pcx.asm			; Ronnie Greene's PCX file dumper

	include memory.asm		; RIOT ram, cart ROM, & optional stack

	END	start   
