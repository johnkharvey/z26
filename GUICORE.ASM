;*
;* z26 GUI support code
;*
;* palette setting and line drawing code based on Asteroids 3.02 by Chris Pile
;*
;* text output based on code from The Graphics Programming Black Book by Michael Abrash
;*

.model large
.386

.data

GUIReturn	dd	?			; 32-bit return address

LineX1		dw	?
LineY1		dw	?
LineX2		dw	?
LineY2		dw	?
LineColor	dw	?


StringCol	dw	?			; column to display at
StringRow	dw	?			; row to display at
StringColor	dw	?			; color to display in
StringChar	dw	?			; character to output

public _GUIFont
_GUIFont	dw	0			; select font


.code

FontPointer	dd	?			; font offset
FontHeight	dw	8			; # of scanlines in a char


SimplexFont label byte				; z26 GUI font

	include simplex5.asm

TinyFont label byte

	include tiny5.asm

;*
;* void gui_Line(int X1, int Y1, int X2, int Y2, int color);
;*

public _gui_Line
_gui_Line proc far

	pop	[GUIReturn]
	pop	[LineX1]
	pop	[LineY1]
	pop	[LineX2]
	pop	[LineY2]
	pop	[LineColor]
	push	[LineColor]
	push	[LineY2]
	push	[LineX2]
	push	[LineY1]
	push	[LineX1]
	push	[GUIReturn]

	pusha

	call	set_packed_pixel_mode

	mov	bx,[LineX1]
	mov	si,[LineY1]
	mov	cx,[LineX2]
	mov	di,[LineY2]
	mov	ax,[LineColor]
	call	line

	popa

	ret

_gui_Line endp


;*
;* void far gui_Font(int Font);
;*

public _gui_Font
_gui_Font	proc	far

	pop	[GUIReturn]
	pop	[_GUIFont]
	push	[_GUIFont]
	push	[GUIReturn]

	cmp	[_GUIFont],0
	jz	FontZero

	mov	cs:[FontHeight],5
	ret

FontZero:
	mov	cs:[FontHeight],8
	ret

_gui_Font endp


;*
;* void far gui_Char( int Col, int Row, int Color, char ch);
;*

public _gui_Char
_gui_Char	proc	far

	pop	[GUIReturn]			; I do it this way because I don't know how to count.
	pop	[StringCol]			; I also don't care very much about how fast it is.
	pop	[StringRow]
	pop	[StringColor]
	pop	[StringChar]
	push	[StringChar]
	push	[StringColor]
	push	[StringRow]
	push	[StringCol]
	push	[GUIReturn]

	cmp	[_GUIFont],0
	jne	SetTinyFont

	mov	word ptr cs:[FontPointer],offset SimplexFont
	mov	word ptr cs:[FontPointer+2],cs
	jmp	DoChar

SetTinyFont:
	mov	word ptr cs:[FontPointer],offset TinyFont
	mov	word ptr cs:[FontPointer+2],cs

DoChar:
	pusha
	push	ds
	push	es

	mov	al,byte ptr [StringChar]
	mov	ah,byte ptr [StringColor]
	mov	bx,[StringRow]
	mov	cx,[StringCol]

	call  	DrawChar

	pop	es
	pop	ds
	popa

	ret

_gui_Char	endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;General equates used by the drawing functions
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

crtc_addr	equ	3D4h   ;base port of the CRT controller (colour)
sequ_addr	equ	3C4h   ;base port of the CRT sequencer
colour_number	equ	3C8h	 ;VGA pallette number
packed_pix	equ	3CEh   ;base port to manipulate packed pixel mode

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Routine:  set_packed_pixel_mode
;Job:	   sets up packed pixel mode (for line)
;Args:	   None
;Returns:  None
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

