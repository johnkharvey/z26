; banks.asm -- z26 bank switch stuff

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 02-17-98  got Parker Bros Working and added TigerVision

.data

ALIGN 2

ReadBank	dw	RBank4		; R/W vectors -- default to 4K cart
WriteBank	dw	WBank4
        
RomBank		dw	0		; Rom bank pointer for F8 & F16

; Parker Brother's ROM Slices

PBSlice0	dw	0
PBSlice1	dw	1*400h
PBSlice2	dw	2*400h
PBSlice3	dw	7*400h		; this one doesn't change
					; points to 1K bank #7
; Tigervision ROM Slices

TVSlice0	dw	0
TVSlice1	dw	3*800h		; this one doesn't change
					; points to 2K bank #3
; Tigervision 32 ROM Slices

TVSlice032	dw	0
TVSlice132	dw	15*800h		; this one doesn't change
					; points to 2K bank #15
; M-Network ROM Slices

MNSlice0	dw	0
MNSlice1	dw	7*800h		; this one doesn't change
					; points to 2K bank #3
; M-Network RAM Slices

MNRamSlice	dw	0		; which 256 byte ram slice

.code

;*
;* set up bank switch scheme
;*

SetupBanks:
	mov	[ReadBank], offset RBank4
	mov	[WriteBank], offset WBank4
	mov	[RomBank],0
	mov	[PBSlice0],0
	mov	[PBSlice1],1*400h
	mov	[PBSlice2],2*400h
	mov	[PBSlice3],7*400h
	mov	[TVSlice0],0
	mov	[TVSlice1],3*800h
	mov	[TVSlice032],0
	mov	[TVSlice132],15*800h
	mov	[MNSlice0],0
	mov	[MNSlice1],7*800h
	mov	[MNRamSlice],0
	mov	[Pitfall2],0
	mov	[Starpath],0

	mov	ax,[_CartSize]
	cmp	ax,01000h
	je	Set4KMode		; 4K cart
	cmp	ax,02000h
	je	Set8kMode		; 8K cart
	cmp	ax,03000h
	je	Set12KMode		; 12K cart
	cmp	ax,04000h
	je	Set16kMode		; 16K cart
	cmp	ax,08000h
	je	Set32kMode		; 32K cart
	cmp	ax,028ffh
	je	SetPitfallII		; Pitfall II cart
	cmp	ax,8448
	je	SetStarpath1		; Supercharger image
	cmp	ax,8448*2
	je	SetStarpath2
	cmp	ax,8448*3
	je	SetStarpath3
	cmp	ax,8448*4
	je	SetStarpath4
	ret

Set4KMode:
	mov	eax,[_Checksum]
	cmp	eax,08f5eeh
	je	SCV			; vidlife
	ret

SCV:
	mov	[ReadBank], offset RBankCV
	mov	[WriteBank], offset WBankCV
	ret

	

Set8kMode:
	mov	eax,[_Checksum]
	cmp	ax,032cfh
	je	SSC8			; stargate
	cmp	ax,025efh
	je	SSC8			; defendr2

	cmp	ax,0e446h
	je	SPB			; dethstar
	cmp	ax,0f9f8h
	je	SPB			; gyruss
	cmp	ax,09a6dh
	je	SPB			; sprcobra
	cmp	ax,0c831h
	je	SPB			; tutank
	cmp	ax,0c026h
	je	SPB			; popeye
	cmp	ax,0ce17h
	je	SPB			; swarcade
	cmp	eax,0cc455h
	je	SPB			; swtagpro
	cmp	ax,05653h
	je	SPB			; qbrtqube
	cmp	ax,0e31ah
	je	SPB			; frogger2
	cmp	ax,0fce0h
	je	SPB			; montzrev
	cmp	ax,01113h
	je	SPB			; docastle
	cmp	ax,09379h
	je	SPB			; toothpro
	cmp	eax,0e1923h
	je	SPB			; jamebond

	cmp	ax,0e35eh
	je	STV			; riverp
	cmp	ax,0cf71h
	je	STV			; springer
	cmp	ax,060bfh
	je	STV			; polaris
	cmp	ax,02510h
	je	STV			; mnr2049r
	cmp	ax,0ec87h
	je	STV			; minrvol2
	cmp	ax,04d38h
	je	STV			; espial

	cmp	ax,0ad52h
	je	SFE			; decathln
	cmp	ax,0f815h
	je	SFE			; robotank

SetF8:
	mov	[ReadBank], offset RBank8
	mov	[WriteBank], offset WBank8

	cmp	eax,0d7238h		; priveye
	je	F8Backwards

	mov	[RomBank],01000h	; need this for moonswep and lancelot
	ret

F8Backwards:
	ret


