;
; here lie the TIA register handlers (except for sound stuff)
;
; they get called via the vector tables during raster generation (TIALineTo)
; they process the TIA events (or objects) that were queued up in the TIA buffer
; when a batch of instructions was executed
;
; the first vector table (TIARegVector) is used when the line is actually to be drawn
; the second (TIARegVector2) is used when the line is off of the display area
;
; on entry:
;	bx = TIA register number (which implies bh = 0)
;	bp = pointer to TIA event in TIA buffer
;

.CEND
.DATASEGMENT

ALIGN 2

TIARegVector dw TRNoop		; 00 -- VSYNC
	dw	TRNoop		; 01 -- VBLANK
	dw	TRNoop		; 02 -- WSYNC
	dw	TRNoop		; 03 -- RSYNC
	dw	TRCopy		; 04 -- NUSIZ0
	dw	TRCopy		; 05 -- NUSIZ1
	dw	TRCopy		; 06 -- COLUP0
	dw	TRCopy		; 07 -- COLUP1
	dw	TRCopy		; 08 -- COLUPF
	dw	TRCopy		; 09 -- COLUBK
	dw	TRCopy		; 0A -- CTRLPF
	dw	TRCopy		; 0B -- REFP0
	dw	TRCopy		; 0C -- REFP1
	dw	TRCopy		; 0D -- PF0
	dw	TRCopy		; 0E -- PF1
	dw	TRCopy		; 0F -- PF2
	dw	TRPlyr		; 10 -- RESP0
	dw	TRPlyr		; 11 -- RESP1
	dw	TRMiss		; 12 -- RESM0
	dw	TRMiss		; 13 -- RESM1
	dw	TRBall		; 14 -- RESBL
	dw	TRSond		; 15 -- AUDC0
	dw	TRSond		; 16 -- AUDC1
	dw	TRSond		; 17 -- AUDF0
	dw	TRSond		; 18 -- AUDF1
	dw	TRSond		; 19 -- AUDV0
	dw	TRSond		; 1A -- AUDV1
	dw	TRGrp0		; 1B -- GRP0
	dw	TRGrp1		; 1C -- GRP1
	dw	TRCopy		; 1D -- ENAM0
	dw	TRCopy		; 1E -- ENAM1
	dw	TRCopy		; 1F -- ENABL
	dw	TRCopy		; 20 -- HMP0
	dw	TRCopy		; 21 -- HMP1
	dw	TRCopy		; 22 -- HMM0
	dw	TRCopy		; 23 -- HMM1
	dw	TRCopy		; 24 -- HMBL	
	dw	TRCopy		; 25 -- VDELP0
	dw	TRCopy		; 26 -- VDELP1
	dw	TRCopy		; 27 -- VDELBL
	dw	TRCopy		; 28 -- RESMP0
	dw	TRCopy		; 29 -- RESMP1
	dw	TRHMov		; 2A -- HMOVE
	dw	TRHClr		; 2B -- HMCLR
	dw	TRCClr		; 2C -- CXCLR

	dw	TRNoop		; 2D
	dw	TRNoop		; 2E
	dw	TRNoop		; 2F
	dw	TRNoop		; 30
	dw	TRNoop		; 31
	dw	TRNoop		; 32
	dw	TRNoop		; 33
	dw	TRNoop		; 34
	dw	TRNoop		; 35
	dw	TRNoop		; 36
	dw	TRNoop		; 37
	dw	TRNoop		; 38
	dw	TRNoop		; 39
	dw	TRNoop		; 3A
	dw	TRNoop		; 3B
	dw	TRNoop		; 3C
	dw	TRNoop		; 3D
	dw	TRNoop		; 3E
	dw	TRNoop		; 3F
        
