;other definitions -- outside any segment

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

MSDOS =			021H		; MSDOS	caller

CYCLESPERSCANLINE = 	76		; TIA timing constant

;*
;* TIA register definitions
;*

VSYNC =			00h		;* vertical sync set/clear       \
VBLANK =		01h		;* vertical blank set/clear       \  immediate
WSYNC =			02h		;* wait for horizontal blank      /  action
RSYNC =			03h		;* reset horizontal sync counter /

NUSIZ0 =		04h		; missile/player size controls
NUSIZ1 =		05h
COLUP0 =		06h		; colors
COLUP1 =		07h
COLUPF =		08h
COLUBK =		09h
CTRLPF =		0Ah		; REF, SCORE, PFP, ball width
REFP0 =			0Bh		; reflect player
REFP1 =			0Ch
PF0 =			0Dh		; playfield bits
PF1 =	 		0Eh
PF2 =			0Fh
RESP0 = 		10h		; horizonal position
RESP1 = 		11h
RESM0 = 		12h
RESM1 = 		13h
RESBL = 		14h

AUDC0 =			15h		;* audio control
AUDC1 =			16h		;*
AUDF0 =			17h		;* audio frequency
AUDF1 =			18h		;*
AUDV0 =			19h		;* audio volume
AUDV1 =			1Ah		;*

GRP0 =			1Bh		; graphics
GRP1 =			1Ch
ENAM0 = 		1Dh		; enables
ENAM1 = 		1Eh
ENABL = 		1Fh
HMP0 =			20h		; horizontal motion
HMP1 =			21h
HMM0 =			22h
HMM1 =			23h
HMBL =			24h
VDELP0 = 		25h		; vertical delay
VDELP1 = 		26h
VDELBL = 		27h
RESMP0 = 		28h		; missile locked to player
RESMP1 = 		29h

HMOVE =			2Ah		; apply horizontal motion
HMCLR =			2Bh		; clear horizontal motion registers
CXCLR =			2Ch		; clear collision latches

;*
;* to make macros easier to write
;*

NUSIZM0 = NUSIZ0
NUSIZM1 = NUSIZ1
NUSIZP0 = NUSIZ0
NUSIZP1 = NUSIZ1



;*
;* TIA bit mask definitions
;*

REF =			01h		; (CTRLPF) reflect playfield
SCORE =			02h		; (CTRLPF) score mode
PFP =			04h		; (CTRLPF) playfield gets priority


;*
;* pixel  bit definitions
;*

PF_BIT = 1
BL_BIT = 2
P1_BIT = 4
M1_BIT = 8
P0_BIT = 16
M0_BIT = 32
DL_BIT = 64


; some display related stuff

DEFAULT_CFirst = 39
MEDIUM_Offset = 19			; offset a medium game this much
					; tune so that game in mode 3 and mode 5
					; appear at same vertical position
					; (unless it's a known tall game)

MAX_TallGame = 240			; size of a tall game


