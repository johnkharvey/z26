/*
** z26 GUI stuff 
*/

/*
** z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/

int	gui_mouse_enabled = 0;
int	gui_original_video_mode;

/*################################v MW v####################################*/
int     gui_LFN_enabled = 0;
char	Longname[261];

#define CFLAG 1
/*################################^ MW ^####################################*/

int	gui_textX = 24;		/* default coordinates of upper left corner of text window */
int	gui_textY = 50;
int	gui_textColor = 6;	/* default text color (11 == green) */

int	colpix = 0;
int	rowpix = 0;
int 	firstfile = 0;
int 	newfirstfile = 0;

int 	curfile = 1;
int	filesread;


#define cols 11
#define rows 63
#define files_on_screen rows*cols
#define maxfiles files_on_screen*4

char	gui_LastAscii = 0;	/* gets set by gui_GetScanCode */


/* prototypes for ASM functions */

void far gui_DrawChar(int col, int row, int color, char ch);
void far gui_Line(int X1, int Y1, int X2, int Y2, int color);
void far gui_Font(int Font);

/* set palette */

void gui_SetPalette(int red, int green, int blue)
{
	/* the object of the game is to split brightness across seven values (1 - 7) */
	/* we assume we are given the triple for value 5 */
	/* we multiply values by 2/6 3/6 4/6 5/6 6/6 7/6 8/6 times the given value */
	/* we allow the colors to saturate if the result is > 63 */

	/* the default palette -- entries 1-7 get overwritten */

	int   red_pal[] = {  0, 14, 18, 24, 31, 36, 40, 45, 60, 60, 50, 20, 10, 30, 50, 45 }; 
	int green_pal[] = {  0, 16, 20, 27, 34, 40, 45, 50, 20, 40, 50, 55, 30, 10, 10, 50 };
	int  blue_pal[] = {  0, 19, 24, 32, 41, 48, 54, 60, 20, 10,  0, 20, 63, 63, 63, 63 };

	union REGS inregs, outregs;

	int i;

	/* compute the palette */

	for (i=1; i<=7; i++)
	{
		  red_pal[i] = (i+1)*red/6;
		green_pal[i] = (i+1)*green/6;
		 blue_pal[i] = (i+1)*blue/6;

		if   (red_pal[i] > 63)   red_pal[i] = 63;
		if (green_pal[i] > 63) green_pal[i] = 63;
		if  (blue_pal[i] > 63)  blue_pal[i] = 63;
	}

	/* set up the DAC registers */

	for (i = 0; i<= 15; i++)
	{
		outportb(0x3c8,i);
		outportb(0x3c9,red_pal[i]);
		outportb(0x3c9,green_pal[i]);
		outportb(0x3c9,blue_pal[i]);
	}

	/* set up the palette RAM */

	for (i=0; i<=15; i++)
	{
		inregs.x.ax = 0x1000;
		inregs.h.bl = i;
		inregs.h.bh = i;
		int86(0x10, &inregs, &outregs);
	}
}


/* restore old video mode */

void gui_RestoreVideoMode(void)
{
	union REGS inregs, outregs;
	
	/* restore original video mode */
	
	inregs.h.ah = 0;
	inregs.h.al = gui_original_video_mode;
	int86(0x10, &inregs, &outregs);
}


/* set gui graphics mode */

void gui_GraphicsMode(void)
{
	union REGS inregs, outregs;

	/* save the current display mode */

	inregs.h.ah = 0x0f;
	int86(0x10, &inregs, &outregs);
	gui_original_video_mode = outregs.h.al;

	/* set the display into graphics mode */
	
	inregs.h.ah = 0;
	inregs.h.al = 0x12;
	int86(0x10, &inregs, &outregs);

	/* see if the mode set worked */

	inregs.h.ah = 0x0f;
	int86(0x10, &inregs, &outregs);

	if (outregs.h.al != 0x12)
	{
		gui_RestoreVideoMode();
		printf("You need a VGA to run z26.");
		exit(1);
	}
}


/* check for mouse */

void gui_CheckMouse(void)
{
	union REGS inregs, outregs;

	inregs.x.ax = 0;
	int86 (0x33, &inregs, &outregs);

	if (outregs.x.ax == 0)
	{
		gui_mouse_enabled = 0;
	}
	else
	{
		gui_mouse_enabled = 1;
	}
}


/* turn on mouse cursor */

