/*
	6507 CPU emulator for z26

 This C file gets generated from cpu.m4, so please edit it there.

 z26 is Copyright 1997-2019 by John Saeger and contributors.  
 z26 is released subject to the terms and conditions of the 
 GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
 Please see COPYING.TXT for details.
*/

db dummy_flag;				/* used by ROL and ROR */
db dummy_high, dummy_low;	/* used by ADC and SBC */
dd Address;

#define bumpclock \
	RClock++; \
	RCycles++;

#define readbank \
	bumpclock \
	ReadAccess[AddressBus]();

#define writebank \
	bumpclock \
	WriteAccess[AddressBus]();

#define opcode($1, $2, $3) \
	void $1(void){ \
	$2 \
	$3 \
}

#define adr_implied 

#define adr_immediate \
	reg_pc++;

#define adr_absolute \
	readbank \
	Address = DataBus; \
	reg_pc++; \
	AddressBus = reg_pc; \
	readbank \
	AddressBus = (DataBus << 8) + Address; \
	reg_pc++;

#define adr_zeropage \
	readbank \
	reg_pc++; \
	AddressBus = DataBus;

#define adr_zeropage_index($1) \
	readbank \
	reg_pc++; \
	AddressBus = DataBus; \
	readbank \
	AddressBus = ((AddressBus + $1) & 0xff);

#define adr_absolute_index_write($1) \
	readbank \
	Address = DataBus; \
	reg_pc++; \
	AddressBus = reg_pc; \
	readbank \
	reg_pc++; \
	AddressBus = (DataBus << 8) + ((Address + $1) & 0xff); \
	readbank \
	AddressBus = (((AddressBus & 0xff00) + Address) + $1) & 0xffff;

#define adr_absolute_index_read($1) \
	readbank \
	Address = DataBus; \
	reg_pc++; \
	AddressBus = reg_pc; \
	readbank \
	reg_pc++; \
	AddressBus = (DataBus << 8) + ((Address + $1) & 0xff); \
	if((Address + $1) > 0xff){ \
		readbank \
		AddressBus = (((AddressBus & 0xff00) + Address) + $1) & 0xffff; \
	}

#define adr_index_indirect \
	readbank \
	AddressBus = DataBus; \
	reg_pc++; \
	readbank \
	AddressBus = (AddressBus + reg_x) & 0xff; \
	readbank \
	Address = DataBus; \
	AddressBus = (AddressBus + 1) & 0xff; \
	readbank \
	AddressBus = (DataBus << 8) + Address;

#define adr_indirect_index_read \
	readbank \
	AddressBus = DataBus; \
	reg_pc++; \
	readbank \
	Address = DataBus; \
	AddressBus = (AddressBus + 1) & 0xff; \
	readbank \
	AddressBus = (DataBus << 8) + ((Address + reg_y) & 0xff); \
	if((Address + reg_y) > 0xff){ \
		readbank \
		AddressBus = (((AddressBus & 0xff00) + Address) + reg_y) & 0xffff; \
	}

#define adr_indirect_index_write \
	readbank \
	AddressBus = DataBus; \
	reg_pc++; \
	readbank \
	Address = DataBus; \
	AddressBus = (AddressBus + 1) & 0xff; \
	readbank \
	AddressBus = (DataBus << 8) + ((Address + reg_y) & 0xff); \
	readbank \
	AddressBus = (((AddressBus & 0xff00) + Address) + reg_y) & 0xffff;

#define adr_relative($1) \
	readbank \
	reg_pc++; \
	if($1){ \
		if(DataBus & 0x80) Address = (0x100 - DataBus) * -1; \
		else Address = DataBus; \
		AddressBus++; \
		readbank \
		if(((reg_pc + Address) & 0xff00) != (reg_pc & 0xff00)){ \
			AddressBus = (reg_pc & 0xff00) + ((reg_pc + Address) & 0xff); \
			readbank \
		} \
		reg_pc = reg_pc + Address; \
	}

#define adr_absolute_indirect \
	readbank \
	reg_pc = DataBus; \
	AddressBus = (AddressBus + 1) & 0xffff; \
	readbank \
	AddressBus = reg_pc + (DataBus << 8); \
	readbank \
	Address = DataBus; \
	AddressBus = (AddressBus & 0xff00) + ((AddressBus + 1) & 0xff); \
	readbank \
	AddressBus = Address + (DataBus << 8);

#define rmw_ram($1) \
	readbank \
	writebank \
	$1 \
	writebank

#define rmw_accu($1) \
	readbank \
	$1

#define adr_push($1) \
	readbank \
	AddressBus = reg_sp + 0x100; \
	DataBus = $1; \
	writebank \
	reg_sp--;

#define adr_pull \
	readbank \
	AddressBus = reg_sp + 0x100; \
	readbank \
	reg_sp++; \
	AddressBus = reg_sp + 0x100; \
	readbank

#define test_z($1) \
	if($1 == 0) flag_Z = 0x02; \
	else flag_Z = 0;

#define test_n($1) \
	flag_N = ($1 & 0x80);

#define test_v($1) \
	flag_V = ($1 & 0x40);

#define test_zn($1) \
	test_z($1) \
	test_n($1)

#define ADC \
	readbank \
	if(!flag_D){ \
		if( (((reg_a + DataBus + flag_C) ^ reg_a) & 0x80) && !((reg_a ^ DataBus) & 0x80) ) flag_V = 0x40; \
		else flag_V = 0; \
		dummy_flag = (((reg_a + DataBus + flag_C) & 0x100) >> 8); \
		reg_a = ((reg_a + DataBus + flag_C) & 0xff); \
		flag_C = dummy_flag; \
		test_zn(reg_a) \
	}else{ \
		dummy_low = (reg_a & 0xf) + (DataBus & 0xf) + flag_C; \
		dummy_high = ((reg_a & 0xf0) >> 4) + ((DataBus & 0xf0) >> 4);	/* + ((dummy_low & 0x10) >> 4); */ \
		if(dummy_low > 9) dummy_low += 6; \
		if (dummy_low > 0xf) dummy_high++; \
		test_z(((reg_a + DataBus + flag_C) & 0xff)) \
		test_n(((dummy_high << 4) | (dummy_low & 0xf))) \
		if( (((dummy_high << 4) ^ reg_a) & 0x80) && !((reg_a ^ DataBus) & 0x80) ) flag_V = 0x40; \
		else flag_V = 0; \
		if (dummy_high > 9) dummy_high += 6; \
		if (dummy_high > 0xf) flag_C = 0x1; \
		else flag_C = 0; \
		reg_a = ((dummy_high << 4) | (dummy_low & 0xf)) & 0xff; \
	}

