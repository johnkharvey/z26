/*
** modified by John Saeger
**
** Jan  6, 1998 -- Added ShiftRegister9 routine for more accurate 9-bit noise.
**                 Accurate noise -- think about it!
** 
** Jan  7, 1998 -- Moved modified Fillbuffer here for convenience.
**
** Jan 16, 1998 -- Added digital signal processing.
**
** Mar 26, 1998 -- Changed DMABufToLoad to a static unsigned char
*/


/*****************************************************************************/
/*                                                                           */
/* Module:  TIA Chip Sound Simulator                                         */
/* Purpose: To emulate the sound generation hardware of the Atari TIA chip.  */
/* Author:  Ron Fries                                                        */
/*                                                                           */
/* Revision History:                                                         */
/*    10-Sep-96 - V1.0 - Initial Release                                     */
/*    14-Jan-97 - V1.1 - Cleaned up sound output by eliminating counter      */
/*                       reset.                                              */
/*                                                                           */
/*****************************************************************************/
/*****************************************************************************/
/*                                                                           */
/*                 License Information and Copyright Notice                  */
/*                 ========================================                  */
/*                                                                           */
/* TiaSound is Copyright(c) 1996 by Ron Fries                                */
/*                                                                           */
/* This library is free software; you can redistribute it and/or modify it   */
/* under the terms of version 2 of the GNU Library General Public License    */
/* as published by the Free Software Foundation.                             */
/*                                                                           */
/* This library is distributed in the hope that it will be useful, but       */
/* WITHOUT ANY WARRANTY; without even the implied warranty of                */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library */
/* General Public License for more details.                                  */
/* To obtain a copy of the GNU Library General Public License, write to the  */
/* Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.   */
/*                                                                           */
/* Any permitted reproduction of these routines, in whole or in part, must   */
/* bear this legend.                                                         */
/*                                                                           */
/*****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>


/* define some data types to keep it platform independent */
#ifdef WIN32
#define int8  char
#define int16 short
#define int32 int
#else
#define int8  char
#define int16 int
#define int32 long
#endif

#define uint8  unsigned int8 
#define uint16 unsigned int16
#define uint32 unsigned int32


/* CONSTANT DEFINITIONS */

/* definitions for AUDCx (15, 16) */
#define SET_TO_1     0x00      /* 0000 */
#define POLY4        0x01      /* 0001 */
#define DIV31_POLY4  0x02      /* 0010 */
#define POLY5_POLY4  0x03      /* 0011 */
#define PURE         0x04      /* 0100 */
#define PURE2        0x05      /* 0101 */
#define DIV31_PURE   0x06      /* 0110 */
#define POLY5_2      0x07      /* 0111 */
#define POLY9        0x08      /* 1000 */
#define POLY5        0x09      /* 1001 */
#define DIV31_POLY5  0x0a      /* 1010 */
#define POLY5_POLY5  0x0b      /* 1011 */
#define DIV3_PURE    0x0c      /* 1100 */
#define DIV3_PURE2   0x0d      /* 1101 */
#define DIV93_PURE   0x0e      /* 1110 */
#define DIV3_POLY5   0x0f      /* 1111 */
                 
#define DIV3_MASK    0x0c                 
                 
#define AUDC0        0x15
#define AUDC1        0x16
#define AUDF0        0x17
#define AUDF1        0x18
#define AUDV0        0x19
#define AUDV1        0x1a

/* the size (in entries) of the 4 polynomial tables */
#define POLY4_SIZE  0x000f
#define POLY5_SIZE  0x001f
#define POLY9_SIZE  0x01ff

/* channel definitions */
#define CHAN1       0
#define CHAN2       1

#define FALSE       0
#define TRUE        !FALSE

/* FUNCTION PROTOTYPES */

void Tia_sound_init (unsigned int sample_freq, unsigned int playback_freq);
void Update_tia_sound (unsigned int addr, unsigned char val);
void Tia_process_2 (register unsigned char *buffer,
                    register unsigned int n);
