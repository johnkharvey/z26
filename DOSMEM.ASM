;*
;* far memory allocator -- returns a segment address
;*

global _DOSalloc
global _DOSfree

_DOSalloc:
	pop	cx		; return adr
	pop	bx		; # of paragraphs to allocate
	push	bx		; restore stack
	push	cx
	mov	ah,048h
	int	021h		; allocate memory
	jc	nomem		;   oops!
	ret			; seg adr already in ax

nomem:	xor	ax,ax		; return NULL
	ret
	
_DOSfree:
	pop	cx		; return adr
	pop	bx		; block to release
	push	bx		; restore stack
	push	cx
	push	es
	mov	es,bx
	mov	ah,049h
	int	021h		; release memory
	pop	es
	ret			; ignore errors
