;*
;* do special setup for recognized cartridges
;*

SetupSpecial:
	mov	eax,[_Checksum]
	jmp	SSKOOL


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
;* process KoolAide RESP cheat
;*

.data
KoolAide	db	0
.code

SSKOOL:
	mov	[KoolAide],0		; assume 0
IFDEF CHEATS
	cmp	eax,0715a2h		; koolaide
	je	SSKOOL_Set
	cmp	eax,071b5dh		; kool-sc
	je	SSKOOL_Set
;	cmp	eax,071a88h		; kool-fix
;	je	SSKOOL_Set
ENDIF
	jmp	SSRSBOXING

SSKOOL_Set:
	mov	[KoolAide],1
	jmp	SSRSBOXING

;*
;* process RSBOXING cheat
;*

.data
RSBoxing	db	0
.code

SSRSBOXING:
	mov	[RSBoxing],0
IFDEF CHEATS
	cmp	eax,24c452h		; rsboxing
	je	SSRSBOXING_Set
ENDIF
	jmp	SSTZ

SSRSBOXING_Set:
	mov	[RSBoxing],1
	jmp	SSTZ

;*
;* process requests to return zero for all undoc TIA reads
;*

.data
TIAZero		db	0
.code

SSTZ:	mov	[TIAZero],0
IFDEF CHEATS
	cmp	eax,067d00h		; berzerk
	je	SSTZ_Set
	cmp	eax,0d5653h		; qbrtqube
	je	SSTZ_Set
	cmp	eax,069fa4h		; spacecav
	je	SSTZ_Set
;	cmp	eax,069409h		; spacanyn
;	je	SSTZ_Set
	cmp	eax,070d15h		; tps
	je	SSTZ_Set
ENDIF
	jmp	SSCFF

SSTZ_Set:
	mov	[TIAZero],1
	jmp	SSCFF


