;*
;* do special setup for recognized cartridges
;*


;*
;* process requests to reverse sense of test of vertical sync
;*

SetupSpecial:
	cmp	ax,07c93h
	je	SSReverse		; centiped
	cmp	ax,09f1eh
	je	SSReverse		; pacman
	cmp	ax,00cc0h
	je	SSReverse		; spikpeak
	cmp	ax,09aa0h
	je	SSReverse		; namegame
	cmp	ax,0bb9ch
	je	SSReverse		; bowling

	jmp	SSWRAP

SSReverse:
	mov	[ReverseSync],1
	jmp	SSWRAP

;*
;* process requests for wrapping negative player positions to zero
;*

SSWRAP:	cmp	ax,0d274h
	je	WZero			; atlantis
	cmp	ax,0c90ah
	je	WZero			; oceancty
	cmp	ax,0de3ah
	je	WZero			; skatebrd
	cmp	ax,0adb9h
	je	WZero			; sq_earth
	cmp	ax,06289h
	je	WZero			; crackpot
	cmp	ax,05b2ah
	je	WZero			; dbldragn
	cmp	ax,058a6h
	je	WZero			; holehunt
	cmp	ax,0deebh
	je	WZero			; strwbery
	cmp	ax,06b3dh
	je	WZero			; boxing

	jmp	SSLINE

WZero:	mov	[WrapZero],1
	jmp	SSLINE

;*
;* process requests for special starting lines
;*

