;*
;* do special setup for recognized cartridges
;*

SetupSpecial:
	jmp	SSFudgeMissile


;*
;* find checksum entry in table pointed to by si
;*

SSFIND:
SSFIND_Loop:
	mov	edx,dword ptr [si]	; pick up checksum
	add	si,4
	cmp	edx,-1			; at end of table ?
	je	SSFIND_Done
	test	edx,0ffff0000h		; top word set ?
	jnz	SSFIND_TestDouble	;   yes, do full dword test
	cmp	ax,dx			;   no, test words
	je	SSFIND_Done		; match
	jmp	SSFIND_Loop

SSFIND_TestDouble:
	cmp	eax,edx
	je	SSFIND_Done
	jmp	SSFIND_Loop

SSFIND_Done:
	ret


;*
;* fudge missile for icehocky
;*

SSFudgeMissile:
	cmp	eax,07df74h		; icehocky
	jne	SSFudgeTimer
	mov	[OldMissile],1
	jmp	SSFudgeTimer



;*
;* process requests to fudge timer
;*

SSFudgeTimer:
	cmp	ax,0b2d7h
	jne	SSTR
	mov	[TimerFudge],dword ptr 22	; frogpond
	jmp	SSTR


;*
;* process requests for Timer0
;*


SSTR:	
;	jmp	SetT0

	cmp	ax,07d00h
	je	SetT0			; berzerk
	cmp	ax,06b3dh
	je	SetT0			; boxing
	cmp	ax,0f1d7h
	je	SetT0			; checkact
	cmp	ax,04d38h
	je	SetT0			; espial
	cmp	ax,0c3ceh
	je	SetT0			; hero

	jmp	SSWRAP

SetT0:	mov	[TimerVec], offset Timer0
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
	cmp	ax,0ecc2h
	je	WZero			; beamride

	jmp	SSLINE

WZero:	mov	[WrapZero],1
	jmp	SSLINE

;*
;* process requests for special starting lines
;*

SSLINE:
	push	si
	mov	si,offset LineTable

SSLINE_Loop:
	mov	edx,dword ptr [si]	; pick up checksum
	add	si,4
	cmp	edx,-1			; at end of table ?
	je	SSLINE_Done
	test	edx,0ffff0000h		; top word set ?
	jnz	SSLINE_TestDouble	;   yes, do full dword test
	cmp	ax,dx			;   no, test words
	je	SSLINE_SetLine		; match
	inc	si
	jmp	SSLINE_Loop

SSLINE_TestDouble:
	cmp	eax,edx
	je	SSLINE_SetLine
	inc	si			; no match, skip line #
	jmp	SSLINE_Loop

SSLINE_SetLine:
	movzx	dx,byte ptr [si]
	mov	[CFirst],dx

SSLINE_Done:
	pop	si
	jmp	SSAU


.CEND
.DATASEGMENT

