;other definitions -- outside any segment

MSDOS =			021H		; MSDOS	caller

CyclesPerScanLine = 	76		; TIA timing constant
CyclesPerLeftHalf =	50		; cycles thru left half of screen


;TIA register offsets

TIANuSiz0 = 		04h		; Missile/Player size controls
TIANuSiz1 = 		05h
TIAColup0 = 		06h
TIAColup1 = 		07h
TIAColupf = 		08h
TIAColubk = 		09h
TIACtrlPf = 		0Ah		; Playfield control,priority,ball size
TIARefP0 = 		0Bh		; Player reflections
TIARefP1 = 		0Ch
TIAPf0 = 		0Dh		; Playfield registers
TIAPf1 = 		0Eh
TIAPf2 = 		0Fh
TIAResp0 = 		10h		; Horizonal position reset registers
TIAResp1 = 		11h
TIAResm0 = 		12h
TIAResm1 = 		13h
TIAResbl = 		14h
TIAGrp0	= 		1Bh		; Graphic 0
TIAGrp1	= 		1Ch		; Graphic 1
TIAEnam0 = 		1Dh		; Enable Missile 0
TIAEnam1 = 		1Eh		; Enable Missile 1
TIAEnabl = 		1Fh		; Ball enable
TIAHmp0	= 		20h
TIAHmp1	= 		21h
TIAHmm0	= 		22h
TIAHmm1	= 		23h
TIAHmbl	= 		24h
TIAVDelp0 = 		25h
TIAVDelp1 = 		26h
TIAVDelbl = 		27h		; Ball enable vertical delay
TIAResmp0 = 		28h		; Missile locked to player flag
TIAResmp1 = 		29h


; TIA Information Buffer. Contains 4 byte records as follows
;
;	0 - Graphics Clock when	written	(TIAEnd	= end of buffer)
;	1 - Register being written
;	2 - Value being	written
;	3 - <reserved>

TIAClock = 		0		; these must be these values ...
TIAReg	 = 		2		; ... and in this order
TIAVal	 = 		3		; (I don't know why)

TIAEnd	= 		255		; end of tia buffer marker
TIAInvalid = 		254		; invalid entry


; TIA Graphic Line  bit definitions

TGPlay = 		1		; Bit for playfield
TGBall = 		2		; Bit for ball
TGPlayer1 = 		4		; Bit for P1
TGMissile1 = 		8		; Bit for M1
TGPlayer0 = 		16		; Bit for P0
TGMissile0 = 		32		; Bit for M0
TGCollisionReset = 	128		; Bit for collision reset here


; displacements into TIAColourTable

TCTPF =			1		;playfield
TCTBK =			0		;backround
TCTP0 =			3		;player 0
TCTP1 =			2		;player 1
