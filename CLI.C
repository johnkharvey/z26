/*
** z26 command line stuff
*/


/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

/*
** load next Starpath Rom
*/

void cli_LoadNextStarpath(void)
{
        int i,j, LoadCount, LoadNum;
	unsigned int pageadr, pagebyte, pagecount;
	unsigned char *p;
	unsigned char *q;

        SC_StartAddress=0;
        LoadCount=4;
        LoadNum=SC_ControlByte;
        for (i = 1; i < 4; i++)
        {
                if (Megaboy[i*8448 + 0x2005] == LoadNum) LoadCount=i;
        }
        LoadNum=LoadCount;

        if (LoadNum == 4) return;

        pagecount = Megaboy[LoadNum*8448 + 0x2003];

	for (i = 0; i < pagecount; i++)
	{
                pagebyte = Megaboy[LoadNum*8448 + 0x2010 + i];
		pageadr = ((pagebyte & 3) * 0x800) + ((pagebyte & 0x1f) >> 2) * 256;

                p = CartRom + pageadr;
                q = Megaboy + LoadNum*8448 + i*256;

		for (j = 0; j < 256; j++)
		{
			*p++ = *q++;
		}
	}
        SC_StartAddress=Megaboy[LoadNum*8448+0x2001]*256+Megaboy[LoadNum*8448+0x2000];
        SC_ControlByte=Megaboy[LoadNum*8448+0x2002];
}

/*
** reload a Starpath file
*/

void cli_ReloadStarpath(void)
{
	int i,j;
	unsigned int pageadr, pagebyte, pagecount;
	unsigned char *p;
        unsigned char far *q;

        if(CartSize == 6144)
        {
                for(i = 0; i < 6144; i++)
                {
                        CartRom[i]=Megaboy[i];
                }
                SC_StartAddress=CartRom[0x17fd]*256+CartRom[0x17fc];
                SC_ControlByte=0x0d;
        }else
        {
	pagecount = CartRom[0x2003];

	for (i = 0; i < pagecount; i++)
	{
		pagebyte = CartRom[0x2010 + i];
		pageadr = ((pagebyte & 3) * 0x800) + ((pagebyte & 0x1f) >> 2) * 256;

                p = CartRom + pageadr;
                q = Megaboy + i*256;
		for (j = 0; j < 256; j++)
		{
                        *p++ = *q++;
		}
	}

        SC_StartAddress=CartRom[0x2001]*256+CartRom[0x2000];
        SC_ControlByte=CartRom[0x2002];
        }
}


#define CRC16_REV 0xA001	/* CRC-16 polynomial reversed */
#define CRC32_REV 0xA0000001	/* CRC-32 polynomial reversed */


/*
** used for generating the CRC lookup table
*/

dd crcrevhware(dd data, dd genpoly, dd accum) 
{
  int i;
  data <<= 1;
  for (i=8;i>0;i--) {
    data >>= 1;
    if ((data ^ accum) & 1)
      accum = (accum >> 1) ^ genpoly;
    else
      accum >>= 1;
    }
  return(accum);
}


/*
** init the CRC lookup table
*/

/*
void init_crc(void) 
{
  int i;
  for (i=0;i<256;i++)
    crctab[i] = crcrevhware(i,CRC32_REV,0);
}
*/

void init_crc(void)
{
}

/*
** update CRC
*/

void ucrc(unsigned char data) 
{
   crc = (crc >> 8) ^ crcrevhware((crc ^ data) & 0xff,CRC32_REV,0);
}

/*
void ucrc(unsigned char data) 
{
   crc = (crc >> 8) ^ crctab[(crc ^ data) & 0xff];
}
*/

/*
** load a ROM image
**
** gets called from gui also -- special ROM setup can go here
*/

