extern void cpu_Instruction(void);
extern void cpu_Reset(void);

/*
extern unsigned char ReadROM(unsigned int);
*/

typedef unsigned long int   dd;
typedef unsigned short dw;
typedef unsigned char  db;

dw cpu_MAR;
db cpu_Rbyte;

unsigned char ReadROM(unsigned int adr)
{
	cpu_MAR = adr;
	ReallyReadRom();
	return(cpu_Rbyte);
}

dw cpu_pc;
db cpu_a, cpu_carry, cpu_x, cpu_y, cpu_sp;
db cpu_ZTest, cpu_NTest, cpu_D, cpu_V, cpu_I, cpu_B;

dd timer;

dd frame;
dw line;
db cycle;
dw BL_Pos, M0_Pos, M1_Pos, P0_Pos, P1_Pos;


enum {_imp, _ac, _rel, _imm, _abs, _abs_x, _abs_y, _zero, _zero_x, _zero_y, _ind, _ind_x, _ind_y};

void ti_showstr(char *str)
{
	fprintf(log, "%s", str);
}

void ti_showhex32(long int num)
{
	fprintf(log, "%08lx",num);
}

void ti_showdec32(long int num)
{
	fprintf(log, "%08ld",num);
}

void ti_showhex16(int num)
{
	fprintf(log, "%04x", num);
}

void ti_showdec16(int num)
{
	fprintf(log, "%3d", num);
}

void ti_showhex8(int num)
{
	fprintf(log, "%02x", num & 0xff);
}


void ShowWeird(int Cycle)
{
	fprintf(log,"<-- weird (%d)", Cycle);
}

void ShowDeep(int Now, int Prev, int Cycle)
{
	fprintf(log,"<-- deep (%d, %x, %x)", Cycle, Prev, Now);
}

void ShowVeryDeep()
{
	fprintf(log,"<-- very deep");
}

int ti_op8()
{
	return (ReadROM(cpu_pc + 1));
}

int ti_op16()
{
	return (ReadROM(cpu_pc + 1) + 256*ReadROM(cpu_pc + 2));
}

void ti_show_ind()
{
	ti_showstr("(");
	ti_showhex16(ti_op16());
	ti_showstr(")");
	ti_showstr("  ");
}

void ti_show_ind_x()
{
	ti_showstr("(");
	ti_showhex8(ti_op8());
	ti_showstr(",x)");
	ti_showstr("  ");
}

void ti_show_ind_y()
{
	ti_showstr("(");
	ti_showhex8(ti_op8());
	ti_showstr("),y");
	ti_showstr("  ");
}

void ti_show_zero_x()
{
	ti_showstr(" ");
	ti_showhex8(ti_op8());
	ti_showstr(",x");
	ti_showstr("   ");
}

void ti_show_zero_y()
{
	ti_showstr(" ");
	ti_showhex8(ti_op8());
	ti_showstr(",y");
	ti_showstr("   ");
}

void ti_show_abs_y()
{
	ti_showstr(" ");
	ti_showhex16(ti_op16());
	ti_showstr(",y");
	ti_showstr(" ");
}

void ti_show_abs_x()
{
	ti_showstr(" ");
	ti_showhex16(ti_op16());
	ti_showstr(",x");
	ti_showstr(" ");
}