set_packed_pixel_mode:	
	mov	dx,sequ_addr		;VGA sequencer base
	mov	ax,0F02h		;Index 2, set write all planes
	out	dx,ax
	mov	dx,packed_pix		;Packed pixel base port
	mov	ax,205h			;Index 5, write bits 0-3 = colour
	out	dx,ax
	mov	ax,3h			;Index 3, set write unmodified
	out	dx,ax
	mov	ax,0FF08h		;Index 8, bitmask set to 11111111b
	out	dx,ax

	mov	ax,0305h		;Mode register set to use write
					;data ANDed with bitmask register
	out	dx,ax
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Routine:  LINE	  (640x480x16).
;Job:	   Draws a line from X1,Y1 to X2,Y2 in chosen colour
;Args:	   bx=X1, si=Y1, cx=X2, di=Y2, al=colour (0-15)
;	   DS preserved
;Returns:  Nothing, all registers, including BP, are destroyed
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

vertical:	
	mov	dx,di			;Y2
	sub	dx,si			;Y2 - Y1 = length
	jnc	down_screen		;Already going down
	neg	bp			;Neg ADD
	neg	dx			;Make length positive
down_screen:	
	inc	dx			;At least one pixel

	add	si,si			;Double for table access
	mov	si,cs:[y_table+si]	;Get Y address

	and	cl,7			;Initial pixel pos
	shr	bx,3			;x1/8
	add	si,bx			;si = (y1*80) + (x1/8)
	mov	ah,128			;Left pixel
	ror	ah,cl			;Roll to correct vertical pixel
blit_vertical:	
	mov	al,ah			;Restore pixel
	xchg	al,[si]			;Plot it
	add	si,bp			;Screen add
	dec	dx			;DEC pixel loop
	jnz	blit_vertical		;Plot remainder
	pop	ds			;Restore
	ret				;Done

line:	push	ds			;Save data segment
	mov	dx,packed_pix		;Packed pixel base port
	mov	ah,al			;Set colour to AH
	xor	al,al			;Index 0, plane fill data set
	out	dx,ax			;Set colour in AH
	mov	ax,0A000h		;Video seg
	mov	ds,ax			;Make DS=Video seg
	mov	bp,80			;Down screen add

	cmp	bx,cx			;x1>x2?
	jz	vertical		;Same, so a vertical line or dot
	jb	left_to_right		;Already left to right

	xchg	bx,cx			;Make x1=x2, x2=x1
	xchg	di,si			;Make y1=y2, y2=y1

left_to_right:	
	sub	cx,bx			;cx = deltax
	sub	di,si			;di = deltay
	jz	horizontal		;Same, so a horizontal line
	jns	no_neg_deltay		;Deltay already positive
	neg	di			;Make deltay positive
	neg	bp			;Going up screen

no_neg_deltay:	
	add	si,si			;Double for table access
	mov	si,cs:[y_table+si]	;Get Y address

	mov	ah,bl			;Low x1
	and	ah,7			;Initial pixel pos
	shr	bx,3			;x1/8
	add	si,bx			;si = (y1*80) + (x1/8)

	cmp	di,cx			;Deltay > deltax?
	jb	horiz_vert		;No, so mix of horizont/vertical

	mov	bx,cx			;Deltax
	add	bx,bx			;DELT2 = (Deltax * 2)
	mov	dx,cx			;Deltax
	sub	dx,di			;Deltax - Deltay
	add	dx,dx			;ERROR = 2 * (Deltax - Deltay)
	mov	al,128			;Far left pixel
	mov	cl,ah			;Initial pixel pos
	ror	al,cl			;Roll to calc start pixel
	mov	cx,di			;Line length
	inc	cx			;Make sure at least one pixel
	neg	di			;Neg Deltay
	sub	dx,bx			;Adjust ERROR

plot_vert_horiz:
	mov	ah,al			;Save pixel
	xchg	ah,[si]			;Plot pixel, needs read/write!!
	add	si,bp			;Add vertical step
	add	di,bx			;Is D variable < 0?
	jns	horiz_step		;No, so a horizontal step needed
	dec	cx			;DEC pixel count
	jnz	plot_vert_horiz		;Loop for next pixel
	pop	ds			;Restore DS
	ret				;Finished
horiz_step:	
	add	di,dx			;D = D + ERROR
	ror	al,1			;Shift pixel right
	adc	si,0			;Step along X on carry
	dec	cx			;DEC pixel count
	jnz	plot_vert_horiz		;Loop for next pixel
	pop	ds			;Restore DS
	ret				;Finished

