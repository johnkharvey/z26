; trace.asm -- z26 trace stuff

.code

TraceInstruction:

	pushad

	dec	[trace_count]	; one less instruction to trace
	
	popad
	ret