#define AND \
	readbank \
	reg_a &= DataBus; \
	test_zn(reg_a)

#define ANC \
	AND \
	if(reg_a & 0x80) flag_C = 1; \
	else flag_C = 0;

#define ANE \
	readbank \
	reg_a = ((reg_a | 0xee) & reg_x) & DataBus; \
	test_zn(reg_a)

#define ARR \
	readbank \
	if(!flag_D){ \
		reg_a &= DataBus; \
		reg_a = ((reg_a >> 1) | (flag_C << 7)) & 0xff; \
		test_zn(reg_a) \
		flag_C = (reg_a & 0x40) >> 6; \
		flag_V = (((reg_a & 0x40) ^ ((reg_a & 0x20) << 1))) & 0x40; \
	}else{ \
		dummy_high = (reg_a & DataBus) >> 4; \
		dummy_low = (reg_a & DataBus) & 0xf; \
		flag_N = flag_C << 7; \
		reg_a = (reg_a & DataBus) >> 1 | flag_N; \
		test_z(reg_a) \
		flag_V = (((reg_a & 0x40) ^ ((reg_a & 0x20) << 1))) & 0x40; \
		if((dummy_low + (dummy_low & 1)) > 5) reg_a = (reg_a & 0xf0) | ((reg_a + 6) & 0xf); \
		if((dummy_high + (dummy_high & 1)) > 5){ \
			reg_a = (reg_a + 0x60) & 0xff; \
			flag_C = 1; \
		}else flag_C = 0; \
	}

#define ASL($1) \
	flag_C = ($1 & 0x80) >> 7; \
	$1 = ($1 << 1) & 0xfe; \
	test_zn($1)

#define ASR \
	readbank \
	reg_a &= DataBus; \
	flag_C = reg_a & 0x01; \
	reg_a = (reg_a >> 1) & 0x7f; \
	test_zn(reg_a)

#define BCC \
	adr_relative(!flag_C)

#define BCS \
	adr_relative(flag_C)

#define BEQ \
	adr_relative(flag_Z)

#define BIT \
	readbank \
	test_v(DataBus) \
	test_n(DataBus) \
	test_z((reg_a & DataBus))

#define BNE \
	adr_relative(!flag_Z)

#define BMI \
	adr_relative(flag_N)

#define BPL \
	adr_relative(!flag_N)

#define BRK \
	readbank \
	reg_pc++; \
	AddressBus = reg_sp + 0x100; \
	DataBus = ((reg_pc & 0xff00) >> 8); \
	flag_B = 0x10; \
	writebank \
	reg_sp--; \
	AddressBus = reg_sp + 0x100; \
	DataBus = reg_pc & 0xff; \
	writebank \
	reg_sp--; \
	AddressBus = reg_sp + 0x100; \
	DataBus = (flag_N | flag_V | 0x20 | flag_B | flag_D | flag_I | flag_Z | flag_C); \
	flag_I = 0x04; \
	writebank \
	reg_sp--; \
	AddressBus = 0xfffe; \
	readbank \
	reg_pc = DataBus; \
	AddressBus = 0xffff; \
	readbank \
	reg_pc = (DataBus << 8) + reg_pc;

#define BVC \
	adr_relative(!flag_V)

#define BVS \
	adr_relative(flag_V)

#define CLC \
	readbank \
	flag_C = 0;

#define CLD \
	readbank \
	flag_D = 0;

#define CLI \
	readbank \
	flag_I = 0;

#define CLV \
	readbank \
	flag_V = 0;

#define CMP \
	readbank \
	test_zn(((reg_a - DataBus) & 0xff)) \
	if(reg_a >= DataBus) flag_C = 1; \
	else flag_C = 0;

#define CPX \
	readbank \
	test_zn(((reg_x - DataBus) & 0xff)) \
	if(reg_x >= DataBus) flag_C = 1; \
	else flag_C = 0;

#define CPY \
	readbank \
	test_zn(((reg_y - DataBus) & 0xff)) \
	if(reg_y >= DataBus) flag_C = 1; \
	else flag_C = 0;

#define DCP \
	DataBus--; \
	test_zn(((reg_a - DataBus) & 0xff)) \
	if(reg_a >= DataBus) flag_C = 1; \
	else flag_C = 0;

#define DEC \
	DataBus--; \
	test_zn(DataBus)

#define DEX \
	readbank \
	reg_x--; \
	test_zn(reg_x)

#define DEY \
	readbank \
	reg_y--; \
	test_zn(reg_y)

#define EOR \
	readbank \
	reg_a ^= DataBus; \
	test_zn(reg_a)

#define INC \
	DataBus++; \
	test_zn(DataBus);

#define INX \
	readbank \
	reg_x++; \
	test_zn(reg_x)

#define INY \
	readbank \
	reg_y++; \
	test_zn(reg_y)

#define ISB \
	DataBus++; \
	if(!flag_D){ \
		if( (((reg_a + (0xff - DataBus) + flag_C) ^ reg_a) & 0x80) && !((reg_a ^ (0xff - DataBus)) & 0x80) ) flag_V = 0x40; \
		else flag_V = 0; \
		dummy_flag = (((reg_a + (0xff - DataBus) + flag_C) & 0x100) >> 8); \
		reg_a = ((reg_a + (0xff - DataBus) + flag_C) & 0xff); \
		flag_C = dummy_flag; \
		test_zn(reg_a) \
	}else{ \
		if( (((reg_a + (0xff - DataBus) + flag_C) ^ reg_a) & 0x80) && !((reg_a ^ (0xff - DataBus)) & 0x80) ) flag_V = 0x40; \
		else flag_V = 0; \
		dummy_flag = (((reg_a + (0xff - DataBus) + flag_C) & 0x100) >> 8); \
		dummy_low = ((reg_a + (0xff - DataBus) + flag_C) & 0xff); \
		test_zn(dummy_low) \
		dummy_low = (reg_a & 0xf) - (DataBus & 0xf) - (1 - flag_C); \
		dummy_high = (reg_a >> 4) - (DataBus >> 4) - ((dummy_low & 0x10) >> 4); \
		if (dummy_low & 0x10) dummy_low -= 6; \
		if (dummy_high & 0x10) dummy_high -= 6; \
		reg_a = ((dummy_high << 4) | (dummy_low & 0xf)) & 0xff; \
		flag_C = dummy_flag; \
		}

