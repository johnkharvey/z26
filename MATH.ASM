;*
;* Paul Robson's original math routines
;*
;* we're only using the decimal stuff for now...
;*


IFDEF compile_old_code

; *****************************************************************************
;          CMP code. Uses the Subtract code. AL = acc,BX points to data
; *****************************************************************************
mDoCmp:  mov     dl,al                   ; save acc on stack
        push    dx
        mov     ah,1                    ; cmp always sets carry
        call    mDoSbc                   ; does subtract
;        usetest al                      ; put the result in the flags
        pop     dx                      ; restore the accumulator
        mov     al,dl
        ret
; *****************************************************************************
;        SBC code. AL is accumulator,AH is carry bit,BX points to data
; *****************************************************************************
mDoSbc:  mov     dh,al                           ; save acc in dh
;        read    dl,bx                           ; dl is the value to subtract
        clc                                     ; clear the carry bit
        cmp     ah,0                            ; if carry is set,don't borrow
        jnz     NoBorrow
        stc                                     ; this is set if the carry is 0
NoBorrow:
        mov     ah,0                            ; clear the carry bit
        sbb     al,dl                           ; do the subtraction
        jc      XBorrow                         ; if not borrowed,set carry
        inc     ah
XBorrow:mov     bh,0                            ; bh is overflow
        mov     bl,dl                           ; are the signs of ops the same ?
        xor     bl,dh
        test    bl,128                          ; if they are the same no ov
        jz      SBCExit
        mov     bl,dh                           ; if sign of result different
        xor     bl,al                           ; to original AC
        test    bl,128
        jz      SBCExit
        inc     bh                              ; Set the overflow flag
SBCExit:mov     [FOver],bh
	usetest	al
        ret

; *****************************************************************************
;        ADC code. AL is accumulator,AH is carry bit,BX points to data
; *****************************************************************************
mDoAdc:  mov     dh,al                           ; dh is the value to add to
;        read    dl,bx                           ; dl is the value to add
        xor     dh,dl                           ; dh top bit 0 if same sign
        add     al,dl                           ; do the actual add
Add2:   jnc     AddNoCarry
                                                ; we got a carry out this time
        add     al,ah                           ; add the old carry in.
RetSetCarry:
        mov     ah,1                            ; new carry equals 1
        jmp     CheckOverflow
AddNoCarry:                                     ; that didn't produce a carry
        add     al,ah                           ; add the old carry in
        jc      RetSetCarry                     ; if that caused a carry set it
CheckOverflow:
        mov     bl,0                            ; dl = overflow flag
        test    dh,128                          ; if inputs were different
        jnz     AdcExit                         ; signs,no overflow
        xor     dl,al                           ; if same,and result is different
        test    dl,128
        jz      AdcExit
        inc     bl                              ; set the overflow flag
AdcExit:mov     [FOver],bl
	usetest	al
        ret

ENDIF

; *****************************************************************************
;    ADC Decimal code. AL is accumulator,AH is carry bit,BX points to data
; *****************************************************************************

mADCBCD: 
	push    bx
	push	cx
	push	dx
	push	di

        mov     di,offset TIABCDToDec           ; si is the BCD->Dec conv.
;        read    dl,bx
        mov     bl,dl
        xor     bh,bh
        mov     cl,[di+bx]                      ; cl = one to add
        mov     bl,al
        mov     al,[di+bx]                      ; al is the other
        add     al,cl                           ; add them together
        add     al,ah                           ; add the carry bit
        xor     ah,ah                           ; and clear it.
        cmp     al,100                          ; if < 100 no carry
        jb      ABNoCarry
        inc     ah                              ; set the carry
        sub     al,100
ABNoCarry:
        mov     bl,al                           ; convert it back
        mov     di,offset TIADecToBCD
        mov     al,[di+bx]

        pop     di
	pop	dx
	pop	cx
	pop	bx
	usetest	al
        ret

; *****************************************************************************
;    SBC Decimal code. AL is accumulator,AH is carry bit,BX points to data
; *****************************************************************************

mSBCBCD: 
	push    bx
	push	cx
	push	dx
	push	di

        mov     di, offset TIABCDToDec          ; si is the BCD->Dec conv.
;        read    dl,bx
        mov     bl,dl
        xor     bh,bh
        mov     cl,[di+bx]                      ; cl = value to subtract
        mov     bl,al
        mov     al,[di+bx]                      ; al is the other
        sub     al,cl                           ; subtract value from acc
        sub     al,1                            ; subtract 1 and add the carry
        add     al,ah                           ; bit - e.g. a borrow.
        mov     ah,1                            ; carry defaults to 1
        cmp     al,100                          ; if < 100 no borrow has
        jb      SBNoCarry                       ; occurred
        xor     ah,ah                           ; clear the carry for borrow
        add     al,100                          ; readjust it.
SBNoCarry:
        mov     bl,al                           ; convert it back
        mov     di,offset TIADecToBCD
        mov     al,[di+bx]

        pop     di
	pop	dx
	pop	cx
	pop	bx
	usetest	al
        ret

.CEND
.DATASEGMENT

TIABCDToDec db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 db 10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
 db 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35
 db 30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45
 db 40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55
 db 50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65
 db 60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75
 db 70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85
 db 80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95
 db 90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105
 db 100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115
 db 110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125
 db 120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135
 db 130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145
 db 140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155
 db 150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165
;
TIADecToBCD db 0,1,2,3,4,5,6,7,8,9,16,17,18,19,20,21
 db 22,23,24,25,32,33,34,35,36,37,38,39,40,41,48,49
 db 50,51,52,53,54,55,56,57,64,65,66,67,68,69,70,71
 db 72,73,80,81,82,83,84,85,86,87,88,89,96,97,98,99
 db 100,101,102,103,104,105,112,113,114,115,116,117,118,119,120,121
 db 128,129,130,131,132,133,134,135,136,137,144,145,146,147,148,149
 db 150,151,152,153,0,1,2,3,4,5,6,7,8,9,16,17
 db 18,19,20,21,22,23,24,25,32,33,34,35,36,37,38,39
 db 40,41,48,49,50,51,52,53,54,55,56,57,64,65,66,67
 db 68,69,70,71,72,73,80,81,82,83,84,85,86,87,88,89
 db 96,97,98,99,100,101,102,103,104,105,112,113,114,115,116,117
 db 118,119,120,121,128,129,130,131,132,133,134,135,136,137,144,145
 db 146,147,148,149,150,151,152,153,0,1,2,3,4,5,6,7
 db 8,9,16,17,18,19,20,21,22,23,24,25,32,33,34,35
 db 36,37,38,39,40,41,48,49,50,51,52,53,54,55,56,57
 db 64,65,66,67,68,69,70,71,72,73,80,81,82,83,84,85
;

.DEND
.CODESEGMENT
