; banks.asm -- z26 bank switch stuff

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 02-17-98  got Parker Bros Working and added TigerVision
; 08-03-02  32-bit

.data

RBankTab label dword
	dd	RBank4			;  0 -- 4K Atari
	dd	RBankCV			;  1 -- Commavid
	dd	RBank8sc		;  2 -- 8K superchip
	dd	RBank8pb		;  3 -- 8K Parker Bros.
	dd	RBank8tv		;  4 -- 8K Tigervision
	dd	RBank8FE		;  5 -- 8K Flat
	dd	RBank16sc		;  6 -- 16K superchip
	dd	RBank16mn		;  7 -- 16K M-Network
	dd	RBank32sc		;  8 -- 32K superchip
	dd	RBank8			;  9 -- 8K Atari - banks swapped
	dd	RBankCM			; 10 -- Compumate
	dd	RBank32tv		; 11 -- 512K Tigervision
        dd      RBank8ua                ; 12 -- 8K UA Ltd.
	dd	RBank8			; 13 -- 8K Atari
	dd	RBank8P2		; 14 -- Pitfall2
	dd	RBank_SP		; 15 -- Starpath
	dd	RBank16			; 16 -- 16K Atari
	dd	RBank32			; 17 -- 32K Atari
	dd	RBankMB			; 18 -- Megaboy
        dd      RBank12                 ; 19 -- 12K

WBankTab label dword
	dd	WBank4
	dd	WBankCV
	dd	WBank8sc
	dd	WBank8pb
	dd	WBank8tv
	dd	WBank8FE
	dd	WBank16sc
	dd	WBank16mn
	dd	WBank32sc
	dd	WBank8
	dd	WBankCM
	dd	WBank32tv
        dd      WBank8ua
	dd	WBank8
	dd	WBank8P2
	dd	WBank_SP
	dd	WBank16
	dd	WBank32
	dd	WBankMB
	dd	WBank12

RomBank		dd	0		; Rom bank pointer for F8 & F16

; Parker Brother's ROM Slices

PBSlice0	dd	0
PBSlice1	dd	1*400h
PBSlice2	dd	2*400h
PBSlice3	dd	7*400h		; this one doesn't change
					; points to 1K bank #7
; Tigervision ROM Slices

TVSlice0	dd	0
TVSlice1	dd	3*800h		; this one doesn't change
					; points to 2K bank #3
; Tigervision 32 ROM Slices

TVSlice032	dd	0
TVSlice132	dd	15*800h		; this one doesn't change
					; points to 2K bank #15
; M-Network ROM Slices

MNSlice0	dd	0
MNSlice1	dd	7*800h		; this one doesn't change
					; points to 2K bank #3
; M-Network RAM Slices

MNRamSlice	dd	0		; which 256 byte ram slice

; CompuMate RAM state

CMRamState	dd	10h		; RAM enabled - read/write state

.code

;*
;* set up bank switch scheme
;*

SetupBanks:
	mov	[RomBank],0
	mov	[PBSlice0],0
	mov	[PBSlice1],1*400h
	mov	[PBSlice2],2*400h
	mov	[PBSlice3],7*400h
	mov	[TVSlice0],0
	mov	[TVSlice1],3*800h
	mov	[TVSlice032],0
        mov     eax,[_CartSize]         ; make last 2K bank fixed for 3F games
        sub     eax,2048
        mov     [TVSlice132],eax
;        mov     [TVSlice132],15*800h
	mov	[MNSlice0],0
	mov	[MNSlice1],7*800h
	mov	[MNRamSlice],0
	mov	[Pitfall2],0
	mov	[Starpath],0

	mov	eax,[_BSType]		; bankswitching type specified
	test	eax,eax			;	  by user?
	je	DetectBySize		; no ... autodetect it *EST*
	cmp	eax,1			    
	je	SCV			; Commavid extra RAM
	cmp	eax,10
	je	SCM			; CompuMate computer module
	ret