#define JMP \
	reg_pc = AddressBus;

#define JSR \
	readbank  \
	Address = DataBus; \
	reg_pc++; \
	AddressBus = reg_sp + 0x100; \
	readbank \
	DataBus = ((reg_pc & 0xff00) >> 8); \
	writebank \
	reg_sp--; \
	AddressBus = reg_sp + 0x100; \
	DataBus = reg_pc & 0xff; \
	writebank \
	reg_sp--; \
	AddressBus = reg_pc; \
	readbank \
	reg_pc = (DataBus << 8) + Address;

#define LAS \
	readbank \
	reg_a = reg_x = reg_sp & DataBus; \
	reg_sp = reg_a; \
	test_zn(reg_a)

#define LAX \
	readbank \
	reg_a = reg_x = DataBus; \
	test_zn(reg_a)

#define LDA \
	readbank \
	reg_a = DataBus; \
	test_zn(reg_a)

#define LDX \
	readbank \
	reg_x = DataBus; \
	test_zn(reg_x)

#define LDY \
	readbank \
	reg_y = DataBus; \
	test_zn(reg_y)

#define LSR($1) \
	flag_C = $1 & 0x01; \
	$1 = ($1 >> 1) & 0x7f; \
	test_zn($1)

#define LXA \
	readbank \
	reg_a = (reg_a | 0xee) & DataBus; \
	reg_x = reg_a; \
	test_zn(reg_a)

#define NOP \
	readbank

#define ORA \
	readbank \
	reg_a |= DataBus; \
	test_zn(reg_a)

#define PHA \
	adr_push(reg_a)

#define PHP \
	adr_push((flag_N | flag_V | 0x20 | flag_B | flag_D | flag_I | flag_Z | flag_C))

#define PLA \
	adr_pull \
	reg_a = DataBus; \
	test_zn(reg_a)

#define PLP \
	adr_pull \
	flag_N = DataBus & 0x80; \
	flag_V = DataBus & 0x40; \
/*	flag_B = DataBus & 0x10; */ \
	flag_D = DataBus & 0x08; \
	flag_I = DataBus & 0x04; \
	flag_Z = DataBus & 0x02; \
	flag_C = DataBus & 0x01;

#define RLA \
	dummy_flag = flag_C; \
	flag_C = (DataBus & 0x80) >> 7; \
	DataBus = ((DataBus << 1) | dummy_flag) & 0xff; \
	reg_a &= DataBus; \
	test_zn(reg_a)

#define ROL($1) \
	dummy_flag = flag_C; \
	flag_C = ($1 & 0x80) >> 7; \
	$1 = (($1 << 1) | dummy_flag) & 0xff; \
	test_zn($1)

#define ROR($1) \
	dummy_flag = flag_C << 7; \
	flag_C = $1 & 0x01; \
	$1 = (($1 >> 1) | dummy_flag) & 0xff; \
	test_zn($1)

#define RRA \
	dummy_flag = flag_C << 7; \
	flag_C = DataBus & 0x01; \
	DataBus = ((DataBus >> 1) | dummy_flag) & 0xff; \
	if(!flag_D){ \
		if( (((reg_a + DataBus + flag_C) ^ reg_a) & 0x80) && !((reg_a ^ DataBus) & 0x80) ) flag_V = 0x40; \
		else flag_V = 0; \
		dummy_flag = (((reg_a + DataBus + flag_C) & 0x100) >> 8); \
		reg_a = ((reg_a + DataBus + flag_C) & 0xff); \
		flag_C = dummy_flag; \
		test_zn(reg_a) \
	}else{ \
		dummy_low = (reg_a & 0xf) + (DataBus & 0xf) + flag_C; \
		dummy_high = ((reg_a & 0xf0) >> 4) + ((DataBus & 0xf0) >> 4);	/* + ((dummy_low & 0x10) >> 4); */ \
		if(dummy_low > 9) dummy_low += 6; \
		if (dummy_low > 0xf) dummy_high++; \
		test_z(((reg_a + DataBus + flag_C) & 0xff)) \
		test_n(((dummy_high << 4) | (dummy_low & 0xf))) \
		if( (((dummy_high << 4) ^ reg_a) & 0x80) && !((reg_a ^ DataBus) & 0x80) ) flag_V = 0x40; \
		else flag_V = 0; \
		if (dummy_high > 9) dummy_high += 6; \
		if (dummy_high > 0xf) flag_C = 0x1; \
		else flag_C = 0; \
		reg_a = ((dummy_high << 4) | (dummy_low & 0xf)) & 0xff; \
	}

#define RTI \
	readbank \
	AddressBus = reg_sp + 0x100; \
	readbank \
	reg_sp++; \
	AddressBus = reg_sp + 0x100; \
	readbank \
	flag_N = DataBus & 0x80; \
	flag_V = DataBus & 0x40; \
/*	flag_B = DataBus & 0x10; */ \
	flag_D = DataBus & 0x08; \
	flag_I = DataBus & 0x04; \
	flag_Z = DataBus & 0x02; \
	flag_C = DataBus & 0x01; \
	reg_sp++; \
	AddressBus = reg_sp + 0x100; \
	readbank \
	reg_pc = DataBus; \
	reg_sp++; \
	AddressBus = reg_sp + 0x100; \
	readbank \
	reg_pc = (DataBus << 8) + reg_pc;

#define RTS \
	readbank \
	AddressBus = reg_sp + 0x100; \
	readbank \
	reg_sp++; \
	AddressBus = reg_sp + 0x100; \
	readbank \
	reg_pc = DataBus; \
	reg_sp++; \
	AddressBus = reg_sp + 0x100; \
	readbank \
	reg_pc = (DataBus << 8) + reg_pc; \
	readbank \
	reg_pc++;

#define SAX \
	DataBus = (reg_a & reg_x); \
	writebank