;*
;* process requests to clear the first few frames
;*
;* (Should really have VSYNC clear to end of frame if it comes before MaxLines.)
;* (but I'm too lazy...)
;*

SSCFF:	mov	[MXDelayedClear],2
	cmp	eax,03d843h		; canyonb
	je	SSCFF_C
	cmp	eax,0e3cfah		; congbong
	je	SSCFF_B			
	cmp	eax,09b2d7h		; frogpond
	je	SSCFF_A
	cmp	eax,073c87h		; plantpat
	je	SSCFF_C

	jmp	SSTALL

SSCFF_A:
	mov	[MXDelayedClear],2
	jmp	SSTALL

SSCFF_B:
	mov	[MXDelayedClear],3
	jmp	SSTALL

SSCFF_C:
	mov	[MXDelayedClear],8
	jmp	SSTALL


;*
;* process requests for tall games
;*

SSTALL:
	mov	[MaxLines],204
	mov	[InitialMaxLines],204

;	cmp	eax,1fb7fbh		; shoot
;	je	SetTall

	cmp	eax,043a0bh		; 32in1-07
	je	SetMedium
	cmp	eax,03db3ch		; 32in1-11
	je	SetTall
	cmp	eax,039081h		; 32in1-17
	je	SetTall
	cmp	eax,037dc3h		; 32in1-20
	je	SetTall
	cmp	eax,035038h		; 32in1-21
	je	SetTall
	cmp	eax,0393d1h		; 32in1-26
	je	SetTall

	cmp	eax,0a8a4dh		; frogdemo
	je	SetMedium
	cmp	eax,0a654dh		; frogrpal
	je	SetMedium
	cmp	eax,0a734dh		; frogrsc
	je	SetMedium
	cmp	eax,0b214dh		; killrpal
	je	SetMedium
	cmp	eax,07814eh		; partydmo
	je	SetMedium
	cmp	eax,0bae4dh		; phasor
	je	SetMedium
	cmp	eax,0b994dh		; phasrpal
	je	SetMedium
	cmp	eax,0b444dh		; sarospal
	je	SetMedium
	cmp	eax,0a504dh		; surv1pal
	je	SetMedium



	cmp	eax,1d2f8eh		; aciddrop
	je	SetTall
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
	cmp	eax,0effc4h		; blueprnt
	je	SetMedium
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
	je	SetTall
	cmp	eax,0754f5h		; parachut
	je	SetMedium
	cmp	eax,0745aeh		; phantomt
	je	SetTall
	cmp	eax,1e3898h		; pickpile
	je	SetTall
	cmp	eax,084f0eh		; pharhcrs
	je	SetMedium
	cmp	eax,0759b0h		; pooyan
	je	SetTall
	cmp	eax,0d5653h		; qbrtqube
	je	SetMedium
	cmp	eax,0e5e28h		; robnhood
	je	SetMedium
	cmp	eax,07c82eh		; robofght
	je	SetTall
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
	cmp	eax,70d15h		; tps
	je	SetMedium
	cmp	eax,070811h		; walker
	je	SetMedium
	cmp	eax,0776e4h		; worldend
	je	SetTall
	cmp	eax,0762d5h		; zoofun
	je	SetTall

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
	cmp	[_XChecksum],0a9fcc60h	; fireball -- regular checksum matches frogrpal
	jne	SSL1
	mov	[_CFirst],36
	jmp	SSPADDLE

SSL1:	cmp	[_XChecksum],0580036eah	; mindmas1 -- matches mindpal1
	je	SSPADDLE

	mov	[UserCFirst],0ffffh
	mov	[DefaultCFirst],0ffffh
	mov	dx,[_CFirst]
	mov	[UserCFirst],dx		; remember...

	push	si
	mov	si,offset LineTable
	call	SSLINE_Setup
	pop	si

	mov	dx,[_CFirst]
	mov	[DefaultCFirst],dx	; remember again...

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

	dd	03c0f5h			; 32in1-00
	db	80
	dd	041004h			; 32in1-02
	db	70
	dd	03adcbh			; 32in1-03
	db	67
	dd	03d379h			; 32in1-04
	db	69
	dd	0401ceh			; 32in1-05
	db	67
	dd	03b89dh			; 32in1-06
	db	67
	dd	043a0bh			; 32in1-07
	db	60
	dd	03e311h			; 32in1-08
	db	60
	dd	03b0a9h			; 32in1-09
	db	70
	dd	0360f7h			; 32in1-10
	db	60
	dd	03db3ch			; 32in1-11
	db	53
	dd	03d19ch			; 32in1-12
	db	67
	dd	03df73h			; 32in1-13
	db	67
	dd	0393f5h			; 32in1-14
	db	67
	dd	038763h			; 32in1-15
	db	67
	dd	035da1h			; 32in1-16
	db	67
	dd	039081h			; 32in1-17
	db	47
	dd	0361fdh			; 32in1-18
	db	60
	dd	03933fh			; 32in1-19
	db	60
	dd	037dc3h			; 32in1-20
	db	46
	dd	035038h			; 32in1-21
	db	59
	dd	03b147h			; 32in1-22
	db	66
	dd	039a06h			; 32in1-23
	db	66
	dd	041866h			; 32in1-24
	db	60
	dd	0392f8h			; 32in1-25
	db	67
	dd	0393d1h			; 32in1-26
	db	50
	dd	038672h			; 32in1-27
	db	60
	dd	042cffh			; 32in1-28
	db	56
	dd	03db0ch			; 32in1-29
	db	66
	dd	03bb0ch			; 32in1-30
	db	68
	dd	03b208h			; 32in1-31
	db	65

	dd	0bd44dh			; commypal
	db	69
	dd	0bb44dh			; compaldm
	db	69
	dd	0a724dh			; drag1pal
	db	62
	dd	080ef9h			; drag2pal
	db	68
	dd	0a114dh			; drag3pal
	db	69
	dd	049ba6h			; drdmopal
	db	69
	dd	0a4f4dh			; firblpal
	db	62
	dd	089ea3h			; firpaldm
	db	62
	dd	0a654dh			; frogrpal (and fireball)
	db	64
	dd	0b214dh			; killrpal
	db	74
	dd	0bac4dh			; mindpall and mindmas1
	db	60
	dd	055fa6h			; mindpal2
	db	60
	dd	05fbfbh			; mindpal3
	db	60
	dd	08744dh			; mindpal4
	db	60
	dd	0b5d4dh			; mndmopal
	db	60
	dd	07804eh			; mxdmopal
	db	60
	dd	0b994dh			; phasrpal
	db	64
	dd	09094dh			; pmix1pal
	db	60
	dd	08b64dh			; pmix2pal
	db	60
	dd	098a4dh			; pmix3pal
	db	60
	dd	0ada4dh			; rabtpal
	db	60
	dd	0b444dh			; sarospal
	db	60
	dd	089c4dh			; sudmopal
	db	60
	dd	08a64dh			; suicdpall
	db	60
	dd	0a4a4dh			; surv2pal
	db	57
	dd	08dc4dh			; surv3pal
	db	57


	dd	08b021h			; excal39
	db	34
	dd	0a5dbfh			; 2600demo
	db	34
	dd	08634dh			; mindmas4
	db	34
	dd	091e4dh			; prtymix1
	db	34


	dd	01d2f8eh		; aciddrop
	db	69
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
	dd	075cafh			; birabira
	db	32
	dd	0bf6fh			; bobby
	db	53
	dd	072efah			; boing
	db	45
	dd	03baceh			; bowling
	db	42
;	dd	07779fh			; bowlg_tw (vblank triggers frame)
;	db	0
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
	db	36
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
	dd	0ccffeh			; dumbo
	db	55
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
;	dd	0b2d7h			; frogpond (Vblank triggers frame)
;	db	0	
	dd	00cb2h			; front_rk
	db	43
	dd	07325fh			; galaga
	db	35
	dd	13c58eh			; ghost2
	db	58
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
	dd	05d600h			; ladywdng
	db	41
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
	db	42
	dd	045aeh			; phantomt
	db	48
	dd	04f0eh			; pharhcrs (Vblank triggers frame)
	db	0	
	dd	061d00h			; philly
	db	36
	dd	0e89f9h			; phoenix
	db	42
	dd	1e3898h			; pickpile
	db	45
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
	dd	0e5e28h			; robnhood
	db	37
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
;	dd	1fb7fbh			; shoot
;	db	45
	dd	07be3h			; shootin
	db	35
	dd	0dde3ah			; skatebrd
	db	37
	dd	070a3eh			; skihunt
	db	42
	dd	06a5f1h			; ski_run
	db	52
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
	dd	07b179h			; traffic (vblank triggers frame)
	db	0			
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
	dd	0cbf85h			; wingwar
	db	51
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
	cmp	eax,03b0a9h		; 32in1-09
	je	SPG0
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
	cmp	eax,07ef53h		; jediaren
	je	SPG1
	cmp	eax,036c7ch		; kaboom
	je	SPG0
;	cmp	eax,079f28h		; mangia
;	je	SPG0
;	cmp	eax,06324eh		; mons
;	je	SPG1
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

;After taking a quick look through all my ROMs, (Never ask me a question
;like this again, if you want a fast answer. ;-) ) I think that
;Traffic, Zoo Fun, Farmyard Fun, Ski Run, Motorodeo, Klax, Open Sesame,
;Col N and Clown Down Town should be PAL and Motocross should be NTSC.
;There are some more games that seem to have the wrong set of colours,
;but I guess that for those the ROM for PAL and NTSC is the same anyway.

