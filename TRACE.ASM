; trace.asm -- z26 trace stuff


.CEND
.DATASEGMENT

trace_count	dd	0	; nonzero if tracing

.DEND
.CODESEGMENT


TraceInstruction:

	pushad

	dec	[trace_count]	; one less instruction to trace
	

	
	
	popad
	ret

