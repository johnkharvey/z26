; *****************************************************************************
;			      Other stuff
; *****************************************************************************

ScanLine	dw	0		; current scan line
Frame		dd	0		; Frame Counter
PrevFrame	dd	0		; Previous value frame counter

FEnd=$

ALIGN 2

TopLine		dw	0		; was 36     top line of display
BottomLine	dw	0		; was 36+200 bottom line of display

OldCFirst	dw	0		; remember original CFirst
					; (for homing the display)

DEFAULT_CFirst = 39

CFirst		dw	0ffffh		; <-- gets changed by SetupSpecial
					; (zero has VBlank trigger a new frame)
					 
MaxLines	dw	200		; max # of lines to scan
					; (gets changed by graphics.asm)

DisplayPointer	dw	0		;pointer into display RAM
DisplayTranslate dw offset TIADisplayToColour ;display to color translation table

ALIGN 4

FrameExit	dd	0		; do this many frames and exit
OriginalFrameExit dd	0		; save it here for FPS calculation
StartTicks	dd	0		; ticks at start
StopTicks	dd	0		; ticks at finish

; *** keep next 4 variables in order !!!!
; they are arranged to match the order of the entries in TIAColourTable

BackgroundColor	dd	0
PlayfieldColor	dd	0
Player1Color	dd	0
Player0Color	dd	0


MicroTick	db	0		; holds a small tick from hardware counter

NoRetrace	db	0		; don't wait for retrace (if 0ffh)
					; moved to vsync.asm

ColumnBlank	db	0		; blank this many columns
GamePaused	db	0		; game paused
NoScoreMode	db	0		; set if we don't want PF to take on player colors
CPUOffset	db	66		; 64 default offset for CPU clock
CPUClock	db	0
WrapZero	db	0		; wrap negative player pos to zero
WrapWsync	db	0		; push late Wsyncs to next line
OldMissile	db	0		; use old missile code for resmpx

ALIGN	2

CtrlFn		dw	 Controls	; Control vector (paddles/sticks)

WByte		db	0		; byte to write

ALIGN 2

OldInt9		dw	0,0		; old vector for int9

TIABuffer	db 256 dup (TIAEnd)	; TIA information buffer
					; 128 just isn't big enough for some
					; trashed games.  I've seen SVector get
					; stepped on (see below)
					; then we're outta control


VDP0Gr		db	0		; Buffer for Player 0 Vert Del Graphic
VDP1Gr		db	0		; Buffer for Player 1 Vert Del Graphic
VDBlEn		db	0		; Buffer for Ball Vertical Delay Enable

TIAScanLine	dw	0		; Scanline
TIAWritePointer dw	0		; Write to TIA Buffer pointer
TIAFrameSkip	dw     -1		; zero if frame skipped
TIACollide	dw	0		; Collision flag word.

SVector dw	PCSound			; Vector for sound updates

AudC0	db	-1			; Sound registers
AudC1	db	-1
AudF0	db	-1
AudF1	db	-1
AudV0	db	-1
AudV1	db	-1

AudMask db	15,15,31,31,15,15	; bitmask for the registers

SDMPX	db	2			; 0 = ch1,1 = ch2,2 = both,-1 = quiet
MinVol	db	8			; minimum volume for PC Speaker


; *** stuff that gets shared with "C" program ***

_psp		dw	0		; gets set by calling C program
psp		dw	0		; gets pointer to PSP 
					; (if .EXE file or module)
_Checksum	dd	0		; gets cart checksum
_dsp		dw	0		; do digital signal processing
_VideoMode	db	3		; video mode (default mode 3 60Hz)
_Joystick	db	1		; do joystick
_DoChecksum	db	0		; set if we should print out checksum
_verbose	db	0		; verbose
_quiet		db	0		; set if we want no sound

ALIGN 2

ModuleReturn	dw	0
ModuleBP	dw	0
ModuleSP	dw	0


;process these commands immediately

ALIGN 2

WrTiaImmediateVector	dw	WrTiaVSync	; 0
			dw	WrTiaVBlank	; 1
			dw	WrTiaWSync	; 2
			dw	WSret		; 3 -- reset horizontal sync
						;      for factory testing only !
		        
; cycle offset table

;CO=-1	;default cycle offset
CO=0	; -1 for Oscar
C1=-2	;(-2) -1 for yars -2 for tron
C2=0	; 0 for vidcube
C3=0	; -1
C4=0	; -1


