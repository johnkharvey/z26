;* ddata.asm -- dword tables

;playfield counter to playfield bit table

;	  PF2		|	  PF1		|	  PF0		|
; 7  6	5  4  3	 2  1  0  7  6	5  4  3	 2  1  0  7  6	5  4  3	 2  1  0
;23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6	5  4  3	 2  1  0
;				  ECX					|

PFClockToBitReversed	dd	1 shl 4		;0	forward
			dd	1 shl 5		;1
			dd	1 shl 6		;2
			dd	1 shl 7		;3
			dd	1 shl 15	;4
			dd	1 shl 14	;5
			dd	1 shl 13	;6
			dd	1 shl 12	;7
			dd	1 shl 11	;8
			dd	1 shl 10	;9
			dd	1 shl 9		;10
			dd	1 shl 8		;11
			dd	1 shl 16	;12
			dd	1 shl 17	;13
			dd	1 shl 18	;14
			dd	1 shl 19	;15
			dd	1 shl 20	;16
			dd	1 shl 21	;17
			dd	1 shl 22	;18
			dd	1 shl 23	;19
		        
			dd	1 shl 23	;20	reversed
			dd	1 shl 22	;21
			dd	1 shl 21	;22
			dd	1 shl 20	;23
			dd	1 shl 19	;24
			dd	1 shl 18	;25
			dd	1 shl 17	;26
			dd	1 shl 16	;27
			dd	1 shl 8		;28
			dd	1 shl 9		;29
			dd	1 shl 10	;30
			dd	1 shl 11	;31
			dd	1 shl 12	;32
			dd	1 shl 13	;33
			dd	1 shl 14	;34
			dd	1 shl 15	;35
			dd	1 shl 7		;36
			dd	1 shl 6		;37
			dd	1 shl 5		;38
			dd	1 shl 4		;39

PFClockToBitForward	dd	1 shl 4		;0	forward
			dd	1 shl 5		;1
			dd	1 shl 6		;2
			dd	1 shl 7		;3
			dd	1 shl 15	;4
			dd	1 shl 14	;5
			dd	1 shl 13	;6
			dd	1 shl 12	;7
			dd	1 shl 11	;8
			dd	1 shl 10	;9
			dd	1 shl 9		;10
			dd	1 shl 8		;11
			dd	1 shl 16	;12
			dd	1 shl 17	;13
			dd	1 shl 18	;14
			dd	1 shl 19	;15
			dd	1 shl 20	;16
			dd	1 shl 21	;17
			dd	1 shl 22	;18
			dd	1 shl 23	;19
		        
			dd	1 shl 4		;0	forward
			dd	1 shl 5		;1
			dd	1 shl 6		;2
			dd	1 shl 7		;3
			dd	1 shl 15	;4
			dd	1 shl 14	;5
			dd	1 shl 13	;6
			dd	1 shl 12	;7
			dd	1 shl 11	;8
			dd	1 shl 10	;9
			dd	1 shl 9		;10
			dd	1 shl 8		;11
			dd	1 shl 16	;12
			dd	1 shl 17	;13
			dd	1 shl 18	;14
			dd	1 shl 19	;15
			dd	1 shl 20	;16
			dd	1 shl 21	;17
			dd	1 shl 22	;18
			dd	1 shl 23	;19