void gui_ShowMouse(void)
{
	union REGS inregs, outregs;
	
	if (gui_mouse_enabled)
	{
		inregs.x.ax = 1;
		int86(0x33, &inregs, &outregs);
	}
}


/* turn off the mouse cursor */

void gui_HideMouse(void)
{
	union REGS inregs, outregs;

	if (gui_mouse_enabled)
	{
		inregs.x.ax = 2;
		int86(0x33, &inregs, &outregs);
	}
}


/* set a pixel */

void gui_Pixel(int x1, int y1, int color)
{
	gui_Line(x1, y1, x1, y1, color);
}


/* draw a rectangle */

void gui_Rectangle(int x1, int y1, int x2, int y2, int color)
{
	int temp;

	if (x2 < x1)
	{
		temp = x2;
		x2 = x1;
		x1 = temp;
	}

	if (y2 < y1)
	{
		temp = y2;
		y2 = y1;
		y1 = temp;
	}

	gui_Line(x1, y1, x2, y1, color);
	gui_Line(x2, y1, x2, y2, color);
	gui_Line(x2, y2, x1, y2, color);
	gui_Line(x1, y2, x1, y1, color);
}


/* draw a filled rectangle */

void gui_FilledRectangle(int x1, int y1, int x2, int y2, int color)
{
	int temp;

	if (x2 < x1)
	{
		temp = x2;
		x2 = x1;
		x1 = temp;
	}

	if (y2 < y1)
	{
		temp = y2;
		y2 = y1;
		y1 = temp;
	}

	do
	{
		gui_Line(x1, y1, x2, y1, color);
		y1++;
	}
	while (y1<=y2);
}


/* set 8 pixels for circle */

void gui_Set8Pixels(int xc, int yc, int x, int y, int color)
{
	gui_Pixel(xc+x, yc+y, color);
	gui_Pixel(xc-x, yc+y, color);
	gui_Pixel(xc+x, yc-y, color);
	gui_Pixel(xc-x, yc-y, color);

	gui_Pixel(xc+y, yc+x, color);
	gui_Pixel(xc-y, yc+x, color);
	gui_Pixel(xc+y, yc-x, color);
	gui_Pixel(xc-y, yc-x, color);
}


/* draw a circle */

void gui_Circle(int xc, int yc, int r, int color)
{
	int x=0;
	int y=r;
	int d=1-r;

	do
	{
		gui_Set8Pixels(xc, yc, x, y, color);

		x++;

		if (d < 0)
			d += 2*x + 1;
		else
		{
			y--;
			d += 2*(x - y) + 1;
		}
	}
	while (x <= y);
}


/* draw 4 lines for disk */

void gui_Draw4Lines(int xc, int yc, int x, int y, int color)
{
	gui_Line(xc-x, yc+y, xc+x, yc+y, color);
	gui_Line(xc-x, yc-y, xc+x, yc-y, color);

	gui_Line(xc-y, yc+x, xc+y, yc+x, color);
	gui_Line(xc-y, yc-x, xc+y, yc-x, color);
}


/* draw a disk */

void gui_Disk(int xc, int yc, int r, int color)
{
	int x=0;
	int y=r;
	int d=1-r;

	do
	{
		gui_Draw4Lines(xc, yc, x, y, color);

		x++;

		if (d < 0)
			d += 2*x + 1;
		else
		{
			y--;
			d += 2*(x - y) + 1;
		}
	}
	while (x <= y);
}


/* draw a panel */

void gui_Panel(int x1, int y1, int x2, int y2, int color, int hilite, int lolite)
{
	gui_FilledRectangle(x1, y1, x2, y2, color);

	gui_Line(x1, y1, x2, y1, hilite);
	gui_Line(x2, y1, x2, y2, lolite);
	gui_Line(x2, y2, x1, y2, lolite);
	gui_Line(x1, y2, x1, y1, hilite);
}


/* draw a string */

/* sets color to following ASCII palette value */