TIARegVector2 dw TRNoop		; 00 -- VSYNC
	dw	TRNoop		; 01 -- VBLANK
	dw	TRNoop		; 02 -- WSYNC
	dw	TRNoop		; 03 -- RSYNC
	dw	TRCopy		; 04 -- NUSIZ0
	dw	TRCopy		; 05 -- NUSIZ1
	dw	TRCopy		; 06 -- COLUP0
	dw	TRCopy		; 07 -- COLUP1
	dw	TRCopy		; 08 -- COLUPF
	dw	TRCopy		; 09 -- COLUBK
	dw	TRCopy		; 0A -- CTRLPF
	dw	TRCopy		; 0B -- REFP0
	dw	TRCopy		; 0C -- REFP1
	dw	TRCopy		; 0D -- PF0
	dw	TRCopy		; 0E -- PF1
	dw	TRCopy		; 0F -- PF2
	dw	TRSave		; 10 -- RESP0
	dw	TRSave		; 11 -- RESP1
	dw	TRSave		; 12 -- RESM0
	dw	TRSave		; 13 -- RESM1
	dw	TRSave		; 14 -- RESBL
	dw	TRSond		; 15 -- AUDC0
	dw	TRSond		; 16 -- AUDC1
	dw	TRSond		; 17 -- AUDF0
	dw	TRSond		; 18 -- AUDF1
	dw	TRSond		; 19 -- AUDV0
	dw	TRSond		; 1A -- AUDV1
	dw	TRGrp0		; 1B -- GRP0
	dw	TRGrp1		; 1C -- GRP1
	dw	TRCopy		; 1D -- ENAM0
	dw	TRCopy		; 1E -- ENAM1
	dw	TRCopy		; 1F -- ENABL
	dw	TRCopy		; 20 -- HMP0
	dw	TRCopy		; 21 -- HMP1
	dw	TRCopy		; 22 -- HMM0
	dw	TRCopy		; 23 -- HMM1
	dw	TRCopy		; 24 -- HMBL
	dw	TRCopy		; 25 -- VDELP0
	dw	TRCopy		; 26 -- VDELP1
	dw	TRCopy		; 27 -- VDELBL
	dw	TRCopy		; 28 -- RESMP0
	dw	TRCopy		; 29 -- RESMP1
	dw	TRHmvB		; 2A -- HMOVE
	dw	TRHClr		; 2B -- HMCLR
	dw	TRCxZr		; 2C -- CXCLR

	dw	TRNoop		; 2D
	dw	TRNoop		; 2E
	dw	TRNoop		; 2F
	dw	TRNoop		; 30
	dw	TRNoop		; 31
	dw	TRNoop		; 32
	dw	TRNoop		; 33
	dw	TRNoop		; 34
	dw	TRNoop		; 35
	dw	TRNoop		; 36
	dw	TRNoop		; 37
	dw	TRNoop		; 38
	dw	TRNoop		; 39
	dw	TRNoop		; 3A
	dw	TRNoop		; 3B
	dw	TRNoop		; 3C
	dw	TRNoop		; 3D
	dw	TRNoop		; 3E
	dw	TRNoop		; 3F
.DEND
.CODESEGMENT

;*
;* sound stuff
;*

TRSond: mov	bl,TIAReg[bp]		; bl = register
	mov	bh,TIAVal[bp]		; bh = data
	call	Sound			; do some sound stuff
	ret

;*
;* clear collision latches (on-screen version)
;*

TRCClr: mov	bl,TIAClock[bp]		; clear the collision flag
	or	byte ptr TIADisplay[bx],80h ; set the bit 7 in the display field
	ret				    ;   (signals raster engine to clear it)

;*
;* clear collision latches (off-screen version)
;*

TRCxZr: mov	[TIACollide],0		; reset the collision word
	ret

;*
;* do nothing
;*
	        
TRNoop: ret				; just ignore it ......

;*
;* copy register
;*

TRCopy: mov	bl,TIAReg[bp]		; register copy.offset in bx
					; bh is already zero
	mov	al,TIAVal[bp]		; value in al
	mov	TIA[bx],al		; write it
	ret

;*
;* clear horizontal motion registers
;*

TRHClr: xor	al,al			; clear the HMove registers
	mov	[TIA+TIAHmp0],al
	mov	[TIA+TIAHmp1],al
	mov	[TIA+TIAHmm0],al
	mov	[TIA+TIAHmm1],al
	mov	[TIA+TIAHmbl],al
	ret

;*
;* player 0 graphics
;*

TRGrp0: mov	al,TIAVal[bp]		; update graphics register 0
	mov	[TIA+TIAGrp0],al
	mov	al,[TIA+TIAGrp1]	; copy Grp1 to Grp1 VDelay
	mov	[VDP1Gr],al
	ret

;*
;* player 1 graphics
;*

TRGrp1: mov	al,TIAVal[bp]		; update graphics register 1
	mov	[TIA+TIAGrp1],al
	mov	al,[TIA+TIAGrp0]	; update the vertical delay registers
	mov	[VDP0Gr],al		; for GRP 0 and ENABL
	mov	al,[TIA+TIAEnabl]
	mov	[VDBlEn],al
	ret

