;*
;* tiatab.asm -- tables needed for TIA emulator
;*

.data

ALIGN 4

;playfield counter to playfield bit table

;	  PF2		|	  PF1		|	  PF0		|
; 7  6	5  4  3	 2  1  0  7  6	5  4  3	 2  1  0  7  6	5  4  3	 2  1  0
;23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6	5  4  3	 2  1  0
;				  ECX					|

PFClockToBitReversed	dd	1 shl 4		;0	forward
			dd	1 shl 5		;1
			dd	1 shl 6		;2
			dd	1 shl 7		;3
			dd	1 shl 15	;4
			dd	1 shl 14	;5
			dd	1 shl 13	;6
			dd	1 shl 12	;7
			dd	1 shl 11	;8
			dd	1 shl 10	;9
			dd	1 shl 9		;10
			dd	1 shl 8		;11
			dd	1 shl 16	;12
			dd	1 shl 17	;13
			dd	1 shl 18	;14
			dd	1 shl 19	;15
			dd	1 shl 20	;16
			dd	1 shl 21	;17
			dd	1 shl 22	;18
			dd	1 shl 23	;19
		        
			dd	1 shl 23	;20	reversed
			dd	1 shl 22	;21
			dd	1 shl 21	;22
			dd	1 shl 20	;23
			dd	1 shl 19	;24
			dd	1 shl 18	;25
			dd	1 shl 17	;26
			dd	1 shl 16	;27
			dd	1 shl 8		;28
			dd	1 shl 9		;29
			dd	1 shl 10	;30
			dd	1 shl 11	;31
			dd	1 shl 12	;32
			dd	1 shl 13	;33
			dd	1 shl 14	;34
			dd	1 shl 15	;35
			dd	1 shl 7		;36
			dd	1 shl 6		;37
			dd	1 shl 5		;38
			dd	1 shl 4		;39

PFClockToBitForward	dd	1 shl 4		;0	forward
			dd	1 shl 5		;1
			dd	1 shl 6		;2
			dd	1 shl 7		;3
			dd	1 shl 15	;4
			dd	1 shl 14	;5
			dd	1 shl 13	;6
			dd	1 shl 12	;7
			dd	1 shl 11	;8
			dd	1 shl 10	;9
			dd	1 shl 9		;10
			dd	1 shl 8		;11
			dd	1 shl 16	;12
			dd	1 shl 17	;13
			dd	1 shl 18	;14
			dd	1 shl 19	;15
			dd	1 shl 20	;16
			dd	1 shl 21	;17
			dd	1 shl 22	;18
			dd	1 shl 23	;19
		        
			dd	1 shl 4		;0	forward
			dd	1 shl 5		;1
			dd	1 shl 6		;2
			dd	1 shl 7		;3
			dd	1 shl 15	;4
			dd	1 shl 14	;5
			dd	1 shl 13	;6
			dd	1 shl 12	;7
			dd	1 shl 11	;8
			dd	1 shl 10	;9
			dd	1 shl 9		;10
			dd	1 shl 8		;11
			dd	1 shl 16	;12
			dd	1 shl 17	;13
			dd	1 shl 18	;14
			dd	1 shl 19	;15
			dd	1 shl 20	;16
			dd	1 shl 21	;17
			dd	1 shl 22	;18
			dd	1 shl 23	;19