void gui_DrawString(int col, int row, int color, char *text)
{
	int ch;
	static int ul = 0;

	while (ch = *text++)
	{
		switch (ch)
		{
		case '`':
			ch = (*text++);
			if (isdigit(ch))
			{
				color = ch - '0';
			}
			else
			{
				switch(ch)
				{
					case 'r':	color = 8;			break;
					case 'o':	color = 9;			break;
					case 'y':	color = 10;			break;
					case 'g':	color = 11;			break;
					case 'b':	color = 12;			break;
					case 'i':	color = 13;			break;
					case 'v':	color = 14;			break;
					case 'w':	color = 15;			break;
					case 'U':	ul = 1;				break;
					case 'u':	ul = 0;				break;
					case 'd':	color = gui_textColor;	break;
					case 'n':	row += 10; col = gui_textX;	break;
				}
			}
			break;

		default:
			gui_Char(col, row, color, ch);
			if (ul)
			{
				gui_Line(col, row+9, col+6, row+9, color);
			}
			col += 6;
			break;
		}
	}
}


/* draw a string (simplified) */

extern int GUIFont;

void gui_puts(char *text)
{
	gui_DrawString(gui_textX, gui_textY, gui_textColor, text);
	if (GUIFont == 0)
		gui_textY += 10;
	else
		gui_textY += 7;  /* 7 */
}


/* draw a button on the main panel */

void gui_MainPanelButton(int y1, int color, char *Text)
{
	gui_Panel(10, y1, 110, y1+20, color, 1, 1);
	gui_DrawString(24, y1+7, 0, Text);
}


/* show the prototype main screen */

void gui_ShowPrototype(void)
{
	int vpos;

	gui_Panel(0,0,639,479, 3,4,2);

	gui_FilledRectangle(120,10,630,470, 1);

	gui_FilledRectangle(10,10,110,30,2);
	gui_DrawString(24,17,6,"z26 (1.21)");

	vpos = 55;
	gui_MainPanelButton(vpos,5,"Video Mode");
	vpos += 25;
	gui_MainPanelButton(vpos,5,"Frame Sync");
	vpos += 25;
	gui_MainPanelButton(vpos,5,"Sound");
	vpos += 25;
	gui_MainPanelButton(vpos,5,"DSP");
	vpos += 25;
	gui_MainPanelButton(vpos,5,"gui Color");
	vpos += 40;
	gui_MainPanelButton(vpos,5,"Help");
	vpos += 25;
	gui_MainPanelButton(vpos,5,"About");
	vpos += 40;
	gui_MainPanelButton(vpos,5,"Exit");

	gui_ShowMouse();

}

/* show main panel */

void gui_ShowMainPanel(void)
{
	gui_Panel(0,0,639,479, 3,4,2);
	gui_DrawString(8, 470, 1, "\x0f");
	gui_DrawString(16, 470, 1, "1997-2000 by John Saeger                                                     http://www.whimsey.com/z26");
}


/* show main inset */

void gui_ShowMainInset(void)
{
	gui_FilledRectangle(6,25,633,467, 1);
}


/* show "More files to the left" arrow or the left border */

void gui_MoreLeft(int mlf)              /* ###############< MW <##################### */
{
        if (mlf)
        {
                gui_FilledRectangle(0,25,5,467, 1); /* LEFT 1-inset  */
/*
                gui_DrawString(1, 246, 6, "\x11");
*/
        }
        else
        {
                gui_FilledRectangle(0,25,5,467, 3); /* LEFT 3-border */
		gui_Line(0,0,0,479,4);
                /* 0-BLK 1-GRY  2-GRY  3-GRY  4-GRY  5-WHT    6-WHT  7-WHT */
                /* 8-RED 9-ORN 10-YEL 11-GRN 12-BLU 13-DKBLU 14-VIO 15-WHT */
                /* gui_DrawString(16, 470, 1, "\x10\x11\x1a\x1b"); */
        }
}


/* show "More files to the right" arrow or the right border */

void gui_MoreRight(int mrf)             /* ###############< MW <##################### */
{
        if (mrf)
        {
                gui_FilledRectangle(634,25,639,467, 1); /* RIGHT 1-inset  */
/*
                gui_DrawString(635, 246, 6, "\x10");
*/
        }
	else
        {
                gui_FilledRectangle(634,25,639,467, 3); /* RIGHT 3-border */
		gui_Line(639,0,639,479,2);
                /* 0-BLK 1-GRY  2-GRY  3-GRY  4-GRY  5-WHT    6-WHT  7-WHT */
                /* 8-RED 9-ORN 10-YEL 11-GRN 12-BLU 13-DKBLU 14-VIO 15-WHT */
                /* gui_DrawString(16, 470, 1, "\x10\x11\x1a\x1b"); */
        }
}


/* show inset for exit screen */

void gui_ShowExitInset(void)
{
	gui_FilledRectangle(6,6,633,473,1);
}


