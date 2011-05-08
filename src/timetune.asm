; timetune.asm -- z26 time tuner
;
;  Aug 3, 2008 -- John Saeger
;
; build with:
; dasm timetune.asm -otimetune.bin -f3


	processor 6502

VSYNC	equ	$00	;Vertical sync set-clear
VBLANK	equ	$01	;Vertical blank set-clear
WSYNC	equ	$02	;Wait for leading edge of horizontal blank
COLUBK	equ	$09	;Color-lum background
	
color	equ	$80	; storage
color1	equ	$81
color2	equ	$82


	org	$1000

	sei
	cld
	ldx	#$ff
	txs			; initialize stack pointer

main
	lda	#0		; black
	sta	color
	sta	color1
	sta	color2
	
	jsr	doframe		; do a black frame
	
	lda	#%10000110	; blue
	sta	color
	lda	#%01001110	; pink
	sta	color1
	lda	#%11001110	; green
	sta	color2
	
	jsr	doframe		; do a colored frame

	jmp	main
	
	
	
doframe	
	lda	#2
	sta	VBLANK		; turn on vblank
         
	sta	VSYNC		; tell VCS to do another frame
	sta	WSYNC
	sta	VSYNC
	sta	WSYNC
	sta	VSYNC
	sta	WSYNC

	lda	#0
	sta	VSYNC

	lda	#0
	sta	VBLANK		; turn off vblank

	ldy	#37
	jsr	syncloop	; vblank top of screen
	
	lda	color
	sta	COLUBK
		
	ldy	#91
	jsr	syncloop	; do some blue lines (unless black)
	
	lda	color1
	sta	COLUBK
	ldy	#5
	jsr	syncloop	; do some pink lines (unless black)
	lda	color
	sta	COLUBK
	
	ldy	#91
	jsr	syncloop	; do some more blue lines (unless black)

;	lda	#2
;	sta	VBLANK		; turn on vblank

	lda	color2
	sta	COLUBK
	
	ldy	#35
	jsr	syncloop	; vblank bottom of screen

	rts


syncloop
	sta	WSYNC		; skip some lines
	dey			; this many
	bne	syncloop
	rts


	org	$1ffc		; startup vectors
	.word	$f000
	.word	$f000
