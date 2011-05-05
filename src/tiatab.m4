#ifdef C_TIATAB
/* 
** tiatab.m4 -- tables needed for z26 TIA emulator
**
** 09-07-02 -- 32-bit
*/

/*
** playfield counter to playfield bit table
**
**	  PF2		|	  PF1		|	  PF0		|
** 7  6	 5  4  3  2  1  0  7  6  5  4  3  2  1  0  7  6  5  4  3  2  1  0
**23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
**				  ECX					|
*/

dd PFClockToBitReversed[] = {
	1<<4,	/*  0	forward */
	1<<5,	/*  1 */
	1<<6,	/*  2 */
	1<<7,	/*  3 */
	1<<15,	/*  4 */
	1<<14,	/*  5 */
	1<<13,	/*  6 */
	1<<12,	/*  7 */
	1<<11,	/*  8 */
	1<<10,	/*  9 */
	1<<9,	/*  10 */
	1<<8,	/*  11 */
	1<<16,	/*  12 */
	1<<17,	/*  13 */
	1<<18,	/*  14 */
	1<<19,	/*  15 */
	1<<20,	/*  16 */
	1<<21,	/*  17 */
	1<<22,	/*  18 */
	1<<23,	/*  19 */
			 
	1<<23,	/*  20	reversed */
	1<<22,	/*  21 */
	1<<21,	/*  22 */
	1<<20,	/*  23 */
	1<<19,	/*  24 */
	1<<18,	/*  25 */
	1<<17,	/*  26 */
	1<<16,	/*  27 */
	1<<8,	/*  28 */
	1<<9,	/*  29 */
	1<<10,	/*  30 */
	1<<11,	/*  31 */
	1<<12,	/*  32 */
	1<<13,	/*  33 */
	1<<14,	/*  34 */
	1<<15,	/*  35 */
	1<<7,	/*  36 */
	1<<6,	/*  37 */
	1<<5,	/*  38 */
	1<<4	/*  39 */
};

dd PFClockToBitForward[] = {
	1<<4,	/* 0	forward */
	1<<5,	/* 1 */
	1<<6,	/* 2 */
	1<<7,	/* 3 */
	1<<15,	/* 4 */
	1<<14,	/* 5 */
	1<<13,	/* 6 */
	1<<12,	/* 7 */
	1<<11,	/* 8 */
	1<<10,	/* 9 */
	1<<9,	/* 10 */
	1<<8,	/* 11 */
	1<<16,	/* 12 */
	1<<17,	/* 13 */
	1<<18,	/* 14 */
	1<<19,	/* 15 */
	1<<20,	/* 16 */
	1<<21,	/* 17 */
	1<<22,	/* 18 */
	1<<23,	/* 19 */
			  
	1<<4,	/* 0	forward */
	1<<5,	/* 1 */
	1<<6,	/* 2 */
	1<<7,	/* 3 */
	1<<15,	/* 4 */
	1<<14,	/* 5 */
	1<<13,	/* 6 */
	1<<12,	/* 7 */
	1<<11,	/* 8 */
	1<<10,	/* 9 */
	1<<9,	/* 10 */
	1<<8,	/* 11 */
	1<<16,	/* 12 */
	1<<17,	/* 13 */
	1<<18,	/* 14 */
	1<<19,	/* 15 */
	1<<20,	/* 16 */
	1<<21,	/* 17 */
	1<<22,	/* 18 */
	1<<23	/* 19 */
};

/*
** pixel to collision word
*/

dd TIAColTab[] = {
	0,	/* 0    */
	0,	/* 0    */
	0,	/* 0    */
	8192,	/* 2000 */
	0,	/* 0    */
	128,	/* 80   */
	64,	/* 40   */
	8384,	/* 20c0 */
	0,	/* 0    */
	2048,	/* 800  */
	1024,	/* 400  */
	11264,	/* 2c00 */
	4,	/* 4    */
	2180,	/* 884  */
	1092,	/* 444  */
	11460,	/* 2cc4 */
	0,	/* 0    */
	32,	/* 20   */
	16,	/* 10   */
	8240,	/* 2030 */
	32768,	/* 8000 */
	32928,	/* 80a0 */
	32848,	/* 8050 */
	41200,	/* a0f0 */
	8,	/* 8    */
	2088,	/* 828  */
	1048,	/* 418  */
	11320,	/* 2c38 */
	32780,	/* 800c */
	34988,	/* 88ac */
	33884,	/* 845c */
	44284,	/* acfc */
	0,	/* 0    */
	512,	/* 200  */
	256,	/* 100  */
	8960,	/* 2300 */
	2,	/* 2    */
	642,	/* 282  */
	322,	/* 142  */
	9154,	/* 23c2 */
	16384,	/* 4000 */
	18944,	/* 4a00 */
	17664,	/* 4500 */
	28416,	/* 6f00 */
	16390,	/* 4006 */
	19078,	/* 4a86 */
	17734,	/* 4546 */
	28614,	/* 6fc6 */
	1,	/* 1    */
	545,	/* 221  */
	273,	/* 111  */
	9009,	/* 2331 */
	32771,	/* 8003 */
	33443,	/* 82a3 */
	33107,	/* 8153 */
	41971,	/* a3f3 */
	16393,	/* 4009 */
	18985,	/* 4a29 */
	17689,	/* 4519 */
	28473,	/* 6f39 */
	49167,	/* c00f */
	51887,	/* caaf */
	50527,	/* c55f */
	61439	/* efff */
};

