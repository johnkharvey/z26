PAGE 66,132

; z26 -- Atari 2600 emulator
; Copyright (C) 1997 by John Saeger

; Based on A26 version 0.15 by Paul Robson.
; PCX Screen Dump code by Ronnie Greene.

; 01-09-97  --	first version -- adapted from version 0.15 of Paul Robson's A26
; 08-28-97  --  (0.8)  first released version
; 11-14-97  --  (0.81) moved copyright notice to display when no filename is entered
; 11-14-97  --  (0.81) added -r option to not wait for vertical retrace (flat out)
; 11-14-97  --  (0.81) change player 0 fire key to space bar
; 11-14-97  --  (0.81) added p for pause, enter to resume
; 11-15-97  --  (0.81) added F9 for B/W F10 for color & fix Starmaster
; 11-17-97  --  (0.81) add a help screen if no filename entered
; 11-18-97  --  (0.81) modified TIAWrap macro
;		       now sets Hmoves to negative color clocks to zero
;                      (fixed left gun on Atlantis)
; 11-18-97  --  (0.81) decided to go to .EXE file format from now on
; 11-22-97  --  (0.82) changed mind about .EXE file
; 11-22-97  --  (0.82) new palette (Atlantis now has bluish water)
; 11-22-97  --  (0.82) incorporated Ronnie Greene's PCX screen capture code
; 11-22-97  --  (0.82) make Enduro copyright notice show up
; 11-26-97  --  (0.83) add column blanking
; 11-26-97  --  (0.83) tune top lines and column blanking for many games
; 11-28-97  --  (0.83) more palette tweaking
; 12-02-97  --  (0.84) got Seaquest & opening screen of Starraiders right color by playing
;		       games with score mode (playfield taking on color of players)
; 12-02-97  --  (0.84) got tetris26, space invaders, taxavoid, catmouse to stop jiggling
;		       by playing games with CyclesPerScanLine
; 12-04-97  --  (0.85) rework vertical synchronization
; 12-13-97  --  (0.86) better playfield colors (single bit resolution)
; 12-15-97  --  (0.86) more work on vertical synchronization
; 12-17-97  --  (0.86) more speed
; 12-23-97  --  (0.87) faster playfield and background draws
;
; see z.c for continuation of change list
;


; assembly time definitions

;comfile =		1		; build a COM file
;exefile =		1		; build an EXE file

; if both of the above are undefined, build a module linkable from C

memcheats =		1		; cheat	on 16-bit reads
;dotiming =		1		; generate timing blips


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
	
	include cpu.asm			; 6502 opcodes, macros and support routines
	include math.asm		; Paul Robson's original math routines
	include cpuhand.asm		; cpu memory & register handlers
	include cmdline.asm		; command line interpreter
	include special.asm		; process special cartridges
	include console.asm		; console output (for debugging)
	include keyboard.asm		; convert keyboard into Atari joystick
	include joy.asm			; joystick routines
	include dosmem.asm		; DOS far memory allocator
	include sound.asm		; PC speaker support
	include graphics.asm		; VGA graphics initialization
	include vsync.asm		; vertical synchronization
	include tia.asm			; <-- the main machine -- * start here *
	include tiahand.asm		; TIA register handlers
	include missile.asm		; missile code
	include tiabuf.asm		; TIA buffer management stuff
	include Pcxwrite.asm		; Ronnie Greene's PCX file dumper

.CEND

.DATASEGMENT

	include memory.asm		; RIOT ram, cart ROM, & optional stack

.DEND

	END	entry   
