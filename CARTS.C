/*
** recognize cart and set up special properties
*/


/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

db KoolAide;		/* do KoolAide cheat */
db RSBoxing;		/* do RSBOXING cheat */
dw UserCFirst;		/* user requests game start here */
dw DefaultCFirst;	/* emu recommends game start here */
db MPdirection;		/* direction mouse must move to emulate paddle */
db MinVol;		/* minimum volume needed to make noise on PC-speaker */
db LG_WrapLine;		/* light gun wrap line */


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
        dw i,j;

        if (crc == 0x7a0d162d) AllowAll4 = 1;   /* Bumper Bash NTSC */
        if (crc == 0x4af43194) AllowAll4 = 1;   /* Bumper Bash PAL */

	KoolAide = 0;				/* KoolAide RESP cheat */
	if (Lookup(Kool)) KoolAide = 1;

	RSBoxing = 0;				/* RSBOXING cheat */
	if (Lookup(Boxing)) RSBoxing = 1;
	
/* special starting lines */

	UserCFirst = CFirst;
	DefaultCFirst = 0xffff;

	if (crc == 0xe5314b6c) CFirst = 56;	/* aciddrop */
	if (crc == 0xb17b62db) CFirst = 1;	/* Balthazar */
	if (crc == 0xfa07aa39) CFirst = 0;	/* pharhcrs -- vblank triggers frame */
	if (crc == 0xbcb42d2b) CFirst = 0;	/* traffic  -- vblank triggers frame */

	if (crc == 0x4f40a18e) CFirst = 30;	/* air_raid */
	if (crc == 0x6f62a864) CFirst = 30;	/* grescape */
	if (crc == 0x7b4eb49c) CFirst = 44;	/* pickpile */
	if (crc == 0xbf9da2b1) CFirst = 37;	/* Robin Hood (PAL) */

/*        if (crc == 0xa01ebff4) CFirst = 54; */    /* CompuMate */

	DefaultCFirst = CFirst;


/* paddle games */

	paddle = 0xff;				/* assume not recognized */

	if (Lookup(Paddle_0)) paddle = 0;
	if (Lookup(Paddle_1)) paddle = 1;
	if (Lookup(Paddle_3)) paddle = 3;

	if (paddle != 0xff)			/* if we found a paddle game set its direction */

	{
		if (PaddleGame == 0)   PaddleGame = 6;	/* default sensitivity 3 */
		if (KeyBase == 0xff)   KeyBase = paddle;
		if (MouseBase == 0xff) MouseBase = paddle;

		MPdirection = 0;

		if (Lookup(MPdir_1)) MPdirection = 1;
		if (Lookup(MPdir_3)) MPdirection = 3;
	}


/* special palettes */

	if (PaletteNumber == 0xff)		/* if user didn't specify a palette */
	{

		if (
			(crc == 0xfa07aa39) ||	/* pharhcrs (prevent auto-switch) */
			(crc == 0x4f40a18e)	/* air_raid (too large) */
		   )
		{
			PaletteNumber = 0;	/* NTSC Palette */
			UserPaletteNumber = 0;
		}
	}


/* games that should be quiet on PC speaker */

	MinVol = 8;
	if (Lookup(be_quiet)) MinVol = 20;


/* games that want Player 1 set to hard */

	if (crc == 0x5c161fe4) IOPortB |= 0x80;	/* he_man */


/* games that want the joystick controls reversed */

	if (Joystick == 0xff)			/* only if user didn't specify a preference */
	{
		Joystick = 1;
		if (Lookup(joy_rev)) Joystick = 2;
	}


/* keypad games */

	if (Lookup(keypad_3)) KeyPad = 3;
	if (Lookup(keypad_2)) KeyPad = 2;


/* driving controller games */

	if (Lookup(driving_con)) Driving = 1;


/* lightgun games */

	LG_WrapLine = 78;

	if (crc == 0x0febd060) { Lightgun = 7; LGadjust = 11; }			  /* shootacd */
	if (crc == 0x56e2d735) { Lightgun = 8; LGadjust = 0;  }			  /* sentinel */
	if (crc == 0xdde8600b) { Lightgun = 9; LGadjust = 5;  LG_WrapLine = 75; } /* guntest4 */


/* Mindlink games */

        if (crc == 0x81187400) Mindlink = 1;    /* Telepathy */
        if (crc == 0x3183c019) Mindlink = 2;    /* Bionic Breakthrough */


/* bankswitching */

	if (Lookup(BS_1)) BSType = 1;		/* CommaVid */
	if (Lookup(BS_3)) BSType = 3;		/* Parker Brothers */
	if (Lookup(BS_4)) BSType = 4;		/* Tigervision */
	if (Lookup(BS_5)) BSType = 5;		/* Activision 8K flat model */
	if (Lookup(BS_9)) BSType = 9;		/* 8K banks reversed */
	if (Lookup(BS_6)) BSType = 6;		/* 16K Superchip that can't be recognized automatically */
	if (Lookup(BS_7)) BSType = 7;		/* M Network 16K */
/*      if (Lookup(BS_8)) BSType = 8; */        /* Atari 32K */
        if (crc == 0xa01ebff4) BSType = 10;     /* Spectravideo CompuMate PAL */

        if(BSType==0)
        {
           switch(CartSize)
           {
           case 0x2000:
              BSType=2;                         /* 8K superchip */
              for(i=0; i<2; i++)
              {
                 for(j=0; j<256; j++)
                 {
                    if(CartRom[0]!=CartRom[i*0x1000+j]) BSType=0;
                 }
              }
           break;
           case 0x4000:
              BSType=6;                         /* 16K superchip */
              for(i=0; i<4; i++)
              {
                 for(j=0; j<256; j++)
                 {
                    if(CartRom[0]!=CartRom[i*0x1000+j]) BSType=0;
                 }
              }
           break;
           case 0x8000:
              BSType=8;                         /* 32K superchip (Fatal Run) */
              for(i=0; i<8; i++)
              {
                 for(j=0; j<256; j++)
                 {
                    if(CartRom[0]!=CartRom[i*0x1000+j]) BSType=0;
                 }
              }
           break;
           }
        }
}