void ti_show_zero()
{
unsigned char op;

	op = ti_op8();
	ti_showstr(" ");

	switch(op)
	{
	case 0x00:	ti_showstr("VSYNC");		break;
	case 0x01:	ti_showstr("VBLANK");		break;
	case 0x02:	ti_showstr("WSYNC");		break;
	case 0x03:	ti_showstr("*RSYNC*");		break;
	case 0x04:	ti_showstr("NUSIZ0");		break;
	case 0x05:	ti_showstr("NUSIZ1");		break;
	case 0x06:	ti_showstr("COLUP0");		break;
	case 0x07:	ti_showstr("COLUP1");		break;
	case 0x08:	ti_showstr("COLUPF");		break;
	case 0x09:	ti_showstr("COLUBK");		break;
	case 0x0a:	ti_showstr("CTRLPF");		break;
	case 0x0b:	ti_showstr("REFP0");		break;
	case 0x0c:	ti_showstr("REFP1");		break;
	case 0x0d:	ti_showstr("PF0");		break;
	case 0x0e:	ti_showstr("PF1");		break;
	case 0x0f:	ti_showstr("PF2");		break;
	case 0x10:	ti_showstr("RESP0");		break;
	case 0x11:	ti_showstr("RESP1");		break;
	case 0x12:	ti_showstr("RESM0");		break;
	case 0x13:	ti_showstr("RESM1");		break;
	case 0x14:	ti_showstr("RESBL");		break;
	case 0x15:	ti_showstr("AUDC0");		break;
	case 0x16:	ti_showstr("AUDC1");		break;
	case 0x17:	ti_showstr("AUDF0");		break;
	case 0x18:	ti_showstr("AUDF1");		break;
	case 0x19:	ti_showstr("AUDV0");		break;
	case 0x1a:	ti_showstr("AUDV1");		break;
	case 0x1b:	ti_showstr("GRP0");		break;
	case 0x1c:	ti_showstr("GRP1");		break;
	case 0x1d:	ti_showstr("ENAM0");		break;
	case 0x1e:	ti_showstr("ENAM1");		break;
	case 0x1f:	ti_showstr("ENABL");		break;
	case 0x20:	ti_showstr("HMP0");		break;
	case 0x21:	ti_showstr("HMP1");		break;
	case 0x22:	ti_showstr("HMM0");		break;
	case 0x23:	ti_showstr("HMM1");		break;
	case 0x24:	ti_showstr("HMBL");		break;
	case 0x25:	ti_showstr("VDELP0");		break;
	case 0x26:	ti_showstr("VDELP1");		break;
	case 0x27:	ti_showstr("VDELBL");		break;
	case 0x28:	ti_showstr("RESMP0");		break;
	case 0x29:	ti_showstr("RESMP1");		break;
	case 0x2a:	ti_showstr("HMOVE");		break;
	case 0x2b:	ti_showstr("HMCLR");		break;
	case 0x2c:	ti_showstr("CXCLR");		break;

	default:	ti_showhex8(op);		break;
	}

	ti_showstr("     ");
}

void ti_show_abs()
{
	unsigned int op;

	op = ti_op16();
	ti_showstr(" ");
	
	switch(op)
	{
	case 0x280:	ti_showstr("SWCHA");		break;
	case 0x281:	ti_showstr("SWACNT");		break;
	case 0x282:	ti_showstr("SWCHB");		break;
	case 0x283:	ti_showstr("SWBCNT");		break;
	case 0x284:	ti_showstr("INTIM");		break;
	case 0x285:	ti_showstr("TIMINT");		break;
	case 0x286:	ti_showstr("intim");		break;
	case 0x287:	ti_showstr("timint");		break;

	case 0x294:	ti_showstr("TIM1T");		break;
	case 0x295:	ti_showstr("TIM8T");		break;
	case 0x296:	ti_showstr("TIM64T");		break;
	case 0x297:	ti_showstr("T1024T");		break;
	
	default:	ti_showhex16(op);		break;
	}

	ti_showstr("   ");
}

void ti_show_immediate()
{
	ti_showstr("#");
	ti_showhex8(ti_op8());
	ti_showstr("     ");
}

void ti_show_ac()
{
	ti_showstr(" a");
	ti_showstr("      ");
}

void ti_show_relative()
{
	int target;

	ti_showstr(" ");
	target = (char) ti_op8();
	target += cpu_pc + 2;
	ti_showhex16(target);
	ti_showstr("   ");
}

void ti_show_code(int optype)
{
	ti_showhex8(ReadROM(cpu_pc));
	ti_showstr(" ");

	switch (optype)
	{
	case _imp:
	case _ac: 
		ti_showstr("      ");
		break;

	case _rel:
	case _imm:
	case _zero:
	case _zero_x:
		ti_showhex8(ReadRom(cpu_pc + 1));
		ti_showstr("    ");

		break;

	case _abs:
	case _abs_x:
	case _abs_y:
	case _ind:
	case _ind_x:
	case _ind_y:
		ti_showhex8(ReadROM(cpu_pc + 1));
		ti_showstr(" ");
		ti_showhex8(ReadROM(cpu_pc + 2));
		ti_showstr(" ");
		break;
	}
}