void Tia_process (register unsigned char *buffer,
                  register unsigned int n,
		  char dsp);

/* LOCAL GLOBAL VARIABLE DEFINITIONS */

/* structures to hold the 6 tia sound control bytes */
static uint8 AUDC[2];    /* AUDCx (15, 16) */
static uint8 AUDF[2];    /* AUDFx (17, 18) */
static uint8 AUDV[2];    /* AUDVx (19, 1A) */

static uint8 Outvol[2];  /* last output volume for each channel */


/* Initialze the bit patterns for the polynomials. */

/* The 4bit and 5bit patterns are the identical ones used in the tia chip. */
/* Though the patterns could be packed with 8 bits per byte, using only a */
/* single bit per byte keeps the math simple, which is important for */
/* efficient processing. */

static uint8 Bit4[POLY4_SIZE] =
      { 1,1,0,1,1,1,0,0,0,0,1,0,1,0,0 };

static uint8 Bit5[POLY5_SIZE] =
      { 0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0,1,0,0,0,0,1 };

/* I've treated the 'Div by 31' counter as another polynomial because of */
/* the way it operates.  It does not have a 50% duty cycle, but instead */
/* has a 13:18 ratio (of course, 13+18 = 31).  This could also be */
/* implemented by using counters. */

static uint8 Div31[POLY5_SIZE] =
      { 0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0 };

/* Rather than have a table with 511 entries, I use a random number */
/* generator. */

static uint8 Bit9[POLY9_SIZE];

static uint8  P4[2]; /* Position pointer for the 4-bit POLY array */
static uint8  P5[2]; /* Position pointer for the 5-bit POLY array */
static uint16 P9[2]; /* Position pointer for the 9-bit POLY array */

static uint8 Div_n_cnt[2];  /* Divide by n counter. one for each channel */
static uint8 Div_n_max[2];  /* Divide by n maximum, one for each channel */


/* In my routines, I treat the sample output as another divide by N counter. */
/* For better accuracy, the Samp_n_cnt has a fixed binary decimal point */
/* which has 8 binary digits to the right of the decimal point. */

static uint16 Samp_n_max; /* Sample max, multiplied by 256 */
static uint16 Samp_n_cnt; /* Sample cnt. */


/*****************************************************************************/
/* Module:    ShiftRegister9                                                 */
/* Purpose:   To generate a sequence of pseudo-random bits 511 bits long     */
/*            by emulating a 9-bit shift register with feedback taps at      */
/*            positions 5 and 9.                                             */
/*                                                                           */
/* Author:    John Saeger                                                    */
/* Date:      Jan 6, 1998                                                    */
/*                                                                           */
/* Inputs:    none                                                           */
/*                                                                           */
/* Outputs:   the next bit in the sequence                                   */
/*                                                                           */
/* Reference: The Art of Electronics by Horowitz and Hill (1st ed.)          */
/*            pages 438-441                                                  */
/*                                                                           */
/*****************************************************************************/

int ShiftRegister9()
{
   static int sreg = 1;		/* initialize to a nonzero value */
   int bit1, bit5, bit9;	/* note: bits are numbered left to right */

   bit9 = sreg & 1;		/* register output and feedback bit */
   bit5 = (sreg & 16) >> 4;	/* the other feedback bit */
   bit1 = bit9 ^ bit5;		/* XOR them together */
   sreg = sreg >> 1;		/* shift the register */
   sreg |= bit1 << 8;		/* OR in the feedback */
   return(bit9);		/* return the register output */
}

/******************************************************************************/
/*                                                                            */
/* Module:   Fillbuffer                                                       */
/* Purpose:  Checks to see if the next buffer in the queue is empty and       */
/*           fills the buffer.                                                */
/*                                                                            */
/* Author:   Ron Fries                                                        */
/* Date:     September 10, 1996                                               */
/*                                                                            */
/******************************************************************************/

