;ATARI 2600 INTERLACED VIDEO PROOF OF CONCEPT
; BASED ON:
;------------------------------------------------------
;$Id: cubeconq.s,v 1.1.2.6 2002/08/18 01:46:07 Billy Exp $
;------------------------------------------------------
; LAST MODIFIED BY GLENN SAUNDERS ON 8/18/2002
	processor 6502
    include "vcs.h"
;color defines
GRAY		=	$00
GOLD		=	$10
ORANGE		=	$20
BRT_ORANGE	=	$30
PINK		=	$40
PURPLE		=	$50
PURPLE_BLUE	=	$70
BLUE		=	$80
GREEN		=	$C0
LT_ORANGE	=	$F0

LUM1		= 	$00	
LUM2		=	$02
LUM3		= 	$04	
LUM4		= 	$06	
LUM5		= 	$08	
LUM6		= 	$0a	
LUM7		= 	$0c	
LUM8		=	$0e

LIGHTBLUE	=	BLUE | LUM1
LIGHTPINK	= 	PINK | LUM1

LIGHTGRAY	=	GRAY | LUM1
BLACK		= 	GRAY | LUM1
WHITE		=	$0F

MEDIUMRED	=	BRT_ORANGE | LUM3
MEDIUMGREEN	=	GREEN | LUM4
MEDIUMBLUE	=	BLUE | LUM4

P0COLOR		=	MEDIUMRED
P1COLOR		=	MEDIUMGREEN
GRADLINES	=	64; DO ALL 128 COLORS ACROSS THE 2-FIELD KERNEL, 64 COLORS PER KERNEL


;Ram variables
	        SEG.U   variables
	       	org $80
	        
interlaced	ds	1
	        
framenum	ds	1

xpos0		ds	1
xpos1		ds	1

rand0		ds	1			;16 bit random number (random routines in common.s)
rand1		ds	1

delay_switch	ds	1		;used to delay switch checking
TEMP
temp0		ds	1
temp1		ds	1
temp2		ds	1
temp3		ds	1
field_toggle	ds	1

	SEG code

	org	$f000

;Common subroutines
;------------------------------------------------------
;$Id: common.s,v 1.2.4.2 2002/08/16 04:14:11 Billy Exp $
;------------------------------------------------------
;start the vertical sync and set the timer for 37 lines of blank
start_vertical_sync		subroutine

	LDA #2
	STA VSYNC ; Begin vertical sync.
	STA WSYNC ; First line of VSYNC
	STA WSYNC ; Second line of VSYNC.


	LDA #44		;timer for 27 lines of blanking
	STA TIM64T
	LDA	#0
	STA WSYNC ; Third line of VSYNC.
	STA VSYNC ; (0)

	rts
;**************************************************************
;wait for the timer to end
wait_timer			subroutine
.wait
	lda INTIM		;timer ended?
	bne	.wait

	rts
;**************************************************************
;start the overscan
start_Overscan			;end scanline 191, begin overscan
	lda	#2	   		;First line turns on VBLANK 
	sta	WSYNC

	sta	HMCLR		;clear all the move registers

	sta	VBLANK

	lda	#36		;Timer for 30 scanlines
	sta	TIM64T

	rts
;**************************************************************
;wait number of line in Y
wait_lines	subroutine
.loop
	sta WSYNC
	dey
	bne .loop
	rts
;**************************************************************

random	subroutine
	lda rand1	;we need to XOR bits 11 and 15 (counting from 0)
    rol         ;15 in bit #6 (of rand3)
    rol         ;11 in bit #4 (of rand3)
    eor rand1   ;XOR the two together
    rol 
    rol         ;pop the XOR'd bit out into carry
    rol rand0   ;rotate 16 bits' worth
    rol rand1   ;note carry = random bit
    rts

;------------------------------------------------------
; ALL INCLUDES NOW INLINE
;
;------------------------------------------------------

			;common subs
;position utility
;copied from the multisprite demo by Piero Cavina which was copied
; from air-sea battle
;http://www.biglist.com/lists/stella/archives/199704/msg00015.html
;------------------------------------------------------
;$Id: FC_position.s,v 1.1 2002/07/22 03:43:57 Billy Exp $
;------------------------------------------------------

; Straight from "Air sea battle", here's the routine
; to convert from standard X positions to FC positions.

fc_cnv STA    TEMP+1
       BPL    LF34B
       CMP    #$9E
       BCC    LF34B
       LDA    #$00
       STA    TEMP+1
