; *****************************************************************************
;
;			   Command Line	interpreter
;
;	-u <n>	upper scan line
;	-l <n>	lower scan line
;	-c <n>	Select sound channels
;	-q <n>	Set off	volume
;	-x	print out checksum of cartridge
;	-r	don't wait for retrace (full speed)
;
; *****************************************************************************


CommandLine:

	push	es

IFNDEF comfile
	mov	ax,psp
	mov	es,ax			; set up pointer to PSP
ENDIF   

	mov	bp,081h			; bp points to the command line
CLSkip:	mov	al,es:[bp]		; skip over spaces
	cmp	al,' '
	jne	CLSkip2
	inc	bp
	jmp	CLSkip
CLSkip2:mov	al,es:[bp]		; see what it is
	cmp	al,13
	je	CLNoFile		;   no file detected
	cmp	al,'-'
	je	Control

	mov	bx,bp			; make it an ASCIIZ string
CLASCZ:	mov	al,es:[bx]
	inc	bx
	cmp	al,32
	jg	CLASCZ
	mov	es:byte	ptr -1[bx],0
        
	push	ds
	push	es
	pop	ds
	mov	dx,bp			; Open the file
	mov	al,0
	mov	ah,03Dh
	int	MSDOS
	jc	LoadFailx
	pop	ds
	push	ax			; save handle for close

	mov	bx,ax			; read the file
	mov	dx,offset CartRom
	mov	cx,16384		; try to read in 16k !!!
	mov	ah,03Fh
	int	MSDOS
	pop	bx			; Close	the file
	push	ax			; ax = bytes read.
	mov	ah,03Eh
	int	MSDOS
	jc	LoadFail

	pop	ax
	push	ax
	cmp	ax,02000h		; 8k cartridge ???
	je	Set8kMode
	cmp	ax,04000h
	je	Set16kMode

	cmp	ax,0800h		; read in a 2k file ???
	jne	CCret			;   no, we've finished.

	mov	bx,07FEh		; copy lower 2k	into upper 2k
CartCopy:
	mov	ax,word	ptr CartRom[bx]
	mov	word ptr CartRom+0800h[bx],ax
	sub	bx,2
	jge	CartCopy
CCret:	jmp	Conret

CLNoFile:
	jmp	CLDoNoFile

Set8kMode:
	mov	[ReadBank], offset RBank8
	mov	[WriteBank], offset WBank8
	jmp	Conret
Set16kMode:
	mov	[ReadBank], offset RBank16
	mov	[WriteBank], offset WBank16
	jmp	Conret
        
Conret:	pop	cx			; cart size
	pop	es
	xor	ax,ax			; before we go
	xor	bx,bx			; checksum the cartridge
	mov	si,offset CartRom
XLoop:	mov	bl,[si]
	inc	si
	add	ax,bx
	loop	XLoop
	mov	[Checksum],ax		; save the checksum for cart recognition

	cmp	[DoChecksum],0
	jz	SetupSpecial
	call	ConWord
	jmp	Quit

; *
; * first process requests for special starting lines *
; *