/* show exit screen */

void gui_ShowExitScreen(void)
{
	gui_Panel(0,0,639,479, 3,4,2);
	gui_ShowExitInset();
	gui_Drawstring(280,210,5,"Exiting z26...");
}


/* show the help screen title */

void gui_ShowTitleBar(char *text)
{
	gui_FilledRectangle(92,5,633,19,2);
	gui_DrawString(102,9,10,text);
}


/* show a filename in the title area */

void gui_ShowFilename(char *text)
{
	int i, j, tch;

	i = strlen(text);
	while(i)
	{
		if (text[--i] == '.')
		{
			text[i] = 0;
			break;
		}
	}

	/* this is pretty ugly -- limit output to ~75 chars */

	j = strlen(text);
	if (j > 76)
	{
		tch = text[76];
		text[76]=0;
	}

	gui_FilledRectangle(92,5,565,19,2);
	gui_DrawString(102,9,6,text);

	/* put back what we've spoiled so we can open the file */

	text[i] = '.';
	if (j > 76)
		text[76]=tch;
}


/* show help button */


#define hl 583

void gui_ShowHelpButton(void)
{
	gui_FilledRectangle(hl-17,5,hl-11,19,3);
	gui_DrawString(hl,9,10,"`oF1`y Help`d");
}

/* show z26 */

void gui_ShowZ26(void)
{
	gui_FilledRectangle(6,5,84,19,2);
	gui_DrawString(16,9,10,version);
}

/* show the close box */

void gui_ShowCloseBox(void)
{
/*
	gui_FilledRectangle(610,10,630,30,2);
	gui_Line(614,14,626,26,1);
	gui_Line(615,14,627,26,1);
	gui_Line(613,14,625,26,1);
	gui_Line(626,14,614,26,1);
	gui_Line(627,14,615,26,1);
	gui_Line(625,14,613,26,1);
*/
}


#define arrowcolor 4
#define rt 27
#define rb 466
#define rl 618
#define rr 631

/* show the scrollbar */

void gui_ShowScrollBar(int i, int j)
{
	int barsize, bartop;

	barsize = (rb-rt)/j;
	bartop = rt + i*(barsize+1);

	if (i) --bartop;

	gui_FilledRectangle(rl-2,rt-2,rr+2,467,2);
	gui_FilledRectangle(rl,bartop,rr,bartop+barsize,arrowcolor);
}

/* show the help screen */

void gui_ShowHelpPage(int screen)
{
	extern char far help_0[];
	extern char far help_1[];
	extern char far help_2[];
	extern char far help_3[];	/* *EST* */
        extern char far help_4[];
	gui_FilledRectangle(6,25,609,467, 1);

	gui_textX = 18;
	gui_textY = 34;


	switch (screen)
	{
	case 0:	
		gui_puts(help_0);
		break;
	
	case 1: 
		gui_puts(help_1); 
		break;

	case 2: 
		gui_puts(help_2); 
		break;
	case 3:
		gui_puts(help_3);
		break;			/* *EST* */
        case 4:
                gui_puts(help_4);
		break;			/* *EST* */
	}

        gui_ShowScrollBar(screen, 5); /* changed to 5 help screens *EST* */
}


#define PgUp	   0x49
#define PgDn	   0x51
#define Home	   0x47
#define End	   0x4f
#define Esc	   0x01
#define F1	   0x3b
#define F10	   0x44
#define UpArrow	   0x48
#define DownArrow  0x50
#define LeftArrow  0x4b
#define RightArrow 0x4d
#define Enter	   0x1c
#define BackSlash  0x2b


/* mouse parameters */

#define vthresh 8
#define hthresh 24

int dx=0;
int dy=0;


/* check if there is mouse motion to be read */
/* we use this routine to avoid highlighting a file until motion stops */

int gui_MouseAhead(void)
{
	if ((dx < -hthresh) ||
	    (dx >  hthresh) ||
	    (dy < -vthresh) ||
	    (dy >  vthresh))
		return(1);
	else
		return(0);
}


/* convert mouse motion into a scan code */