horizontal:
	inc	cx			;X2 + 1 (at least one pixel)
	mov	dx,cx	

	add	si,si			;Double for table access
	mov	si,cs:[y_table+si]	;Get Y address

	mov	cl,bl
	shr	bx,3			;x1/8
	add	si,bx			;si = (y1*80) + (x1/8)
	and	cl,7			;Initial pixel pos
	mov	ax,8000h		;Left pixel and OR mask
	shr	ah,cl			;Shift initial pix pos
do_left_pix:	
	or	al,ah			;OR in mask
	shr	ah,1			;Next pix
	jc	done_left		;Ready to step
	dec	dx			;DEC length
	jnz	do_left_pix		;More bits
	xchg	al,[si]			;Plot this mask
	pop	ds			;Restore
	ret				;Done
done_left:	
	dec	dx			;Adjust for last mask shift
	xchg	al,[si]			;Plot left edge
	not	ah			;Right edge mask = 255
	inc	si			;Next screen address
	mov	cl,dl			;Low pixels left
	shr	dx,3			;CX / 8
	jz	do_right_edge		;No middle x8 bits, do right edge
blit_middle:	
	mov	al,ah			;Set mask to 255
	xchg	al,[si]			;Plot whole group of 8
	inc	si			;Next address
	dec	dx			;DEC length
	jnz	blit_middle		;More middle bytes
do_right_edge:	
	and	cl,7			;Any right edge?
	jz	no_right_edge		;No, so all done
	xor	al,al			;Initial mask
	ror	ax,cl			;Shift in write bits
	xchg	al,[si]			;Plot right edge group
no_right_edge:
	pop	ds			;Restore
	ret				;Done

horiz_vert:	
	mov	bx,di			;Deltay
	add	bx,bx			;DELT2 = (2 * Deltay)
	mov	dx,di			;Deltay
	sub	dx,cx			;Deltay - Deltax
	add	dx,dx			;ERROR = 2 * (Deltay - Deltax)
	xor 	di,di			;DELT2
	sub	di,cx			;D = DELT2 - Deltax

	inc	cx			;At least one pixel
	mov	al,cl			;Save CL

	mov	cl,ah			;Initial pixel POS
	mov	ah,128			;Far left pixel
	ror	ah,cl			;Roll to calc start pixel
	mov	cl,al			;Restore CL
	xor	al,al			;Zero start mask
	sub	dx,bx			;Adjust ERROR

plot_horiz_vert:
	or	al,ah			;Or in current pixel
	add	di,bx			;D = D + DELT2
	jns	vert_step		;D >= 0?
	ror	ah,1			;Add horizontal step
	jc	next_x_address		;On carry, store pixel and step
	dec	cx			;DEC pixel count
	jnz	plot_horiz_vert		;Loop for next pixel
	xchg	al,[si]			;Store any pixels left
	pop	ds			;Restore DS
	ret				;Finished
next_x_address:	
	xchg	al,[si]			;Plot pixel, needs read/write!!
	inc	si			;Next X address
	xor	al,al			;Zero new pixels
	dec	cx			;DEC pixel count
	jnz	plot_horiz_vert		;Loop for next pixel
	pop	ds			;Restore DS
	ret				;Finished
