;*
;* do special setup for recognized cartridges
;*


;*
;* process requests to reverse sense of test of vertical sync
;*

SetupSpecial:
	cmp	ax,0e0e9h
	je	SSReverse		; astroidc (cures jitter)
	cmp	ax,08ae0h
	je	SSReverse		; astroids (cures jitter)
	cmp	ax,0677eh
	je	SSReverse		; bugsbun
	cmp	ax,00828h
	je	SSReverse		; clwndown (cures jitter)
	cmp	ax,0676ch
	je	SSReverse		; commando (cures missile from wrong position)
	cmp	ax,0a531h
	je	SSReverse		; doubdunk (cures bad graphics)
	cmp	ax,02bc1h
	je	SSReverse		; mspacman (shows first line)
	cmp	ax,00fc5h
	je	SSReverse		; packong
	cmp	ax,08b88h
	je	SSReverse		; ramit
	cmp	ax,0a402h
	je	SSReverse		; spaceinv
	cmp	ax,0deb1h
	je	SSReverse		; supercce
	cmp	ax,0ddb2h
	je	SSReverse		; suprman1
	cmp	ax,0d95eh
	je	SSReverse		; suprman2
	cmp	ax,070c4h
	je	SSReverse		; survlrun
	cmp	ax,0811h
	je	SSReverse		; walker
	cmp	ax,096a1h
	je	SSReverse		; xevious
;	cmp	ax,0a5d6h
;	je	SSReverse		; oystr29

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

	jmp	SSLINE

WZero:	mov	[WrapZero],1
	jmp	SSLINE

;*
;* process requests for special starting lines
;*

