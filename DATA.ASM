
;most of our data is here
;we try to keep it in one place, away from the code
;it runs faster that way (something about cache coherency...)


; *****************************************************************************
;		       6502 Register Set (storage)
;	during emulation these locations do not contain correct data !
; *****************************************************************************

RPC		dw	0		; program counter (stored in BP)
RA		db	0		; accumulator (stored in AL)
RCarry		db	0		; carry bit (stored in AH)
RS		db	0		; stack pointer (stored in CL)

; *****************************************************************************
;		 These flags are updated during emulation
;     Z and N are worked out from the values stored in RZTEST and RNTEST
; *****************************************************************************

RClock		db	0		; clock cycles (stored in SI)
RCycles		db	0		; cycles for this instruction.

ALIGN 2

RX		db	0		; x register (stored in DL)
		db	0		; to allow 16-bit load & store (see _index)
RY		db	0		; y register (stored in DH)
		db	0		; to allow 16-bit load & store (see _index)
RZTest		db	0		; value for zero test (Z set when 0)
RNTest		db	0		; value for sign test (N set when -ve)
FDec		db	0		; decimal flag
FOver		db	0		; overflow flag
FIntDis		db	0		; interrupt disable flag
FBreak		db	0		; Break flag

; *****************************************************************************
;				Riot Timer
; *****************************************************************************

ALIGN 2

Timer		dw	0		; the RIOT Timer
TickCnt		dw	0		; Number of ticks till timer clicks
TRate		dw	0		; Number of cycles per timer count

; *****************************************************************************
;			      Other stuff
; *****************************************************************************

ScanLine	dw	0		; current scan line
Frame		dw	0		; Frame Counter
PrevFrame	dw	0		; Previous value frame counter
VBlank		db	0		; VBlank flag

FEnd=$

ALIGN 2

TimerVec	dw	 Timer0		;timer routine vector -- Timer1 for starmaster
					;				and solaris

TopLine		dw	0		; was 36     top line of display
BottomLine	dw	0		; was 36+200 bottom line of display

CFirst		dw	0		; <-- gets changed by SetupSpecial
					; (leave it zero here)
					 
CLast		dw	256		; was 256 last scan line (from CMDLine)

MaxLines	dw	200		;max # of lines to scan
					;gets changed if doing shrunk screen

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
NoRetrace	db	0		; don't wait for retrace (if 1)
ColumnBlank	db	0		; blank this many columns
GamePaused	db	0		; game paused
NoScoreMode	db	0		; set if we don't want PF to take on player colors
CyclesPerLine	db	CyclesPerScanLine-2 ; # of cycles to execute instructions for each line
VBlankFrame	db	0		; VBlank causes a new frame
LastCycle	db	0		; for DoInstructions
ReverseSync	db	0		; sync on reverse transition
WrapZero	db	0		; wrap negative player pos to zero
					; atlantis and oceancty
ALIGN	2

ReadBank	dw	RBank4		; Bank switching function (Read)
WriteBank	dw	WBank4		; were RBank4 and WBank4
        
RomBank		dw	0

SubVector	dw	DoSbc		; vectors for add and subtract
AddVector	dw	DoAdc

CtrlFn		dw	 Controls	; Control vector (paddles/sticks)

Ret00		db	0
Ret0F		db	0Fh
Ret80		db	80h
RetFF		db	0FFh

TimerCount	dw	8,64,1024	; count values for the RIOT

RetWd		db	0		; byte returned from collision read

WByte		db	0		; byte to write




IOPortB		db	00Bh		; IO Port B (switches)
IOPortA		db	0FFh		; IO Port A (joystick)

DumpPorts	db	0,0,0,0		; Input ports (inp0..3)

InputLatch	db	080h		; Input latch (inp4)
		db	080h		; Input latch (inp5)
	   
ALIGN 2

OldInt9		dw	0,0		; old vector for int9