LF34B: LSR
       LSR
       LSR
       LSR
       TAY
       LDA    TEMP+1
       AND    #$0F
       STY    TEMP+1
       CLC
       ADC    TEMP+1
       CMP    #$0F
       BCC    LF360
       SBC    #$0F
       INY
LF360: CMP    #$08
       EOR    #$0F
       BCS    LF369
       ADC    #$01
       DEY
LF369: INY
       ASL
       ASL
       ASL
       ASL
       STA    TEMP+1
       TYA
       ORA    TEMP+1
       RTS
;------------------------------------------------------
;$Log: FC_position.s,v $
;Revision 1.1  2002/07/22 03:43:57  Billy
;horizontal position working for both heads
;
; NOW INLINE
;------------------------------------------------------


;Setup stuff
start
	sei             ;clear interupts
	cld             ;set to non-BCD mode
    
;Clear all memory except $ff/$1ff - Stack end
	lda #0
clear
	sta $ff,x		;x still has $ff in it
	dex
	bne clear		;x comes out with 0

main_game

normal_repeat				;repeat point
	
	lda	#$FF				;start interlaced
	sta interlaced

;set player numbers to triple
	lda	#$06
	sta	NUSIZ0
	sta	NUSIZ1

;setup the missiles
	lda	#$02
	sta	RESMP0		;lock the missiles to the players (and disable)
	sta	RESMP1

;set background
	lda #BLACK
	sta COLUBK



;set framenum	
	lda	#2
	sta	framenum

frame
;Vertical sync
	dec	framenum
	
	lda	interlaced		;see if we are in interlaced mode
	beq	non_interlaced	

	lda framenum
	beq	even_sync	

non_interlaced			;entry point for non-interlaced
	;this is the vertical sync for the first field of an interlaced frame
	;or just a normal non-interlaced vertical sync
	lda #2
	sta WSYNC
	sta VSYNC ; Begin vertical sync.

	sta WSYNC ; First line of VSYNC
	sta WSYNC ; Second line of VSYNC.
	lda	#0
	sta WSYNC ; Third line of VSYNC.
	sta VSYNC ; (0)

	lda	#BLACK
	sta	COLUBK

	jmp done_sync
even_sync
	;this is the vertical sync for the second field of an interlaced fram
	sta WSYNC
	;need 40 cycles until the start of vertical sync
	
	;this style of loop delays 5*Y+1
	ldy	#7
even_sync_loop1
	dey		 
	bne	even_sync_loop1
	;36 cycles
	nop 		;38

	lda #2		;40
		
	sta VSYNC ; Begin vertical sync.
	sta WSYNC ; First line of VSYNC
	sta WSYNC ; Second line of VSYNC.

	sta WSYNC ; Third line of VSYNC.
	;need 33 cycles until the end of VSYNC

	;this style of loop delays 5*Y+1
	ldy	#6
even_sync_loop2
	dey		 
	bne	even_sync_loop2
	;31 cycles		
	lda #0	;33
	sta VSYNC 

done_sync

	LDA #40		;timer for 34 lines of blanking
	STA TIM64T

	lda	#22		;starting x of sprites
	sta	xpos0
	lda	#38
	sta xpos1

;this contains the positioning routine, 4 scan lines 
;player positioning routines
;------------------------------------------------------
;$Id: position_players.s,v 1.2 2002/07/23 02:17:19 Billy Exp $
;------------------------------------------------------
;this takes 4 scan lines
;position player 0 head	
	lda	xpos0
	clc
	adc	#35			;get the player to the edge of my screen
	jsr fc_cnv
	sta WSYNC
	sta	HMP0		; remember, we're still doing Vblank now
    and #$0F
    tay
plpsl0
	dey
    bpl	plpsl0
    sta	RESP0		
    sta	WSYNC
    sta	HMOVE

;position player 1 head	
	lda	xpos1
	clc
	adc	#35			;get the player to the edge of my screen
	jsr fc_cnv
	ldx	#0
	stx HMP0		;clear the 0 hmove register
	sta WSYNC
	sta	HMP1		; remember, we're still doing Vblank now
   	and #$0F
    tay    
plpsl1
	dey
   	bpl	plpsl1
    sta	RESP1		
    sta	WSYNC
    sta	HMOVE
;------------------------------------------------------
;$Log: position_players.s,v $
;Revision 1.2  2002/07/23 02:17:19  Billy
;small change
;
;------------------------------------------------------
	
	
;wait for the vertical blank to end

	jsr wait_timer
	sta	WSYNC	;37th line of VBLANK

	sta	VBLANK   ;A comes back as zero, end vblank
	sta WSYNC
	sta WSYNC

