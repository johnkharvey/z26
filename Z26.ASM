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
;
; (0.88)  Jan  3, 1998  First version in "C"
; (0.88)                Precision frame timer (-f<n> option)
; (0.88)  Jan 10, 1998  Ron Fries sound code added with Sound Blaster support
; (0.88)                -q switch (quiet)
;
; (0.89)  Jan 11, 1998  fix time constant calculation for 8-bit cards
; (0.89)                fix pitch on 16-bit cards
; (0.89)                added difficulty switches within emu F5 & F6
;
; (0.90)  Jan 22, 1998  lay groundwork for Mode-X
; (0.90)                new VGA sync based on vertical nondisplay interval
; (0.90)  Jan 23, 1998  multiple missiles -- fixed missile command!
; (0.90)  Jan 24, 1998  mid-line collisions -- freeway and oystron(!)
;
; (0.91)  Feb  2, 1998  60 Hz refresh video modes
; (0.91a) Feb  4, 1998  vertical blinds -v3
;
; (0.92)  Feb 11, 1998  Joystick support, 60Hz video mode 2 now default
;
; (0.93)  Feb 22, 1998  different palette, 
;			different Joystick code,
;                       remove ModeX support 
;			simplify sound routines
;                       added timeout to ResetDSP routine
;         Feb 27, 1998  added 1 second startup delay to allow monitor sync
; 
;	                fixed a flicker problem
;
; (0.94)  Mar  9, 1998  added video mode 3, just like mode 2 but 4 more 
;			scanlines
;
;			adjusted vertical position of games to take advantage
;			of mode 3
;
;	  Mar 11, 1998  restore 0.92 sound routines 
;			(even leave out timeout from ResetDSP)
;
;	  Mar 11, 1998  restore 0.92 joystick routines
;
; (0.95)  Mar 17, 1998  fix blinking line in upper left corner that showed up
;			in 0.94 by responding immediately to vblank turned on
;
;                       made some progress on jitter by triggering on the 
;			positive going edge of vsync
;
;                       made some progress on a windows startup problem by
;			delaying before going into graphics mode
;
;                       fix the joystick games that previously didn't work
;			with the joystick
;
; (0.96)  Mar 18, 1998  made sound initialization wait for Windows 95 to
;			finish with the sound card
;
;			added timeouts to vertical sync code that causes
;			automatic reversion to old code if timeout occurs
;
;			reverse sync on space invaders (still doesn't fix)
;
;			sound off during pause for all sound cards
;
;	  Mar 27, 1998  put part of sound drivers in assembly language, based
;			in part on Asteroids v3.02 (c) 1997 by Chris Pile
;			this fixes rare sound related lockup on exit
;
; (0.97)  Mar 30, 1998  fix sound related lockup on termination (Try 2)
;			implemented Atari super-chip games
;			implemented CBS Ram Plus games
;
; (0.98)  Apr  6, 1998  pure assembly language sound drivers
;
; (0.99)  Apr  9, 1998  pure assembly language everything
;                       (re-wrote Ron Fries' TIASound in asm)
;
; (1.00)  Apr 17, 1998  fixed a sound bug in DSP (introduced in 0.99)
;			turn on hardware low pass filter on version 3.xx DSP
;			re-map keyboard and support 2 player joystick games
;
; (1.01)  Apr 29, 1998  sound generation is now interrupt driven
;                       NDI timing done by 8253 hardware timer
;                       more precise frame timer
;                       non-linear palette (generally brighter)
;
; (1.02)  May  4, 1998  move _ProgramDSP (start SB DMA) to after graphics init
;			(may help distortion on some systems)
;
;			don't fill buffer with silence at startup
;			(this CAUSES a click)
;
;			silence buffer when game paused


; assembly time definitions

; choose one of these:

;comfile =		1		; build a COM file
;exefile =		1		; build an EXE file
;module =		1		; build a C linkable module

; and choose any of these

memcheats =		1		; cheat	on 16-bit reads
;trace =		1		; generate tracing code
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
	
	include cmdline.asm		; command line interpreter
	include special.asm		; process special cartridges
	include graphics.asm		; VGA graphics initialization
	include vsync.asm		; vertical synchronization

	include trace.asm		; trace buffer stuff
	include banks.asm		; bank switch code
	include cpu.asm			; 6502 opcodes, macros and support routines
	include math.asm		; Paul Robson's original math routines
	include cpuhand.asm		; cpu memory & register handlers
	include tia.asm			; <-- the main machine -- * start here *
	include tiahand.asm		; TIA register handlers
	include missile.asm		; missile code
	include tiabuf.asm		; TIA buffer management stuff
	include tiasnd.asm		; asm version of Ron Fries' TIASound
	include time.asm		; z26 timing functions

	include sbdrv.asm		; sound blaster assembly code
	include keyboard.asm		; convert keyboard into Atari joystick
	include joy.asm			; joystick routines
	include sound.asm		; PC speaker support
	include dosmem.asm		; DOS far memory allocator
	include Pcxwrite.asm		; Ronnie Greene's PCX file dumper
	include console.asm		; console output (for debugging)
	include msg.asm			; messages

.CEND

	include memory.asm		; RIOT ram, cart ROM, & optional stack


	END	entry   