DetectBySize:
	mov	eax,[_CartSize]
	cmp	eax,02000h
	je	Set8kMode		; 8K cart
	cmp	eax,03000h
	je	Set12KMode		; 12K cart
	cmp	eax,04000h
	je	Set16kMode		; 16K cart
	cmp	eax,08000h
	je	Set32kMode		; 32K cart
	cmp	eax,028ffh
	je	SetPitfallII		; Pitfall II cart
        cmp     eax,65536
	je	SMB			; Megaboy 64K cart *EST*
	cmp	eax,6144
        je      SetStarpath             ; Supercharger image
        mov     ebx,8448                ; file size is multiple of 8448 bytes?
        xor     edx,edx
        div     ebx
        cmp     edx,0
        je      SetStarpath             ; ... must be Supercharger game
	mov	eax,[_CartSize]
        cmp     eax,65536
        ja      Set32kTVMode            ; large Tigervision game
        ret


; Setup CompuMate

SCM:	mov     [RomBank],03000h
	call	InitCompuMate		; init Compumate keyboard
	ret				; see keyboard.asm


; Setup Commavid RAM module

SCV:	mov	ebx,2047		; copy ROM to RAM for MagiCard
SCV1:	mov	al,_CartRom[ebx]
	mov	_Ram[ebx],al
	dec	ebx
	jns	SCV1
	ret

Set8kMode:
	mov	[RomBank],01000h	; need this for moonswep and lancelot
	mov	[_BSType],13
	ret

Set12KMode:
        mov     [_BSType],19
	ret

Set16kMode:
	mov	[_BSType],16
	ret

Set32kMode:
	mov	[_BSType],17
	ret

SMB:	mov	[_BSType],18
	ret

Set32kTVMode:
        mov     [_BSType],11
        ret

;*
;* hardware read/write testing macros
;*

test_hw_read macro
	and	esi,01fffh
	cmp	esi,1000h		; if not ROM, read hardware
	jb	ReadHardware
	endm

test_hw_write macro
	and	esi,01fffh
	cmp	esi,1000h
	jb	WriteHardware
	endm

MapRomBank macro
	add	esi,[RomBank]
	add	esi,offset _CartRom - 1000h
	endm

WriteRam macro
	mov	al,[WByte]
	mov	[esi],al
	endm

;*
;* standard 4K cart
;*

RBank4: test_hw_read
	add	esi,offset _CartRom - 1000h
	ret
        

WBank4:	test_hw_write
	ret


;*
;* Commavid RAM cart (vidlife)
;*

CVR_TestRam macro
local NotRam

	cmp	esi,17ffh
	ja	NotRam
	add	esi,offset _Ram - 1000h
	ret

NotRam:
	endm

CVW_TestRam macro
local NotRam

	cmp	esi,17ffh
	ja	NotRam
	add	esi,offset _Ram - 1000h - 400h
	WriteRam
	ret

NotRam:
	endm


RBankCV: test_hw_read
	CVR_TestRam
	add	esi,offset _CartRom - 1000h
	ret
        

WBankCV:test_hw_write
	CVW_TestRam
	ret

;*
;* standard 8K cart (F8)
;*

SetBank_8 macro
local NoChange

	cmp	esi,1FF8h		; if not in switch area ...
	jb	NoChange		; ... there's no change
	cmp	esi,1FF9h
	ja	NoChange

	mov	eax,esi
	sub	eax,1FF8h		; bank #
	shl	eax,12			; bank address
	mov	[RomBank],eax

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

	cmp	esi,10ffh
	ja	NotRam
	add	esi,offset _Ram - 1000h - 80h
	ret

NotRam:
	endm

SCW_TestRam macro
local NotRam

	cmp	esi,10ffh
	ja	NotRam
	add	esi,offset _Ram - 1000h
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

	cmp	esi,1FF8h		; if not in switch area ...
	jb	NoChange		; ... there's no change
	cmp	esi,1FFAh
	ja	NoChange

	mov	eax,esi
	sub	eax,1FF8h		; bank #
	shl	eax,12			; bank address
	mov	[RomBank],eax

NoChange:
	endm

FAR_TestRam macro
local NotRam

	cmp	esi,11ffh
	ja	NotRam
	add	esi,offset _Ram - 1000h - 100h
	ret

NotRam:
	endm

