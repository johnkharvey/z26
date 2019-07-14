/*
** recognize cart and set up special properties
*/

db KoolAide;		/* do KoolAide cheat */
db RSBoxing;		/* do RSBOXING cheat */
db MPdirection;		/* direction mouse must move to emulate paddle */
db MinVol;			/* minimum volume needed to make noise on PC-speaker */
db LG_WrapLine;		/* light gun wrap line */

// this came from the thread:
// https://stackoverflow.com/questions/27303062/strstr-function-like-that-ignores-upper-or-lower-case
// and was written by Clifford

char* stristr( const char* str1, const char* str2 )
{
    const char* p1 = str1 ;
    const char* p2 = str2 ;
    const char* r = *p2 == 0 ? str1 : 0 ;

    while( *p1 != 0 && *p2 != 0 )
    {
        if( tolower( (unsigned char)*p1 ) == tolower( (unsigned char)*p2 ) )
        {
            if( r == 0 ) r = p1 ;
            p2++ ;
        }
        else
        {
            p2 = str2 ;
            if( r != 0 ) p1 = r + 1 ;
            if( tolower( (unsigned char)*p1 ) == tolower( (unsigned char)*p2 ) )
            {
                r = p1 ;
                p2++ ;
            }
            else
            {
                r = 0 ;
            }
        }
        p1++ ;
    }
    return *p2 == 0 ? (char*)r : 0 ;
}

db Lookup(dd *table)
{
	dd t;

	while(1)
	{
		t = *table++;
		if (t == -1)  return(0);
		if (t == crc) return(1);
	}
}

