;*
;* modex.asm -- z26 Mode-X support
;*

; mode setting code adapted from Michael Abrash's
; Graphics Programming Black Book, listing 47.1
; which itself is based on public-domain code by John Bridges

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

SC_INDEX =	03c4h		; sequence controller index
CRTC_INDEX =	03d4h		; CRT controller index
MISC_OUTPUT =	03c2h		; miscellaneous output register
SCREEN_SEG =	0a000h		; segment of display memory in mode X

.data
ModeXDisplayPointer	dw	0
ModeX79Shift            dw      50      ; offset each line's copy pointer
ModeX			db	0	; set if in modex
ModeXPage		db	0	; for telling if even or odd page (Frame not reliable)

MXDelayedClear		db	0	; 1 for frogpond, 2 for congbong
					; nobody else should notice
					; delayed clear (kludge -- see tia.asm)

Remap50Hz label byte		; remap 60Hz mode to 50Hz mode if PAL game
	db	10		; 0
	db	10		; 1
	db	11		; 2
	db	11		; 3
	db	10		; 4
	db	11		; 5
	db	12		; 6
	db	13		; 7
	db	14		; 8
	db	13		; 9
	db	10		; 10
	db	11		; 11
	db	12		; 12
	db	13		; 13
	db	14		; 14


MiscOutputTable label byte	; value of misc output register
	db	0		; 0  (mode 0-3 handled elsewhere)
	db	0		; 1
	db	0		; 2
	db	0		; 3
	db	0e3h		; 4
	db	0e7h		; 5
	db	0e7h		; 6
	db	0e7h		; 7
	db	0a7h		; 8
	db	0e7h		; 9
	db	0e3h		; 10
	db	0e7h		; 11
	db	0e7h		; 12
	db	0e7h		; 13
	db	0a7h		; 14

DoubleScanTable label byte	; if nonzero, mode doesn't do doublescan
	db	0		; 0
	db	0		; 1
	db	0		; 2
	db	0		; 3
	db	0		; 4
	db	0		; 5
	db	1		; 6
	db	1		; 7
	db	0		; 8
	db	1		; 9
	db	0		; 10
	db	0		; 11
	db	1		; 12
	db	1		; 13
	db	0		; 14

ScanLineTable label byte	; if nonzero, mode is a simulated scanline mode
	db	0		; 0
	db	0		; 1
	db	0		; 2
	db	0		; 3
	db	0		; 4
	db	0		; 5
	db	1		; 6
	db	0		; 7
	db	0		; 8
	db	0		; 9
	db	0		; 10
	db	0		; 11
	db	1		; 12
	db	0		; 13
	db	0		; 14

FlipTable label byte		; if nonzero, mode can do page flipping
	db	0		; 0
	db	0		; 1
	db	0		; 2
	db	0		; 3
	db	1		; 4
	db	1		; 5
	db	0		; 6
	db	0		; 7
	db	1		; 8
	db	0		; 9
	db	1		; 10
	db	1		; 11
	db	0		; 12
	db	0		; 13
	db	1		; 14

ALIGN 2

ParmTable label word
	dw	0		; 0
	dw	0		; 1
	dw	0		; 2
	dw	0		; 3
	dw	CRTParms	; 4
	dw	MX5Parms	; 5
	dw	MX5Parms	; 6
        dw      MX5Parms        ; 7
	dw	MX8Parms	; 8
	dw	MX9Parms	; 9
	dw	MX10Parms	; 10
	dw	MX11Parms	; 11
	dw	MX11Parms	; 12
	dw	MX11Parms	; 13
	dw	MX14Parms	; 14