int gui_MouseScan(void)
{
	union REGS inregs, outregs;

	int this_x, this_y;

	if (!gui_mouse_enabled) return 0;

	inregs.x.ax = 11;	/* # of mickeys since last call */
	int86 (0x33, &inregs, &outregs);

	this_x = outregs.x.cx;
	this_y = outregs.x.dx;

	/* dominance test -- make it easier to go just horiz or just vert */
	
	if (abs(this_x)*vthresh > 2*abs(this_y)*hthresh)
	{
		this_y = 0;
		dy = 0;
	}
	else if (abs(this_y)*hthresh > 2*abs(this_x)*vthresh)
	{
		this_x = 0;
		dx = 0;
	}

	dx += this_x;
	dy += this_y;

	if (dx < -hthresh)
	{
		dx += hthresh;
		return(LeftArrow);
	}
	else if (dx > hthresh)
	{
		dx -= hthresh;
		return(RightArrow);
	}
	else if (dy < -vthresh)
	{
		dy += vthresh;
		return(UpArrow);
	}
	else if (dy > vthresh)
	{
		dy -= vthresh;
		return(DownArrow);
	}

	inregs.x.ax = 3;	/* read mouse position and button status */
	int86 (0x33, &inregs, &outregs);
	if (outregs.x.bx & 7)
	{
		while (outregs.x.bx & 7)
		{
			int86(0x33, &inregs, &outregs);
		}

		return(Enter);
	}	

	return(0);
}


gui_GetScanCode(void)
{
	union REGS inregs, outregs;
	int scode;

	do
	{

		if (scode = gui_MouseScan())
		{
			gui_LastAscii = 0;
			return(scode);
		}

		inregs.h.ah = 1;
		int86(0x16, &inregs, &outregs);

	} while (outregs.x.flags & 64);

	inregs.h.ah = 0;
	int86(0x16, &inregs, &outregs);
	gui_LastAscii = outregs.h.al;		/* save last ASCII value for ASCII chars */

	return(outregs.h.ah);
}


/* show help screens */

#define pgmin 0
#define pgmax 4

void gui_ShowHelp(void)
{
	int ch, page;

	gui_ShowMainPanel();
	gui_ShowZ26();

	gui_ShowTitleBar("Quick Reference");

	gui_ShowCloseBox();

	ch = 0;
	page = 0;
	gui_ShowHelpPage(page);
	while ((ch != Esc) && (ch != Enter))
	{
		ch = 0;
		while (ch != PgUp && ch != PgDn && ch != Esc && ch != Home && ch != End 
		       && ch != Enter && ch != UpArrow && ch != DownArrow)
			ch = gui_GetScanCode();

		if ((ch == PgUp) || (ch == UpArrow))
		{
			--page;
			if (page < pgmin) 
				page = pgmin;
			else
				gui_ShowHelpPage(page);
		}

		if ((ch == PgDn) || (ch == DownArrow))
		{
			++page;
			if (page > pgmax) 
				page = pgmax;
			else
				gui_ShowHelpPage(page);
		}

		if (ch == Home)
		{
			if (page != 0)
			{
				page = 0;
				gui_ShowHelpPage(page);
			}
		}

		if (ch == End)
		{
			if (page != pgmax)
			{
				page = pgmax;
				gui_ShowHelpPage(page);
			}
		}
	}
}



/*################################v MW v####################################*/


/* check for Long File Name support */

void gui_CheckLFN(void)
{
	struct REGPACK regpack;
	unsigned char buffer[8];

	regpack.r_ax    = 0x71A7;				/* Win95 convert time */
	regpack.r_bx    = 0x0001;				/* Dos time to file   */
	regpack.r_cx    = 0x0000;				/* Dos time           */
	regpack.r_dx    = 0x0001;				/* Dos date           */
	regpack.r_es    = FP_SEG((void far *) buffer);		/* Set datasegment    */
	regpack.r_di    = FP_OFF((void far *) buffer);		/* Set offset         */
	regpack.r_flags = regpack.r_flags | CFLAG;		/* Set carryflag      */

	intr(0x21, &regpack);					/* Call interrupt     */

	if(regpack.r_ax == 0x7100)
		gui_LFN_enabled = 0;				/* No windows         */
	  else
		gui_LFN_enabled = 1;				/* In a dos-box       */
}


/* find start of filename in a path */

int findsof(char* main)
{
	int i=0;

	i = strlen(main);
	while(i)
	{
		if (main[--i] == '\\') return i+1;
	}

	return 0;
}


/* get long filename into filename buffer */