LineTable label byte

	dd	08387h			; actionmn
	db	68
	dd	078a61h			; air_raid
	db	50
	dd	0b0a9h			; alienret
	db	74
	dd	0fd0e6h			; artlduel
	db	26
	dd	0fd096h			; Art_duel
	db	26
	dd	07f62h			; asterpal
	db	68
	dd	06c060h			; astrblst
	db	30
	dd	06d274h			; atlantis
	db	42
	dd	04e06h			; bachelor
	db	28
	dd	05706h			; bachlrtt
	db	28
	dd	0568fh			; baseattk
	db	71
	dd	078e4ah			; bermdtri
	db	45
	dd	0737ddh			; bermuda
	db	32
	dd	016beh			; bibi
	db	71
	dd	0bf6fh			; bobby
	db	53
	dd	072efah			; boing
	db	45
	dd	03baceh			; bowling
	db	42
	dd	03cccdh			; braingms
	db	42
	dd	0f578h			; buckrog
	db	34
	dd	08504h			; burgtime
	db	32
	dd	06000h			; burndesr
	db	32
	dd	03d843h			; canyonb
	db	61
	dd	07d16h			; carnival
	db	31
	dd	034dch			; cathouse
	db	41
	dd	08e07h			; catmouse
	db	36
	dd	037b7h			; chalenge
	db	23
	dd	01a5eh			; challang
	db	41
	dd	045cbh			; chinasyn
	db	37
	dd	083e3h			; chuckwgn
	db	28
	dd	05485h			; circatri
	db	46
	dd	057177h			; circus
	db	44
	dd	00828h			; clwndown
	db	46
	dd	075b0dh			; cokewins
	db	40
	dd	0a01ch			; coln
	db	47
	dd	08698h			; combat
	db	43
	dd	039135h			; concentr
	db	43
	dd	0e90bh			; condor
	db	34
	dd	03cfah			; congbong
	db	46
	dd	0712ech			; cosmcark
	db	46
	dd	0d169h			; cosmcorr
	db	40
	dd	022abh			; cosmcrep
	db	45
	dd	03dac6h			; cosmswrm
	db	40
	dd	0e8575h			; crazclmb
	db	50
	dd	07b4aeh			; crshdive
	db	38
	dd	0657eh			; crusmisl
	db	41
	dd	014144ch		; cryscast
	db	40
	dd	05ac00h			; custrev
	db	37
	dd	07b6b1h			; cx2616pl
	db	50
	dd	02d81h			; dancplat
	db	58
	dd	05b2ah			; dbldragn
	db	68
	dd	07f16ch			; defender
	db	50
	dd	06f6b1h			; demonatk
	db	42
	dd	0ce26h			; dethtrap
	db	41
	dd	07c814h			; dicepuzl
	db	38
	dd	0885ch			; dragster
	db	32
	dd	07cd6h			; drgndfnd
	db	42
	dd	01984ach		; dsrtfalc
	db	27
	dd	02902h			; duckshot
	db	68
	dd	02018h			; earthdie
	db	36
	dd	06ccd7h			; eggomana
	db	46
	dd	066e29h			; encontl5
	db	42
	dd	06dd61h			; endro_tw
	db	37
	dd	06f69ah			; enduro
	db	37
	dd	04d38h			; espial
	db	70
	dd	070bb6h			; fantcvoy
	db	36
	dd	06ee6dh			; farmyard
	db	38
	dd	09233h			; fatalrun
	db	68
	dd	08dcfh			; fb_pir8
	db	68
	dd	0ab1ch			; fighterp
	db	60
	dd	08ab0h			; firebird
	db	77
	dd	0729f3h			; firefite
	db	44
	dd	0756ach			; firefly
	db	50
	dd	03d33ch			; flagcapt
	db	43
	dd	03d15eh			; football
	db	41
	dd	046b6h			; forest
	db	70
	dd	074a05h			; frankmon
	db	43
	dd	0b2d7h			; frogpond (Vblank triggers frame)
	db	0	
	dd	00cb2h			; front_rk
	db	43
	dd	07325fh			; galaga
	db	35
	dd	094b8h			; ghostman
	db	33
	dd	07104fh			; gigolo
	db	41
	dd	08e4dh			; gijoe
	db	36
	dd	049beh			; grescape
	db	35
	dd	0fdbfh			; harbresc
	db	45
	dd	07c8bah			; immies
	db	24
	dd	08828h			; infiltrt
	db	35
	dd	0b00ah			; iwantmom
	db	42
	dd	0a9c2h			; jawbreak
	db	31
	dd	0ef53h			; jediaren
	db	38
	dd	04000h			; jnglfevr
	db	32
	dd	077a48h			; jrnyescp
	db	41
	dd	0cb15h			; karate
	db	33
	dd	00a00h			; knightwn
	db	40
	dd	00b7ah			; lasrgate
	db	28
	dd	0ff2ch			; lasrvoly
	db	28
	dd	07e228h			; m_a_d
	db	47
	dd	03769h			; malagai
	db	40
	dd	079f28h			; mangia
	db	34
	dd	07c25eh			; marflegr
	db	44
	dd	00264h			; mastbuld
	db	42
	dd	09e43h			; metdef
	db	71
	dd	03db85h			; minigolf
	db	46
	dd	0ec87h			; minrvol2
	db	68
	dd	07900h			; mislcont
	db	86
	dd	0dc54h			; misn3000
	db	60
	dd	07ccdeh			; misslcmd
	db	44
	dd	02510h			; mnr2049r
	db	36
	dd	0757cah			; mogulman
	db	37
	dd	07c2bh			; motocros
	db	86
	dd	0a890h			; mrdo
	db	37
	dd	06d7fch			; muscmach
	db	45
	dd	0ced99h			; mygolf
	db	60
	dd	02a4bh			; nghtmare
	db	41
	dd	08403h			; nightstk
	db	66
	dd	072126h			; noescape
	db	51
	dd	09e5a5h			; obelix
	db	68
	dd	06c90ah			; oceancity
	db	42
	dd	04cebh			; offrockr
	db	36
	dd	0613ch			; omegrace
	db	46
	dd	06a939h			; opensesm
	db	42
	dd	00fc5h			; packong
	db	32
	dd	054f5h			; parachut
	db	63
	dd	09f1eh			; pacman
	db	37
	dd	07187dh			; pandchse
	db	43
	dd	045aeh			; phantomt
	db	65
	dd	04f0eh			; pharhcrs (Vblank triggers frame)
	db	0	
	dd	061d00h			; philly
	db	36
	dd	0e89f9h			; phoenix
	db	42
	dd	06ae6h			; piececke
	db	47
	dd	073c87h			; plantpat
	db	45
	dd	0d60bfh			; polaris
	db	63
	dd	0cc026h			; popeye
	db	46
	dd	0759b0h			; pooyan
	db	32
	dd	0de082h			; porkys
	db	46
	dd	0790d8h			; pyrmdwar
	db	60
	dd	06de9bh			; qbert
	db	48
	dd	05653h			; qbrtqube
	db	37
	dd	061495h			; raftridr
	db	47
	dd	076a4h			; rescter1
	db	36
	dd	016bf9ah		; roadrunr
	db	32
	dd	0da469h			; rocnrope
	db	38
	dd	07ffd8h			; roomdoom
	db	32
	dd	0ef608h			; rs_baseb
	db	37
	dd	0cdbcch			; rstennis
	db	70
	dd	07200ah			; saveship
	db	45
	dd	06fc86h			; seamnstr
	db	45
	dd	07be3h			; shootin
	db	35
	dd	0dde3ah			; skatebrd
	db	37
	dd	070a3eh			; skihunt
	db	43
	dd	0398afh			; skydiver
	db	43
	dd	03507bh			; slotmach
	db	43
	dd	0f56deh			; smurf_pl
	db	66
	dd	0f2462h			; smurfres
	db	53
	dd	02697h			; snalsqrl
	db	54
	dd	075df2h			; snekpeek
	db	38
	dd	07e543h			; sorcerer
	db	50
	dd	078933h			; spacattk
	db	37
	dd	07a402h			; spaceinv
	db	42
	dd	07d2f5h			; spachase
	db	40
	dd	03da9dh			; spacjock
	db	44
	dd	06f551h			; spcinvad
	db	44
	dd	07c896h			; spcrobot
	db	44
	dd	0736a0h			; spidrftr
	db	38
	dd	06373h			; spidrman
	db	32
	dd	00cc0h			; spikpeak
	db	50
	dd	06df79h			; spitfire
	db	35
	dd	0109a6dh		; sprcobra
	db	45
	dd	0cf71h			; springer
	db	40
	dd	0148037h		; sprnmast
	db	32
	dd	0dc396h			; spyhuntr
	db	36
	dd	08769ch			; sssnake
	db	41
	dd	07554fh			; starfox
	db	50
	dd	077fceh			; stargn
	db	48
	dd	070bb3h			; starmast
	db	57
	dd	0f4668h			; startrek
	db	38
	dd	07679dh			; stratgyx
	db	29
	dd	0772ach			; strnghld
	db	38
	dd	0deebh			; strwbery
	db	40
	dd	0cd03h			; supferar
	db	68
	dd	06cc64h			; supferri
	db	33
	dd	0127a01h		; suprbasb
	db	37
	dd	08000h			; surfprds
	db	62
	dd	03f52dh			; surround
	db	42
	dd	070c4h			; survlrun
	db	36
	dd	0cbe1h			; tacscan
	db	47
	dd	01866h			; tapeworm
	db	42
	dd	019e4h			; tapper
	db	37
	dd	03a20ah			; tennis
	db	42
	dd	0fb0ceh			; test
	db	27
	dd	06fa48h			; thrshold
	db	28
	dd	079cfh			; timewarp
	db	44
	dd	06d58dh			; tomboy
	db	32
	dd	09379h			; toothpro
	db	36
	dd	04d67h			; towerinf
	db	42
	dd	08822h			; ufopatrl
	db	26
	dd	08272h			; univchos
	db	48
	dd	0748dfh			; vidcube
	db	41
	dd	05e7eh			; vidolymp
	db	37
	dd	0811h			; walker
	db	47
	dd	07bfc2h			; walldfnd
	db	38
	dd	07f832h			; wordzapr
	db	33
	dd	0776e4h			; worldend
	db	69
	dd	044dch			; xenophob
	db	38
	dd	096a1h			; xevious
	db	31
	dd	062d5h			; zoofun
	db	37

	dd	-1			; end of table

