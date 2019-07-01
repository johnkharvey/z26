// ;other definitions -- outside any segment
// 
// ; z26 is Copyright 1997-2011 by John Saeger and contributors.  
// ; z26 is released subject to the terms and conditions of the 
// ; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
// ; Please see COPYING.TXT for details.
// 
// ;;; MSDOS equ 021H     		;  MSDOS caller (Obsolete!)

#define CYCLESPERSCANLINE 76	// ;  TIA timing constant

// ;*
// ;* TIA register definitions
// ;*

#define VSYNC 	0x00         // ; * vertical sync set/clear       \- 
#define VBLANK 	0x01         // ; * vertical blank set/clear       \-  immediate
#define WSYNC 	0x02         // ; * wait for horizontal blank      /-  action
#define RSYNC 	0x03         // ; * reset horizontal sync counter /-

#define NUSIZ0 	0x04         // ;  missile/player size controls
#define NUSIZ1 	0x05 
#define COLUP0 	0x06         // ;  colors
#define COLUP1 	0x07 
#define COLUPF 	0x08 
#define COLUBK 	0x09 
#define CTRLPF 	0x0A         // ;  REF, SCORE, PFP, ball width
#define REFP0 	0x0B         // ;  reflect player
#define REFP1 	0x0C 
#define PF0 	0x0D         // ;  playfield bits
#define PF1 	0x0E 
#define PF2 	0x0F 
#define RESP0 	0x10         // ;  horizonal position
#define RESP1 	0x11 
#define RESM0 	0x12 
#define RESM1 	0x13 
#define RESBL 	0x14 

#define AUDC0 	0x15         // ; * audio control
#define AUDC1 	0x16         // ; *
#define AUDF0 	0x17         // ; * audio frequency
#define AUDF1 	0x18         // ; *
#define AUDV0 	0x19         // ; * audio volume
// #define AUDV1 	0x1A         // ; * <-- defined in c_tiasnd.c

#define GRP0 	0x1B         // ;  graphics
#define GRP1 	0x1C 
#define ENAM0 	0x1D         // ;  enables
#define ENAM1 	0x1E 
#define ENABL 	0x1F 
#define HMP0 	0x20         // ;  horizontal motion
#define HMP1 	0x21 
#define HMM0 	0x22 
#define HMM1 	0x23 
#define HMBL 	0x24 
#define VDELP0 	0x25         // ;  vertical delay
#define VDELP1 	0x26 
#define VDELBL 	0x27 
#define RESMP0 	0x28         // ;  missile locked to player
#define RESMP1 	0x29 

#define HMOVE 	0x2A         // ;  apply horizontal motion
#define HMCLR 	0x2B         // ;  clear horizontal motion registers
#define CXCLR 	0x2C		 // ;  clear collision latches

// ;*
// ;* to make macros easier to write
// ;*

#define NUSIZM0 NUSIZ0 
#define NUSIZM1 NUSIZ1 
#define NUSIZP0 NUSIZ0 
#define NUSIZP1 NUSIZ1 



// ;*
// ;* TIA bit mask definitions
// ;*

#define REF 	0x01         // ;  (CTRLPF) reflect playfield
#define SCORE 	0x02         // ;  (CTRLPF) score mode
#define PFP 	0x04  	     // ;  (CTRLPF) playfield gets priority


// ;*
// ;* pixel  bit definitions
// ;*

#define PF_BIT 	1 
#define BL_BIT 	2 
#define P1_BIT 	4 
#define M1_BIT 	8 
#define P0_BIT 	16 
#define M0_BIT 	32 
#define DL_BIT 	64 


// ; some display related stuff

#define DEFAULT_CFirst	39 
#define MEDIUM_Offset 	19   	// ;  offset a medium game this much
                        		// ;  tune so that game in mode 3 and mode 5
                        		// ;  appear at same vertical position
                        		// ;  (unless it's a known tall game)

#define MAX_TallGame 	240		// ;  size of a tall game