FAW_TestRam macro
local NotRam

	cmp	esi,10ffh
	ja	NotRam
	add	esi,offset _Ram - 1000h
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

	cmp	esi,1FF6h		; if not in switch area...
	jb	NoChange		; ... there's no change
	cmp	esi,1FF9h
	ja	NoChange

	mov	eax,esi
	sub	eax,1FF6h		; bank #
	shl	eax,12			; bank address
	mov	[RomBank],eax

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
;* CompuMate computer module
;*

ChangeState_CM macro
local NoChange
local NoResetKeyCount
local NoIncreaseKeyCount

	cmp	esi,0280h
	jne	NoChange
	test	[WByte],20h
	jz	NoResetKeyCount
	mov	[CM_Collumn],0
NoResetKeyCount:
	test	[WByte],40h
	jz	NoIncreaseKeyCount
	inc	[CM_Collumn]
	cmp	[CM_Collumn],10
	jne	NoIncreaseKeyCount
	mov	[CM_Collumn],0
NoIncreaseKeyCount:
	mov	al,[WByte]
	mov	[CMRamState],eax
	and	eax,03h
	shl	eax,12
	mov	[RomBank],eax

NoChange:
	endm


TestRam_CM macro
local NoRAM
local NoWrite

	cmp	esi,1800h
	jb	NoRAM
	test	[CMRamState],10h	; RAM enabled?
	jnz	NoRAM
	add	esi,offset _Ram - 1000h - 800h
	test	[CMRamState],20h	; write enabled?
	jz	NoWrite
	WriteRam
NoWrite:
	ret
NoRAM:
	endm


RBankCM:
	test_hw_read
	TestRam_CM
	MapRomBank
	ret


WBankCM:
	ChangeState_CM
	test_hw_write
	TestRam_CM
	ret

;*
;* standard 32K cart (F4)
;*

SetBank_32 macro
local NoChange

	cmp	esi,1FF4h		; if not in switch area ...
	jb	NoChange		; ... there's no change
	cmp	esi,1FFbh
	ja	NoChange

	mov	eax,esi
	sub	eax,1FF4h		; bank #
	shl	eax,12			; bank address
	mov	[RomBank],eax

NoChange:
	endm

RBank32:
	test_hw_read
	SetBank_32
	MapRomBank
	ret

WBank32:
	test_hw_write
	SetBank_32
	ret

;*
;* standard 32K cart with Super-Chip (F4+sc)
;*

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

	cmp	esi,1Fe0h		; if not in switch area ...
	jb	NoChange		; ... there's no change
        cmp     esi,1FF7h
	ja	NoChange

	push	ebx
	mov	eax,esi
	and	eax,7
	shl	eax,10			; new bank
	mov	ebx,esi
	and	ebx,18h
	shr	ebx,1			; slice to set *4
	mov	[PBSlice0 + ebx],eax	
	pop	ebx

NoChange:
	endm

PB_MapSlice macro
	mov	eax,esi
	and	eax,0c00h
	shr	eax,8			; slice # we're in *4
	and	esi,03ffh		; mask low order bits
	add	esi,[PBSlice0 + eax]	; point to proper ROM slice
	add	esi,offset _CartRom

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
;* extended to 512K, but $1800-$1FFF still is the fixed bank
;*

TV_SetSlice macro
local NoChange

	cmp	esi,03fh
	ja	NoChange

	mov	al,[WByte]
;        and     eax,3
        and     eax,0ffh
	shl	eax,11			; new bank
	mov	[TVSlice0],eax

NoChange:
	endm

TV_MapSlice macro
	mov	eax,esi
	and	eax,0800h
	shr	eax,9			; slice # we're in *4
	and	esi,07ffh		; mask low order bits
	add	esi,[TVSlice0 + eax]	; point to proper ROM slice
	add	esi,offset _CartRom
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
;* extended to 512K - last 2K in ROM get used as fixed bank
;*

TV_SetSlice32 macro
local NoChange

	cmp	esi,03fh
	ja	NoChange

	mov	al,[WByte]
	and	eax,0ffh		; 0fh
	shl	eax,11			; new bank
	mov	[TVSlice032],eax

NoChange:
	endm