SSLINE:
	cmp	ax,0f69ah
	je	Line42B			; enduro
	cmp	ax,0b0a9h
	je	Line66			; alienret
	cmp	ax,0f578h
	je	Line32			; buckrog
	cmp	ax,08387h
	je	Line64			; actionmn
	cmp	ax,0ab1ch
	je	Line52			; fighterp (* doesn't fix *)
	cmp	ax,07f62h
	je	Line69			; asterpal
	cmp	ax,03695h
	je	Line35			; dkjr
	cmp	ax,0e90bh
	je	Line32			; condor
	cmp	ax,022abh
	je	Line52			; cosmcrep
	cmp	ax,0ce26h
	je	Line48			; dethtrap
	cmp	ax,07cd6h
	je	Line42			; drgndfnd
	cmp	ax,046b6h
	je	Line74			; forest
	cmp	ax,0b109h
	je	Line32			; iq180
	cmp	ax,0a9c2h
	je	Line18			; jawbreak
	cmp	ax,00b7ah
	je	Line31			; lasrgate
	cmp	ax,0ff2ch
	je	Line31			; lasrvoly
	cmp	ax,03769h
	je	Line46			; malagai
	cmp	ax,0dc54h
	je	Line60			; misn3000
	cmp	ax,0877fh
	je	Line40			; mousetrp
	cmp	ax,00fc5h
	je	Line28			; packong
	cmp	ax,045aeh
	je	Line66			; phantomt
	cmp	ax,04f0eh
	je	Line24			; pharhcrs
	cmp	ax,0200ah
	je	Line41			; saveship
	cmp	ax,0fc86h
	je	Line41			; seamnstr
	cmp	ax,07be3h
	je	Line22			; shootin
	cmp	ax,02697h
	je	Line50			; snalsqrl
	cmp	ax,0769ch
	je	Line40			; sssnake
	cmp	ax,0deebh
	je	Line40			; strwbery
	cmp	ax,08000h
	je	Line60			; surfprds
	cmp	ax,04d67h
	je	Line48			; towerinf
	cmp	ax,00de3h
	je	Line34			; wallball
	cmp	ax,0bfc2h
	je	Line34			; walldfnd
	cmp	ax,0568fh
	je	Line69			; baseattk (doesn't fix)
	cmp	ax,062d5h
	je	Line34			; zoofun
	cmp	ax,08698h
	je	Line40			; combat
	cmp	ax,09318h
	je	Line35			; indy500
	cmp	ax,0e5beh
	je	Line37			; Tetris26
	cmp	ax,0a402h
	je	Line42			; spaceinv
	cmp	ax,01088h
	je	Line18			; darkcham
	cmp	ax,0bd1dh
	je	Line48			; jrpacman
	cmp	ax,016cfh
	je	Line38			; kangaroo
	cmp	ax,0d1a7h
	je	Line38			; polepos
	cmp	ax,0f608h
	je	Line32			; rs_baseb
	cmp	ax,07044h
	je	Line37			; solarfox
	cmp	ax,00cc0h
	je	Line50			; spikpeak
	cmp	ax,0c5dch
	je	Line40			; taz
	cmp	ax,08bbbh
	je	Line37			; vanguard
	cmp	ax,0912ch
	je	Line50			; choprcmd
	cmp	ax,083e3h
	je	Line31			; chuckwgn
	cmp	ax,00828h
	je	Line43			; clwndown
	cmp	ax,0fdbfh
	je	Line42			; harbresc

	cmp	ax,044dch
	je	Line34			; xenophob
	cmp	ax,0ffb5h
	je	Line36			; alphbeam
	cmp	ax,0e0e9h
	je	Line36			; astroidc
	cmp	ax,08ae0h
	je	Line36			; astroids
	cmp	ax,01a5eh
	je	Line36			; challang
	cmp	ax,08234h
	je	Line30			; eggcatch
	cmp	ax,02bc1h
	je	Line36			; mspacman
	cmp	ax,04e4ah
	je	Line36			; piginspc
	cmp	ax,02462h
	je	Line36			; smurfres
	cmp	ax,0fbedh
	je	Line36			; starraid
	cmp	ax,08e07h
	je	Line36			; catmouse
	cmp	ax,045cbh
	je	Line35			; chinasyn
	cmp	ax,08d5ch
	je	Line36			; colorbar
	cmp	ax,02415h
	je	Line36			; comandrd
	cmp	ax,09f21h
	je	Line36			; crosfrce
	cmp	ax,02d81h
	je	Line58			; dancplat
	cmp	ax,081cfh
	je	Line40			; darkcvrn
	cmp	ax,0bd1fh
	je	Line42			; dishastr
	cmp	ax,0ccd7h
	je	Line40			; eggomana
	cmp	ax,00cb2h
	je	Line40			; front_rk
	cmp	ax,08828h
	je	Line36			; infiltrt
	cmp	ax,0cb15h
	je	Line30			; karate
	cmp	ax,06097h
	je	Line36			; marinwar
	cmp	ax,04790h
	je	Line38			; mrpostmn
	cmp	ax,09aa0h
	je	Line36			; namegame
	cmp	ax,09f1eh
	je	Line36			; pacman
	cmp	ax,0187dh
	je	Line38			; pandchse
	cmp	ax,076a4h
	je	Line28			; rescter1
	cmp	ax,0badeh
	je	Line34			; sharkatk
	cmp	ax,08each
	je	Line36			; shtlorbt
	cmp	ax,00a3eh
	je	Line36			; skihunt
	cmp	ax,0d2f5h
	je	Line40			; spachase
	cmp	ax,0f551h
	je	Line40			; spactunl
	cmp	ax,06373h
	je	Line32			; spidrman
	cmp	ax,0c4a4h
	je	Line40			; squeezbx
	cmp	ax,0deb1h
	je	Line36			; supercce
	cmp	ax,0ddb2h
	je	Line36			; suprman1
	cmp	ax,0d95eh
	je	Line36			; suprman2
	cmp	ax,046d8h
	je	Line34			; tanksbut
	cmp	ax,01866h
	je	Line40			; tapeworm
	cmp	ax,08822h
	je	Line24			; ufopatrl
	cmp	ax,08272h
	je	Line43			; univchos
	cmp	ax,0186eh
	je	Line36			; vidcheck
	cmp	ax,00194h
	je	Line36			; othello
	cmp	ax,04e40h
	je	Line47			; advntron
	cmp	ax,09794h
	je	Line36			; assault
	cmp	ax,0d169h
	je	Line36			; cosmcorr
	cmp	ax,0c814h
	je	Line38			; dicepuzl
	cmp	ax,08ab0h
	je	Line72			; firebird
	cmp	ax,0a1c0h
	je	Line42			; fishdrby
	cmp	ax,0ec02h
	je	Line37			; flashgrd
	cmp	ax,070c3h
	je	Line39			; freeway
	cmp	ax,000d3h
	je	Line34			; frogger
	cmp	ax,0b2d7h
	je	Line36			; frogpond
	cmp	ax,01129h
	je	Line44			; funwnumb
	cmp	ax,06c7ch
	je	Line42			; kaboom
	cmp	ax,00264h
	je	Line42			; mastbuld
	cmp	ax,057cah
	je	Line32			; mogulman
	cmp	ax,01cd4h
	je	Line32			; moonptrl
	cmp	ax,0d7fch
	je	Line42			; muscmach
	cmp	ax,059b0h
	je	Line28			; pooyan
	cmp	ax,090d8h
	je	Line64			; pyrmdwar
	cmp	ax,0b384h
	je	Line39			; quintroo
	cmp	ax,0dbcch
	je	Line67			; rstennis
	cmp	ax,0c962h
	je	Line40			; skeetsht
	cmp	ax,0507bh
	je	Line39			; slotmach
	cmp	ax,0861ah
	je	Line38			; spacewar
	cmp	ax,0f52dh
	je	Line37			; surround
	cmp	ax,070c4h
	je	Line12			; survlrun
	cmp	ax,0ad92h
	je	Line38			; tictac3d
	cmp	ax,09fcch
	je	Line53			; trondead
	cmp	ax,0153bh
	je	Line40			; tubybird
	cmp	ax,0811h
	je	Line44			; walker


	jmp	SSTR			; process Timer1 requests


; *
; * start line setting handlers *
; *

Line12:	mov	[CFirst],12
	jmp	SSTR

Line18:	mov	[CFirst],18
	jmp	SSTR

Line22:	mov	[CFirst],22
	jmp	SSTR

Line24:	mov	[CFirst],24
	jmp	SSTR

Line26:	mov	[CFirst],26
	jmp	SSTR

Line28:	mov	[CFirst],28
	jmp	SSTR

Line30:	mov	[CFirst],30
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

Line39:	mov	[CFirst],39
	jmp	SSTR

Line40:	mov	[CFirst],40
	jmp	SSTR

Line41:	mov	[CFirst],41
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

Line47:	mov	[CFirst],47
	jmp	SSTR

Line48:	mov	[CFirst],48
	jmp	SSTR

Line50:	mov	[CFirst],50
	jmp	SSTR

Line52:	mov	[CFirst],52
	jmp	SSTR

Line53:	mov	[CFirst],53
	jmp	SSTR

Line54:	mov	[CFirst],54
	jmp	SSTR

Line56: mov	[CFirst],56
	jmp	SSTR

Line58:	mov	[CFirst],58
	jmp	SSTR

Line60:	mov	[CFirst],60
	jmp	SSTR

Line64:	mov	[CFirst],64
	jmp	SSTR

Line66:	mov	[CFirst],66
	jmp	SSTR

Line67:	mov	[CFirst],67
	jmp	SSTR

Line69:	mov	[CFirst],69
	jmp	SSTR

Line72:	mov	[CFirst],72
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
	cmp	ax,0186eh
	je	SSAUQ			; vidcheck


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
	je	SSCB8			; moonptrl
	cmp	ax,0b429h
	je	SSCB8			; pressure
	cmp	ax,09538h
	je	SSCB8			; lasrblst
	cmp	ax,046b6h
	je	SSCB8			; forest
	cmp	ax,0b1d0h
	je	SSCB8			; homerun
	cmp	ax,0c25eh
	je	SSCB8			; marflegr
	cmp	ax,057cah
	je	SSCB8			; mogulman (** it switches! **)

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
	cmp	ax,022abh
	je	Cycles1			; cosmcrep
	cmp	ax,08ab0h
	je	Cycles3			; firebird
	cmp	ax,0f52dh
	je	Cycles1			; surround


	jmp	SetupVBlankFrame

Cycles1:
	mov	[CyclesPerLine],CyclesPerScanLine-1
	jmp	SetupVBlankFrame

Cycles3:
	mov	[CyclesPerLine],CyclesPerScanLine-3
	jmp	SetupVBlankFrame

SetupVBlankFrame:
	cmp	ax,0bb9ch
	je	SetVBlankFrame		; bowling
	cmp	ax,0c771h
	je	SetVBlankFrame		; tunlrunr
	cmp	ax,0bb9ch
	je	SetVBlankFrame		; condor
;	cmp	ax,02b06h
;	je	SetVBlankFrame		; oscar

	jmp	SetupDone


SetVBlankFrame:
	mov	[VBlankFrame],1
	jmp	SetupDone
	

SetupDone:
	ret