#define SBC \
	readbank \
	if(!flag_D){ \
		if( (((reg_a + (0xff - DataBus) + flag_C) ^ reg_a) & 0x80) && !((reg_a ^ (0xff - DataBus)) & 0x80) ) flag_V = 0x40; \
		else flag_V = 0; \
		dummy_flag = (((reg_a + (0xff - DataBus) + flag_C) & 0x100) >> 8); \
		reg_a = ((reg_a + (0xff - DataBus) + flag_C) & 0xff); \
		flag_C = dummy_flag; \
		test_zn(reg_a) \
	}else{ \
		if( (((reg_a + (0xff - DataBus) + flag_C) ^ reg_a) & 0x80) && !((reg_a ^ (0xff - DataBus)) & 0x80) ) flag_V = 0x40; \
		else flag_V = 0; \
		dummy_flag = (((reg_a + (0xff - DataBus) + flag_C) & 0x100) >> 8); \
		dummy_low = ((reg_a + (0xff - DataBus) + flag_C) & 0xff); \
		test_zn(dummy_low) \
		dummy_low = (reg_a & 0xf) - (DataBus & 0xf) - (1 - flag_C); \
		dummy_high = (reg_a >> 4) - (DataBus >> 4) - ((dummy_low & 0x10) >> 4); \
		if (dummy_low & 0x10) dummy_low -= 6; \
		if (dummy_high & 0x10) dummy_high -= 6; \
		reg_a = ((dummy_high << 4) | (dummy_low & 0xf)) & 0xff; \
		flag_C = dummy_flag; \
		}

#define SBX \
	readbank \
	if(!((reg_x & reg_a) < DataBus)) flag_C = 1; \
	else flag_C = 0; \
	reg_x = ((reg_x & reg_a) - DataBus) & 0xff; \
	test_zn(reg_x)

#define SEC \
	readbank \
	flag_C = 1;

#define SED \
	readbank \
	flag_D = 8;

#define SEI \
	readbank \
	flag_I = 4;

#define SHA \
	DataBus = (((AddressBus + 0x100) & 0xff00) >> 8) & reg_x & reg_a; \
	writebank

#define SHS \
	DataBus = (((AddressBus + 0x100) & 0xff00) >> 8) & reg_x & reg_a; \
	reg_sp = (reg_a & reg_x); \
	writebank

#define SHX \
	DataBus = (((AddressBus + 0x100) & 0xff00) >> 8) & reg_x; \
	writebank

#define SHY \
	DataBus = (((AddressBus + 0x100) & 0xff00) >> 8) & reg_y; \
	writebank

#define SLO \
	flag_C = (DataBus & 0x80) >> 7; \
	DataBus = (DataBus << 1) & 0xfe; \
	reg_a |= DataBus; \
	test_zn(reg_a)

#define SRE \
	flag_C = DataBus & 0x01; \
	DataBus = (DataBus >> 1) & 0x7f; \
	reg_a ^= DataBus; \
	test_zn(reg_a)

#define STA \
	DataBus = reg_a; \
	writebank

#define STX \
	DataBus = reg_x; \
	writebank

#define STY \
	DataBus = reg_y; \
	writebank

#define TAX \
	readbank \
	reg_x = reg_a; \
	test_zn(reg_x)

#define TAY \
	readbank \
	reg_y = reg_a; \
	test_zn(reg_y)

#define TXA \
	readbank \
	reg_a = reg_x; \
	test_zn(reg_a)

#define TYA \
	readbank \
	reg_a = reg_y; \
	test_zn(reg_a)

#define TSX \
	readbank \
	reg_x = reg_sp; \
	test_zn(reg_x)

#define TXS \
	readbank \
	reg_sp = reg_x;

/*
	the opcode definitions
*/

opcode(_00,adr_implied,BRK)											/* 00 - BRK implied */
opcode(_01,adr_index_indirect,ORA)									/* 01 - ORA (indirect,x) */
																	/* 02 - JAM */
opcode(_03,adr_index_indirect,rmw_ram(SLO))							/* 03 - SLO (indirect,x) */
opcode(_04,adr_zeropage,NOP)										/* 04 - NOP zeropage */
opcode(_05,adr_zeropage,ORA)										/* 05 - ORA zeropage */
opcode(_06,adr_zeropage,rmw_ram(ASL(DataBus)))						/* 06 - ASL zeropage */
opcode(_07,adr_zeropage,rmw_ram(SLO))								/* 07 - SLO zeropage */
opcode(_08,adr_implied,PHP)											/* 08 - PHP implied */
opcode(_09,adr_immediate,ORA)										/* 09 - ORA immediate */
opcode(_0a,adr_implied,rmw_accu(ASL(reg_a)))						/* 0a - ASL implied */
opcode(_0b,adr_immediate,ANC)										/* 0b - ANC immediate */
opcode(_0c,adr_absolute,NOP)										/* 0c - NOP absolute */
opcode(_0d,adr_absolute,ORA)										/* 0d - ORA absolute */
opcode(_0e,adr_absolute,rmw_ram(ASL(DataBus)))						/* 0e - ASL absolute */
opcode(_0f,adr_absolute,rmw_ram(SLO))								/* 0f - SLO absolute */
opcode(_10,adr_implied,BPL)											/* 10 - BPL relative */
opcode(_11,adr_indirect_index_read,ORA)								/* 11 - ORA (indirect),y */
																	/* 12 - JAM */
opcode(_13,adr_indirect_index_write,rmw_ram(SLO))					/* 13 - SLO (indirect),y */
opcode(_14,adr_zeropage_index(reg_x),NOP)							/* 14 - NOP zeropage,x */
opcode(_15,adr_zeropage_index(reg_x),ORA)							/* 15 - ORA zeropage,x */
opcode(_16,adr_zeropage_index(reg_x),rmw_ram(ASL(DataBus)))			/* 16 - ASL zeropage,x */
opcode(_17,adr_zeropage_index(reg_x),rmw_ram(SLO))					/* 17 - SLO zeropage,x */
opcode(_18,adr_implied,CLC)											/* 18 - CLC implied */
opcode(_19,adr_absolute_index_read(reg_y),ORA)						/* 19 - ORA absolute,y */
opcode(_1a,adr_implied,NOP)											/* 1a - NOP implied */
opcode(_1b,adr_absolute_index_write(reg_y),rmw_ram(SLO))			/* 1b - SLO absolute,y */
opcode(_1c,adr_absolute_index_read(reg_x),NOP)						/* 1c - NOP absolute,x */
opcode(_1d,adr_absolute_index_read(reg_x),ORA)						/* 1d - ORA absolute,x */
opcode(_1e,adr_absolute_index_write(reg_x),rmw_ram(ASL(DataBus)))	/* 1e - ASL absolute,x */
opcode(_1f,adr_absolute_index_write(reg_x),rmw_ram(SLO))			/* 1f - SLO absolute,x */
opcode(_20,,JSR)													/* 20 - JSR absolute */
opcode(_21,adr_index_indirect,AND)									/* 21 - AND (indirect,x) */
																	/* 22 - JAM */
