draw_char(char ch, char* font, char* surface, int width, int row, int col, int fg, int bg)
{
	int i,j;
	char *fp;	/* font pointer */
	char *sp;	/* surface pointer */

	char fbyte;	/* font byte */

	fp = font + 8*ch;

	for (i=0; i<8; i++)
	{
		sp = surface + width*(row+i) + col;
		fbyte = *fp++;		/* pick up a font byte */
		for (j=0; j<6; j++)
		{
			if (fbyte & 0x80)
				*sp++ = fg;
			else
				*sp++ = bg;
			fbyte <<= 1;
		}
	}
}

extern char *simplex5;
extern char *tiny5;

sl_putch(int row, int col, char ch)
{
	draw_char(ch, simplex5, srv_buffer, srv_pitch, row, col, 7, 0);
}

show_scanlines()
{
	char *mp;	/* message pointer */
	char ch;
	int col = 1;

	sprintf(msg, "%u LINES  %u FPS", LinesInFrame, CurrentFPS);
	mp = msg;
	while (1)
	{
		ch = *mp++;
		if (ch == 0) break;
		sl_putch(1, col, ch);
		col += 6;
	}
}
