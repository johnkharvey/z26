; banks.asm -- z26 bank switch stuff

; 02-17-98  got Parker Bros Working and added TigerVision

.CEND
.DATASEGMENT

CartSize	dw	0		; gets cart size (cmdline.asm)

ReadBank	dw	RBank4		; R/W vectors -- default to 4K cart
WriteBank	dw	WBank4
        
RomBank		dw	0		; Rom bank pointer for F8 & F16

.DEND
.CODESEGMENT


;*
;* set up bank switch scheme
;*

SetupBanks:
	mov	ax,[CartSize]
	cmp	ax,02000h
	je	Set8kMode		; 8K cart
	cmp	ax,03000h
	je	Set12KMode		; 12K cart
	cmp	ax,04000h
	je	Set16kMode		; 16K cart
	ret

Set8kMode:
	mov	ax,[_Checksum]
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


	mov	[ReadBank], offset RBank8
	mov	[WriteBank], offset WBank8
	ret


; set up Parker Brother's 8K bank switch scheme

SPB:	mov	[ReadBank], offset RBank8pb
	mov	[WriteBank], offset WBank8pb
	ret

; set up Tigervision 8K bank switch scheme

STV:	mov	[ReadBank], offset RBank8tv
	mov	[WriteBank], offset WBank8tv
	ret

; set up FE (JSR/RTS) bank switch scheme

SFE:	mov	[ReadBank], offset RBank8FE
	mov	[WriteBank], offset WBank8FE
	ret

Set12KMode:
	mov	[ReadBank], offset RBank12
	mov	[WriteBank], offset WBank12
	ret

Set16kMode:
	mov	ax,[_Checksum]
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
	cmp	ax,0c525h
	je	SSC			; sprfootb
	cmp	ax,08037h
	je	SSC			; sprnmast
	cmp	ax,07c00h
	je	SSC			; ofthewal
	cmp	ax,06db1h
	je	SSC			; secretq
	cmp	ax,09ffah
	je	SSC			; radarlok
	cmp	ax,04f39h
	je	SSC			; klax
	cmp	ax,04887h
	je	SSC			; klaxntsc

	mov	[ReadBank], offset RBank16
	mov	[WriteBank], offset WBank16
	ret


; setup 16K super-chip vectors

SSC:	mov	[ReadBank], offset RBank16sc
	mov	[WriteBank], offset WBank16sc
	ret

; setup 8K super-chip vectors (defendr2, stargate)

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

;*
;* standard 4K cart
;*

RBank4: test_hw_read
	add	si,offset _CartRom - 1000h
	ret
        

WBank4:	test_hw_write
	ret


;*
;* standard 8K cart (F8)
;*

RBank8:	test_hw_read
	cmp	si,1FF8h		; if not in switch area...
	je	F8_RBank0
	cmp	si,1FF9h
	je	F8_RBank1
	add	si,[RomBank]
	add	si,offset _CartRom - 1000h
	ret

F8_RBank0:
	mov	[RomBank],0
	add	si,[RomBank]
	add	si,offset _CartRom - 1000h
	ret

F8_RBank1:
	mov	[RomBank],1000h
	add	si,[RomBank]
	add	si,offset _CartRom - 1000h
	ret

FA_RBank2:
	mov	[RomBank],2000h
	add	si,[RomBank]
	add	si,offset _CartRom - 1000h
	ret


WBank8:	test_hw_write
	cmp	si,1FF8h		; if not in switch area...
	je	F8_WBank0
	cmp	si,1FF9h
	je	F8_WBank1
	ret

F8_WBank0:
	mov	[RomBank],0
	ret

F8_WBank1:
	mov	[RomBank],1000h
	ret

FA_WBank2:
	mov	[RomBank],2000h
	ret


;*
;* standard 8K cart with Super-Chip (F8+sc)
;*

RBank8sc:
	test_hw_read
	cmp	si,1FF8h		; if not in switch area...
	je	F8_RBank0
	cmp	si,1FF9h
	je	F8_RBank1
	jmp	RBank16scTestRam


WBank8sc:
	test_hw_write
	cmp	si,1FF8h		; if not in switch area...
	je	F8_WBank0
	cmp	si,1FF9h
	je	F8_WBank1
	jmp	WBank16scTestRam


;*
;* 12K Ram Plus cart (FA)
;*

RBank12:
	test_hw_read
	cmp	si,1FF8h		; if not in switch area...
	je	F8_RBank0
	cmp	si,1FF9h
	je	F8_RBank1
	cmp	si,1FFAh
	je	FA_RBank2

	cmp	si,11ffh
	ja	RBank16scNoChange
	add	si,offset _Ram - 1000h - 100h
	ret


WBank12:
	test_hw_write
	cmp	si,1FF8h		; if not in switch area...
	je	F8_WBank0
	cmp	si,1FF9h
	je	F8_WBank1
	cmp	si,1FFAh
	je	FA_WBank2

	cmp	si,11ffh
	ja	WBank16scNoChange
	add	si,offset _Ram - 1000h
	push	ax
	mov	al,[WByte]
	mov	[si],al
	pop	ax
	ret


;*
;* standard 16K cart (F16)
;*

