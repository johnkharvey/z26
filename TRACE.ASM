; trace.asm -- z26 trace stuff


.data

trace_count	dd	0	; nonzero if tracing

.code

TraceInstruction:

	pushad

	dec	[trace_count]	; one less instruction to trace
	

	
	
	popad
	ret