opcode(_23,adr_index_indirect,rmw_ram(RLA))							/* 23 - RLA (indirect,x) */
opcode(_24,adr_zeropage,BIT)										/* 24 - BIT zeropage */
opcode(_25,adr_zeropage,AND)										/* 25 - AND zeropage */
opcode(_26,adr_zeropage,rmw_ram(ROL(DataBus)))						/* 26 - ROL zeropage */
opcode(_27,adr_zeropage,rmw_ram(RLA))								/* 27 - RLA zeropage */
opcode(_28,adr_implied,PLP)											/* 28 - PLP implied */
opcode(_29,adr_immediate,AND)										/* 29 - AND immediate */
opcode(_2a,adr_implied,rmw_accu(ROL(reg_a)))						/* 2a - ROL implied */
opcode(_2b,adr_immediate,ANC)										/* 2b - ANC immediate */
opcode(_2c,adr_absolute,BIT)										/* 2c - BIT absolute */
opcode(_2d,adr_absolute,AND)										/* 2d - AND absolute */
opcode(_2e,adr_absolute,rmw_ram(ROL(DataBus)))						/* 2e - ROL absolute */
opcode(_2f,adr_absolute,rmw_ram(RLA))								/* 2f - RLA absolute */
opcode(_30,adr_implied,BMI)											/* 30 - BMI relative */
opcode(_31,adr_indirect_index_read,AND)								/* 31 - AND (indirect),y */
																	/* 32 - JAM */
opcode(_33,adr_indirect_index_write,rmw_ram(RLA))					/* 33 - RLA (indirect),y */
opcode(_34,adr_zeropage_index(reg_x),NOP)							/* 34 - NOP zeropage,x */
opcode(_35,adr_zeropage_index(reg_x),AND)							/* 35 - AND zeropage,x */
opcode(_36,adr_zeropage_index(reg_x),rmw_ram(ROL(DataBus)))			/* 36 - ROL zeropage,x */
opcode(_37,adr_zeropage_index(reg_x),rmw_ram(RLA))					/* 37 - RLA zeropage,x */
opcode(_38,adr_implied,SEC)											/* 38 - SEC implied */
opcode(_39,adr_absolute_index_read(reg_y),AND)						/* 39 - AND absolute,y */
opcode(_3a,adr_implied,NOP)											/* 3a - NOP implied */
opcode(_3b,adr_absolute_index_write(reg_y),rmw_ram(RLA))			/* 3b - RLA absolute,y */
opcode(_3c,adr_absolute_index_read(reg_x),NOP)						/* 3c - NOP absolute,x */
opcode(_3d,adr_absolute_index_read(reg_x),AND)						/* 3d - AND absolute,x */
opcode(_3e,adr_absolute_index_write(reg_x),rmw_ram(ROL(DataBus)))	/* 3e - ROL absolute,x */
opcode(_3f,adr_absolute_index_write(reg_x),rmw_ram(RLA))			/* 3f - RLA absolute,x */
opcode(_40,adr_implied,RTI)											/* 40 - RTI implied */
opcode(_41,adr_index_indirect,EOR)									/* 41 - EOR (indirect,x) */
																	/* 42 - JAM */
opcode(_43,adr_index_indirect,rmw_ram(SRE))							/* 43 - SRE (indirect,x) */
opcode(_44,adr_zeropage,NOP)										/* 44 - NOP zeropage */
opcode(_45,adr_zeropage,EOR)										/* 45 - EOR zeropage */
opcode(_46,adr_zeropage,rmw_ram(LSR(DataBus)))						/* 46 - LSR zeropage */
opcode(_47,adr_zeropage,rmw_ram(SRE))								/* 47 - SRE zeropage */
opcode(_48,adr_implied,PHA)											/* 48 - PHA implied */
opcode(_49,adr_immediate,EOR)										/* 49 - EOR immediate */
opcode(_4a,adr_implied,rmw_accu(LSR(reg_a)))						/* 4a - LSR implied */
opcode(_4b,adr_immediate,ASR)										/* 4b - ASR immediate */
opcode(_4c,adr_absolute,JMP)										/* 4c - JMP absolute */
opcode(_4d,adr_absolute,EOR)										/* 4d - EOR absolute */
opcode(_4e,adr_absolute,rmw_ram(LSR(DataBus)))						/* 4e - LSR absolute */
opcode(_4f,adr_absolute,rmw_ram(SRE))								/* 4f - SRE absolute */
opcode(_50,adr_implied,BVC)											/* 50 - BVC relative */
opcode(_51,adr_indirect_index_read,EOR)								/* 51 - EOR (indirect),y */
																	/* 52 - JAM */
opcode(_53,adr_indirect_index_write,rmw_ram(SRE))					/* 53 - SRE (indirect),y */
opcode(_54,adr_zeropage_index(reg_x),NOP)							/* 54 - NOP zeropage,x */
opcode(_55,adr_zeropage_index(reg_x),EOR)							/* 55 - EOR zeropage,x */
opcode(_56,adr_zeropage_index(reg_x),rmw_ram(LSR(DataBus)))			/* 56 - LSR zeropage,x */
opcode(_57,adr_zeropage_index(reg_x),rmw_ram(SRE))					/* 57 - SRE zeropage,x */
opcode(_58,adr_implied,CLI)											/* 58 - CLI implied */
opcode(_59,adr_absolute_index_read(reg_y),EOR)						/* 59 - EOR absolute,y */
opcode(_5a,adr_implied,NOP)											/* 5a - NOP implied */
opcode(_5b,adr_absolute_index_write(reg_y),rmw_ram(SRE))			/* 5b - SRE absolute,y */
opcode(_5c,adr_absolute_index_read(reg_x),NOP)						/* 5c - NOP absolute,x */
opcode(_5d,adr_absolute_index_read(reg_x),EOR)						/* 5d - EOR absolute,x */
opcode(_5e,adr_absolute_index_write(reg_x),rmw_ram(LSR(DataBus)))	/* 5e - LSR absolute,x */
opcode(_5f,adr_absolute_index_write(reg_x),rmw_ram(SRE))			/* 5f - SRE absolute,x */
opcode(_60,adr_implied,RTS)											/* 60 - RTS implied */
opcode(_61,adr_index_indirect,ADC)									/* 61 - ADC (indirect,x) */
																	/* 62 - JAM */