vert_step:
	xchg	al,[si]			;Plot any pixels pending
	xor	al,al			;Zero new pixels
	add	di,dx			;D = D + ERROR
	ror	ah,1			;Do the xstep
	adc	si,bp			;Screen address Y step + X step
	dec	cx			;DEC pixel count
	jnz	plot_horiz_vert		;Loop for next pixel
	pop	ds			;Restore DS
	ret				;Finished

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Allows faster calculations of the Y screen coordinate than mult/shifting
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
y_table	dw	 0 
	dw	 80 
	dw	 160 
	dw	 240 
	dw	 320 
	dw	 400 
	dw	 480 
	dw	 560 
	dw	 640 
	dw	 720 
	dw	 800 
	dw	 880 
	dw	 960 
	dw	 1040 
	dw	 1120 
	dw	 1200 
	dw	 1280 
	dw	 1360 
	dw	 1440 
	dw	 1520 
	dw	 1600 
	dw	 1680 
	dw	 1760 
	dw	 1840 
	dw	 1920 
	dw	 2000 
	dw	 2080 
	dw	 2160 
	dw	 2240 
	dw	 2320 
	dw	 2400 
	dw	 2480 
	dw	 2560 
	dw	 2640 
	dw	 2720 
	dw	 2800 
	dw	 2880 
	dw	 2960 
	dw	 3040 
	dw	 3120 
	dw	 3200 
	dw	 3280 
	dw	 3360 
	dw	 3440 
	dw	 3520 
	dw	 3600 
	dw	 3680 
	dw	 3760 
	dw	 3840 
	dw	 3920 
	dw	 4000 
	dw	 4080 
	dw	 4160 
	dw	 4240 
	dw	 4320 
	dw	 4400 
	dw	 4480 
	dw	 4560 
	dw	 4640 
	dw	 4720 
	dw	 4800 
	dw	 4880 
	dw	 4960 
	dw	 5040 
	dw	 5120 
	dw	 5200 
	dw	 5280 
	dw	 5360 
	dw	 5440 
	dw	 5520 
	dw	 5600 
	dw	 5680 
	dw	 5760 
	dw	 5840 
	dw	 5920 
	dw	 6000 
	dw	 6080 
	dw	 6160 
	dw	 6240 
	dw	 6320 
	dw	 6400 
	dw	 6480 
	dw	 6560 
	dw	 6640 
	dw	 6720 
	dw	 6800 
	dw	 6880 
	dw	 6960 
	dw	 7040 
	dw	 7120 
	dw	 7200 
	dw	 7280 
	dw	 7360 
	dw	 7440 
	dw	 7520 
	dw	 7600 
	dw	 7680 
	dw	 7760 
	dw	 7840 
	dw	 7920 
	dw	 8000 
	dw	 8080 
	dw	 8160 
	dw	 8240 
	dw	 8320 
	dw	 8400 
	dw	 8480 
	dw	 8560 
	dw	 8640 
	dw	 8720 
	dw	 8800 
	dw	 8880 
	dw	 8960 
	dw	 9040 
	dw	 9120 
	dw	 9200 
	dw	 9280 
	dw	 9360 
	dw	 9440 
	dw	 9520 
	dw	 9600 
	dw	 9680 
	dw	 9760 
	dw	 9840 
	dw	 9920 
	dw	 10000 
	dw	 10080 
	dw	 10160 
	dw	 10240 
	dw	 10320 
	dw	 10400 
	dw	 10480 
	dw	 10560 
	dw	 10640 
	dw	 10720 
	dw	 10800 
	dw	 10880 
	dw	 10960 
	dw	 11040 
	dw	 11120 
	dw	 11200 
	dw	 11280 
	dw	 11360 
	dw	 11440 
	dw	 11520 
	dw	 11600 
	dw	 11680 
	dw	 11760 
	dw	 11840 
	dw	 11920 
	dw	 12000 
	dw	 12080 
	dw	 12160 
	dw	 12240 
	dw	 12320 
	dw	 12400 
	dw	 12480 
	dw	 12560 
	dw	 12640 
	dw	 12720 
	dw	 12800 
	dw	 12880 
	dw	 12960 
	dw	 13040 
	dw	 13120 
	dw	 13200 
	dw	 13280 
	dw	 13360 
	dw	 13440 
	dw	 13520 
	dw	 13600 
	dw	 13680 
	dw	 13760 
	dw	 13840 
	dw	 13920 
	dw	 14000 
	dw	 14080 
	dw	 14160 
	dw	 14240 
	dw	 14320 
	dw	 14400 
	dw	 14480 
	dw	 14560 
	dw	 14640 
	dw	 14720 
	dw	 14800 
	dw	 14880 
	dw	 14960 
	dw	 15040 
	dw	 15120 
	dw	 15200 
	dw	 15280 
	dw	 15360 
	dw	 15440 
	dw	 15520 
	dw	 15600 
	dw	 15680 
	dw	 15760 
	dw	 15840 
	dw	 15920 
	dw	 16000 
	dw	 16080 
	dw	 16160 
	dw	 16240 
	dw	 16320 
	dw	 16400 
	dw	 16480 
	dw	 16560 
	dw	 16640 
	dw	 16720 
	dw	 16800 
	dw	 16880 
	dw	 16960 
	dw	 17040 
	dw	 17120 
	dw	 17200 
	dw	 17280 
	dw	 17360 
	dw	 17440 
	dw	 17520 
	dw	 17600 
	dw	 17680 
	dw	 17760 
	dw	 17840 
	dw	 17920 
	dw	 18000 
	dw	 18080 
	dw	 18160 
	dw	 18240 
	dw	 18320 
	dw	 18400 
	dw	 18480 
	dw	 18560 
	dw	 18640 
	dw	 18720 
	dw	 18800 
	dw	 18880 
	dw	 18960 
	dw	 19040 
	dw	 19120 
	dw	 19200 
	dw	 19280 
	dw	 19360 
	dw	 19440 
	dw	 19520 
	dw	 19600 
	dw	 19680 
	dw	 19760 
	dw	 19840 
	dw	 19920 
	dw	 20000 
	dw	 20080 
	dw	 20160 
	dw	 20240 
	dw	 20320 
	dw	 20400 
	dw	 20480 
	dw	 20560 
	dw	 20640 
	dw	 20720 
	dw	 20800 
	dw	 20880 
	dw	 20960 
	dw	 21040 
	dw	 21120 
	dw	 21200 
	dw	 21280 
	dw	 21360 
	dw	 21440 
	dw	 21520 
	dw	 21600 
	dw	 21680 
	dw	 21760 
	dw	 21840 
	dw	 21920 
	dw	 22000 
	dw	 22080 
	dw	 22160 
	dw	 22240 
	dw	 22320 
	dw	 22400 
	dw	 22480 
	dw	 22560 
	dw	 22640 
	dw	 22720 
	dw	 22800 
	dw	 22880 
	dw	 22960 
	dw	 23040 
	dw	 23120 
	dw	 23200 
	dw	 23280 
	dw	 23360 
	dw	 23440 
	dw	 23520 
	dw	 23600 
	dw	 23680 
	dw	 23760 
	dw	 23840 
	dw	 23920 
	dw	 24000 
	dw	 24080 
	dw	 24160 
	dw	 24240 
	dw	 24320 
	dw	 24400 
	dw	 24480 
	dw	 24560 
	dw	 24640 
	dw	 24720 
	dw	 24800 
	dw	 24880 
	dw	 24960 
	dw	 25040 
	dw	 25120 
	dw	 25200 
	dw	 25280 
	dw	 25360 
	dw	 25440 
	dw	 25520 
	dw	 25600 
	dw	 25680 
	dw	 25760 
	dw	 25840 
	dw	 25920 
	dw	 26000 
	dw	 26080 
	dw	 26160 
	dw	 26240 
	dw	 26320 
	dw	 26400 
	dw	 26480 
	dw	 26560 
	dw	 26640 
	dw	 26720 
	dw	 26800 
	dw	 26880 
	dw	 26960 
	dw	 27040 
	dw	 27120 
	dw	 27200 
	dw	 27280 
	dw	 27360 
	dw	 27440 
	dw	 27520 
	dw	 27600 
	dw	 27680 
	dw	 27760 
	dw	 27840 
	dw	 27920 
	dw	 28000 
	dw	 28080 
	dw	 28160 
	dw	 28240 
	dw	 28320 
	dw	 28400 
	dw	 28480 
	dw	 28560 
	dw	 28640 
	dw	 28720 
	dw	 28800 
	dw	 28880 
	dw	 28960 
	dw	 29040 
	dw	 29120 
	dw	 29200 
	dw	 29280 
	dw	 29360 
	dw	 29440 
	dw	 29520 
	dw	 29600 
	dw	 29680 
	dw	 29760 
	dw	 29840 
	dw	 29920 
	dw	 30000 
	dw	 30080 
	dw	 30160 
	dw	 30240 
	dw	 30320 
	dw	 30400 
	dw	 30480 
	dw	 30560 
	dw	 30640 
	dw	 30720 
	dw	 30800 
	dw	 30880 
	dw	 30960 
	dw	 31040 
	dw	 31120 
	dw	 31200 
	dw	 31280 
	dw	 31360 
	dw	 31440 
	dw	 31520 
	dw	 31600 
	dw	 31680 
	dw	 31760 
	dw	 31840 
	dw	 31920 
	dw	 32000 
	dw	 32080 
	dw	 32160 
	dw	 32240 
	dw	 32320 
	dw	 32400 
	dw	 32480 
	dw	 32560 
	dw	 32640 
	dw	 32720 
	dw	 32800 
	dw	 32880 
	dw	 32960 
	dw	 33040 
	dw	 33120 
	dw	 33200 
	dw	 33280 
	dw	 33360 
	dw	 33440 
	dw	 33520 
	dw	 33600 
	dw	 33680 
	dw	 33760 
	dw	 33840 
	dw	 33920 
	dw	 34000 
	dw	 34080 
	dw	 34160 
	dw	 34240 
	dw	 34320 
	dw	 34400 
	dw	 34480 
	dw	 34560 
	dw	 34640 
	dw	 34720 
	dw	 34800 
	dw	 34880 
	dw	 34960 
	dw	 35040 
	dw	 35120 
	dw	 35200 
	dw	 35280 
	dw	 35360 
	dw	 35440 
	dw	 35520 
	dw	 35600 
	dw	 35680 
	dw	 35760 
	dw	 35840 
	dw	 35920 
	dw	 36000 
	dw	 36080 
	dw	 36160 
	dw	 36240 
	dw	 36320 
	dw	 36400 
	dw	 36480 
	dw	 36560 
	dw	 36640 
	dw	 36720 
	dw	 36800 
	dw	 36880 
	dw	 36960 
	dw	 37040 
	dw	 37120 
	dw	 37200 
	dw	 37280 
	dw	 37360 
	dw	 37440 
	dw	 37520 
	dw	 37600 
	dw	 37680 
	dw	 37760 
	dw	 37840 
	dw	 37920 
	dw	 38000 
	dw	 38080 
	dw	 38160 
	dw	 38240 
	dw	 38320 

