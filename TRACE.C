/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

enum {_imp, _ac, _rel, _imm, _abs, _abs_x, _abs_y, _zero, _zero_x, _zero_y, _ind, _ind_x, _ind_y};


typedef char InstName[4];
InstName InstList[256]={
   "brk","ora","jam","slo","nop","ora","asl","slo",
   "php","ora","asl","anc","nop","ora","asl","slo",

   "bpl","ora","jam","slo","nop","ora","asl","slo",
   "clc","ora","nop","slo","nop","ora","asl","slo",

   "jsr","and","jam","rla","bit","and","rol","rla",     
   "plp","and","rol","jam","bit","and","rol","rla",

   "bmi","and","jam","rla","nop","and","rol","rla",    
   "sec","and","nop","rla","nop","and","rol","rla",     

   "rti","eor","jam","sre","nop","eor","lsr","sre",
   "pha","eor","lsr","asr","jmp","eor","lsr","sre",

   "bvc","eor","jam","sre","nop","eor","lsr","sre",    
   "cli","eor","nop","sre","nop","eor","lsr","sre",  

   "rts","adc","jam","rra","nop","adc","ror","rra",
   "pla","adc","ror","arr","jmp","adc","ror","rra",

   "bvs","adc","jam","rra","nop","adc","ror","rra",
   "sei","adc","nop","rra","nop","adc","ror","rra",

   "nop","sta","nop","sax","sty","sta","stx","sax",
   "dey","nop","txa","ane","sty","sta","stx","sax",

   "bcc","sta","jam","sha","sty","sta","stx","sax",
   "tya","sta","txs","shs","shy","sta","shx","sha",

   "ldy","lda","ldx","lax","ldy","lda","ldx","lax",
   "tay","lda","tax","lxa","ldy","lda","ldx","lax",

   "bcs","lda","jam","lax","ldy","lda","ldx","lax",
   "clv","lda","tsx","las","ldy","lda","ldx","lax",

   "cpy","cmp","nop","dcp","cpy","cmp","dec","dcp",
   "iny","cmp","dex","sbx","cpy","cmp","dec","dcp",

   "bne","cmp","jam","dcp","nop","cmp","dec","dcp",
   "cld","cmp","nop","dcp","nop","cmp","dec","dcp",

   "cpx","sbc","nop","isb","cpx","sbc","inc","isb",
   "inx","sbc","nop","jam","cpx","sbc","inc","isb",

   "beq","sbc","jam","isb","nop","sbc","inc","isb",
   "sed","sbc","nop","isb","nop","sbc","inc","isb"
};

int AccessList[256] = {
   _imp, _ind_x, _imp, _ind_x, _zero, _zero, _zero, _zero,
   _imp, _imm, _ac, _imm, _abs, _abs, _abs, _abs,

   _rel, _ind_y, _imp, _ind_y, _zero_x, _zero_x, _zero_x, _zero_x,
   _imp, _abs_y, _imp, _abs_y, _abs_x, _abs_x, _abs_x, _abs_x,

   _abs, _ind_x, _imp, _ind_x, _zero, _zero, _zero, _zero,
   _imp, _imm, _ac, _imp, _abs, _abs, _abs, _abs,

   _rel, _ind_y, _imp, _ind_y, _zero, _zero_x, _zero_x, _zero_x,
   _imp, _abs_y, _imp, _abs_y, _imp, _abs_x, _abs_x, _abs_x,

   _imp, _ind_x, _imp, _ind_x, _zero, _zero, _zero, _zero,
   _imp, _imm, _ac, _imm, _abs, _abs, _abs, _abs,

   _rel, _ind_y, _imp, _ind_y, _zero_x, _zero_x, _zero_x, _zero_x,
   _imp, _abs_y, _imp, _abs_y, _abs_x, _abs_x, _abs_x, _abs_x,
 
   _imp, _ind_x, _imp, _ind_x, _zero, _zero, _zero, _zero,
   _imp, _imm, _ac, _imm, _ind, _imm, _abs, _abs,

   _rel, _ind_y, _imp, _ind_y, _zero_x, _zero_x, _zero_x, _zero_x,
   _imp, _abs_y, _imp, _abs_y, _abs_x, _abs_x, _abs_x, _abs_x,

   _imm, _ind_x, _imm, _ind_x, _zero, _zero, _zero, _zero,
   _imp, _imm, _imp, _imm, _abs, _abs, _abs, _abs,

   _rel, _ind_y, _imp, _ind_y, _zero_x, _zero_x, _zero_y, _zero_y,
   _imp, _abs_y, _imp, _abs_y, _abs_x, _abs_x, _abs_y, _abs_y,

   _imm, _ind_x, _imm, _ind_x, _zero, _zero, _zero, _zero,
   _imp, _imm, _imp, _imm, _abs, _abs, _abs, _abs,

   _rel, _ind_y, _imp, _ind_y, _zero_x, _zero_x, _zero_y, _zero_y,
   _imp, _abs_y, _imp, _abs_y, _abs_x, _abs_x, _abs_y, _abs_y,

   _imm, _ind_x, _imm, _ind_x, _zero, _zero, _zero, _zero,
   _imp, _imm, _imp, _imm, _abs, _abs, _abs, _abs,

   _rel, _ind_y, _imp, _ind_y, _zero_x, _zero_x, _zero_x, _zero_x,
   _imp, _abs_y, _imp, _abs_y, _abs_x, _abs_x, _abs_x, _abs_x,

   _imm, _ind_x, _imm, _ind_x, _zero, _zero, _zero, _zero,
   _imp, _imm, _imp, _imp, _abs, _abs, _abs, _abs,

   _rel, _ind_y, _imp, _ind_y, _zero_x, _zero_x, _zero_x, _zero_x,
   _imp, _abs_y, _imp, _abs_y, _abs_x, _abs_x, _abs_x, _abs_x
};