; don't have Traffic

SSP:	cmp	[_PaletteNumber],0ffh	; did user specify a palette number ?
	jne	SSAU			;   yes, don't override

	cmp	eax,03f28eh		; 32in1-01
	je	SSPAL
	cmp	eax,039081h		; 32in1-17
	je	SSPAL
	cmp	eax,037dc3h		; 32in1-20
	je	SSPAL

	cmp	eax,0a504dh		; surv1pal
	je	SSPAL


	cmp	eax,03d843h		; canyonb
	je	SSNTSC
	cmp	eax,070828h		; clwndown
	je	SSPAL
	cmp	eax,07a01ch		; coln
	je	SSPAL
	cmp	eax,072d81h		; dancplat
	je	SSPAL
	cmp	eax,07f16ch		; defender
	je	SSNTSC
	cmp	eax,06ee6dh		; farmyard
	je	SSPAL
	cmp	eax,078dcfh		; fb_pir8
	je	SSNTSC
	cmp	eax,0746b6h		; forest
	je	SSPAL
	cmp	eax,07325fh		; galaga
	je	SSPAL
	cmp	eax,1a4f39h		; klax
	je	SSPAL
	cmp	eax,07c25eh		; marflegr
	je	SSPAL
	cmp	eax,077c2bh		; motocros
	je	SSNTSC
	cmp	eax,1606a4h		; motor
	je	SSPAL
	cmp	eax,06a939h		; opensesm
	je	SSPAL
	cmp	eax,07187dh		; pandchse
	je	SSPAL
	cmp	eax,0754f5h		; parachut
	je	SSNTSC
	cmp	eax,1e3898h		; pickpile
	je	SSPAL
	cmp	eax,070a3eh		; skihunt
	je	SSPAL
	cmp	eax,06a5f1h		; ski_run
	je	SSPAL
	cmp	eax,070bb3h		; starmast
	je	SSNTSC
	cmp	eax,0f2462h		; smurfres
	je	SSNTSC
	cmp	eax,06d58dh		; tomboy
	je	SSPAL
	cmp	eax,07b179h		; traffic
	je	SSPAL
	cmp	eax,0cbf85h		; wingwar
	je	SSPAL
	cmp	eax,0762d5h		; zoofun
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


	jmp	SetP1Hard