KeyTable	db	128 dup (0)	; Key pressed table

TIABuffer	db 256 dup (TIAEnd)	; TIA information buffer
					; 128 just isn't big enough for some trashed games
					; I've seen SVector get stepped on (see below)
					; then we're outta control


VDP0Gr		db   0			; Buffer for Player 0 Vert Del Graphic
VDP1Gr		db   0			; Buffer for Player 1 Vert Del Graphic
VDBlEn		db   0			; Buffer for Ball Vertical Delay Enable

TIAScanLine	dw	0		; Scanline
TIAWritePointer dw	0		; Write to TIA Buffer pointer
TIAFrameSkip	dw	-1		; zero if frame skipped
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

global _psp
_psp		dw	0		; gets set by calling C program
psp		dw	0		; gets pointer to PSP (if .EXE file or module)

global _CartRom
IFNDEF module
_CartRom	dw	offset CartRom	; gets overwritten by "C" malloc
ENDIF
IFDEF module
_CartRom	dw	0
ENDIF

global _DoCopyright
_DoCopyright	dw	0		; set by cmdline if "C" program should output
					; copyright message

global	_quiet
_quiet		dw	0		; set if we want no sound

global	_DoChecksum
_DoChecksum	dw	0		; set if we should print out checksum

global	_Checksum
_Checksum	dw	0		; gets cart checksum

global	_verbose
_verbose	dw	0		; verbose

global	_credits
_credits	dw	0		; show credits

global	_dsp
_dsp		dw	0		; do digital signal processing

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
CO=-1	; -1 for buck rogers
C1=-2	; -1 for yars -2 for tron
C2=0	; 0 for vidcube
C3=0	; -1


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
		db	68+CO	;1d	ENAM0
		db	68+CO	;1e	ENAM1
		db	68+CO	;1f	ENABL
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


TGODiffTab	dw	TGORet		; 0
		dw	TGO2Close	; 1
		dw	TGO2Medium	; 2
		dw	TGO3Close	; 3
		dw	TGO2Far		; 4
		dw	TGO2Width	; 5
		dw	TGO3Medium	; 6
		dw	TGO4Width	; 7

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

ALIGN 2

Frequency dw 39 ; 30000.00 Hz
 dw 79 ; 15000.00 Hz
 dw 119 ; 10000.00 Hz
 dw 159 ; 7500.00 Hz
 dw 198 ; 6000.00 Hz
 dw 238 ; 5000.00 Hz
 dw 278 ; 4285.71 Hz
 dw 318 ; 3750.00 Hz
 dw 357 ; 3333.33 Hz
 dw 397 ; 3000.00 Hz
 dw 437 ; 2727.27 Hz
 dw 477 ; 2500.00 Hz
 dw 517 ; 2307.69 Hz
 dw 556 ; 2142.86 Hz
 dw 596 ; 2000.00 Hz
 dw 636 ; 1875.00 Hz
 dw 676 ; 1764.71 Hz
 dw 715 ; 1666.67 Hz
 dw 755 ; 1578.95 Hz
 dw 795 ; 1500.00 Hz
 dw 835 ; 1428.57 Hz
 dw 875 ; 1363.64 Hz
 dw 914 ; 1304.35 Hz
 dw 954 ; 1250.00 Hz
 dw 994 ; 1200.00 Hz
 dw 1034 ; 1153.85 Hz
 dw 1073 ; 1111.11 Hz
 dw 1113 ; 1071.43 Hz
 dw 1153 ; 1034.48 Hz
 dw 1193 ; 1000.00 Hz
 dw 1233 ; 967.74 Hz
 dw 1272 ; 937.50 Hz
;

; Vectors and Opcodes for the 6507 interpreter