void gui_GetLFN(char* Shortname)
{
int i;

        if (gui_LFN_enabled)
        {

/*==============================================================================
LFN - Get Canonical Long Filename Or Path

        AX = 7160h
        CL = 02h
        CH = SUBST expansion flag
            00h return a path containing true path for a SUBSTed drive letter
            80h return a path containing the SUBSTed drive letter
        DS:SI -> ASCIZ short filename or path
        ES:DI -> 261-byte buffer for canonicalized long name

Return: CF set on error
            AX = error code
                02h invalid component in directory path or drive letter only
                03h malformed path or invalid drive letter
            ES:DI buffer unchanged
        CF clear if successful
            ES:DI buffer filled with qualified long name (can contain
                  lowercase letters)

Desc:   Function to get the Win95 long filename for a given short filename.
        determine the canonical name of the specified filename or path,
          corresponding to the undocumented TRUENAME command in COMMAND.COM

BUGS:   even though the maximum length of a complete long pathname is 260
          characters, Windows95 returns CF set/AX=0003h even if the file
          exists whenever the full pathname is more than 255 characters
        Windows95 incorrectly treats filenames where the first two characters
          after the drive letter and colon are both slashes (either forward
          or backward) as a UNC (network name) and requires several seconds
          to attempt to resolve the name before returning an unchanged
          string

SeeAlso: AH=60h,AX=7160h/CL=00h,AX=7160h/CL=01h
==============================================================================*/

		struct REGPACK regpack;

                static int fnpos;

                regpack.r_ax    = 0x7160;                         /* Get Canonical LFN   */
                regpack.r_cx    = 0x0002;                         /*  or Path            */
                regpack.r_ds    = FP_SEG((void far *) Shortname); /* Set SFN datasegment */
                regpack.r_si    = FP_OFF((void far *) Shortname); /* Set SFN offset      */
                regpack.r_es    = FP_SEG((void far *) Longname);  /* Set LFN datasegment */
                regpack.r_di    = FP_OFF((void far *) Longname);  /* Set LFN offset      */
                regpack.r_flags = regpack.r_flags | CFLAG;        /* Set carryflag       */

                intr(0x21, &regpack);                             /* Call interupt       */

                fnpos = findsof(Longname);

		i = 0;
		while (Longname[i++] = Longname[fnpos++]);

        }
}


/* display a long filename */

void gui_ShowLFN(char* Shortname)
{
	gui_Font(0);

	if (gui_LFN_enabled && strchr(Shortname, '~'))
	{
		gui_GetLFN(Shortname);
                gui_ShowFilename(Longname);
	}
	else
	{
		gui_ShowFilename(Shortname);
	}

        gui_Font(1);
}

/*################################^ MW ^####################################*/


/* compute colpix and rowpix */

void gui_SetRowCol(int FileNum)
{
	FileNum -= firstfile;

	colpix = gui_textX + (FileNum / rows) * 57;  /* 52, 57 */
	rowpix = gui_textY + (FileNum % rows) * 7;
}

/* show a short filename */

void gui_ShowShort(char *text, int color, int hideflag) /* ###############< MW <##################### */
{
	int ch;

        while ( (ch = *text++) != '.' )
	{
                if (ch == '~' && hideflag) break; /* ###############< MW <##################### */
		if (ch == 0)   break;
		gui_Char(colpix, rowpix, color, ch);
		colpix += 6;
	}
}


#include <dir.h>

void gui_ShowFile(int FileNum, char *text)
{
	--FileNum;

	gui_SetRowCol(FileNum);
        gui_ShowShort(text, gui_textColor, 1); /* ###############< MW <##################### */
}


void gui_HiLiteFile(int FileNum, char *name)
{
	--FileNum;

	gui_SetRowCol(FileNum);
	gui_FilledRectangle(colpix-1,rowpix-1,colpix+47,rowpix+5,9);
        gui_ShowShort(name, 1, 0); /* ###############< MW <##################### */
	gui_ShowLFN(name);
}

void gui_HiLiteChar(int FileNum, char *text, int charnum)
{
	--FileNum;

	gui_SetRowCol(FileNum);

	colpix += (charnum-1)*6;

	gui_FilledRectangle(colpix-1,rowpix-1,colpix+5,rowpix+5,10);
	gui_Char(colpix, rowpix, 1, text[charnum-1]);
}


void gui_LowLiteFile(int FileNum, char *text)
{
	--FileNum;

	gui_SetRowCol(FileNum);
	gui_FilledRectangle(colpix-1,rowpix-1,colpix+47,rowpix+5,1);
        gui_ShowShort(text, gui_textColor, 1); /* ###############< MW <##################### */
}


