; The Thomas Jentzsch linear screen copy routinen (32-bit)
; all code optimized for original P5 (without MMX)

;*
;* fast linear copy screen (160 pixels)
;*

PUBLIC _CFDoLinearCopy
; abcs -> abcd (with compare)
_CFDoLinearCopy:
        pushad

        mov     esi,[_emu_pixels]
        mov     ebp,[_emu_pixels_prev]
        mov     edi,[_screen_pixels]
        mov     ecx,40

CFDLCloop:                      ; u v   execution pipes
        mov     eax,[esi]       ; 1
        add     esi,4           ;   1
        cmp     eax,[ebp]       ; 1
        je      CFDLCnoWrite    ;   1
        mov     [edi],eax       ; 1
CFDLCnoWrite:
        add     edi,4           ; 1
        add     ebp,4           ;   1
        dec     ecx             ; 1
        jnz     CFDLCloop       ;   1
                                ; 4-5   total cycles
; 50% average: 180 cycles (+extra penalties due to branch mispredictions)
        popad
        ret


PUBLIC _CDoLinearCopy
; abcd -> aabbccdd (with compare)
_CDoLinearCopy:
        pushad

        mov     esi,[_emu_pixels]
        mov     edi,[_screen_pixels]
        mov     ebp,[_emu_pixels_prev]
        mov     ecx,40

CDLCLoop:                       ; u v   execution pipes
        mov     eax,[esi]       ; 1     or more, depends on cache
        add     esi,4           ;   1
        cmp     eax,[ebp]       ; 1     or more, depends on cache
        jne     CDLCcopy        ;   1
        add     ebp,4           ; 1
        add     edi,8           ;   1
        dec     ecx             ; 1
        jnz     CDLCLoop        ;   1
                                ; 4     total cycles
        popad
        ret

CDLCcopy:
        mov     edx,eax         ; 1
        mov     al,ah           ;   1
        shl     eax,16          ; 1     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        mov     ebx,edx         ;   1
        shr     ebx,16          ; 1
        mov     dh,dl           ;   1
        and     edx, 0000ffffh  ; 1
        add     ebp,4           ;   1
        or      eax,edx         ; 1
        mov     edx,ebx         ;   1
        mov     bl,bh           ; 1
        mov     dh,dl           ;   1
        shl     ebx,16          ; 1
        and     edx, 0000ffffh  ;   1
        mov     [edi],eax       ; 1
        or      ebx,edx         ;   1
        mov     [edi+4],ebx     ; 1
        add     edi,8           ;   1
        dec     ecx             ; 1
        jnz     CDLCLoop        ;   1
                                ;12     total cycles
; 50% average: 320 cycles (+extra penalties due to branch mispredictions)
        popad
        ret


PUBLIC _CDoWideLinearCopy
; abcd -> aaaabbbbccccdddd (with compare)
_CDoWideLinearCopy:
        pushad

        mov     esi,[_emu_pixels]
        mov     ebp,[_emu_pixels_prev]
        mov     edi,[_screen_pixels]
        mov     ecx,40

CDWLCLoop:                      ; u v   execution pipes
        mov     eax,[esi]       ; 1     or more, depends on cache
        add     esi,4           ;   1
        cmp     eax,[ebp]       ; 1
        jne     CDWLCcopy       ;   1   + extra penalties due to branch mispredictions
        add     ebp,4           ; 1
        add     edi,16          ;   1
        dec     ecx             ; 1
        jnz     CDWLCLoop       ;   1
                                ; 4     total cycles
        popad
        ret

CDWLCcopy:
        mov     edx,eax         ; 1     abcd
        mov     ah,al           ;   1   a1
        mov     ebx,eax         ; 1     a2
        mov     dl,dh           ;   1   b1
        shl     eax,16          ; 1     a4
        and     ebx,0000ffffh   ;   1   a5
        or      eax,ebx         ; 1     a6
        mov     ebx,edx         ;   1   b2
        mov     [edi],eax       ; 1     a7
        mov     eax,edx         ;   1   b3
        shl     ebx,16          ; 1     b4
        and     eax,0000ffffh   ;   1   b5
        shr     edx,16          ; 1     cd
        or      eax,ebx         ;   1   b6
        mov     [edi+4],eax     ; 1     b7
        mov     eax,edx         ;   1   cd
        mov     ah,al           ; 1     c1
        mov     ebx,eax         ;   1   c2
        shl     eax,16          ; 1     c4
        and     ebx,0000ffffh   ;   1   c5
        mov     dl,dh           ; 1     d1
        or      eax,ebx         ;   1   c6
        mov     ebx,edx         ; 1     d2
        and     edx,0000ffffh   ;   1   d5
        shl     ebx,16          ; 1     d4
        mov     [edi+8],eax     ;   1   c7
        or      edx,ebx         ; 1     d6
        add     ebp,4           ;   1   -
        mov     [edi+12],edx    ; 1     d7

        add     edi,16          ;   1   -
        dec     ecx             ; 1     -
        jnz     CDWLCLoop       ;   1   -
                                ;18     total cycles