SSAUQ:
	mov	[MinVol],20		; Quiet Please!
	jmp	SetP1Hard

; *
; * process player 1 hard requests
; *


SetP1Hard:
	cmp	ax,094a9h
	je	SP1HARD
	jmp	SetupLong

SP1HARD:
	mov	dl,[_IOPortB]		; p1 hard
	or	dl,128
	mov	[_IOPortB],dl
	jmp	SetupLong


;*
;* select how sharp to make the auto-sync test (bailout)
;*

.data
BailoutLine	dw	0
.code

SetupLong:
	cmp	eax,0b994dh	; phasrpal
	je	BailoutVeryLong


	cmp	eax,1d2f8eh	; *aciddrop
	je	BailoutVeryLong
	cmp	eax,06d1d4h	; astrowar
	je	BailoutVeryLong
	cmp	eax,0737ddh	; bermuda
	je	BailoutVeryLong
	cmp	eax,076f32h	; boombang
	je	BailoutVeryLong
	cmp	eax,0746b6h	; forest
	je	BailoutVeryLong
	cmp	eax,09b2d7h	; *frogpond
	je	BailoutVeryLong
	cmp	eax,07325fh	; galaga
	je	BailoutVeryLong
	cmp	eax,0749beh	; grescape
	je	BailoutVeryLong
	cmp	eax,06b109h	; iq180
	je	BailoutVeryLong
	cmp	eax,07cb15h	; karate
	je	BailoutVeryLong
	cmp	eax,0806aah	; *lockchse
	je	BailoutVeryLong
	cmp	eax,072a4bh	; nghtmare
	je	BailoutVeryLong
	cmp	eax,06f551h	; spactunl
	je	BailoutVeryLong
	cmp	eax,06a939h	; *opensesm
	je	BailoutLong
	cmp	eax,07187dh	; pandchse
	je	BailoutVeryLong
	cmp	eax,1e3898h	; pickpile
	je	BailoutVeryLong
	cmp	eax,073c87h	; plantpat
	je	BailoutVeryLong
	cmp	eax,0736dbh	; scudiv_p
	je	BailoutVeryLong
	cmp	eax,06fc86h	; seamnstr
	je	BailoutVeryLong
	cmp	eax,068each	; shtlorbt
	je	BailoutVeryLong
	cmp	eax,070a3eh	; *skihunt
	je	BailoutVeryLong
	cmp	eax,06a5f1h	; ski_run
	je	BailoutVeryLong
	cmp	eax,0684b8h	; spacmast
	je	BailoutVeryLong
	cmp	eax,07274fh	; spacraid
	je	BailoutVeryLong
	cmp	eax,0726efh	; spact_tw
	je	BailoutVeryLong
	cmp	eax,0ccf71h	; springer
	je	BailoutVeryLong
	cmp	eax,0d18cch	; sq_fire
	je	BailoutVeryLong
	cmp	eax,06cc64h	; supferri
	je	BailoutVeryLong
	cmp	eax,0746d8h	; tanksbut
	je	BailoutVeryLong
	cmp	eax,03e5beh	; tetris26
	je	BailoutVeryLong
	cmp	eax,0779cfh	; timewarp
	je	BailoutVeryLong
	cmp	eax,06d58dh	; tomboy
	je	BailoutVeryLong
	cmp	eax,07b179h	; traffic
	je	BailoutVeryLong
	cmp	eax,07153bh	; tubybird
	je	BailoutVeryLong
	cmp	eax,060de3h	; wallball
	je	BailoutVeryLong
	cmp	eax,07bfc2h	; walldfnd
	je	BailoutVeryLong
	cmp	eax,0cbf85h	; wingwar
	je	BailoutVeryLong
	cmp	eax,0776e4h	; worldend
	je	BailoutVeryLong
	cmp	eax,0762d5h	; zoofun
	je	BailoutVeryLong

NotLong:
	cmp	[_CFirst],0ffffh
	je	BailoutShort
	cmp	[_CFirst],44
	jb	BailoutShort

BailoutLong:
	mov	[BailoutLine],350
	jmp	SetupDone

BailoutShort:
	mov	[BailoutLine],270
	jmp	SetupDone

BailoutVeryLong:
	mov	[BailoutLine],5000
	jmp	SetupDone

SetupDone:
	ret