int cli_LoadROM(unsigned char *filename)
{

unsigned char SCBIOS[188] = { 
0xa5,0xfa,0x85,0x81,0x4c,0x0e,0xf8,0xff,
0xff,0xff,0xa9,0x00,0x85,0x81,0xa9,0x00,
0x85,0x1b,0x85,0x1c,0x85,0x1d,0x85,0x1e,
0x85,0x1f,0x85,0x19,0x85,0x1a,0x85,0x08,
0x85,0x01,0xa9,0x10,0x85,0x21,0x85,0x02,
0xa2,0x07,0xca,0xca,0xd0,0xfd,0xa9,0x00,
0x85,0x20,0x85,0x10,0x85,0x11,0x85,0x02,
0x85,0x2a,0xa9,0x05,0x85,0x0a,0xa9,0xff,
0x85,0x0d,0x85,0x0e,0x85,0x0f,0x85,0x84,
0x85,0x85,0xa9,0xf0,0x85,0x83,0xa9,0x74,
0x85,0x09,0xa9,0x0c,0x85,0x15,0xa9,0x1f,
0x85,0x17,0x85,0x82,0xa9,0x07,0x85,0x19,
0xa2,0x08,0xa0,0x00,0x85,0x02,0x88,0xd0,
0xfb,0x85,0x02,0x85,0x02,0xa9,0x02,0x85,
0x02,0x85,0x00,0x85,0x02,0x85,0x02,0x85,
0x02,0xa9,0x00,0x85,0x00,0xca,0x10,0xe4,
0x06,0x83,0x66,0x84,0x26,0x85,0xa5,0x83,
0x85,0x0d,0xa5,0x84,0x85,0x0e,0xa5,0x85,
0x85,0x0f,0xa6,0x82,0xca,0x86,0x82,0x86,
0x17,0xe0,0x0a,0xd0,0xc3,0xa9,0x02,0x85,
0x01,0xa5,0x81,0xa2,0x1c,0xa0,0x00,0x84,
0x19,0x84,0x09,0x94,0x81,0xca,0x10,0xfb,
0xa2,0xff,0x29,0xff,0xd0,0x03,0x4c,0xf1,
0xff,0x4c,0xf0,0xff
};

	FILE *fp;
        unsigned int i, j;
	int ch;
	unsigned int MBcount;
	unsigned char *p;

	init_crc();

	fp = fopen(filename, "rb");
	if (fp == NULL)	return(0);
			
/*        p = CartRom; */
        p = Megaboy;
	CartSize = 0;
	Checksum = 0;
	XChecksum = 0;
	crc = 0;

	while ( (ch = getc(fp)) != EOF )
	{
		*p++ = ch;
		Checksum += ch;
		ucrc(ch);
		if (XChecksum & 0x8000000) XChecksum |= 1;
		XChecksum = (XChecksum << 1) ^ ch;
		++CartSize;
                if (CartSize > 33798) break;
	}

        for(i = 0; i < 0x8000; i++) CartRom[i] = Megaboy[i];

        if(CartSize==33799)
	{
	   fseek(fp, 32768, SEEK_SET);
	   MBcount=0;
	   while ( (ch = getc(fp)) != EOF )
	   {
		Megaboy[MBcount] = ch;
		++MBcount;
		if (MBcount==32768) break;
	   }
	}

	fclose(fp);

	if (CartSize == 2048)	/* 2K cart -- copy lower to upper */
	{
		for (i = 0; i < 2048; i++)
		{
			CartRom[2048+i] = CartRom[i];
		}
	}

        if ((CartSize == 6144)||(CartSize == 8448)||(CartSize == 2*8448)
                ||(CartSize == 3*8448)||(CartSize == 33792))
        /* Starpath image -- reload according to page table */
	{
/*
                for (i = 0; i < 8448; i++)       save first SC load 
                {
                        Megaboy[i] = CartRom[i];
                }
*/
                for (i = 0; i < 0x2000; i++)	/* fill everything with Starpath halts */
		{
			CartRom[i] = 0x52;
		}

                for (i = 0; i< 188; i++)        /* generate fake SC BIOS */
                {
                        CartRom[i + 0x1800] = SCBIOS[i];
                }

                CartRom[0x1ffc]=0x0a;           /* setup BIOS reset vector */
                CartRom[0x1ffd]=0xf8;

                cli_ReloadStarpath();
	}

	return(1);
}


/*
**  Command Line interpreter
**
**	-u <n>	upper scan line
**  ->	-b      black and white
**	-c <n>  choose color palette <n>
**  ->	-q	quiet
**  ->	-v <n>  select video mode
**  ->	-s <n>  sound options
**	-x	print out checksum of cartridge
**  ->	-r	don't wait for retrace (full speed), -r<n> run at <n> fps
**	-f <n>  do <n> frames and exit
**  ->	-d <n>  do digital signal processing
**  ->	-j <n>	do joystick
**	-p <n>  do paddle game with sensitivity <n>
**	-k <n>  set keyboard player base
**	-t	trace instructions
**  ->	-0      player 0 hard
**  ->	-1      player 1 hard
**	-y <n>	emulate none <0>, left <1>, right <2> or both <3> keypads *EST*
**	-w	emulate driving controllers *EST*
**	-g	overrride bankswitching type detection *EST*
**	-m <n>	paddle to emulate with mouse; 0xff=joystick *EST*
**	-o	simulate PAL colour loss *EST*
**	-l <n>	emulate lightgun and adjust horizontally *EST*
**	-a <n>	adjust lightgun vertically *EST*
**	-n	show line number count *EST*
**      -i      emulate Mindlink controller, <1> right, <2> left *EST*
**      -4      allow all 4 directions on the joystick simultaniously *EST*
**      -e      enable faster mode X copy routines
**      -z      rotate screen 90ø counter-clockwise in linear modes
**	-h	copy half screen (alternate scan lines)
*/

FILE *log;