RBank16:
	test_hw_read
	cmp	si,1FF6h		; if not in switch area...
	jb	RBank16NoChange		; theres no change
	cmp	si,1FF9h
	ja	RBank16NoChange

	push	ax			; 16k ROM switch
	mov	ax,si
	sub	ax,1FF6h		; its 0,1,2,3
	shl	ax,12			; its 0,4k,8k,12k
	mov	[RomBank],ax
	pop	ax

RBank16NoChange:
	add	si,[RomBank]
	add	si,offset _CartRom - 1000h
	ret


WBank16:
	test_hw_write
	cmp	si,1FF6h		; if not in switch area...
	jb	WBank16NoChange		; theres no change
	cmp	si,1FF9h
	ja	WBank16NoChange

	push	ax			; 16k ROM switch
	mov	ax,si
	sub	ax,1FF6h		; its 0,1,2,3
	shl	ax,12			; its 0,4k,8k,12k
	mov	[RomBank],ax
	pop	ax

WBank16NoChange:
	ret


;*
;* standard 16K cart with Super-Chip (F16+sc)
;*

RBank16sc:
	test_hw_read
	cmp	si,1FF6h		; if not in switch area...
	jb	RBank16scTestRam	; theres no change
	cmp	si,1FF9h
	ja	RBank16scNoChange

	push	ax			; 16k ROM switch
	mov	ax,si
	sub	ax,1FF6h		; its 0,1,2,3
	shl	ax,12			; its 0,4k,8k,12k
	mov	[RomBank],ax
	pop	ax

RBank16scNoChange:
	add	si,[RomBank]
	add	si,offset _CartRom - 1000h
	ret

RBank16scTestRam:
	cmp	si,10ffh
	ja	RBank16scNoChange
	add	si,offset _Ram - 1000h - 80h
	ret


WBank16sc:
	test_hw_write
	cmp	si,1FF6h		; if not in switch area...
	jb	WBank16scTestRam	; theres no change
	cmp	si,1FF9h
	ja	WBank16scNoChange

	push	ax			; 16k ROM switch
	mov	ax,si
	sub	ax,1FF6h		; its 0,1,2,3
	shl	ax,12			; its 0,4k,8k,12k
	mov	[RomBank],ax
	pop	ax

WBank16scNoChange:
	ret

WBank16scTestRam:
	cmp	si,10ffh
	ja	WBank16scNoChange
	add	si,offset _Ram - 1000h
	push	ax
	mov	al,[WByte]
	mov	[si],al
	pop	ax
	ret

;*
;* Parker Brother's 8K cart
;*

.CEND
.DATASEGMENT

; Parker Brother's ROM Slices

PBSlice0	dw	0
PBSlice1	dw	1*400h
PBSlice2	dw	2*400h
PBSlice3	dw	7*400h		; this one doesn't change
					; points to 1K bank #7

.DEND
.CODESEGMENT


PB_SetSlice macro
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

	endm

PB_MapSlice macro
	push	bx
	mov	bx,si
	and	bx,0fffh
	shr	bx,10			; slice # we're in
	shl	bx,1			; *2
	and	si,03ffh		; mask low order bits
	add	si,[PBSlice0 + bx]	; point to proper ROM slice
	pop	bx

	endm


RBank8pb:
	test_hw_read
	cmp	si,1Fe0h		; if not in switch area...
	jb	RBank8pbNoChange	; theres no change
	cmp	si,1FF8h
	ja	RBank8pbNoChange

	PB_SetSlice

RBank8pbNoChange:
	PB_MapSlice

	add	si,offset _CartRom
	ret


WBank8pb:
	test_hw_write
	cmp	si,1Fe0h		; if not in switch area...
	jb	WBank8pbNoChange	; theres no change
	cmp	si,1FF8h
	ja	WBank8pbNoChange

	PB_SetSlice

WBank8pbNoChange:
	ret

;*
;* Tigervision 8K cart
;*

.CEND
.DATASEGMENT

; Tigervision ROM Slices

TVSlice0	dw	0
TVSlice1	dw	3*800h		; this one doesn't change
					; points to 2K bank #3
.DEND
.CODESEGMENT


TV_SetSlice macro
	push	ax
	mov	al,[WByte]
	and	ax,3
	shl	ax,11			; new bank
	mov	[TVSlice0],ax
	pop	ax
	endm

TV_MapSlice macro
	push	bx
	mov	bx,si
	and	bx,0fffh
	shr	bx,11			; slice # we're in
	shl	bx,1			; *2
	and	si,07ffh		; mask low order bits
	add	si,[TVSlice0 + bx]	; point to proper ROM slice
	pop	bx
	endm


RBank8tv:
	test_hw_read
	TV_MapSlice
	add	si,offset _CartRom
	ret

WBank8tv:
	cmp	si,03fh			; in range?
	ja	NoTiger			;   no
	TV_SetSlice			; defined in banks.asm

NoTiger:
	test_hw_write
	ret


;*
;* FE 8K bankswitch scheme (JSR/RTS) (* doesn't work *)
;*

RBank8FE:
	cmp	si,0feh
	jne	RBank8FENoChange
	mov	[RomBank],0h

RBank8FENoChange:
	test_hw_read
	add	si,[RomBank]
	add	si,offset _CartRom - 1000h
	ret


WBank8FE:
	cmp	si,0feh
	jne	WBank8FENoChange
	mov	[RomBank],1000h

WBank8FENoChange:
	test_hw_write
	ret

