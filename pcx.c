/*
** z26 is Copyright 1997-2001 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the
** GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/


char PCXFileName[13]={'z','2','6','p','0','0','0','0','.','p','c','x',0};

dw PCXFileCounter = 0;

void PCXWriteFile(void)
{

dw PCXMaxLines[15] = {
                200,
                200,
                200,
                204,
                240,
                240,
                240,
                400,
                240,
                400,
                256,
                256,
                256,
                400,
                256,
};

db PCXHeader[128] = { 0x0a,5,1,8,0,0,0,0,63,1,0xff,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,1,64,1,1,1,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0
                    };

        FILE *fp;
        int i, j, count;
        db ch;
        dw lines;

        lines=PCXMaxLines[VideoMode];
        PCXHeader[10]=(lines - 1) & 0xff;
        PCXHeader[11]=(lines - 1) >> 8;

        fp = fopen(PCXFileName,"wb");
        for(i=0; i<128; i++)
        {
                fputc(PCXHeader[i], fp);
        }
        for(i=0; i<lines; i++)
        {
                ch=ScreenBuffer[i*160];
                count=0;
                for(j=0; j<160; j++)
                {
                        if(ch == ScreenBuffer[i*160+j]) count++;
                        else
                        {
                                fputc(0xc0|((count*2)&0x3f), fp);
                                fputc(ch, fp);
                                count=1;
                                ch=ScreenBuffer[i*160+j];
                        }
                        if(count == 32)
                        {
                                fputc(0xfe, fp);
                                fputc(ch, fp);
                                count=1;
                                ch=ScreenBuffer[i*160+j];
                        }
                }
                if(count)
                {
                        fputc(0xc0|((count*2)&0x3f), fp);
                        fputc(ch, fp);
                }
        }
        fputc(0x0c, fp);
        for(i=0; i<384; i++)
        {
                fputc(PCXPalette[i], fp);
        }
        for(i=0; i<384; i++)
        {
                fputc(PCXPalette[i], fp);
        }
        fclose(fp);

        PCXFileCounter++;
        if(PCXFileCounter == 10000) PCXFileCounter = 0;
        sprintf(&PCXFileName[4],"%04i.pcx",PCXFileCounter);
}