CopyTable label word
        dw      DoLinearCopy    ; 0
        dw      DoLinearCopy    ; 1
        dw      DoLinearCopy    ; 2
        dw      DoLinearCopy    ; 3
        dw      DoRegularCopy   ; 4
        dw      DoRegularCopy   ; 5
        dw      MX6CopyScreen   ; 6
        dw      MX7CopyScreen   ; 7
        dw      DoRegularCopy   ; 8
        dw      MX7CopyScreen   ; 9
        dw      DoRegularCopy   ; 10
        dw      DoRegularCopy   ; 11
        dw      MX6CopyScreen   ; 12
        dw      MX7CopyScreen   ; 13
        dw      DoRegularCopy   ; 14

FastCopyTable label word
        dw      FDoLinearCopy    ; 0
        dw      FDoLinearCopy    ; 1
        dw      FDoLinearCopy    ; 2
        dw      FDoLinearCopy    ; 3
        dw      FDoRegularCopy   ; 4
        dw      FDoRegularCopy   ; 5
        dw      FMX6CopyScreen   ; 6
        dw      FMX7CopyScreen   ; 7
        dw      FDoRegularCopy   ; 8
        dw      FMX7CopyScreen   ; 9
        dw      FDoRegularCopy   ; 10
        dw      FDoRegularCopy   ; 11
        dw      FMX6CopyScreen   ; 12
        dw      FMX7CopyScreen   ; 13
        dw      FDoRegularCopy   ; 14

StartLineTable label word
	dw	32		; 0
	dw	32		; 1
	dw	32		; 2
	dw	30		; 3
	dw	20		; 4  (22)
	dw	20		; 5
	dw	20		; 6
	dw	1		; 7
	dw	20		; 8
	dw	1		; 9
	dw	38		; 10 (38)
	dw	38		; 11
	dw	38		; 12
	dw	1		; 13
	dw	38		; 14

MaxLineTable label word
	dw	200		; 0
	dw	200		; 1
	dw	200		; 2
	dw	204		; 3
	dw	240		; 4
	dw	240		; 5
	dw	240		; 6
        dw      400             ; 7
	dw	240		; 8
        dw      400             ; 9
	dw	256		; 10
	dw	256		; 11
	dw	256		; 12
        dw      400             ; 13
	dw	256		; 14


CopyCounterTable label word
        dw      200*40          ; 0
        dw      200*40          ; 1
        dw      200*40          ; 2
        dw      204*40          ; 3
        dw      240*20          ; 4
        dw      240*20          ; 5
        dw      240             ; 6
        dw      400             ; 7     hardcoded into copy routine
        dw      240*20          ; 8
        dw      400             ; 9     hardcoded into copy routine
        dw      256*20          ; 10
        dw      256*20          ; 11
        dw      256             ; 12
        dw      400             ; 13    hardcoded into copy routine
        dw      256*20          ; 14


; index data pairs for CRT controller registers that differ between mode 13 and mode X

CRTParms label word
	dw	00d06h	; vertical total
	dw	03e07h	; overflow (bit 8 of vertical counts)
	dw	04109h	; cell height (2 to double scan)
	dw	0ea10h	; v sync start
	dw	0ac11h	; (ac) v sync end and protect cr0-cr7
	dw	0df12h	; vertical displayed
	dw	0e715h	; vblank start
	dw	00616h	; vblank end
	dw	-1


MX5Parms label word
	dw	06c00h	; horizontal total
	dw	04f01h	; horizontal display enable end
	dw	05002h	; horizontal blanking start
	dw	08203h	; horizontal blanking end
	dw	05b04h	; horizontal retrace start
	dw	08705h	; horizontal retrace end

	dw	00d06h	; vertical total
	dw	03e07h	; overflow (bit 8 of vertical counts)
	dw	04109h	; cell height (2 to double scan)
	dw	0ea10h	; v sync start
	dw	0ac11h	; (ac) v sync end and protect cr0-cr7
	dw	0df12h	; vertical displayed
	dw	0e715h	; vblank start
	dw	00616h	; vblank end
	dw	-1