db TIADisplayToColour[] = {
 0,1,4,4,2,2,2,2,2,2,2,2,2,2,2,2,
 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
};

db TIADisplayToColour2[] = {
 0,1,4,1,2,1,4,1,2,1,4,1,2,1,4,1,
 3,1,4,1,3,1,4,1,3,1,4,1,3,1,4,1,
 3,1,4,1,3,1,4,1,3,1,4,1,3,1,4,1,
 3,1,4,1,3,1,4,1,3,1,4,1,3,1,4,1
};

dd *PF_Table = PFClockToBitForward;		/* current pointer to playfield mask bits */
db *PixelColorTable = TIADisplayToColour;	/* pixel to color translation table */

/*
** sprite definitions
**
** The top bit of the delay byte is the triple flag.
** This means subsequent RESPx outputs the leading sprite.
**
** Note:  There is an entry just before the first entry of a single-width 
**	  player sprite that is not there, that should have the triple flag
**	  set.	That is there should be four entries with the triple flag set.
*/ 

define(LeadingPlayer,`
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	10,
	0,	9,
	1<<7,	8,
	1<<6,	7,
	1<<5,	6,
	1<<4,	5,
	1<<3,	4,
	1<<2,	3,
	1<<1,	2,
	1,	1,
	0,	0,
')


define(BlankPlayer,`
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	10,
	0,	9,
	0,	8,
	0,	7,
	0,	6,
	0,	5,
	0,	4,
	0,	3,
	0,	2,
	0,	1,
	0,	0,
')


define(TrailingPlayer,`
	0,	0,
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	10,
	0,	9,
	1<<7,	8,
	1<<6,	7,
	1<<5,	6,
	1<<4,	5,
	1<<3,	4,
	1<<2,	3,
	1<<1,	2,
	1,	1,
	0,	0,
')


define(LeadingMissile,`
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	0,
	1<<7,	8,
	1<<6,	7,
	1<<5,	6,
	1<<4,	5,
	1<<3,	4,
	1<<2,	3,
	1<<1,	2,
	1,	1,
	0,	0,
')


define(BlankMissile,`
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	0,
	0,	8,
	0,	7,
	0,	6,
	0,	5,
	0,	4,
	0,	3,
	0,	2,
	0,	1,
	0,	0,
')


define(TrailingMissile,`
	0,	0,
	0,	0,
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	0,
	1<<7,	8,
	1<<6,	7,
	1<<5,	6,
	1<<4,	5,
	1<<3,	4,
	1<<2,	3,
	1<<1,	2,
	1,	1,
	0,	0,
')


define(MediumGap,`
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
')


define(WideGap,`
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
')


/*
** Medium and wide players have an extra leading clock.
** They have the extra triple flag too.
*/

define(MediumPlayer,`
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	18,
	0,	17,
	1<<7,	16,
	1<<7,	15,
	1<<6,	14,
	1<<6,	13,
	1<<5,	12,
	1<<5,	11,
	1<<4,	10,
	1<<4,	9,
	1<<3,	8,
	1<<3,	7,
	1<<2,	6,
	1<<2,	5,
	1<<1,	4,
	1<<1,	3,
	1,	2,
	1,	1,
	0,	0,
')


define(MediumBlankPlayer,`
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	18,
	0,	17,
	0,	16,
	0,	15,
	0,	14,
	0,	13,
	0,	12,
	0,	11,
	0,	10,
	0,	9,
	0,	8,
	0,	7,
	0,	6,
	0,	5,
	0,	4,
	0,	3,
	0,	2,
	0,	1,
	0,	0,
')


define(WidePlayer,`
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	34,
	0,	33,
	1<<7,	32,
	1<<7,	31,
	1<<7,	30,
	1<<7,	29,
	1<<6,	28,
	1<<6,	27,
	1<<6,	26,
	1<<6,	25,
	1<<5,	24,
	1<<5,	23,
	1<<5,	22,
	1<<5,	21,
	1<<4,	20,
	1<<4,	19,
	1<<4,	18,
	1<<4,	17,
	1<<3,	16,
	1<<3,	15,
	1<<3,	14,
	1<<3,	13,
	1<<2,	12,
	1<<2,	11,
	1<<2,	10,
	1<<2,	9,
	1<<1,	8,
	1<<1,	7,
	1<<1,	6,
	1<<1,	5,
	1,	4,
	1,	3,
	1,	2,
	1,	1,
	0,	0,
')


define(WideBlankPlayer,`
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	0x80,
	0,	34,
	0,	33,
	0,	32,
	0,	31,
	0,	30,
	0,	29,
	0,	28,
	0,	27,
	0,	26,
	0,	25,
	0,	24,
	0,	23,
	0,	22,
	0,	21,
	0,	20,
	0,	19,
	0,	18,
	0,	17,
	0,	16,
	0,	15,
	0,	14,
	0,	13,
	0,	12,
	0,	11,
	0,	10,
	0,	9,
	0,	8,
	0,	7,
	0,	6,
	0,	5,
	0,	4,
	0,	3,
	0,	2,
	0,	1,
	0,	0,
')


/*
** default sprite definitions as a function of NUSIZ
*/

db P_0[] = { LeadingPlayer 0 };
db P_1[] = { LeadingPlayer TrailingPlayer 0 };
db P_2[] = { LeadingPlayer MediumGap TrailingPlayer 0 };
db P_3[] = { LeadingPlayer TrailingPlayer TrailingPlayer 0 };
db P_4[] = { LeadingPlayer WideGap TrailingPlayer 0 };
db P_5[] = { MediumPlayer 0 };
db P_6[] = { LeadingPlayer MediumGap TrailingPlayer MediumGap TrailingPlayer 0 };
db P_7[] = { WidePlayer 0 };

db M_0[] = { LeadingMissile 0 };
db M_1[] = { LeadingMissile TrailingMissile 0 };
db M_2[] = { LeadingMissile MediumGap TrailingMissile 0 };
db M_3[] = { LeadingMissile TrailingMissile TrailingMissile 0 };
db M_4[] = { LeadingMissile WideGap TrailingMissile 0 };
db M_5[] = { LeadingMissile 0 };
db M_6[] = { LeadingMissile MediumGap TrailingMissile MediumGap TrailingMissile 0 };
db M_7[] = { LeadingMissile 0 };

db P0_Sprite[] = { LeadingPlayer 0 };
db P1_Sprite[] = { LeadingPlayer 0 };	
db BL_Sprite[] = { LeadingMissile 0 };
db M0_Sprite[] = { LeadingMissile 0 };
db M1_Sprite[] = { LeadingMissile 0 };

/*
** multi sprite definitions
*/
	
db MP_0[] = { BlankPlayer 0 };
db MP_1[] = { BlankPlayer TrailingPlayer 0 };
db MP_2[] = { BlankPlayer MediumGap TrailingPlayer 0 };
db MP_3[] = { BlankPlayer TrailingPlayer TrailingPlayer 0 };
db MP_4[] = { BlankPlayer WideGap TrailingPlayer 0 };
db MP_5[] = { MediumBlankPlayer 0 };
db MP_6[] = { BlankPlayer MediumGap TrailingPlayer MediumGap TrailingPlayer 0 };
db MP_7[] = { WideBlankPlayer 0 };

db MM_0[] = { BlankMissile 0 };
db MM_1[] = { BlankMissile TrailingMissile 0 };
db MM_2[] = { BlankMissile MediumGap TrailingMissile 0 };
db MM_3[] = { BlankMissile TrailingMissile TrailingMissile 0 };
db MM_4[] = { BlankMissile WideGap TrailingMissile 0 };
db MM_5[] = { BlankMissile 0 };
db MM_6[] = { BlankMissile MediumGap TrailingMissile MediumGap TrailingMissile 0 };
db MM_7[] = { BlankMissile 0 };

#define P_0_Size 0x0d
#define P_1_Size 0x1d
#define P_2_Size 0x2d
#define P_3_Size 0x2d
#define P_4_Size 0x4d
#define P_5_Size 0x16
#define P_6_Size 0x4d
#define P_7_Size 0x26

#define M_0_Size 0x0c
#define M_1_Size 0x1c
#define M_2_Size 0x2c
#define M_3_Size 0x2c
#define M_4_Size 0x4c
#define M_5_Size 0x0c
#define M_6_Size 0x4c
#define M_7_Size 0x0c

#define P0_SpriteSize 13 
#define P1_SpriteSize 13
#define M0_SpriteSize 12 
#define M1_SpriteSize 12 
#define BL_SpriteSize 12

db *P0_RegularTable[] = { P_0, P_1, P_2, P_3, P_4, P_5, P_6, P_7 };
db *P1_RegularTable[] = { P_0, P_1, P_2, P_3, P_4, P_5, P_6, P_7 };

db P0_SizeTable[] = { P_0_Size, P_1_Size, P_2_Size, P_3_Size, P_4_Size, P_5_Size, P_6_Size, P_7_Size };
db P1_SizeTable[] = { P_0_Size, P_1_Size, P_2_Size, P_3_Size, P_4_Size, P_5_Size, P_6_Size, P_7_Size };

db *M0_RegularTable[] = { M_0, M_1, M_2, M_3, M_4, M_5, M_6, M_7 };
db *M1_RegularTable[] = { M_0, M_1, M_2, M_3, M_4, M_5, M_6, M_7 };

db M0_SizeTable[] = { M_0_Size, M_1_Size, M_2_Size, M_3_Size, M_4_Size, M_5_Size, M_6_Size, M_7_Size };
db M1_SizeTable[] = { M_0_Size, M_1_Size, M_2_Size, M_3_Size, M_4_Size, M_5_Size, M_6_Size, M_7_Size };

db *P0_MultipleTable[] = { MP_0, MP_1, MP_2, MP_3, MP_4, MP_5, MP_6, MP_7 };
db *P1_MultipleTable[] = { MP_0, MP_1, MP_2, MP_3, MP_4, MP_5, MP_6, MP_7 };

db *M0_MultipleTable[] = { MM_0, MM_1, MM_2, MM_3, MM_4, MM_5, MM_6, MM_7 };
db *M1_MultipleTable[] = { MM_0, MM_1, MM_2, MM_3, MM_4, MM_5, MM_6, MM_7 };


#define M4 0 	 /*  I am not actually sure if this should be zero or -4.  */

db DeepHMOVE[] = {
/* 0 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-7,-7,-7,-7,-7,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-7,-7,-7,-7,-7,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 5, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* 1 */
 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 8,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 7, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 5, 5, 5, 5, 5,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* 2 */
 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 8, 8,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 7, 7, 7,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* 3 */
 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0,10,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 9, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 8, 8, 8,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 7, 7, 7, 7, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 6, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* 4 */
 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0,11,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0,10,10,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 9, 9, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 8, 8, 8, 8, 8,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 7, 7, 7, 7, 7, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 6, 6, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* 5 */
 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0,12,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0,11,11,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0,10,10,10,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 9, 9, 9, 9, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 8, 8, 8, 8, 8, 8,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 7, 7, 7, 7, 7, 7, 7,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0, 6, 6, 6, 6, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* 6 */
 0,0,0,0,0,0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0,13,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0,12,12,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0,11,11,11,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0,10,10,10,10,10,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 9, 9, 9, 9, 9, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 8, 8, 8, 8, 8, 8, 8,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0, 7, 7, 7, 7, 7, 7, 7, 7, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0,	/* f */
/* 7 */
 0,0,0,0,0,0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,M4, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0,14,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0,13,13,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0,12,12,12,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0,11,11,11,11,11,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0,10,10,10,10,10,10,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 9, 9, 9, 9, 9, 9, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0, 8, 8, 8, 8, 8, 8, 8, 8, 8,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0,	/* f */
/* 8 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* 9 */
 0,0,0,0,0,0,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0,-10,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-11,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-12,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-13,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-14,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-14,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* a */
 0,0,0,0,0,0,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-10,-10,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-11,-11,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-12,-12,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-13,-13,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-13,-13,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* b */
 0,0,0,0,0,0,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-9,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-10,-10,-10,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-11,-11,-11,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-12,-12,-12,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-12,-12,-12,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 2,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* c */
 0,0,0,0,0,0,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-8,-8,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-9,-9,-9,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-10,-10,-10,-10,-10,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-11,-11,-11,-11,-11,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-11,-11,-11,-11,-11,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 1, 1, 1,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* d */
 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-7,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-8,-8,-8,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-9,-9,-9,-9,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-10,-10,-10,-10,-10,-10,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-10,-10,-10,-10,-10,-10,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* e */
 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-7,-7,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-8,-8,-8,-8,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-9,-9,-9,-9,-9,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-9,-9,-9,-9,-9,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 5,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 2, 2, 2, 2, 2,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* f */
/* f */
 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 0 */
 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 1 */
 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 2 */
 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 3 */
 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 4 */
 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 5 */
 0,0,0,0,0,0,-7,-7,-7,-7,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 6 */
 0,0,0,0,0,0,-8,-8,-8,-8,-8,-8,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 7 */
 0,0,0,0,0,0,-8,-8,-8,-8,-8,-8,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 8 */
 0,0,0,0,0,0, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* 9 */
 0,0,0,0,0,0, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* a */
 0,0,0,0,0,0, 4, 4, 4,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* b */
 0,0,0,0,0,0, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* c */
 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* d */
 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,	/* e */
 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	/* f */
};
#endif


/**
** z26 is Copyright 1997-2011 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