; set up Parker Brother's 8K bank switch scheme

SPB:	mov	[ReadBank], offset RBank8pb
	mov	[WriteBank], offset WBank8pb
	ret

; set up Tigervision 8K bank switch scheme

STV:	mov	[ReadBank], offset RBank8tv
	mov	[WriteBank], offset WBank8tv
	ret

; set up FE (flat model) bank switch scheme

SFE:	mov	[ReadBank], offset RBank8FE
	mov	[WriteBank], offset WBank8FE
	ret

Set12KMode:
	mov	[ReadBank], offset RBank12
	mov	[WriteBank], offset WBank12
	ret

Set16kMode:
	mov	eax,[_Checksum]
	cmp	ax,02416h
	je	SSC			; digdug
	cmp	ax,0a44ch
	je	SSC			; cryscast
	cmp	ax,0bc36h
	je	SSC			; milliped
	cmp	ax,0bd1dh
	je	SSC			; jrpacman
	cmp	ax,084ach
	je	SSC			; dsrtfalc
	cmp	ax,01088h
	je	SSC			; darkcham
	cmp	eax,1fb7fbh
	je	SSC			; shoot(ing gallery)
	cmp	ax,0c525h
	je	SSC			; sprfootb
	cmp	ax,08037h
	je	SSC			; sprnmast
	cmp	ax,05f30h
	je	SSC			; ofthwall
	cmp	ax,06db1h
	je	SSC			; secretq
	cmp	ax,09ffah
	je	SSC			; radarlok
	cmp	ax,04f39h
	je	SSC			; klax
	cmp	ax,04887h
	je	SSC			; klaxntsc
	cmp	eax,16217bh
	je	SSC			; savemary

	cmp	ax,094a9h
	je	SMN			; he_man
	cmp	ax,003c8h
	je	SMN			; bnj
	cmp	ax,08504h
	je	SMN			; burgtime

	mov	[ReadBank], offset RBank16
	mov	[WriteBank], offset WBank16
	ret

Set32kMode:
	mov	eax,[_Checksum]
	cmp	eax,0299233h
	je	SetFatalRun
	mov	[ReadBank], offset RBank32tv
	mov	[WriteBank], offset WBank32tv
	ret

SetFatalRun:
	mov	[ReadBank], offset RBank32sc
	mov	[WriteBank], offset WBank32sc
	ret

; setup 16K super-chip vectors

SSC:	mov	[ReadBank], offset RBank16sc
	mov	[WriteBank], offset WBank16sc
	ret

; setup M-Network 16K

SMN:	mov	[ReadBank], offset RBank16mn
	mov	[WriteBank], offset WBank16mn
	ret

; setup 8K super-chip vectors

SSC8:	mov	[ReadBank], offset RBank8sc
	mov	[WriteBank], offset WBank8sc
	ret

;*
;* hardware read/write testing macros
;*

test_hw_read macro
	and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware
	endm

test_hw_write macro
	and	si,01fffh
	cmp	si,1000h
	jb	WriteHardware
	endm

MapRomBank macro
	add	si,[RomBank]
	add	si,offset _CartRom - 1000h
	endm

WriteRam macro
	push	ax
	mov	al,[WByte]
	mov	[si],al
	pop	ax
	endm

;*
;* standard 4K cart
;*

RBank4: test_hw_read
	add	si,offset _CartRom - 1000h
	ret
        

WBank4:	test_hw_write
	ret


;*
;* Commavid RAM cart (vidlife)
;*

CVR_TestRam macro
local NotRam

	cmp	si,17ffh
	ja	NotRam
	add	si,offset _Ram - 1000h
	ret

NotRam:
	endm

CVW_TestRam macro
local NotRam

	cmp	si,17ffh
	ja	NotRam
	add	si,offset _Ram - 1000h - 400h
	WriteRam
	ret

NotRam:
	endm


RBankCV: test_hw_read
	CVR_TestRam
	add	si,offset _CartRom - 1000h
	ret
        

WBankCV:test_hw_write
	CVW_TestRam
	ret

;*
;* standard 8K cart (F8)
;*

SetBank_8 macro
local NoChange

	cmp	si,1FF8h		; if not in switch area ...
	jb	NoChange		; ... there's no change
	cmp	si,1FF9h
	ja	NoChange

	push	ax
	mov	ax,si
	sub	ax,1FF8h		; bank #
	shl	ax,12			; bank address
	mov	[RomBank],ax
	pop	ax

NoChange:
	endm

RBank8:	test_hw_read
	SetBank_8
	MapRomBank
	ret


WBank8:	test_hw_write
	SetBank_8
	ret

;*
;* standard 8K cart with Super-Chip (F8+sc)
;*