/* swap file ptrs (for gui_Qsort) */

void gui_swap(char *v[], int i, int j)
{
	char *temp;

	temp = v[i];
	v[i] = v[j];
	v[j] = temp;
}


/* sort files -- Quicksort -- C.A.R. Hoare (1962) -- via K&R p. 110 */

void gui_Qsort(char *v[], int left, int right)
{
	int i, last;

	if (left >= right) return;

	gui_swap(v, left, (left + right)/2);
	last = left;
	for (i=left+1; i<=right; i++)
		if (strcmp(v[i], v[left]) < 0)
			gui_swap(v, ++last, i);
	gui_swap(v, left, last);
	gui_Qsort(v, left, last-1);
	gui_Qsort(v, last+1, right);
}

int gui_getpage(int file)
{
	return((file-1)/(files_on_screen));
}

void gui_ShowTotal(int tot)
{
	char tempstr[100];

	int top, left, t_color, a_color;

	top = 470;
	left = 290;
	t_color = 6;
	a_color = 1;

	itoa(tot, tempstr, 10);
	gui_Font(0);
	if (gui_getpage(curfile) > 0) a_color = 6; else a_color = 1;
	gui_DrawString(left,top,a_color,"\021 ");
	gui_DrawString(left+12,top,t_color,tempstr);
	left += (strlen(tempstr)+2)*6;
	if (tot > 1)
	{
		gui_DrawString(left,top,t_color," ROMs");
		left += 5*6;
	}
	else
	{
		gui_DrawString(left,top,t_color," ROM");
		left += 4*6;
	}
	if (gui_getpage(curfile) < gui_getpage(filesread)) a_color = 6; else a_color = 1;
	gui_DrawString(left,top,a_color," \020");
	gui_Font(1);
}

void gui_ShowTooMany(void)
{
	int top = 470;
	int left = 275;
	int color = 8;

	gui_Font(0);
	gui_DrawString(left,top,color,"(Too many ROMs)");
	gui_Font(1);
}

int gui_HandleRightArrow(int curfile, int filesread)
{
	int curcol, lastcol;

	curcol = (curfile-1) / rows;
	lastcol = (filesread-1) / rows;

	/* normal behavior */

	if (curfile + rows <= filesread)
		return curfile+rows;

	/* only do weird behavior if last partial column */
	/* is first column on next screen */

	if (((curcol+1) % cols) != 0)
		return curfile;

	/* weird behavior -- jump to last file */

	if (curcol < lastcol) 
		return filesread;

	return curfile;
}