typedef char TIAname[8];
TIAname TIAList[0x40] = {
   "VSYNC", "VBLANK", "WSYNC", "*RSYNC*", "NUSIZ0", "NUSIZ1", "COLUP0", "COLUP1",
   "COLUPF", "COLUBK", "CTRLPF", "REFP0", "REFP1", "PF0", "PF1", "PF2",
   "RESP0", "RESP1", "RESM0", "RESM1", "RESBL", "AUDC0", "AUDC1", "AUDF0",
   "AUDF1", "AUDV0", "AUDV1", "GRP0", "GRP1", "ENAM0", "ENAM1", "ENABL",
   "HMP0", "HMP1", "HMM0", "HMM1", "HMBL", "VDELP0", "VDELP1", "VDELBL",
   "RESMP0", "RESMP1", "HMOVE", "HMCLR", "CXCLR", "2d", "2e", "2f",

   "CXM0P", "CXM1P", "CXP0FB", "CXP1FB", "CXM0FB", "CXM1FB", "CXBLPF", "CXPPMM",
   "INPT0", "INPT1", "INPT2", "INPT3", "INPT4", "INPT5", "3e", "3f"
};

typedef char RIOTname[7];
RIOTname RIOTList1[8] = {
   "SWCHA", "SWACNT", "SWCHB", "SWBCNT",
   "INTIM", "TIMINT", "intim", "timint"
};

RIOTname RIOTList2[4] = {
   "TIM1T", "TIM8T", "TIM64T", "T1024T"
};

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

dw P0_Pos, P1_Pos, M0_Pos, M1_Pos, BL_Pos;

dw adr, prevadr;

dd frame;
dw line;
db cycle;

void ShowWeird(int Cycle)
{
	fprintf(log,"<-- weird (%d)\n", Cycle);
}

void ShowDeep(int Now, int Prev, int Cycle)
{
	fprintf(log,"<-- deep (%d, %x, %x)\n", Cycle, Prev, Now);
}

void ShowVeryDeep(int Now, int Prev, int Cycle)
{
	fprintf(log,"<-- very deep (%d, %x, %x)\n", Cycle, Prev, Now);
}

void ShowAdjusted(void)
{
	fprintf(log,"Adjusted\n");
}

void ShowUndocTIA(void)
{
	fprintf(log,"<-- Undoc TIA\n");
}

void ShowCollision(void)
{
	fprintf(log,"<-- Collision\n");
}

void ShowSCWrite(void)
{
	fprintf(log,"<-- SC Write\n");
}

void Showaddress(void)
{
        fprintf(log, "\n(%04x %04x)", adr, prevadr);
}

int ti_op8(void)
{
	return (ReadROM(cpu_pc + 1));
}

int ti_op16(void)
{
	return (ReadROM(cpu_pc + 1) + 256*ReadROM(cpu_pc + 2));
}

void ti_show_ind(void)
{
        fprintf(log, "(%04x)  ", ti_op16());

}

void ti_show_ind_x(void)
{
        fprintf(log, "(%02x,x)  ", ti_op8());
}

void ti_show_ind_y(void)
{
        fprintf(log, "(%02x),y  ", ti_op8());
}

void ti_show_zero_x(void)
{
        fprintf(log, " %02x,x   ", ti_op8());
}

void ti_show_zero_y(void)
{
        fprintf(log, " %02x,y   ", ti_op8());
}

void ti_show_abs_y(void)
{
        fprintf(log, " %04x,y ", ti_op16());
}

