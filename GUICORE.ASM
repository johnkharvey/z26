;*
;* z26 GUI support code
;*
;* palette setting and line drawing code based on Asteroids 3.02 by Chris Pile
;*
;* text output based on code from The Graphics Programming Black Book by Michael Abrash
;*

; z26 is Copyright 1997-2001 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.


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

PUBLIC SimplexFont                              ; used in modex.asm too
SimplexFont label byte                          ; z26 GUI font

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

	imul	si,80
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
	imul	si,80
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

	imul	si,80
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
db      '  `oCtrl`d -- fire   Use the arrow keys ( `o', 018h, ' ', 019h, ' ', 01bh, ' ', 01ah, ' `d) to move.`n'
db      '     `o/`d -- trigger (booster grip)`n'
db      '`oRShift`d -- booster (booster grip)`n`n'

db	'`y`UPlayer 1 Joystick`u`d`n`n'
db      '     `on`d -- fire   `os`d -- left   `oe`d -- up   `of`d -- right   `od`d -- down`n'
db      '     `ob`d -- trigger (booster grip)`n'
db      '     `ov`d -- booster (booster grip)`n`n'

db      '`y`UPlayer 0 Driving Controller`u`d`n`n'
db      '  `oCtrl`d -- accelerate   `o',01ah, '`d -- turn clockwise   `o',01bh, '`d -- turn counter-clockwise`n`n'

db      '`y`UPlayer 1 Driving Controller`u`d`n`n'
db      '     `on`d -- accelerate   `of`d -- turn clockwise   `os`d -- turn counter-clockwise`n`n'

db      '`y`UKeyboard Controllers`u`d`n`n'

db      '`y  left port         right port`n`n'

db      '`o  7   8   9         1   2   3`n'
db      '`d  1   2   3         1   2   3`n`n'

db      '`o  u   i   o         q   w   e`n'
db      '`d  4   5   6         4   5   6`n`n'

db      '`o  j   k   l         a   s   d`n'
db      '`d  7   8   9         7   8   9`n`n'

db      '`o  m   ,   .         z   x   c`n'
db      '`d  *   0   #         *   0   #`n`n'

db	0


public _help_1
_help_1 label byte

db      '`y`UCompuMate Keyboard`u`d`n`n'
db      '`d Use PC keyboard columns `o1 `d- `o0`n'
db      '   `oCtrl`d -- FUNC`n'
db      ' `oLShift`d -- SHIFT`n`n'

db      '`y`UMindlink Controller`u`d`n`n'
db      '`d Use the mouse to move horizontally.`n'
db      ' `obutton`d -- start the game`n'
db      '    `oTab`d -- switch between player 1 and player 2`n`n'

db      '`y`UMouse Handling in Paddle Emulation`u`d`n`n'
db      '    `oTab`d -- switch between horiz. normal, vert. normal, horiz. reversed and vert. reversed`n`n'

db      '`y`UKid Vid Controller`u`d`n`n'
db      '`d Use keys `o1 2 3 `dto start the corresponding tape.`n'
db      ' `oF1 `dalso stops and rewinds the tape. `n'

db	0


public _help_2
_help_2 label byte

db	'`y`UPausing a Game`u`n`n'
db      '`oBackS`d -- pause`n'
db      '`oEnter`d -- resume`n`n'

db	'`y`UVideo Modes`u`n`n'
db      '`oAlt 0 `d-- 320x200 70Hz (standard mode 13)`n'
db      '`oAlt 1 `d-- 320x200 60Hz`n'
db      '`oAlt 2 `d-- 320x200 60Hz narrow`n'
db      '`oAlt 3 `d-- 320x204 60Hz narrow`n'
db      '`oAlt 4 `d-- 320x240 60Hz (standard Mode-X)`n'
db      '`oAlt 5 `d-- 320x240 60Hz narrow`n'
db      '`oAlt 6 `d-- 320x240 60Hz scanline`n'
db      '`oAlt 7 `d-- 320x480 60Hz very narrow and tall`n'
db      '`oAlt 8 `d-- 320x240 60Hz intense scanline`n'
db      '`oAlt 8 `d-- 360x480 60Hz shows number of scanlines in frame`n`n'

