; *****************************************************************************
;
;			   Command Line	interpreter
;
;	-u <n>	upper scan line
;	-l <n>	lower scan line
;	-c	show credits
;	-q	quiet
;       -v <n>  select video mode
;       -s      display sound diagnostic messages
;	-x	print out checksum of cartridge
;	-r	don't wait for retrace (full speed), -r1 use old vsync code
;	-f <n>  do <n> frames and exit
;       -d      do digital signal processing
;	-j	do joystick
;
; *****************************************************************************

;_CommandLine:
;	mov	ax,_psp
;	mov	psp,ax
CommandLine:
	pusha
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
	je	CLDoNoFile		;   no file detected
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
	mov	dx,offset _CartRom
	mov	cx,16384		; try to read in 16k !!!
	mov	ah,03Fh
	int	MSDOS
	mov	[CartSize],ax
	pop	bx			; Close	the file
	mov	ah,03Eh
	int	MSDOS
	jc	LoadFail

	cmp	[CartSize],0800h	; read in a 2k file ???
	jne	DoXsum			;   no, we've finished.

	mov	bx,07FEh		; copy lower 2k	into upper 2k
	mov	si,offset _CartRom
CartCopy:
	mov	ax,word	ptr [bx+si]
	mov	word ptr 0800h[bx+si],ax
	sub	bx,2
	jge	CartCopy

       
DoXsum:	mov	cx,[CartSize]

	xor	ax,ax			; before we go
	xor	bx,bx			; checksum the cartridge
	
	mov	si,offset _CartRom
XLoop:	mov	bl,[si]
	inc	si
	add	ax,bx
	loop	XLoop
	mov	[_Checksum],ax		; save the checksum for cart recognition

	pop	es

	call	SetupSpecial
	call	SetupBanks

	popa
	
	cmp	[_DoChecksum],0
	jz	STUP_3
	call	_ShowChecksum
	jmp	ReallyQuit

STUP_3:
	ret


LoadFailx:
	pop	ds

	call	FileNotFound
	jmp	ReallyQuit

LoadFail:
	pop	es
	jmp	CLDoNoFile


Control:mov	cl,es:1[bp]		; get control letter
	cmp	cl,'A'
	jl	CNext
	cmp	cl,'Z'
	jg	CNext
	add	cl,32
CNext:	add	bp,2
	mov	al,0

	xor	eax,eax
	xor	ebx,ebx
GetInt:
	mov	bl,es:[bp]
	inc	bp
	cmp	bl,'0'
	jl	EndInt
	cmp	bl,'9'
	jg	EndInt
	sub	bl,'0'
	imul	eax,10
	add	eax,ebx
	jmp	GetInt


EndInt:					; Command in CL,Value in AL
	cmp	cl,'u'
	je	CMUpper
	cmp	cl,'l'
	je	CMLower
	cmp	cl,'c'
	je	CMCredits
	cmp	cl,'q'
	je	CMQuiet
	cmp	cl,'s'
	je	CMVerbose
	cmp	cl,'v'
	je	CMVideoMode
	cmp	cl,'0'
	je	CMD0
	cmp	cl,'1'
	je	CMD1
	cmp	cl,'b'
	je	CMBW
	cmp	cl,'x'
	je	CMXsum
	cmp	cl,'r'
	je	CMNoRetrace
	cmp	cl,'t'
	je	CMTimer1
	cmp	cl,'f'
	je	CMFrameExit
	cmp	cl,'d'
	je	CMDsp
	cmp	cl,'j'
	je	CMJoy

	call	BadSwitch		; put out a message
	jmp	ReallyQuit		; and quit

Back:	jmp	CLSkip			; back to the beginning

CMUpper:xor	ah,ah			; set upper scan line
	mov	[CFirst],ax
	jmp	CLSkip
CMLower:xor	ah,ah			; set lower scan line
	mov	[CLast],ax
	jmp	CLSkip

CMCredits:				; show credits
;	pop	es
;	popa

	call	_ShowCredits
	jmp	ReallyQuit

CMQuiet:				; quiet!
	mov	[_quiet],1
	jmp	CLSkip

CMVerbose:
	mov	[_verbose],1		; verbose
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

CMXsum:	mov	[_DoChecksum],1		; do checksum

	jmp	CLSkip

CMNoRetrace:
	cmp	eax,0
	jz	CMNR1
	mov	[NoRetrace],al		; don't wait for retrace (full speed)
	jmp	CLSkip

CMNR1:	mov	[NoRetrace],0ffh
	jmp	CLSkip

CMTimer1:
	mov	[TimerVec],offset Timer1 ; force Timer1
	jmp	CLSkip

CMFrameExit:				; do <n> frames and exit
	mov	[FrameExit],eax
	jmp	CLSkip

CMDsp:
	mov	[_dsp],ax
	jmp	CLSkip

CMVideoMode:
	mov	[_VideoMode],al
	jmp	CLSkip

CMJoy:	mov	[_Joystick],al		; do joystick
	jmp	CLSkip

; we didn't see a filename string
; output a copyright message

CLDoNoFile:
;	pop	es
;	popa

	call	_ShowCopyright
	jmp	ReallyQuit