void ti_show_abs_x(void)
{
        fprintf(log, " %04x,x ", ti_op16());
}

void ti_show_zero(void)
{
unsigned char op;

	op = ti_op8();

        if(op&0x80) {fprintf(log, " %02x     ", op);}
        else{
           if(op&0x40) op=op-0x40;
           /* simplified check for write-only access  *EST* */
           if(!((ReadROM(cpu_pc)&0xe0)==0x80)) op=(op&0x0f)+0x30;
           fprintf(log, " %s     ", TIAList[op]);
        }
}

void ti_show_abs(void)
{
	unsigned int op;

	op = ti_op16();

        if ((op>0x27f)&&(op<0x288))
        {
           op=op-0x280;
           fprintf(log, " %s   ", RIOTList1[op]);
        }else{
           if ((op>0x293)&&(op<0x298))
           {
              op=op-0x294;
              fprintf(log, " %s   ", RIOTList2[op]);
           }else{
/* if not ROM, RIOT or RIOT RAM, it must be TIA; *EST* */
              if(!(op&0xf280))
              {
                 ti_show_zero();
              }else fprintf(log, " %04x   ", op);
           }
        }
}

void ti_show_immediate(void)
{
        fprintf(log, "#%02x     ", ti_op8());
}

void ti_show_relative(void)
{
	int target;
	target = (char) ti_op8();
	target += cpu_pc + 2;
        fprintf(log, " %04x   ", target);
}

void ShowInstruction(void)
{
int optype;

        optype=AccessList[ReadROM(cpu_pc)];
        fprintf(log, "%04x: ", cpu_pc);

/* ti_show_code */
	switch (optype)
	{
	case _imp:
	case _ac: 
                fprintf(log, "%02x       ", ReadROM(cpu_pc));
		break;

	case _rel:
	case _imm:
	case _zero:
	case _zero_x:
                fprintf(log, "%02x %02x    ", ReadROM(cpu_pc), ReadROM(cpu_pc + 1));
		break;

	case _abs:
	case _abs_x:
	case _abs_y:
	case _ind:
	case _ind_x:
	case _ind_y:
                fprintf(log, "%02x %02x %02x ", ReadROM(cpu_pc), ReadROM(cpu_pc +1), ReadROM(cpu_pc +2));
		break;
	}

/* ti_show_op */
        fprintf(log, "%s ", InstList[ReadROM(cpu_pc)]);
	switch(optype)
	{
        case _imp:              fprintf(log, "        ");       break;
        case _ac:               fprintf(log, " a      ");       break;
	case _rel:		ti_show_relative();		break;
        case _imm:              ti_show_immediate();            break;
	case _abs:		ti_show_abs();			break;
        case _abs_x:            ti_show_abs_x();                break;
        case _abs_y:            ti_show_abs_y();                break;
	case _zero:		ti_show_zero();			break;
        case _zero_x:           ti_show_zero_x();               break;
	case _ind:		ti_show_ind();			break;
        case _ind_x:            ti_show_ind_x();                break;
        case _ind_y:            ti_show_ind_y();                break;
        }
}

void ShowRegisters(void)
{
/*
        fprintf(log, "\n(%3d %3d %3d) (%3d %3d) (%3d %3d %3d %3d %3d) ",
           (int)frame, line, cycle, line-42, cycle*3-68,
           (P0_Pos-68+5)%160, (P1_Pos-68+5)%160, (M0_Pos-68+4)%160,
           (M1_Pos-68+4)%160, (BL_Pos-68+4)%160);
*/

        fprintf(log, "\n(%3d %3d %3d %3d) (%3d %3d %3d %3d %3d) ",
           (int)frame, line, cycle, cycle*3-68,
           (P0_Pos-68+5)%160, (P1_Pos-68+5)%160, (M0_Pos-68+4)%160,
           (M1_Pos-68+4)%160, (BL_Pos-68+4)%160);


	if (cpu_NTest & 0x80)
                fprintf(log, "N");
	else
                fprintf(log, "n");

	if (cpu_V)
                fprintf(log, "V");
	else
                fprintf(log, "v");

	if (cpu_B)
                fprintf(log, "B");
	else
                fprintf(log, "b");

	if (cpu_D)
                fprintf(log, "D");
	else
                fprintf(log, "d");

	if (cpu_I)
                fprintf(log, "I");
	else
                fprintf(log, "i");

	if (cpu_ZTest)
                fprintf(log, "z");
	else
                fprintf(log, "Z");

	if (cpu_carry)
                fprintf(log, "C");
	else
                fprintf(log, "c");

        fprintf(log, " %02x %02x %02x %02x  ", cpu_a, cpu_x, cpu_y, cpu_sp);
}
