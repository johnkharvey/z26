; Here we find decimal arithmetic routines and the ARR routine for z26

; The algorithms are basically compiler generated from snippets of code extracted
; from 6510core.c by Ettore Perazzoli (ettore@comm2000.it).  6510core.c is part
; of the VICE Commodore 64 emulator.

; Too bad I couldn't just plug the original 6510core.c in and use the whole
; thing.  But I couldn't get it to compile with Turbo-C.  Besides, it would
; have been bigger and slower if I'd done it that way.  So I extracted the 
; minimum amount of code that I was too lazy to re-write from scratch
; and modified it until it would compile.  Then I reworked the compiler
; output to run in the z26 environment, and I did a little cleanup.  
; But there's room for improvement.

; By the way, this isn't the only code in z26 based on 6510core.c.  In particular,
; I used it as a guide for the implementation of all of the undocumented instructions.  
; I'm also using it as a reference for just about any question I might have about 
; how the 6507 in the Atari 2600 is supposed to work.  
; The code is very nice and easy to read.


; The approximate modified C code is as follows:


; unsigned char value;
; unsigned int  tmp_value, tmp, src, tmp_a, tmp_2;
; unsigned char flag_carry, reg_a;
;
;
; void ADCdecimal(void)
; {
;	tmp_value = (value);
;
;	tmp = (reg_a & 0xf) + (tmp_value & 0xf) + (flag_carry);
;	if (tmp > 0x9)
;		tmp += 0x6;
;	if (tmp <= 0x0f)
;		tmp = (tmp & 0xf) + (reg_a & 0xf0) + (tmp_value & 0xf0);
;	else
;		tmp = (tmp & 0xf) + (reg_a & 0xf0) + (tmp_value & 0xf0) + 0x10;
;	LOCAL_SET_ZERO(!((reg_a + tmp_value + (flag_carry)) & 0xff));
;	LOCAL_SET_SIGN(tmp & 0x80);
;	LOCAL_SET_OVERFLOW(((reg_a ^ tmp) & 0x80)
;                             && !((reg_a ^ tmp_value) & 0x80));
;	if ((tmp & 0x1f0) > 0x90)
;		tmp += 0x60;
;	LOCAL_SET_CARRY((tmp & 0xff0) > 0xf0);
;
;	reg_a = tmp;
;
; }
;
;
; void SBCdecimal(void)
; {
;	src = (value);
;	tmp = reg_a - src - ((flag_carry) ? 0 : 1);
;
;	tmp_a = (reg_a & 0xf) - (src & 0xf) - ((flag_carry) ? 0 : 1);
;	if (tmp_a & 0x10)
;              tmp_a = ((tmp_a - 6) & 0xf)
;                       | ((reg_a & 0xf0) - (src & 0xf0) - 0x10);
;	else
;              tmp_a = (tmp_a & 0xf) | ((reg_a & 0xf0) - (src & 0xf0));
;	if (tmp_a & 0x100)
;              tmp_a -= 0x60;
;
;	LOCAL_SET_CARRY(tmp < 0x100);
;	LOCAL_SET_NZ(tmp & 0xff);
;	LOCAL_SET_OVERFLOW(((reg_a ^ tmp) & 0x80)
;                             && ((reg_a ^ src) & 0x80));
;	reg_a = tmp_a;
; } 
;
;
; /* The fanciest opcode ever... ARR! */
;
; void ARR(void)
; {
;      tmp = reg_a & (value);
;      if (LOCAL_DECIMAL()) {
;          tmp_2 = tmp;
;          tmp_2 |= (flag_carry) << 8;
;          tmp_2 >>= 1;
;          LOCAL_SET_SIGN(flag_carry);
;          LOCAL_SET_ZERO(!tmp_2);
;          LOCAL_SET_OVERFLOW((tmp_2 ^ tmp) & 0x40);
;          if (((tmp & 0xf) + (tmp & 0x1)) > 0x5)
;              tmp_2 = (tmp_2 & 0xf0) | ((tmp_2 + 0x6) & 0xf);
;          if (((tmp & 0xf0) + (tmp & 0x10)) > 0x50) {
;              tmp_2 = (tmp_2 & 0x0f) | ((tmp_2 + 0x60) & 0xf0);
;              LOCAL_SET_CARRY(1);
;          } else
;              LOCAL_SET_CARRY(0);
;          reg_a = tmp_2;
;      } else {
;          tmp |= (flag_carry) << 8;
;          tmp >>= 1;
;          LOCAL_SET_NZ(tmp);
;          LOCAL_SET_CARRY(tmp & 0x40);
;          LOCAL_SET_OVERFLOW((tmp & 0x40) ^ ((tmp & 0x20) << 1));
;          reg_a = tmp;
;      }
; }


