/******************************************************************************

    Atari VCS 2600 cart emulation

    Emulation of the cartslot for Atari 2600
    Several banking schemes have been used for larger roms,
    and some carts contained RAM.

    Mapper identification routines based on Cowering's code.

 ******************************************************************************/

// stripped down and converted to C for z26
// Aug 7, 2019

// z26 compatible cart type definitions

#define Z26_2K	0		// (by size)
#define Z26_4K	0		// (by size)
#define Z26_CV	1		// (signature mame)
#define Z26_F8S 2		// 8K superchip
#define Z26_E0	3		// (signature mame)
#define Z26_3F	4		// (signature mame)
#define Z26_FE	5		// (signature mame)
#define Z26_F6S 6		// 16K superchip
#define Z26_E7	7		// (signature Stella)
#define Z26_F4S 8		// 32K superchip
#define Z26_F8SW 9		// (signature mame) aka F8R -- 8K swapped
#define Z26_CM	10		// (CRC) Compumate
#define Z26_3FP 11		// 3F+ -- 512K tigervision (same as 3F in z26)
#define Z26_UA	12		// (signature mame)
#define Z26_EF	13		// (* undetected *) 64K Homestar Runner
#define Z26_3E	14		// (signature Stella)
#define Z26_AR	15		// Starpath
#define Z26_F6	16		// (signature mame)
#define Z26_F4	17		// (by size)
#define Z26_DC	18		// (signature mame) aka MB -- megaboy
#define Z26_FA	19		// (by size)
#define Z26_F8	20		// (by size)
#define Z26_DPC 21		// (by size) aka P2 -- pitfall 2
#define Z26_4A5 22		// (signature z26) supercat
#define Z26_084 23		// (* undetected *) EconoBanking

// these are in mame but not in z26

#define Z26_FV 0		// (signature mame)
#define Z26_JVP 0		// (signature mame)
#define Z26_32IN1 0
#define Z26_8IN1 0
#define Z26_4IN1 0
#define Z26_SS 0		// (signature mame)
#define Z26_X07 0
#define Z26_HARMONY 0

/*-------------------------------------------------
  detection helper routines
 -------------------------------------------------*/

int find_signature(const uint8_t *cart, uint32_t len, 
				   const uint8_t *signature, int siglen)
{
	int numfound = 0;

	for (int i = 0; i < len - sizeof signature; i++)
	{
		if (!memcmp(&cart[i], signature, siglen))
		{
			++numfound;
		}
	}
	return numfound;
}

int find_signatures(const uint8_t *cart, uint32_t len, 
					const uint8_t *signature, int siglen, int signum)
{
	while (signum--)
	{
		if (find_signature(cart, len, signature + signum*siglen, siglen))
		{
			return 1;
		}
	}
	return 0;
}

int detect_super_chip(const uint8_t *cart, uint32_t len)
{
	static const unsigned char signatures[] = {
									0xa2, 0x7f, 0x9d, 0x00, 0xf0, // dig dug
									0xae, 0xf6, 0xff, 0x4c, 0x00, // off the wall
	};

	if (len == 0x4000)
	{
		if (find_signatures(cart, len, signatures, 5, 2))
		{
			return 1;
		}
	}
	for (int i = 0x1000; i < len; i += 0x1000)
	{
		if (memcmp(cart, cart + i, 0x100))
		{
			return 0;
		}
	}
	/* Check the reset vector does not point into the super chip RAM area */
	if ((((cart[0x0ffd] << 8) | cart[0x0ffc]) & 0x0fff) < 0x0100)
	{
		return 0;
	}
	return 1;
}


int detect_modeDC(const uint8_t *cart, uint32_t len)
{
	// mame
	// signature is also in 'video reflex'.. maybe figure out that controller port someday...
	static const unsigned char signature[] = { 0x8d, 0xf0, 0xff };

	if (len == 0x10000)
	{
		return find_signature(cart, len, signature, 3);
	}
	return 0;
}