;
; pixel to collision word
;
TIAColTab label word
   dw 0		; 0
   dw 0		; 0
   dw 0		; 0
   dw 8192	; 2000
   dw 0		; 0
   dw 128	; 80
   dw 64	; 40
   dw 8384	; 20c0
   dw 0		; 0
   dw 2048	; 800
   dw 1024	; 400
   dw 11264	; 2c00
   dw 4		; 4
   dw 2180	; 884
   dw 1092	; 444
   dw 11460	; 2cc4
   dw 0		; 0
   dw 32	; 20
   dw 16	; 10
   dw 8240	; 2030
   dw 32768	; 8000
   dw 32928	; 80a0
   dw 32848	; 8050
   dw 41200	; a0f0
   dw 8		; 8
   dw 2088	; 828
   dw 1048	; 418
   dw 11320	; 2c38
   dw 32780	; 800c
   dw 34988	; 88ac
   dw 33884	; 845c
   dw 44284	; acfc
   dw 0		; 0
   dw 512	; 200
   dw 256	; 100
   dw 8960	; 2300
   dw 2		; 2
   dw 642	; 282
   dw 322	; 142
   dw 9154	; 23c2
   dw 16384	; 4000
   dw 18944	; 4a00
   dw 17664	; 4500
   dw 28416	; 6f00
   dw 16390	; 4006
   dw 19078	; 4a86
   dw 17734	; 4546
   dw 28614	; 6fc6
   dw 1		; 1
   dw 545	; 221
   dw 273	; 111
   dw 9009	; 2331
   dw 32771	; 8003
   dw 33443	; 82a3
   dw 33107	; 8153
   dw 41971	; a3f3
   dw 16393	; 4009
   dw 18985	; 4a29
   dw 17689	; 4519
   dw 28473	; 6f39
   dw 49167	; c00f
   dw 51887	; caaf
   dw 50527	; c55f
   dw 61439	; efff

IFDEF compileoldcode
;
TIADisplayToColour label byte
 db 0,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
;
TIADisplayToColour2 label byte
 db 0,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1
 db 3,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1
 db 3,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1
 db 3,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1

ENDIF

;IFDEF compileoldcode
;
TIADisplayToColour label byte
 db 0,1,4,4,2,2,2,2,2,2,2,2,2,2,2,2
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
;
TIADisplayToColour2 label byte
 db 0,1,4,1,2,1,4,1,2,1,4,1,2,1,4,1
 db 3,1,4,1,3,1,4,1,3,1,4,1,3,1,4,1
 db 3,1,4,1,3,1,4,1,3,1,4,1,3,1,4,1
 db 3,1,4,1,3,1,4,1,3,1,4,1,3,1,4,1

;ENDIF


PF_Table	dw	PFClockToBitForward	; current pointer to playfield mask bits
PixelColorTable	dw	TIADisplayToColour	; pixel to color translation table


;*
;* sprite definitions
;*
;* The top bit of the delay byte is the triple flag.
;* This means subsequent RESPx outputs the leading sprite.
;*
;* Note:  There is an entry just before the first entry of a single-width 
;*        player sprite that isn't there, that should have the triple flag
;*        set.  That is there should be four entries with the triple flag set.
;* 

LeadingPlayer macro
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		10
	db	0,		9
	db	10000000b,	8
	db	1000000b,	7
	db	100000b,	6
	db	10000b,		5
	db	1000b,		4
	db	100b,		3
	db	10b,		2
	db	1b,		1
	db	0,		0
	endm

BlankPlayer macro
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		10
	db	0,		9
	db	0,		8
	db	0,		7
	db	0,		6
	db	0,		5
	db	0,		4
	db	0,		3
	db	0,		2
	db	0,		1
	db	0,		0
	endm

TrailingPlayer macro
	db	0,		0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		10
	db	0,		9
	db	10000000b,	8
	db	1000000b,	7
	db	100000b,	6
	db	10000b,		5
	db	1000b,		4
	db	100b,		3
	db	10b,		2
	db	1b,		1
	db	0,		0
	endm

LeadingMissile macro
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		0
	db	10000000b,	8
	db	1000000b,	7
	db	100000b,	6
	db	10000b,		5
	db	1000b,		4
	db	100b,		3
	db	10b,		2
	db	1b,		1
	db	0,		0
	endm

BlankMissile macro
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		0
	db	0,		8
	db	0,		7
	db	0,		6
	db	0,		5
	db	0,		4
	db	0,		3
	db	0,		2
	db	0,		1
	db	0,		0
	endm

TrailingMissile macro
	db	0,		0
	db	0,		0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		0
	db	10000000b,	8
	db	1000000b,	7
	db	100000b,	6
	db	10000b,		5
	db	1000b,		4
	db	100b,		3
	db	10b,		2
	db	1b,		1
	db	0,		0
	endm

MediumGap macro
	db	2*16 dup (0)
	endm

WideGap macro
	db	6*16 dup (0)
	endm

