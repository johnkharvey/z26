;*
;* z26 sound stuff
;*

;*
;* put a byte in the sound queue
;*
;* this is a helper routine, don't call directly
;*

;*
;* for sound at 44100 Hz, output 7 bytes per 5 calls
;*

QueueSoundByte:
	call	KidVid_Sound_Byte	 ;  get kidvid sample
	push	eax
	call	TIA_Sound_Byte		 ;  get TIA sample
	pop	ebx			 ;  kidvid sample

	add     eax,ebx			 ;  mix the samples
	shr     eax,1
	
	mov	dword [SQ_byte],eax	; for sound at 44100 Hz, output 7 bytes per 5 calls
	
	dec	dword [SQ_resample]	; time for a double sample ?
	
	cmp	dword [SQ_resample],2	;   do a double sample on call 2 ...
	je	QSB_store2
	cmp	dword [SQ_resample],0	;   ... and on call 0
	jne	QSB_dostore
	mov	dword [SQ_resample],5	; reset the sample counter
	
QSB_store2:
	call	SQ_Store	
QSB_dostore:
	call	SQ_Store		 ;  put it in the sound queue

	ret

;*
;* put sound bytes into buffer
;* called once per scan line
;*
;* call this one...
;*


QueueSoundBytes:
	pushad
 	cmp	byte [quiet],0		; doing sound at all?
	jnz near SoundQueueFull		;    no, don't queue anything
TryQueue:
	call	SQ_Test
	cmp	eax,-1			 ;  sound queue already full?
	jne near SoundQueueLoop		;   no
	
	cmp     byte [SyncToSoundBuffer],1 ; syncronizing to sound buffer?
	jne near SoundQueueFull           ;    no, don't queue anything

	pushad				 ;    no, wait for room
	call	srv_Events 		; I think you're not supposed to call this from the callback
	popad
	jmp	TryQueue

SoundQueueLoop:
	call	QueueSoundByte
	call	QueueSoundByte

	call	SQ_Test
	cmp	eax,0			 ;  sound queue at least 1/2 full?
	je near SoundQueueLoop		 ;    no

SoundQueueFull:
	popad
	ret


; z26 is Copyright 1997-2011 by John Saeger and contributors.  
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.