;*
;* text output for z26 GUI
;*
;* based on listing 26-1 and listing 26-2 in the Graphics Programming Black Book by Michael Abrash
;*

VGA_VIDEO_SEGMENT		equ	0a000h		;VGA display memory segment
FONT_CHARACTER_SIZE		equ	8
SCREEN_WIDTH			equ	80		; screen width in bytes

; VGA register equates.

SC_INDEX			equ	3c4h		;SC index register
SC_MAP_MASK			equ	2		;SC map mask register index
GC_INDEX			equ	3ceh		;GC index register
GC_SET_RESET			equ	0		;GC set/reset register index
GC_ENABLE_SET_RESET	 	equ	1	 	;GC enable set/reset register index
GC_ROTATE			equ	3		;GC data rotate/logical function register index
GC_MODE				equ	5		;GC Mode register
GC_BIT_MASK			equ	8		;GC bit mask register index


; Subroutine to draw a text character in mode 012h (640x480x16)
; Background around the pixels that make up the character is preserved.
; Font used should be pointed to by FontPointer.
;
; Input:
;  AL = character to draw
;  AH = color to draw character in (0-15)
;  BX = row to draw text character at
;  CX = column to draw text character at
;
;  Forces ALU function to "move".
;  Forces write mode 3.

DrawChar	proc	near

	push	 ax		;preserve character to draw in AL