;start visible area		
	ldy	#10			;wait ten lines to space it down some
	jsr wait_lines

	lda	#P0COLOR	;set up my player colors
	sta	COLUP0
	lda	#P1COLOR
	sta	COLUP1

;first draw some diagonal lines
	ldx #4			;x is used for an outer loop counter to draw the lines 4 times
	lda framenum 	;see which frame I'm on
	beq diags_even

diags_odd
diags_outer_odd
	lda	#$40
	ldy	#4			
diags_inner_odd
	sta WSYNC		
	sta	GRP0		
	sta GRP1
	lsr				;shift bit over twice
	lsr
	dey
	bne diags_inner_odd
	dex
	bne diags_outer_odd
	jmp done_diags	

diags_even	
diags_outer_even
	lda	#$80
	ldy	#4			
diags_inner_even
	sta WSYNC
	sta	GRP0
	sta GRP1
	lsr				;shift bit over twice
	lsr
	dey
	bne diags_inner_even
	dex
	bne diags_outer_even
done_diags
	
	sta WSYNC 		;end of 26th/beginning of 27th line
	lda	#0
	sta GRP0		;kill the graphics
	sta GRP1	

;now on 27th line
	ldy	#10			;space down 10 more lines
	jsr wait_lines
;now on 37th line

;now draw some space ships
	lda framenum	
	beq ships_even

ships_odd	
	ldx #14			;x is an index into the graphic
ships_odd_loop
	lda	spaceship,x
	sta WSYNC
	sta GRP0
	sta GRP1
	dex				;need every other line
	dex
	bpl ships_odd_loop	

	jmp done_ships

ships_even
	ldx #15	
ships_even_loop
	lda	spaceship,x
	sta WSYNC
	sta GRP0
	sta GRP1
	dex
	dex
	bpl ships_even_loop	
	
done_ships
		
	sta WSYNC	;end of 45th/beginning of 46th
	lda #0		;kill the graphics
	sta GRP0
	sta GRP1

;now on 46th line


	ldy #10
	jsr wait_lines
;now on 86th line
;now the demo as suggested by Glenn Saunders

;here what I want to do is in noninterlaced mode, don't do chronocolor.
;in other words, just pick the odd line kernel for both fields in noninterlaced mode.
;this should eliminate the flicker and provide a more visual contrast between the two modes.


; set playfield graphics
	lda #%01010101
	STA PF0



	lda	interlaced		;see if we are in interlaced mode
	bne	do_interlaced

do_noninterlaced
	lda	field_toggle
	beq	odd_demo
	jmp	even_demo

do_interlaced

	lda	framenum
	bne	odd_demo
	jmp	even_demo
	
odd_demo
	lda	#MEDIUMRED
	sta	COLUBK	

	lda	#WHITE
	sta	COLUPF

	ldy #5
	jsr wait_lines
;now on line +10
	lda	#BLACK
	sta	COLUBK
	sta	COLUPF
	ldy #5
	jsr wait_lines

;now on line +15
	lda	#MEDIUMRED
	sta	COLUBK	
	lda	#WHITE
	sta	COLUPF


	ldy #5
	jsr wait_lines
;now on line +25
	lda	#BLACK
	sta	COLUBK
	sta	COLUPF
	ldy #5
	jsr wait_lines

;now on line +30
	lda	#BLACK
	sta	COLUBK
	sta	COLUPF	
	ldy #5
	jsr wait_lines
;now on line +40
	lda	#BLACK
	sta	COLUBK
	sta	COLUPF
	ldy #5
	jsr wait_lines

;now on line +45
	lda	#MEDIUMRED
	sta	COLUBK	
	lda	#WHITE
	sta	COLUPF

	sta WSYNC
;now on line +46
	lda	#BLACK
	sta	COLUBK
	sta	COLUPF
	ldy #5
	jsr wait_lines

;now on line +51
	lda	#MEDIUMBLUE
	sta	COLUBK
	lda	#WHITE
	sta	COLUPF	
	sta	WSYNC
;now on line +52
	lda	#BLACK
	sta	COLUBK
	sta	COLUPF
	ldy #5
	jsr wait_lines

;now on line +57
	lda	#MEDIUMRED
	sta	COLUBK
	lda	#WHITE
	sta	COLUPF
	
	sta WSYNC