TV_MapSlice32 macro
	mov	eax,esi
	and	eax,0800h
	shr	eax,9			; slice # we're in *4
	and	esi,07ffh		; mask low order bits
	add	esi,[TVSlice032 + eax]	; point to proper ROM slice
	add	esi,offset _CartRom
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
local Trace

        cmp     debugflag,1             ; no BS if trace code reads the memory
        je      Trace
        cmp     esi,1000h
        jb      Trace
        mov     eax,2000h
        and     eax,esi                 ; isolate bank bit from address
        xor     eax,2000h               ; invert it
        shr     eax,1                   ; position it
        mov     [RomBank],eax           ; this is our bank
Trace:
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
; 0 --	00 -  FF
; 1 -- 100 - 1FF
; 2 -- 200 - 2FF
; 3 -- 300 - 3FF

; large chunk mapped at 400 to 7FF


MNR_TestRam macro
local Done, ReadBig

	cmp	esi,19ffh
	ja	Done
	cmp	esi,1400h
	jb	Done
	cmp	esi,17ffh
	jbe	ReadBig
	cmp	esi,1900h
	jb	Done
	add	esi,[MNRamSlice]	; read small, pick up current slice
	add	esi,offset _Ram - 1900h
	ret

ReadBig:
	cmp	[MNSlice0],0ffffh	; RAM mapped in ?
	jne	Done			;	no
	add	esi,offset _Ram - 1400h + 400h
	ret

Done:
	endm

MNW_TestRam macro
local Done, WriteBig

	cmp	esi,18ffh
	ja	Done
	cmp	esi,1000h
	jb	Done
	cmp	esi,13ffh
	jbe	WriteBig
	cmp	esi,1800h
	jb	Done
	add	esi,[MNRamSlice]	; write small, pick up current slice
	add	esi,offset _Ram - 1800h
	WriteRam
	ret

WriteBig:
	cmp	[MNSlice0],0ffffh	; RAM mapped in ?
	jne	Done			;	no
	add	esi,offset _Ram - 1000h + 400h
	WriteRam
	ret
	
Done:
	endm

MN_SetRamSlice macro
local Done, NotMapLower

	cmp	esi,1FE7h
	jne	NotMapLower
	mov	[MNSlice0],0ffffh	; map RAM into lower slice
	jmp	Done

NotMapLower:
	cmp	esi,1fe8h
	jb	Done
	cmp	esi,1feBh
	ja	Done
	mov	eax,esi
	sub	eax,1fe8h
	shl	eax,8
	mov	[MNRamSlice],eax

Done:
	endm

MN_SetSlice macro
local NoChange

	cmp	esi,1FE0h		; if not in switch area...
	jb	NoChange		; ... there's no change
	cmp	esi,1FE6h
	ja	NoChange

	mov	eax,esi
	sub	eax,1FE0h		; bank #
	shl	eax,11			; bank address
	mov	[MNSlice0],eax

NoChange:
	endm

MN_MapSlice macro

	mov	eax,esi
	and	eax,0800h
	shr	eax,9			; slice # we're in
	and	esi,07ffh		; mask low order bits
	add	esi,[MNSlice0 + eax]	; point to proper ROM slice
	add	esi,offset _CartRom

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
;*
;* Megaboy (F0) *EST*
;*

SetBank_MB macro
local NoChange

	cmp	esi,1FF0h		; if not in switch area ...
	jne	NoChange		; ... there's no change

	mov	eax,[RomBank]
	add	eax,01000h
        and     eax,0f000h
	mov	[RomBank],eax

NoChange:
	endm

RBankMB:
	test_hw_read
	SetBank_MB
	MapRomBank
	ret


WBankMB:
	test_hw_write
	SetBank_MB
	ret

;*
;* UA Ltd. 8K cart (24)
;*

SetBank_8ua macro
local DoChange
local NoChange

        cmp     esi,220h                ; bank 0 hotspot?
        je      DoChange                
        cmp     esi,240h                ; bank 1 hotspot?
        jne     NoChange

DoChange:
        push    eax
        mov     eax,esi
        and     eax,40h                 ; high or low bank
        shl     eax,6                   ; bank address
        mov     [RomBank],eax
        pop     eax

NoChange:
	endm

RBank8ua:
        SetBank_8ua
        test_hw_read
	MapRomBank
	ret


WBank8ua:
        SetBank_8ua
        test_hw_write
        ret