db	'`y`UScrolling the Screen`u`d`n`n'
db      ' `oPgUp`d -- scroll screen up.`n'
db      ' `oPgDn`d -- scroll screen down.`n'
db      ' `oHome`d -- return to default screen position or top of file.`n`n'

db      '`y`UScreen Capture`u`d`n`n'
db      '    `o=`d -- PCX screen capture`n`n'

db      '`y`UTrace Mode`u`d`n`n'
db      '  `oF11`d -- resume tracing`n'
db      '  `oF12`d -- interrupt tracing`n`n'

db      '`y`UPalette Change`u`d`n`n'
db      '    `o-`d -- switch between NTSC -> PAL -> SECAM palettes (set B/W switch manually for SECAM)`n`n'

db	0


public _help_3
_help_3 label byte

db	'`y`UCommand Line Switches`u`d`n`n'

db	'  `o-0`d  -- start with player 0 hard`n'
db	'  `o-1`d  -- start with player 1 hard`n`n'
db      '  `o-4`d  -- allow all 4 directions on the joystick to be pressed simultaniously`n`n'
db	'  `o-5`d  -- enable 50Hz video modes`n`n'
db	'  `o-b`d  -- start in black and white mode`n`n'
db	'  `o-c`yN`d -- color palette  (`y0`d = NTSC  `y1`d = PAL  `y2`d = SECAM)`n`n'
db      '  `o-d`yN`d -- DSP processing level  (`y1`d = low   `y2`d = high)`n`n'
db      '  `o-e`d  -- enable 32-bit Mode-X and 160 pixel linear video modes`n`n'
db	'  `o-f`yN`d -- run `yN`d frames and print timing results`n`n'
db      '  `o-g`yN`d -- override game type  (`y1`d - Commavid extra RAM,`n'
db      '                              `y2`d - 8K superchip,`n'
db      '                              `y3`d - 8K Parker Brothers,`n'
db      '                              `y4`d - 8K Tigervision,`n'
db      '                              `y5`d - 8K Decathlon & Robot Tank,`n'
db      '                              `y6`d - 16K superchip,`n'
db      '                              `y7`d - 16K M-Network,`n'
db      '                              `y8`d - 32K superchip,`n'
db      '                              `y9`d - 8K Atari -- banks swapped`n'
db      '                             `y10`d - Spectravideo CompuMate`n'
db      '                             `y11`d - 32K Tigervision)`n`n'
db      '  `o-h`d  -- enable half-sized (alternate scanline) display (video modes 0 - 3 only)`n`n'
db      '  `o-i`yN`d -- emulate Mindlink controller (`y1`d = right   `y2`d = left)`n`n'
db      '  `o-j`yN`d -- joystick option     (`y0`d = keyboard only (analog joystick off),`n'
db      '                              `y2`d = reverse keyboard controls)`n`n'
db      '  `o-k`yN`d -- paddle to emulate with keyboard  (`y0`d - `y3`d)`n'
db      '  `o-p`yN`d -- paddle sensitivity  (`y1`d - `y15`d -- keyboard only)`n'
db      '  `o-m`yN`d -- paddle to emulate with mouse  (`y0`d - `y3`d)`n'
db      '  `o-m1`yXY`d -- emulate two paddles with mouse  (X and Y = `y0`d to `y3`d)`n'

db	0


public _help_4
_help_4 label byte
db      '`y`UCommand Line Switches (continued)`u`d`n`n'

