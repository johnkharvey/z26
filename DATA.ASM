; *****************************************************************************
;			      Other stuff
; *****************************************************************************

.data

PFClockToBitTable	dw	PFClockToBitReversed

DisplayTranslate dw offset TIADisplayToColour ;display to color translation table


ALIGN	2

CtrlFn		dw	 Controls	; Control vector (paddles/sticks)



jam_msg	db	'Halt ','$'

;process these commands immediately

ALIGN 2

WrTiaImmediateVector	dw	WrTiaVSync	; 0
			dw	WrTiaVBlank	; 1
			dw	WrTiaWSync	; 2
			dw	WSret		; 3 -- reset horizontal sync
						;      for factory testing only !
		        
; cycle offset table


CycleOffset	db	68	;00	VSYNC
		db	68	;01	VBLANK
		db	68	;02	WSYNC
		db	68	;03	RSYNC
		db	68	;04	NUSIZ0
		db	68	;05	NUSIZ1
		db	68	;06	COLUP0
		db	68	;07	COLUP1
		db	68	;08	COLUPF
		db	68	;09	COLUBK
		db	68	;0a	CTRLPF
		db	68	;0b	REFP0
		db	68	;0c	REFP1
		db	68-2	;0d	PF0	-- -1 for yars  -2 for tron
		db	68-2	;0e	PF1
		db	68-2	;0f	PF2
		db	68-5	;10	RESP0	-- tune for Pacman
		db	68-5	;11	RESP1	-- ditto
		db	68-4	;12	RESM0	-- ditto 4
		db	68-4	;13	RESM1	-- ditto 4
		db	68-4	;14	RESBL	-- ditto 4
		db	68	;15	AUDC0
		db	68	;16	AUDC1
		db	68	;17	AUDF0
		db	68	;18	AUDF1
		db	68	;19	AUDV0
		db	68	;1a	AUDV1
		db	68	;1b	GRP0
		db	68	;1c	GRP1
		db	68	;1d	ENAM0
		db	68	;1e	ENAM1
		db	68	;1f	ENABL
		db	68	;20	HMP0
		db	68	;21	HMP1
		db	68	;22	HMM0
		db	68	;23	HMM1
		db	68	;24	HMBL
		db	68	;25	VDELP0
		db	68	;26	VDEL01
		db	68	;27	VDELBL
		db	68	;28	RESMP0
		db	68	;29	RESMP1
		db	68	;2a	HMOVE
		db	68	;2b	HMCLR
		db	68	;2c	CXCLR

        

ALIGN 2
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