; 50% average: 440 cycles (+extra penalties due to branch mispredictions)
        popad
        ret


PUBLIC _FDoLinearCopy
; abcs -> abcd (with compare)
_FDoLinearCopy:
        push    esi
        mov     esi,[_emu_pixels]
        push    edi
        mov     edi,[_screen_pixels]
        push    ecx
        mov     ecx,40

        rep movsd               ;13 + n
; loop total: 53 cycles
        pop     ecx
        pop     edi
        pop     esi
        ret


PUBLIC _DoLinearCopy
; abcd -> aabbccdd
_DoLinearCopy:
        pushad
        mov     esi,[_emu_pixels]
        mov     edi,[_screen_pixels]
        mov     ecx,40

DLCLoop:                        ; u v   execution pipes
        mov     eax,[esi]       ; 1     or more, depends on cache
        add     esi,4           ;   1
        mov     edx,eax         ; 1
        mov     al,ah           ;   1
        shl     eax,16          ; 1     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        mov     ebx,edx         ;   1
        shr     ebx,16          ; 1
        mov     dh,dl           ;   1
        and     edx, 0000ffffh  ; 1
        add     ebp,4           ;   1
        or      eax,edx         ; 1
        mov     edx,ebx         ;   1
        mov     bl,bh           ; 1
        mov     dh,dl           ;   1
        shl     ebx,16          ; 1
        and     edx, 0000ffffh  ;   1
        mov     [edi],eax       ; 1
        or      ebx,edx         ;   1
        mov     [edi+4],ebx     ; 1
        add     edi,8           ;   1
        dec     ecx             ; 1
        jnz     DLCLoop         ;   1
                                ;11     total cycles
; loop total: 440 cycles
        popad
        ret


PUBLIC _DoWideLinearCopy
; abcd -> aaaabbbbccccdddd
_DoWideLinearCopy:
        pushad

        mov     esi,[_emu_pixels]
        mov     edi,[_screen_pixels]
        mov     ecx,40

DWLCLoop:                       ; u v   execution pipes/cycles
        mov     eax,[esi]       ; 1     or more, depends on cache
        add     esi,4           ;   1   -
        mov     edx,eax         ; 1     abcd
        and     eax,0000ffffh   ;   1   ab1
        mov     ebx,eax         ; 1     ab2
        mov     ah,al           ;   1   a1
        mov     ebp,eax         ; 1     a2
        add     edi,16          ;   1   -
        shl     eax,16          ; 1     a3
        mov     bl,bh           ;   1   b1
        or      eax,ebp         ; 1     a4
        mov     ebp,ebx         ;   1   b2
        shl     ebx,16          ; 1     b3
        mov     [edi-16],eax    ;   1   a5
        shr     edx,16          ; 1     cd1
        or      ebp,ebx         ;   1   b4
        mov     eax,edx         ; 1     cd2
        mov     dh,dl           ;   1   c1
        mov     [edi-12],ebp    ; 1     b5
        mov     ebx,edx         ;   1   c2
        shl     edx,16          ; 1     c3
        mov     al,ah           ;   1   d1
        mov     ebp,eax         ; 1     d2
        or      edx,ebx         ;   1   c4
        shl     eax,16          ; 1     d3
        mov     [edi-8],edx     ;   1   c5
        or      eax,ebp         ; 1     d4
        dec     ecx             ;   1   -
        mov     [edi-4],eax     ; 1     c5
        jnz     DWLCLoop        ;   1   -
                                ;15     total cycles
        popad
        ret
; loop total: 600 cycles
        popad
        ret