/*
** modified by John Saeger (Jan 8, 1998) to use sb.c Sound Blaster routines
*/

static unsigned char DMABufToLoad = 0;
extern unsigned int gHalfBufSize;
extern unsigned int dsp;

void Fillbuffer (void)
{
   /* if the SB initialized properly */
   if (Sb_init)
   {
      /* if buffer is not inuse */
      if (DMABufToLoad != gDMABufNowPlaying)
      {
         /* fill the buffer with data */
         if (DMABufToLoad == 0)
            Tia_process(DMABuf, gHalfBufSize, dsp);
         else
            Tia_process(DMABuf + gHalfBufSize, gHalfBufSize, dsp);

         /* buffer is ready to xmit */
         DMABufToLoad ^= 1;
      }
   }
}

/*****************************************************************************/
/* Module:  Tia_sound_init()                                                 */
/* Purpose: to handle the power-up initialization functions                  */
/*          these functions should only be executed on a cold-restart        */
/*                                                                           */
/* Author:  Ron Fries                                                        */
/* Date:    September 10, 1996                                               */
/*                                                                           */
/* Inputs:  sample_freq - the value for the '30 Khz' Tia audio clock         */
/*          playback_freq - the playback frequency in samples per second     */
/*                                                                           */
/* Outputs: Adjusts local globals - no return value                          */
/*                                                                           */
/*****************************************************************************/

void Tia_sound_init (uint16 sample_freq, uint16 playback_freq)
{
   uint8 chan;
   int16 n;

   /* fill the 9bit polynomial with random bits */

   for (n=0; n<POLY9_SIZE; n++)
   {
/*      Bit9[n] = rand() & 0x01;  */     /* fill poly9 with random bits */
	Bit9[n] = ShiftRegister9();	/* fill poly9 with pseudo-random bits */
   }

   /* calculate the sample 'divide by N' value based on the playback freq. */
   Samp_n_max = (uint16)(((uint32)sample_freq<<8)/playback_freq);
   Samp_n_cnt = 0;  /* initialize all bits of the sample counter */

   /* initialize the local globals */
   for (chan = CHAN1; chan <= CHAN2; chan++)
   {
      Outvol[chan] = 0;
      Div_n_cnt[chan] = 0;
      Div_n_max[chan] = 0;
      AUDC[chan] = 0;
      AUDF[chan] = 0;
      AUDV[chan] = 0;
      P4[chan] = 0;
      P5[chan] = 0;
      P9[chan] = 0;
   }
}


/*****************************************************************************/
/* Module:  Update_tia_sound()                                               */
/* Purpose: To process the latest control values stored in the AUDF, AUDC,   */
/*          and AUDV registers.  It pre-calculates as much information as    */
/*          possible for better performance.  This routine has not been      */
/*          optimized.                                                       */
/*                                                                           */
/* Author:  Ron Fries                                                        */
/* Date:    January 14, 1997                                                 */
/*                                                                           */
/* Inputs:  addr - the address of the parameter to be changed                */
/*          val - the new value to be placed in the specified address        */
/*                                                                           */
/* Outputs: Adjusts local globals - no return value                          */
/*                                                                           */
/*****************************************************************************/