; *
; * now here's some code I don't understand *
; *

xTIAWrap macro
local TWneg,TWret

	cmp	al,240			; went negative ???
	ja	TWneg			;   yes, adjust
	cmp	al,160			; past right side ?
	jb	TWret			;   no
	sub	al,160			;   yes
	jmp	TWret

TWneg:	add	al,160			; adjust
TWret:
	endm

TIAWrap macro
local TWneg,TWret

	cmp	al,240			; went negative ???
	ja	TWneg			;   yes, adjust
	cmp	al,160			; past right side ?
	jb	TWret			;   no
	sub	al,160			;   yes
	jmp	TWret

TWneg:	xor	al,al			; adjust
TWret:
	endm


;*
;* apply horizontal motion (on-screen version)
;*
;* Adjust old locations (those already written)
;* by the amount in the HMxx registers
;*

TRHMov: xor	bx,bx			; bx is offset into registers
					; (start counting at zero)
					; (relavent registers start at 010h)
					; (that's why we add 090h instead of 080h)
					; (to select the "OLD COPY")
TRHMLoop:
	mov	al,bl			; get the register to find...
	add	al,090h			; you move the OLD COPY
	mov	ah,TIA+TIAHmp0[bx]	; this is the amount to move
	sar	ah,4			; preserve sign 
	call	TIAUpdatePosition	; update the position
	inc	bx			; there are 5 to do.
	cmp	bx,5
	jne	TRHMLoop
	call	TIASortBuffer		; order may have been compromised
	ret

TIAUpdatePosition:
	push	ax
	push	bp
	mov	bp,offset TIABuffer
TIAUP2: 
	cmp	byte ptr TIAClock[bp],TIAEnd	; check at the end
	je	TIAUP1
	add	bp,4
	cmp	TIAReg-4[bp],al		; check if found the added one
	jne	TIAUP2
	sub	bp,4			; bp points to it
	mov	al,TIAClock[bp]
	sub	al,ah			; add the offset to it
	TIAWrap
	mov	TIAClock[bp],al
TIAUP1: pop	bp
	pop	ax
	ret


;*
;* apply horizontal motion (off-screen version)
;*

TRHmvB: mov	bx,0
TRHMB1: mov	ah,TIA+TIAHmp0[bx]	; get the adjustment
	sar	ah,4			; preserve sign
	mov	al,TIA+TIAResp0[bx]
	sub	al,ah			; adjust it !
	TIAWrap
	mov	TIA+TIAResp0[bx],al
	inc	bx
	cmp	bx,5
	jne	TRHMB1
	ret

;*
;* Set register = clock value
;*

TRSave: mov	bl,TIAReg[bp]		; bx = offset to register
	mov	al,TIAClock[bp]		; ax = clock
	mov	TIA[bx],al
	ret
        


; *****************************************************************************
;
;			   Ball handling code
;
; *****************************************************************************

TRBall:					; ok , we've found a ball draw.....
	mov	bl,[TIA+TIAVDelbl]	; look at vertical ball delayed
	mov	al,[TIA+TIAEnabl]	; is the ball enabled flag (normal)
	test	bl,1
	jz	TRBBall2
	mov	al,[VDBlEn]		; is the ball enabled flag (delayed)
TRBBall2:
	test	al,2			; test if the ball is enabled....
	jz	TRBNoDraw

	mov	bl,TIAClock[bp]		; get the clock value
	xor	bh,bh			; bx offset to clock
	add	bx,offset TIADisplay	; bx points to ball start in line
	mov	al,[TIA+TIACtrlPf]	; al (b5,b4) are the size
	mov	ah,TGBall		; ah is the ball bit
	call	TIASolidObject

TRBNoDraw:
	mov	al,TIAClock[bp]		; update RESBl counter with clock
	mov	[TIA+TIAResbl],al	; so its drawn on the next line
	mov	al,TIAReg[bp]		; register that was written....
	test	al,128			; if bit 7 is clear (new Res...)
	jnz	TNret
	or	al,128
	call	TIAInvalidate		; invalidate old copies
TNret:	ret

; *****************************************************************************
;
;		       Missile handling code
;
;	On entry	BP Points to the missile record (clock/addr/data/0)
;
; *****************************************************************************

TRMiss:					; ok , we've found a missile draw....
	mov	bl,TIAReg[bp]		; bx = 0 if m0,bx = 1 if m1
	and	bx,1

	mov	al,TIA+TIAResmp0[bx]	; if its locked to the player
	test	al,2			; don't do anything at all !
	jnz	TNret

	mov	al,TIA+TIAEnam0[bx]	; get the enable flag
	test	al,2			; if zero,don't draw
	jz	TRMNoDraw

	mov	al,TIA+TIANuSiz0[bx]	; get the missile size
	mov	ah,TGMissile0		; and the pixel to set
	cmp	bl,0			; which is different for the missiles !
	jz	TGMCDraw
	mov	ah,TGMissile1
TGMCDraw:
	push	bx
	mov	bl,TIAClock[bp]		; get clock value (bh already 0)
	add	bx,offset TIADisplay	; bx points to ball start in line
	call	TIASolidObject		; draw the object .....
	pop	bx
TRMNoDraw:
	mov	al,TIAClock[bp]		; update RESm# counter with clock
	mov	TIA+TIAResm0[bx],al	; so its drawn on the next line
	mov	al,TIAReg[bp]		; register that was written....
	test	al,128			; if bit 7 is clear (new Res...)
	jnz	TGret
	or	al,128
	call	TIAInvalidate		; invalidate old copies
TGret:	ret

; *****************************************************************************
;
;	look for the first item in TIABuffer (BP) where Register = al
;	and mark it invalid
;
; *****************************************************************************

TIAInvalidate:
	push	bp
TIAI1:	mov	ah,TIAClock[bp]		; check if finished
	cmp	ah,TIAEnd
	je	TIAI2
	cmp	al,TIAReg[bp]		; if found, mark it
	je	TIAIMark
	add	bp,4			; do next until end
	jmp	TIAI1
TIAIMark:				; mark it invalid.
	mov	byte ptr TIAClock[bp],TIAInvalid
TIAI2:
	pop	bp
	ret

; *****************************************************************************
;
;    Draw solid object 1,2,4,8 clocks wide at address BX (ptr into display)
;    bit to set in AH, Size register in AL
;
; *****************************************************************************

TIASolidObject:
	and	al,030h			; mask out bits other than size
	jnz	TIASONot1
	or	[bx],ah			; set the bit
	ret
TIASONot1:
	push	cx
	mov	cl,ah			; cx = word version
	mov	ch,ah
	or	[bx],cx			; 2 clocks
	cmp	al,010h
	je	TSRet
	or	2[bx],cx		; 4 clocks
	cmp	al,020h
	je	TSRet
	or	4[bx],cx		; 8 clocks
	or	6[bx],cx
TSRet:  
	pop	cx
	ret
        

; *****************************************************************************
;
;				  Draw Player
;
;	On entry	BP Points to the player record (clock/addr/data/0)
;
; *****************************************************************************


TRPlyr:
	push	cx			; ok , we've found a player draw....
	mov	bl,TIAReg[bp]		; bx = 0 if p0, bx = 1 if p1
	and	bx,1

	mov	ah,TGPlayer0		; and the pixel to set
	cmp	bl,0			; which is different for the players !
	jz	TGPCDraw
	mov	ah,TGPlayer1
TGPCDraw:
	mov	al,TIA+TIANuSiz0[bx]	; size in al
	mov	cl,TIAReg[bp]		; if its a +64 write always size 0
	test	cl,64			; (we're doing a copied player from below)
	jz	TGPCNoCopy
	xor	al,al
TGPCNoCopy:
	mov	ch,TIA+TIAGrp0[bx]	; graphic in ch
	mov	cl,TIA+TIAVDelp0[bx]	; if vertical delay set
	test	cl,1
	jz	TGPCNoVDelay
	mov	ch,VDP0Gr[bx]		; use the vertical delay graphic
TGPCNoVDelay:
	mov	cl,TIA+TIARefP0[bx]	; reflection in cl
	push	bx
	mov	bl,TIAClock[bp]		; get clock value (bh already 0)
	add	bx,offset TIADisplay	; bx points to player start in line

	push	si
	call	TIAGraphObject		; call the graph object routine
	pop	si
	pop	bx

	mov	al,TIAReg[bp]		; if its a copy draw....
	test	al,64			; (e.g. bit 6 is set)
	jnz	TRPNoSetRes		; don't set RESP# from the clock

	mov	al,TIAClock[bp]		; update RESp# counter with clock
	mov	TIA+TIAResp0[bx],al	; so its drawn on the next line

; *** HMMMM... ***

	mov	ah,TIA+TIAResmp0[bx]	; if missile attached to player
	test	ah,2
	jz	TRPNoSetRes
	add	al,4			; missile at centre of player.
	mov	TIA+TIAResm0[bx],al

TRPNoSetRes:
	mov	al,TIAReg[bp]		; register that was written....
	test	al,128			; if bit 7 is clear (new Res...)
	jnz	TRPret
	or	al,128
	call	TIAInvalidate		; invalidate old copies
TRPret:
	pop	cx
	ret

; *****************************************************************************
;
;	 Draw player graphic CH in size/copy AL at screen at BX.
;	 CL = Reflection Flag,AH is bit to set
;
; *****************************************************************************


TIAGraphObject:
	and	al,7			; only required bits from Graphic
	jnz	TGODifferent		;   if anything weird...
TGOStd: 
	cmp	ch,0			; do standard
	jz	TGORet			;   if zero, do nothing
	test	cl,8			; reflected ?
	jnz	TGORef			;   yes
	BuildForward 0
	BuildForward 1
	BuildForward 2
	BuildForward 3
	BuildForward 4
	BuildForward 5
	BuildForward 6
	BuildForward 7
TGORet: ret
        
TGORef: BuildReverse 0
	BuildReverse 1
	BuildReverse 2
	BuildReverse 3
	BuildReverse 4
	BuildReverse 5
	BuildReverse 6
	BuildReverse 7
	ret
        

TGODifferent:				; Handle oddities.......
	movzx	esi,al
	jmp	[offset TGODiffTab + esi*2]

TGO3Close:				; 3 Copies,close @ 0,16,32
	call	TGOStd
	mov	al,TIAClock[bp]
	mov	ah,TIAReg[bp]
	mov	cx,ax
	add	al,16
	or	ah,64
	call	TIAInsert
	xchg	ax,cx
	add	al,32
	or	ah,64
	call	TIAInsert
	ret

TGO2Close:				; 2 copies seperated by 16 cycles
	call	TGOStd
	mov	al,TIAClock[bp]
	mov	ah,TIAReg[bp]
	add	al,16
	or	ah,64
	call	TIAInsert
	ret

TGO3Medium:				; 3 copies,medium @ 0,32,64
	call	TGOStd
	mov	al,TIAClock[bp]
	mov	ah,TIAReg[bp]
	mov	cx,ax
	add	al,32
	or	ah,64
	call	TIAInsert
	xchg	ax,cx
	add	al,64
	or	ah,64
	call	TIAInsert
	ret

TGO2Medium:				; 2 copies seperated by 32 cycles
	call	TGOStd
	mov	al,TIAClock[bp]
	mov	ah,TIAReg[bp]
	add	al,32
	or	ah,64
	call	TIAInsert
	ret

TGO2Far:			       ; 2 copies seperated by 64 cycles
	call	TGOStd
	mov	al,TIAClock[bp]
	mov	ah,TIAReg[bp]
	add	al,64
	or	ah,64
	call	TIAInsert
	ret


TGO2Width:
	cmp	ch,0			; do standard
	jz	TGORet			;   if zero, do nothing
	mov	al,ah
	test	cl,8			; reflected ?
	jnz	TGO2Ref			;   yes
	BuildForward2 0
	BuildForward2 1
	BuildForward2 2
	BuildForward2 3
	BuildForward2 4
	BuildForward2 5
	BuildForward2 6
	BuildForward2 7
	ret
        
TGO2Ref:
	BuildReverse2 0
	BuildReverse2 1
	BuildReverse2 2
	BuildReverse2 3
	BuildReverse2 4
	BuildReverse2 5
	BuildReverse2 6
	BuildReverse2 7
	ret

        
TGO4Width:
	cmp	ch,0			; do standard
	jz	TGORet			;   if zero, do nothing
	mov	al,ah
	push	ax
	shl	eax,16
	pop	ax
	test	cl,8			; reflected ?
	jnz	TGO4Ref			;   yes
	BuildForward4 0
	BuildForward4 1
	BuildForward4 2
	BuildForward4 3
	BuildForward4 4
	BuildForward4 5
	BuildForward4 6
	BuildForward4 7
	ret
        
TGO4Ref:
	BuildReverse4 0
	BuildReverse4 1
	BuildReverse4 2
	BuildReverse4 3
	BuildReverse4 4
	BuildReverse4 5
	BuildReverse4 6
	BuildReverse4 7
	ret

