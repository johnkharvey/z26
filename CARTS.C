/*
** recognize cart and set up special properties
*/

/*
** warning -- switch only tests bottom 16 bits of case value in Turbo-C 2.0
*/


/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

db KoolAide;		/* do KoolAide cheat */
db RSBoxing;		/* do RSBOXING cheat */
db TIAZero;		/* return zero for undocumented TIA reads */
dw UserCFirst;		/* user requests game start here */
dw DefaultCFirst;	/* emu recommends game start here */
db MPdirection;		/* direction mouse must move to emulate paddle */
db MinVol;		/* minimum volume needed to make noise on PC-speaker */
db LG_WrapLine;		/* light gun wrap line */


void RecognizeCart(void)
{
	db paddle;
        dw i,j;

/*
** recognize KoolAide RESP cheat
*/

	KoolAide = 0;

	switch(Checksum)
	{
	case 0x715a2:				/* koolaide */
	case 0x71b5d:				/* kool-sc */
			KoolAide = 1; break;
	}

/*
** recognize RSBOXING cheat
*/

	RSBoxing = 0;
	
	switch(Checksum)
	{
	case 0x24c452:				/* rsboxing */
	case 0x23e39c:				/* rsboxing (PAL) */
			RSBoxing = 1; break;
	}

/*
** recognize games that want zero for undocumented TIA reads
*/

	TIAZero = 0;

#ifdef commentx

	switch(Checksum)
	{
	case 0x67d00:				/* berzerk */
	case 0xd5653:				/* qbrtqube */
	case 0x69fa4:				/* spacecav */
	case 0x69409:				/* spacanyn */
	case 0x70d15:				/* tps */
			TIAZero = 1; break;
	}
#endif

/* 
** recognize starting lines 
*/

	UserCFirst = CFirst;
	DefaultCFirst = 0xffff;

	switch(Checksum)
	{
	case 0x1d2f8e:	CFirst = 56; break;	/* aciddrop */
	case 0x770c5:	CFirst = 1;  break;	/* Balthazar */

	case 0x84f0e:				/* pharhcrs */
	case 0x7b179:				/* traffic */
			  CFirst = 0; break;	/* (vblank triggers frame) */
	}

	DefaultCFirst = CFirst;

/* 
** recognize paddle games 
*/

	paddle = 0xff;				/* assume not recognized */


	switch(Checksum)
	{
	case 0xa4f4d:				/* firblpal */
	case 0x91e4d:				/* prtymix1 */
	case 0x89e4d:				/* prtymix2 */
	case 0x9984d:				/* prtymix3 */
	case 0x9094d:				/* pmix1pal */
	case 0x8b64d:				/* pmix2pal */
	case 0x98a4d:				/* pmix3pal */
	case 0x6d8a3:				/* sweat1 */
	case 0x322fc:				/* sweat2 */

	/* case 0x3b0a9: */			/* 32in1-09 */
	case 0x78357:				/* actnforc (PAL) */
	case 0x78387:				/* actionmn */
	case 0x54e06:				/* bachelor */
	case 0x55706:				/* bachlrtt */
	case 0x852b2:				/* backgam */
	case 0x62e00:				/* beatem */
	case 0x3b06f:				/* blakjack */
	case 0x3d708:				/* breakout */
	case 0x3d891:				/* breakout (PAL) */
	case 0x683f6:				/* bugs */
	case 0x7e271:				/* casino */
	case 0x5485d:				/* circatri */
	case 0x54dcf:				/* circus (PAL) */
	case 0x6ccd7:				/* eggomana */
	case 0x66e29:				/* encontl5 */
	case 0x78e4d:				/* gijoe */
	case 0x70434:				/* guardian */
	case 0x36c7c:				/* kaboom */
	case 0x8929f:				/* mpong10 */
	case 0x6d7fc:				/* muscmach */
	case 0x3c030:				/* nightdrv */
	case 0x3c307:				/* nghtdrvr (PAL) */
	case 0x61d00:				/* philly */
	case 0x7844b:				/* picnic */
	case 0x6ae62:				/* piececke */
	case 0x751c3:				/* sagent */
	case 0x6eaa5:				/* solrstrm */
	case 0x3978c:				/* stplchse */
	case 0x81aef:				/* superbrk */
	case 0x81657:				/* srbrkout (PAL) */
	case 0x7b217:				/* warlords */
	case 0x7b963:				/* warlords (PAL) */
	case 0x7e2ea:				/* warplock */
			paddle = 0; break;

	case 0x3d843:				/* canyonb */
	case 0x6ee82:				/* dem2dmds */
	case 0x7ef53:				/* jediaren */
	case 0x7f8d7:				/* jediaren (PAL) */
	case 0x3bee2:				/* strtracr */
	case 0x3bb66:				/* strtracr (PAL) */
	case 0x35e7e:				/* vidolymp */
	case 0x35d05:				/* vid_olym (PAL) */
			paddle = 1; break;

	case 0x7cbe1:				/* tacscan */
			paddle = 3; break;
	}

	switch(crc)
	{
	case 0x19fc874c:	/* fireball  (regular matches frogrpal) */
	case 0xe18a4ca:		/* 32in1-09  (regular matches alienret) */
			paddle = 0; break;
	}

/*
** if we found a paddle game set its direction
*/

	if (paddle != 0xff)
	{
		if (PaddleGame == 0) PaddleGame = 6;	/* default sensitivity 3 */
		if (KeyBase == 0xff)   KeyBase = paddle;
		if (MouseBase == 0xff) MouseBase = paddle;

		MPdirection = 0;

		switch(Checksum)
		{
		case 0x9984d:			/* prtymix3 */
		case 0x98a4d:			/* pmix3pal */

		case 0x3b0a9:			/* 32in1-09 */
		case 0x54e06:			/* bachelor */
		case 0x55706:			/* bachlrtt */
		case 0x3b06f:			/* blakjack */
		case 0x7e271:			/* casino */
		case 0x3978c:			/* stplchse */
			MPdirection = 1; break;

		case 0x6d8a3:			/* sweat1 */

		case 0x852b2:			/* backgam */
		case 0x3d843:			/* canyonb */
		case 0x8929f:			/* mpong10 */
		case 0x35e7e:			/* vidolymp */
		case 0x35d05:			/* vid_olym (PAL) */
			MPdirection = 3; break;
		}
	}

/*
** recognize special palettes
*/

	if (PaletteNumber == 0xff)		/* if user didn't specify a palette */
	{
		switch(Checksum)
		{
		case 0x78a61:			/* air_raid (too large) */
		case 0x84f0e:			/* pharhcrs (prevent auto-switch) */
			PaletteNumber = 0;	/* NTSC Palette */
			UserPaletteNumber = 0;
			break;
		}
	}

/*
** recognize games that should be quiet on PC speaker
*/

	MinVol = 8;

	switch(Checksum & 0xffff)		/* these are old checksums -- test 16 bits */
	{
	case 0x392d:				/* vidchess */
	case 0x6b3d:				/* boxing */
	case 0x8d5c:				/* colorbar */
	case 0xc814:				/* dicepuzl */
	case 0x5b2a:				/* dbldragn */
	case 0xe271:				/* casino */
	case 0x99c8:				/* stampede */
	case 0xad92:				/* tictac3d */
	case 0xb1d0:				/* homerun */
	case 0x507b:				/* slotmach */
	case 0x186e:				/* vidcheck */
			MinVol = 20; break;
	}

/*
** recognize games that want Player 1 set to hard
*/

	switch(Checksum)
	{
	case 0x1694a9:				/* he_man */
			IOPortB |= 0x80;
	}

/*
** recognize games that want the joystick controls reversed
*/

	if (Joystick == 0xff)			/* only if user didn't specify a preference */
	{
		Joystick = 1;
		
		switch (Checksum)
		{
		case 0xde9ff:			/* raiders  */
		case 0x1e3898:			/* pickpile */
				Joystick = 2; break;
		}
	}

/*
** recognize keypad games
*/

	switch(Checksum)
	{
	case 0x39135:				/* concentr */
	case 0x3905a:				/* concentr (PAL) */
	case 0xfffb5:				/* alphbeam */
	case 0x84398:				/* basic */
	case 0x84440:				/* basicprg (PAL) */
	case 0xd8234:				/* eggcatch */
	case 0x3cccd:				/* braingms */
	case 0x3a688:				/* codebrk */
	case 0xddca2:				/* cookmons */
	case 0xa31df:				/* grover */
	case 0x38191:				/* magicard */
	case 0xe2b06:				/* oscar */
			KeyPad = 3; break;

	case 0x9fbed:				/* starraid */
	case 0x9fe26:				/* starraid (PAL) */
			KeyPad = 2; break;
	}

/*
** recognize driving controller games
*/

	switch(Checksum)
	{
	case 0x39318:				/* indy500 */
	case 0x394f2:				/* indy_500 (PAL) */
			Driving = 1; break;
	}

/*
** recognize lightgun games
*/

	LG_WrapLine = 78;

	switch(Checksum)
	{
	case 0x1fb7fb:	Lightgun = 7; LGadjust = 11; 			break;	/* shootacd */
	case 0x1a3410:	Lightgun = 8; LGadjust = 0;  			break;	/* sentinel */
	case 0xd62fe:   Lightgun = 9; LGadjust = 5;  LG_WrapLine = 75; 	break;	/* guntest4 */
	}

/*
** recognize bankswitch types
*/

	switch(Checksum)
	{
	case 0x3b72b:				/* vidlife 2K (final version) */
	case 0x38191:				/* magicard */
	case 0x8f5ee:				/* vidlife 4K */
			BSType = 1; break;	/* commavid */

	case 0xde446:				/* dethstar */
	case 0xbf9f8:				/* gyruss */
	case 0x109a6d:				/* sprcobra */
	case 0x109687:				/* sprcobra (PAL) */
	case 0xdc831:				/* tutank */
	case 0xdc425:				/* tutankha (PAL) */
	case 0xcc026:				/* popeye */
	case 0xcba9e:				/* popeye (PAL) */
	case 0xcce17:				/* swarcade */
	case 0xde6b6:				/* sw_rotj (PAL) */
	case 0xcc455:				/* swtagpro */
	case 0xd5653:				/* qbrtqube */
	case 0xee31a:				/* frogger2 */
	case 0xefce0:				/* montzrev */
	case 0xd1113:				/* docastle */
	case 0xc9379:				/* toothpro */
	case 0xe1923:				/* jamebond */
			BSType = 3; break;	/* Parker Brothers */

	case 0xde35e:				/* riverp */
	case 0xccf71:				/* springer */
	case 0xd60bf:				/* polaris */
	case 0xd2510:				/* mnr2049r */
	case 0xdec87:				/* minrvol2 */
	case 0xc4d38:				/* espial */
			BSType = 4; break;

	case 0xdad52:				/* decathln */
	case 0xcf815:				/* robotank */
			BSType = 5; break;

	case 0xd7238:				/* priveye */
			BSType = 9; break;	/* 8K banks backwards */

	case 0x1d2416:				/* digdug */
	case 0x1d5f30:				/* ofthwall */
			BSType = 6; break;	/* 16K Superchip */

	case 0x1694a9:				/* he_man */
	case 0x2f03c8:				/* bnj */
	case 0x188504:				/* burgtime */
			BSType = 7; break;	/* M Network 16K */

	case 0x299233:				/* fatalrun */
			BSType = 8; break;	/* Atari 32K */
	}

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
           }
        }

}