SSLINE:
	cmp	ax,08387h
	je	Line69			; actionmn
	cmp	ax,0b0a9h
	je	Line70			; alienret
	cmp	ax,0e0e9h
	je	Line36			; astroidc
	cmp	ax,08ae0h
	je	Line36			; astroids
	cmp	ax,0f578h
	je	Line35			; buckrog
	cmp	ax,06000h
	je	Line28			; burndesr
	cmp	ax,07d16h
	je	Line26			; carnival
	cmp	ax,08e07h
	je	Line34			; catmouse
	cmp	ax,037b7h
	je	Line19			; chalenge
	cmp	ax,01a5eh
	je	Line37			; challang
	cmp	ax,045cbh
	je	Line37			; chinasyn
	cmp	ax,083e3h
	je	Line28			; chuckwgn
	cmp	ax,00828h
	je	Line43			; clwndown
	cmp	ax,0a01ch
	je	Line43			; coln
	cmp	ax,08d5ch
	je	Line36			; colorbar
	cmp	ax,02415h
	je	Line36			; comandrd
	cmp	ax,08698h
	je	Line39			; combat
	cmp	ax,0e90bh
	je	Line32			; condor
	cmp	ax,09f21h
	je	Line36			; crosfrce
	cmp	ax,02d81h
	je	Line58			; dancplat
	cmp	ax,081cfh
	je	Line41			; darkcvrn
	cmp	ax,0ce26h
	je	Line48			; dethtrap
	cmp	ax,0c814h
	je	Line35			; dicepuzl
	cmp	ax,0bd1fh
	je	Line42			; dishastr
	cmp	ax,03695h
	je	Line36			; dkjr
	cmp	ax,0885ch
	je	Line29			; dragster
	cmp	ax,07cd6h
	je	Line38			; drgndfnd
	cmp	ax,02018h
	je	Line35			; earthdie
	cmp	ax,08234h
	je	Line30			; eggcatch
	cmp	ax,0ccd7h
	je	Line40			; eggomana
	cmp	ax,0f69ah
	je	Line42B			; enduro
	cmp	ax,0ab1ch
	je	Line52			; fighterp (* doesn't fix *)
	cmp	ax,0ec02h
	je	Line42			; flashgrd
	cmp	ax,046b6h
	je	Line70			; forest
	cmp	ax,00cb2h
	je	Line39			; front_rk
	cmp	ax,01129h
	je	Line48			; funwnumb
	cmp	ax,0fdbfh
	je	Line41			; harbresc
	cmp	ax,058a6h
	je	Line35			; holehunt
	cmp	ax,08828h
	je	Line31			; infiltrt
	cmp	ax,0a9c2h
	je	Line18			; jawbreak
	cmp	ax,04000h
	je	Line28			; jnglfevr
	cmp	ax,00a00h
	je	Line40			; knightwn
	cmp	ax,00b7ah
	je	Line28			; lasrgate
	cmp	ax,0ff2ch
	je	Line28			; lasrvoly
	cmp	ax,03769h
	je	Line36			; malagai
	cmp	ax,06097h
	je	Line44			; marinwar
	cmp	ax,00264h
	je	Line38			; mastbuld
	cmp	ax,0dc54h
	je	Line60			; misn3000
	cmp	ax,07c2bh
	je	Line83			; motocros
	cmp	ax,0877fh
	je	Line43			; mousetrp
	cmp	ax,02bc1h
	je	Line35			; mspacman
	cmp	ax,09aa0h
	je	Line32			; namegame
	cmp	ax,02b06h
	je	Line26			; oscar
	cmp	ax,00194h
	je	Line36			; othello
	cmp	ax,054f5h
	je	Line59			; parachut
	cmp	ax,00fc5h
	je	Line28			; packong
	cmp	ax,045aeh
	je	Line60			; phantomt
	cmp	ax,09f1eh
	je	Line36			; pacman
	cmp	ax,0187dh
	je	Line40			; pandchse
	cmp	ax,04e4ah
	je	Line36			; piginspc
	cmp	ax,076a4h
	je	Line36			; rescter1
	cmp	ax,0badeh
	je	Line36			; sharkatk
	cmp	ax,07be3h
	je	Line22			; shootin
	cmp	ax,08each
	je	Line36			; shtlorbt
	cmp	ax,02462h
	je	Line36			; smurfres
	cmp	ax,02697h
	je	Line50			; snalsqrl
	cmp	ax,07044h
	je	Line38			; solarfox
	cmp	ax,06373h
	je	Line32			; spidrman
	cmp	ax,00cc0h
	je	Line50			; spikpeak
	cmp	ax,0c4a4h
	je	Line40			; squeezbx
	cmp	ax,0deebh
	je	Line37			; strwbery
	cmp	ax,0deb1h
	je	Line36			; supercce
	cmp	ax,0ddb2h
	je	Line36			; suprman1
	cmp	ax,0d95eh
	je	Line36			; suprman2
	cmp	ax,0cd03h
	je	Line70			; supferar
	cmp	ax,0cc64h
	je	Line34			; supferri
	cmp	ax,08ed6h
	je	Line36			; surfsup1
	cmp	ax,08ed5h
	je	Line36			; surf_fix
	cmp	ax,08000h
	je	Line60			; surfprds
	cmp	ax,070c4h
	je	Line9			; survlrun
	cmp	ax,0cbe1h
	je	Line39			; tacscan
	cmp	ax,046d8h
	je	Line34			; tanksbut
	cmp	ax,01866h
	je	Line38			; tapeworm
	cmp	ax,079cfh
	je	Line40			; timewarp
	cmp	ax,08822h
	je	Line24			; ufopatrl
	cmp	ax,08272h
	je	Line48			; univchos
	cmp	ax,0811h
	je	Line42			; walker
	cmp	ax,00de3h
	je	Line34			; wallball
	cmp	ax,044dch
	je	Line37			; xenophob
	cmp	ax,096a1h
	je	Line28			; xevious
	cmp	ax,062d5h
	je	Line34			; zoofun
	cmp	ax,0f5b3h
	je	Line34			; starempr


	jmp	SSTR			; process Timer1 requests


; *
; * start line setting handlers *
; *

Line9:	mov	[CFirst],9
	jmp	SSTR

Line18:	mov	[CFirst],18
	jmp	SSTR

Line19:	mov	[CFirst],19
	jmp	SSTR

Line22:	mov	[CFirst],22
	jmp	SSTR

Line24:	mov	[CFirst],24
	jmp	SSTR

Line26:	mov	[CFirst],26
	jmp	SSTR

Line28:	mov	[CFirst],28
	jmp	SSTR

Line29:	mov	[CFirst],29
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

Line48:	mov	[CFirst],48
	jmp	SSTR

Line50:	mov	[CFirst],50
	jmp	SSTR

Line52:	mov	[CFirst],52
	jmp	SSTR

Line58:	mov	[CFirst],58
	jmp	SSTR

Line59:	mov	[CFirst],59
	jmp	SSTR

Line60:	mov	[CFirst],60
	jmp	SSTR

Line69:	mov	[CFirst],69
	jmp	SSTR

Line70:	mov	[CFirst],70
	jmp	SSTR

Line83:	mov	[CFirst],83
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
	cmp	ax,0bf9ah
	je	SSCB8			; roadrunr

	jmp	SetupScoreMode


SSCB8:	mov	[ColumnBlank],8		; blank first 8 columns
	jmp	SetupScoreMode


SetupScoreMode:
	cmp	ax,0359ch
	je	NoScore			; seaquest
	cmp	ax,0fbedh
	je	NoScore			; starraid
	cmp	ax,0ffb5h
	je	NoScore			; alphbeam

	jmp	SetupCPUOffset

NoScore:
	mov	[NoScoreMode],1
	jmp	SetupCPUOffset

SetupCPUOffset:
	cmp	ax,0a402h
	je	CPU71			; spaceinv
	cmp	ax,0e5beh
	je	CPU69			; tetris26
	cmp	ax,054f5h
	je	CPU69			; parachut

	jmp	SetupVBlankFrame

CPU69:	mov	[CPUOffset],69
	jmp	SetupVBlankFrame

CPU71:	mov	[CPUOffset],71
	jmp	SetupVBlankFrame

SetupVBlankFrame:
	cmp	ax,0bb9ch
	je	SetVBlankFrame		; bowling
	cmp	ax,0c771h
	je	SetVBlankFrame		; tunlrunr

	jmp	SetupDone


SetVBlankFrame:
	mov	[VBlankFrame],1
	jmp	SetupDone
	

SetupDone:
	ret