int detect_modeF6(const uint8_t *cart, uint32_t len)
{
	// mame
	static const unsigned char signature[] = { 0x8d, 0xf6, 0xff };

	if (len == 0x4000)
	{
		return find_signature(cart, len, signature, 3);
	}
	return 0;
}

int detect_snowhite(const uint8_t *cart, uint32_t len)
{
	// mame
	static const unsigned char snowwhite[] = { 0x10, 0xd0, 0xff, 0xff }; // Snow White Proto

	if (len == 0x2000 && !memcmp(&cart[0x1ffc], snowwhite, sizeof(snowwhite)))
		return 1;
	return 0;
}

int detect_mode3E(const uint8_t *cart, uint32_t len)
{

// mame
// this one is a little hacky... looks for STY $3e, which is unique to
// 'not boulderdash', but is the only example I have (cow)
// Would have used STA $3e, but 'Alien' and 'Star Raiders' do that for unknown reasons
//	static const unsigned char signature[3] = { 0x84, 0x3e, 0x9d };

	// Stella
	static const unsigned char signature[] = { 0x85, 0x3E, 0xA9, 0x00 };  // STA $3E; LDA #$00

	if (len >= 0x8000)	// <-- check this
	{
		return find_signature(cart, len, signature, 4);
	}
	return 0;
}

int detect_modeSS(const uint8_t *cart, uint32_t len)
{
	// mame
	static const unsigned char signature[] = { 0xbd, 0xe5, 0xff, 0x95, 0x81 };

	if (len == 0x0800 || len == 0x1000)
	{
		return find_signature(cart, len, signature, 5);
	}
	return 0;
}

int detect_modeFE(const uint8_t *cart, uint32_t len)
{
	// mame
	static const unsigned char signatures[] =  {
									0x20, 0x00, 0xd0, 0xc6, 0xc5,
									0x20, 0xc3, 0xf8, 0xa5, 0x82,
									0xd0, 0xfb, 0x20, 0x73, 0xfe,
									0x20, 0x00, 0xf0, 0x84, 0xd6,
	};

	if (len == 0x2000)
	{
		return find_signatures(cart, len, signatures, 5, 4);
	}
	return 0;
}

int detect_modeE0(const uint8_t *cart, uint32_t len)
{
	// mame
	static const unsigned char signatures[] =  {
									0x8d, 0xe0, 0x1f,
									0x8d, 0xe0, 0x5f,
									0x8d, 0xe9, 0xff,
									0xad, 0xe9, 0xff,
									0xad, 0xed, 0xff,
									0xad, 0xf3, 0xbf,
	};

	if (len == 0x2000)
	{
		return find_signatures(cart, len, signatures, 3, 6);
	}
	return 0;
}

int detect_modeCV(const uint8_t *cart, uint32_t len)
{
	// mame
	static const unsigned char signatures[] = {
									0x9d, 0xff, 0xf3,
									0x99, 0x00, 0xf4,
	};

	if (len == 0x0800 || len == 0x1000)
	{
		return find_signatures(cart, len, signatures, 3, 2);
	}
	return 0;
}

int detect_modeFV(const uint8_t *cart, uint32_t len)
{
	// mame
	static const unsigned char signatures[] = { 0x2c, 0xd0, 0xff };

	if (len == 0x2000)
	{
		return find_signatures(cart, len, signatures, 3, 1);
	}
	return 0;
}

int detect_modeJVP(const uint8_t *cart, uint32_t len)
{
	// mame
	static const unsigned char signatures[] = {
									0x2c, 0xc0, 0xef, 0x60,
									0x8d, 0xa0, 0x0f, 0xf0,
	};

	if (len == 0x4000 || len == 0x2000)
	{
		return find_signatures(cart, len, signatures, 4, 2);
	}
	return 0;
}

