/*
** z26 command line stuff
*/


/*
** z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/


/*
** load next Starpath Rom
*/

int cli_LoadNextStarpath(int LoadNum)
{
	int i,j;
	unsigned int pageadr, pagebyte, pagecount;
	unsigned char *p;
	unsigned char *q;

	if (LoadNum > 4) return(0);

	pagecount = CartRom[LoadNum*8448 + 0x2003];

	for (i = 0; i < pagecount; i++)
	{
		pagebyte = CartRom[LoadNum*8448 + 0x2010 + i];
		pageadr = ((pagebyte & 3) * 0x800) + ((pagebyte & 0x1f) >> 2) * 256;

		p = CartRom + pageadr;
		q = CartRom + LoadNum*8448 + i*256;

		for (j = 0; j < 256; j++)
		{
			*p++ = *q++;
		}
	}

	return(1);
}

/*
** reload a Starpath file
*/

int cli_ReloadStarpath(unsigned char *filename)
{
	int i,j;
	FILE *fp;
	unsigned int pageadr, pagebyte, pagecount;
	unsigned char *p;

	fp = fopen(filename, "rb");
	if (fp == NULL) return(0);

	pagecount = CartRom[0x2003];

	for (i = 0; i < pagecount; i++)
	{
		pagebyte = CartRom[0x2010 + i];
		pageadr = ((pagebyte & 3) * 0x800) + ((pagebyte & 0x1f) >> 2) * 256;

		p = CartRom + pageadr;
		for (j = 0; j < 256; j++)
		{
			*p++ = getc(fp);
		}
	}

	fclose(fp);
	return(1);
}

/*
** load a ROM image
**
** gets called from gui also -- special ROM setup can go here
*/

int cli_LoadROM(unsigned char *filename)
{
	FILE *fp;
	int i, j;
	int ch;
	unsigned char *p;

	fp = fopen(filename, "rb");
	if (fp == NULL)	return(0);
			
	p = CartRom;
	CartSize = 0;
	Checksum = 0;
	XChecksum = 0;

	while ( (ch = getc(fp)) != EOF )
	{
		*p++ = ch;
		Checksum += ch;
		if (XChecksum & 0x8000000) XChecksum |= 1;
		XChecksum = (XChecksum << 1) ^ ch;
		++CartSize;
		if (CartSize > 33998) break;
	}

	fclose(fp);

	if (CartSize == 2048)	/* 2K cart -- copy lower to upper */
	{
		for (i = 0; i < 2048; i++)
		{
			CartRom[2048+i] = CartRom[i];
		}
	}

	if (CartSize == 8448)	/* Starpath image -- reload according to page table */
	{
		for (i = 0; i < 0x2000; i++)	/* fill everything with Starpath halts */
		{
			CartRom[i] = 0x52;
		}

		cli_ReloadStarpath(filename);
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
**      -t      trace instructions
**  ->	-0      player 0 hard
**  ->	-1      player 1 hard
**      -y <n>  emulate none <0>, left <1>, right <2> or both <3> keypads *EST*
**      -w      emulate driving controllers *EST*
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
	case 'c':  	PaletteNumber = parm;			break;
	case 'p':  	PaddleGame = (parm & 0xf) << 1;		break;
	case 'k':  	KeyBase = parm & 3;			break;
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
        case 'y':       KeyPad = parm & 3;                     break; /* *EST* */
        case 'w':       Driving = 1;                           break; /* *EST* */ 
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
	char FileName[260];

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

	if (CartSize > 32768)
	{
		printf("Unsupported file.");
		exit(1);
	}

	if (DoChecksum)
	{
		printf("%lx checksum -- %lx alternative checksum\n", Checksum, XChecksum);
		printf("%ld bytes", (long int) CartSize);
		exit(1);
	}


}

