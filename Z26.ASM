; z26 -- Atari 2600 emulator
; Copyright (C) 1997-1998 by John Saeger

; Based on A26 version 0.15 by Paul Robson.

; assembly time definitions -- choose one of these:

;exefile =		1		; build an EXE file
;module =		1		; build a C linkable module

IFDEF module

.model large				; if small module define ModuleReturnAdr -- word
					; if large module define ModuleReturnAdr -- dword
					; (see tia.asm)
ENDIF

IFDEF exefile

.model small
.stack 01000h				; .EXE files get a stack segment

ENDIF

	include defs.asm		; our definitions
	
.386					; allow 32-bit instructions

.data
	include ddata.asm		; dword data
	include init.asm		; initialized data
	include data.asm		; data
.data?
	include memory.asm		; RIOT ram, cart ROM, & optional stack
.code
	include console.asm		; console output
	include msg.asm			; messages
	include special.asm		; process special cartridges
	include graphics.asm		; VGA graphics initialization
	include	modex.asm		; modex support
	include vsync.asm		; vertical synchronization
	include trace.asm		; trace buffer stuff
	include banks.asm		; bank switch code
	include	riot.asm		; RIOT emu
	include cpu.asm			; 6502 opcodes, macros and support routines
	include cpuhand.asm		; cpu memory & register handlers
	include main.asm		; <-- the main machine -- * start here *
	include tia.asm			; TIA emulator
	include tiahand.asm		; TIA register handlers
	include tiabuf.asm		; TIA buffer management stuff
	include tiasnd.asm		; asm version of Ron Fries' TIASound
	include time.asm		; z26 timing functions

	include sbdrv.asm		; sound blaster assembly code
	include paddle.asm		; paddle support code
	include keyboard.asm		; convert keyboard into Atari joystick
	include joy.asm			; joystick routines
	include sound.asm		; PC speaker support
	include Pcxwrite.asm		; Ronnie Greene's PCX file dumper

	END	start   