MX8Parms label word
	dw	06c00h	; horizontal total
	dw	04f01h	; horizontal display enable end
	dw	05002h	; horizontal blanking start
	dw	08203h	; horizontal blanking end
	dw	05b04h	; horizontal retrace start
	dw	08705h	; horizontal retrace end

	dw	00506h	; vertical total
	dw	01107h	; overflow (bit 8 of vertical counts)
	dw	04009h	; cell height (2 to double scan)
	dw	0f310h	; v sync start
	dw	0a511h	; (ac) v sync end and protect cr0-cr7
	dw	0ef12h	; vertical displayed
	dw	0f015h	; vblank start
	dw	00516h	; vblank end
	dw	-1


MX9Parms label word	; 360x480
	dw	06b00h	; horz total
	dw	05901h	; horz displ
	dw	05a02h	; start horz blnk
	dw	08e03h	; end horz blnk
	dw	05e04h	; start h sync
	dw	08a05h	; end h sync

	dw	00d06h	; vert tot
	dw	03e07h	; overflow
	dw	04009h	; cell ht
	dw	0ea10h	; vsync strt
	dw	0ac11h	; vsync end
	dw	0df12h	; vert displayed
	dw	02d13h	;* offset
	dw	00014h	;* turn off dword mode
	dw	0e715h	; vblank start
	dw	00616h	; vblank end
	dw	0e317h	;* turn on byte mode
	dw	-1


MX10Parms label word	; 320x240 50Hz
	dw	05f00h
	dw	04f01h
	dw	05002h
	dw	08203h
	dw	05404h
	dw	08005h

	dw	06f06h
	dw	0ba07h
	dw	00008h
	dw	04109h

	dw	02710h
	dw	00911h
	dw	0fe12h
	dw	02813h
	dw	00014h
	dw	0ff15h
	dw	01016h
	dw	0e317h
	dw	-1


MX11Parms label word	; 320x240 50Hz (squished)
	dw	06c00h	; horizontal total
	dw	04f01h	; horizontal display enable end
	dw	05002h	; horizontal blanking start
	dw	08203h	; horizontal blanking end
	dw	05b04h	; horizontal retrace start
	dw	08705h	; horizontal retrace end

	dw	06f06h
	dw	0ba07h
	dw	00008h
	dw	04109h

	dw	02710h
	dw	00911h
	dw	0fe12h
	dw	02813h
	dw	00014h
	dw	0ff15h
	dw	01016h
	dw	0e317h
	dw	-1

MX14Parms label word
	dw	06c00h	; horizontal total
	dw	04f01h	; horizontal display enable end
	dw	05002h	; horizontal blanking start
	dw	08203h	; horizontal blanking end
	dw	05b04h	; horizontal retrace start
	dw	08705h	; horizontal retrace end

	dw	03506h	; vertical total
	dw	01d07h	; overflow (bit 8 of vertical counts)
	dw	04009h	; cell height (2 to double scan)
	dw	01310h	; v sync start
	dw	0a511h	; (ac) v sync end and protect cr0-cr7
	dw	0ff12h	; vertical displayed
	dw	00015h	; vblank start
	dw	00516h	; vblank end
	dw	-1



.code

;*
;* initialize mode x
;*

ModeXInit:
	pusha
	push	es

        cmp	[_VideoMode],14		; doing a valid mode ?
	ja	MXPRet			;	 no, ret for now

	mov	[ModeX],1


        mov     ax,[_ScreenSeg]        ; make sure we render into screen buffer
        mov     gs,ax