.DEND
.CODESEGMENT


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

SSCB:	mov	si,offset ColumnBlankTable
	call	SSFIND			; lookup checksum
	cmp	edx,-1
	je	SetupScoreMode		;   not found
	mov	[ColumnBlank],8		;   found, blank first 8 columns
	jmp	SetupScoreMode

.CEND
.DATASEGMENT

ColumnBlankTable label byte

	dd	0359ch			; seaquest
	dd	0d0e6h			; pitfall
	dd	0912ch			; chopper command
	dd	0006bh			; keystone kapers
	dd	048fbh			; river raid
	dd	070c3h			; freeway
	dd	08ac5h			; barnstorming
	dd	0676ch			; commando
	dd	03f40h			; crossbow
	dd	05b2ah			; dbldragn
	dd	06fd1h			; rivraid2
	dd	04094h			; kung_fu
	dd	0de3ah			; skatebrd
	dd	06289h			; crackpot
	dd	068d0h			; csmcomtr
	dd	0220fh			; dolphin
	dd	04159h			; frostbit
	dd	0d872h			; grandprx
	dd	058a6h			; holehunt
	dd	05974h			; megmania
	dd	0c658h			; pitf_cce
	dd	07ef2h			; plaqattk
	dd	090d8h			; pyrmdwar
	dd	0935dh			; seahwk
	dd	0274fh			; spacraid
	dd	0cbe1h			; tacscan
	dd	0d58dh			; tomboy
	dd	0186eh			; vidcheck
	dd	0392dh			; vidchess
	dd	06b3dh			; boxing
	dd	0f608h			; rs_baseb
	dd	00fdah			; spcshutl
	dd	01cd4h			; moonptrl
	dd	0b429h			; pressure
	dd	09538h			; lasrblst
	dd	046b6h			; forest
	dd	0b1d0h			; homerun
	dd	0c25eh			; marflegr
	dd	057cah			; mogulman (** it switches! **)
	dd	0bf9ah			; roadrunr
	dd	0ecc2h			; beamride
	dd	0dd61h			; endro_tw
	dd	0f69ah			; enduro
	dd	0ad52h			; decathln
	dd	0f815h			; robotank
	dd	0b491h			; skyjinks
;	dd	094a9h			; he_man (** it switches! **)

	dd	-1

.DEND
.CODESEGMENT


SetupScoreMode:
	cmp	ax,0359ch
	je	NoScore			; seaquest
	cmp	ax,0fbedh
	je	NoScore			; starraid
	cmp	ax,0ffb5h
	je	NoScore			; alphbeam

	jmp	SetP1Hard

NoScore:
	mov	[NoScoreMode],1
	jmp	SetP1Hard


SetP1Hard:
	cmp	ax,094a9h
	je	SP1HARD
	jmp	SetupWrapWsync

SP1HARD:
	mov	dl,[IOPortB]		; p1 hard
	or	dl,128
	mov	[IOPortB],dl
	jmp	SetupWrapWsync

SetupWrapWsync:

	cmp	ax,09f21h
	je	DoWrapWsync		; crosfrce
	cmp	ax,0e0e9h
	je	DoWrapWsync		; astroidc
	cmp	ax,08ae0h
	je	DoWrapWsync		; astroids
	cmp	ax,03cfah
	je	DoWrapWsync		; congbong
	jmp	SetupDone

DoWrapWsync:
	mov	[WrapWsync],1
	jmp	SetupDone

	

SetupDone:
	ret