SCR_TestRam macro
local NotRam

	cmp	si,10ffh
	ja	NotRam
	add	si,offset _Ram - 1000h - 80h
	ret

NotRam:
	endm

SCW_TestRam macro
local NotRam

	cmp	si,10ffh
	ja	NotRam
	add	si,offset _Ram - 1000h
	WriteRam
	ret

NotRam:
	endm


RBank8sc:
	test_hw_read
	SetBank_8
	SCR_TestRam
	MapRomBank
	ret

WBank8sc:
	test_hw_write
	SetBank_8
	SCW_TestRam
	ret

;*
;* 12K Ram Plus cart (FA)
;*

SetBank_12 macro
local NoChange

	cmp	si,1FF8h		; if not in switch area ...
	jb	NoChange		; ... there's no change
	cmp	si,1FFAh
	ja	NoChange

	push	ax
	mov	ax,si
	sub	ax,1FF8h		; bank #
	shl	ax,12			; bank address
	mov	[RomBank],ax
	pop	ax

NoChange:
	endm

FAR_TestRam macro
local NotRam

	cmp	si,11ffh
	ja	NotRam
	add	si,offset _Ram - 1000h - 100h
	ret

NotRam:
	endm

FAW_TestRam macro
local NotRam

	cmp	si,10ffh
	ja	NotRam
	add	si,offset _Ram - 1000h
	WriteRam

NotRam:
	endm

RBank12:
	test_hw_read
	SetBank_12
	FAR_TestRam
	MapRomBank
	ret


WBank12:
	test_hw_write
	SetBank_12
	FAW_TestRam
	ret

;*
;* standard 16K cart (F16)
;*

SetBank_16 macro
local NoChange

	cmp	si,1FF6h		; if not in switch area...
	jb	NoChange		; ... there's no change
	cmp	si,1FF9h
	ja	NoChange

	push	ax
	mov	ax,si
	sub	ax,1FF6h		; bank #
	shl	ax,12			; bank address
	mov	[RomBank],ax
	pop	ax

NoChange:
	endm

RBank16:
	test_hw_read
	SetBank_16
	MapRomBank
	ret


WBank16:
	test_hw_write
	SetBank_16
	ret


;*
;* standard 16K cart with Super-Chip (F16+sc)
;*

RBank16sc:
	test_hw_read
	SetBank_16
	SCR_TestRam
	MapRomBank
	ret



WBank16sc:
	test_hw_write
	SetBank_16
	SCW_TestRam
	ret

;*
;* standard 32K cart with Super-Chip (F4+sc)
;*

SetBank_32 macro
local NoChange

	cmp	si,1FF4h		; if not in switch area ...
	jb	NoChange		; ... there's no change
	cmp	si,1FFbh
	ja	NoChange

	push	ax
	mov	ax,si
	sub	ax,1FF4h		; bank #
	shl	ax,12			; bank address
	mov	[RomBank],ax
	pop	ax

NoChange:
	endm

RBank32sc:
	test_hw_read
	SetBank_32
	SCR_TestRam
	MapRomBank
	ret

WBank32sc:
	test_hw_write
	SetBank_32
	SCW_TestRam
	ret

;*
;* Parker Brother's 8K cart
;*


PB_SetSlice macro
local NoChange

	cmp	si,1Fe0h		; if not in switch area ...
	jb	NoChange		; ... there's no change
	cmp	si,1FF8h
	ja	NoChange

	push	ax
	push	bx
	mov	ax,si
	and	ax,7
	shl	ax,10			; new bank
	mov	bx,si
	and	bx,18h
	shr	bx,2			; slice to set *2			
	mov	[PBSlice0 + bx],ax	
	pop	bx
	pop	ax

NoChange:
	endm

PB_MapSlice macro
	push	bx
	mov	bx,si
	and	bx,0fffh
	shr	bx,10			; slice # we're in
	shl	bx,1			; *2
	and	si,03ffh		; mask low order bits
	add	si,[PBSlice0 + bx]	; point to proper ROM slice
	add	si,offset _CartRom
	pop	bx

	endm


RBank8pb:
	test_hw_read
	PB_SetSlice
	PB_MapSlice
	ret


WBank8pb:
	test_hw_write
	PB_SetSlice
	ret

;*
;* Tigervision 8K cart
;*

TV_SetSlice macro
local NoChange

	cmp	si,03fh
	ja	NoChange

	push	ax
	mov	al,[WByte]
	and	ax,3
	shl	ax,11			; new bank
	mov	[TVSlice0],ax
	pop	ax

NoChange:
	endm