vectors dw op00,op01,fail,fail,fail,op05,op06,fail
	dw op08,op09,op0a,fail,fail,op0d,op0e,fail
	dw op10,op11,fail,fail,fail,op15,op16,fail
	dw op18,op19,fail,fail,fail,op1d,op1e,fail

	dw op20,op21,fail,fail,op24,op25,op26,fail
	dw op28,op29,op2a,fail,op2c,op2d,op2e,fail
	dw op30,op31,fail,fail,fail,op35,op36,fail
	dw op38,op39,fail,fail,fail,op3d,op3e,fail

	dw op40,op41,fail,fail,fail,op45,op46,fail
	dw op48,op49,op4a,fail,op4c,op4d,op4e,fail
	dw op50,op51,fail,fail,fail,op55,op56,fail
	dw op58,op59,fail,fail,fail,op5d,op5e,fail

	dw op60,op61,fail,fail,fail,op65,op66,fail
	dw op68,op69,op6a,fail,op6c,op6d,op6e,fail
	dw op70,op71,fail,fail,fail,op75,op76,fail
	dw op78,op79,fail,fail,fail,op7d,op7e,fail

	dw fail,op81,fail,fail,op84,op85,op86,fail
	dw op88,fail,op8a,fail,op8c,op8d,op8e,fail
	dw op90,op91,fail,fail,op94,op95,op96,fail
	dw op98,op99,op9a,fail,fail,op9d,fail,fail

	dw opa0,opa1,opa2,fail,opa4,opa5,opa6,fail
	dw opa8,opa9,opaa,fail,opac,opad,opae,fail
	dw opb0,opb1,fail,fail,opb4,opb5,opb6,fail
	dw opb8,opb9,opba,fail,opbc,opbd,opbe,fail

	dw opc0,opc1,fail,fail,opc4,opc5,opc6,fail
	dw opc8,opc9,opca,fail,opcc,opcd,opce,fail
	dw opd0,opd1,fail,fail,fail,opd5,opd6,fail
	dw opd8,opd9,fail,fail,fail,opdd,opde,fail

	dw ope0,ope1,fail,fail,ope4,ope5,ope6,fail
	dw ope8,ope9,opea,fail,opec,oped,opee,fail
	dw opf0,opf1,fail,fail,fail,opf5,opf6,fail
	dw opf8,opf9,fail,fail,fail,opfd,opfe,fail

; *****************************************************************************
;			    Cycles per instruction
; *****************************************************************************
;	      0	 1  2  3  4  5	6  7  8	 9  a  b  c  d	e  f
Cycles	db    7, 6, 2, 8, 3, 3, 5, 5, 3, 2, 2, 2, 4, 4, 6, 6  ; 0
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; 1
	db    6, 6, 2, 8, 3, 3, 5, 5, 4, 2, 2, 2, 4, 4, 6, 6  ; 2
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; 3
	db    6, 6, 2, 8, 3, 3, 7, 5, 3, 2, 2, 2, 3, 4, 6, 6  ; 4
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; 5
	db    6, 6, 2, 8, 3, 3, 5, 5, 4, 2, 2, 2, 5, 4, 6, 6  ; 6
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; 7
	db    2, 6, 2, 6, 3, 3, 3, 3, 2, 2, 2, 2, 4, 4, 4, 4  ; 8
	db    2, 6, 2, 6, 4, 4, 4, 4, 2, 5, 2, 5, 5, 5, 5, 5  ; 9
	db    2, 6, 2, 6, 3, 3, 3, 3, 2, 2, 2, 2, 4, 4, 4, 4  ; a
	db    2, 5, 2, 5, 4, 4, 4, 4, 2, 4, 2, 4, 4, 4, 4, 4  ; b
	db    2, 6, 2, 8, 3, 3, 5, 5, 2, 2, 2, 2, 4, 4, 6, 6  ; c
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; d
	db    2, 6, 2, 8, 3, 3, 5, 5, 2, 2, 2, 2, 4, 4, 6, 6  ; e
	db    2, 5, 2, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7  ; f


