;*
;* Read bank switcher (SI contains the address accessed)
;*

ALIGN_ENTRY

RBank4: and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware

	add	si,[_RomPtr]		; offset CartRom - 1000h
					; set in z.c
	ret
        

ALIGN_ENTRY

RBank8: and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware
	cmp	si,1FF8h		; if not in switch area...
	jb	RBank8NoChange		; theres no change
	cmp	si,1FFAh
	ja	RBank8NoChange
	mov	[RomBank],0		; selected bank 0
	cmp	si,1FF8h
	je	RBank8NoChange
	mov	[RomBank],1000h		; selected bank 1
RBank8NoChange:
	add	si,[RomBank]

	add	si,[_RomPtr]		; offset CartRom - 1000h
					; set in z.c
	ret


ALIGN_ENTRY

RBank16: and	si,01fffh
	cmp	si,1000h		; if not ROM, read hardware
	jb	ReadHardware
	cmp	si,1FF6h		; if not in switch area...
	jb	RBank16NoChange		; theres no change
	cmp	si,1FFAh
	ja	RBank16NoChange

	push	ax			; 16k ROM switch
	mov	ax,si
	sub	ax,1FF6h		; its 0,1,2,3
	shl	ax,12			; its 0,4k,8k,12k
	mov	[RomBank],ax
	pop	ax

RBank16NoChange:
	add	si,[RomBank]

	add	si,[_RomPtr]		; offset CartRom - 1000h
					; set in z.c
	ret


ALIGN_ENTRY

WBank4: and	si,01fffh
	cmp	si,1000h
	jb	WriteHardware
	ret
        

ALIGN_ENTRY

WBank8: and	si,01fffh
	cmp	si,1000h		; if not ROM,no effect
	jb	WriteHardware
	cmp	si,1FF8h		; if not in switch area...
	jb	Bank8NoChange		; theres no change
	cmp	si,1FFAh
	ja	Bank8NoChange
	mov	[RomBank],0		; selected bank 0
	cmp	si,1FF8h
	je	Bank8NoChange
	mov	[RomBank],1000h		; selected bank 1
Bank8NoChange:
	add	si,[RomBank]
WBRet:	ret
					        

ALIGN_ENTRY

WBank16:and	si,01fffh
	cmp	si,1000h		; if not ROM,no effect
	jb	WriteHardware
	cmp	si,1FF6h		; if not in switch area...
	jb	Bank16NoChange		; theres no change
	cmp	si,1FFAh
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
