                processor       6502
                include         vcs.h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Zeropage variables declaration
;
                SEG.U   Variables
                ORG     $a0
Val1            ds      1
Val2            ds      1
Disp1           ds      5
Disp2           ds      5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Program initialization
;
                SEG     Code
                ORG     $d000
                .byte   00

                ORG     $d100

Ziffern         .byte   $77,$22,$77,$77,$55,$77,$44,$77,$77,$77,$77,$77,$77,$66,$77,$77
                .byte   $55,$66,$11,$11,$55,$44,$44,$11,$55,$55,$55,$55,$44,$55,$44,$44
                .byte   $55,$22,$77,$33,$77,$77,$77,$11,$77,$77,$77,$66,$44,$55,$66,$66
                .byte   $55,$22,$44,$11,$11,$11,$55,$11,$55,$11,$55,$55,$44,$55,$44,$44
                .byte   $77,$77,$77,$77,$11,$77,$77,$11,$77,$77,$55,$77,$77,$66,$77,$44
                ;       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F

                ALIGN   256

Cart_Init:
                sei
                cld                     

Common_Init:
                ldx     #$28            ; Clear the TIA registers ($04-$2C)
                lda     #$00
TIAClear:
                sta     $04,X
                dex
                bpl     TIAClear

                txs                     
 
IOClear:
                sta     SWBCNT          
                sta     SWACNT          

                lda     $d000
                sta     Val1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Main program loop
;
NewFrame:
                lda     #$02
                sta     WSYNC           
;                sta     VBLANK          
                sta     VSYNC           
                sta     WSYNC           
                sta     WSYNC
                sta     WSYNC
                lda     #$00
                sta     VSYNC           

                lda     #43             ; Vblank for 37 lines
                sta     TIM64T          

                LDX     #$00
                LDA     Val1
                AND     #$F0
                LSR
                LSR
                LSR
                LSR
CD1:            TAY
                LDA     Ziffern,Y
                AND     #$F0
                STA     Disp1,X
                TYA
                CLC
                ADC     #$10
                INX
                CPX     #$05
                BNE     CD1

                LDX     #$00
                LDA     Val1
                AND     #$0F
CD2:            TAY
                LDA     Ziffern,Y
                AND     #$0F
                ORA     Disp1,X
                STA     Disp1,X
                TYA
                CLC
                ADC     #$10
                INX
                CPX     #$05
                BNE     CD2

                LDX     #$00
                LDA     Val2
                AND     #$F0
                LSR
                LSR
                LSR
                LSR
CD3:            TAY
                LDA     Ziffern,Y
                AND     #$F0
                STA     Disp2,X
                TYA
                CLC
                ADC     #$10
                INX
                CPX     #$05
                BNE     CD3

                LDX     #$00
                LDA     Val2
                AND     #$0F
CD4:            TAY
                LDA     Ziffern,Y
                AND     #$0F
                ORA     Disp2,X
                STA     Disp2,X
                TYA
                CLC
                ADC     #$10
                INX
                CPX     #$05
                BNE     CD4

VblankLoop:
                lda     INTIM
                bne     VblankLoop      
                sta     WSYNC           
                sta     VBLANK          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DisplayStart:
                nop
                nop
                nop
                nop
                LDA     #$C4            ;blue
                STA     COLUBK
                LDA     #$0e            ;white
                STA     COLUP0
                STA     COLUP1
                STA     RESP0
                STA     RESP1
                STA     WSYNC
                LDX     #$00
D1:             LDA     Disp1,X
                STA     GRP0
                LDA     Disp2,X
                STA     GRP1
                STA     WSYNC
                STA     WSYNC
                INX
                CPX     #$05
                BNE     D1

                LDA     #$00
                STA     GRP0
                STA     GRP1
                LDX     #182
D2:             STA     WSYNC
                DEX
                BNE     D2

                lda     #$02
                sta     VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OverscanStart:  lda     #35             ;skip 30 lines (overscan)
                sta     TIM64T

                lda     INPT4
                and     #$80
                bne     OverscanLoop
WaitLoop:
                lda     INPT4
                and     #$80
                beq     WaitLoop

                ldx     #$04
                lda     $f000,x
                lda     $fff8
                ldx     15
Wait1000:
                sta     WSYNC
                dex
                bpl     Wait1000

                ldx     $d000
                inx
                cpx     #61
                beq     Restart
                stx     $fa
                jmp     $f800
Restart:
                inc     Val2
                jmp     $f80a

OverscanLoop:
                lda     INTIM
                bne     OverscanLoop    
                sta     WSYNC           

                jmp     NewFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Set up the 6502 interrupt vector table
;
                ORG     $dffc
Reset           .word   Cart_Init
IRQ             .word   Cart_Init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ORG     $f000
                .word   Cart_Init
                .byte   $0d,$08,$00,$00,$b6,$00

                ORG     $f010
                .byte     $00,$04,$08,$0c,$10,$14,$18,$1c,$01,$05,$09,$0d
                .byte     $11,$15,$19,$1d,$02,$06,$0a,$0e,$12,$16,$1a,$1e

                ORG     $f0ff
                .byte   $ff


Q               SET     1

                REPEAT  60
                .byte   Q
                ds      $1fff
                .word   Cart_Init
                .byte   $0d,$01,$00,Q,$20,$00
                ds      10
                .byte   $00
                ds      $ec
                .byte   $ff
Q               SET     Q+1
                REPEND

                END