; Set up set/reset to produce character color, using the readability
; of VGA register to preserve the setting of reserved bits 7-4.

	mov	 dx,GC_INDEX
	mov	 al,GC_SET_RESET
	out	dx,al
	inc	dx
	in	al,dx
	and	al,0f0h
	and	ah,0fh
	or	al,ah
	out	dx,al

; Select write mode 3, using the readability of VGA registers
; to leave bits other than the write mode bits unchanged.

	mov	dx,GC_INDEX
	mov	al,GC_MODE
	out	dx,al
	inc	dx
	in	al,dx
	or	al,3
	out	dx,al

; Set DS:SI to point to font and ES to point to display memory.

	lds	si,cs:[FontPointer]	;point to font
	mov	dx,VGA_VIDEO_SEGMENT
	mov	es,dx			;point to display memory

; Calculate screen address of byte character starts in.

	pop	ax			;get back character to draw in AL


	xchg	ax,bx

	mov	di,SCREEN_WIDTH		;screen width in bytes
	mul	di			;calculate offset of start of row

	mov	di,cx			;set aside the column
	and	cl,0111b		;keep only the column in-byte address
	shr	di,3			;divide column by 8 to make a byte address
	add	di,ax			;and point to byte

; Calculate font address of character.

	xor	bh,bh
	shl	bx,3			;offset in font of character (assume 8 bytes per char)
	add	si,bx			;offset in font segment of character