;now on line +58
	lda	#BLACK
	sta	COLUBK
	sta	COLUPF
	ldy #5
	jsr wait_lines

;now on line +63
	lda	#MEDIUMBLUE
	sta	COLUBK
	lda	#WHITE
	sta	COLUPF	
	sta 	WSYNC

; more black lines
	lda	#BLACK
	sta	COLUPF
	sta	COLUBK
	ldy #5
	jsr wait_lines
;gradient
	
	lda	#$02
	STA	COLUBK
	STA	WSYNC

	ldx	#GRADLINES-1
cyclerODD
	
	adc	#4
	STA	COLUBK
	STA	WSYNC
	
	dex
	bne	cyclerODD


	LDA #WHITE
	STA COLUPF
	LDA #0
	STA COLUBK
; draw a diagonal using PF2
	ADC #%01000000
	

	sta PF1
	sta WSYNC
	
	ROR
	ROR
	sta PF1
	sta WSYNC
	

	
	ROR
	ROR
	sta PF1
	sta WSYNC
	
	
	ROR
	ROR
	sta PF1
	sta WSYNC

	LDA #0
	STA PF1
	
	ADC #2
	
	sta PF2
	sta WSYNC
	
	ROL
	ROL
	sta PF2
	sta WSYNC
	
	ROL
	ROL
	sta PF2
	sta WSYNC

	ROL
	ROL
	sta PF2
	sta WSYNC
	
	
;now on line +64
	jmp end_demo	
	
	
even_demo
	lda	#MEDIUMBLUE
	sta	COLUBK	

	lda	#MEDIUMRED
	sta	COLUPF

	ldy #5
	jsr wait_lines
;now on line +10
	lda	#BLACK
	sta 	COLUBK
	sta	COLUPF

	ldy #5
	jsr wait_lines

;now on line +15
	lda	#BLACK
	sta 	COLUBK
	sta	COLUPF
	ldy #5
	jsr wait_lines
;now on line +25
	lda	#BLACK
	sta 	COLUBK
	sta	COLUPF
	ldy #5
	jsr wait_lines

;now on line +30
	lda	#MEDIUMBLUE
	sta	COLUBK	
	lda	#MEDIUMRED
	sta	COLUPF
	
	ldy #5
	jsr wait_lines
;now on line +40
	lda	#BLACK
	sta 	COLUBK
	sta	COLUPF
	ldy #5
	jsr wait_lines

;now on line +45
	lda	#MEDIUMRED
	sta	COLUBK	
	lda	#MEDIUMRED
	sta	COLUPF
	sta WSYNC
;now on line +46
	lda	#BLACK
	sta	COLUPF
	sta	COLUBK
	ldy #5
	jsr wait_lines
;now on line +51
	lda	#MEDIUMBLUE
	sta	COLUBK	
	lda	#MEDIUMRED
	sta	COLUPF
	sta WSYNC
;now on line +52
	lda	#BLACK
	sta 	COLUBK
	sta	COLUPF
	ldy #12
	jsr wait_lines
; more black lines
	lda	#BLACK
	sta	COLUPF
	sta	COLUBK
	ldy #5
	jsr wait_lines

; now do an 8 scanline gradient
;gradient
	
	lda	#$00
	STA	COLUBK
	STA	WSYNC

	ldx	#GRADLINES-1
cyclerEVEN
	
	adc	#4
	STA	COLUBK
	
	STA	WSYNC
	
	dex
	bne	cyclerEVEN

	LDA #WHITE
	STA COLUPF
	LDA #0
	STA COLUBK

; draw a diagonal using PF2
	LDA #%10000000
	

	sta PF1
	sta WSYNC
	
	ROR
	ROR
	sta PF1
	sta WSYNC
	

	
	ROR
	ROR
	sta PF1
	sta WSYNC
	
	
	ROR
	ROR
	sta PF1
	sta WSYNC

	LDA #0
	STA PF1
	
	ADC #1
	
	sta PF2
	sta WSYNC
	
	ROL
	ROL
	sta PF2
	sta WSYNC
	
	ROL
	ROL
	sta PF2
	sta WSYNC

	ROL
	ROL
	sta PF2
	sta WSYNC
	

;now on line +64
end_demo
	lda	#BLACK
	sta 	COLUBK
	sta 	PF0
	sta	PF2

;now on line 150
	ldy	#79-GRADLINES
	;ldy	#28
	jsr wait_lines


;Overscan
	jsr start_Overscan	

	lda delay_switch
	bne	skip_switch_check
;check for reset
	lda SWCHB
	and	#1
	bne	no_reset