; here comes the real stuff...

	cli

	mov	dx,SC_INDEX
	mov	ax,0604h
	out	dx,ax			; disable chain4 mode

	mov	dx,CRTC_INDEX
	mov	ax,0e317h
	out	dx,ax			; disable word mode

	mov	ax,000014h
	out	dx,ax			; disable doubleword mode

	mov	ax,0100h
	out	dx,ax			; synchronous reset while setting misc output

	movzx	si,[_VideoMode]
	mov	al,[MiscOutputTable + si]

	mov	dx,MISC_OUTPUT
	out	dx,al

	mov	dx,SC_INDEX
	mov	ax,0300h
	out	dx,al			; undo reset (restart sequencer)

	mov	dx,CRTC_INDEX		; reprogram the CRT controller
	mov	al,11h			; vsync end reg contains register ...
	out	dx,al			; ... write protect bit
	inc	dx			; CRT controller data register
	in	al,dx			; get current vsync end register setting
	and	al,07fh			; remove write protect on various ...
	out	dx,al			; ... CRTC registers
	dec	dx			; CRT controller index
	cld

	movzx	si,[_VideoMode]
	shl	si,1
	mov	si,[ParmTable + si]

SetCRTParmsLoop:
	lodsw				; get the next CRT index/data pair
	cmp	ax,-1
	je	SetCRTParmsDone
	out	dx,ax			; set the next CRT index/data pair
	jmp	SetCRTParmsLoop

SetCRTParmsDone:
	movzx	si,[_VideoMode]
	cmp	[DoubleScanTable + si],0 ; doing doublescan?
	jz	MXPRet			;   yes
	mov	dx,CRTC_INDEX		;   no, turn off doublescan mode
	mov	al,9			; cell height
	out	dx,al
	inc	dx
	in	al,dx
	and	al, not 1fh
	out	dx,al			; turn off doublescan mode

MXPRet:
	sti
	call	MXClearMem		; clear mem now...

	pop	es
	popa
	ret

;*
;* clear VGA memory
;*

MXClearMem:
	cmp	[ModeX],0		; in ModeX ?
	jz	MXRet			;   no, ignore call

	pushad
	push	es

	mov	dx,SC_INDEX
	mov	ax,0f02h
	out	dx,ax			; enable writes to all four planes

	mov	ax,SCREEN_SEG		; now clear memory ...
	mov	es,ax			; ... 4 pixels at a time
	sub	di,di			; point es:di to display memory
	sub	ax,ax			; clear to zero-value pixels
	mov	cx,0ffffh		; # of dwords to clear 
	rep	stosb

	pop	es
	popad

MXRet:	ret


;*
;* Flip ModeX page
;*


ModeXFlipPage:
	cmp	[ModeX],0		; in ModeX ?
	jz	MXRet			;	no, ignore call
	mov	[ModeXDisplayPointer],0	; assume even frame or no flipping

	push	si
	movzx	si,[_VideoMode]
	cmp	[FlipTable + si],0
	pop	si
	jz	NoFlipping

FlipThrottleLoop:
	call	_GetTime		; prevent false alarms if running in a fast refresh mode (mode 8)
	sub	eax,dword ptr [LastVsyncTime]	; (see vsync.asm for LastVsyncTime and PreGap)
	cmp	eax,dword ptr [PreFlip]		; at least 7/8 of a frame or so since last Vsync?	
	jb	FlipThrottleLoop	;	 no, keep waiting

DoFlipping:
	inc	[ModeXPage]
	mov	ah,080h
	test	[ModeXPage],1
	jz	DoFlip
	mov	ah,0
	mov	[ModeXDisplayPointer],08000h

DoFlip:
	mov	dx,CRTC_INDEX
	mov	al,00ch
	out	dx,al			; select upper byte of display page adr
	mov	al,ah
	inc	dx
	out	dx,al
	mov	dx,CRTC_INDEX
	mov	al,00dh
	out	dx,al			; select low byte of display page adr
	xor	al,al
	inc	dx
	out	dx,al			; lower byte of display page is always zero
	
NoFlipping:
	cmp	[_MaxLines],220		; doing partial screen
	ja	MXRet			;	no
	add	[ModeXDisplayPointer],800 ; yes, start 10 lines down
	cmp	[_VideoMode],9
	jne	MXRet
	add	[ModeXDisplayPointer],100
	ret


