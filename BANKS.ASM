; banks.asm -- z26 bank switch stuff


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
	cmp	ax,0e446h
	je	SPB			; dethstar
	cmp	ax,0f9f8h
	je	SPB			; gyruss
	cmp	ax,09a6dh
	je	SPB			; sprcobra

	mov	[ReadBank], offset RBank8
	mov	[WriteBank], offset WBank8
	ret


; set up Parker Brother's bank switch scheme

SPB:	mov	[ReadBank], offset RBank8pb
	mov	[WriteBank], offset WBank8pb
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
	cmp	ax,0677dh
	je	SSC8			; stargate
	cmp	ax,04dbdh
	je	SSC8			; defendr2
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
;* standard 4K cart
;*

ALIGN_ENTRY

RBank4: and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware
	add	si,offset _CartRom - 1000h
	ret
        

ALIGN_ENTRY

WBank4: and	si,01fffh
	cmp	si,1000h
	jb	WriteHardware
	ret


;*
;* standard 8K cart (F8)
;*

ALIGN_ENTRY

RBank8:	and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware
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


ALIGN_ENTRY

WBank8:	and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	WriteHardware
	cmp	si,1FF8h		; if not in switch area...
	je	F8_WBank0
	cmp	si,1FF9h
	je	F8_WBank1
	add	si,[RomBank]
	ret

F8_WBank0:
	mov	[RomBank],0
	add	si,[RomBank]
	ret

F8_WBank1:
	mov	[RomBank],1000h
	add	si,[RomBank]
	ret

FA_WBank2:
	mov	[RomBank],2000h
	add	si,[RomBank]
	ret


;*
;* standard 8K cart with Super-Chip (F8+sc)
;*

ALIGN_ENTRY

RBank8sc:
	and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware
	cmp	si,1FF8h		; if not in switch area...
	je	F8_RBank0
	cmp	si,1FF9h
	je	F8_RBank1
	jmp	RBank16scTestRam


ALIGN_ENTRY

WBank8sc:
	and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	WriteHardware
	cmp	si,1FF8h		; if not in switch area...
	je	F8_WBank0
	cmp	si,1FF9h
	je	F8_WBank1
	jmp	WBank16scTestRam


;*
;* 12K Ram Plus cart (FA)
;*

ALIGN_ENTRY

RBank12:
	and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware
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


ALIGN_ENTRY

WBank12:
	and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	WriteHardware
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

ALIGN_ENTRY

RBank16: and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware
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


ALIGN_ENTRY

WBank16:and	si,01fffh
	cmp	si,1000h		; if not ROM,no effect
	jb	WriteHardware
	cmp	si,1FF6h		; if not in switch area...
	jb	Bank16NoChange		; theres no change
	cmp	si,1FF9h
	ja	Bank16NoChange

	push	ax			; 16k ROM switch
	mov	ax,si
	sub	ax,1FF6h		; its 0,1,2,3
	shl	ax,12			; its 0,4k,8k,12k
	mov	[RomBank],ax
	pop	ax

Bank16NoChange:
	add	si,[RomBank]
	ret


;*
;* standard 16K cart with Super-Chip (F16+sc)
;*

ALIGN_ENTRY

RBank16sc:
	and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware
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


ALIGN_ENTRY

WBank16sc:
	and	si,01fffh
	cmp	si,1000h		; if not ROM,no effect
	jb	WriteHardware
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
	add	si,[RomBank]
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

ALIGN_ENTRY

RBank8pb:
	and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware
	cmp	si,1Fe0h		; if not in switch area...
	jb	RBank8pbNoChange	; theres no change
	cmp	si,1FF8h
	ja	RBank8pbNoChange

	push	eax
	movzx	eax,si
	sub	ax,1Fe0h		; slice setting routine to call
	call	[PBSliceSet + eax*2]
	pop	eax

RBank8pbNoChange:
	push	eax
	movzx	eax,si
	shr	eax,10			; slice # we're in
	add	si,[PBSlice0 + eax*2]	; point to proper ROM slice

	add	si,offset _CartRom - 1000h
	pop	eax
	ret


ALIGN_ENTRY

WBank8pb:
	and	si,01fffh
	cmp	si,1000h		; if not ROM,no effect
	jb	WriteHardware
	cmp	si,1Fe0h		; if not in switch area...
	jb	WBank8pbNoChange	; theres no change
	cmp	si,1FF8h
	ja	WBank8pbNoChange

	push	eax
	movzx	eax,si
	sub	ax,1Fe0h		; slice setting routine to call
	call	[PBSliceSet + eax*2]
	pop	eax

WBank8pbNoChange:
	push	eax
	movzx	eax,si
	shr	eax,10			; slice # we're in
	add	si,[PBSlice0 + eax*2]	; point to proper ROM slice

	pop	eax
	ret


; Parker Brother's slice setting routines

PB0_0:	mov	[PBSlice0],0
	ret

PB0_1:	mov	[PBSlice0],0400h
	ret

PB0_2:	mov	[PBSlice0],0800h
	ret

PB0_3:	mov	[PBSlice0],0c00h
	ret

PB0_4:	mov	[PBSlice0],1000h
	ret

PB0_5:	mov	[PBSlice0],1400h
	ret

PB0_6:	mov	[PBSlice0],1800h
	ret

PB0_7:	mov	[PBSlice0],1c00h
	ret

PB1_0:	mov	[PBSlice1],0
	ret

PB1_1:	mov	[PBSlice1],0400h
	ret

PB1_2:	mov	[PBSlice1],0800h
	ret

PB1_3:	mov	[PBSlice1],0c00h
	ret

PB1_4:	mov	[PBSlice1],1000h
	ret

PB1_5:	mov	[PBSlice1],1400h
	ret

PB1_6:	mov	[PBSlice1],1800h
	ret

PB1_7:	mov	[PBSlice1],1c00h
	ret

PB2_0:	mov	[PBSlice2],0
	ret

PB2_1:	mov	[PBSlice2],0400h
	ret

PB2_2:	mov	[PBSlice2],0800h
	ret

PB2_3:	mov	[PBSlice2],0c00h
	ret

PB2_4:	mov	[PBSlice2],1000h
	ret

PB2_5:	mov	[PBSlice2],1400h
	ret

PB2_6:	mov	[PBSlice2],1800h
	ret

PB2_7:	mov	[PBSlice2],1c00h
	ret


.CEND
.DATASEGMENT


;Parker Brother's slice setting branch table


PBSliceSet	dw	PB0_0
		dw	PB0_1
		dw	PB0_2
		dw	PB0_3
		dw	PB0_4
		dw	PB0_5
		dw	PB0_6
		dw	PB0_7

		dw	PB1_0
		dw	PB1_1
		dw	PB1_2
		dw	PB1_3
		dw	PB1_4
		dw	PB1_5
		dw	PB1_6
		dw	PB1_7

		dw	PB2_0
		dw	PB2_1
		dw	PB2_2
		dw	PB2_3
		dw	PB2_4
		dw	PB2_5
		dw	PB2_6
		dw	PB2_7

; Memory read/write vectors

CartSize	dw	0		; gets cart size (cmdline.asm)

ReadBank	dw	RBank4		; default to 4K cart
WriteBank	dw	WBank4
        
RomBank		dw	0		; Rom bank pointer for F8 & F16


; Parker Brother's ROM Slices

PBSlice0	dw	0
PBSlice1	dw	0
PBSlice2	dw	0
PBSlice3	dw	1c00h		; this one doesn't change
					; points to 1K bank #7

.DEND
.CODESEGMENT