void Update_tia_sound (uint16 addr, uint8 val)
{
    uint16 new_val = 0;
    uint8 chan;

    /* determine which address was changed */
    switch (addr)
    {
       case AUDC0:
          AUDC[0] = val & 0x0f;
          chan = 0;
          break;

       case AUDC1:
          AUDC[1] = val & 0x0f;
          chan = 1;
          break;

       case AUDF0:
          AUDF[0] = val & 0x1f;
          chan = 0;
          break;

       case AUDF1:
          AUDF[1] = val & 0x1f;
          chan = 1;
          break;

       case AUDV0:
          AUDV[0] = (val & 0x0f) << 3;
          chan = 0;
          break;

       case AUDV1:
          AUDV[1] = (val & 0x0f) << 3;
          chan = 1;
          break;

       default:
          chan = 255;
          break;
    }

    /* if the output value changed */
    if (chan != 255)
    {
       /* an AUDC value of 0 is a special case */
       if (AUDC[chan] == SET_TO_1)
       {
          /* indicate the clock is zero so no processing will occur */
          new_val = 0;

          /* and set the output to the selected volume */
          Outvol[chan] = AUDV[chan];
       }
       else
       {
          /* otherwise calculate the 'divide by N' value */
          new_val = AUDF[chan] + 1;

          /* if bits 2 & 3 are set, then multiply the 'div by n' count by 3 */
          if ((AUDC[chan] & DIV3_MASK) == DIV3_MASK)
          {
             new_val *= 3;
          }
       }

       /* only reset those channels that have changed */
       if (new_val != Div_n_max[chan])
       {
          /* reset the divide by n counters */
          Div_n_max[chan] = new_val;

          /* if the channel is now volume only or was volume only */
          if ((Div_n_cnt[chan] == 0) || (new_val == 0))
          {
             /* reset the counter (otherwise let it complete the previous) */
             Div_n_cnt[chan] = new_val;
          }
       }
    }
}


/*****************************************************************************/
/* Module:  Tia_process()                                                    */
/* Purpose: To fill the output buffer with the sound output based on the     */
/*          tia chip parameters.  This routine has been optimized.           */
/*                                                                           */
/* Author:  Ron Fries                                                        */
/* Date:    September 10, 1996                                               */
/*                                                                           */
/* Modified: Jan 16, 1998 -- added digital signal processing                 */
/*                                                                           */
/* Inputs:  *buffer - pointer to the buffer where the audio output will      */
/*                    be placed                                              */
/*          n - size of the playback buffer                                  */
/*          dsp - form of dsp to use (0=none,                                */
/*                                    1=moving average,                      */
/*                                    2=scaled moving average                */
/*                                                                           */
/* Outputs: the buffer will be filled with n bytes of audio - no return val  */
/*                                                                           */
/*****************************************************************************/