;*
;* copy line to modex display
;*

MXMove4 macro op1

	add	si,op1
        mov     al,es:[si]
        add	si,2
        mov     gs:[di],al
        inc	di
        mov     al,es:[si]
        add	si,2
        mov     gs:[di],al
        inc	di
        mov     al,es:[si]
        add	si,2
        mov     gs:[di],al
        inc	di
        mov     al,es:[si]
	add	si,2-op1
        mov     gs:[di],al
	inc	di

	endm

ModeXCopyScreen:
	pusha
	push	es
        push    gs                      ; *EST*

        mov     ax,0a000h
        mov     gs,ax

        mov     ax,[_ScreenSeg]
        mov     es,ax                   ; dest segment is ScreenBuffer

	movzx	si,[_VideoMode]
        cmp     si,3                    ; linear video mode ?
        ja      NoTurnedScreen          ;   yes, don't rotate screen
        test    [_TurnScreen],1         ; rotating enabled ?
        jne     DoLinearTurn            ;   yes, jump directly to copy routine
NoTurnedScreen:
	shl	si,1
        test    [_EnableFastCopy],1
        jnz     JumpToFast
	jmp	[CopyTable + si]
JumpToFast:
        jmp     [FastCopyTable + si]


;*
;* fast linear copy screen (160 pixels)
;*

FDoLinearCopy:
        mov     ax,[MaxLineTable + si]
        mov     si,[_ScreenOfs]
        mov     di,80

	push	ds
	push	es

	push	es
	pop	ds	; make ds source
	push	gs
	pop	es	; make es dest

FDLCLoop:
	mov	cx,40
	rep	movsd

	add	di,160
	dec	ax
	jnz	FDLCLoop

	pop	es
	pop	ds

        jmp     MXCRet
        
;*
;* linear copy screen
;*        

DoLinearCopy:
        mov     cx,[CopyCounterTable + si]
        mov     si,[_ScreenOfs]
        mov     di,-8

        push    ebx

        mov     ax,es
        push    ds
        mov     ds,ax

; optimized for original P5 (without MMX)
DLCLoop:                        ; u v   execution pipes
        mov     ax,[si]         ; 1     or more, depends on cache
        add     di,8            ;   1
        mov     dx,ax           ; 1
        mov     al,ah           ;   1
        shl     eax,16          ; 2     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        mov     dh,dl           ;   1
        mov     bx,[si+2]       ; 1     or more, depends on cache
        mov     ax,dx           ;   1
        mov     dx,bx           ; 1
        mov     bl,bh           ;   1
        mov     gs:[di],eax     ; 3     segment and instruction size prefix (pairs in u-pipe only, two extra decode cycles)
        mov     dh,dl           ;   1
        shl     ebx,16          ; 2     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        add     si,4            ;   1
        mov     bx,dx           ; 1
        dec     cx              ;   1
        mov     gs:[di+4],ebx   ; 3     segment and instruction size prefix (pairs in u-pipe only, two extra decode cycles)
        jnz     DLCLoop         ;   1
                                ;15     total cycles
        pop     ds
        pop     ebx

        jmp     MXCRet


;*
;* linear copy turned 90 degrees counter-clockwise
;*

DoLinearTurn:
        mov     si,[_ScreenOfs]
        mov     di,320*179+56

        mov     bx,51
DLTLine:
        mov     cx,160
DLTLoop:
        mov     al,es:[si+320]
        mov     ah,es:[si+480]
        shl     eax,16
        mov     al,es:[si]
        mov     ah,es:[si+160]
        mov     gs:[di],eax
        sub     di,320
        inc     si
        dec     cx
        jnz     DLTLoop
        add     di,320*160+4
        add     si,480
        dec     bx
        jnz     DLTLine

        jmp     MXCRet


;*
;* normal copy line
;*

DoRegularCopy:
        mov     cx,[CopyCounterTable + si]
        push    cx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0302h
	out	dx,ax			; enable planes 0,1 for even pixels