void ti_show_op(char *opstr, int optype)
{

	ti_show_code(optype);


	ti_showstr(opstr);
	ti_showstr(" ");
	switch(optype)
	{
	case _imp:		ti_showstr("        ");	break;
	case _ac:		ti_show_ac();			break;
	case _rel:		ti_show_relative();		break;
	case _imm:		ti_show_immediate();	break;
	case _abs:		ti_show_abs();			break;
	case _abs_x:	ti_show_abs_x();		break;
	case _abs_y:	ti_show_abs_y();		break;
	case _zero:		ti_show_zero();			break;
	case _zero_x:	ti_show_zero_x();		break;
	case _ind:		ti_show_ind();			break;
	case _ind_x:	ti_show_ind_x();		break;
	case _ind_y:	ti_show_ind_y();		break;
	}
}

void ShowInstruction(void)
{
	ti_showhex16(cpu_pc);
	ti_showstr(": ");

	switch(ReadROM(cpu_pc))
	{
	case 0x00: ti_show_op("brk",_imp);		break;
	case 0x01: ti_show_op("ora",_ind_x);	break;
	case 0x02: ti_show_op("jam",_imp);		break;
	case 0x03: ti_show_op("slo",_ind_x); 	break;
	case 0x04: ti_show_op("nop",_zero);		break;
	case 0x05: ti_show_op("ora",_zero);		break;
	case 0x06: ti_show_op("asl",_zero);		break;
	case 0x07: ti_show_op("slo",_zero);		break;
	case 0x08: ti_show_op("php",_imp);		break;
	case 0x09: ti_show_op("ora",_imm);		break;
	case 0x0a: ti_show_op("asl",_ac);		break;
	case 0x0b: ti_show_op("anc",_imm);		break;
	case 0x0c: ti_show_op("nop",_abs);		break;
	case 0x0d: ti_show_op("ora",_abs);		break;
	case 0x0e: ti_show_op("asl",_abs);		break;
	case 0x0f: ti_show_op("slo",_abs);		break;

	case 0x10: ti_show_op("bpl",_rel);		break;
	case 0x11: ti_show_op("ora",_ind_y);	break;
	case 0x12: ti_show_op("jam",_imp);		break;
	case 0x13: ti_show_op("slo",_ind_y);	break;
	case 0x14: ti_show_op("nop",_zero_x);	break;
	case 0x15: ti_show_op("ora",_zero_x);	break;
	case 0x16: ti_show_op("asl",_zero_x);	break;
	case 0x17: ti_show_op("slo",_zero_x);	break;
	case 0x18: ti_show_op("clc",_imp);		break;
	case 0x19: ti_show_op("ora",_abs_y);	break;
	case 0x1a: ti_show_op("nop",_imp);		break;
	case 0x1b: ti_show_op("slo",_abs_y);	break;
	case 0x1c: ti_show_op("nop",_abs_x);	break;
	case 0x1d: ti_show_op("ora",_abs_x);	break;
	case 0x1e: ti_show_op("asl",_abs_x);	break;
	case 0x1f: ti_show_op("slo",_abs_x);	break;

	case 0x20: ti_show_op("jsr",_abs);		break;
	case 0x21: ti_show_op("and",_ind_x);	break;
	case 0x22: ti_show_op("jam",_imp);		break;
	case 0x23: ti_show_op("rla",_ind_x);	break;
	case 0x24: ti_show_op("bit",_zero);		break;
	case 0x25: ti_show_op("and",_zero);		break;
	case 0x26: ti_show_op("rol",_zero);		break;
	case 0x27: ti_show_op("rla",_zero);		break;
	case 0x28: ti_show_op("plp",_imp);		break;
	case 0x29: ti_show_op("and",_imm);		break;
	case 0x2a: ti_show_op("rol",_ac);		break;
	case 0x2b: ti_show_op("jam",_imp);		break;
	case 0x2c: ti_show_op("bit",_abs);		break;
	case 0x2d: ti_show_op("and",_abs);		break;
	case 0x2e: ti_show_op("rol",_abs);		break;
	case 0x2f: ti_show_op("rla",_abs);		break;

	case 0x30: ti_show_op("bmi",_rel);		break;
	case 0x31: ti_show_op("and",_ind_y);	break;
	case 0x32: ti_show_op("jam",_imp);		break;
	case 0x33: ti_show_op("rla",_ind_y);	break;
	case 0x34: ti_show_op("nop",_zero);		break;
	case 0x35: ti_show_op("and",_zero_x);	break;
	case 0x36: ti_show_op("rol",_zero_x);	break;
	case 0x37: ti_show_op("rla",_zero_x);	break;
	case 0x38: ti_show_op("sec",_imp);		break;
	case 0x39: ti_show_op("and",_abs_y);	break;
	case 0x3a: ti_show_op("nop",_imp);		break;
	case 0x3b: ti_show_op("rla",_abs_y);	break;
	case 0x3c: ti_show_op("nop",_imp);		break;
	case 0x3d: ti_show_op("and",_abs_x);	break;
	case 0x3e: ti_show_op("rol",_abs_x);	break;
	case 0x3f: ti_show_op("rla",_abs_x);	break;

	case 0x40: ti_show_op("rti",_imp);		break;
	case 0x41: ti_show_op("eor",_ind_x);	break;
	case 0x42: ti_show_op("jam",_imp);		break;
	case 0x43: ti_show_op("sre",_ind_x);	break;
	case 0x44: ti_show_op("nop",_zero);		break;
	case 0x45: ti_show_op("eor",_zero);		break;
	case 0x46: ti_show_op("lsr",_zero);		break;
	case 0x47: ti_show_op("sre",_zero);		break;
	case 0x48: ti_show_op("pha",_imp);		break;
	case 0x49: ti_show_op("eor",_imm);		break;
	case 0x4a: ti_show_op("lsr",_ac);		break;
	case 0x4b: ti_show_op("asr",_imm);		break;
	case 0x4c: ti_show_op("jmp",_abs);		break;
	case 0x4d: ti_show_op("eor",_abs);		break;
	case 0x4e: ti_show_op("lsr",_abs);		break;
	case 0x4f: ti_show_op("sre",_abs);		break;

	case 0x50: ti_show_op("bvc",_rel);		break;
	case 0x51: ti_show_op("eor",_ind_y);	break;
	case 0x52: ti_show_op("jam",_imp);		break;
	case 0x53: ti_show_op("sre",_ind_y);	break;
	case 0x54: ti_show_op("nop",_zero_x);	break;
	case 0x55: ti_show_op("eor",_zero_x);	break;
	case 0x56: ti_show_op("lsr",_zero_x);	break;
	case 0x57: ti_show_op("sre",_zero_x);	break;
	case 0x58: ti_show_op("cli",_imp);		break;
	case 0x59: ti_show_op("eor",_abs_y);	break;
	case 0x5a: ti_show_op("nop",_imp);		break;
	case 0x5b: ti_show_op("sre",_abs_y);	break;
	case 0x5c: ti_show_op("nop",_abs_x);	break;
	case 0x5d: ti_show_op("eor",_abs_x);	break;
	case 0x5e: ti_show_op("lsr",_abs_x);	break;
	case 0x5f: ti_show_op("sre",_abs_x);	break;
 
	case 0x60: ti_show_op("rts",_imp);		break;
	case 0x61: ti_show_op("adc",_ind_x);	break;
	case 0x62: ti_show_op("jam",_imp);		break;
	case 0x63: ti_show_op("rra",_ind_x);	break;
	case 0x64: ti_show_op("nop",_zero);		break;
	case 0x65: ti_show_op("adc",_zero);		break;
	case 0x66: ti_show_op("ror",_zero);		break;
	case 0x67: ti_show_op("rra",_zero);		break;
	case 0x68: ti_show_op("pla",_imp);		break;
	case 0x69: ti_show_op("adc",_imm);		break;
	case 0x6a: ti_show_op("ror",_ac);		break;
	case 0x6b: ti_show_op("arr",_imm);		break;
	case 0x6c: ti_show_op("jmp",_ind);		break;
	case 0x6d: ti_show_op("adc",_imm);		break;
	case 0x6e: ti_show_op("ror",_abs);		break;
	case 0x6f: ti_show_op("rra",_abs);		break;

	case 0x70: ti_show_op("bvs",_rel);		break;
	case 0x71: ti_show_op("adc",_ind_y);	break;
	case 0x72: ti_show_op("jam",_imp);		break;
	case 0x73: ti_show_op("rra",_ind_y);	break;
	case 0x74: ti_show_op("nop",_zero_x);	break;
	case 0x75: ti_show_op("adc",_zero_x);	break;
	case 0x76: ti_show_op("ror",_zero_x);	break;
	case 0x77: ti_show_op("rra",_zero_x);	break;
	case 0x78: ti_show_op("sei",_imp);		break;
	case 0x79: ti_show_op("adc",_abs_y);	break;
	case 0x7a: ti_show_op("nop",_imp);		break;
	case 0x7b: ti_show_op("rra",_abs_y);	break;
	case 0x7c: ti_show_op("nop",_abs_x);	break;
	case 0x7d: ti_show_op("adc",_abs_x);	break;
	case 0x7e: ti_show_op("ror",_abs_x);	break;
	case 0x7f: ti_show_op("rra",_abs_x);	break;

	case 0x80: ti_show_op("nop",_imm);		break;
	case 0x81: ti_show_op("sta",_ind_x);	break;
	case 0x82: ti_show_op("nop",_imm);		break;
	case 0x83: ti_show_op("sax",_ind_x);	break;
	case 0x84: ti_show_op("sty",_zero);		break;
	case 0x85: ti_show_op("sta",_zero);		break;
	case 0x86: ti_show_op("stx",_zero);		break;
	case 0x87: ti_show_op("sax",_zero);		break;
	case 0x88: ti_show_op("dey",_imp);		break;
	case 0x89: ti_show_op("nop",_imm);		break;
	case 0x8a: ti_show_op("txa",_imp);		break;
	case 0x8b: ti_show_op("ane",_imm);		break;
	case 0x8c: ti_show_op("sty",_abs);		break;
	case 0x8d: ti_show_op("sta",_abs);		break;
	case 0x8e: ti_show_op("stx",_abs);		break;
	case 0x8f: ti_show_op("sax",_abs);		break;

	case 0x90: ti_show_op("bcc",_rel);		break;
	case 0x91: ti_show_op("sta",_ind_y);	break;
	case 0x92: ti_show_op("jam",_imp);		break;
	case 0x93: ti_show_op("sha",_ind_y);	break;
	case 0x94: ti_show_op("sty",_zero_x);	break;
	case 0x95: ti_show_op("sta",_zero_x);	break;
	case 0x96: ti_show_op("stx",_zero_y);	break;
	case 0x97: ti_show_op("sax",_zero_y);	break;
	case 0x98: ti_show_op("tya",_imp);		break;
	case 0x99: ti_show_op("sta",_abs_y);	break;
	case 0x9a: ti_show_op("txs",_imp);		break;
	case 0x9b: ti_show_op("shs",_abs_y);	break;
	case 0x9c: ti_show_op("shy",_abs_x);	break;
	case 0x9d: ti_show_op("sta",_abs_x);	break;
	case 0x9e: ti_show_op("shx",_abs_y);	break;
	case 0x9f: ti_show_op("sha",_abs_y);	break;

	case 0xa0: ti_show_op("ldy",_imm);		break;
	case 0xa1: ti_show_op("lda",_ind_x);	break;
	case 0xa2: ti_show_op("ldx",_imm);		break;
	case 0xa3: ti_show_op("lax",_ind_x);	break;
	case 0xa4: ti_show_op("ldy",_zero);		break;
	case 0xa5: ti_show_op("lda",_zero);		break;
	case 0xa6: ti_show_op("ldx",_zero);		break;
	case 0xa7: ti_show_op("lax",_zero);		break;
	case 0xa8: ti_show_op("tay",_imp);		break;
	case 0xa9: ti_show_op("lda",_imm);		break;
	case 0xaa: ti_show_op("tax",_imp);		break;
	case 0xab: ti_show_op("lxa",_imm);		break;
	case 0xac: ti_show_op("ldy",_abs);		break;
	case 0xad: ti_show_op("lda",_abs);		break;
	case 0xae: ti_show_op("ldx",_abs);		break;
	case 0xaf: ti_show_op("lax",_abs);		break;

	case 0xb0: ti_show_op("bcs",_rel);		break;
	case 0xb1: ti_show_op("lda",_ind_y);	break;
	case 0xb2: ti_show_op("jam",_imp);		break;
	case 0xb3: ti_show_op("lax",_ind_y);	break;
	case 0xb4: ti_show_op("ldy",_zero_x);	break;
	case 0xb5: ti_show_op("lda",_zero_x);	break;
	case 0xb6: ti_show_op("ldx",_zero_y);	break;
	case 0xb7: ti_show_op("lax",_zero_y);	break;
	case 0xb8: ti_show_op("clv",_imp);		break;
	case 0xb9: ti_show_op("lda",_abs_y);	break;
	case 0xba: ti_show_op("tsx",_imp);		break;
	case 0xbb: ti_show_op("las",_abs_y);	break;
	case 0xbc: ti_show_op("ldy",_abs_x);	break;
	case 0xbd: ti_show_op("lda",_abs_x);	break;
	case 0xbe: ti_show_op("ldx",_abs_y);	break;
	case 0xbf: ti_show_op("lax",_abs_y);	break;

	case 0xc0: ti_show_op("cpy",_imm);		break;
	case 0xc1: ti_show_op("cmp",_ind_x);	break;
	case 0xc2: ti_show_op("nop",_imm);		break;
	case 0xc3: ti_show_op("dcp",_ind_x);	break;
	case 0xc4: ti_show_op("cpy",_zero);		break;
	case 0xc5: ti_show_op("cmp",_zero);		break;
	case 0xc6: ti_show_op("dec",_zero);		break;
	case 0xc7: ti_show_op("dcp",_zero);		break;
	case 0xc8: ti_show_op("iny",_imp);		break;
	case 0xc9: ti_show_op("cmp",_imm);		break;
	case 0xca: ti_show_op("dex",_imp);		break;
	case 0xcb: ti_show_op("sbx",_imm);		break;
	case 0xcc: ti_show_op("cpy",_abs);		break;
	case 0xcd: ti_show_op("cmp",_abs);		break;
	case 0xce: ti_show_op("dec",_abs);		break;
	case 0xcf: ti_show_op("dcp",_abs);		break;

	case 0xd0: ti_show_op("bne",_rel);		break;
	case 0xd1: ti_show_op("cmp",_ind_y);	break;
	case 0xd2: ti_show_op("jam",_imp);		break;
	case 0xd3: ti_show_op("dcp",_ind_y);	break;
	case 0xd4: ti_show_op("nop",_zero_x);	break;
	case 0xd5: ti_show_op("cmp",_zero_x);	break;
	case 0xd6: ti_show_op("dec",_zero_x);	break;
	case 0xd7: ti_show_op("dcp",_zero_x);	break;
	case 0xd8: ti_show_op("cld",_imp);		break;
	case 0xd9: ti_show_op("cmp",_abs_y);	break;
	case 0xda: ti_show_op("nop",_imp);		break;
	case 0xdb: ti_show_op("dcp",_abs_y);	break;
	case 0xdc: ti_show_op("nop",_abs_x);	break;
	case 0xdd: ti_show_op("cmp",_abs_x);	break;
	case 0xde: ti_show_op("dec",_abs_x);	break;
	case 0xdf: ti_show_op("dcp",_abs_x);	break;

	case 0xe0: ti_show_op("cpx",_imm);		break;
	case 0xe1: ti_show_op("sbc",_ind_x);	break;
	case 0xe2: ti_show_op("nop",_imm);		break;
	case 0xe3: ti_show_op("isb",_ind_x);	break;
	case 0xe4: ti_show_op("cpx",_zero);		break;
	case 0xe5: ti_show_op("sbc",_zero);		break;
	case 0xe6: ti_show_op("inc",_zero);		break;
	case 0xe7: ti_show_op("isb",_zero);		break;
	case 0xe8: ti_show_op("inx",_imp);		break;
	case 0xe9: ti_show_op("sbc",_imm);		break;
	case 0xea: ti_show_op("nop",_imp);		break;
	case 0xeb: ti_show_op("jam",_imp);		break;
	case 0xec: ti_show_op("cpx",_abs);		break;
	case 0xed: ti_show_op("sbc",_abs);		break;
	case 0xee: ti_show_op("inc",_abs);		break;
	case 0xef: ti_show_op("isb",_abs);		break;

	case 0xf0: ti_show_op("beq",_rel);		break;
	case 0xf1: ti_show_op("sbc",_ind_y);	break;
	case 0xf2: ti_show_op("jam",_imp);		break;
	case 0xf3: ti_show_op("isb",_ind_y);	break;
	case 0xf4: ti_show_op("nop",_zero_x);	break;
	case 0xf5: ti_show_op("sbc",_zero_x);	break;
	case 0xf6: ti_show_op("inc",_zero_x);	break;
	case 0xf7: ti_show_op("isb",_zero_x);	break;
	case 0xf8: ti_show_op("sed",_imp);		break;
	case 0xf9: ti_show_op("sbc",_abs_y);	break;
	case 0xfa: ti_show_op("nop",_imp);		break;
	case 0xfb: ti_show_op("isb",_abs_y);	break;
	case 0xfc: ti_show_op("nop",_abs_x);	break;
	case 0xfd: ti_show_op("sbc",_abs_x);	break;
	case 0xfe: ti_show_op("inc",_abs_x);	break;
	case 0xff: ti_show_op("isb",_abs_x);	break;

	}
/*
	ti_showstr("\n"); 
*/

}