;*
;* Medium and wide players have an extra leading clock.
;* They have the extra triple flag too.

MediumPlayer macro
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		18
	db	0,		17
	db	10000000b,	16
	db	10000000b,	15
	db	1000000b,	14
	db	1000000b,	13
	db	100000b,	12
	db	100000b,	11
	db	10000b,		10
	db	10000b,		9
	db	1000b,		8
	db	1000b,		7
	db	100b,		6
	db	100b,		5
	db	10b,		4
	db	10b,		3
	db	1b,		2
	db	1b,		1
	db	0,		0
	endm


MediumBlankPlayer macro
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		18
	db	0,		17
	db	0,		16
	db	0,		15
	db	0,		14
	db	0,		13
	db	0,		12
	db	0,		11
	db	0,		10
	db	0,		9
	db	0,		8
	db	0,		7
	db	0,		6
	db	0,		5
	db	0,		4
	db	0,		3
	db	0,		2
	db	0,		1
	db	0,		0
	endm


WidePlayer macro
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		34
	db	0,		33
	db	10000000b,	32
	db	10000000b,	31
	db	10000000b,	30
	db	10000000b,	29
	db	1000000b,	28
	db	1000000b,	27
	db	1000000b,	26
	db	1000000b,	25
	db	100000b,	24
	db	100000b,	23
	db	100000b,	22
	db	100000b,	21
	db	10000b,		20
	db	10000b,		19
	db	10000b,		18
	db	10000b,		17
	db	1000b,		16
	db	1000b,		15
	db	1000b,		14
	db	1000b,		13
	db	100b,		12
	db	100b,		11
	db	100b,		10
	db	100b,		9
	db	10b,		8
	db	10b,		7
	db	10b,		6
	db	10b,		5
	db	1b,		4
	db	1b,		3
	db	1b,		2
	db	1b,		1
	db	0,		0
	endm


WideBlankPlayer macro
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		34
	db	0,		33
	db	0,		32
	db	0,		31
	db	0,		30
	db	0,		29
	db	0,		28
	db	0,		27
	db	0,		26
	db	0,		25
	db	0,		24
	db	0,		23
	db	0,		22
	db	0,		21
	db	0,		20
	db	0,		19
	db	0,		18
	db	0,		17
	db	0,		16
	db	0,		15
	db	0,		14
	db	0,		13
	db	0,		12
	db	0,		11
	db	0,		10
	db	0,		9
	db	0,		8
	db	0,		7
	db	0,		6
	db	0,		5
	db	0,		4
	db	0,		3
	db	0,		2
	db	0,		1
	db	0,		0
	endm


;*
;* sprite size calculation macro
;*

SpriteSize macro %1
%1&_Size = ($-&%1)/2-1
	endm

;*
;* default sprite definitions
;*

P_0 label byte		; Player NUSIZ = 0

P0_Sprite label byte
P1_Sprite label byte	
	LeadingPlayer

SpriteSize P_0

P0_SpriteSize = 13
P1_SpriteSize = 13


M_0 label byte		; Missile NUSIZ = 0
M_5 label byte		; Missile NUSIZ = 5
M_7 label byte		; Missile NUSIZ = 7

BL_Sprite label byte
M0_Sprite label byte
M1_Sprite label byte
	LeadingMissile

SpriteSize M_0
SpriteSize M_5
SpriteSize M_7

M0_SpriteSize = 12
M1_SpriteSize = 12
BL_SpriteSize = 12


P_1 label byte		; Player NUSIZ = 1
	LeadingPlayer
	TrailingPlayer

SpriteSize P_1

M_1 label byte		; Missile NUSIZ = 1
	LeadingMissile
	TrailingMissile

SpriteSize M_1

P_2 label byte		; Player NUSIZ = 2
	LeadingPlayer
	MediumGap
	TrailingPlayer

SpriteSize P_2

M_2 label byte		; Missile NUSIZ = 2
	LeadingMissile
	MediumGap
	TrailingMissile

SpriteSize M_2

P_3 label byte		; Player NUSIZ = 3
	LeadingPlayer
	TrailingPlayer
	TrailingPlayer

SpriteSize P_3