; And here's the assembly code:


.CEND
.DATASEGMENT

_tmp		dw	0
_tmp_value	dw	0
_tmp_a		dw	0
_src		dw	0
_tmp_2		dw	0

_value		db	0
_reg_a		db	0
_flag_carry	db	0

.DEND
.CODESEGMENT

_LOCAL_SETUP macro

	mov	[_reg_a],al
	mov	[_flag_carry],ah
	mov	[_value],dl

	endm

_LOCAL_RESTORE macro

	mov	al,[_reg_a]
	mov	ah,[_flag_carry]
	mov	dl,[_value]

	endm


_LOCAL_SET_ZERO macro

	test	ax,ax
	setz	[RZTest]

	endm


_LOCAL_SET_SIGN macro

	test	ax,ax
	setnz	[RNTest]
	shl	[RNTest],7

	endm


_LOCAL_SET_OVERFLOW macro

	test	ax,ax
	setnz	[flag_overflow]

	endm


_LOCAL_SET_CARRY macro

	test	ax,ax
	setnz	[_flag_carry]

	endm


_LOCAL_SET_NZ macro

	usetest	al

	endm


_ADCdecimal:

	_LOCAL_SETUP

	movzx	dx,[_value]
	mov	[_tmp_value],dx

	movzx	ax,[_reg_a]
	and	ax,0fh
	and	dx,0fh
	add	ax,dx

	movzx	dx,[_flag_carry]
	add	ax,dx

	cmp	ax,9
	jbe	ADCD_1
	add	ax,6
ADCD_1:
	mov	[_tmp_2],ax

	and	ax,0fh
	movzx	dx,[_reg_a]
	and	dx,0f0h
	add	ax,dx
	mov	dx,[_tmp_value]
	and	dx,0f0h
	add	ax,dx

	cmp	[_tmp_2],0fh
	jbe	ADCD_3

	add	ax,010h
ADCD_3:
	mov	[_tmp],ax
	movzx	ax,[_reg_a]
	add	ax,[_tmp_value]
	movzx	dx,[_flag_carry]
	add	ax,dx
	and	ax,0ffh
	neg	ax
	sbb	ax,ax
	inc	ax

	_LOCAL_SET_ZERO

	mov	ax,[_tmp]
	and	ax,080h

	_LOCAL_SET_SIGN

	movzx	ax,[_reg_a]
	xor	ax,[_tmp]
	test	ax,080h
	je	ADCD_4
	movzx	ax,[_reg_a]
	xor	ax,[_tmp_value]
	test	ax,080h

	jne	ADCD_4
	mov	ax,1
	jmp	ADCD_5
ADCD_4:
	xor	ax,ax
ADCD_5:
	_LOCAL_SET_OVERFLOW

	mov	ax,[_tmp]
	and	ax,01f0h
	cmp	ax,090h
	jbe	ADCD_6
	add	[_tmp],060h
ADCD_6:
	test	[_tmp],0ff00h
	setnz	al

	_LOCAL_SET_CARRY

	mov	ax,[_tmp]
	mov	[_reg_a],al

	_LOCAL_RESTORE

	ret	


_SBCdecimal:

	_LOCAL_SETUP

	movzx	ax,[_value]
	mov	[_src],ax
	cmp	[_flag_carry],0
	je	SBCD_1
	xor	ax,ax
	jmp	SBCD_2
SBCD_1:
	mov	ax,1
SBCD_2:
	movzx	dx,[_reg_a]
	sub	dx,[_src]
	sub	dx,ax
	mov	[_tmp],dx
	movzx	ax,[_reg_a]
	and	ax,15
	mov	dx,[_src]
	and	dx,15
	sub	ax,dx
	push	ax
	cmp	[_flag_carry],0
	je	SBCD_3
	xor	ax,ax
	jmp	SBCD_4
SBCD_3:
	mov	ax,1
