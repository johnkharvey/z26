;
; PCXWrite.asm
; written for A26 by Ronnie Greene - 9/26/97
; Writes the 320x200 VGA screen to a .PCX file
;

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

.data

PCXHeader   DB 10, 5, 1, 8, 4 DUP (0), 63, 1, 199, 8 DUP (0)
   DB 128, 0, 0, 0, 128, 0, 128, 128, 0, 0, 0, 128, 128
   DB 0, 128, 0, 5 DUP (128), 3 DUP (192), 255, 0, 0, 0, 255
   DB 0, 255, 255, 0, 0, 0, 255, 0, 255, 0, 6 DUP (255)
   DB 0, 1, 64, 1, 1, 59 DUP (0)

PCXFilename      DB 'Z26P0000.PCX', 0
PCXFileHandle    DW 0
PCXFileNumber    DW 0
PCXWriteBuffer   DB 360 DUP (0)
PCXHexTable      DB '0123456789ABCDEF'

.code

PCXWriteFile proc near
	pusha
	push es

   ; create a new file for writing (overwriting existing)
   mov ah, 3ch
   xor cx, cx
   mov dx, offset PCXFilename
   int 21h
   jnc PCXLabel1
   jmp PCXDone

PCXLabel1:
   mov [PCXFileHandle], ax

   ; write the header information
   mov bx, ax
   mov ah, 40h
   mov cx, 128
   mov dx, offset PCXHeader
   int 21h

   ; encode the VGA screen
   mov ax, 0a000h
   mov es, ax                 ; point dest segment to video memory
   xor si, si                 ; reset source to start of screen
   mov cx, 200                ; do 200 rows
PCXLoop1:
   push cx

   ; process 320 pixels
   mov al, es:[si]            ; read the first pixel on the line
   mov ah, al                 ; ah = last pixel read
   mov di, offset PCXWriteBuffer     ; point dest to write buffer
   mov dx, 0                  ; dx = write buffer length
   inc si                     ; advance read pos
   mov cx, 319                ; do 319 more pixels
   mov bl, 1                  ; bl = current run length
   
PCXLoop2:
   mov al, es:[si]            ; read the next pixel on the line
   inc si                     ; advance read pos
   cmp bl, 63                 ; is the current count 63 or more?
   je PCXJump2                ; yes, need to write out run
   cmp al, ah                 ; is the current pixel the same as the last?
   je PCXJump3                ; yes, keep going

PCXJump2:                     ; pixels differ, write out last pixel info
   cmp bl, 1                  ; do we need to write a count byte?
   je PCXJump4                ; no, skip it

   ; write out count value for pixel run
   add bl, 192                ; count byte = run length + 192
   mov [di], bl               ; write it to buffer
   inc di                     ; advance write pos
   inc dx                     ; advance write length

   ;write out pixel value
PCXJump4:
   mov [di], ah               ; write last pixel to buffer
   inc di                     ; advance write pos
   inc dx                     ; advance write length
   xor bl, bl                 ; reset count to zero
   mov ah, al                 ; set last byte to current byte

PCXJump3:
   inc bl                     ; add 1 to run length
   loop PCXLoop2              ; go back for rest of row

   ; write remaining information to buffer
   cmp bl, 1
   jle PCXJump5
   add bl, 192
   mov [di], bl
   inc di
   inc dx

PCXJump5:
   mov [di], ah
   inc di
   inc dx

   ; write buffer to file
   mov ah, 40h
   mov bx, [PCXFileHandle]
   mov cx, dx
   mov dx, offset PCXWriteBuffer
   int 21h

   ; go back for another row
   pop cx
   loop PCXLoop1

PCXSep:
   ; write out separator byte (0x0c)
   mov ah, 40h
   mov bx, [PCXFileHandle]
   mov cx, 1
   mov dx, offset PCXWriteBuffer
   mov byte ptr [PCXWriteBuffer], 12
   int 21h

   ; write the palette
   mov ah, 40h
   mov bx, [PCXFileHandle]
   mov cx, 384
   mov dx, offset PCXPalette
   int 21h

   mov ah, 40h
   mov bx, [PCXFileHandle]
   mov cx, 384
   mov dx, offset PCXPalette
   int 21h              ; write the palette data twice to get 768 bytes

   ; close the file
   mov ah, 3eh
   int 21h

   ;need to update the filename to write another one
   pop es
   mov dx, [PCXFileNumber]
   inc dx
   mov [PCXFileNumber],dx

; prints the number in DX into 4 chars in Filename positions 4-7
PCXHexNum:
   mov cx, 4
   mov bx, offset PCXHexTable
   mov di, offset PCXFilename
   add di, 7
   std
PCXHexLoop:
   mov al, dl
   and al, 0fh
   xlatb
   stosb
   shr dx, 4
   loop PCXHexLoop
   cld

PCXDone:
	popa
   ret

PCXWriteFile endp