db      '  `o-l`yN`d -- enable lightgun emulation and adjust by `yN`d cycles`n'
db      '  `o-a`yN`d -- adjust lightgun emulation by `yN`d scanlines`n`n'
db      '  `o-n`d  -- show line number count after end of emulation`n`n'
db      '  `o-o`d  -- simulate PAL colour loss`n`n'
db      '  `o-q`d  -- quiet`n`n'
db	'  `o-r`d  -- run full speed  (vsync off)`n'
db      '  `o-r`yN`d -- run at `yN`d frames per second`n`n'
db	'  `o-s`yN`d -- sound option   (`y0`d = show diagnostic messages,`n'
db	'                         `y1`d = use PC speaker,`n'
db	'                         `y2`d = run Soundblaster at 15700 Hz)`n`n'
db      '  `o-t`d  -- write code-trace to file Z26.LOG`n`n'
db	'  `o-u`yN`d -- start scanning game at line `yN`d`n`n'
db	'  `o-v`yN`d -- start in video mode `yN`d`n`n'
db      '  `o-w`yN`d -- emulate driving controllers  (`y1`d = left   `y2`d = right   `y3`d = both)`n`n'
db      '  `o-x`d  -- print out checksum of cartridge`n`n'
db      '  `o-y`yN`d -- emulate keyboard controller  (`y1`d = left   `y2`d = right   `y3`d = both)`n`n'
db      '  `o-z`d  -- rotate screen 90 degrees counter-clockwise (video modes 0 - 3 only)`n`n'


db	0


public _help_5
_help_5 label byte

db	'`y`UCredits`u`d`n`n'
db	'      `oPaul Robson`d -- Wrote original A26.`n'
db	'     `oRonnie Green`d -- Original PCX screen capture code.`n'
db	'        `oRon Fries`d -- TIA sound emulation.`n'
db	'      `oJim Leonard`d -- Helped with video modes.`n'
db	'       `oChris Pile`d -- Sound Blaster drivers and line drawing code.`n'
db	' `oEttore Perazzoli`d -- Helped with 6502 undocumented instructions.`n'
db	'    `oAndreas Boose`d -- Also helped with 6502 undocumented instructions.`n'
db	' `oWolfgang Lorentz`d -- 6502 diagnostics.`n'
db	'      `oBob Colbert`d -- Helped with object wrapping.`n'
db	'     `oPiero Cavina`d -- Helped with multiple missiles.`n'
db	'      `oErik Mooney`d -- Helped with HMOVE blanks.`n'
db	'     `oKevin Horton`d -- Helped with bankswitching and digital voice.`n'
db	'        `oDan Boris`d -- Atari 2600 schematics.`n'
db	'   `oMatt Pritchard`d -- Font design tools.`n'
db	'       `oMatt Conte`d -- Helped with digital voice and 50Hz video modes.`n'
db	'      `oJohn Dullea`d -- Fast, elegant 2600 graphics techniques, and help with Pitfall II.`n'
db	'    `oBradford Mott`d -- Helped with object positioning (weird HMOVE).`n'
db      '    `oChris Wilkson`d -- Helped with Pitfall II.`n'
db      '      `oLee Krueger`d -- Helped with Kid Vid support, rare carts and documentation.`n'
db      ' `oEckhard Stolberg`d -- Helped with object positioning, PAL/SECAM colors, digital voice, controllers,`n'
db	'                     Cosmic Ark effect, Pitfall II, CompuMate, Supercharger games, fast video`n'
db      '                     modes, Kid Vid support and the new PCX screen capture code.`n'
db      '  `oThomas Jentzsch`d -- Helped with trace mode and Kid Vid support.`n'
db      '`oMichael Walden Jr`d -- Helped with GUI.`n'
db      '`o  Henning Mueller`d -- Helped with CompuMate.`n'
db	'  `oChristian Bogey`d -- Helped with SECAM colors. `n`n'

db      '`nThanks to one and all!!`n`n`n`n`n`n'

db	'`y`UCopyright/License`u`d`n`n'
db      'z26 is Copyright 1997-2002 by John Saeger and is a derived work with many`n'
db	'contributors.  z26 is released subject to the terms and conditions of the`n'
db	'GNU General Public License Version 2 (GPL).  `oz26 comes with no warranty.`d`n'
db	'Please see the included COPYING.TXT for details.  Source code for the`n'
db	'current release is available at the homepage shown elsewhere on the screen.`n'

db	0


	END