opcode(_63,adr_index_indirect,rmw_ram(RRA))							/* 63 - RRA (indirect,x) */
opcode(_64,adr_zeropage,NOP)										/* 64 - NOP zeropage */
opcode(_65,adr_zeropage,ADC)										/* 65 - ADC zeropage */
opcode(_66,adr_zeropage,rmw_ram(ROR(DataBus)))						/* 66 - ROR zeropage */
opcode(_67,adr_zeropage,rmw_ram(RRA))								/* 67 - RRA zeropage */
opcode(_68,adr_implied,PLA)											/* 68 - PLA implied */
opcode(_69,adr_immediate,ADC)										/* 69 - ADC immediate */
opcode(_6a,adr_implied,rmw_accu(ROR(reg_a)))						/* 6a - ROR implied */
opcode(_6b,adr_immediate,ARR)										/* 6b - ARR immediate */
opcode(_6c,adr_absolute_indirect,JMP)								/* 6c - JMP (indirect) */
opcode(_6d,adr_absolute,ADC)										/* 6d - ADC absolute */
opcode(_6e,adr_absolute,rmw_ram(ROR(DataBus)))						/* 6e - ROR absolute */
opcode(_6f,adr_absolute,rmw_ram(RRA))								/* 6f - RRA absolute */
opcode(_70,adr_implied,BVS)											/* 70 - BVS relative */
opcode(_71,adr_indirect_index_read,ADC)								/* 71 - ADC (indirect),y */
																	/* 72 - JAM */
opcode(_73,adr_indirect_index_write,rmw_ram(RRA))					/* 73 - RRA (indirect),y */
opcode(_74,adr_zeropage_index(reg_x),NOP)							/* 74 - NOP zeropage,x */
opcode(_75,adr_zeropage_index(reg_x),ADC)							/* 75 - ADC zeropage,x */
opcode(_76,adr_zeropage_index(reg_x),rmw_ram(ROR(DataBus)))			/* 76 - ROR zeropage,x */
opcode(_77,adr_zeropage_index(reg_x),rmw_ram(RRA))					/* 77 - RRA zeropage,x */
opcode(_78,adr_implied,SEI)											/* 78 - SEI implied */
opcode(_79,adr_absolute_index_read(reg_y),ADC)						/* 79 - ADC absolute,y */
opcode(_7a,adr_implied,NOP)											/* 7a - NOP implied */
opcode(_7b,adr_absolute_index_write(reg_y),rmw_ram(RRA))			/* 7b - RRA absolute,y */
opcode(_7c,adr_absolute_index_read(reg_x),NOP)						/* 7c - NOP absolute,x */
opcode(_7d,adr_absolute_index_read(reg_x),ADC)						/* 7d - ADC absolute,x */
opcode(_7e,adr_absolute_index_write(reg_x),rmw_ram(ROR(DataBus)))	/* 7e - ROR absolute,x */
opcode(_7f,adr_absolute_index_write(reg_x),rmw_ram(RRA))			/* 7f - RRA absolute,x */
opcode(_80,adr_immediate,NOP)										/* 80 - NOP immediate */
opcode(_81,adr_index_indirect,STA)									/* 81 - STA (indirect,x) */
opcode(_82,adr_immediate,NOP)										/* 82 - NOP immediate */
opcode(_83,adr_index_indirect,SAX)									/* 83 - SAX (indirect),x */
opcode(_84,adr_zeropage,STY)										/* 84 - STY zeropage */
opcode(_85,adr_zeropage,STA)										/* 85 - STA zeropage */
opcode(_86,adr_zeropage,STX)										/* 86 - STX zeropage */
opcode(_87,adr_zeropage,SAX)										/* 87 - SAX zeropage */
opcode(_88,adr_implied,DEY)											/* 88 - DEY implied */
opcode(_89,adr_immediate,NOP)										/* 89 - NOP immediate */
opcode(_8a,adr_implied,TXA)											/* 8a - TXA implied */
opcode(_8b,adr_immediate,ANE)										/* 8b - ANE immediate */
opcode(_8c,adr_absolute,STY)										/* 8c - STY absolute */
opcode(_8d,adr_absolute,STA)										/* 8d - STA absolute */
opcode(_8e,adr_absolute,STX)										/* 8e - STX absolute */
opcode(_8f,adr_absolute,SAX)										/* 8f - SAX absolute */
opcode(_90,adr_implied,BCC)											/* 90 - BCC relative */
opcode(_91,adr_indirect_index_write,STA)							/* 91 - STA (indirect),y */
																	/* 92 - JAM */
opcode(_93,adr_indirect_index_write,SHA)							/* 93 - SHA (indirect),y */
opcode(_94,adr_zeropage_index(reg_x),STY)							/* 94 - STY zeropage,x */
opcode(_95,adr_zeropage_index(reg_x),STA)							/* 95 - STA zeropage,x */
opcode(_96,adr_zeropage_index(reg_y),STX)							/* 96 - STX zeropage,y */
opcode(_97,adr_zeropage_index(reg_y),SAX)							/* 97 - SAX zeropage,y */
opcode(_98,adr_implied,TYA)											/* 98 - TYA implied */
opcode(_99,adr_absolute_index_write(reg_y),STA)						/* 99 - STA absolute,y */
opcode(_9a,adr_implied,TXS)											/* 9a - TXS implied */
opcode(_9b,adr_absolute_index_write(reg_y),SHS)						/* 9b - SHS absolute,y */
opcode(_9c,adr_absolute_index_write(reg_x),SHY)						/* 9c - SHY absolute,x */
opcode(_9d,adr_absolute_index_write(reg_x),STA)						/* 9d - STA absolute,x */
opcode(_9e,adr_absolute_index_write(reg_y),SHX)						/* 9e - SHX absolute,y */
opcode(_9f,adr_absolute_index_write(reg_y),SHA)						/* 9f - SHA absolute,y */
opcode(_a0,adr_immediate,LDY)										/* a0 - LDY immediate */
opcode(_a1,adr_index_indirect,LDA)									/* a1 - LDA (indirect,x) */
opcode(_a2,adr_immediate,LDX)										/* a2 - LDX immediate */
opcode(_a3,adr_index_indirect,LAX)									/* a3 - LAX (indirect,x) */
opcode(_a4,adr_zeropage,LDY)										/* a4 - LDY zeropage */
opcode(_a5,adr_zeropage,LDA)										/* a5 - LDA zeropage */
opcode(_a6,adr_zeropage,LDX)										/* a6 - LDX zeropage */
opcode(_a7,adr_zeropage,LAX)										/* a7 - LAX zeropage */
opcode(_a8,adr_implied,TAY)											/* a8 - TAY implied */
opcode(_a9,adr_immediate,LDA)										/* a9 - LDA immediate */
opcode(_aa,adr_implied,TAX)											/* aa - TAX implied */
opcode(_ab,adr_immediate,LXA)										/* ab - LXA immediate */
opcode(_ac,adr_absolute,LDY)										/* ac - LDY absolute */
opcode(_ad,adr_absolute,LDA)										/* ad - LDA absolute */
opcode(_ae,adr_absolute,LDX)										/* ae - LDX absolute */
opcode(_af,adr_absolute,LAX)										/* af - LAX absolute */
opcode(_b0,adr_implied,BCS)											/* b0 - BCS relative */
opcode(_b1,adr_indirect_index_read,LDA)								/* b1 - LDA (indirect),y */
																	/* b2 - JAM */