reset
	lda	#15				;insert a delay
	sta delay_switch
	
	jmp	main_game
no_reset

;check for select
	lda SWCHB
	and #$02
	bne no_select

	lda #$FF
	eor	interlaced
	beq	no_field_toggle

do_field_toggle
	lda #$FF
	eor	field_toggle
	sta	field_toggle

no_field_toggle
	sta interlaced
	
	lda	#15				;insert a delay
	sta delay_switch	
	
no_select
skip_switch_check

frame_done
;update framenum
	lda framenum
	bne no_update_framenum
	lda	#2
	sta framenum
no_update_framenum

;decrement delay_switch
	lda	delay_switch
	beq	no_dec_delay_switch
	dec delay_switch
no_dec_delay_switch
;wait for overscan to end
	jsr wait_timer
;wait_FF
;	lda INTIM		;timer ended?
;	bne	wait_FF

	jmp frame

;this packs graphics.c and drawit.s all the way down to the bottom, where all should work	
	org	$fef1		

;------------------------------------------------------
;graphics
;------------------------------------------------------
;$id$
;------------------------------------------------------
score_digits
digit_0
	dc	%01111110
	dc	%11111111
	dc	%11100111
	dc	%11000011
	dc	%11000011
	dc	%11100111
	dc	%11111111
	dc	%01111110
digit_1
	dc	%00011100
	dc	%00111100
	dc	%01111100
	dc	%00011100
	dc	%00011100
	dc	%00011100
	dc	%01111111
	dc	%01111111
digit_2
	dc	%11111111
	dc	%11111111
	dc	%00001111
	dc	%00001111
	dc	%11111111
	dc	%11100000
	dc	%11100000
	dc	%11111111
digit_3
	dc	%11111111
	dc	%11111111
	dc	%00000111
	dc	%00000111
	dc	%11111111
	dc	%00000111
	dc	%00000111
	dc	%11111111
digit_4
	dc	%11100111
	dc	%11100111
	dc	%11100111
	dc	%11100111
	dc	%11111111
	dc	%00000111
	dc	%00000111
	dc	%00000111
digit_5
	dc	%11111111
	dc	%11111111
	dc	%11110000
	dc	%11110000
	dc	%11111111
	dc	%00000111
	dc	%00000111
	dc	%11111111
digit_6
	dc	%11111111
	dc	%11000000
	dc	%11000000
	dc	%11111111
	dc	%11111111
	dc	%11000111
	dc	%11000111
	dc	%11111111
digit_7
	dc	%11111111
	dc	%11111111
	dc	%11001111
	dc	%00001111
	dc	%00001111
	dc	%00001111
	dc	%00001111
	dc	%00001111
digit_8
	dc	%11111111
	dc	%11000111
	dc	%11000111
	dc	%11111111
	dc	%11111111
	dc	%11000111
	dc	%11000111
	dc	%11111111
digit_9
	dc	%11111111
	dc	%11000111
	dc	%11000111
	dc	%11111111
	dc	%11111111
	dc	%00000111
	dc	%00000111
	dc	%11111111

spaceship
	dc	%00011000
	dc	%00011000
	dc	%00100100
	dc	%01000010
	dc	%11011011
	dc	%11011011
	dc	%11000011
	dc	%10000001
	
	dc	%11100111
	dc	%11111111
	dc	%01111110
	dc	%01000010
	dc	%11011011
	dc	%11011011
	dc	%11000011
	dc	%10000001

;------------------------------------------------------
;$Log$
;------------------------------------------------------



;make sure nothing gets put here so unmodified superchargers 
;can play the game
	org	$fff8
	ds	4
;Boot up points....

	org	$fffc
	dc.w	start                    ; Reset vector
    dc.w	start                    ; IRQ vector

;------------------------------------------------------
;$Log: cubeconq.s,v $
;Revision 1.1.2.6  2002/08/18 01:46:07  Billy
;not much...
;
;Revision 1.1.2.5  2002/08/17 04:58:44  Billy
;interleaving improved
;
;Revision 1.1.2.4  2002/08/16 04:14:11  Billy
;maybe interlacing works.
;
;Revision 1.1.2.3  2002/08/16 02:38:45  Billy
;submitted to stella list, ugly
;
;Revision 1.1.2.2  2002/08/14 02:25:56  Billy
;experiment with changing background color
;
;Revision 1.1.2.1  2002/08/14 01:11:49  Billy
;Playfield experiments
;
;------------------------------------------------------