SetupSpecial:
	cmp	ax,0f69ah
	je	Line42B			; enduro
	cmp	ax,000d3h
	je	Line38			; frogger
	cmp	ax,01129h
	je	Line38			; funwnumb
	cmp	ax,09538h
	je	Line39B			; lasrblst
	cmp	ax,00194h
	je	Line40			; othello
	cmp	ax,0b0a9h
	je	Line52			; alienret
	cmp	ax,09794h
	je	Line39			; assault
	cmp	ax,0bf6fh
	je	Line40			; bobby (** doesn't fix **)
	cmp	ax,03ae7h
	je	Line40			; brickick (** doesn't fix **)
	cmp	ax,0a44ch
	je	Line52			; cryscast
	cmp	ax,044dch
	je	Line40			; xenophob
	cmp	ax,0f578h
	je	Line36			; buckrog
	cmp	ax,08387h
	je	Line69			; actionmn
	cmp	ax,0ab1ch
	je	Line56			; fighterp (* doesn't fix *)
	cmp	ax,07f62h
	je	Line36			; asterpal
	cmp	ax,0e0e9h
	je	Line36			; astroidc
	cmp	ax,08ae0h
	je	Line36			; astroids
	cmp	ax,01a5eh
	je	Line40			; challang
	cmp	ax,03695h
	je	Line39			; dkjr
	cmp	ax,08234h
	je	Line40			; eggcatch
	cmp	ax,02b06h
	je	Line32			; oscar
	cmp	ax,02462h
	je	Line40			; smurfres
	cmp	ax,0fbedh
	je	Line38			; starraid
	cmp	ax,045cbh
	je	Line37			; chinasyn
	cmp	ax,02415h
	je	Line40			; comandrd
	cmp	ax,0e90bh
	je	Line36			; condor
	cmp	ax,022abh
	je	Line52			; cosmcrep
	cmp	ax,09f21h
	je	Line39			; crosfrce
	cmp	ax,02d81h
	je	Line42			; dancplat
	cmp	ax,0ce26h
	je	Line40			; dethtrap
	cmp	ax,0bd1fh
	je	Line42			; dishastr
	cmp	ax,07cd6h
	je	Line42			; drgndfnd
	cmp	ax,0ccd7h
	je	Line44			; eggomana
	cmp	ax,046b6h
	je	Line74			; forest
	cmp	ax,08828h
	je	Line40			; infiltrt
	cmp	ax,0b109h
	je	Line38			; iq180
	cmp	ax,0a9c2h
	je	Line18			; jawbreak
	cmp	ax,00b7ah
	je	Line31			; lasrgate
	cmp	ax,0ff2ch
	je	Line31			; lasrvoly
	cmp	ax,03769h
	je	Line46			; malagai
	cmp	ax,09f28h
	je	Line35			; mangia
	cmp	ax,06097h
	je	Line40			; marinwar
	cmp	ax,0dc54h
	je	Line48			; misn3000
	cmp	ax,0877fh
	je	Line44			; mousetrp
	cmp	ax,04790h
	je	Line43			; mrpostmn
	cmp	ax,09aa0h
	je	Line38			; namegame
	cmp	ax,0a939h
	je	Line44			; opensesm
	cmp	ax,00fc5h
	je	Line40			; packong
	cmp	ax,045aeh
	je	Line69			; phantomt
	cmp	ax,04f0eh
	je	Line24			; pharchrs
	cmp	ax,01d00h
	je	Line34			; philly
	cmp	ax,076a4h
	je	Line34			; rescter1
	cmp	ax,0200ah
	je	Line45			; saveship
	cmp	ax,0fc86h
	je	Line45			; seamnstr
	cmp	ax,0badeh
	je	Line40			; sharkatk
	cmp	ax,07be3h
	je	Line22			; shootin
	cmp	ax,08each
	je	Line40			; shtlorbt
	cmp	ax,00a3eh
	je	Line42			; skihunt
	cmp	ax,02697h
	je	Line54			; snalsqrl
	cmp	ax,06373h
	je	Line36			; spidrman
	cmp	ax,0c4a4h
	je	Line44			; squeezbx
	cmp	ax,0769ch
	je	Line44			; sssnake
	cmp	ax,0deebh
	je	Line42			; strwbery
	cmp	ax,0deb1h
	je	Line40			; supercce
	cmp	ax,0ddb2h
	je	Line40			; suprman1
	cmp	ax,0d95eh
	je	Line40			; suprman2
	cmp	ax,08000h
	je	Line56			; surfprds
	cmp	ax,046d8h
	je	Line38			; tanksbut
	cmp	ax,04d67h
	je	Line48			; towerinf
	cmp	ax,08822h
	je	Line36			; ufopatrl
	cmp	ax,00de3h
	je	Line38			; wallball
	cmp	ax,0bfc2h
	je	Line38			; walldfnd
	cmp	ax,05c5bh
	je	Line40			; xman
	cmp	ax,0511bh
	je	Line40			; xtack
	cmp	ax,0568fh
	je	Line60			; baseattk (doesn't fix)
	cmp	ax,062d5h
	je	Line38			; zoofun
	cmp	ax,0f1d7h
	je	Line40			; checkers
	cmp	ax,08698h
	je	Line43			; combat
	cmp	ax,09318h
	je	Line37			; indy500
	cmp	ax,08d5ch
	je	Line40			; ?? who are you ??
;	cmp	ax,0b229h
;	je	Line60			; moonswep
	cmp	ax,0e5beh
	je	Line40			; Tetris26
	cmp	ax,08e07h
	je	Line42			; catmouse
;	cmp	ax,08ab0h
;	je	Line40			; firebird (doesn't fix)

	jmp	SSTR			; process Timer1 requests

; *
; * start line setting handlers *
; *

Line18:	mov	[CFirst],18
	jmp	SSTR

Line22:	mov	[CFirst],22
	jmp	SSTR

Line24:	mov	[CFirst],24
	jmp	SSTR

Line31:	mov	[CFirst],31
	jmp	SSTR

Line32:	mov	[CFirst],32
	jmp	SSTR

Line34:	mov	[CFirst],34
	jmp	SSTR

Line35:	mov	[CFirst],35
	jmp	SSTR

Line36:	mov	[CFirst],36
	jmp	SSTR

Line37:	mov	[CFirst],37
	jmp	SSTR

Line38:	mov	[CFirst],38
	jmp	SSTR

Line39B:mov	[CFirst],39
	jmp	SSCB8			; do column blanking

Line39:	mov	[CFirst],39
	jmp	SSTR

Line40:	mov	[CFirst],40
	jmp	SSTR

Line42B:mov	[CFirst],42		; first display line
	jmp	SSCB8			; do column blanking

Line42:	mov	[CFirst],42
	jmp	SSTR

Line43:	mov	[CFirst],43
	jmp	SSTR

Line44:	mov	[CFirst],44
	jmp	SSTR

Line45:	mov	[CFirst],45
	jmp	SSTR

Line46:	mov	[CFirst],46
	jmp	SSTR

Line48:	mov	[CFirst],48
	jmp	SSTR

Line52:	mov	[CFirst],52
	jmp	SSTR

Line54:	mov	[CFirst],54
	jmp	SSTR

Line56: mov	[CFirst],56
	jmp	SSTR

Line60:	mov	[CFirst],60
	jmp	SSTR

Line69:	mov	[CFirst],69
	jmp	SSTR

Line74:	mov	[CFirst],74
	jmp	SSTR

; *
; * process Timer1 requests *
; *


SSTR:	cmp	ax,0bb3h
	je	SetTimer1		; starmaster
	cmp	ax,0a757h
	je	SetTimer1		; solaris
	cmp	ax,08614h
	je	SetTimer1		; demohrby
	cmp	ax,0c8bah
	je	SetTimer1		; immies

	jmp	SSAU			; process audio requests

SetTimer1:
	mov	[TimerVec],offset Timer1 ; starmaster
	jmp	SSAU

; *
; * process audio requests (silence...)
; *

SSAU:	cmp	ax,0392dh
	je	SSAUQ			; vidchess
	cmp	ax,06b3dh
	je	SSAUQ			; boxing
	cmp	ax,08d5ch
	je	SSAUQ			; colorbar
	cmp	ax,0c814h
	je	SSAUQ			; dicepuzl
	cmp	ax,05b2ah
	je	SSAUQ			; dbldragn
	cmp	ax,0e271h
	je	SSAUQ			; casino
	cmp	ax,099c8h
	je	SSAUQ			; stampede
	cmp	ax,0ad92h
	je	SSAUQ			; tictac3d
	cmp	ax,0b1d0h
	je	SSAUQ			; homerun
	cmp	ax,0507bh
	je	SSAUQ			; slotmach


	jmp	SSCB			; process column blanking requests

SSAUQ:
	mov	[MinVol],20		; Quiet Please!
	jmp	SSCB

; *
; * process column blank requests *
; *

SSCB:	cmp	ax,0359ch
	je	SSCB8			; seaquest
	cmp	ax,0d0e6h
	je	SSCB8			; pitfall
	cmp	ax,0912ch
	je	SSCB8			; chopper command
	cmp	ax,0006bh
	je	SSCB8			; keystone kapers
	cmp	ax,048fbh
	je	SSCB8			; river raid
;	cmp	ax,0a402h
;	je	SSCB8			; spaceinv
	cmp	ax,070c3h
	je	SSCB8			; freeway
	cmp	ax,08ac5h
	je	SSCB8			; barnstorming
	cmp	ax,0676ch
	je	SSCB8			; commando
	cmp	ax,03f40h
	je	SSCB8			; crossbow
	cmp	ax,05b2ah
	je	SSCB8			; dbldragn
	cmp	ax,06fd1h
	je	SSCB8			; rivraid2
	cmp	ax,04094h
	je	SSCB8			; kung_fu
	cmp	ax,0de3ah
	je	SSCB8			; skatebrd
	cmp	ax,06289h
	je	SSCB8			; crackpot
	cmp	ax,068d0h
	je	SSCB8			; csmcomtr
	cmp	ax,0220fh
	je	SSCB8			; dolphin
	cmp	ax,04159h
	je	SSCB8			; frostbit
	cmp	ax,0d872h
	je	SSCB8			; grandprx
	cmp	ax,058a6h
	je	SSCB8			; holehunt
	cmp	ax,05974h
	je	SSCB8			; megmania
	cmp	ax,0c658h
	je	SSCB8			; pitf_cce
	cmp	ax,07ef2h
	je	SSCB8			; plaqattk
	cmp	ax,090d8h
	je	SSCB8			; pyrmdwar
	cmp	ax,0935dh
	je	SSCB8			; seahwk
	cmp	ax,0274fh
	je	SSCB8			; spacraid
	cmp	ax,0cbe1h
	je	SSCB8			; tacscan
	cmp	ax,0d58dh
	je	SSCB8			; tomboy
	cmp	ax,0186eh
	je	SSCB8			; vidcheck
	cmp	ax,0392dh
	je	SSCB8			; vidchess
	cmp	ax,06b3dh
	je	SSCB8			; boxing
	cmp	ax,0f608h
	je	SSCB8			; rs_baseb
	cmp	ax,00fdah
	je	SSCB8			; spcshutl
	cmp	ax,01cd4h
	je	SSCB4			; moonptrl
	cmp	ax,0b429h
	je	SSCB8			; pressure
;	cmp	ax,057cah
;	je	SSCB8			; mogulman (it switches!)

	jmp	SetupScoreMode


SSCB8:	mov	[ColumnBlank],8		; blank first 8 columns
	jmp	SetupScoreMode

SSCB4:	mov	[ColumnBlank],4		; blank first 4 columns
	jmp	SetupScoreMode


SetupScoreMode:
	cmp	ax,0359ch
	je	NoScore			; seaquest
	cmp	ax,0fbedh
	je	NoScore			; starraid
	jmp	SetupCyclesPerScanLine

NoScore:
	mov	[NoScoreMode],1
	jmp	SetupCyclesPerScanLine


SetupCyclesPerScanLine:
	cmp	ax,0e5beh
	je	Cycles1			; tetris26
	cmp	ax,0a402h
	je	Cycles3			; spaceinv
	cmp	ax,00eb4h
	je	Cycles1			; taxavoid
	cmp	ax,08e07h
	je	Cycles3			; catmouse
;	cmp	ax,0e90bh
;	je	Cycles3			; condor (doesn't help much)
	cmp	ax,022abh
	je	Cycles1			; cosmcrep
;	cmp	ax,09f21h
;	je	Cycles1			; crosfrce (doesn't fix)
;	cmp	ax,0217fh
;	je	Cycles3			; gopher (doesn't fix)
;	cmp	ax,07a61h
;	je	Cycles1			; imagslct (doesn't fix)
;	cmp	ax,0a9c2h
;	je	Cycles3			; jawbreak (doesn't fix)
;	cmp	ax,04cebh
;	je	Cycles3			; offrockr (doesn't fix)
;	cmp	ax,04f0eh
;	je	Cycles3			; pharhcrs (doesn't fix)
;	cmp	ax,03cd9h
;	je	Cycles3			; quickstp (doesn't fix)
;	cmp	ax,07be3h
;	je	Cycles1			; shootin (doesn't fix)
;	cmp	ax,0df79h
;	je	Cycles3			; spitfire (doesn't fix)

	jmp	SetupDone

Cycles1:
	mov	[CyclesPerLine],CyclesPerScanLine-1
	jmp	SetupDone

Cycles3:
	mov	[CyclesPerLine],CyclesPerScanLine-3
	jmp	SetupDone
	

SetupDone:
	ret

LoadFailx:
	pop	ds
LoadFail:
	pop	es
	mov	al,7
	jmp	ConOut

Control:mov	cl,es:1[bp]		; get control letter
	cmp	cl,'A'
	jl	CNext
	cmp	cl,'Z'
	jg	CNext
	add	cl,32
CNext:	add	bp,2
	mov	al,0
GetInt:	mov	ah,es:[bp]
	inc	bp
	cmp	ah,'0'
	jl	EndInt
	cmp	ah,'9'
	jg	EndInt
	mov	bl,al			; al = al * 10
	shl	al,2
	add	al,bl
	add	al,al
	add	al,ah
	sub	al,'0'
	jmp	GetInt

EndInt:					; Command in CL,Value in AL
	cmp	cl,'u'
	je	CMUpper
	cmp	cl,'l'
	je	CMLower
	cmp	cl,'c'
	je	CMChannel
	cmp	cl,'q'
	je	CMMinVol
	cmp	cl,'0'
	je	CMD0
	cmp	cl,'1'
	je	CMD1
	cmp	cl,'b'
	je	CMBW
	cmp	cl,'x'
	je	CMXsum
	cmp	cl,'r'
	je	CMNoRetrace
	cmp	cl,'t'
	je	CMTimer1
Back:	jmp	CLSkip			; back to the beginning

CMUpper:xor	ah,ah			; set upper scan line
	mov	[CFirst],ax
	jmp	CLSkip
CMLower:xor	ah,ah			; set lower scan line
	mov	[CLast],ax
	jmp	CLSkip

CMChannel:				; set the audio	sound channel (PC spkr)
	mov	[SDMPX],al
	jmp	CLSkip

CMMinVol:				; set the minimum volume (PC spkr)
	mov	[MinVol],al
	jmp	CLSkip

CMD0:	mov	al,[IOPortB]		; p0 hard
	or	al,64
	mov	[IOPortB],al
	jmp	CLSkip

CMD1:	mov	al,[IOPortB]		; p1 hard
	or	al,128
	mov	[IOPortB],al
	jmp	CLSkip

CMBW:	mov	al,[IOPortB]		; black	and white
	and	al,0C3h
	mov	[IOPortB],al
	jmp	CLSkip

CMXsum:	mov	[DoChecksum],1		; do checksum
	jmp	CLSkip

CMNoRetrace:
	mov	[NoRetrace],1		; don't wait for retrace (full speed)
	jmp	CLSkip

CMTimer1:
	mov	[TimerVec],offset Timer1 ; force Timer1
	jmp	CLSkip

; we didn't see a filename string

CLDoNoFile:
	pop	es
	mov	dx,offset CopyRight
	mov	ah,9
	int	MSDOS			; output the copyright msg
	mov	dx,offset Cred1
	mov	ah,9
	int	MSDOS
	mov	dx,offset Cred2
	mov	ah,9
	int	MSDOS
	mov	dx,offset Msg0
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg1
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg2
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg3
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg4
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg5
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg6
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg6a
	mov	ah,9
	int	MSDOS
	mov	dx,offset Msg7
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg8
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg9
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg10
	mov	ah,9
	int	MSDOS			; output a message
	mov	dx,offset Msg11
	mov	ah,9
	int	MSDOS			; output a message
	jmp	Empty			;   exit

.CEND
.DATASEGMENT

CopyRight	db	13,10,'z26 -- An Atari 2600 emulator (0.83)',13,10,'Copyright (C) 1997 by John Saeger',13,10,10,'$'
Cred1		db	'Based on A26 version 0.15 by Paul Robson.',13,10,'$'
Cred2		db	'PCX screen capture is by Ronnie Greene.',13,10,10,'$'
Msg0		db	'   F1 -- reset',13,10,'$'
Msg1		db	'   F2 -- select',13,10,'$'
Msg2		db	'   F9 -- black and white',13,10,'$'
Msg3		db	'  F10 -- color',13,10,'$'
Msg4		db	'SPACE -- fire',13,10,'$'
Msg5		db	'    p -- pause game',13,10,'$'
Msg6		db	'ENTER -- resume game',13,10,'$'
Msg6a		db	'    = -- PCX screen capture',13,10,'$'
Msg7		db	'  ESC -- quit game',13,10,10,'$'

Msg8		db	'Command Line Switches (put before filename)',13,10,10,'$'

Msg9		db	'   -0 -- player 0 hard',13,10,'$'
Msg10		db	'   -r -- do not wait for VGA retrace (full speed)',13,10,10,'$'

Msg11		db	'The Atari joystick is emulated with the arrow keys.',13,10,10,'$'

.DEND
.CODESEGMENT
