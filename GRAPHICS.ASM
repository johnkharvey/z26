	
; *****************************************************************************
;
;			    Switch Graphics Mode
;
; *****************************************************************************

TIAGraphicMode:
	mov	ah,1			; turn off the cursor
	mov	ch,020h
	int	010h
	mov	ah,0			; switch to 320x200 VGA	mode
	mov	al,013h
	int	010h
	call	TIAPalette
	ret

TIATextMode:
	mov	ah,0			; switch to 80x25 colour mode
	mov	al,3
	int	010h
	mov	ah,1			; turn cursor back on
	mov	cx,0B0Ch
	int	010h
	ret

; *****************************************************************************
;
;		       Set the VGA Palette up
;
; *****************************************************************************

TIAPalette:
        mov     bp,offset TIAVGATable
        mov     cl,0
TIAPalLoop:
        mov     al,255
        mov     dx,03c6h
        out     dx,al
        add     dx,2
        mov     al,cl
        out     dx,al
        inc     dx
        mov     al,0[bp]
        out     dx,al
        mov     al,1[bp]
        out     dx,al
        mov     al,2[bp]
        out     dx,al
        add     bp,3
        inc     cl
        cmp     cl,128
        jne     TIAPalLoop
        ret
	
