; macros.asm -- macros for z26


;segment declaration macros

.CODESEGMENT macro
_TEXT SEGMENT USE16 DWORD PUBLIC 'CODE'
        ASSUME cs:_TEXT, ds:_TEXT, es:_TEXT
ALIGN 2 
        endm
        
.CEND   macro
_TEXT ENDS
        endm

.DATASEGMENT macro
_TEXT SEGMENT USE16 DWORD PUBLIC 'CODE'
        ASSUME cs:_TEXT, ds:_TEXT, es:_TEXT     ;tiny model -- (cs == ds)
ALIGN 2 
        endm

.DEND   macro
_TEXT ENDS
        endm



;macros for using an external electronic timer (HP 5326B) connected to a parallel port

pport=  0378h

BLIP_HP_HALF macro
IFDEF dotiming
        mov     dx,pport                ; blip the HP timer -- run at half rate
        in      al,dx
        xor     al,1                    ; data bit 0 of parallel port
        out     dx,al
ENDIF   
        endm
        
BLIP_HP_FULL macro
IFDEF dotiming
        mov     dx,pport                ; blip the HP timer -- run at full rate
        mov     al,0
        out     dx,al
        inc     al
        out     dx,al
ENDIF   
        endm

TIMER_ON macro                          ; for time interval measurements -- on
IFDEF dotiming
        mov     al,1
        mov     dx,pport
        out     dx,al
ENDIF
        endm

TIMER_OFF macro                         ; for time interval measurements -- off
IFDEF dotiming
        mov     al,0
        mov     dx,pport
        out     dx,al
ENDIF
        endm


;a keyboard macro

ifpress macro   op1,op2                 ; if key #1 pressed drop bit
        local   M1
        test    [KeyTable+op1],128  ; #2 of ah (128,64,32...1)
        jz      M1
        and     ah,255-op2               ; drop a bit
M1:
        endm


;macros for outputting player graphics

;Forward macros

BuildForward macro op1                  ;note: must be called 8 times in a row
local M1
        rol     ch,1
        jnc     M1
        or      op1[bx],ah
M1:
        endm

BuildForward2 macro op1                 ;note: must be called 8 times in a row
local M1
        rol     ch,1
        jnc     M1
        or      2*op1[bx],ax
M1:
        endm

BuildForward4 macro op1                 ;note: must be called 8 times in a row
local M1
        rol     ch,1
        jnc     M1
        or      4*op1[bx],eax
M1:
        endm
        
        
;Reflected macros       

BuildReverse macro op1                  ;note: must be called 8 times in a row
local M1
        ror     ch,1
        jnc     M1
        or      op1[bx],ah
M1:
        endm

BuildReverse2 macro op1                 ;note: must be called 8 times in a row
local M1
        ror     ch,1
        jnc     M1
        or      2*op1[bx],ax
M1:
        endm

BuildReverse4 macro op1                 ;note: must be called 8 times in a row
local M1
        ror     ch,1
        jnc     M1
        or      4*op1[bx],eax
M1:
        endm
        

; arithmetic macros

;* don't disturb si in these macros!

DoASL macro
        xor     dh,dh
        shl     dx,1                    ; do the shift
        mov     ah,dh                   ; set the carry from the result
        usetest dl                      ; update the Z & N value registers
        endm

DoROL macro
        shr     ah,1
        rcl     dl,1
        rcl     ah,1
        usetest dl
        endm

DoROR macro
        shr     ah,1
        rcr     dl,1
        rcl     ah,1
        usetest dl
        endm

DoLSR macro
        mov     ah,dl                   ; set carry from bit 0 of DL
        and     ah,1
        shr     dl,1                    ; shift it right
        usetest dl                      ; use the result to test
        endm



; *****************************************************************************
; *****************************************************************************
;
;                       6502 Emulation Macros
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;            ALL READING/WRITING DONE VIA READ/WRITE
; *****************************************************************************


read    macro   op1,op2                 ; read memory at #2 to #1
        
        mov     si,op2
        call    [ReadBank]              ; call the bank read function
        mov     op1,byte ptr [si]

        endm
        

