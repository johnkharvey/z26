;*
;* z26 sound stuff
;*
;* it's up to the *operating system* to empty the sound queue
;* it's up to the z26 core to fill it up
;*
;
; z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.


.data

SQ_Start label byte		; <-- start clearing here

SQ_Input	dd	1 dup (?)	; point to next avail byte for storing
SQ_Output	dd	1 dup (?)	; point to next avail byte for fetching
SQ_Count	dd	1 dup (?)
SQ_Top	dd	1 dup (?)

SQ_MAX = 4608			; 3072, 1024

SoundQ	db	(SQ_MAX + 2) dup (?)

SQ_End label byte			; <-- finish clearing here

.code

;*
;* Initialize sound queue
;*

Init_SoundQ:
	clear_mem SQ_Start, SQ_End

	mov	[SQ_Input],offset SoundQ	; initialize sound queue stuff
	mov	[SQ_Output],offset SoundQ
	mov	[SQ_Count],0
	mov	[SQ_Top],offset SoundQ + SQ_MAX + 1

	ret

;*
;* routine to get status of sound queue
;*
;* returns:
;*
;*    -1 if sound queue full and no room for more output
;*     0 if there's too much room      (less than 1/2 full)
;*     1 if there's just enough room   (more than 1/2 full)
;*

SQ_Test:
	cmp	[_quiet],0		; doing sound at all?
	jnz	SQ_Just_Right		;   no, pretend queue is *just right*

	cmp	[SQ_Count],SQ_MAX	; sound queue already full?
	jae	SQ_Full			;   yes, don't queue anything
	cmp	[SQ_Count],SQ_MAX/2	; less than 1/2 full?
	jbe	SQ_Empty		;   yes

SQ_Just_Right:
	mov	eax,1			;   no
	ret

SQ_Empty:
	mov	eax,0
	ret

SQ_Full:
	mov	eax,-1
	ret


;*
;* routine to put byte in al in the sound queue
;* always make sure SQ_Count < SQ_MAX before calling
;*

SQ_Store:
	cmp	[_quiet],0		; doing sound at all?
	jnz	SQS_skip_store		;   no, don't store sound byte

;	pushad
;	call	_srv_lock_audio
;	popad

	mov	esi,[SQ_Input]
	mov	[esi],al
	inc	esi
	inc	[SQ_Count]
	cmp	esi,[SQ_Top]
	jb	SQS_done
	mov	esi,offset SoundQ
SQS_done:
	mov	[SQ_Input],esi

;	pushad
;	call	_srv_unlock_audio
;	popad

SQS_skip_store:
	ret


;*
;* routine to put the sound in the sound buffer
;*

PUBLIC _Tia_process

_Tia_process:
	pushad
	mov	eax,[_bufsize]
	cmp	[SQ_Count],eax		; enough sound available?
	ja	Sound_Enough		;   yes

	pushad				;   no, make sure there's enough
	call	_QueueSoundBytes
	popad

Sound_Enough:
	mov	ecx,[_bufsize]		; # of bytes

	mov	edi,[_DMABuf]
	mov	esi,[SQ_Output]

SoundFillLoop:
	mov	al,[esi]
	inc	esi
	cmp	esi,[SQ_Top]
	jb	SF_done
	mov	esi,offset SoundQ
SF_done:mov	[edi],al		; put it in soundblaster buffer
	inc	edi
	dec	ecx			; more room in soundblaster buffer?
	jnz	SoundFillLoop		;   yes, get more

	mov	eax,[_bufsize]
	sub	[SQ_Count],eax
	mov	[SQ_Output],esi
	
SoundBufferBail:
	popad
	ret



;*
;* put a byte in the sound queue
;*

QueueSoundByte:
	call	SQ_Test
	cmp	eax,-1			; sound queue already full?
	je	SoundQueueFull		;   yes, don't queue anything

	call	KidVid_Sound_Byte	;   no, get kidvid sample
	push	eax
	call	TIA_Sound_Byte		; get TIA sample
	pop	ebx			; kidvid sample

        add     eax,ebx			; mix the samples
        shr     eax,1

	call	SQ_Store		; put it in the sound queue

SoundQueueFull:
	ret

;*
;* put sound bytes into buffer
;* called once per scan line
;*

_QueueSoundBytes proc near


SoundQueueLoop:
	call	QueueSoundByte
	call	QueueSoundByte

	call	SQ_Test
	cmp	eax,0			; sound queue at least 1/2 full?
	je	SoundQueueLoop		;   no

        ret

_QueueSoundBytes endp