MXEvenLoop:
	MXMove4	0
	dec	cx
	jnz	MXEvenLoop

        pop     cx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]
	mov	ax,0c02h
	out	dx,ax			; enable planes 2,3 for odd pixels

MXOddLoop:
        MXMove4 1
	dec	cx
	jnz	MXOddLoop
	
MXCRet:
        pop     gs
        pop     es
	popa
	ret


;*
;* mode 6 and 12 screen copy
;*

MX6CopyScreen:
        mov     cx,[CopyCounterTable + si]
        push    cx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0302h
	out	dx,ax			; enable planes 0,1 for even pixels

MX6EvenLine:
        mov     bx,20
MX6EvenLoop:
	MXMove4	0
        dec     bx
        jnz     MX6EvenLoop
        add     di,80                   ; skip one scanline
        dec     cx
        jnz     MX6EvenLine

        pop     cx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]
	mov	ax,0c02h
	out	dx,ax			; enable planes 2,3 for odd pixels

MX6OddLine:
        mov     bx,20
MX6OddLoop:
        MXMove4 1
        dec     bx
        jnz     MX6OddLoop
        add     di,80                   ; skip one scanline
        dec     cx
        jnz     MX6OddLine
        jmp     MXCRet
	

;*
;* mode 7 and 9 line copy
;*

MX7Move4 macro op1
        mov     al,es:[si+op1]
        mov     ah,es:[si+op1+4]
        mov     gs:[di],al
        mov     gs:[di+1],ah
        mov     al,es:[si+op1+8]
        mov     ah,es:[si+op1+12]
        mov     gs:[di+2],al
        mov     gs:[di+3],ah
        add     si,16
	add	di,4

	endm

MX7CopyScreen:
        mov     [ModeX79Shift],50
        cmp	[_VideoMode],9
	je	MX7CopyContinue

        add     [ModeXDisplayPointer],20        ; move mode 7 toward middle
        mov     [ModeX79Shift],40

MX7CopyContinue:
        mov     bx,[_LinesInFrame]
        cmp     bx,400
        jbe     MX7skip
        mov     bx,400
MX7skip:
        push    bx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0102h
	out	dx,ax			; enable plane 0 for these pixels

MX7Loop0a:
        mov     cx,10
MX7Loop0:
	MX7Move4 0
	dec	cx
	jnz	MX7Loop0
        add     di,[ModeX79Shift]
        dec     bx
        jnz     MX7Loop0a

        pop     bx
        push    bx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0202h
	out	dx,ax			; enable plane 1 for these pixels

MX7Loop1a:
        mov     cx,10
MX7Loop1:
        MX7Move4 1
	dec	cx
        jnz     MX7Loop1
        add     di,[ModeX79Shift]
        dec     bx
        jnz     MX7Loop1a

        pop     bx
        push    bx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0402h
	out	dx,ax			; enable plane 2 for these pixels

MX7Loop2a:
        mov     cx,10
MX7Loop2:
        MX7Move4 2
	dec	cx
        jnz     MX7Loop2
        add     di,[ModeX79Shift]
        dec     bx
        jnz     MX7Loop2a

        pop     bx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0802h
	out	dx,ax			; enable plane 3 for these pixels

MX7Loop3a:
        mov     cx,10
MX7Loop3:
        MX7Move4 3
	dec	cx
        jnz     MX7Loop3
        add     di,[ModeX79Shift]
        dec     bx
        jnz     MX7Loop3a

	jmp	MXCRet



;*
;* Fast Mode X copy routines
;*

;*
;* copy line to modex display
;*

FMXMove4 macro op1

        mov     al,es:[si+op1+4]
        mov     ah,es:[si+op1+6]
        shl     eax,16
        mov     al,es:[si+op1]
        mov     ah,es:[si+op1+2]
        mov     gs:[di],eax
        add     si,8
        add     di,4

	endm