TV_MapSlice macro
	push	bx
	mov	bx,si
	and	bx,0fffh
	shr	bx,11			; slice # we're in
	shl	bx,1			; *2
	and	si,07ffh		; mask low order bits
	add	si,[TVSlice0 + bx]	; point to proper ROM slice
	add	si,offset _CartRom
	pop	bx
	endm


RBank8tv:
	test_hw_read
	TV_MapSlice
	ret

WBank8tv:
	TV_SetSlice
	test_hw_write
	ret


;*
;* Tigervision 32K cart
;*

TV_SetSlice32 macro
local NoChange

	cmp	si,03fh
	ja	NoChange

	push	ax
	mov	al,[WByte]
	and	ax,0fh
	shl	ax,11			; new bank
	mov	[TVSlice032],ax
	pop	ax

NoChange:
	endm

TV_MapSlice32 macro
	push	bx
	mov	bx,si
	and	bx,0fffh
	shr	bx,11			; slice # we're in
	shl	bx,1			; *2
	and	si,07ffh		; mask low order bits
	add	si,[TVSlice032 + bx]	; point to proper ROM slice
	add	si,offset _CartRom
	pop	bx
	endm


RBank32tv:
	test_hw_read
	TV_MapSlice32
	ret

WBank32tv:
	TV_SetSlice32
	test_hw_write
	ret


;*
;* FE 8K bankswitch scheme -- flat model
;*

FE_SetBank macro
	push	bx
	mov	bx,2000h
	and	bx,si			; isolate bank bit from address
	xor	bx,2000h		; invert it
	shr	bx,1			; position it
	mov	[RomBank],bx		; this is our bank
	pop	bx
	endm


RBank8FE:
	FE_SetBank
	test_hw_read
	MapRomBank
	ret


WBank8FE:
	FE_SetBank
	test_hw_write
	ret


;*
;* M-Network 16K cart
;*

; small chunks mapped at 0 to 3FF
;
; 0 --  00 -  FF
; 1 -- 100 - 1FF
; 2 -- 200 - 2FF
; 3 -- 300 - 3FF

; large chunk mapped at 400 to 7FF


MNR_TestRam macro
local Done, ReadBig

	cmp	si,19ffh
	ja	Done
	cmp	si,1400h
	jb	Done
	cmp	si,17ffh
	jbe	ReadBig
	cmp	si,1900h
	jb	Done
	add	si,[MNRamSlice]		; read small, pick up current slice
	add	si,offset _Ram - 1900h
	ret

ReadBig:
	cmp	[MNSlice0],0ffffh	; RAM mapped in ?
	jne	Done			;   no
	add	si,offset _Ram - 1400h + 400h
	ret

Done:
	endm

MNW_TestRam macro
local Done, WriteBig

	cmp	si,18ffh
	ja	Done
	cmp	si,1000h
	jb	Done
	cmp	si,13ffh
	jbe	WriteBig
	cmp	si,1800h
	jb	Done
	add	si,[MNRamSlice]		; write small, pick up current slice
	add	si,offset _Ram - 1800h
	WriteRam
	ret

WriteBig:
	cmp	[MNSlice0],0ffffh	; RAM mapped in ?
	jne	Done			;   no
	add	si,offset _Ram - 1000h + 400h
	WriteRam
	ret
	
Done:
	endm

MN_SetRamSlice macro
local Done, NotMapLower

	cmp	si,1FE7h
	jne	NotMapLower
	mov	[MNSlice0],0ffffh	; map RAM into lower slice
	jmp	Done

NotMapLower:
	cmp	si,1fe8h
	jb	Done
	cmp	si,1feBh
	ja	Done
	push	ax
	mov	ax,si
	sub	ax,1fe8h
	shl	ax,8
	mov	[MNRamSlice],ax
	pop	ax

Done:
	endm

MN_SetSlice macro
local NoChange

	cmp	si,1FE0h		; if not in switch area...
	jb	NoChange		; ... there's no change
	cmp	si,1FE6h
	ja	NoChange

	push	ax
	mov	ax,si
	sub	ax,1FE0h		; bank #
	shl	ax,11			; bank address
	mov	[MNSlice0],ax
	pop	ax

NoChange:
	endm

MN_MapSlice macro

	push	bx
	mov	bx,si
	and	bx,0fffh
	shr	bx,11			; slice # we're in
	shl	bx,1			; *2
	and	si,07ffh		; mask low order bits
	add	si,[MNSlice0 + bx]	; point to proper ROM slice
	add	si,offset _CartRom
	pop	bx

	endm


RBank16mn:
	test_hw_read
	MN_SetSlice
	MN_SetRamSlice
	MNR_TestRam
	MN_MapSlice
	ret

WBank16mn:
	test_hw_write
	MN_SetSlice
	MN_SetRamSlice
	MNW_TestRam
	ret