CycleOffset	db	68+CO	;00	VSYNC
		db	68+CO	;01	VBLANK
		db	68+CO	;02	WSYNC
		db	68+CO	;03	RSYNC
		db	68+CO	;04	NUSIZ0
		db	68+CO	;05	NUSIZ1
		db	68+C2	;06	COLUP0
		db	68+C2	;07	COLUP1
		db	68+C2	;08	COLUPF
		db	68+C2	;09	COLUBK
		db	68+C2	;0a	CTRLPF
		db	68+CO	;0b	REFP0
		db	68+CO	;0c	REFP1
		db	68+C1	;0d	PF0
		db	68+C1	;0e	PF1
		db	68+C1	;0f	PF2
		db	68-5	;10	RESP0	-- tune for Pacman
		db	68-5	;11	RESP1	-- ditto
		db	68-4	;12	RESM0	-- ditto 4
		db	68-4	;13	RESM1	-- ditto 4
		db	68-4	;14	RESBL	-- ditto 4
		db	68+CO	;15	AUDC0
		db	68+CO	;16	AUDC1
		db	68+CO	;17	AUDF0
		db	68+CO	;18	AUDF1
		db	68+CO	;19	AUDV0
		db	68+CO	;1a	AUDV1
		db	68+C3	;1b	GRP0
		db	68+C3	;1c	GRP1
		db	68+C4	;1d	ENAM0
		db	68+C4	;1e	ENAM1
		db	68+C4	;1f	ENABL
		db	68+CO	;20	HMP0
		db	68+CO	;21	HMP1
		db	68+CO	;22	HMM0
		db	68+CO	;23	HMM1
		db	68+CO	;24	HMBL
		db	68+CO	;25	VDELP0
		db	68+CO	;26	VDEL01
		db	68+CO	;27	VDELBL
		db	68+CO	;28	RESMP0
		db	68+CO	;29	RESMP1
		db	68+CO	;2a	HMOVE
		db	68+CO	;2b	HMCLR
		db	68+CO	;2c	CXCLR

        

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


PFClockToBitTable	dw	PFClockToBitReversed


;
; Display to collision word
;
;
; Display to collision word
;
TIAColTab dw 0 ; 0
   dw 0 ; 0
   dw 0 ; 0
   dw 8192 ; 2000
   dw 0 ; 0
   dw 128 ; 80
   dw 64 ; 40
   dw 8384 ; 20c0
   dw 0 ; 0
   dw 2048 ; 800
   dw 1024 ; 400
   dw 11264 ; 2c00
   dw 4 ; 4
   dw 2180 ; 884
   dw 1092 ; 444
   dw 11460 ; 2cc4
   dw 0 ; 0
   dw 32 ; 20
   dw 16 ; 10
   dw 8240 ; 2030
   dw 32768 ; 8000
   dw 32928 ; 80a0
   dw 32848 ; 8050
   dw 41200 ; a0f0
   dw 8 ; 8
   dw 2088 ; 828
   dw 1048 ; 418
   dw 11320 ; 2c38
   dw 32780 ; 800c
   dw 34988 ; 88ac
   dw 33884 ; 845c
   dw 44284 ; acfc
   dw 0 ; 0
   dw 512 ; 200
   dw 256 ; 100
   dw 8960 ; 2300
   dw 2 ; 2
   dw 642 ; 282
   dw 322 ; 142
   dw 9154 ; 23c2
   dw 16384 ; 4000
   dw 18944 ; 4a00
   dw 17664 ; 4500
   dw 28416 ; 6f00
   dw 16390 ; 4006
   dw 19078 ; 4a86
   dw 17734 ; 4546
   dw 28614 ; 6fc6
   dw 1 ; 1
   dw 545 ; 221
   dw 273 ; 111
   dw 9009 ; 2331
   dw 32771 ; 8003
   dw 33443 ; 82a3
   dw 33107 ; 8153
   dw 41971 ; a3f3
   dw 16393 ; 4009
   dw 18985 ; 4a29
   dw 17689 ; 4519
   dw 28473 ; 6f39
   dw 49167 ; c00f
   dw 51887 ; caaf
   dw 50527 ; c55f
   dw 61439 ; efff
;
TIADisplayToColour db 0,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
;
TIADisplayToColour2 db 0,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1
 db 3,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1
 db 3,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1
 db 3,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1
;
TIAColourTable	db	TIAColubk	; Background
		db	TIAColupf	; Playfield
		db	TIAColup1	; Player 1,Missile 1
		db	TIAColup0	; Player 0,Missile 0

TIADisplayToColor dw	TIADisplayToColour

TIAColorPFTable	db	160 dup (TIAColupf)

TIAColorPlayTable db	80 dup (TIAColup0)
		  db    80 dup (TIAColup1)

TIAPFColorByClock	dw offset TIAColorPFTable

