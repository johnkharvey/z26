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

draw_char4(char ch, char* font, char* surface, int width, int row, int col, int fg, int bg)
{
	int i,j;
	char *fp;	/* font pointer */
	dd *sp;		/* surface pointer */

	fg = srv_colortab[fg];
	bg = srv_colortab[bg];

	char fbyte;	/* font byte */

	fp = font + 8*ch;

	for (i=0; i<8; i++)
	{
		sp = (dd*) surface + width*(row+i)/4 + col;
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

draw_char2(char ch, char* font, char* surface, int width, int row, int col, int fg, int bg)
{
	int i,j;
	char *fp;	/* font pointer */
	dw *sp;		/* surface pointer */

	fg = srv_colortab[fg];
	bg = srv_colortab[bg];

	char fbyte;	/* font byte */

	fp = font + 8*ch;

	for (i=0; i<8; i++)
	{
		sp = (dw*) surface + width*(row+i)/2 + col;
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

draw_char3(char ch, char* font, char* surface, int width, int row, int col, int fg, int bg)
{
	int i,j;
	char *fp;	/* font pointer */
	db *sp;		/* surface pointer */

	fg = srv_colortab[fg];
	bg = srv_colortab[bg];

	char fbyte;	/* font byte */

	fp = font + 8*ch;

	for (i=0; i<8; i++)
	{
		sp = (db*) surface + width*(row+i) + 3*col;
		fbyte = *fp++;		/* pick up a font byte */
		for (j=0; j<6; j++)
		{
			if (fbyte & 0x80)
			{
				*sp++ = fg&0xff;
				*sp++ = (fg&0xff00)>>8;
				*sp++ = (fg&0xff0000)>>16;
			}
			else
			{
				*sp++ = bg&0xff;
				*sp++ = (bg&0xff00)>>8;
				*sp++ = (bg&0xff0000)>>16;
			}
			fbyte <<= 1;
		}
	}
}

extern char *simplex5;
extern char *tiny5;

show_scanlines()
{
	char *mp;	/* message pointer */
	char ch;
	int col = Horiz;

	sprintf(msg, "%u LINES  %u FPS   ", LinesInFrame, CurrentFPS);
	mp = msg;

	switch(srv_screen->format->BytesPerPixel)
	{
	case 4:
		while (1)
		{
			ch = *mp++;
			if (ch == 0) break;
			draw_char4(ch, simplex5, srv_buffer, srv_pitch, 1, col, 7, 0);
			col += 6;
		}
		break;

	case 3:
		while (1)
		{
			ch = *mp++;
			if (ch == 0) break;
			draw_char3(ch, simplex5, srv_buffer, srv_pitch, 1, col, 7, 0);
			col += 6;
		}
		break;

	case 2:
		while (1)
		{
			ch = *mp++;
			if (ch == 0) break;
			draw_char2(ch, simplex5, srv_buffer, srv_pitch, 1, col, 7, 0);
			col += 6;
		}
		break;

	default:
		while (1)
		{
			ch = *mp++;
			if (ch == 0) break;
			draw_char(ch, simplex5, srv_buffer, srv_pitch, 1, col, 7, 0);
			col += 6;
		}
		break;
	}
        SDL_UpdateRect(srv_screen, 1, 1, Horiz+120,8);
}