void RecognizeCart(void)
{
	db paddle;
	db LeftSuggestion, RightSuggestion;

	KoolAide = 0;				/* KoolAide RESP cheat */
	if (Lookup(Kool)) KoolAide = 1;

	RSBoxing = 0;				/* RSBOXING cheat */
	if (Lookup(Boxing)) RSBoxing = 1;
	
/* special starting lines */

	DefaultCFirst = 0xffff;

	if (crc == 0xe5314b6c) GameOffset =  16; 	/* aciddrop */
	if (crc == 0x19b76676) GameOffset =  12; 	/* Bermuda Triangle (PAL) */
	if (crc == 0xd8777a3b) GameOffset =  42; 	/* Starsoft - Gefecht im All (PAL).bin */
	if (crc == 0x7805bc6f) GameOffset = -16; 	/* Acid Drop (1992) (Salu) [f1] (NTSC by TJ).a26 */
	if (crc == 0x7b4eb49c) GameOffset =  16; 	/* pickpile */
	if (crc == 0x20010308) GameOffset = -4;	 	/* challang */
	if (crc == 0xf3ded2e3) GameOffset = -4;  	/* pandchse */
	if (crc == 0xc44d074f) GameOffset = -7;  	/* zoofun */
	if (crc == 0x4f40a18e) GameOffset =  16; 	/* air_raid */
	if (crc == 0x7b8fcd3a) GameOffset =  21; 	/* bibi */
	if (crc == 0x6f62a864) GameOffset = -10; 	/* grescape */
	if (crc == 0x38d3342b) GameOffset =  10; 	/* coln */
	if (crc == 0x92fd7dbf) GameOffset =  16; 	/* alienret */
	if (crc == 0x84a23e70) GameOffset = -8;  	/* kingkong */
	if (crc == 0x7b7921c3) GameOffset =  3;  	/* vg_steep */
	if (crc == 0xeab1d9d0) GameOffset =  3;  	/* vg_treas */
	if (crc == 0x71b85acc) GameOffset =  11; 	/* walker */
	if (crc == 0x36910e4d) GameOffset =  8;  	/* frogger2 */
	if (crc == 0x81ae3d7d) GameOffset =  8;  	/* metdef */
	if (crc == 0x350c63ba) GameOffset =  8;  	/* minrvol2 */
	if (crc == 0x747bfaf6) GameOffset =  10; 	/* snalsqrl */
	if (crc == 0xdc25b7ea) GameOffset = -16; 	/* timewarp */
	if (crc == 0xf674d128) GameOffset =  8;  	/* baseattk */
	if (crc == 0x7117e8a9) GameOffset = -4;  	/* drgndfnd */
	if (crc == 0x77daa7b0) GameOffset =  16; 	/* firebird */
	if (crc == 0x25967483) GameOffset =  22; 	/* motocros */
	if (crc == 0xa9d7698f) GameOffset =  8;	 	/* spact_tw */
	if (crc == 0x5463707)  GameOffset =  8;  	/* cosmcorr */
	if (crc == 0xf5f8ffff) GameOffset =  8;  	/* dancplat */
	if (crc == 0x9d63d054) GameOffset =  5;  	/* forest */
	if (crc == 0x680a43b0) GameOffset =  12;	/* saveship */
	if (crc == 0x39d92c76) GameOffset = -12;	/* PAL artillery duel */
	if (crc == 0x8ab11748) GameOffset = -12;	/* Karate (unknown) */
	if (crc == 0xcbebf38e) GameOffset = 10;		/* Nightmare (PAL) */

//	if (crc == 0xb17b62db) DefaultCFirst = 1;	 /* Balthazar */
//	if (crc == 0xfa07aa39) DefaultCFirst = 0;	 /* pharhcrs -- vblank triggers frame */

/* special palettes */

	if (UserPaletteNumber == 0xff)		/* if user didn't specify a palette */
	{
		if (Lookup(NTSC_colours))	GamePaletteNumber = 0;	/* NTSC Palette */
		if (Lookup(PAL_colours))	GamePaletteNumber = 1;      /* PAL Palette */
		if (strstr(FileName, "NTSC")) GamePaletteNumber = 0;
		if (strstr(FileName, "PAL")) GamePaletteNumber = 1;
		if (strstr(FileName, "SECAM")) GamePaletteNumber = 2;

		PaletteNumber = GamePaletteNumber;
	}

/* games that want Player 1 set to hard */

	if (Lookup(Player_1_hard)) IOPortB |= 0x80;


/* games that want the joystick controls reversed */
/* XOR flag bit so that ports can still be swapped by user */
	if (Lookup(joy_rev)) SwapPortsFlag ^= 0x01;


/* games that need to use "impossible" joystick positions */
	if (crc == 0x7a0d162d) AllowAll4 = 1;   /* Bumper Bash NTSC */
	if (crc == 0x4af43194) AllowAll4 = 1;   /* Bumper Bash PAL */


/* detect controllers */
	LeftSuggestion = JS;		/* assume joystick controllers by default */
	RightSuggestion = JS;

/* paddle games */
	paddle = 0xff;				/* assume not recognized */

	if (Lookup(Paddle_0)) paddle = 0;
	if (Lookup(Paddle_1)) paddle = 1;
	if (Lookup(Paddle_3)) { paddle = 1; SwapPortsFlag ^= 0x01; }
		/* Tac Scan uses paddle on right controller port -> swap ports */
//	if (Lookup(Paddle_3)) paddle = 3;

	/* Marble Craze NTSC and PAL -- use both mouse axis to emulate paddles */
	if (crc == 0x095a655f) { MouseBaseX = 1; MouseBaseY = 0; paddle = 0; }	/* NTSC */
	if (crc == 0x96a0b1f9) { MouseBaseX = 1; MouseBaseY = 0; paddle = 0; }	/* PAL */

	if (paddle != 0xff)			/* if we found a paddle game set its direction */
	{
		LeftSuggestion = PC;
		RightSuggestion = PC;
		if (PaddleSensitivity == 0)   PaddleSensitivity = 6;	/* default sensitivity 3 */

		MPdirection = 0;

		/* MPdir bit0 = 1 -> vertical paddle motion */
		if (Lookup(MPdir_1)) MPdirection = 1;
		if (Lookup(MPdir_2)) MPdirection = 2;
		if (Lookup(MPdir_3)) MPdirection = 3;
		if ((MouseBaseY == 0xff) && (MPdirection & 0x01)) MouseBaseY = paddle;
		else if ((MouseBaseX == 0xff) && !(MPdirection & 0x01)) MouseBaseX = paddle;
	}


/* Kid Vid games */
	if (crc == 0x9927a7ae) { RightSuggestion = KV; KidVid = 0x44; }	/* Smurfs Save the Day */
	if (crc == 0x0b63f9e3) { RightSuggestion = KV; KidVid = 0x48; }	/* The Berenstain Bears */


/* keypad games */

	if (Lookup(keypad_3)) { RightSuggestion = KP; LeftSuggestion = KP; }
	if (Lookup(keypad_2)) RightSuggestion = KP;


/* driving controller games */

	if (Lookup(driving_con_2)) RightSuggestion = DC;
	if (Lookup(driving_con_3)) { RightSuggestion = DC; LeftSuggestion = DC; }


/* lightgun games */

	LG_WrapLine = 78;

	if (crc == 0x0febd060) { LeftSuggestion = LG; Lightgun = 7; LGadjust = 11; }			/* shootacd */
	if (crc == 0x56e2d735) { LeftSuggestion = LG; Lightgun = 8; LGadjust = 0;  }			/* sentinel */
	if (crc == 0xdde8600b) { LeftSuggestion = LG; Lightgun = 9; LGadjust = 5;  LG_WrapLine = 75; }	/* guntest4 */


/* Mindlink games */

	if (crc == 0x81187400) RightSuggestion = ML;	/* Telepathy */
	if (crc == 0x3183c019) LeftSuggestion = ML;	/* Bionic Breakthrough */


/* CompuMate keyboard */
	if (crc == 0xa01ebff4) { RightSuggestion = CM; LeftSuggestion = CM; }	/* Spectravideo CompuMate PAL */
	if (crc == 0xdfa1388d) { RightSuggestion = CM; LeftSuggestion = CM; }	/* Spectravideo CompuMate NTSC */


/* TrakBalls */
	if (crc == 0x16119bbc) { RightSuggestion = ST; LeftSuggestion = ST; }	/* Missile Command hack NTSC ST mouse */
	if (crc == 0x094ed116) { RightSuggestion = ST; LeftSuggestion = ST; }	/* Missile Command hack PAL ST mouse */
	if (crc == 0x8f7e1223) { RightSuggestion = TB; LeftSuggestion = TB; }	/* Missile Command hack NTSC CX-22 */
	if (crc == 0x90215889) { RightSuggestion = TB; LeftSuggestion = TB; }	/* Missile Command hack PAL CX-22 */
	if (crc == 0x8590dabb) { RightSuggestion = AM; LeftSuggestion = AM; }	/* Missile Command hack NTSC Amiga mouse */
	if (crc == 0xe4062d87) { RightSuggestion = AM; LeftSuggestion = AM; }	/* Missile Command hack PAL Amiga mouse */
	if (crc == 0xd4f23bda) { RightSuggestion = AM; LeftSuggestion = AM; }	/* Missile Command hack NTSC Amiga mouse (v1.2) */
	if (crc == 0x9593b81c) { RightSuggestion = AM; LeftSuggestion = AM; }	/* Missile Command hack PAL Amiga mouse (v1.2) */

        
/* if the user didn't specify controllers, use autodetection */
	if (LeftController == 0xff) LeftController = LeftSuggestion;
	if (RightController == 0xff) RightController = RightSuggestion;

/* bankswitching */

	BSType = 0;
	
	if (Lookup(BS_1)) BSType = 1;		/* CommaVid */
	if (Lookup(BS_3)) BSType = 3;		/* Parker Brothers */
	if (Lookup(BS_4)) BSType = 4;		/* Tigervision */
	if (Lookup(BS_5)) BSType = 5;		/* Activision 8K flat model */
	if (Lookup(BS_6)) BSType = 6;		/* 16K Superchip that can't be recognized automatically */
	if (Lookup(BS_7)) BSType = 7;		/* M Network 16K */
	if (Lookup(BS_8)) BSType = 8;       /* Atari 32K */
	if (Lookup(BS_9)) BSType = 9;		/* 8K banks reversed */
	if (crc == 0xa01ebff4) BSType = 10; /* Spectravideo CompuMate PAL */
	if (crc == 0xdfa1388d) BSType = 10;	/* Spectravideo CompuMate NTSC */
	if (Lookup(BS_11)) BSType = 11;		/* 32K Tigervision */
	if (Lookup(BS_12)) BSType = 12;     /* 8K UA Ltd. */

	if (stristr(FileName, "[2K]"))  BSType = 0;		// 4K Atari
	if (stristr(FileName, "[4K]"))  BSType = 0;		// 4K Atari
	if (stristr(FileName, "[CV]"))  BSType = 1;		// Commavid
	if (stristr(FileName, "[F8S]")) BSType = 2;		// 8K superchip
	if (stristr(FileName, "[E0]"))  BSType = 3;		// 8K Parker Bros.
	if (stristr(FileName, "[3F]"))  BSType = 4;		// 8K Tigervision
	if (stristr(FileName, "[FE]"))  BSType = 5;		// 8K flat
	if (stristr(FileName, "[F6S]")) BSType = 6;		// 16K superchip
	if (stristr(FileName, "[E7]"))  BSType = 7;		// 16K M-Network
	if (stristr(FileName, "[F4S]")) BSType = 8;		// 32K superchip
	if (stristr(FileName, "[F8R]")) BSType = 9;		// 8K Atari banks swapped
	if (stristr(FileName, "[CM]"))  BSType = 10;	// Compumate
	if (stristr(FileName, "[3F+]")) BSType = 11;	// 512K Tigervision
	if (stristr(FileName, "[UA]"))  BSType = 12;	// UA Ltd.
	if (stristr(FileName, "[EF]"))  BSType = 13;	// 64K Homestar Runner / Paul Slocum
	if (stristr(FileName, "[3E]"))  BSType = 14;	// large 3F + 32K RAM (Krokodile / Andrew Davie)
	if (stristr(FileName, "[AR]"))  BSType = 15;	// Starpath
	if (stristr(FileName, "[F6]"))  BSType = 16;	// 16K Atari
	if (stristr(FileName, "[F4]"))  BSType = 17;	// 32K Atari
	if (stristr(FileName, "[MB]"))  BSType = 18;	// Megaboy
	if (stristr(FileName, "[FA]"))  BSType = 19;	// 12K CBS
	if (stristr(FileName, "[F8]"))  BSType = 20;	// 8K Atari
	if (stristr(FileName, "[P2]"))  BSType = 21;	// Pitfall 2
	if (stristr(FileName, "[4A5]")) BSType = 22;	// supercat
	if (stristr(FileName, "[084]")) BSType = 23;	// EconoBanking

	if (stristr(FileName, ".2k"))	BSType = 0;		// 4K Atari
	if (stristr(FileName, ".4k"))	BSType = 0;		// 4K Atari
	if (stristr(FileName, ".cv"))	BSType = 1;		// Commavid
	if (stristr(FileName, ".f8s"))	BSType = 2;		// 8K superchip
	if (stristr(FileName, ".e0"))	BSType = 3;		// 8K Parker Bros.
	if (stristr(FileName, ".3f"))	BSType = 4;		// 8K Tigervision
	if (stristr(FileName, ".fe"))	BSType = 5;		// 8K flat
	if (stristr(FileName, ".f6s"))	BSType = 6;		// 16K superchip
	if (stristr(FileName, ".e7"))	BSType = 7;		// 16K M-Network
	if (stristr(FileName, ".f4s"))	BSType = 8;		// 32K superchip
	if (stristr(FileName, ".f8r"))	BSType = 9;		// 8K Atari banks swapped
	if (stristr(FileName, ".cm"))   BSType = 10;	// Compumate
	if (stristr(FileName, ".3f+"))	BSType = 11;	// 512K Tigervision
	if (stristr(FileName, ".ua"))	BSType = 12;	// UA Ltd.
	if (stristr(FileName, ".ef"))   BSType = 13;	// 64K Homestar Runner / Paul Slocum
	if (stristr(FileName, ".3e"))	BSType = 14;	// large 3F + 32K RAM (Krokodile / Andrew Davie)
	if (stristr(FileName, ".ar"))	BSType = 15;	// Starpath
	if (stristr(FileName, ".f6"))	BSType = 16;	// 16K Atari
	if (stristr(FileName, ".f4"))	BSType = 17;	// 32K Atari
	if (stristr(FileName, ".mb"))   BSType = 18;	// Megaboy
	if (stristr(FileName, ".fa"))	BSType = 19;	// 12K CBS
	if (stristr(FileName, ".f8"))	BSType = 20;	// 8K Atari
	if (stristr(FileName, ".p2"))	BSType = 21;	// Pitfall 2
	if (stristr(FileName, ".dpc"))	BSType = 21;	// Pitfall 2
	if (stristr(FileName, ".4a5"))	BSType = 22;	// supercat
	if (stristr(FileName, ".084"))	BSType = 23;	// EconoBanking

	if (UserBankswitch !=0xff) BSType = UserBankswitch;
}

/**
** z26 is Copyright 1997-2019 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

