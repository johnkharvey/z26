; trace.asm -- z26 trace buffer stuff


EXTRN _TraceBuffer:word

TRACE_BUF_MAX =	8192
TRACE_LINE_MAX = 1000

LOG_READ_ADDRESS macro
IFDEF trace

	call	LogReadAddress

ENDIF
endm

LOG_WRITE_ADDRESS macro
IFDEF trace

	call	LogWriteAddress

ENDIF
endm

LOG_READ_DATA macro
IFDEF trace

	call	LogReadData

ENDIF
endm

LOG_WRITE_DATA macro
IFDEF trace

	call	LogWriteData

ENDIF
endm



IFDEF trace

LogReadAddress:
	push	ax

	pop	ax
	ret


LogWriteAddress:
	push	ax

	pop	ax
	ret


LogReadData:
	push	ax

	pop	ax
	ret


LogWriteData:
	push	ax

	pop	ax
	ret

;*
;* put the byte in al into the trace buffer
;*

LogPutByte:
	push	bx
	mov	bx,_TracePtr
	cmp	bx,TRACE_BUF_MAX
	jae	LogPutRet
	inc	[_TracePtr]
	mov	byte ptr [_TraceBuffer + bx],al

LogPutRet:
	pop	bx
	ret

ENDIF



.CEND
.DATASEGMENT

_TracePtr	dw	0	; pointer into trace buffer
_TraceLine	dw	0	; # of lines in trace buffer

.DEND
.CODESEGMENT