;*
;* normal copy line
;*

FDoRegularCopy:
        mov     cx,[CopyCounterTable + si]
        push    cx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0302h
	out	dx,ax			; enable planes 0,1 for even pixels

FMXEvenLoop:
        FMXMove4 0
	dec	cx
        jnz     FMXEvenLoop

        pop     cx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]
	mov	ax,0c02h
	out	dx,ax			; enable planes 2,3 for odd pixels

FMXOddLoop:
        FMXMove4 1
	dec	cx
        jnz     FMXOddLoop
	
FMXCRet:
        pop     gs
        pop     es
	popa
	ret


;*
;* mode 6 and 12 screen copy
;*

FMX6CopyScreen:
        mov     cx,[CopyCounterTable + si]
        push    cx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0302h
	out	dx,ax			; enable planes 0,1 for even pixels

FMX6EvenLine:
        mov     bx,20
FMX6EvenLoop:
        FMXMove4 0
        dec     bx
        jnz     FMX6EvenLoop
        add     di,80                   ; skip one scanline
        dec     cx
        jnz     FMX6EvenLine

        pop     cx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]
	mov	ax,0c02h
	out	dx,ax			; enable planes 2,3 for odd pixels

FMX6OddLine:
        mov     bx,20
FMX6OddLoop:
        FMXMove4 1
        dec     bx
        jnz     FMX6OddLoop
        add     di,80                   ; skip one scanline
        dec     cx
        jnz     FMX6OddLine
        jmp     FMXCRet
	

;*
;* mode 7 and 9 line copy
;*

FMX7Move4 macro op1
        mov     al,es:[si+op1+8]
        mov     ah,es:[si+op1+12]
        shl     eax,16
        mov     al,es:[si+op1]
        mov     ah,es:[si+op1+4]
        mov     gs:[di],eax
        add     si,16
	add	di,4

	endm

FMX7CopyScreen:
        mov     [ModeX79Shift],50
        cmp	[_VideoMode],9
        je      FMX7CopyContinue

        add     [ModeXDisplayPointer],20        ; move mode 7 toward middle
        mov     [ModeX79Shift],40

FMX7CopyContinue:
        mov     bx,[_LinesInFrame]
        cmp     bx,400
        jbe     FMX7skip
        mov     bx,400
FMX7skip:
        push    bx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0102h
	out	dx,ax			; enable plane 0 for these pixels

FMX7Loop0a:
        mov     cx,10
FMX7Loop0:
        FMX7Move4 0
	dec	cx
        jnz     FMX7Loop0
        add     di,[ModeX79Shift]
        dec     bx
        jnz     FMX7Loop0a

        pop     bx
        push    bx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0202h
	out	dx,ax			; enable plane 1 for these pixels

FMX7Loop1a:
        mov     cx,10
FMX7Loop1:
        FMX7Move4 1
	dec	cx
        jnz     FMX7Loop1
        add     di,[ModeX79Shift]
        dec     bx
        jnz     FMX7Loop1a

        pop     bx
        push    bx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0402h
	out	dx,ax			; enable plane 2 for these pixels

FMX7Loop2a:
        mov     cx,10
FMX7Loop2:
        FMX7Move4 2
	dec	cx
        jnz     FMX7Loop2
        add     di,[ModeX79Shift]
        dec     bx
        jnz     FMX7Loop2a

        pop     bx
        mov     si,[_ScreenOfs]
        mov     di,[ModeXDisplayPointer]

	mov	dx,SC_INDEX
	mov	ax,0802h
	out	dx,ax			; enable plane 3 for these pixels

FMX7Loop3a:
        mov     cx,10
FMX7Loop3:
        FMX7Move4 3
	dec	cx
        jnz     FMX7Loop3
        add     di,[ModeX79Shift]
        dec     bx
        jnz     FMX7Loop3a

        jmp     FMXCRet