opcode(_b3,adr_indirect_index_read,LAX)								/* b3 - LAX (indirect),y */
opcode(_b4,adr_zeropage_index(reg_x),LDY)							/* b4 - LDY zeropage,x */
opcode(_b5,adr_zeropage_index(reg_x),LDA)							/* b5 - LDA zeropage,x */
opcode(_b6,adr_zeropage_index(reg_y),LDX)							/* b6 - LDX zeropage,y */
opcode(_b7,adr_zeropage_index(reg_y),LAX)							/* b7 - LAX zeropage,Y */
opcode(_b8,adr_implied,CLV)											/* b8 - CLV implied */
opcode(_b9,adr_absolute_index_read(reg_y),LDA)						/* b9 - LDA absolute,y */
opcode(_ba,adr_implied,TSX)											/* ba - TSX implied */
opcode(_bb,adr_absolute_index_read(reg_y),LAS)						/* bb - LAS absolute,y */
opcode(_bc,adr_absolute_index_read(reg_x),LDY)						/* bc - LDY absolute,x */
opcode(_bd,adr_absolute_index_read(reg_x),LDA)						/* bd - LDA absolute,x */
opcode(_be,adr_absolute_index_read(reg_y),LDX)						/* be - LDX absolute,y */
opcode(_bf,adr_absolute_index_read(reg_y),LAX)						/* bf - LAX absolute,y */
opcode(_c0,adr_immediate,CPY)										/* c0 - CPY immediate */
opcode(_c1,adr_index_indirect,CMP)									/* c1 - CMP (indirect,x) */
opcode(_c2,adr_immediate,NOP)										/* c2 - NOP immediate */
opcode(_c3,adr_index_indirect,rmw_ram(DCP))							/* c3 - DCP (indirect,x) */
opcode(_c4,adr_zeropage,CPY)										/* c4 - CPY zeropage */
opcode(_c5,adr_zeropage,CMP)										/* c5 - CMP zeropage */
opcode(_c6,adr_zeropage,rmw_ram(DEC))								/* c6 - DEC zeropage */
opcode(_c7,adr_zeropage,rmw_ram(DCP))								/* c7 - DCP zeropage */
opcode(_c8,adr_implied,INY)											/* c8 - INY implied */
opcode(_c9,adr_immediate,CMP)										/* c9 - CMP immediate */
opcode(_ca,adr_implied,DEX)											/* ca - DEX implied */
opcode(_cb,adr_immediate,SBX)										/* cb - SBX immediate */
opcode(_cc,adr_absolute,CPY)										/* cc - CPY absolute */
opcode(_cd,adr_absolute,CMP)										/* cd - CMP absolute */
opcode(_ce,adr_absolute,rmw_ram(DEC))								/* ce - DEC absolute */
opcode(_cf,adr_absolute,rmw_ram(DCP))								/* cf - DCP absolute */
opcode(_d0,adr_implied,BNE)											/* d0 - BNE relative */
opcode(_d1,adr_indirect_index_read,CMP)								/* d1 - CMP (indirect),y */
																	/* d2 - JAM */
opcode(_d3,adr_indirect_index_write,rmw_ram(DCP))					/* d3 - DCP (indirect),y */
opcode(_d4,adr_zeropage_index(reg_x),NOP)							/* d4 - NOP zeropage,x */
opcode(_d5,adr_zeropage_index(reg_x),CMP)							/* d5 - CMP zeropage,x */
opcode(_d6,adr_zeropage_index(reg_x),rmw_ram(DEC))					/* d6 - DEC zeropage,x */
opcode(_d7,adr_zeropage_index(reg_x),rmw_ram(DCP))					/* d7 - DCP zeropage,x */
opcode(_d8,adr_implied,CLD)											/* d8 - CLD implied */
opcode(_d9,adr_absolute_index_read(reg_y),CMP)						/* d9 - CMP absolute,y */
opcode(_da,adr_implied,NOP)											/* da - NOP implied */
opcode(_db,adr_absolute_index_write(reg_y),rmw_ram(DCP))			/* db - DCP absolute,y */
opcode(_dc,adr_absolute_index_read(reg_x),NOP)						/* dc - NOP absolute,x */
opcode(_dd,adr_absolute_index_read(reg_x),CMP)						/* dd - CMP absolute,x */
opcode(_de,adr_absolute_index_write(reg_x),rmw_ram(DEC))			/* de - DEC absolute,x */
opcode(_df,adr_absolute_index_write(reg_x),rmw_ram(DCP))			/* df - DCP absolute,x */
opcode(_e0,adr_immediate,CPX)										/* e0 - CPX immediate */
opcode(_e1,adr_index_indirect,SBC)									/* e1 - SBC (indirect,x) */
opcode(_e2,adr_immediate,NOP)										/* e2 - NOP immediate */
opcode(_e3,adr_index_indirect,rmw_ram(ISB))							/* e3 - ISB (indirect,x) */
opcode(_e4,adr_zeropage,CPX)										/* e4 - CPX zeropage */
opcode(_e5,adr_zeropage,SBC)										/* e5 - SBC zeropage */
opcode(_e6,adr_zeropage,rmw_ram(INC))								/* e6 - INC zeropage */
opcode(_e7,adr_zeropage,rmw_ram(ISB))								/* e7 - ISB zeropage */
opcode(_e8,adr_implied,INX)											/* e8 - INX implied */
opcode(_e9,adr_immediate,SBC)										/* e9 - SBC immediate */
opcode(_ea,adr_implied,NOP)											/* ea - NOP implied (this is the real one) */
opcode(_eb,adr_immediate,SBC)										/* eb - SBC immediate */
opcode(_ec,adr_absolute,CPX)										/* ec - CPX absolute */
opcode(_ed,adr_absolute,SBC)										/* ed - SBC absolute */
opcode(_ee,adr_absolute,rmw_ram(INC))								/* ee - INC absolute */
opcode(_ef,adr_absolute,rmw_ram(ISB))								/* ef - ISB absolute */
opcode(_f0,adr_implied,BEQ)											/* f0 - BEQ relative */
opcode(_f1,adr_indirect_index_read,SBC)								/* f1 - SBC (indirect),y */
																	/* f2 - JAM */
