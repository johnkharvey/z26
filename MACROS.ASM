; macros.asm -- macros for z26


;segment declaration macros

;*
;* for .com file use tiny model
;*

IFDEF comfile
.CODESEGMENT macro
_TEXT SEGMENT USE16 PARA PUBLIC 'CODE'
        ASSUME cs:_TEXT, ds:_TEXT, es:_TEXT
ALIGN 16
        endm
        
.CEND   macro
_TEXT ENDS
        endm

.DATASEGMENT macro
_TEXT SEGMENT USE16 PARA PUBLIC 'CODE'
        ASSUME cs:_TEXT, ds:_TEXT, es:_TEXT     ;tiny model -- (cs == ds)
ALIGN 16
        endm

.DEND   macro
_TEXT ENDS
        endm
ENDIF

;*
;* for .exe file use small model
;*

IFNDEF comfile
.CODESEGMENT macro
_TEXT SEGMENT USE16 PARA PUBLIC 'CODE'
        ASSUME cs:_TEXT, ds:_DATA, es:_DATA
ALIGN 16
        endm
        
.CEND   macro
_TEXT ENDS
        endm

.DATASEGMENT macro
_DATA SEGMENT USE16 PARA PUBLIC 'DATA'
        ASSUME cs:_TEXT, ds:_DATA, es:_DATA     ;small model
ALIGN 16
        endm

.DEND   macro
_DATA ENDS
        endm
ENDIF


;*
;* macro to align entry points of code
;*

ALIGN_ENTRY macro

ALIGN 4

	endm

;*
;* a keyboard macro
;*

ifpress macro   op1,op2                 ; if key #1 pressed drop bit
        local   M1
        test    [KeyTable+op1],128  ; #2 of ah (128,64,32...1)
        jz      M1
        and     ah,255-op2               ; drop a bit
M1:
        endm