void ShowRegisters()
{
	ti_showstr("\n");

	ti_showstr("(");
	ti_showdec16((int) frame);
	ti_showstr(" ");
	ti_showdec16(line);
	ti_showstr(" ");
	ti_showdec16(cycle);
	ti_showstr(") ");

	ti_showstr("(");
	ti_showdec16(line-41);
	ti_showstr(" ");
	ti_showdec16(cycle*3-68);
	ti_showstr(") ");

	ti_showstr("(");
	ti_showdec16((P0_Pos-68+5)%160);
	ti_showstr(" ");
	ti_showdec16((P1_Pos-68+5)%160);
	ti_showstr(" ");
	ti_showdec16((M0_Pos-68+4)%160);
	ti_showstr(" ");
	ti_showdec16((M1_Pos-68+4)%160);
	ti_showstr(" ");
	ti_showdec16((BL_Pos-68+4)%160);
	ti_showstr(") ");

	ti_showstr(" ");
/*
	ti_showhex32(timer);
	ti_showstr("  ");
*/

	if (cpu_NTest & 0x80)
		ti_showstr("N");
	else
		ti_showstr("n");

	if (cpu_V)
		ti_showstr("V");
	else
		ti_showstr("v");

	if (cpu_B)
		ti_showstr("B");
	else
		ti_showstr("b");

	if (cpu_D)
		ti_showstr("D");
	else
		ti_showstr("d");

	if (cpu_I)
		ti_showstr("I");
	else
		ti_showstr("i");

	if (cpu_ZTest)
		ti_showstr("z");
	else
		ti_showstr("Z");

	if (cpu_carry)
		ti_showstr("C");
	else
		ti_showstr("c");

	ti_showstr(" ");

	ti_showhex8(cpu_a);
	ti_showstr(" ");

	ti_showhex8(cpu_x);
	ti_showstr(" ");

	ti_showhex8(cpu_y);
	ti_showstr(" ");

	ti_showhex8(cpu_sp);
	ti_showstr("  ");

/*	ti_showstr("\n"); */
}