void cli_InterpretParm(char *p)
{
	int ch, parm;

	p++;
	ch = tolower(*p++);
	parm = atol(p);

	switch (ch)
	{
	case 'v':  	VideoMode = parm;			break;
	case 'u':  	CFirst = parm;				break;
	case 'q':  	quiet = 1;				break;
	case 's':  	SoundMode = parm;			break;
	case '0':  	IOPortB |= 64;				break;
	case '1':  	IOPortB |= 128;				break;
	case '5':	Use50Hz = 1;				break;
	case 'b':  	IOPortB &= 0xc3;			break;
	case 'x':  	DoChecksum = 1;				break;
	case 'f':  	FrameExit = parm;			break;
	case 'd':  	dsp = parm;				break;
	case 'j':  	Joystick = parm;			break;
	case 'c':  	PaletteNumber = parm;
			UserPaletteNumber = parm;
                        if(parm == 2) {
                           IOPortB &= 0xf7;
/*                           Use50Hz = 1; */
                        }
                        break;
	case 'p':  	PaddleGame = (parm & 0xf) << 1;		break;
	case 'k':  	KeyBase = parm & 3;			break;
	case 'm':	MouseBase = parm & 3;			break;
	case 't':  	if (parm) TraceCount = parm; else TraceCount = 0xff;
			TraceEnabled = 1;
			log = fopen("z26.log", "w");
			if (log == NULL)
			{
				printf("Couldn't build log file.");
				TraceCount = 0;
				TraceEnabled = 0;
			}
			OldTraceCount = TraceCount;
			break;

	case 'r':  	if (parm == 0)
				NoRetrace = 0xff;
			else
				NoRetrace = parm;
			break;
	case 'y':	KeyPad = parm & 3;		       break; /* *EST* */
	case 'w':	Driving = 1;			       break; /* *EST* */ 
        case 'g':       BSType = parm & 0x0f;                  break; /* *EST* */
	case 'o':	SimColourLoss = 1;		       break; /* *EST* */
	case 'l':	Lightgun = parm;		       break; /* *EST* */
	case 'a':	LGadjust = parm;		       break; /* *EST* */
	case 'n':	ShowLineCount = 1;		       break; /* *EST* */
        case 'i':       Mindlink = parm & 3;                   break; /* *EST* */
        case '4':       AllowAll4 = 1;                         break; /* *EST* */
        case 'e':       EnableFastCopy = 1;                    break; /* *EST* */
        case 'z':       TurnScreen = 1;                        break; /* *EST* */
        case 'h':	HalfScreen = 1;			       break;
        default:   	printf("Bad command line switch seen: -%c", ch);
		   	exit(1);
	}
}

void cli_WriteParms(int argc, char *argv[])
{
	int i, ch;
	FILE *fp;
	char *p;

	fp = fopen("z26.cli", "w");
	if (fp == NULL)
	{
		printf("Couldn't build cli file.");
		exit(1);
	}

	i = 1;
	argc--;		/* skip over the filename */

	while (argc--)
	{
		p = argv[i++];
		if (*p == '-')
		{		
			while (ch = *p++)
			{
				fputc(ch, fp);
			}
			
			fputc(' ', fp);
		}
	}

	fputc(0, fp);
	fclose(fp);
}


void cli_ReadParms(void)
{
	int ch, i;
	FILE *fp;
	char ParmString[1024];
	char *p;

	fp = fopen("z26.cli", "r");
	if (fp == NULL)
		return; /* was return(0); *EST* */
	i = 0;

	while ( (( ch = fgetc(fp)) != EOF) && (i <= 1022) )
		ParmString[i++] = ch;

	ParmString[i] = 0;
	i = 0;

	p = ParmString;

	while (*p == '-')
	{
		cli_InterpretParm(p);
		while (!isspace(*p++)) ;
	}
	
	fclose(fp);	
}


void cli_CommandLine(int argc, char *argv[])
{
	long int i;
	long int parm;
	int ch, cnt;
	unsigned char *p;
	char ROMLoaded = 0; char ROMSeen = 0;
      char FileName[260];  /* to z26.c */

	cli_ReadParms();

	i = 1;
	cnt = argc - 1;		/* skip over the program name */

	while(cnt--)
	{
		p = argv[i++];
		if (*p == '-')
			cli_InterpretParm(p);
		else
		{	
			strncpy(FileName,p,255);
			if (!strchr(FileName,'.'))
				strcat(FileName,".bin");
			ROMLoaded = cli_LoadROM(FileName);
			ROMSeen = 1;
			if (TraceCount) fprintf(log,"%s\n\n", FileName);
		}
	}

	if (!ROMSeen)
	{
		cli_WriteParms(argc, argv);
		printf("\nParameters recorded.\nTo restore defaults delete the file z26.cli.\n");
		exit(0);
	}

	if (!ROMLoaded)
	{
		printf("File not found... %s", FileName);
		exit(1);
	}
/*
	if (CartSize > 32768)
	{
		printf("Unsupported file.");
		exit(1);
	}
*/
	if (DoChecksum)
	{
		printf("%06lx checksum -- %08lx crc\n", Checksum, crc);
		printf("%ld bytes", (long int) CartSize);
		exit(1);
	}


}

