page 66,132

; head.asm -- Atari 2600 emulator ASM core functions

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; Based on A26 version 0.15 by Paul Robson.

; assembly time definitions

TRACE = 1
showdeep = 1
CHEATS = 1

	.386

.MODEL flat, syscall