; Set up the GC rotation. In write mode 3, this is the rotation
; of CPU data before it is ANDed with the Bit Mask register to
; form the bit mask. Force the ALU function to "move". Uses the
; readability of VGA registers to leave reserved bits unchanged.

	mov	dx,GC_INDEX
	mov	al,GC_ROTATE
	out	dx,al
	inc	dx
	in	al,dx
	and	al,0e0h
	or	al,cl
	out	dx,al

; Set up BH as bit mask for left half, BL as rotation for right half.

	mov	bx,0ffffh
	shr	bh,cl
	neg	cl
	add	cl,8
	shl	bl,cl

; Draw the character, left half first, then right half in the
; succeeding byte, using the data rotation to position the character
; across the byte boundary and then using write mode 3 to combine the
; character data with the bit mask to allow the set/reset value (the
; character color) through only for the proper portion (where the
; font bits for the character are 1) of the character for each byte.
; Wherever the font bits for the character are 0, the background
; color is preserved.
; Does not check for case where character is byte-aligned and
; no rotation and only one write is required.

	mov	cx,cs:[FontHeight] ;FONT_CHARACTER_SIZE
	mov	dx,GC_INDEX
	
	push	si
	push	di		; save pointers for right half

	mov	al,GC_BIT_MASK
	mov	ah,bh
	out	dx,ax		; Set the bit mask for the left half of the char

LeftCharLoop:
	mov	al,[si]		;get character byte
	inc	si
	xchg	al,es:[di]	;load latches & write char
	add	di,SCREEN_WIDTH	;point to next line of char in display mem
	dec	cx
	jnz	LeftCharLoop

	mov	cx,cs:[FontHeight] ;FONT_CHARACTER_SIZE

	pop	di
	pop	si		; restore pointers
	inc	di		; but point at next char in display mem

	mov	al,GC_BIT_MASK
	mov	ah,bl
	out	dx,ax		; Set the bit mask for the right half of the char

RightCharLoop:
	mov	al,[si]		;get character byte
	inc	si
	xchg	al,es:[di]	;load latches & write char
	add	di,SCREEN_WIDTH	;point to next line of char in display mem
	dec	cx
	jnz	RightCharLoop

	ret

DrawChar	endp


;*
;* here's where we hide gui messages
;*
;* we put them in a code segment so we don't have to go to a huge model to store lots of it
;*

.code


public _help_0
_help_0 label byte

db	'`U`yConsole Controls`u`d`n`n'
db	'`o  F1        F2        F3        F4        F5        F6        F7        F8`n'
db	'`d  Reset     Select    B/W       Color     P0 easy   P0 hard   P1 easy   P1 hard`n`n'

db	'`y`UPlayer 0 Joystick or Paddles`u`d`n`n'
db	'  `oCtrl`d -- fire   Use the arrow keys ( `o', 018h, ' ', 019h, ' ', 01bh, ' ', 01ah, ' `d) to move.`n`n'

db	'`y`UPlayer 1 Joystick`u`d`n`n'
db	'     `on`d -- fire   `os`d -- left   `oe`d -- up   `of`d -- right   `od`d -- down`n`n'

db	'`y`UPausing a Game`u`n`n'
db	'     `op`d -- pause`n'
db	' `oEnter`d -- resume`n`n'