readsx  macro   op1,op2                 ; read memory at #2 to #1
                                        ; sign extended
        mov     si,op2
        call    [ReadBank]              ; call the bank read function
        movsx   op1,byte ptr [si]

        endm

read16  macro op1,op2
        mov     si,op2
        call    [ReadBank]
        mov     op1,word ptr [si]
        endm


write   macro   op1,op2                 ; write #1 to memory at #2
        mov     si,op2                  ; set address
        mov     [WByte],op1             ; set data
        call    [WriteBank]
        endm
        
        
rewrite macro   op1                     ;rewrite byte in #1
        mov     byte ptr [si],op1       ;assume si has the address
        endm


zread   macro   op1,op2                 ; zero page read
        mov     si,op2
        call    ReadHardwarePage0
        mov     op1,[si]
        endm
        

zread16 macro   op1,op2                 ; 16-bit zero page read
        mov     si,op2
        call    ReadHardwarePage0
        mov     op1,[si]
        endm


zwrite  macro   op1,op2                 ; zeropage write
        mov     si,op2                  ; set address
        mov     [WByte],op1             ; set data
        call    WriteHardwarePage0      ; and write
        endm


fetch   macro   op1
        read    op1,bp
        inc     bp
        endm


fetchsx macro   op1
        readsx  op1,bp
        inc     bp
        endm


fetch16 macro   op1
        read16  op1,bp
        add     bp,2
        endm


IFDEF memcheats
absolute macro
        fetch16 bx
        endm
ELSE
absolute macro                          ; fetch absolute address to bx
        fetch   bl
        fetch   bh
        endm
ENDIF   


zeropage macro                          ; fetch zero page to bx
        fetch   bl
        xor     bh,bh
        endm


_index macro    op1
        add     bx,word ptr[op1]        ;this is not a cheat
        endm


indexx  macro                           ; x index
        _index  RX
        endm
        

indexy  macro                           ; y index
        _index  RY
        endm


pagechange macro
        local   M1
        
        cmp     dh,bh                   ; page changed
        jz      M1
        inc     [RClock]
        inc     [RCycles]
M1:
        endm

IFDEF memcheats
readaddress macro
        xor     bh,bh
        read16  dx,bx
        mov     bx,dx
        endm
ELSE
readaddress macro                       ; read data in bx -> bx
        xor     bh,bh                   ; must be in page zero
        read    dl,bx
        inc     bl
        read    dh,bx
        mov     bx,dx
        endm
ENDIF   


absolutex macro                         ; absolute,x EAC
        absolute
        mov     dx,bx
        indexx
        endm


absolutey macro                         ; absolute,y EAC
        absolute
        mov     dx,bx
        indexy
        endm


zeropagex macro                         ; zeropage,x EAC
        zeropage
        add     bl,[RX]
        endm


zeropagey macro                         ; zeropage,y EAC
        zeropage
        add     bl,[RY]
        endm


indirectx macro                         ; (indirect,x) EAC
        zeropage
        indexx
        readaddress
        endm


indirecty macro                         ; (indirect),y EAC
        zeropage
        readaddress
        mov     dx,bx
        indexy
        endm


relative macro                          ; sign extend fetch byte -> dx
        fetchsx dx
        endm


useztest macro  op1                     ; use #1 to test Z
        mov     [RZTest],op1
        endm
        

usentest macro  op1                     ; use #1 to test N      
        mov     [RNTest],op1
        endm
        

usetest macro   op1                     ; use #1 to test both N and Z (normal)
        useztest op1
        usentest op1
        endm

; load CPU registers

LoadRegs macro
	mov	ax,word ptr [RA]	; mov al,[RA]; mov ah,[RCarry]
	mov	cl,[RS]
	mov	bp,[RPC]
	endm

; save CPU registers

SaveRegs macro
	mov	word ptr [RA],ax	; mov [RA],al; mov [RCarry],ah
	mov	[RS],cl
	mov	[RPC],bp
	endm