M_3 label byte		; Missile NUSIZ = 3
	LeadingMissile
	TrailingMissile
	TrailingMissile

SpriteSize M_3

P_4 label byte		; Player NUSIZ = 4
	LeadingPlayer
	WideGap
	TrailingPlayer

SpriteSize P_4

M_4 label byte		; Missile NUSIZ = 4
	LeadingMissile
	WideGap
	TrailingMissile

SpriteSize M_4

P_5 label byte		; Player NUSIZ = 5
	MediumPlayer

SpriteSize P_5

P_6 label byte		; Player NUSIZ = 6
	LeadingPlayer
	MediumGap
	TrailingPlayer
	MediumGap
	TrailingPlayer

SpriteSize P_6

M_6 label byte		; Missile NUSIZ = 6
	LeadingMissile
	MediumGap
	TrailingMissile
	MediumGap
	TrailingMissile

SpriteSize M_6

P_7 label byte		; Player NUSIZ = 7
	WidePlayer

SpriteSize P_7


;*
;* multi sprite definitions
;*	

MP_0 label byte		; Player NUSIZ = 0
	BlankPlayer

MM_0 label byte		; Missile NUSIZ = 0
MM_5 label byte		; Missile NUSIZ = 5
MM_7 label byte		; Missile NUSIZ = 7
	BlankMissile

MP_1 label byte		; Player NUSIZ = 1
	BlankPlayer
	TrailingPlayer

MM_1 label byte		; Missile NUSIZ = 1
	BlankMissile
	TrailingMissile

MP_2 label byte		; Player NUSIZ = 2
	BlankPlayer
	MediumGap
	TrailingPlayer

MM_2 label byte		; Missile NUSIZ = 2
	BlankMissile
	MediumGap
	TrailingMissile

MP_3 label byte		; Player NUSIZ = 3
	BlankPlayer
	TrailingPlayer
	TrailingPlayer

MM_3 label byte		; Missile NUSIZ = 3
	BlankMissile
	TrailingMissile
	TrailingMissile

MP_4 label byte		; Player NUSIZ = 4
	BlankPlayer
	WideGap
	TrailingPlayer

MM_4 label byte		; Missile NUSIZ = 4
	BlankMissile
	WideGap
	TrailingMissile

MP_5 label byte		; Player NUSIZ = 5
	MediumBlankPlayer

MP_6 label byte		; Player NUSIZ = 6
	BlankPlayer
	MediumGap
	TrailingPlayer
	MediumGap
	TrailingPlayer

MM_6 label byte		; Missile NUSIZ = 6
	BlankMissile
	MediumGap
	TrailingMissile
	MediumGap
	TrailingMissile

MP_7 label byte		; Player NUSIZ = 7
	WideBlankPlayer



P0_RegularTable label word
P1_RegularTable label word
	dw	P_0
	dw	P_1
	dw	P_2
	dw	P_3
	dw	P_4
	dw	P_5
	dw	P_6
	dw	P_7

P0_SizeTable label byte
P1_SizeTable label byte
	db	P_0_Size
	db	P_1_Size
	db	P_2_Size
	db	P_3_Size
	db	P_4_Size
	db	P_5_Size
	db	P_6_Size
	db	P_7_Size

M0_RegularTable label word
M1_RegularTable label word
	dw	M_0
	dw	M_1
	dw	M_2
	dw	M_3
	dw	M_4
	dw	M_5
	dw	M_6
	dw	M_7

M0_SizeTable label byte
M1_SizeTable label byte
	db	M_0_Size
	db	M_1_Size
	db	M_2_Size
	db	M_3_Size
	db	M_4_Size
	db	M_5_Size
	db	M_6_Size
	db	M_7_Size


;IFDEF compileoldcode

P0_MultipleTable label word
P1_MultipleTable label word
	dw	MP_0
	dw	MP_1
	dw	MP_2
	dw	MP_3
	dw	MP_4
	dw	MP_5
	dw	MP_6
	dw	MP_7

M0_MultipleTable label word
M1_MultipleTable label word
	dw	MM_0
	dw	MM_1
	dw	MM_2
	dw	MM_3
	dw	MM_4
	dw	MM_5
	dw	MM_6
	dw	MM_7

