.data

BailoutLine	dw	0

LongTable label dword
	dd	07a01ch		; coln
	dd	06a939h		; opensesm
	dd	06fc86h		; seamnstr
	dd	0726efh		; spact_tw
	dd	06f551h		; spactunl
	dd	03e5beh		; tetris26
	dd	-1



.code




;*
;* do special setup for recognized cartridges
;*

SetupSpecial:
	mov	eax,[_Checksum]
	jmp	SSFudgeTimer


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
;* process requests to fudge timer
;*

SSFudgeTimer:
	mov	dword ptr [TimerFudge],0
	cmp	ax,0b2d7h
	jne	SSGRPx
	mov	[TimerFudge],dword ptr 22	; frogpond
	jmp	SSGRPx

;*
;* process GRPx delay requests
;*

SSGRPx:
	mov	[GRPxDelay],1		; assume 1
	cmp	eax,0736a0h		; spidrftr
	jne	SSCFF
	mov	[GRPxDelay],-2
	jmp	SSCFF

;*
;* process requests to clear the first few frames
;*
;* (kludge, should really have vsync clear to end of frame if it comes before MaxLines)
;* (but I'm too lazy...)
;*

SSCFF:	mov	[MXDelayedClear],2
	cmp	eax,0e3cfah
	je	SSCFF_B			; congbong
	cmp	eax,09b2d7h
	je	SSCFF_A			; frogpond

	jmp	SSTR

SSCFF_A:
	mov	[MXDelayedClear],2
	jmp	SSTR

SSCFF_B:
	mov	[MXDelayedClear],3
	jmp	SSTR


;*
;* process requests for Timer0
;*


SSTR:	
	mov	[TimerVec], offset Timer1
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

SSWRAP:	mov	[WrapZero],0
	cmp	ax,06289h
	je	WZero			; crackpot
	cmp	ax,05b2ah
	je	WZero			; dbldragn
	cmp	ax,058a6h
	je	WZero			; holehunt
	cmp	ax,0deebh
	je	WZero			; strwbery
	cmp	eax,0d5653h
	je	WZero			; qbrtqube
	cmp	eax,0f56deh
	je	WZero			; smurf_pl (makes house show up)
	cmp	eax,0f2462h
	je	WZero			; smurfres (makes house show up)
	cmp	eax,0d1cd4h
	je	WZero			; moonptrl
	cmp	eax,0cf815h
	je	WZero			; robotank

	jmp	SSTALL

WZero:	mov	[WrapZero],1
	jmp	SSTALL

;*
;* process requests for tall games
;*

SSTALL:
	mov	[MaxLines],204
	mov	[InitialMaxLines],204
	cmp	eax,078a61h		; air_raid
	je	SetMedium
	cmp	eax,07b0a9h		; alienret
	je	SetMedium
	cmp	eax,054e06h		; bachelor
	je	SetMedium
	cmp	eax,055706h		; bachlrtt
	je	SetMedium
	cmp	eax,0716beh		; bibi
	je	SetTall
	cmp	eax,06bf6fh		; bobby
	je	SetTall
	cmp	eax,077d16h		; carnival
	je	SetMedium
	cmp	eax,0737b7h		; chalenge
	je	SetTall
	cmp	eax,0e1a5eh		; challang
	je	SetTall
	cmp	eax,0745cbh		; chinasyn
	je	SetMedium
	cmp	eax,070828h		; clwndown
	je	SetMedium
	cmp	eax,07a01ch		; coln
	je	SetMedium
	cmp	eax,0fbd78h		; color
	je	SetTall
	cmp	eax,06d169h		; cosmcorr
	je	SetMedium
	cmp	eax,07b6b1h		; cx2616pl
	je	SetTall
	cmp	eax,072d81h		; dancplat
	je	SetMedium
	cmp	eax,06ce26h		; dethtrap
	je	SetMedium
	cmp	eax,07c814h		; dicepuzl
	je	SetMedium
	cmp	eax,077cd6h		; drgndfnd
	je	SetTall
	cmp	eax,06ee6dh		; farmyard
	je	SetMedium
	cmp	eax,0746b6h		; forest
	je	SetTall
	cmp	eax,0749beh		; grescape
	je	SetMedium
	cmp	eax,07c8bah		; immies
	je	SetMedium
	cmp	eax,06b109h		; iq180
	je	SetMedium
	cmp	eax,07cb15h		; karate
	je	SetMedium
	cmp	eax,072d4dh		; kingkong
	je	SetMedium
	cmp	eax,073769h		; malagai
	je	SetMedium
	cmp	eax,07c25eh		; marflegr
	je	SetTall
	cmp	eax,0dec87h		; minrvol2
	je	SetMedium
	cmp	eax,0d2510h		; mnr2049r
	je	SetMedium
	cmp	eax,077c2bh		; motocros
	je	SetTall
	cmp	eax,06a939h		; opensesm
	je	SetTall
	cmp	eax,070fc5h		; packong
	je	SetMedium
	cmp	eax,07187dh		; pandchse
	je	SetMedium
	cmp	eax,0754f5h		; parachut
	je	SetMedium
	cmp	eax,0745aeh		; phantomt
	je	SetTall
	cmp	eax,084f0eh		; pharhcrs
	je	SetMedium
	cmp	eax,0759b0h		; pooyan
	je	SetTall
	cmp	eax,0d5653h		; qbrtqube
	je	SetMedium
	cmp	eax,0da469h		; rocnrope
	je	SetMedium
	cmp	eax,07200ah		; saveship
	je	SetMedium
	cmp	eax,06fc86h		; seamnstr
	je	SetTall
	cmp	eax,0dde3ah		; skatebrd
	je	SetMedium
	cmp	eax,070a3eh		; skihunt
	je	SetTall
	cmp	eax,072697h		; snalsqrl
	je	SetTall
	cmp	eax,075df2h		; snekpeek
	je	SetMedium
	cmp	eax,07d2f5h		; spachase
	je	SetMedium
	cmp	eax,06f551h		; spactunl
	je	SetTall
	cmp	eax,0726efh		; spact_tw
	je	SetTall
	cmp	eax,0d0cc0h		; spikpeak
	je	SetMedium
	cmp	eax,0dc396h		; spyhuntr
	je	SetMedium
	cmp	eax,05deebh		; strwbery
	je	SetMedium
	cmp	eax,0770c4h		; survlrun
	je	SetMedium
	cmp	eax,06fa48h		; thrshold
	je	SetMedium
	cmp	eax,0779cfh		; timewarp
	je	SetMedium
	cmp	eax,074d67h		; towerinf
	je	SetMedium
	cmp	eax,070811h		; walker
	je	SetMedium
	cmp	eax,0776e4h		; worldend
	je	SetTall
	cmp	eax,0762d5h		; zoofun
	je	SetMedium

	jmp	SSLINE


SetMedium:
	mov	[MaxLines],MAX_TallGame
	mov	[InitialMaxLines],220	; mark this a medium game
	jmp	SSLINE

SetTall:
	mov	[MaxLines],MAX_TallGame
	mov	[InitialMaxLines],MAX_TallGame
	jmp	SSLINE

ifdef compileoldcode

SetMedium:
	mov	[MaxLines],240
	mov	[InitialMaxLines],220	; mark this a medium game
	jmp	SSLINE

SetTall:
	mov	[MaxLines],240
	mov	[InitialMaxLines],240
	jmp	SSLINE

SetUltraMedium:
	mov	[MaxLines],240
	mov	[InitialMaxLines],220
	cmp	[_VideoMode],0ffh	; did user specify a video mode ?
	jne	SSLINE			;   yes, don't override
	mov	[_VideoMode],7		;   otherwise force mode 7
	jmp	SSLINE

SetUltraTall:
	mov	[MaxLines],240
	mov	[InitialMaxLines],240
	cmp	[_VideoMode],0ffh	; did user specify a video mode ?
	jne	SSLINE			;   yes, don't override
	mov	[_VideoMode],7		;   otherwise force mode 7
	jmp	SSLINE

endif

;*
;* process requests for special starting lines
;*

SSLINE:
	mov	[UserCFirst],0ffffh
	mov	[DefaultCFirst],0ffffh
	mov	dx,[_CFirst]
	mov	[UserCFirst],dx			; remember...

	push	si
	mov	si,offset LineTable
	call	SSLINE_Setup
	pop	si

	mov	dx,[_CFirst]
	mov	[DefaultCFirst],dx		; remember again...

	jmp	SSPADDLE


SSLINE_Setup:
SSLINE_Loop:
	mov	edx,dword ptr [si]	; pick up checksum
	add	si,4
	cmp	edx,-1			; at end of table ?
	je	SSLINE_SearchDone
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
	mov	[_CFirst],dx

SSLINE_SearchDone:
	ret

.data

LineTable label byte

	dd	01d2f8eh		; aciddrop
	db	62
	dd	08387h			; actionmn
	db	68
	dd	078a61h			; air_raid
	db	49
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
	db	41
	dd	04e06h			; bachelor
	db	29
	dd	05706h			; bachlrtt
	db	29
	dd	0568fh			; baseattk
	db	71
	dd	078e4ah			; bermdtri
	db	45
	dd	0737ddh			; bermuda
	db	32
	dd	016beh			; bibi
	db	50
	dd	0bf6fh			; bobby
	db	53
	dd	072efah			; boing
	db	45
	dd	03baceh			; bowling
	db	42
	dd	03cccdh			; braingms
	db	42
	dd	073ae7h			; brickick
	db	44
	dd	0f578h			; buckrog
	db	34
	dd	08504h			; burgtime
	db	32
	dd	06000h			; burndesr
	db	32
	dd	01a765ch		; califgms
	db	40
	dd	03d843h			; canyonb
	db	59
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
	db	30
	dd	05485h			; circatri
	db	46
	dd	057177h			; circus
	db	44
	dd	070828h			; clwndown
	db	47
	dd	07a01ch			; coln
	db	47
	dd	0fbd78h			; color
	db	36
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
	dd	022abh			; cosmcrep
	db	45
	dd	03dac6h			; cosmswrm
	db	40
	dd	0e8575h			; crazclmb
	db	49
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
	db	56
	dd	05b2ah			; dbldragn
	db	68
	dd	07f16ch			; defender
	db	50
	dd	06f6b1h			; demonatk
	db	41
	dd	0ce26h			; dethtrap
	db	41
	dd	07c814h			; dicepuzl
	db	38
	dd	06a21ch			; dodge_em
	db	49
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
	db	42
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
	db	49
	dd	09233h			; fatalrun
	db	68
	dd	08dcfh			; fb_pir8
	db	68
	dd	0ab1ch			; fighterp
	db	60
	dd	08ab0h			; firebird
	db	77
	dd	0729f3h			; firefite
	db	40
	dd	0756ach			; firefly
	db	49
	dd	03d33ch			; flagcapt
	db	43
	dd	03d15eh			; football
	db	41
	dd	046b6h			; forest (extra tall)
	db	41
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
	db	40
	dd	01cb8ach		; ikariwar
	db	56
	dd	07c8bah			; immies
	db	24
	dd	039318h			; indy500
	db	35
	dd	08828h			; infiltrt
	db	35
	dd	06b109h			; iq180
	db	37
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
	db	75
	dd	0dc54h			; misn3000
	db	60
	dd	07ccdeh			; misslcmd
	db	44
	dd	02510h			; mnr2049r
	db	36
	dd	0757cah			; mogulman
	db	37
	dd	07c2bh			; motocros
	db	51
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
	db	49
	dd	09e5a5h			; obelix
	db	68
	dd	06c90ah			; oceancity
	db	41
	dd	04cebh			; offrockr
	db	36
	dd	0613ch			; omegrace
	db	46
	dd	06a939h			; opensesm (extra tall)
	db	42
	dd	00fc5h			; packong
	db	32
	dd	054f5h			; parachut
	db	63
	dd	09f1eh			; pacman
	db	35
	dd	07187dh			; pandchse
	db	43
	dd	045aeh			; phantomt
	db	48
	dd	04f0eh			; pharhcrs (Vblank triggers frame)
	db	0	
	dd	061d00h			; philly
	db	36
	dd	0e89f9h			; phoenix
	db	42
	dd	06ae6h			; piececke
	db	49
	dd	073c87h			; plantpat
	db	45
	dd	0d60bfh			; polaris
	db	63
	dd	0cc026h			; popeye
	db	46
	dd	0759b0h			; pooyan
	db	30
	dd	0de082h			; porkys
	db	48
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
	dd	06fc86h			; seamnstr (extra tall)
	db	42
	dd	06badeh			; sharkatk
	db	37
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
	db	49
	dd	078933h			; spacattk
	db	37
	dd	07a402h			; spaceinv
	db	44
	dd	07d2f5h			; spachase
	db	40
	dd	03da9dh			; spacjock
	db	44
	dd	06f551h			; spactunl (extra tall)
	db	42
	dd	06f551h			; spcinvad
	db	44
	dd	07c896h			; spcrobot
	db	44
	dd	0736a0h			; spidrftr
	db	38
	dd	06373h			; spidrman
	db	32
	dd	00cc0h			; spikpeak
	db	43
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
	db	49
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
	db	41
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
	db	34
	dd	06d58dh			; tomboy
	db	32
	dd	09379h			; toothpro
	db	36
	dd	04d67h			; towerinf
	db	39
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
;	dd	0cbf85h			; wingwar
;	db	51
	dd	07f832h			; wordzapr
	db	33
	dd	0776e4h			; worldend
	db	42
	dd	044dch			; xenophob
	db	38
	dd	096a1h			; xevious
	db	31
	dd	062d5h			; zoofun
	db	37

	dd	-1			; end of table

.code

;*
;* process requests for paddle games
;*

SSPADDLE:

	cmp	eax,078387h		; actionmn
	je	SPG0
	cmp	eax,054e06h		; bachelor
	je	SPG0
	cmp	eax,055706h		; bachlrtt
	je	SPG0
	cmp	eax,062e00h		; beatem
	je	SPG0
	cmp	eax,03b06fh		; blakjack
	je	SPG0
	cmp	eax,03d708h		; breakout
	je	SPG0
	cmp	eax,0683f6h		; bugs
	je	SPG0
	cmp	eax,07e271h		; casino
	je	SPG0
	cmp	eax,05485dh		; circatri
	je	SPG0
	cmp	eax,06ee82h		; dem2dmds
	je	SPG1
	cmp	eax,06ccd7h		; eggomana
	je	SPG0
	cmp	eax,066e29h		; encontl5
	je	SPG0
	cmp	eax,078e4dh		; gijoe
	je	SPG0
	cmp	eax,070434h		; guardian
	je	SPG0
	cmp	eax,036c7ch		; kaboom
	je	SPG0
;	cmp	eax,079f28h		; mangia
;	je	SPG0
	cmp	eax,8929fh		; mpong10
	je	SPG0
	cmp	eax,06d7fch		; muscmach
	je	SPG0
	cmp	eax,03c030h		; nightdrv
	je	SPG0
	cmp	eax,061d00h		; philly
	je	SPG0
	cmp	eax,07844bh		; picnic
	je	SPG0
	cmp	eax,06ae62h		; piececke
	je	SPG0
	cmp	eax,06eaa5h		; solrstrm
	je	SPG0
	cmp	eax,03978ch		; stplchse
	je	SPG0
	cmp	eax,03bee2h		; strtracr
	je	SPG1
	cmp	eax,081aefh		; superbrk
	je	SPG0
	cmp	eax,07cbe1h		; tacscan
	je	SPG3
	cmp	eax,035e7eh		; vidolymp
	je	SPG1
	cmp	eax,07b217h		; warlords
	je	SPG0
	cmp	eax,07e2eah		; warplock
	je	SPG0


	jmp	SSP

SPG0:	mov	dx,0600h		; sensitivity 3, paddle 0
	jmp	SPGSet

SPG1:	mov	dx,0601h		; sensitivity 3, paddle 1
	jmp	SPGSet

SPG3:	mov	dx,0603h		; sensitivity 3, paddle 3
	jmp	SPGSet

SPGSet:	cmp	dword ptr [_PaddleGame],0
	jne	SPGSkipSensitivity
	mov	byte ptr [_PaddleGame],dh
SPGSkipSensitivity:
	cmp	[_KeyBase],0ffh
	jne	SPGSkipKeyBase
	mov	[_KeyBase],dl
SPGSkipKeyBase:
	jmp	SSP

;*
;* process requests for special palette
;*

SSP:	cmp	[_PaletteNumber],0ffh	; did user specify a palette number ?
	jne	SSAU			;   yes, don't override
	cmp	eax,07c25eh		; marflegr
	je	SSPAL
	cmp	eax,03d843h		; canyonb
	je	SSNTSC
	cmp	eax,072d81h		; dancplat
	je	SSPAL
	cmp	eax,07f16ch		; defender
	je	SSNTSC
	cmp	eax,078dcfh		; fb_pir8
	je	SSNTSC
	cmp	eax,0746b6h		; forest
	je	SSPAL
	cmp	eax,07325fh		; galaga
	je	SSPAL
	cmp	eax,0f2462h		; smurfres
	je	SSNTSC
	cmp	eax,070bb3h		; starmast
	je	SSNTSC
	cmp	eax,0754f5h		; parachut
	je	SSNTSC
	cmp	eax,06d58dh		; tomboy
	je	SSPAL
	jmp	SSAU

SSPAL:	mov	[_PaletteNumber],1
	jmp	SSAU

SSNTSC:	mov	[_PaletteNumber],0
	jmp	SSAU


; *
; * process audio requests (silence...)
; *

SSAU:	mov	[MinVol],8
	cmp	ax,0392dh
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


	jmp	SetupScoreMode		; process column blanking requests

SSAUQ:
	mov	[MinVol],20		; Quiet Please!
	jmp	SetupScoreMode

; *
; * process column blank requests *
; *

SSCB:	jmp	SetupScoreMode

SetupScoreMode:
	mov	[NoScoreMode],0
	cmp	ax,0359ch
	je	NoScore			; seaquest
	cmp	ax,0fbedh
	je	NoScore			; starraid
	cmp	ax,0ffb5h
	je	NoScore			; alphbeam
	cmp	eax,042cc1h
	je	NoScore			; bsktball

	jmp	SetP1Hard

NoScore:
	mov	[NoScoreMode],1
	jmp	SetP1Hard


SetP1Hard:
	cmp	ax,094a9h
	je	SP1HARD
	jmp	SetupLong

SP1HARD:
	mov	dl,[_IOPortB]		; p1 hard
	or	dl,128
	mov	[_IOPortB],dl
	jmp	SetupLong


SetupLong:
	mov	si,offset LongTable
	call	SSFIND
	cmp	edx,-1			; entry found ?
	je	NotLong			;   no, short game
	mov	[BailoutLine],340
	jmp	SetupDone

NotLong:
	mov	[BailoutLine],270
	jmp	SetupDone

SetupDone:
	ret