opcode(_f3,adr_indirect_index_write,rmw_ram(ISB))					/* f3 - ISB (indirect),y */
opcode(_f4,adr_zeropage_index(reg_x),NOP)							/* f4 - NOP zeropage,x */
opcode(_f5,adr_zeropage_index(reg_x),SBC)							/* f5 - SBC zeropage,x */
opcode(_f6,adr_zeropage_index(reg_x),rmw_ram(INC))					/* f6 - INC zeropage,x */
opcode(_f7,adr_zeropage_index(reg_x),rmw_ram(ISB))					/* f7 - ISB zeropage,x */
opcode(_f8,adr_implied,SED)											/* f8 - SED implied */
opcode(_f9,adr_absolute_index_read(reg_y),SBC)						/* f9 - SBC absolute,y */
opcode(_fa,adr_implied,NOP)											/* fa - NOP implied */
opcode(_fb,adr_absolute_index_write(reg_y),rmw_ram(ISB))			/* fb - ISB absolute,y */
opcode(_fc,adr_absolute_index_read(reg_x),NOP)						/* fc - NOP absolute,x */
opcode(_fd,adr_absolute_index_read(reg_x),SBC)						/* fd - SBC absolute,x */
opcode(_fe,adr_absolute_index_write(reg_x),rmw_ram(INC))			/* fe - INC absolute,x */
opcode(_ff,adr_absolute_index_write(reg_x),rmw_ram(ISB))			/* ff - ISB absolute,x */

/*
	opcode vector table

 note:  the jam handler should be defined externally
        (since it is typically environment dependent)
*/

void (* vectors[256])(void) = {
	_00,_01,jam,_03,_04,_05,_06,_07,_08,_09,_0a,_0b,_0c,_0d,_0e,_0f,
	_10,_11,jam,_13,_14,_15,_16,_17,_18,_19,_1a,_1b,_1c,_1d,_1e,_1f,
	_20,_21,jam,_23,_24,_25,_26,_27,_28,_29,_2a,_0b,_2c,_2d,_2e,_2f,	/* _2b=_0b */
	_30,_31,jam,_33,_34,_35,_36,_37,_38,_39,_3a,_3b,_3c,_3d,_3e,_3f,
	_40,_41,jam,_43,_44,_45,_46,_47,_48,_49,_4a,_4b,_4c,_4d,_4e,_4f,
	_50,_51,jam,_53,_54,_55,_56,_57,_58,_59,_5a,_5b,_5c,_5d,_5e,_5f,
	_60,_61,jam,_63,_64,_65,_66,_67,_68,_69,_6a,_6b,_6c,_6d,_6e,_6f,
	_70,_71,jam,_73,_74,_75,_76,_77,_78,_79,_7a,_7b,_7c,_7d,_7e,_7f,
	_80,_81,_82,_83,_84,_85,_86,_87,_88,_89,_8a,_8b,_8c,_8d,_8e,_8f,
	_90,_91,jam,_93,_94,_95,_96,_97,_98,_99,_9a,_9b,_9c,_9d,_9e,_9f,
	_a0,_a1,_a2,_a3,_a4,_a5,_a6,_a7,_a8,_a9,_aa,_ab,_ac,_ad,_ae,_af,
	_b0,_b1,jam,_b3,_b4,_b5,_b6,_b7,_b8,_b9,_ba,_bb,_bc,_bd,_be,_bf,
	_c0,_c1,_c2,_c3,_c4,_c5,_c6,_c7,_c8,_c9,_ca,_cb,_cc,_cd,_ce,_cf,
	_d0,_d1,jam,_d3,_d4,_d5,_d6,_d7,_d8,_d9,_da,_db,_dc,_dd,_de,_df,
	_e0,_e1,_e2,_e3,_e4,_e5,_e6,_e7,_e8,_e9,_ea,_e9,_ec,_ed,_ee,_ef,	/* _eb=_e9 */
	_f0,_f1,jam,_f3,_f4,_f5,_f6,_f7,_f8,_f9,_fa,_fb,_fc,_fd,_fe,_ff
};


/*
	Initialise the 6502/6507 CPU emulator
*/

void Init_CPU(void) {
	reg_pc = 0;		/*  program counter */
	reg_sp = 0;		/*  stack pointer */
	reg_a = 0;		/*  accumulator (stored in AL) */
	flag_C = 0;		/*  carry bit   (stored in AH) */
	reg_x = 0;		/*  x register */
	reg_y = 0;		/*  y register */
	flag_Z = 0;		/*  zero test value (Z set when 0) */
	flag_N = 0;		/*  sign test value (N set when negative) */
	flag_D = 0;		/*  decimal flag */
	flag_V = 0;		/*  overflow flag */
	flag_I = 0;		/*  interrupt disable flag */
	flag_B = 0;		/*  break flag */
 	flag_B = 0x10;	/* B flag is always set exept when pushing the status byte after a hardware IRQ */
	RCycles = 0;		/*  cycles per instruction */
	RClock = 0;		/*  clock cycles */

	TriggerWSYNC = 0;	/* TIA tells CPU to pause on next read cycle */
}

/*
	Reset the CPU
*/

void Reset(void) {
	reg_sp = 0xff;
	AddressBus = 0xfffc;		// get reset vector from $fffc + $fffd
	readbank
	reg_pc = DataBus;
	AddressBus++;
	readbank
	reg_pc += (DataBus << 8);
	RClock = 0;
}

/*
	do a single instruction
*/

void do_Instruction(void) {
	if (TraceCount) TraceInstruction();
	RCycles = 0;
	AddressBus = reg_pc;
	readbank
	reg_pc++;
	AddressBus = reg_pc;
	(* vectors[DataBus])();
}
