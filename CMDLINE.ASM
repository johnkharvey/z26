; *****************************************************************************
;
;			   Command Line	interpreter
;
;	-u <n>	upper scan line
;	-l <n>	lower scan line
;	-c <n>	Select sound channels
;	-q <n>	Set off	volume
;	-x	print out checksum of cartridge
;
; *****************************************************************************


CommandLine:

	push	es

IFNDEF comfile
	mov	ax,psp
	mov	es,ax			; set up pointer to PSP
ENDIF   

	mov	bp,081h			; bp points to the command line
CLSkip:	mov	al,es:[bp]		; skip over spaces
	cmp	al,' '
	jne	CLSkip2
	inc	bp
	jmp	CLSkip
CLSkip2:mov	al,es:[bp]		; see what it is
	cmp	al,13
	je	CCret
	cmp	al,'-'
	je	Control

	mov	bx,bp			; make it an ASCIIZ string
CLASCZ:	mov	al,es:[bx]
	inc	bx
	cmp	al,32
	jg	CLASCZ
	mov	es:byte	ptr -1[bx],0
        
	push	ds
	push	es
	pop	ds
	mov	dx,bp			; Open the file
	mov	al,0
	mov	ah,03Dh
	int	MSDOS
	jc	LoadFailx
	pop	ds
	push	ax			; save handle for close

	mov	bx,ax			; read the file
	mov	dx,offset CartRom
	mov	cx,16384		; try to read in 16k !!!
	mov	ah,03Fh
	int	MSDOS
	pop	bx			; Close	the file
	push	ax			; ax = bytes read.
	mov	ah,03Eh
	int	MSDOS
	jc	LoadFail

	pop	ax
	push	ax
	cmp	ax,02000h		; 8k cartridge ???
	je	Set8kMode
	cmp	ax,04000h
	je	Set16kMode

	cmp	ax,0800h		; read in a 2k file ???
	jne	CCret			;   no, we've finished.

	mov	bx,07FEh		; copy lower 2k	into upper 2k
CartCopy:
	mov	ax,word	ptr CartRom[bx]
	mov	word ptr CartRom+0800h[bx],ax
	sub	bx,2
	jge	CartCopy
CCret:	jmp	Conret
Set8kMode:
	mov	[ReadBank], offset RBank8
	mov	[WriteBank], offset WBank8
	jmp	Conret
Set16kMode:
	mov	[ReadBank], offset RBank16
	mov	[WriteBank], offset WBank16
	jmp	Conret
        
Conret:	pop	cx			; cart size
	pop	es
	xor	ax,ax			; before we go
	xor	bx,bx			; checksum the cartridge
	mov	si,offset CartRom
XLoop:	mov	bl,[si]
	inc	si
	add	ax,bx
	loop	XLoop
	mov	[Checksum],ax		; save the checksum for cart recognition

	cmp	[DoChecksum],0
	jz	SetupSpecial
	call	ConWord
	jmp	Quit

SetupSpecial:
	cmp	ax,0f69ah		; Enduro
	jne	SS1
	mov	[CFirst],30		; first display line
	jmp	SetupDone

SS1:	cmp	ax,08387h
	jne	SS2
	mov	[CFirst],69		; GI Joe Cobra Strike (actionmn)
	jmp	SetupDone
SS2:
SetupDone:
	ret

LoadFailx:
	pop	ds
LoadFail:
	pop	es
	mov	al,7
	jmp	ConOut

Control:mov	cl,es:1[bp]		; get control letter
	cmp	cl,'A'
	jl	CNext
	cmp	cl,'Z'
	jg	CNext
	add	cl,32
CNext:	add	bp,2
	mov	al,0
GetInt:	mov	ah,es:[bp]
	inc	bp
	cmp	ah,'0'
	jl	EndInt
	cmp	ah,'9'
	jg	EndInt
	mov	bl,al			; al = al * 10
	shl	al,2
	add	al,bl
	add	al,al
	add	al,ah
	sub	al,'0'
	jmp	GetInt

EndInt:					; Command in CL,Value in AL
	cmp	cl,'u'
	je	CMUpper
	cmp	cl,'l'
	je	CMLower
	cmp	cl,'c'
	je	CMChannel
	cmp	cl,'q'
	je	CMMinVol
	cmp	cl,'0'
	je	CMD0
	cmp	cl,'1'
	je	CMD1
	cmp	cl,'b'
	je	CMBW
	cmp	cl,'x'
	je	CMXsum
Back:	jmp	CLSkip			; back to the beginning

CMUpper:xor	ah,ah			; set upper scan line
	mov	[CFirst],ax
	jmp	CLSkip
CMLower:xor	ah,ah			; set lower scan line
	mov	[CLast],ax
	jmp	CLSkip

CMChannel:				; set the audio	sound channel (PC spkr)
	mov	[SDMPX],al
	jmp	CLSkip

CMMinVol:				; set the minimum volume (PC spkr)
	mov	[MinVol],al
	jmp	CLSkip

CMD0:	mov	al,[IOPortB]		; p0 hard
	or	al,64
	mov	[IOPortB],al
	jmp	CLSkip

CMD1:	mov	al,[IOPortB]		; p1 hard
	or	al,128
	mov	[IOPortB],al
	jmp	CLSkip

CMBW:	mov	al,[IOPortB]		; black	and white
	and	al,0C3h
	mov	[IOPortB],al
	jmp	CLSkip

CMXsum:	mov	[DoChecksum],1		; do checksum
	jmp	CLSkip