void gui_ShowList(void)
{
	int i, ch;
	int ach = 0;

	char 	*FileNamePtrs[maxfiles+2];

	struct ffblk ffblk;
	int done;


	char toomanyfiles = 0;

	int	ScanPtr = 0;
	int	StartPtr = 1;
	int	EndPtr = 1;
	int	Found = 0;
        int     curpage = 0;            /* ###############< MW <##################### */
        int     lastpage = 0;           /* ###############< MW <##################### */

	srand(time(NULL) % 37);

	for (i=1; i<=maxfiles; i++)
	{
		FileNamePtrs[i] = &Megaboy[14*i];
	}

	ch = 0;
	while (ch != Esc)
	{
		i = 1;

		/* load filenames into CartRom after every game */

		done = findfirst("*.bin", &ffblk, 0);
		if (!done)
		{
			while (!done)
			{
				strncpy(FileNamePtrs[i++],ffblk.ff_name,14);

				done = findnext(&ffblk);
				if (!done)
					if (i > maxfiles)
					{
						toomanyfiles = 1;
						break;
					}
			}
		}

		filesread = i - 1;
		if (filesread > 0) gui_Qsort(FileNamePtrs, 1, filesread);

		EndPtr = filesread;

		gui_ShowMainPanel();
		gui_ShowZ26();
		gui_ShowTitleBar(rom_list);
		gui_ShowHelpButton();
		gui_ShowCloseBox();
		gui_ShowMainInset();
	
		gui_textX = 9;
		gui_textY = 27;

		gui_Font(1);

		if (filesread > 0)
		{
			if (toomanyfiles)
				gui_ShowTooMany();
			else
				gui_ShowTotal(filesread);

			for (i=1; i+firstfile <= filesread; i++)
			{
				if (i > files_on_screen) break;
				gui_ShowFile(i+firstfile,FileNamePtrs[i+firstfile]);
			}
                        /* ###############v MW v##################### */
                        gui_Font(0);
                        gui_MoreLeft(curfile > files_on_screen);
                        curpage = 0;
                        while (curpage * files_on_screen < curfile) curpage++;
                        lastpage = 0;
                        while (lastpage * files_on_screen < filesread) lastpage++;
                        gui_MoreRight(curpage < lastpage);
                        gui_Font(1);
                        /* ###############^ MW ^##################### */
		}
		else
			gui_ShowFile(1,"(NO FILES)\0");

		if (filesread > 0) gui_HiLiteFile(curfile,FileNamePtrs[curfile]);

		ch = 0;
		while (ch != Esc && ch != F1 && ch != Enter)
		{
			ch = gui_GetScanCode();
			if (filesread > 0) 
				gui_LowLiteFile(curfile,FileNamePtrs[curfile]);
			else
				continue;

			switch(ch)
			{
			case BackSlash:	/* for testing */
				curfile = rand() % filesread;
				ScanPtr = 0;
				StartPtr = 1;
				EndPtr = filesread;
				Found = 0;
				break;

			case UpArrow:
				if (curfile > 1)
					curfile--;
				break;

			case DownArrow:
				if (curfile < filesread)
					curfile++;
				break;

			case RightArrow:
				curfile = gui_HandleRightArrow(curfile, filesread);
				break;

			case LeftArrow:
				if (curfile - rows >= 1)
					curfile -= rows;
				break;

			case Home:
				curfile = 1;
				break;

			case End:
				curfile = filesread;
				break;

			default:
				if (!isgraph(gui_LastAscii)) break;
				ach = toupper(gui_LastAscii);
				Found = 0;
				for (i=StartPtr; i<=EndPtr; i++)
				{
					if ( !Found && (FileNamePtrs[i][ScanPtr] == ach) )
					{
						curfile = i;
						StartPtr = curfile;
						Found = i;
					}
					if (  Found && (FileNamePtrs[i][ScanPtr] == ach) )
					{
						Found = i;
					}
				}

				EndPtr = Found;
				ScanPtr++;

				if (!Found)
				{
					if (filesread > 0) 					gui_HiLiteFile(curfile,FileNamePtrs[curfile]);
					ScanPtr = 0;
					StartPtr = 1;
					EndPtr = filesread;
					Found = 0;
					break;

				}
				break;

			}

			if (curfile > filesread) curfile = filesread;
			if (curfile < 1)	    curfile = 1;

			if (!isgraph(gui_LastAscii))
			{
				ScanPtr = 0;
				StartPtr = 1;
				EndPtr = filesread;
				Found = 0;
			}

			/* redraw screen if necessary */

			while (curfile < firstfile+1) firstfile -= files_on_screen;
			while (curfile > firstfile+files_on_screen) firstfile += files_on_screen;

			if (toomanyfiles)
				gui_ShowTooMany();
			else
				gui_ShowTotal(filesread);


			if (newfirstfile != firstfile)
			{
				newfirstfile = firstfile;				
				gui_ShowMainInset();

				for (i=1; i+firstfile <= filesread; i++)
				{
					if (i > files_on_screen) break;
					gui_ShowFile(i+firstfile,FileNamePtrs[i+firstfile]);
				}
                                /* ###############v MW v##################### */
                                gui_Font(0);
                                gui_MoreLeft(curfile > files_on_screen);
                                curpage = 0;
                                while (curpage * files_on_screen < curfile) curpage++;
                                lastpage = 0;
                                while (lastpage * files_on_screen < filesread) lastpage++;
                                gui_MoreRight(curpage < lastpage);
                                gui_Font(1);
                                /* ###############^ MW ^##################### */
			}

			if (!gui_MouseAhead()) gui_HiLiteFile(curfile,FileNamePtrs[curfile]);
			if (Found) gui_HiLiteChar(curfile,FileNamePtrs[curfile], ScanPtr);
			
		}

		gui_Font(0);

		if (ch == F1)
			gui_ShowHelp();

		if (ch == Enter)
		{
			def_LoadDefaults();
			cli_ReadParms();
			cli_LoadROM(FileNamePtrs[curfile]);

			psp = _psp;		/* for environment scanner  (sbdrv.asm) */
			emulator();		/* call emulator	      (tia.asm) */
			
			gui_SetPalette(35, 40, 45);	/* 31, 34, 41 */

		}
	}
}
