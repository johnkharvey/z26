/*
** z26 GUI stuff 
*/

int	gui_mouse_enabled = 0;
int	gui_original_video_mode;

int	gui_textX = 24;		/* default coordinates of upper left corner of text window */
int	gui_textY = 50;
int	gui_textColor = 6;	/* default text color (11 == green) */


/* prototypes for ASM functions */

void far gui_DrawChar(int col, int row, int color, char ch);
void far gui_Line(int X1, int Y1, int X2, int Y2, int color);


/* set palette */

gui_SetPalette(int red, int green, int blue)
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

gui_RestoreVideoMode()
{
	union REGS inregs, outregs;
	
	/* restore original video mode */
	
	inregs.h.ah = 0;
	inregs.h.al = gui_original_video_mode;
	int86(0x10, &inregs, &outregs);
}


/* set gui graphics mode */

gui_GraphicsMode()
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

gui_CheckMouse()
{
	union REGS inregs, outregs;

	if (gui_mouse_enabled)
	{
		inregs.x.ax = 0;
		int86 (0x33, &inregs, &outregs);

		if (outregs.x.ax == 0)
		{
			gui_mouse_enabled = 0;
			printf("You need a mouse to run the z26 gui.");
			exit(1);
		}
	}
}


/* turn on mouse cursor */

gui_ShowMouse()
{
	union REGS inregs, outregs;
	
	if (gui_mouse_enabled)
	{
		inregs.x.ax = 1;
		int86(0x33, &inregs, &outregs);
	}
}


/* turn off the mouse cursor */

gui_HideMouse()
{
	union REGS inregs, outregs;

	if (gui_mouse_enabled)
	{
		inregs.x.ax = 2;
		int86(0x33, &inregs, &outregs);
	}
}


/* set a pixel */

gui_Pixel(int x1, int y1, int color)
{
	gui_Line(x1, y1, x1, y1, color);
}


/* draw a rectangle */

gui_Rectangle(int x1, int y1, int x2, int y2, int color)
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

gui_FilledRectangle(int x1, int y1, int x2, int y2, int color)
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

gui_Set8Pixels(int xc, int yc, int x, int y, int color)
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

gui_Circle(int xc, int yc, int r, int color)
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

gui_Draw4Lines(int xc, int yc, int x, int y, int color)
{
	gui_Line(xc-x, yc+y, xc+x, yc+y, color);
	gui_Line(xc-x, yc-y, xc+x, yc-y, color);

	gui_Line(xc-y, yc+x, xc+y, yc+x, color);
	gui_Line(xc-y, yc-x, xc+y, yc-x, color);
}


/* draw a disk */

gui_Disk(int xc, int yc, int r, int color)
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

gui_Panel(int x1, int y1, int x2, int y2, int color, int hilite, int lolite)
{
	gui_FilledRectangle(x1, y1, x2, y2, color);

	gui_Line(x1, y1, x2, y1, hilite);
	gui_Line(x2, y1, x2, y2, lolite);
	gui_Line(x2, y2, x1, y2, lolite);
	gui_Line(x1, y2, x1, y1, hilite);
}


/* draw a string */

/* ` sets color to following ASCII palette value */

gui_DrawString(int col, int row, int color, char *text)
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
					case 'r':  color = 8;			break;
					case 'o':  color = 9;			break;
					case 'y':  color = 10;			break;
					case 'g':  color = 11;			break;
					case 'b':  color = 12;			break;
					case 'i':  color = 13;			break;
					case 'v':  color = 14;			break;
					case 'w':  color = 15;			break;
					case 'U':  ul = 1;			break;
					case 'u':  ul = 0;			break;
					case 'd':  color = gui_textColor;	break;
					case 'n':  row += 10; col = gui_textX;	break;
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

gui_puts(char *text)
{
	gui_DrawString(gui_textX, gui_textY, gui_textColor, text);
	gui_textY += 10;
}


/* draw a button on the main panel */

gui_MainPanelButton(int y1, int color, char *Text)
{
	gui_Panel(10, y1, 110, y1+20, color, 1, 1);
	gui_DrawString(24, y1+7, 0, Text);
}


/* show the prototype main screen */

gui_ShowPrototype()
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


/* show the help screen title */

gui_ShowTitleBar(char *text)
{
	gui_FilledRectangle(97,10,630,30,2);
	gui_DrawString(107,17,10,text);
}


/* show the close box */

gui_ShowCloseBox()
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
#define rt 42
#define rb 466

/* show the scrollbar */

gui_ShowScrollBar(int i, int j)
{
	int barsize, bartop;

	barsize = (rb-rt)/j;
	bartop = rt + (i-1)*barsize;

	gui_FilledRectangle(610,40,630,467,2);
	gui_FilledRectangle(613,bartop,627,bartop+barsize,arrowcolor);
}

/* show the help screen */

gui_ShowHelpPage(int screen)
{
	extern char far help_0[];
	extern char far help_1[];
	extern char far help_2[];

	gui_FilledRectangle(10,40,600,467, 1);

	gui_textX = 24;
	gui_textY = 50;


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
	}

	gui_ShowScrollBar(screen+1, 3);
}


#define PgUp 0x49
#define PgDn 0x51
#define Home 0x47
#define esc  0x01

gui_GetScanCode()
{
	union REGS inregs, outregs;
	inregs.h.ah = 0;
	int86(0x16, &inregs, &outregs);
	return(outregs.h.ah);
}


/* show help screens */

#define pgmin 0
#define pgmax 2

gui_ShowHelp()
{
	int ch, page;

	gui_Panel(0,0,639,479, 3,4,2);
/*
	gui_FilledRectangle(10,40,630,467, 1);
*/
	gui_FilledRectangle(10,10,87,30,2);
	gui_DrawString(20,17,10,"z26 (1.21)");

	gui_DrawString(11, 470, 1, "\x0f");
	gui_DrawString(19, 470, 1, "1997-1998 by John Saeger                                                    http://www.whimsey.com/z26");

	gui_ShowTitleBar("Quick Reference");

	gui_ShowCloseBox();

	ch = 0;
	page = 0;
	gui_ShowHelpPage(page);
	while (ch != esc)
	{
		ch = 0;
		while (ch != PgUp && ch != PgDn && ch != esc && ch != Home)
			ch = gui_GetScanCode();

		if (ch == PgUp)
		{
			--page;
			if (page < pgmin) 
				page = pgmin;
			else
				gui_ShowHelpPage(page);
		}

		if (ch == PgDn)
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
	}
}