db	'`y`UVideo Modes`u`n`n'
db	'     `o0 `d-- 320x200 70Hz (standard mode 13)`n'
db	'     `o1 `d-- 320x200 60Hz`n'
db	'     `o2 `d-- 320x200 60Hz narrow`n'
db	'     `o3 `d-- 320x204 60Hz narrow`n'
db	'     `o4 `d-- 320x240 60Hz (standard Mode-X)`n'
db	'     `o5 `d-- 320x240 60Hz narrow`n'
db	'     `o6 `d-- 320x240 60Hz scanline`n'
db	'     `o7 `d-- 320x480 60Hz very narrow and tall`n'
db	'     `o8 `d-- 320x240 60Hz intense scanline`n`n'

db	'`y`UScrolling the Screen`u`d`n`n'
db	' `oPgUp`d -- scroll screen up.`n'
db	' `oPgDn`d -- scroll screen down.`n'
db	' `oHome`d -- return to default screen position or top of file.`n`n'

db	'`y`UScreen Capture`u`d`n`n'
db	'    `o=`d -- PCX screen capture`n`n'

db	0


public _help_1
_help_1 label byte

db	'`y`UCommand Line Switches`u`d`n`n'

db	'  `o-0`d  -- start with player 0 hard`n'
db	'  `o-1`d  -- start with player 1 hard`n`n'
db	'  `o-b`d  -- start in black and white mode`n`n'
db	'  `o-c`yN`d -- color palette  (`y0`d = NTSC  `y1`d = PAL)`n`n'
db	'  `o-d`yN`d -- DSP processing level  (`y1`d = low   `y2`d = high)`n`n'
db	'  `o-f`yN`d -- run `yN`d frames and print timing results`n`n'
db	'  `o-j`yN`d -- joystick option    (`y0`d = keyboard only (analog joystick off),`n'
db	'                             `y2`d = reverse keyboard controls)`n`n'
db	'  `o-k`yN`d -- paddle to emulate   (`y0`d - `y3`d)`n'
db	'  `o-p`yN`d -- paddle sensitivity  (`y1`d - `y15`d)`n`n'
db	'  `o-q`d  -- quiet`n`n'
db	'  `o-r`d  -- run full speed  (vsync off)`n'
db	'  `o-r`yN`d -- run at `yN`d frames per second`n`n'
db	'  `o-s`yN`d -- sound option   (`y0`d = show diagnostic messages,`n'
db	'                         `y1`d = use PC speaker,`n'
db	'                         `y2`d = run Soundblaster at 15700 Hz)`n`n'
db	'  `o-u`yN`d -- start scanning game at line `yN`d`n`n'
db	'  `o-v`yN`d -- start in video mode `yN`d`n`n'
db	'  `o-x`d  -- print out checksum of cartridge`n'

db	0


public _help_2
_help_2 label byte

db	'`y`UCredits`u`d`n`n'
db	'     `oPaul Robson`d -- Wrote original A26.`n'
db	'    `oRonnie Green`d -- PCX screen capture code.`n'
db	'       `oRon Fries`d -- TIA sound emulation.`n'
db	'     `oJim Leonard`d -- Helped with video modes.`n'
db	'      `oChris Pile`d -- Sound Blaster drivers and line drawing code.`n'
db	'`oEttore Perazzoli`d -- 6502 undocumented instructions.`n'
db	'   `oAndreas Boose`d -- Also helped with 6502 undocumented instructions.`n'
db	'`oWolfgang Lorentz`d -- 6502 diagnostics.`n'
db	'     `oBob Colbert`d -- Information on object wrapping.`n'
db	'    `oPiero Cavina`d -- Information on multiple missiles.`n'
db	'    `oKevin Horton`d -- Information on bankswitching.`n'
db	'       `oDan Boris`d -- Atari 2600 schematics.`n'
db	'     `oJohn Dullea`d -- Fast, elegant 2600 graphics techniques.`n'
db	'   `oBradford Mott`d -- Information on player positioning.`n'
db	'`oEckhard Stolberg`d -- Information on player positioning and PAL colors.`n`n'

db	'`nThanks to one and all!!`n`n'

db	0

	END