SBCD_4:
	pop	dx
	sub	dx,ax
	mov	[_tmp_a],dx
	test	[_tmp_a],010h
	je	SBCD_5
	movzx	ax,[_reg_a]
	and	ax,0f0h
	mov	dx,[_src]
	and	dx,0f0h
	sub	ax,dx
	add	ax,-16
	mov	dx,[_tmp_a]
	add	dx,-6
	and	dx,0fh
	or	ax,dx
	mov	[_tmp_a],ax
	jmp	SBCD_6
SBCD_5:
	movzx	ax,[_reg_a]
	and	ax,0f0h
	mov	dx,[_src]
	and	dx,0f0h
	sub	ax,dx
	mov	dx,[_tmp_a]
	and	dx,0fh
	or	ax,dx
	mov	[_tmp_a],ax
SBCD_6:
	test	[_tmp_a],0100h
	je	SBCD_7
	sub	[_tmp_a],060h
SBCD_7:
	cmp	[_tmp],0100h
	jae	SBCD_8
	mov	ax,1
	jmp	SBCD_9
SBCD_8:
	xor	ax,ax
SBCD_9:
	_LOCAL_SET_CARRY

	mov	ax,[_tmp]
	and	ax,0ffh

	_LOCAL_SET_NZ

	movzx	ax,[_reg_a]
	xor	ax,[_tmp]
	test	ax,080h
	je	SBCD_10
	movzx	ax,[_reg_a]
	xor	ax,[_src]
	test	ax,080h
	je	SBCD_10
	mov	ax,1
	jmp	SBCD_11
SBCD_10:
	xor	ax,ax
SBCD_11:
	_LOCAL_SET_OVERFLOW

	mov	ax,[_tmp_a]
	mov	[_reg_a],al

	_LOCAL_RESTORE

	ret	


_ARR:
	_LOCAL_SETUP

	mov	al,[_reg_a]
	and	al,[_value]
	xor	ah,ah
	mov	[_tmp],ax
	
	movzx	ax,[flag_decimal]
	test	ax,ax
	je	ARR_4
	mov	ax,[_tmp]
	mov	[_tmp_2],ax
	movzx	ax,[_flag_carry]
	shl	ax,8
	or	[_tmp_2],ax
	shr	[_tmp_2],1

	movzx	ax,[_flag_carry]

	_LOCAL_SET_SIGN

	mov	ax,[_tmp_2]
	neg	ax
	sbb	ax,ax
	inc	ax

	_LOCAL_SET_ZERO

	mov	ax,[_tmp_2]
	xor	ax,[_tmp]
	and	ax,64

	_LOCAL_SET_OVERFLOW

	mov	ax,[_tmp]
	and	ax,15
	mov	dx,[_tmp]
	and	dx,1
	add	ax,dx
	cmp	ax,5
	jbe	ARR_1
	mov	ax,[_tmp_2]
	and	ax,240
	mov	dx,[_tmp_2]
	add	dx,6
	and	dx,15
	or	ax,dx
	mov	[_tmp_2],ax
ARR_1:
	mov	ax,[_tmp]
	and	ax,240
	mov	dx,[_tmp]
	and	dx,16
	add	ax,dx
	cmp	ax,80
	jbe	ARR_2
	mov	ax,[_tmp_2]
	and	ax,15
	mov	dx,[_tmp_2]
	add	dx,96
	and	dx,240
	or	ax,dx
	mov	[_tmp_2],ax
	mov	ax,1

	_LOCAL_SET_CARRY

	jmp	ARR_3
ARR_2:
	xor	ax,ax

	_LOCAL_SET_CARRY

ARR_3:
	mov	ax,[_tmp_2]
	mov	[_reg_a],al
	jmp	ARR_5
ARR_4:
	movzx	ax,[_flag_carry]
	shl	ax,8
	or	[_tmp],ax
	shr	[_tmp],1
	mov	ax,[_tmp]

	_LOCAL_SET_NZ

	mov	ax,[_tmp]
	and	ax,64

	_LOCAL_SET_CARRY

	mov	ax,[_tmp]
	and	ax,32
	shl	ax,1
	mov	dx,[_tmp]
	and	dx,64
	xor	ax,dx

	_LOCAL_SET_OVERFLOW

	mov	ax,[_tmp]
	mov	[_reg_a],al
ARR_5:

	_LOCAL_RESTORE

	ret	
