;*
;* fast linear copy screen (160 pixels)
;*

PUBLIC _CFDoLinearCopy

_CFDoLinearCopy:
	pushad
        mov     esi,[_emu_pixels]
        mov     edi,[_screen_pixels]
        mov     ebp,[_emu_pixels_prev]

	mov	ecx,40
CFDLCloop:
        mov     eax,[esi]
        cmp     eax,[ebp]
        je      CFDLCnoWrite
        mov     [edi],eax
CFDLCnoWrite:
        add     esi,4
        add     edi,4
        add     ebp,4
        dec     ecx
        jnz     CFDLCloop

	popad
	ret

;*
;* The Thomas Jentzsch linear screen copy routine (32-bit)
;*        

PUBLIC _CDoLinearCopy

_CDoLinearCopy:
        pushad

        mov     ecx,40
        mov     esi,[_emu_pixels]
        mov     edi,[_screen_pixels]
	sub	edi,8
        mov     ebp,[_emu_pixels_prev]
        sub     ebp,4

; optimized for original P5 (without MMX)

CDLCLoop:                       ; u v   execution pipes
        mov     eax,[esi]       ; 1     or more, depends on cache
        add     ebp,4
        cmp     eax,[ebp]
        jne     CDLCcopy
        add     esi,4
        add     edi,8
        dec     ecx
        jnz     CDLCLoop
        popad
        ret
CDLCcopy:
        add     edi,8           ;   1
        mov     edx,eax         ; 1
        mov     al,ah           ;   1
        shl     eax,16          ; 2     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        mov     dh,dl           ;   1
        mov     bx,[esi+2]      ; 1     or more, depends on cache
        mov     ax,dx           ;   1
        mov     edx,ebx         ; 1
        mov     bl,bh           ;   1
        mov     [edi],eax       ; 3     segment and instruction size prefix (pairs in u-pipe only, two extra decode cycles)
        mov     dh,dl           ;   1
        shl     ebx,16          ; 2     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        add     esi,4           ;   1
        mov     bx,dx           ; 1
        dec     ecx             ;   1
        mov     [edi+4],ebx     ; 3     segment and instruction size prefix (pairs in u-pipe only, two extra decode cycles)
        jnz     CDLCLoop        ;   1
                                ;15     total cycles
        popad

	ret


PUBLIC _CDoWideLinearCopy

_CDoWideLinearCopy:
        pushad

        mov     ecx,80
        mov     esi,[_emu_pixels]
        mov     edi,[_screen_pixels]
	sub	edi,8
        mov     ebp,[_emu_pixels_prev]
        sub     ebp,2

CDWLCLoop:                      ; u v   execution pipes
        mov     ax,[esi]        ; 1     or more, depends on cache
        add     ebp,2
        cmp     ax,[ebp]
        jne     CDWLCcopy
        add     esi,2
        add     edi,8
        dec     ecx
        jnz     CDWLCLoop
        popad
        ret
CDWLCcopy:
        add     edi,8           ;   1
        mov     edx,eax         ; 1
        mov     ah,al           ;   1
        shl     eax,16          ; 2     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        mov     dh,dl           ;   1
        mov     bl,[esi+1]      ; 1     or more, depends on cache
        mov     ax,dx           ;   1
        mov     edx,ebx         ; 1
        mov     bh,bl           ;   1
        mov     [edi],eax       ; 3     segment and instruction size prefix (pairs in u-pipe only, two extra decode cycles)
        mov     dh,dl           ;   1
        shl     ebx,16          ; 2     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        add     esi,2           ;   1
        mov     bx,dx           ; 1
        dec     ecx             ;   1
        mov     [edi+4],ebx     ; 3     segment and instruction size prefix (pairs in u-pipe only, two extra decode cycles)
        jnz     CDWLCLoop       ;   1
                                ;15     total cycles
        popad

	ret

;*
;* fast linear copy screen (160 pixels)
;*

PUBLIC _FDoLinearCopy

_FDoLinearCopy:
	pushad
        mov     esi,[_emu_pixels]
        mov     edi,[_screen_pixels]

	mov	ecx,40
	rep	movsd

	popad
	ret

;*
;* The Thomas Jentzsch linear screen copy routine (32-bit)
;*        

PUBLIC _DoLinearCopy

_DoLinearCopy:
        pushad

        mov     ecx,40
        mov     esi,[_emu_pixels]
        mov     edi,[_screen_pixels]
	sub	edi,8

; optimized for original P5 (without MMX)

DLCLoop:                        ; u v   execution pipes
        mov     ax,[esi]        ; 1     or more, depends on cache
        add     edi,8           ;   1
        mov     edx,eax         ; 1
        mov     al,ah           ;   1
        shl     eax,16          ; 2     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        mov     dh,dl           ;   1
        mov     bx,[esi+2]      ; 1     or more, depends on cache
        mov     ax,dx           ;   1
        mov     edx,ebx         ; 1
        mov     bl,bh           ;   1
        mov     [edi],eax       ; 3     segment and instruction size prefix (pairs in u-pipe only, two extra decode cycles)
        mov     dh,dl           ;   1
        shl     ebx,16          ; 2     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        add     esi,4           ;   1
        mov     bx,dx           ; 1
        dec     ecx             ;   1
        mov     [edi+4],ebx     ; 3     segment and instruction size prefix (pairs in u-pipe only, two extra decode cycles)
        jnz     DLCLoop         ;   1
                                ;15     total cycles
        popad

	ret


PUBLIC _DoWideLinearCopy

_DoWideLinearCopy:
        pushad

        mov     ecx,80
        mov     esi,[_emu_pixels]
        mov     edi,[_screen_pixels]
	sub	edi,8

DWLCLoop:                       ; u v   execution pipes
        mov     ah,[esi]        ; 1     or more, depends on cache
        add     edi,8           ;   1
        mov     edx,eax         ; 1
        mov     al,ah           ;   1
        shl     eax,16          ; 2     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        mov     dl,dh           ;   1
        mov     bh,[esi+1]      ; 1     or more, depends on cache
        mov     ax,dx           ;   1
        mov     edx,ebx         ; 1
        mov     bl,bh           ;   1
        mov     [edi],eax       ; 3     segment and instruction size prefix (pairs in u-pipe only, two extra decode cycles)
        mov     dl,dh           ;   1
        shl     ebx,16          ; 2     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        add     esi,2           ;   1
        mov     bx,dx           ; 1
        dec     ecx             ;   1
        mov     [edi+4],ebx     ; 3     segment and instruction size prefix (pairs in u-pipe only, two extra decode cycles)
        jnz     DWLCLoop        ;   1
                                ;15     total cycles
        popad

	ret