int detect_modeE7(const uint8_t *cart, uint32_t len)
{

// mame
//	static const unsigned char signatures[] = {
//									0xad, 0xe5, 0xff,
//									0x8d, 0xe7, 0xff,
//	};

	// Stella
	static const unsigned char signatures[] = {
    	0xAD, 0xE2, 0xFF,  // LDA $FFE2
    	0xAD, 0xE5, 0xFF,  // LDA $FFE5
    	0xAD, 0xE5, 0x1F,  // LDA $1FE5
    	0xAD, 0xE7, 0x1F,  // LDA $1FE7
    	0x0C, 0xE7, 0x1F,  // NOP $1FE7
    	0x8D, 0xE7, 0xFF,  // STA $FFE7
    	0x8D, 0xE7, 0x1F,  // STA $1FE7
	};

	if (len == 0x2000 || len == 0x4000)
	{
		return find_signatures(cart, len, signatures, 3, 7);
	}
	return 0;
}

int detect_modeUA(const uint8_t *cart, uint32_t len)
{
	// mame
	static const unsigned char signature[] = { 0x8d, 0x40, 0x02 };

	if (len == 0x2000)
	{
		return find_signature(cart, len, signature, 3);
	}
	return 0;
}

int detect_8K_mode3F(const uint8_t *cart, uint32_t len)
{
	int numfound = 0;
	// mame
	static const unsigned char signature1[] = { 0xa9, 0x01, 0x85, 0x3f };
	static const unsigned char signature2[] = { 0xa9, 0x02, 0x85, 0x3f };
	// have to look for two signatures because 'not boulderdash' gives false positive otherwise

	if (len == 0x2000)
	{
		for (int i = 0; i < len - sizeof signature1; i++)
		{
			if (!memcmp(&cart[i], signature1, sizeof signature1))
			{
				numfound |= 0x01;
			}
			if (!memcmp(&cart[i], signature2, sizeof signature2))
			{
				numfound |= 0x02;
			}
		}
	}
	if (numfound == 0x03)
		return 1;
	return 0;
}

int detect_32K_mode3F(const uint8_t *cart, uint32_t len)
{
	// mame
//	static const unsigned char signature[] = { 0xa9, 0x0e, 0x85, 0x3f };
	// Stella
	static const unsigned char signature[] = { 0x85, 0x3f };

	if (len >= 0x8000)
	{
		if (find_signature(cart, len, signature, 2) >= 2)
		{
			return 1;
		}
	}
	return 0;
}

/*-------------------------------------------------
 identify_cart_type - code to detect cart type from
 fullpath
 -------------------------------------------------*/

// 4in1 & 8in1 are not currently detected from fullpath...
int identify_cart_type(const uint8_t *ROM, uint32_t len)
{
	int type = 0;

	// auto-detect bank mode
	if (detect_modeDC(ROM, len))
		type = Z26_DC;
	else if (detect_mode3E(ROM, len))
		type = Z26_3E;
	else if (detect_modeFE(ROM, len))
		type = Z26_FE;
	else if (detect_modeSS(ROM, len))
		type = Z26_SS;
	else if (detect_modeE0(ROM, len))
		type = Z26_E0;
	else if (detect_modeCV(ROM, len))
		type = Z26_CV;
	else if (detect_modeFV(ROM, len))
		type = Z26_FV;
	else if (detect_modeJVP(ROM, len))
		type = Z26_JVP;
	else if (detect_modeUA(ROM, len))
		type = Z26_UA;
	else if (detect_8K_mode3F(ROM, len))
		type = Z26_3F;
	else if (detect_32K_mode3F(ROM, len))
		type = Z26_3FP;
	else if (detect_modeE7(ROM, len))
		type = Z26_E7;
	else if (detect_snowhite(ROM, len))
		type = Z26_F8SW;
	return type;
}

/**
** This file contains code from the MAME project which is
** released under the BSD-3-Clause license.
** Additional copyright holders: Fabio Priuli, Cowering
**
** BSD-3-Clause license
** --------------------
**
** Copyright (c) 2019, MAME 0.212 copyright holders
** All rights reserved.
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the <organization> nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
** 
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
** DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/**
** This file contains code (signatures) from the Stella project which is
** released under the GPL Version 2 license (see COPYING.TXT).
** Additional copyright holders: Bradford Mott, Steve Anthony
*/

/**
** z26 is Copyright 1997-2019 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/