void Tia_process (register unsigned char *buffer, register uint16 n, char dsp)
{
    register uint8 audc0,audv0,audc1,audv1;
    register uint8 div_n_cnt0,div_n_cnt1;
    register uint8 p5_0, p5_1,outvol_0,outvol_1;
    
    static unsigned int prev_sample = 0;
    static unsigned char next_sample = 0;


    audc0 = AUDC[0];
    audv0 = AUDV[0];
    audc1 = AUDC[1];
    audv1 = AUDV[1];

    /* make temporary local copy */
    p5_0 = P5[0];
    p5_1 = P5[1];
    outvol_0 = Outvol[0];
    outvol_1 = Outvol[1];
    div_n_cnt0 = Div_n_cnt[0];
    div_n_cnt1 = Div_n_cnt[1];

    /* loop until the buffer is filled */
    while (n)
    {
       /* Process channel 0 */
       if (div_n_cnt0 > 1)
       {
          div_n_cnt0--;
       }
       else if (div_n_cnt0 == 1)
       {
          div_n_cnt0 = Div_n_max[0];

          /* the P5 counter has multiple uses, so we inc it here */
          p5_0++;
          if (p5_0 == POLY5_SIZE)
             p5_0 = 0;

          /* check clock modifier for clock tick */
          if  (((audc0 & 0x02) == 0) ||
              (((audc0 & 0x01) == 0) && Div31[p5_0]) ||
              (((audc0 & 0x01) == 1) &&  Bit5[p5_0]))
          {
             if (audc0 & 0x04)       /* pure modified clock selected */
             {
                if (outvol_0)        /* if the output was set */
                   outvol_0 = 0;     /* turn it off */
                else
                   outvol_0 = audv0; /* else turn it on */
             }
             else if (audc0 & 0x08)    /* check for p5/p9 */
             {
                if (audc0 == POLY9)    /* check for poly9 */
                {
                   /* inc the poly9 counter */
                   P9[0]++;
                   if (P9[0] == POLY9_SIZE)
                      P9[0] = 0;

                   if (Bit9[P9[0]])
                      outvol_0 = audv0;
                   else
                      outvol_0 = 0;
                }
                else                        /* must be poly5 */
                {
                   if (Bit5[p5_0])
                      outvol_0 = audv0;
                   else
                      outvol_0 = 0;
                }
             }
             else  /* poly4 is the only remaining option */
             {
                /* inc the poly4 counter */
                P4[0]++;
                if (P4[0] == POLY4_SIZE)
                   P4[0] = 0;

                if (Bit4[P4[0]])
                   outvol_0 = audv0;
                else
                   outvol_0 = 0;
             }
          }
       }


       /* Process channel 1 */
       if (div_n_cnt1 > 1)
       {
          div_n_cnt1--;
       }
       else if (div_n_cnt1 == 1)
       {
          div_n_cnt1 = Div_n_max[1];

          /* the P5 counter has multiple uses, so we inc it here */
          p5_1++;
          if (p5_1 == POLY5_SIZE)
             p5_1 = 0;

          /* check clock modifier for clock tick */
          if  (((audc1 & 0x02) == 0) ||
              (((audc1 & 0x01) == 0) && Div31[p5_1]) ||
              (((audc1 & 0x01) == 1) &&  Bit5[p5_1]))
          {
             if (audc1 & 0x04)       /* pure modified clock selected */
             {
                if (outvol_1)        /* if the output was set */
                   outvol_1 = 0;     /* turn it off */
                else
                   outvol_1 = audv1; /* else turn it on */
             }
             else if (audc1 & 0x08)    /* check for p5/p9 */
             {
                if (audc1 == POLY9)    /* check for poly9 */
                {
                   /* inc the poly9 counter */
                   P9[1]++;
                   if (P9[1] == POLY9_SIZE)
                      P9[1] = 0;

                   if (Bit9[P9[1]])
                      outvol_1 = audv1;
                   else
                      outvol_1 = 0;
                }
                else                        /* must be poly5 */
                {
                   if (Bit5[p5_1])
                      outvol_1 = audv1;
                   else
                      outvol_1 = 0;
                }
             }
             else  /* poly4 is the only remaining option */
             {
                /* inc the poly4 counter */
                P4[1]++;
                if (P4[1] == POLY4_SIZE)
                   P4[1] = 0;

                if (Bit4[P4[1]])
                   outvol_1 = audv1;
                else
                   outvol_1 = 0;
             }
          }
       }

       /* decrement the sample counter - value is 256 since the lower
          byte contains the fractional part */
       Samp_n_cnt -= 256;

       /* if the count down has reached zero */
       if (Samp_n_cnt < 256)
       {
          /* adjust the sample counter */
          Samp_n_cnt += Samp_n_max;

          /* calculate the latest output value and place in buffer */

          if (dsp)
          {
            /* take the edge off the square wave */

            next_sample = outvol_0 + outvol_1;

            /* scaled moving average (dsp = 2) */
            prev_sample = (prev_sample + next_sample) >> 1;
            *(buffer++) = (unsigned char) prev_sample;

            /* simple moving average (dsp = 1) */
            if (dsp == 1) prev_sample = next_sample;
          }
          else
          {
            /* no signal processing (dsp = 0) */
            *(buffer++) = outvol_0 + outvol_1; 
          }

          /* and indicate one less byte to process */
          n--;
       }
    }

    /* save for next round */
    P5[0] = p5_0;
    P5[1] = p5_1;
    Outvol[0] = outvol_0;
    Outvol[1] = outvol_1;
    Div_n_cnt[0] = div_n_cnt0;
    Div_n_cnt[1] = div_n_cnt1;
}

