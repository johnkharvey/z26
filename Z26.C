/*
** z26 -- an Atari 2600 emulator
*/

/*
** z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
** contributors.  z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/


#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "globals.c"
#include "ct.c"
#include "carts.c"
#include "cli.c"
#include "trace.c"
#include "pcx.c"
#include "kidvid.c"
#include "palette.c"

#include "sdlsrv.c"

char *default_arg[] = { "z26", "-r100000", "-f5000", "demonatk.bin" };

extern void emulator();

void ClearScreenBuffers()
{
        int i;

        for (i=0; i<65000; i++)
        {
                RealScreenBuffer1[i] = 0;
                RealScreenBuffer2[i] = 0;
                RealScreenBuffer3[i] = 0;
                RealScreenBuffer4[i] = 0;
        }

}
int main(int argc, char *argv[])
{
        def_LoadDefaults();

        RealScreenBuffer1=(char *) calloc(65000,sizeof(char));
        if(RealScreenBuffer1==NULL)
        {
                srv_print("Couldn't allocate ScreenBuffer 1!  \n");
                exit(1);
        }

        RealScreenBuffer2=(char *) calloc(65000,sizeof(char));
        if(RealScreenBuffer2==NULL)
        {
                srv_print("Couldn't allocate ScreenBuffer 2!  \n");
                exit(1);
        }

        RealScreenBuffer3=(char *) calloc(65000,sizeof(char));
        if(RealScreenBuffer3==NULL)
        {
                srv_print("Couldn't allocate ScreenBuffer 3!  \n");
                exit(1);
        }

        RealScreenBuffer4=(char *) calloc(65000,sizeof(char));
        if(RealScreenBuffer4==NULL)
        {
                srv_print("Couldn't allocate ScreenBuffer 4!  \n");
                exit(1);
        }

        ClearScreenBuffers();

        ScreenBuffer = RealScreenBuffer1;
        ScreenBufferPrev = RealScreenBuffer2;

	if (argc == 1)
	{
//		cli_CommandLine(4, default_arg);
		srv_print("version 2.04");
		exit(1);
	}
	else
	{
	   	cli_CommandLine(argc, argv);
	}

   	emulator();		   /* call emulator -- (main.asm) */

	if (ShowFPS)
	{
		sprintf(msg, "%d fps",1000*(Flips-FrameExit/20)/(SDL_GetTicks()-FirstFlipTime));
		srv_print(msg);
	}
   	
	if(ShowLineCount) 
	{
		sprintf(msg, "%u scanlines in last frame\n",LinesInFrame);
		srv_print(msg);
	}
		
	switch(MessageCode) {
		case 1:
			sprintf(msg, "Unable to find load %02x\n", SC_ControlByte);
			srv_print(msg);
			break;
		case 2:
			sprintf(msg, "Starpath call @ %04x\n", cpu_pc);
			srv_print(msg);
			break;
		case 3:
			sprintf(msg, "JAM instruction %02x @ %04x\n", cpu_a, cpu_pc);
			srv_print(msg);
			break;
       		}


        free(RealScreenBuffer1);
        free(RealScreenBuffer2);
        free(RealScreenBuffer3);
        free(RealScreenBuffer4);
}                                                         
