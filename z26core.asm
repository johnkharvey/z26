
;;;;;

;; NASN version of Z26 asm code.

;; Converted from MASM syntax to NASM, 20040413 bkw. Most of the work
;; was done with a perl script (scripts/masm_to_nasm.pl), with a bit
;; of manual tweaking.

;; This file contains all the assembly code from Z26, catted together
;; in one file. To assemble, use NASM version 0.98.38 (other versions
;; may or may not work, YMMV). Get NASM from http://nasm.sourceforge.net

;; On Linux:
;;   nasm -t -felf -o z26core.o all.asm

;; On Windows: ***NOT TESTED YET***
;;   nasm -t -fcoff -o z26core.o all.asm


;;;;; macro kludgery to emulate variadic macros	

%macro fake_arg 0
	; fake argument
%endmacro

%macro PF_PixelLoop 5
	PF_PixelLoop %1, %2, %3, %4, %5, fake_arg
%endmacro

%macro BK_PixelLoop 5
	BK_PixelLoop %1, %2, %3, %4, %5, fake_arg
%endmacro

%macro PF_PixelLoop 4
	PF_PixelLoop %1, %2, %3, %4, fake_arg, fake_arg
%endmacro

%macro BK_PixelLoop 4
	BK_PixelLoop %1, %2, %3, %4, fake_arg, fake_arg
%endmacro

%macro PF_PixelLoop 3
	PF_PixelLoop %1, %2, %3, fake_arg, fake_arg, fake_arg
%endmacro

%macro BK_PixelLoop 3
	BK_PixelLoop %1, %2, %3, fake_arg, fake_arg, fake_arg
%endmacro

%macro PF_PixelLoop 2
	PF_PixelLoop %1, %2, fake_arg, fake_arg, fake_arg, fake_arg
%endmacro

%macro BK_PixelLoop 2
	BK_PixelLoop %1, %2, fake_arg, fake_arg, fake_arg, fake_arg
%endmacro

%macro PF_PixelLoop 1
	PF_PixelLoop %1, fake_arg, fake_arg, fake_arg, fake_arg, fake_arg
%endmacro

%macro BK_PixelLoop 1
	BK_PixelLoop %1, fake_arg, fake_arg, fake_arg, fake_arg, fake_arg
%endmacro

? equ 0
;;; page 66,132

; z26core.asm -- Atari 2600 emulator ASM core functions

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; Based on A26 version 0.15 by Paul Robson.

;;; merged: 	include head.asm		; (32) asm time definitions
;;; page 66,132

; head.asm -- Atari 2600 emulator ASM core functions

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; Based on A26 version 0.15 by Paul Robson.

; assembly time definitions

TRACE equ 1 
showdeep equ 1 
CHEATS equ 1 
;;; .386
;;; .MODEL flat, C



;;; end merge of head.asm


;;; merged: 	include extern.asm		; (32) external to ASM, internal to C
;*
;* extern.asm -- z26 externals (external to asm, internal to C program)
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.
extern CartRom  ; byte
extern ScreenBuffer  ; dword
extern PCXPalette  ; byte
extern SoundQ  ; byte
extern SQ_Max  ; dword
extern CartSize  ; dword
extern Checksum  ; dword
extern XChecksum  ; dword
extern VideoMode  ; byte
extern CFirst  ; dword
extern quiet  ; byte
extern IOPortA  ; byte
extern IOPortA_Controllers  ; byte
extern IOPortA_UnusedBits  ; byte
extern IOPortB  ; byte
extern DoChecksum  ; byte
extern dsp  ; byte
extern Joystick  ; byte
extern PaletteNumber  ; byte
extern KeyBase  ; byte
extern TraceCount  ; byte
extern TraceEnabled  ; byte
extern OldTraceCount  ; byte
extern KeyPad  ; byte
extern Driving  ; byte
extern BSType  ; dword
extern MouseBase  ; byte
extern SimColourLoss  ; byte
extern Lightgun  ; byte
extern LGadjust  ; dword
extern Mindlink  ; byte
extern AllowAll4  ; byte
extern EnableFastCopy  ; byte
extern KidVid  ; byte
extern KidVidTape  ; byte
extern SampleByte  ; byte
extern kv_TapeBusy  ; dword
extern LinesInFrame  ; dword	; *EST*
extern PrevLinesInFrame  ; dword
extern VBlankOn  ; dword
extern VBlankOff  ; dword
extern BailoutLine  ; dword
extern MaxLines  ; dword
extern UserPaletteNumber  ; byte
extern SC_StartAddress  ; dword
extern SC_ControlByte  ; byte

;dw cpu_pc;
;db cpu_a, cpu_carry, cpu_x, cpu_y, cpu_sp;
;db cpu_ZTest, cpu_NTest, cpu_D, cpu_V, cpu_I, cpu_B;
extern cpu_pc  ; dword
extern cpu_a  ; byte
extern cpu_carry  ; byte
extern cpu_x  ; byte
extern cpu_y  ; byte
extern cpu_sp  ; byte
extern cpu_ZTest  ; byte
extern cpu_NTest  ; byte
extern cpu_D  ; byte
extern cpu_V  ; byte
extern cpu_I  ; byte
extern cpu_B  ; byte
extern cpu_MAR  ; dword
extern cpu_Rbyte  ; byte
extern frame  ; dword
extern line  ; dword
extern cycle  ; byte
extern BL_Pos  ; dword
extern M0_Pos  ; dword
extern M1_Pos  ; dword
extern P0_Pos  ; dword
extern P1_Pos  ; dword
extern InitCVars  ; near
extern ShowRegisters  ; near
extern ShowInstruction  ; near
extern ShowWeird  ; near
extern ShowDeep  ; near
extern ShowVeryDeep  ; near
extern ShowAdjusted  ; near
extern ShowUndocTIA  ; near
extern ShowCollision  ; near
extern ShowSCWrite  ; near
extern cli_LoadNextStarpath  ; near
extern cli_ReloadStarpath  ; near
extern KoolAide  ; byte
extern RSBoxing  ; byte
extern UserCFirst  ; dword
extern DefaultCFirst  ; dword
extern MPdirection  ; byte
extern MinVol  ; byte
extern LG_WrapLine  ; byte
extern RecognizeCart  ; near
extern PCXWriteFile  ; near
extern kv_OpenSampleFile  ; near
extern kv_CloseSampleFile  ; near
extern kv_GetNextSampleByte  ; near
extern kv_SetNextSong  ; near
extern GeneratePalette  ; near
extern MessageCode  ; byte
extern srv_CreateScreen  ; near
extern srv_WindowScreen  ; near
extern srv_DestroyScreen  ; near
extern srv_CopyScreen  ; near
extern srv_Events  ; near
extern srv_Flip  ; near
extern srv_done  ; byte
extern KeyTable  ; byte
extern srv_get_mouse_movement  ; near
extern srv_get_mouse_button_status  ; near
extern srv_mouse_button  ; dword
extern srv_micky_x  ; dword
extern srv_micky_y  ; dword
extern emu_pixels  ; dword
extern screen_pixels  ; dword
extern emu_pixels_prev  ; dword
extern srv_SetPalette  ; near
extern srv_sound_on  ; near
extern srv_sound_off  ; near
extern DMABuf  ; dword
extern bufsize  ; dword
extern srv_lock_audio  ; near
extern srv_unlock_audio  ; near
extern ClearScreenBuffers  ; near
extern NoRetrace  ; dword
extern SyncToSoundBuffer  ; byte
extern ChargeTrigger0  ; dword
;EXTRN _ChargeTrigger1:dword
;EXTRN _ChargeTrigger2:dword
;EXTRN _ChargeTrigger3:dword
extern ChargeCounter  ; dword
extern DumpPorts  ; byte
extern InputLatch  ; byte
extern CM_Collumn  ; byte
extern ExitEmulator  ; byte
extern GamePaused  ; byte
extern OldCFirst  ; dword
extern Controls  ; near
extern InitCompuMate  ; near
extern ControlSWCHAWrite  ; near
extern TestLightgunHit  ; near
extern UpdateTrakBall  ; near
extern Seconds  ; dword
;;; end merge of extern.asm

;;; merged: 	include defs.asm		; (32) our definitions
;other definitions -- outside any segment

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

MSDOS equ 021H 		 ;  MSDOS	caller

CYCLESPERSCANLINE equ 76 		 ;  TIA timing constant

;*
;* TIA register definitions
;*

VSYNC equ 00h 		 ; * vertical sync set/clear       \ 
VBLANK equ 01h 		 ; * vertical blank set/clear       \  immediate
WSYNC equ 02h 		 ; * wait for horizontal blank      /  action
RSYNC equ 03h 		 ; * reset horizontal sync counter /

NUSIZ0 equ 04h 		 ;  missile/player size controls
NUSIZ1 equ 05h 
COLUP0 equ 06h 		 ;  colors
COLUP1 equ 07h 
COLUPF equ 08h 
COLUBK equ 09h 
CTRLPF equ 0Ah 		 ;  REF, SCORE, PFP, ball width
REFP0 equ 0Bh 		 ;  reflect player
REFP1 equ 0Ch 
PF0 equ 0Dh 		 ;  playfield bits
PF1 equ 0Eh 
PF2 equ 0Fh 
RESP0 equ 10h 		 ;  horizonal position
RESP1 equ 11h 
RESM0 equ 12h 
RESM1 equ 13h 
RESBL equ 14h 

AUDC0 equ 15h 		 ; * audio control
AUDC1 equ 16h 		 ; *
AUDF0 equ 17h 		 ; * audio frequency
AUDF1 equ 18h 		 ; *
AUDV0 equ 19h 		 ; * audio volume
AUDV1 equ 1Ah 		 ; *

GRP0 equ 1Bh 		 ;  graphics
GRP1 equ 1Ch 
ENAM0 equ 1Dh 		 ;  enables
ENAM1 equ 1Eh 
ENABL equ 1Fh 
HMP0 equ 20h 		 ;  horizontal motion
HMP1 equ 21h 
HMM0 equ 22h 
HMM1 equ 23h 
HMBL equ 24h 
VDELP0 equ 25h 		 ;  vertical delay
VDELP1 equ 26h 
VDELBL equ 27h 
RESMP0 equ 28h 		 ;  missile locked to player
RESMP1 equ 29h 

HMOVE equ 2Ah 		 ;  apply horizontal motion
HMCLR equ 2Bh 		 ;  clear horizontal motion registers
CXCLR equ 2Ch 		 ;  clear collision latches

;*
;* to make macros easier to write
;*

NUSIZM0 equ NUSIZ0 
NUSIZM1 equ NUSIZ1 
NUSIZP0 equ NUSIZ0 
NUSIZP1 equ NUSIZ1 



;*
;* TIA bit mask definitions
;*

REF equ 01h 		 ;  (CTRLPF) reflect playfield
SCORE equ 02h 		 ;  (CTRLPF) score mode
PFP equ 04h 		 ;  (CTRLPF) playfield gets priority


;*
;* pixel  bit definitions
;*

PF_BIT equ 1 
BL_BIT equ 2 
P1_BIT equ 4 
M1_BIT equ 8 
P0_BIT equ 16 
M0_BIT equ 32 
DL_BIT equ 64 


; some display related stuff

DEFAULT_CFirst equ 39 
MEDIUM_Offset equ 19 			 ;  offset a medium game this much
					 ;  tune so that game in mode 3 and mode 5
					 ;  appear at same vertical position
					 ;  (unless it's a known tall game)

MAX_TallGame equ 240 			 ;  size of a tall game



;;; end merge of defs.asm

;;; merged: 	include init.asm		; (32) initialized data
;*
;* init.asm -- initialize all data in z26 asm modules
;*
;* 09-02-02 -- 32-bit
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

[section .data]
IN_Start:  ; byte			; <-- start clearing hera

RiotRam		times 128 db 0	 ;  RIOT ram (must be initially zero)
TIA		times 64 db 0	 ;  TIA Registers (also should be zero)
Ram		times 2048 db 0	 ;  extra ram

Frame		dd  0	 ;  Frame Counter
PrevFrame	dd  0	 ;  Previous value frame counter

VBlanking	dd  0	 ;  0 if vblanking, -1 otherwise
VBlank		db  0	 ;  VBlank flag
VSyncFlag	db  0	 ;  VSync flag

ScanLine	dd  0	 ;  current scan line
OurBailoutLine	dd  0	 ;  initial bailout line
					 ;  we fine tune it if exceeded

TopLine		dd  0	 ;  top line of display
BottomLine	dd  0	 ;  bottom line of display

WByte		db  0	 ;  byte to write

DisplayPointer	dd  0	 ;  pointer into display RAM
IN_End:  ; byte			; <-- finish clearing here


[section .code]

;*
;* routine to do rep stosb to data segment
;*

rep_stosb:
	cmp	ecx,0
	jz near rs_done

rs_loop:
 	mov	byte [edi],al
	inc	edi
	dec	ecx
	jnz near rs_loop

rs_done:
	ret


;*
;* macro to clear memory
;*

;;; converted macro:
%macro clear_mem 2

	mov	edi, %1
	mov	ecx, %2
	sub	ecx,edi  ;  # of bytes to clear
	xor	al,al
	call	rep_stosb  ;  clear memory

%endmacro


;*
;* initialize data
;*

InitData:
	clear_mem  IN_Start,  IN_End

 	mov	dword [OurBailoutLine],1000
 	mov	dword [ScanLine],1
 	mov	dword [VBlanking],-1

 	mov	eax,dword [ScreenBuffer]
 	mov	dword [DisplayPointer],eax

 	call	InitCVars
	call	Init_CPU
	call	Init_CPUhand
	call	Init_TIA
	call	Init_Riot
	call	Init_P2
	call	Init_Starpath
	call	Init_Tiasnd
	call	Init_SoundQ

	call	RandomizeRIOTTimer
	
	ret


;;; end merge of init.asm


;;; merged: 	include simplex5.asm		; large font
;
; Code for simplex5.f8
;

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.
global simplex5
simplex5 dd _simplex5
_simplex5:  ; byte
 db 000h,000h,000h,000h,000h,000h,000h,000h,038h,044h,092h,0bah,092h,044h,038h,000h,038h,044h,082h,082h,082h,044h,038h,000h,03ch,042h,0a1h,091h,089h,085h,042h,03ch
 db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,000h,078h,078h,07ah,07ah,002h,03eh,000h,0e0h,0e8h,0e8h,00ah,07ah,002h,03eh,000h,0ffh,081h,081h,081h,081h,081h,081h,0ffh
 db 0ffh,081h,0bdh,0bdh,0bdh,0bdh,081h,0ffh,0feh,082h,082h,082h,082h,082h,0feh,000h,000h,07eh,07eh,07eh,07eh,07eh,07eh,000h,0feh,082h,0aah,092h,0aah,082h,0feh,000h
 db 0feh,082h,08ah,092h,0a2h,082h,0feh,000h,03eh,020h,03eh,020h,020h,060h,0e0h,0c0h,03fh,021h,03fh,021h,023h,067h,0e6h,0c0h,07ch,082h,0bah,0a2h,0bah,082h,07ch,000h
 db 080h,0c0h,0e0h,0f0h,0e0h,0c0h,080h,000h,010h,030h,070h,0f0h,070h,030h,010h,000h,020h,070h,0f8h,020h,0f8h,070h,020h,000h,0feh,082h,0bah,0bah,0bah,082h,0feh,000h
 db 006h,00ch,018h,0e6h,0ceh,09eh,0feh,000h,018h,0a8h,0c8h,0e8h,008h,010h,020h,000h,040h,0a8h,098h,0b8h,080h,040h,020h,000h,020h,070h,0f8h,020h,0f8h,070h,020h,000h
 db 000h,020h,070h,0f8h,020h,020h,000h,000h,000h,020h,020h,0f8h,070h,020h,000h,000h,000h,020h,030h,0f8h,030h,020h,000h,000h,000h,020h,060h,0f8h,060h,020h,000h,000h
 db 008h,010h,020h,020h,020h,020h,040h,080h,000h,000h,050h,0f8h,050h,000h,000h,000h,070h,088h,0a8h,0a8h,088h,088h,088h,070h,070h,088h,0a8h,088h,088h,088h,088h,070h
 db 000h,000h,000h,000h,000h,000h,000h,000h,020h,020h,020h,020h,020h,000h,020h,000h,048h,048h,000h,000h,000h,000h,000h,000h,000h,050h,0f8h,050h,0f8h,050h,000h,000h
 db 020h,078h,0a0h,070h,028h,0f0h,020h,000h,000h,088h,010h,020h,040h,088h,000h,000h,060h,090h,060h,098h,090h,090h,068h,000h,020h,020h,040h,000h,000h,000h,000h,000h
 db 010h,020h,040h,040h,040h,020h,010h,000h,040h,020h,010h,010h,010h,020h,040h,000h,000h,088h,050h,0f8h,050h,088h,000h,000h,000h,020h,020h,0f8h,020h,020h,000h,000h
 db 000h,000h,000h,000h,000h,020h,020h,040h,000h,000h,000h,0f8h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,000h,000h,008h,010h,020h,040h,080h,000h,000h
 db 070h,088h,088h,0a8h,088h,088h,070h,000h,020h,060h,020h,020h,020h,020h,070h,000h,070h,088h,008h,010h,020h,040h,0f8h,000h,070h,088h,008h,030h,008h,088h,070h,000h
 db 090h,090h,090h,0f8h,010h,010h,010h,000h,0f8h,080h,080h,0f0h,008h,088h,070h,000h,070h,080h,080h,0f0h,088h,088h,070h,000h,0f8h,008h,008h,010h,020h,040h,040h,000h
 db 070h,088h,088h,070h,088h,088h,070h,000h,070h,088h,088h,078h,008h,008h,070h,000h,000h,020h,000h,000h,000h,020h,000h,000h,000h,020h,000h,000h,000h,020h,020h,040h
 db 000h,010h,020h,040h,020h,010h,000h,000h,000h,000h,0f8h,000h,000h,0f8h,000h,000h,000h,040h,020h,010h,020h,040h,000h,000h,070h,088h,008h,010h,020h,000h,020h,000h
 db 070h,088h,0a8h,0a8h,090h,080h,078h,000h,070h,088h,088h,0f8h,088h,088h,088h,000h,0f0h,088h,088h,0f0h,088h,088h,0f0h,000h,078h,080h,080h,080h,080h,080h,078h,000h
 db 0f0h,088h,088h,088h,088h,088h,0f0h,000h,0f8h,080h,080h,0e0h,080h,080h,0f8h,000h,0f8h,080h,080h,0f0h,080h,080h,080h,000h,078h,080h,080h,098h,088h,088h,070h,000h
 db 088h,088h,088h,0f8h,088h,088h,088h,000h,070h,020h,020h,020h,020h,020h,070h,000h,078h,008h,008h,008h,008h,008h,0f0h,000h,088h,090h,0a0h,0c0h,0a0h,090h,088h,000h
 db 080h,080h,080h,080h,080h,080h,0f8h,000h,088h,0d8h,0a8h,088h,088h,088h,088h,000h,088h,0c8h,0a8h,098h,088h,088h,088h,000h,070h,088h,088h,088h,088h,088h,070h,000h
 db 0f0h,088h,088h,0f0h,080h,080h,080h,000h,070h,088h,088h,088h,0a8h,090h,068h,000h,0f0h,088h,088h,0f0h,0a0h,090h,088h,000h,078h,080h,080h,070h,008h,008h,0f0h,000h
 db 0f8h,020h,020h,020h,020h,020h,020h,000h,088h,088h,088h,088h,088h,088h,070h,000h,088h,088h,088h,088h,088h,050h,020h,000h,088h,088h,088h,088h,0a8h,0d8h,088h,000h
 db 088h,088h,050h,020h,050h,088h,088h,000h,088h,088h,050h,020h,020h,020h,020h,000h,0f8h,008h,010h,020h,040h,080h,0f8h,000h,070h,040h,040h,040h,040h,040h,070h,000h
 db 000h,080h,040h,020h,010h,008h,000h,000h,070h,010h,010h,010h,010h,010h,070h,000h,000h,020h,050h,088h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0fch
 db 040h,040h,020h,000h,000h,000h,000h,000h,000h,000h,070h,008h,078h,088h,078h,000h,080h,080h,0f0h,088h,088h,088h,0f0h,000h,000h,000h,078h,080h,080h,080h,078h,000h
 db 008h,008h,078h,088h,088h,088h,078h,000h,000h,000h,070h,088h,0f8h,080h,070h,000h,038h,040h,040h,0f8h,040h,040h,040h,000h,000h,000h,070h,088h,088h,078h,008h,070h
 db 080h,080h,0f0h,088h,088h,088h,088h,000h,000h,020h,000h,020h,020h,020h,020h,000h,000h,008h,000h,008h,008h,008h,008h,070h,080h,080h,088h,090h,0e0h,090h,088h,000h
 db 060h,020h,020h,020h,020h,020h,030h,000h,000h,000h,050h,0a8h,0a8h,088h,088h,000h,000h,000h,0f0h,088h,088h,088h,088h,000h,000h,000h,070h,088h,088h,088h,070h,000h
 db 000h,000h,0f0h,088h,088h,0f0h,080h,080h,000h,000h,078h,088h,088h,078h,008h,008h,000h,000h,078h,080h,080h,080h,080h,000h,000h,000h,078h,080h,070h,008h,0f0h,000h
 db 000h,040h,0f8h,040h,040h,040h,038h,000h,000h,000h,088h,088h,088h,088h,070h,000h,000h,000h,088h,088h,088h,050h,020h,000h,000h,000h,088h,088h,0a8h,0a8h,050h,000h
 db 000h,000h,088h,050h,020h,050h,088h,000h,000h,000h,088h,088h,050h,020h,040h,080h,000h,000h,0f8h,010h,020h,040h,0f8h,000h,030h,020h,020h,040h,020h,020h,030h,000h
 db 020h,020h,020h,020h,020h,020h,020h,000h,060h,020h,020h,010h,020h,020h,060h,000h,068h,0b0h,000h,000h,000h,000h,000h,000h,000h,000h,020h,050h,088h,088h,0f8h,000h
 db 020h,020h,020h,020h,020h,020h,020h,000h,060h,020h,020h,010h,020h,020h,060h,000h,068h,0b0h,000h,000h,000h,000h,000h,000h,000h,000h,020h,050h,088h,088h,0f8h,000h

;;; end merge of simplex5.asm

;;; merged: 	include tiny5.asm		; small font
;
; Code for tiny5.f8
;

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.
global _tiny5
_tiny5 dd tiny5
tiny5:  ; byte
 db 000h,000h,000h,000h,000h,000h,000h,000h,038h,044h,092h,0bah,092h,044h,038h,000h,038h,044h,082h,082h,082h,044h,038h,000h,03ch,042h,0a1h,091h,089h,085h,042h,03ch
 db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,000h,078h,078h,07ah,07ah,002h,03eh,000h,0e0h,0e8h,0e8h,00ah,07ah,002h,03eh,000h,0ffh,081h,081h,081h,081h,081h,081h,0ffh
 db 0ffh,081h,0bdh,0bdh,0bdh,0bdh,081h,0ffh,0feh,082h,082h,082h,082h,082h,0feh,000h,000h,07eh,07eh,07eh,07eh,07eh,07eh,000h,0feh,082h,0aah,092h,0aah,082h,0feh,000h
 db 0feh,082h,08ah,092h,0a2h,082h,0feh,000h,03eh,020h,03eh,020h,020h,060h,0e0h,0c0h,03fh,021h,03fh,021h,023h,067h,0e6h,0c0h,07ch,082h,0bah,0a2h,0bah,082h,07ch,000h
 db 080h,0c0h,0e0h,0f0h,0e0h,0c0h,080h,000h,010h,030h,070h,0f0h,070h,030h,010h,000h,020h,070h,0f8h,020h,0f8h,070h,020h,000h,0feh,082h,0bah,0bah,0bah,082h,0feh,000h
 db 006h,00ch,018h,0e6h,0ceh,09eh,0feh,000h,018h,0a8h,0c8h,0e8h,008h,010h,020h,000h,040h,0a8h,098h,0b8h,080h,040h,020h,000h,020h,070h,0f8h,020h,0f8h,070h,020h,000h
 db 020h,070h,0f8h,020h,020h,000h,000h,000h,020h,020h,0f8h,070h,020h,000h,000h,000h,020h,030h,0f8h,030h,020h,000h,000h,000h,020h,060h,0f8h,060h,020h,000h,000h,000h
 db 030h,020h,020h,020h,060h,000h,000h,000h,000h,050h,0f8h,050h,000h,000h,000h,000h,070h,088h,088h,088h,070h,000h,000h,000h,070h,088h,0a8h,088h,070h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,000h,020h,020h,020h,000h,020h,000h,000h,000h,048h,048h,000h,000h,000h,000h,000h,000h,050h,0f8h,050h,0f8h,050h,000h,000h,000h
 db 078h,0a0h,070h,028h,0f0h,000h,000h,000h,088h,010h,020h,040h,088h,000h,000h,000h,060h,090h,060h,098h,070h,000h,000h,000h,020h,020h,040h,000h,000h,000h,000h,000h
 db 010h,020h,020h,020h,010h,000h,000h,000h,040h,020h,020h,020h,040h,000h,000h,000h,088h,050h,0f8h,050h,088h,000h,000h,000h,020h,020h,0f8h,020h,020h,000h,000h,000h
 db 000h,000h,000h,020h,020h,040h,000h,000h,000h,000h,0f8h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,000h,000h,000h,008h,010h,020h,040h,080h,000h,000h,000h
 db 070h,088h,0a8h,088h,070h,000h,000h,000h,020h,060h,020h,020h,070h,000h,000h,000h,070h,088h,010h,060h,0f8h,000h,000h,000h,0f0h,008h,070h,008h,0f0h,000h,000h,000h
 db 090h,090h,0f8h,010h,010h,000h,000h,000h,0f8h,080h,0f0h,008h,0f0h,000h,000h,000h,070h,080h,0f0h,088h,070h,000h,000h,000h,0f8h,008h,010h,020h,040h,000h,000h,000h
 db 070h,088h,070h,088h,070h,000h,000h,000h,070h,088h,078h,008h,070h,000h,000h,000h,000h,020h,000h,020h,000h,000h,000h,000h,000h,020h,000h,020h,020h,040h,000h,000h
 db 010h,020h,040h,020h,010h,000h,000h,000h,000h,0f8h,000h,0f8h,000h,000h,000h,000h,040h,020h,010h,020h,040h,000h,000h,000h,070h,088h,010h,020h,000h,020h,000h,000h
 db 070h,088h,0a8h,090h,080h,078h,000h,000h,070h,088h,0f8h,088h,088h,000h,000h,000h,0f0h,088h,0f0h,088h,0f0h,000h,000h,000h,078h,080h,080h,080h,078h,000h,000h,000h
 db 0f0h,088h,088h,088h,0f0h,000h,000h,000h,0f8h,080h,0e0h,080h,0f8h,000h,000h,000h,0f8h,080h,0f0h,080h,080h,000h,000h,000h,078h,080h,0b8h,088h,070h,000h,000h,000h
 db 088h,088h,0f8h,088h,088h,000h,000h,000h,070h,020h,020h,020h,070h,000h,000h,000h,078h,008h,008h,008h,0f0h,000h,000h,000h,088h,090h,0e0h,090h,088h,000h,000h,000h
 db 080h,080h,080h,080h,0f8h,000h,000h,000h,088h,0d8h,0a8h,088h,088h,000h,000h,000h,088h,0c8h,0a8h,098h,088h,000h,000h,000h,070h,088h,088h,088h,070h,000h,000h,000h
 db 0f0h,088h,0f0h,080h,080h,000h,000h,000h,070h,088h,0a8h,090h,068h,000h,000h,000h,0f0h,088h,0f0h,090h,088h,000h,000h,000h,078h,080h,070h,008h,0f0h,000h,000h,000h
 db 0f8h,020h,020h,020h,020h,000h,000h,000h,088h,088h,088h,088h,070h,000h,000h,000h,088h,088h,088h,050h,020h,000h,000h,000h,088h,088h,0a8h,0d8h,088h,000h,000h,000h
 db 088h,050h,020h,050h,088h,000h,000h,000h,088h,050h,020h,020h,020h,000h,000h,000h,0f8h,010h,020h,040h,0f8h,000h,000h,000h,070h,040h,040h,040h,070h,000h,000h,000h
 db 080h,040h,020h,010h,008h,000h,000h,000h,070h,010h,010h,010h,070h,000h,000h,000h,000h,020h,050h,088h,000h,000h,000h,000h,000h,000h,000h,000h,0f8h,000h,000h,000h
 db 040h,040h,020h,000h,000h,000h,000h,000h,000h,070h,090h,090h,078h,000h,000h,000h,080h,080h,0f0h,088h,0f0h,000h,000h,000h,000h,078h,080h,080h,078h,000h,000h,000h
 db 008h,008h,078h,088h,078h,000h,000h,000h,070h,088h,0f8h,080h,070h,000h,000h,000h,038h,040h,0f8h,040h,040h,000h,000h,000h,000h,070h,088h,078h,008h,070h,000h,000h
 db 080h,080h,0f0h,088h,088h,000h,000h,000h,020h,000h,020h,020h,020h,000h,000h,000h,008h,000h,008h,008h,048h,030h,000h,000h,080h,080h,090h,0e0h,090h,000h,000h,000h
 db 060h,020h,020h,020h,030h,000h,000h,000h,000h,050h,0a8h,0a8h,088h,000h,000h,000h,000h,0f0h,088h,088h,088h,000h,000h,000h,000h,070h,088h,088h,070h,000h,000h,000h
 db 000h,0f0h,088h,0f0h,080h,080h,000h,000h,000h,078h,088h,078h,008h,008h,000h,000h,000h,078h,080h,080h,080h,000h,000h,000h,030h,040h,020h,010h,060h,000h,000h,000h
 db 040h,0f8h,040h,040h,038h,000h,000h,000h,000h,088h,088h,088h,070h,000h,000h,000h,000h,088h,088h,050h,020h,000h,000h,000h,000h,088h,0a8h,0a8h,050h,000h,000h,000h
 db 000h,0d8h,020h,020h,0d8h,000h,000h,000h,000h,088h,088h,050h,020h,0c0h,000h,000h,000h,0f0h,020h,040h,0f0h,000h,000h,000h,030h,020h,040h,020h,030h,000h,000h,000h
 db 020h,020h,020h,020h,020h,000h,000h,000h,060h,020h,010h,020h,060h,000h,000h,000h,068h,0b0h,000h,000h,000h,000h,000h,000h,020h,050h,088h,088h,0f8h,000h,000h,000h
 db 020h,020h,020h,020h,020h,000h,000h,000h,060h,020h,010h,020h,060h,000h,000h,000h,068h,0b0h,000h,000h,000h,000h,000h,000h,020h,050h,088h,088h,0f8h,000h,000h,000h

;;; end merge of tiny5.asm


;;; merged: 	include service.asm		; I/O and other services for emulation core
; service.asm -- I/O and other services for z26 core

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 07-27-02 -- break ground


;*
;* sprite table support
;*

;;; converted macro:
%macro AddTablePointer 1
 	add	esi,dword [%1_Table] ; 32-bit -- add in table offset
%endmacro



;*
;* routine to do rep stosw to graphics segment
;*

;;; converted macro:
%macro gs_rep_stosw 0
	rep	stosw
%endmacro


;*
;* routine to store to graphics segment
;*

;;; converted macro:
%macro gs_store 2
	mov	byte %1, %2
%endmacro



;*
;* initialize services
;*

Init_Service:
	call	SetupSoundBlaster
	call	TIAGraphicMode		 ;  Switch into VGA mode
;	call	MouseInit		; *EST*
	ret

;*
;* end of program (escape pressed or bad opcode)
;*

GoDOS:
	call	kv_CloseSampleFile	 ;  close file if opened
	call	sound_clear		 ;  turn sound off (Soundblaster)
	call	TIARestoreVideoMode

	jmp	ModuleReturn

TestEscExit:
 	test	byte [ExitEmulator],128 ; ESC or backslash pressed?
	jnz near GoDOS
	ret

;*
;* soundblaster entry points
;*

SetupSoundBlaster:
	call	srv_sound_on
	ret

sound_clear:
	call	srv_sound_off
	ret


;*
;* frame synchronizer
;*

VSync:	
	pushad

	call	srv_Events
 	cmp	byte [srv_done],0
	jnz near GoDOS

	call	srv_Flip

	popad
	ret


;*
;* z26 linear graphics modes and palette setup
;*

TIARestoreVideoMode:
	pushad
	call	srv_DestroyScreen	 ;  destroy the screen
	popad
	ret

;*
;* turn on graphics mode
;*
global TIAGraphicMode

TIAGraphicMode:
	pushad
         cmp     byte [VideoMode],8 ; did user specify a valid (0-8) video mode
        jna near UserVideoMode            ;     yes, don't override
         mov     byte [VideoMode],0 ; set default mode
UserVideoMode:
	call	position_game		 ;  set game vertical positionn
;	call	_GeneratePalette	; calculate palette colors
	call	srv_CreateScreen	 ;  set up the screen
        call    ClearScreenBuffers      ;  clear the 4 buffers for screen comparing
	popad
	ret

;*
;* switch windowed mode
;*

TIAWindowMode:
	pushad
	call	srv_WindowScreen
	popad
	ret

;*
;* copy frame buffer to screen
;*

ModeXCopyScreen:
	pushad
	call	srv_CopyScreen
	popad
	ret


;*
;* routine to blank the remains of the screen buffer, if not all of the
;* displayed data gets filled by the rendering routine
;* gets called from MAIN.ASM
;*

BlankBufferEnd:
        pushad
 	mov	eax,dword [MaxLines]
 	lea	eax, [eax+eax*4]
	shl	eax,5			 ;  *160

 	add	eax,dword [ScreenBuffer]

 	cmp	dword [DisplayPointer],eax ; render pointer past end of displayable?
        jae near BBEret                   ;         yes, don't blank unfilled buffer

         mov     esi,dword [DisplayPointer]
        sub     eax,esi                  ;  max. buffer size - current buffer position
        mov     ebx,0
BBEdo:
         mov     dword [esi],ebx ; fill unused buffer space with black
        add     esi,4
        sub     eax,4
        jnz near BBEdo
BBEret:
        popad
        ret

;;; end merge of service.asm

;;; merged: 	include soundq.asm		; (32) sound queue stuff
;*
;* z26 sound stuff
;*
;* it's up to the *operating system* to empty the sound queue
;* it's up to the z26 core to fill it up
;*
;
; z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.


[section .data]

;_SQ_Max		dd	3072*3
SQ_Start:  ; byte		; <-- start clearing here

SQ_Input	dd  0	 ;  point to next avail byte for storing
SQ_Output	dd  0	 ;  point to next avail byte for fetching
SQ_Count	dd  0
SQ_Top		dd  0

;SQ_MAX = 3072*3			; 3072, 1024

;_SoundQ	times 65000 db 0
SQ_End:  ; byte			; <-- finish clearing here

[section .code]

;*
;* Initialize sound queue
;*

Init_SoundQ:
	clear_mem  SQ_Start,  SQ_End

 	mov	dword [SQ_Input], SoundQ ; initialize sound queue stuff
 	mov	dword [SQ_Output], SoundQ
 	mov	dword [SQ_Count],0
	mov	eax, SoundQ
	inc	eax
 	add	eax,dword [SQ_Max]
 	mov	dword [SQ_Top],eax
;	mov	[SQ_Top], SoundQ + SQ_MAX + 1

	ret

;*
;* routine to get status of sound queue
;*
;* returns:
;*
;*    -1 if sound queue full and no room for more output
;*     0 if there's too much room      (less than 1/2 full)
;*     1 if there's just enough room   (more than 1/2 full)
;*

SQ_Test:
 	cmp	byte [quiet],0 ; doing sound at all?
	jnz near SQ_Just_Right		 ;    no, pretend queue is *just right*

 	mov	eax,dword [SQ_Max]
 	cmp	dword [SQ_Count],eax ; sound queue already full?
	jae near SQ_Full			 ;    yes, don't queue anything
	shr	eax,1
 	cmp	dword [SQ_Count],eax ; less than 1/2 full?
	jbe near SQ_Empty		 ;    yes

SQ_Just_Right:
	mov	eax,1			 ;    no
	ret

SQ_Empty:
	mov	eax,0
	ret

SQ_Full:
	mov	eax,-1
	ret


;*
;* routine to put byte in al in the sound queue
;* always make sure SQ_Count < SQ_MAX before calling
;*

;;; extern debug_sound_byte ;;;DEBUG

SQ_Store:

	;;; pushad ;;; DEBUG
	;;; push eax ;;; DEBUG
	;;; call debug_sound_byte ;;; DEBUG
	;;; add esp, 4
	;;; popad ;;;DEBUG

	;;; what goes into the queue is what comes out - error in tiasnd, not here

 	cmp	byte [quiet],0 ; doing sound at all?
	jnz near SQS_skip_store		 ;    no, don't store sound byte

;	pushad
;	call	srv_lock_audio
;	popad

 	mov	esi,dword [SQ_Input]
 	mov	byte [esi],al
	inc	esi
 	inc	dword [SQ_Count]
 	cmp	esi,dword [SQ_Top]
	jb near SQS_done
	mov	esi, SoundQ
SQS_done:
 	mov	dword [SQ_Input],esi

;	pushad
;	call	srv_unlock_audio
;	popad

SQS_skip_store:
	ret


;*
;* routine to put the sound in the sound buffer
;*
global Tia_process

Tia_process:
	pushad
 	mov	eax,dword [bufsize]
 	cmp	dword [SQ_Count],eax ; enough sound available?
	ja near Sound_Enough		 ;    yes

	pushad				 ;    no, make sure there's enough
	call	QueueSoundBytes
	popad

Sound_Enough:
 	mov	ecx,dword [bufsize] ; # of bytes

 	mov	edi,dword [DMABuf]
 	mov	esi,dword [SQ_Output]

SoundFillLoop:
 	mov	al,byte [esi]
	inc	esi
 	cmp	esi,dword [SQ_Top]
	jb near SF_done
	mov	esi, SoundQ
SF_done: mov	byte [edi],al ; put it in soundblaster buffer
	inc	edi
	dec	ecx			 ;  more room in soundblaster buffer?
	jnz near SoundFillLoop		 ;    yes, get more

 	mov	eax,dword [bufsize]
 	sub	dword [SQ_Count],eax
 	mov	dword [SQ_Output],esi
	
SoundBufferBail:
	popad
	ret



;*
;* put a byte in the sound queue
;*

QueueSoundByte:
	call	SQ_Test
	cmp	eax,-1			 ;  sound queue already full?
	jne near QSB_room		 ;    no, there's room

;        cmp     [NoRetrace],-1         ; synchronizing to monitor?
         cmp     byte [SyncToSoundBuffer],1 ; syncronizing to sound buffer?
        jne near SoundQueueFull           ;    no, don't queue anything

	pushad				 ;    no, wait for room
	call	srv_Events
	popad
	jmp	QueueSoundByte

QSB_room:
	;;;FIXME: ;;; BKW: KidVid stuff commented out for now.
	;;;FIXME: ;;;call	KidVid_Sound_Byte	 ;    no, get kidvid sample
	;;;FIXME: ;;;push	eax
	call	TIA_Sound_Byte		 ;  get TIA sample
	;;;FIXME: ;;;pop	ebx			 ;  kidvid sample

	;;;FIXME: ;;;add     eax,ebx			 ;  mix the samples
	;;;FIXME: ;;;shr     eax,1

;;; 20040416 bkw: DIRTY HACK ALERT!
;;; Something's wrong with the TIA code, causing the sound output to
;;; be too quiet for humans to hear (at least on Linux). Blindly
;;; adding 0x70 to the sound byte makes it audible (though probably
;;; wildly inaccurate). For one thing, we only ever get 3 values out
;;; of TIA_Sound_Byte (that's 0x00, 0x10, and 0x20, with 0x00 occurring
;;; only at the beginning of emulation!). That means we're effectively
;;; working at 1.5 bits of sample resolution!
;;; Until I can fix whatever's wrong with TIA_Sound_Byte, this will
;;; at least let people hear something. Note that I have NO IDEA
;;; what this does to the Windows version.
		  add eax, 70h

	call	SQ_Store		 ;  put it in the sound queue

SoundQueueFull:
	ret

;*
;* put sound bytes into buffer
;* called once per scan line
;*

QueueSoundBytes:  ;  proc near


SoundQueueLoop:
	call	QueueSoundByte
	call	QueueSoundByte

	call	SQ_Test
	cmp	eax,0			 ;  sound queue at least 1/2 full?
	je near SoundQueueLoop		 ;    no

        ret

; QueueSoundBytes endp



;;; end merge of soundq.asm

;;; merged: 	include lincopy.asm		; (32) video copy support
; The Thomas Jentzsch linear screen copy routinen (32-bit)
; all code optimized for original P5 (without MMX)

;*
;* fast linear copy screen (160 pixels)
;*
global CFDoLinearCopy
; abcs -> abcd (with compare)
CFDoLinearCopy:
        pushad

         mov     esi,dword [emu_pixels]
         mov     ebp,dword [emu_pixels_prev]
         mov     edi,dword [screen_pixels]
        mov     ecx,40

CFDLCloop:                       ;  u v   execution pipes
         mov     eax,dword [esi] ; 1
        add     esi,4            ;    1
         cmp     eax,dword [ebp] ; 1
        je near CFDLCnoWrite     ;    1
         mov     dword [edi],eax ; 1
CFDLCnoWrite:
        add     edi,4            ;  1
        add     ebp,4            ;    1
        dec     ecx              ;  1
        jnz near CFDLCloop        ;    1
                                 ;  4-5   total cycles
; 50% average: 180 cycles (+extra penalties due to branch mispredictions)
        popad
        ret
global CDoLinearCopy
; abcd -> aabbccdd (with compare)
CDoLinearCopy:
        pushad

         mov     esi,dword [emu_pixels]
         mov     edi,dword [screen_pixels]
         mov     ebp,dword [emu_pixels_prev]
        mov     ecx,40

CDLCLoop:                        ;  u v   execution pipes
         mov     eax,dword [esi] ; 1     or more, depends on cache
        add     esi,4            ;    1
         cmp     eax,dword [ebp] ; 1     or more, depends on cache
        jne near CDLCcopy         ;    1
        add     ebp,4            ;  1
        add     edi,8            ;    1
        dec     ecx              ;  1
        jnz near CDLCLoop         ;    1
                                 ;  4     total cycles
        popad
        ret

CDLCcopy:
        mov     edx,eax          ;  1
        mov     al,ah            ;    1
        shl     eax,16           ;  1     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        mov     ebx,edx          ;    1
        shr     ebx,16           ;  1
        mov     dh,dl            ;    1
        and     edx, 0000ffffh   ;  1
        add     ebp,4            ;    1
        or      eax,edx          ;  1
        mov     edx,ebx          ;    1
        mov     bl,bh            ;  1
        mov     dh,dl            ;    1
        shl     ebx,16           ;  1
        and     edx, 0000ffffh   ;    1
         mov     dword [edi],eax ; 1
        or      ebx,edx          ;    1
         mov     dword [edi+4],ebx ; 1
        add     edi,8            ;    1
        dec     ecx              ;  1
        jnz near CDLCLoop         ;    1
                                 ; 12     total cycles
; 50% average: 320 cycles (+extra penalties due to branch mispredictions)
        popad
        ret
global CDoWideLinearCopy
; abcd -> aaaabbbbccccdddd (with compare)
CDoWideLinearCopy:
        pushad

         mov     esi,dword [emu_pixels]
         mov     ebp,dword [emu_pixels_prev]
         mov     edi,dword [screen_pixels]
        mov     ecx,40

CDWLCLoop:                       ;  u v   execution pipes
         mov     eax,dword [esi] ; 1     or more, depends on cache
        add     esi,4            ;    1
         cmp     eax,dword [ebp] ; 1
        jne near CDWLCcopy        ;    1   + extra penalties due to branch mispredictions
        add     ebp,4            ;  1
        add     edi,16           ;    1
        dec     ecx              ;  1
        jnz near CDWLCLoop        ;    1
                                 ;  4     total cycles
        popad
        ret

CDWLCcopy:
        mov     edx,eax          ;  1     abcd
        mov     ah,al            ;    1   a1
        mov     ebx,eax          ;  1     a2
        mov     dl,dh            ;    1   b1
        shl     eax,16           ;  1     a4
        and     ebx,0000ffffh    ;    1   a5
        or      eax,ebx          ;  1     a6
        mov     ebx,edx          ;    1   b2
         mov     dword [edi],eax ; 1     a7
        mov     eax,edx          ;    1   b3
        shl     ebx,16           ;  1     b4
        and     eax,0000ffffh    ;    1   b5
        shr     edx,16           ;  1     cd
        or      eax,ebx          ;    1   b6
         mov     dword [edi+4],eax ; 1     b7
        mov     eax,edx          ;    1   cd
        mov     ah,al            ;  1     c1
        mov     ebx,eax          ;    1   c2
        shl     eax,16           ;  1     c4
        and     ebx,0000ffffh    ;    1   c5
        mov     dl,dh            ;  1     d1
        or      eax,ebx          ;    1   c6
        mov     ebx,edx          ;  1     d2
        and     edx,0000ffffh    ;    1   d5
        shl     ebx,16           ;  1     d4
         mov     dword [edi+8],eax ; 1   c7
        or      edx,ebx          ;  1     d6
        add     ebp,4            ;    1   -
         mov     dword [edi+12],edx ; 1     d7

        add     edi,16           ;    1   -
        dec     ecx              ;  1     -
        jnz near CDWLCLoop        ;    1   -
                                 ; 18     total cycles
; 50% average: 440 cycles (+extra penalties due to branch mispredictions)
        popad
        ret
global FDoLinearCopy
; abcs -> abcd (with compare)
FDoLinearCopy:
        push    esi
         mov     esi,dword [emu_pixels]
        push    edi
         mov     edi,dword [screen_pixels]
        push    ecx
        mov     ecx,40

        rep movsd                ; 13 + n
; loop total: 53 cycles
        pop     ecx
        pop     edi
        pop     esi
        ret
global DoLinearCopy
; abcd -> aabbccdd
DoLinearCopy:
        pushad
         mov     esi,dword [emu_pixels]
         mov     edi,dword [screen_pixels]
        mov     ecx,40

DLCLoop:                         ;  u v   execution pipes
         mov     eax,dword [esi] ; 1     or more, depends on cache
        add     esi,4            ;    1
        mov     edx,eax          ;  1
        mov     al,ah            ;    1
        shl     eax,16           ;  1     instruction size prefix (pairs in u-pipe only, one extra decode cycle)
        mov     ebx,edx          ;    1
        shr     ebx,16           ;  1
        mov     dh,dl            ;    1
        and     edx, 0000ffffh   ;  1
        add     ebp,4            ;    1
        or      eax,edx          ;  1
        mov     edx,ebx          ;    1
        mov     bl,bh            ;  1
        mov     dh,dl            ;    1
        shl     ebx,16           ;  1
        and     edx, 0000ffffh   ;    1
         mov     dword [edi],eax ; 1
        or      ebx,edx          ;    1
         mov     dword [edi+4],ebx ; 1
        add     edi,8            ;    1
        dec     ecx              ;  1
        jnz near DLCLoop          ;    1
                                 ; 11     total cycles
; loop total: 440 cycles
        popad
        ret
global DoWideLinearCopy
; abcd -> aaaabbbbccccdddd
DoWideLinearCopy:
        pushad

         mov     esi,dword [emu_pixels]
         mov     edi,dword [screen_pixels]
        mov     ecx,40

DWLCLoop:                        ;  u v   execution pipes/cycles
         mov     eax,dword [esi] ; 1     or more, depends on cache
        add     esi,4            ;    1   -
        mov     edx,eax          ;  1     abcd
        and     eax,0000ffffh    ;    1   ab1
        mov     ebx,eax          ;  1     ab2
        mov     ah,al            ;    1   a1
        mov     ebp,eax          ;  1     a2
        add     edi,16           ;    1   -
        shl     eax,16           ;  1     a3
        mov     bl,bh            ;    1   b1
        or      eax,ebp          ;  1     a4
        mov     ebp,ebx          ;    1   b2
        shl     ebx,16           ;  1     b3
         mov     dword [edi-16],eax ; 1   a5
        shr     edx,16           ;  1     cd1
        or      ebp,ebx          ;    1   b4
        mov     eax,edx          ;  1     cd2
        mov     dh,dl            ;    1   c1
         mov     dword [edi-12],ebp ; 1     b5
        mov     ebx,edx          ;    1   c2
        shl     edx,16           ;  1     c3
        mov     al,ah            ;    1   d1
        mov     ebp,eax          ;  1     d2
        or      edx,ebx          ;    1   c4
        shl     eax,16           ;  1     d3
         mov     dword [edi-8],edx ; 1   c5
        or      eax,ebp          ;  1     d4
        dec     ecx              ;    1   -
         mov     dword [edi-4],eax ; 1     c5
        jnz near DWLCLoop         ;    1   -
                                 ; 15     total cycles
        popad
        ret
; loop total: 600 cycles
        popad
        ret

;;; end merge of lincopy.asm

;;; merged: 	include position.asm		; (32) position game vertically
[section .data]
StartLineTable:  ; dword
        dd      28, 28, 28       ;  400x300
        dd      22, 42, 42       ;  320x240
        dd      42, 58, 58       ;  320x200
        dd      28, 28, 28       ;  800x600
        dd      22, 42, 42       ;  640x480
        dd      42, 58, 58       ;  640x400
        dd      28, 28, 28       ;  800x600
        dd      22, 42, 42       ;  640x480
        dd      42, 58, 58       ;  640x400

;              NTSC PAL SECAM
MaxLineTable:  ; dword
        dd      266
        dd      240
        dd      200
        dd      266
        dd      240
        dd      200
        dd      266
        dd      240
        dd      200

[section .code]


position_game:

;*
;* set up max # of lines to display based on video mode
;*

 	movzx	esi,byte [VideoMode]
 	mov	esi,dword [MaxLineTable + esi*4]
         cmp     esi,dword [MaxLines] ; did user specify a screen height?
        ja near UserSetHeight            ;    yes, don't override
 	mov	dword [MaxLines],esi
UserSetHeight:

;*
;* set up CFirst (first line to display)
;*

 	mov	edx,dword [UserCFirst]
 	mov	dword [CFirst],edx
 	cmp	dword [UserCFirst],0ffffh ; did user specify a line number?
	jne near TGM_TestUltimate	 ;    yes, don't override
 	mov	edx,dword [DefaultCFirst]
 	mov	dword [CFirst],edx
 	cmp	dword [DefaultCFirst],0ffffh ; does game have a recommended starting line?
	jne near TGM_TestUltimate	 ;    yes, use it

         movzx   esi,byte [PaletteNumber]
        cmp     esi,3                    ;  if not NTSC, PAL or SECAM (0, 1, 2)
        jb near ValidPaletteNumber
        mov     esi,0                    ;    then position for NTSC game
ValidPaletteNumber:
         movzx   edx,byte [VideoMode]
        imul    edx,3                    ;  3 palettes per video mode
        add     esi,edx
 	mov	esi,dword [StartLineTable + esi*4]
 	mov	dword [CFirst],esi ; use the standard default

;*
;* adjust CFirst based on game size
;*

TGM_TestUltimate:
 	cmp	dword [MaxLines],400 ; in a very tall video mode?
	jb near TGM_Done		 ;    no
 	cmp	dword [CFirst],0 ; frogpond or pharhcrs ?
	jz near TGM_Done		 ;    yes
 	mov	dword [CFirst],1 ; no, this is ultimate reality mode

TGM_Done:
 	mov	edx,dword [CFirst]
 	mov	dword [OldCFirst],edx ; remember starting line for homing the display
 	mov	dword [TopLine],edx ; set up some things in case there's no vsync
 	add	edx,dword [MaxLines] ; (like bowlg_tw.bin)
 	mov	dword [BottomLine],edx

	ret

;;; end merge of position.asm


;*
;* emulator core files
;*

;;; merged: 	include main.asm		; (32) <-- the main machine
;*
;* main.asm -- main entry point here...
;*
;* 09-02-02 -- 32-bit
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.


[section .data]

ModuleSP	dd	?


[section .code]
global emulator

emulator:				 ;  near if small model, far if medium
	pushad

     	mov	eax,esp
 	mov	dword [ModuleSP],eax ; save sp (no return adr on stack)

	jmp	start

ModuleReturn:
 	mov	eax,dword [ModuleSP]
	mov	esp,eax

	popad

	ret



;*
;* main startup
;*

start:
       	call	InitData		 ;  initialize data
	call	RecognizeCart		 ;  do special setup for individual carts
	call	SetupBanks
	call	Reset			 ;  Reset the CPU -- must follow SetupBanks
	call	Init_Service
	call	Controls		 ;  check controls before emulation starts

;*
;* the main outer loop
;*

xmain:  
	call	VSync			 ;  now look for vblank
	call	ModeXCopyScreen		 ;  copy screenbuffer to video RAM
	call	ScanFrame

Paused:	pushad
	call	Controls		 ;  check which keys pressed
	popad
 	test	byte [GamePaused],1 ; game paused ?
	jz near xmain			 ;    no, next frame

PausedLoop:
	pushad
	call	Controls		 ;  check which keys pressed
	popad
 	test	byte [GamePaused],1 ; game paused ?
	jnz near PausedLoop		 ;    yes
	jmp	xmain			 ;  to next frame


;*
;* Do One Frame
;*

ScanFrame:
 	mov	eax,dword [ScreenBuffer] ; reset display pointer
 	mov	dword [DisplayPointer],eax
ScanFrameLoop:

	call	nTIALineTo		 ;  generate a raster line

	call	TestEscExit		 ;  exit if ESC pressed

 	inc	dword [ScanLine] ; Increment the scanline counter
 	sub  byte [RClock],CYCLESPERSCANLINE ; adjust RClock for next line

 	test	byte [VBlank],080h ; discharging capacitors ?
	jnz near ScanBailOut		 ;    yes
					 ; 	 no, put some charge on the capacitors
 	test dword [ChargeCounter],080000000h ; already fully charged ?
	jnz near ScanBailOut		 ;    yes, don't increment
 	inc  dword [ChargeCounter] ; no, add some charge

ScanBailOut:
 	mov	eax,dword [ScanLine] ; do emergency bail-out test
 	cmp	eax,dword [OurBailoutLine] ; too many lines?
	jl near NDret			 ;    not yet
 	mov	eax,dword [BailoutLine] ; yes, sharpen (or loosen) the test
 	mov	dword [OurBailoutLine],eax	

 	mov	edx,dword [LinesInFrame]
 	mov	dword [PrevLinesInFrame],edx
         mov     edx,dword [ScanLine] ; LinesInFrame is important for
         mov     dword [LinesInFrame],edx ; calculating the video frame delay
         dec     dword [LinesInFrame] ; So, we need to do it here too!

DontSharpen:
 	inc	dword [Frame] ; to the next frame
 	mov	dword [ScanLine],1

NDret:
 	mov	eax,dword [Frame]
 	cmp	eax,dword [PrevFrame] ; have we gone to a new frame ?
	je near ScanFrameLoop		 ;    not yet
        call    BlankBufferEnd           ;    yes, blank screen buffer if anything left
 	mov	dword [PrevFrame],eax ; yes, mark it as current
	ret				 ; 	 and return


;;; end merge of main.asm


;;; merged: 	include banks.asm		; (32) bank switch code
; banks.asm -- z26 bank switch stuff

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 02-17-98  got Parker Bros Working and added TigerVision
; 08-03-02  32-bit

[section .data]
RBankTab:  ; dword
	dd	RBank4			 ;   0 -- 4K Atari
	dd	RBankCV			 ;   1 -- Commavid
	dd	RBank8sc		 ;   2 -- 8K superchip
	dd	RBank8pb		 ;   3 -- 8K Parker Bros.
	dd	RBank8tv		 ;   4 -- 8K Tigervision
	dd	RBank8FE		 ;   5 -- 8K Flat
	dd	RBank16sc		 ;   6 -- 16K superchip
	dd	RBank16mn		 ;   7 -- 16K M-Network
	dd	RBank32sc		 ;   8 -- 32K superchip
	dd	RBank8			 ;   9 -- 8K Atari - banks swapped
	dd	RBankCM			 ;  10 -- Compumate
	dd	RBank32tv		 ;  11 -- 512K Tigervision
        dd      RBank8ua                 ;  12 -- 8K UA Ltd.
        dd      RBankEF                  ;  13 -- 64K Homestar Runner / Paul Slocum
	dd	RBank8P2		 ;  14 -- Pitfall2
	dd	RBank_SP		 ;  15 -- Starpath
	dd	RBank16			 ;  16 -- 16K Atari
	dd	RBank32			 ;  17 -- 32K Atari
	dd	RBankMB			 ;  18 -- Megaboy
        dd      RBank12                  ;  19 -- 12K
        dd      RBank8                   ;  20 -- 8K Atari
WBankTab:  ; dword
	dd	WBank4
	dd	WBankCV
	dd	WBank8sc
	dd	WBank8pb
	dd	WBank8tv
	dd	WBank8FE
	dd	WBank16sc
	dd	WBank16mn
	dd	WBank32sc
	dd	WBank8
	dd	WBankCM
	dd	WBank32tv
        dd      WBank8ua
        dd      WBankEF
	dd	WBank8P2
	dd	WBank_SP
	dd	WBank16
	dd	WBank32
	dd	WBankMB
	dd	WBank12
	dd	WBank8

RomBank		dd	0		 ;  Rom bank pointer for F8 & F16

; Parker Brother's ROM Slices

PBSlice0	dd	0
PBSlice1	dd	1*400h
PBSlice2	dd	2*400h
PBSlice3	dd	7*400h		 ;  this one doesn't change
					 ;  points to 1K bank #7
; Tigervision ROM Slices

TVSlice0	dd	0
TVSlice1	dd	3*800h		 ;  this one doesn't change
					 ;  points to 2K bank #3
; Tigervision 32 ROM Slices

TVSlice032	dd	0
TVSlice132	dd	15*800h		 ;  this one doesn't change
					 ;  points to 2K bank #15
; M-Network ROM Slices

MNSlice0	dd	0
MNSlice1	dd	7*800h		 ;  this one doesn't change
					 ;  points to 2K bank #3
; M-Network RAM Slices

MNRamSlice	dd	0		 ;  which 256 byte ram slice

; CompuMate RAM state

CMRamState	dd	10h		 ;  RAM enabled - read/write state

[section .code]

;*
;* set up bank switch scheme
;*

SetupBanks:
 	mov	dword [RomBank],0
 	mov	dword [PBSlice0],0
 	mov	dword [PBSlice1],1*400h
 	mov	dword [PBSlice2],2*400h
 	mov	dword [PBSlice3],7*400h
 	mov	dword [TVSlice0],0
 	mov	dword [TVSlice1],3*800h
 	mov	dword [TVSlice032],0
         mov     eax,dword [CartSize] ; make last 2K bank fixed for 3F games
        sub     eax,2048
         mov     dword [TVSlice132],eax
;        mov     [TVSlice132],15*800h
 	mov	dword [MNSlice0],0
 	mov	dword [MNSlice1],7*800h
 	mov	dword [MNRamSlice],0
 	mov	byte [Pitfall2],0
 	mov	byte [Starpath],0

 	mov	eax,dword [BSType] ; bankswitching type specified
	test	eax,eax			 ; 	  by user?
	je near DetectBySize		 ;  no ... autodetect it *EST*
	cmp	eax,1			    
	je near SCV			 ;  Commavid extra RAM
	cmp	eax,10
	je near SCM			 ;  CompuMate computer module
	ret

DetectBySize:
 	mov	eax,dword [CartSize]
	cmp	eax,02000h
	je near Set8kMode		 ;  8K cart
	cmp	eax,03000h
	je near Set12KMode		 ;  12K cart
	cmp	eax,04000h
	je near Set16kMode		 ;  16K cart
	cmp	eax,08000h
	je near Set32kMode		 ;  32K cart
	cmp	eax,028ffh
	je near SetPitfallII		 ;  Pitfall II cart
        cmp     eax,65536
	je near SMB			 ;  Megaboy 64K cart *EST*
	cmp	eax,6144
        je near SetStarpath              ;  Supercharger image
        mov     ebx,8448                 ;  file size is multiple of 8448 bytes?
        xor     edx,edx
        div     ebx
        cmp     edx,0
        je near SetStarpath              ;  ... must be Supercharger game
 	mov	eax,dword [CartSize]
        cmp     eax,65536
        ja near Set32kTVMode             ;  large Tigervision game
        ret


; Setup CompuMate

SCM: mov     dword [RomBank],03000h
	pushad
	call	InitCompuMate		 ;  init Compumate keyboard
	popad
	ret				 ;  see controls.c


; Setup Commavid RAM module

SCV:	mov	ebx,2047		 ;  copy ROM to RAM for MagiCard
SCV1: mov	al,byte [CartRom+ebx]
 	mov	byte [Ram+ebx],al
	dec	ebx
	jns	SCV1
	ret

Set8kMode:
 	mov	dword [RomBank],01000h ; need this for moonswep and lancelot
         mov     dword [BSType],20
	ret

Set12KMode:
         mov     dword [BSType],19
	ret

Set16kMode:
 	mov	dword [BSType],16
	ret

Set32kMode:
 	mov	dword [BSType],17
	ret

SMB: mov	dword [BSType],18
	ret

Set32kTVMode:
         mov     dword [BSType],11
        ret

;*
;* hardware read/write testing macros
;*

;;; converted macro:
%macro test_hw_read 0
	and	esi,01fffh
	cmp	esi,1000h  ;  if not ROM, read hardware
	jb near ReadHardware
%endmacro


;;; converted macro:
%macro test_hw_write 0
	and	esi,01fffh
	cmp	esi,1000h
	jb near WriteHardware
%endmacro


;;; converted macro:
%macro MapRomBank 0
 	add	esi,dword [RomBank]
	add	esi, CartRom - 1000h
%endmacro


;;; converted macro:
%macro WriteRam 0
 	mov	al,byte [WByte]
 	mov	byte [esi],al
%endmacro


;*
;* standard 4K cart
;*

RBank4: test_hw_read
	add	esi, CartRom - 1000h
	ret
        

WBank4:	test_hw_write
	ret


;*
;* Commavid RAM cart (vidlife)
;*

;;; converted macro:
%macro CVR_TestRam 0
; local ; NotRam

	cmp	esi,17ffh
	ja near %%NotRam
	add	esi, Ram - 1000h
	ret

%%NotRam:
%endmacro


;;; converted macro:
%macro CVW_TestRam 0
; local ; NotRam

	cmp	esi,17ffh
	ja near %%NotRam
	add	esi, Ram - 1000h - 400h
	WriteRam
	ret

%%NotRam:
%endmacro



RBankCV: test_hw_read
	CVR_TestRam
	add	esi, CartRom - 1000h
	ret
        

WBankCV:test_hw_write
	CVW_TestRam
	ret

;*
;* standard 8K cart (F8)
;*

;;; converted macro:
%macro SetBank_8 0
; local ; NoChange

	cmp	esi,1FF8h  ;  if not in switch area ...
	jb near %%NoChange  ;  ... there's no change
	cmp	esi,1FF9h
	ja near %%NoChange

	mov	eax,esi
	sub	eax,1FF8h  ;  bank #
	shl	eax,12  ;  bank address
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


RBank8:	test_hw_read
	SetBank_8
	MapRomBank
	ret


WBank8:	test_hw_write
	SetBank_8
	ret

;*
;* standard 8K cart with Super-Chip (F8+sc)
;*

;;; converted macro:
%macro SCR_TestRam 0
; local ; NotRam

	cmp	esi,10ffh
	ja near %%NotRam
	add	esi, Ram - 1000h - 80h
	ret

%%NotRam:
%endmacro


;;; converted macro:
%macro SCW_TestRam 0
; local ; NotRam

	cmp	esi,10ffh
	ja near %%NotRam
	add	esi, Ram - 1000h
	WriteRam
	ret

%%NotRam:
%endmacro



RBank8sc:
	test_hw_read
	SetBank_8
	SCR_TestRam
	MapRomBank
	ret

WBank8sc:
	test_hw_write
	SetBank_8
	SCW_TestRam
	ret

;*
;* 12K Ram Plus cart (FA)
;*

;;; converted macro:
%macro SetBank_12 0
; local ; NoChange

	cmp	esi,1FF8h  ;  if not in switch area ...
	jb near %%NoChange  ;  ... there's no change
	cmp	esi,1FFAh
	ja near %%NoChange

	mov	eax,esi
	sub	eax,1FF8h  ;  bank #
	shl	eax,12  ;  bank address
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


;;; converted macro:
%macro FAR_TestRam 0
; local ; NotRam

	cmp	esi,11ffh
	ja near %%NotRam
	add	esi, Ram - 1000h - 100h
	ret

%%NotRam:
%endmacro


;;; converted macro:
%macro FAW_TestRam 0
; local ; NotRam

	cmp	esi,10ffh
	ja near %%NotRam
	add	esi, Ram - 1000h
	WriteRam

%%NotRam:
%endmacro


RBank12:
	test_hw_read
	SetBank_12
	FAR_TestRam
	MapRomBank
	ret


WBank12:
	test_hw_write
	SetBank_12
	FAW_TestRam
	ret

;*
;* standard 16K cart (F16)
;*

;;; converted macro:
%macro SetBank_16 0
; local ; NoChange

	cmp	esi,1FF6h  ;  if not in switch area...
	jb near %%NoChange  ;  ... there's no change
	cmp	esi,1FF9h
	ja near %%NoChange

	mov	eax,esi
	sub	eax,1FF6h  ;  bank #
	shl	eax,12  ;  bank address
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


RBank16:
	test_hw_read
	SetBank_16
	MapRomBank
	ret


WBank16:
	test_hw_write
	SetBank_16
	ret


;*
;* standard 16K cart with Super-Chip (F16+sc)
;*

RBank16sc:
	test_hw_read
	SetBank_16
	SCR_TestRam
	MapRomBank
	ret



WBank16sc:
	test_hw_write
	SetBank_16
	SCW_TestRam
	ret

;*
;* CompuMate computer module
;*

;;; converted macro:
%macro ChangeState_CM 0
; local ; NoChange
; local ; NoResetKeyCount
; local ; NoIncreaseKeyCount

	cmp	esi,0280h
	jne near %%NoChange
 	test	byte [WByte],20h
	jz near %%NoResetKeyCount
 	mov	byte [CM_Collumn],0
%%NoResetKeyCount:
 	test	byte [WByte],40h
	jz near %%NoIncreaseKeyCount
 	inc	byte [CM_Collumn]
 	cmp	byte [CM_Collumn],10
	jne near %%NoIncreaseKeyCount
 	mov	byte [CM_Collumn],0
%%NoIncreaseKeyCount:
 	mov	al,byte [WByte]
 	mov	dword [CMRamState],eax
	and	eax,03h
	shl	eax,12
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro



;;; converted macro:
%macro TestRam_CM 0
; local ; NoRAM
; local ; NoWrite

	cmp	esi,1800h
	jb near %%NoRAM
 	test	dword [CMRamState],10h ; RAM enabled?
	jnz near %%NoRAM
	add	esi, Ram - 1000h - 800h
 	test	dword [CMRamState],20h ; write enabled?
	jz near %%NoWrite
	WriteRam
%%NoWrite:
	ret
%%NoRAM:
%endmacro



RBankCM:
	test_hw_read
	TestRam_CM
	MapRomBank
	ret


WBankCM:
	ChangeState_CM
	test_hw_write
	TestRam_CM
	ret

;*
;* standard 32K cart (F4)
;*

;;; converted macro:
%macro SetBank_32 0
; local ; NoChange

	cmp	esi,1FF4h  ;  if not in switch area ...
	jb near %%NoChange  ;  ... there's no change
	cmp	esi,1FFbh
	ja near %%NoChange

	mov	eax,esi
	sub	eax,1FF4h  ;  bank #
	shl	eax,12  ;  bank address
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


RBank32:
	test_hw_read
	SetBank_32
	MapRomBank
	ret

WBank32:
	test_hw_write
	SetBank_32
	ret

;*
;* standard 32K cart with Super-Chip (F4+sc)
;*

RBank32sc:
	test_hw_read
	SetBank_32
	SCR_TestRam
	MapRomBank
	ret

WBank32sc:
	test_hw_write
	SetBank_32
	SCW_TestRam
	ret

;*
;* Parker Brother's 8K cart
;*


;;; converted macro:
%macro PB_SetSlice 0
; local ; NoChange

	cmp	esi,1Fe0h  ;  if not in switch area ...
	jb near %%NoChange  ;  ... there's no change
        cmp     esi,1FF7h
	ja near %%NoChange

	push	ebx
	mov	eax,esi
	and	eax,7
	shl	eax,10  ;  new bank
	mov	ebx,esi
	and	ebx,18h
	shr	ebx,1  ;  slice to set *4
 	mov	dword [PBSlice0 + ebx],eax	
	pop	ebx

%%NoChange:
%endmacro


;;; converted macro:
%macro PB_MapSlice 0
	mov	eax,esi
	and	eax,0c00h
	shr	eax,8  ;  slice # we're in *4
	and	esi,03ffh  ;  mask low order bits
 	add	esi,dword [PBSlice0 + eax] ; point to proper ROM slice
	add	esi, CartRom

%endmacro



RBank8pb:
	test_hw_read
	PB_SetSlice
	PB_MapSlice
	ret


WBank8pb:
	test_hw_write
	PB_SetSlice
	ret

;*
;* Tigervision 8K cart
;* extended to 512K, but $1800-$1FFF still is the fixed bank
;*

;;; converted macro:
%macro TV_SetSlice 0
; local ; NoChange

	cmp	esi,03fh
	ja near %%NoChange

 	mov	al,byte [WByte]
  ;  and     eax,3
        and     eax,0ffh
	shl	eax,11  ;  new bank
 	mov	dword [TVSlice0],eax

%%NoChange:
%endmacro


;;; converted macro:
%macro TV_MapSlice 0
	mov	eax,esi
	and	eax,0800h
	shr	eax,9  ;  slice # we're in *4
	and	esi,07ffh  ;  mask low order bits
 	add	esi,dword [TVSlice0 + eax] ; point to proper ROM slice
	add	esi, CartRom
%endmacro



RBank8tv:
	test_hw_read
	TV_MapSlice
	ret

WBank8tv:
	TV_SetSlice
	test_hw_write
	ret


;*
;* Tigervision 32K cart
;* extended to 512K - last 2K in ROM get used as fixed bank
;*

;;; converted macro:
%macro TV_SetSlice32 0
; local ; NoChange

	cmp	esi,03fh
	ja near %%NoChange

 	mov	al,byte [WByte]
	and	eax,0ffh  ;  0fh
	shl	eax,11  ;  new bank
 	mov	dword [TVSlice032],eax

%%NoChange:
%endmacro


;;; converted macro:
%macro TV_MapSlice32 0
	mov	eax,esi
	and	eax,0800h
	shr	eax,9  ;  slice # we're in *4
	and	esi,07ffh  ;  mask low order bits
 	add	esi,dword [TVSlice032 + eax] ; point to proper ROM slice
	add	esi, CartRom
%endmacro



RBank32tv:
	test_hw_read
	TV_MapSlice32
	ret

WBank32tv:
	TV_SetSlice32
	test_hw_write
	ret


;*
;* FE 8K bankswitch scheme -- flat model
;*

;;; converted macro:
%macro FE_SetBank 0
; local ; Trace

         cmp byte byte [debugflag],1 ; no BS if trace code reads the memory
        je near %%Trace
        cmp     esi,1000h
        jb near %%Trace
        mov     eax,2000h
        and     eax,esi  ;  isolate bank bit from address
        xor     eax,2000h  ;  invert it
        shr     eax,1  ;  position it
         mov     dword [RomBank],eax ; this is our bank
%%Trace:
%endmacro



RBank8FE:
	FE_SetBank
	test_hw_read
	MapRomBank
	ret


WBank8FE:
	FE_SetBank
	test_hw_write
	ret


;*
;* M-Network 16K cart
;*

; small chunks mapped at 0 to 3FF
;
; 0 --	00 -  FF
; 1 -- 100 - 1FF
; 2 -- 200 - 2FF
; 3 -- 300 - 3FF

; large chunk mapped at 400 to 7FF


;;; converted macro:
%macro MNR_TestRam 0
; local ; Done, ReadBig

	cmp	esi,19ffh
	ja near %%Done
	cmp	esi,1400h
	jb near %%Done
	cmp	esi,17ffh
	jbe near %%ReadBig
	cmp	esi,1900h
	jb near %%Done
 	add	esi,dword [MNRamSlice] ; read small, pick up current slice
	add	esi, Ram - 1900h
	ret

%%ReadBig:
 	cmp	dword [MNSlice0],0ffffh ; RAM mapped in ?
	jne near %%Done  ;  no
	add	esi, Ram - 1400h + 400h
	ret

%%Done:
%endmacro


;;; converted macro:
%macro MNW_TestRam 0
; local ; Done, WriteBig

	cmp	esi,18ffh
	ja near %%Done
	cmp	esi,1000h
	jb near %%Done
	cmp	esi,13ffh
	jbe near %%WriteBig
	cmp	esi,1800h
	jb near %%Done
 	add	esi,dword [MNRamSlice] ; write small, pick up current slice
	add	esi, Ram - 1800h
	WriteRam
	ret

%%WriteBig:
 	cmp	dword [MNSlice0],0ffffh ; RAM mapped in ?
	jne near %%Done  ;  no
	add	esi, Ram - 1000h + 400h
	WriteRam
	ret
	
%%Done:
%endmacro


;;; converted macro:
%macro MN_SetRamSlice 0
; local ; Done, NotMapLower

	cmp	esi,1FE7h
	jne near %%NotMapLower
 	mov	dword [MNSlice0],0ffffh ; map RAM into lower slice
	jmp	%%Done

%%NotMapLower:
	cmp	esi,1fe8h
	jb near %%Done
	cmp	esi,1feBh
	ja near %%Done
	mov	eax,esi
	sub	eax,1fe8h
	shl	eax,8
 	mov	dword [MNRamSlice],eax

%%Done:
%endmacro


;;; converted macro:
%macro MN_SetSlice 0
; local ; NoChange

	cmp	esi,1FE0h  ;  if not in switch area...
	jb near %%NoChange  ;  ... there's no change
	cmp	esi,1FE6h
	ja near %%NoChange

	mov	eax,esi
	sub	eax,1FE0h  ;  bank #
	shl	eax,11  ;  bank address
 	mov	dword [MNSlice0],eax

%%NoChange:
%endmacro


;;; converted macro:
%macro MN_MapSlice 0

	mov	eax,esi
	and	eax,0800h
	shr	eax,9  ;  slice # we're in
	and	esi,07ffh  ;  mask low order bits
 	add	esi,dword [MNSlice0 + eax] ; point to proper ROM slice
	add	esi, CartRom

%endmacro



RBank16mn:
	test_hw_read
	MN_SetSlice
	MN_SetRamSlice
	MNR_TestRam
	MN_MapSlice
	ret

WBank16mn:
	test_hw_write
	MN_SetSlice
	MN_SetRamSlice
	MNW_TestRam
	ret
;*
;* Megaboy (F0) *EST*
;*

;;; converted macro:
%macro SetBank_MB 0
; local ; NoChange

	cmp	esi,1FF0h  ;  if not in switch area ...
	jne near %%NoChange  ;  ... there's no change

 	mov	eax,dword [RomBank]
	add	eax,01000h
        and     eax,0f000h
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


RBankMB:
	test_hw_read
	SetBank_MB
	MapRomBank
	ret


WBankMB:
	test_hw_write
	SetBank_MB
	ret

;*
;* UA Ltd. 8K cart (24)
;*

;;; converted macro:
%macro SetBank_8ua 0
; local ; DoChange
; local ; NoChange

        cmp     esi,220h  ;  bank 0 hotspot?
        je near %%DoChange                
        cmp     esi,240h  ;  bank 1 hotspot?
        jne near %%NoChange

%%DoChange:
        push    eax
        mov     eax,esi
        and     eax,40h  ;  high or low bank
        shl     eax,6  ;  bank address
         mov     dword [RomBank],eax
        pop     eax

%%NoChange:
%endmacro


RBank8ua:
        SetBank_8ua
        test_hw_read
	MapRomBank
	ret


WBank8ua:
        SetBank_8ua
        test_hw_write
        ret

;*
;* Homestar Runner / Paul Slocum (EF) 64K
;*

;;; converted macro:
%macro SetBank_EF 0
; local ; NoChange

        cmp     esi,1FE0h  ;  if not in switch area...
	jb near %%NoChange  ;  ... there's no change
        cmp     esi,1FEFh
	ja near %%NoChange

	mov	eax,esi
        sub     eax,1FE0h  ;  bank #
	shl	eax,12  ;  bank address
 	mov	dword [RomBank],eax

%%NoChange:
%endmacro


RBankEF:
	test_hw_read
        SetBank_EF
	MapRomBank
	ret


WBankEF:
	test_hw_write
        SetBank_EF
	ret

;;; end merge of banks.asm

;;; merged: 	include pitfall2.asm		; (32) Pitfall II bank switch code
;*
;* Pitfall 2 8K bankswitch scheme -- similar to standard F8
;*
;* 5-12-99 -- break ground
;* 7-17-02 -- 32-bit
;*
;* Based in part on David Crane's U.S. Patent 4,644,495, Feb 17,1987.
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

[section .data]

; global Pitfall2 flag 
P2_Start:  ; byte			; <-- start clearing here

Pitfall2	db	0		 ;  tell RIOT timer to clock the music

P2_Flags	db	0,0,0,0,0,0,0,0
P2_Counters	dd	0,0,0,0,0,0,0,0
P2_Top		db	0,0,0,0,0,0,0,0
P2_Bottom	db	0,0,0,0,0,0,0,0
P2_Enable	db	0,0,0,0,0,0,0,0
P2_Music_Top	dd	0,0,0,0,0,0,0,0
P2_Music_Bottom	dd	0,0,0,0,0,0,0,0
P2_Music_Count	dd	0,0,0,0,0,0,0,0

P2_Rbyte	db	0		 ;  return value for CPU read commands
P2_Null		db	0		 ;  return value for null read commands
P2_AUDV		db	0		 ;  create an AUDV byte here

P2_sreg		dd	0		 ;  initialize shift register to non-zero val
P2_End:  ; byte			; <-- finish clearing here

[section .data]




ALIGN 2
P2_Vectors:  ; dword

;*
;* read commands
;*

	dd	P2_Read_Random		 ;  00 -- Random # generator
	dd	P2_Read_Random		 ;  01 -- Random # generator
	dd	P2_Read_Random		 ;  02 -- Random # generator
	dd	P2_Read_Random		 ;  03 -- Random # generator
	dd	P2_Read_Sound		 ;  04 -- Sound value
	dd	P2_Read_Sound		 ;  05 -- Sound value
	dd	P2_Read_Sound		 ;  06 -- Sound value
	dd	P2_Read_Sound		 ;  07 -- Sound value
	dd	P2_Read_DF		 ;  08 -- DF0
	dd	P2_Read_DF		 ;  09 -- DF1
	dd	P2_Read_DF		 ;  0a -- DF2
	dd	P2_Read_DF		 ;  0b -- DF3
	dd	P2_Read_DF		 ;  0c -- DF4
	dd	P2_Read_DF		 ;  0d -- DF5
	dd	P2_Read_DF		 ;  0e -- DF6
	dd	P2_Read_DF		 ;  0f -- DF7
	dd	P2_Read_DF_Flag		 ;  10 -- DF0 AND flag
	dd	P2_Read_DF_Flag		 ;  11 -- DF1 AND flag
	dd	P2_Read_DF_Flag		 ;  12 -- DF2 AND flag
	dd	P2_Read_DF_Flag		 ;  13 -- DF3 AND flag
	dd	P2_Read_DF_Flag		 ;  14 -- DF4 AND flag
	dd	P2_Read_DF_Flag		 ;  15 -- DF5 AND flag
	dd	P2_Read_DF_Flag		 ;  16 -- DF6 AND flag
	dd	P2_Read_DF_Flag		 ;  17 -- DF7 AND flag
	dd	P2_NoIO			 ;  18 -- DF0 AND flag swapped
	dd	P2_NoIO			 ;  19 -- DF1 AND flag swapped
	dd	P2_NoIO			 ;  1a -- DF2 AND flag swapped
	dd	P2_NoIO			 ;  1b -- DF3 AND flag swapped
	dd	P2_NoIO			 ;  1c -- DF4 AND flag swapped
	dd	P2_NoIO			 ;  1d -- DF5 AND flag swapped
	dd	P2_NoIO			 ;  1e -- DF6 AND flag swapped
	dd	P2_NoIO			 ;  1f -- DF7 AND flag swapped
	dd	P2_NoIO			 ;  20 -- DF0 AND flag reversed
	dd	P2_NoIO			 ;  21 -- DF1 AND flag reversed
	dd	P2_NoIO			 ;  22 -- DF2 AND flag reversed
	dd	P2_NoIO			 ;  23 -- DF3 AND flag reversed
	dd	P2_NoIO			 ;  24 -- DF4 AND flag reversed
	dd	P2_NoIO			 ;  25 -- DF5 AND flag reversed
	dd	P2_NoIO			 ;  26 -- DF6 AND flag reversed
	dd	P2_NoIO			 ;  27 -- DF7 AND flag reversed
	dd	P2_NoIO			 ;  28 -- DF0 AND flag SHR 1
	dd	P2_NoIO			 ;  29 -- DF1 AND flag SHR 1
	dd	P2_NoIO			 ;  2a -- DF2 AND flag SHR 1
	dd	P2_NoIO			 ;  2b -- DF3 AND flag SHR 1
	dd	P2_NoIO			 ;  2c -- DF4 AND flag SHR 1
	dd	P2_NoIO			 ;  2d -- DF5 AND flag SHR 1
	dd	P2_NoIO			 ;  2e -- DF6 AND flag SHR 1
	dd	P2_NoIO			 ;  2f -- DF7 AND flag SHR 1
	dd	P2_NoIO			 ;  30 -- DF0 AND flag SHL 1
	dd	P2_NoIO			 ;  31 -- DF1 AND flag SHL 1
	dd	P2_NoIO			 ;  32 -- DF2 AND flag SHL 1
	dd	P2_NoIO			 ;  33 -- DF3 AND flag SHL 1
	dd	P2_NoIO			 ;  34 -- DF4 AND flag SHL 1
	dd	P2_NoIO			 ;  35 -- DF5 AND flag SHL 1
	dd	P2_NoIO			 ;  36 -- DF6 AND flag SHL 1
	dd	P2_NoIO			 ;  37 -- DF7 AND flag SHL 1
	dd	P2_ReadFlags		 ;  38 -- DF0 flag
	dd	P2_ReadFlags		 ;  39 -- DF1 flag
	dd	P2_ReadFlags		 ;  3a -- DF2 flag
	dd	P2_ReadFlags		 ;  3b -- DF3 flag
	dd	P2_ReadFlags		 ;  3c -- DF4 flag
	dd	P2_ReadFlags		 ;  3d -- DF5 flag
	dd	P2_ReadFlags		 ;  3e -- DF6 flag
	dd	P2_ReadFlags		 ;  3f -- DF7 flag

;*
;* write commands
;*

	dd	P2_WriteTop		 ;  40 -- DF0 top count
	dd	P2_WriteTop		 ;  41 -- DF1 top count
	dd	P2_WriteTop		 ;  42 -- DF2 top count
	dd	P2_WriteTop		 ;  43 -- DF3 top count
	dd	P2_WriteTop		 ;  44 -- DF4 top count
	dd	P2_WriteTop		 ;  45 -- DF5 top count
	dd	P2_WriteTop		 ;  46 -- DF6 top count
	dd	P2_WriteTop		 ;  47 -- DF7 top count
	dd	P2_WriteBottom		 ;  48 -- DF0 bottom count
	dd	P2_WriteBottom		 ;  49 -- DF1 bottom count
	dd	P2_WriteBottom		 ;  4a -- DF2 bottom count
	dd	P2_WriteBottom		 ;  4b -- DF3 bottom count
	dd	P2_WriteBottom		 ;  4c -- DF4 bottom count
	dd	P2_WriteBottom		 ;  4d -- DF5 bottom count
	dd	P2_WriteBottom		 ;  4e -- DF6 bottom count
	dd	P2_WriteBottom		 ;  4f -- DF7 bottom count
	dd	P2_WriteCounterLow	 ;  50 -- DF0 counter low
	dd	P2_WriteCounterLow	 ;  51 -- DF1 counter low
	dd	P2_WriteCounterLow	 ;  52 -- DF2 counter low
	dd	P2_WriteCounterLow	 ;  53 -- DF3 counter low
	dd	P2_WriteCounterLow	 ;  54 -- DF4 counter low
	dd	P2_WriteCounterLow	 ;  55 -- DF5 counter low
	dd	P2_WriteCounterLow	 ;  56 -- DF6 counter low
	dd	P2_WriteCounterLow	 ;  57 -- DF7 counter low
	dd	P2_WriteCounterHigh	 ;  58 -- DF0 counter high
	dd	P2_WriteCounterHigh	 ;  59 -- DF1 counter high
	dd	P2_WriteCounterHigh	 ;  5a -- DF2 counter high
	dd	P2_WriteCounterHigh	 ;  5b -- DF3 counter high
	dd	P2_WriteCounterHigh	 ;  5c -- DF4 counter high
	dd	P2_WriteCounterHigh	 ;  5d -- DF5 counter high AND music enable
	dd	P2_WriteCounterHigh	 ;  5e -- DF6 counter high AND music enable
	dd	P2_WriteCounterHigh	 ;  5f -- DF7 counter high AND music enable
	dd	P2_NoIO			 ;  60 -- not used (draw line movement)
	dd	P2_NoIO			 ;  61 -- not used (draw line movement)
	dd	P2_NoIO			 ;  62 -- not used (draw line movement)
	dd	P2_NoIO			 ;  63 -- not used (draw line movement)
	dd	P2_NoIO			 ;  64 -- not used (draw line movement)
	dd	P2_NoIO			 ;  65 -- not used (draw line movement)
	dd	P2_NoIO			 ;  66 -- not used (draw line movement)
	dd	P2_NoIO			 ;  67 -- not used (draw line movement)
	dd	P2_NoIO			 ;  68 -- not used
	dd	P2_NoIO			 ;  69 -- not used
	dd	P2_NoIO			 ;  6a -- not used
	dd	P2_NoIO			 ;  6b -- not used
	dd	P2_NoIO			 ;  6c -- not used
	dd	P2_NoIO			 ;  6d -- not used
	dd	P2_NoIO			 ;  6e -- not used
	dd	P2_NoIO			 ;  6f -- not used
	dd	P2_ResetRandom		 ;  70 -- random number generator reset
	dd	P2_ResetRandom		 ;  71 -- random number generator reset
	dd	P2_ResetRandom		 ;  72 -- random number generator reset
	dd	P2_ResetRandom		 ;  73 -- random number generator reset
	dd	P2_ResetRandom		 ;  74 -- random number generator reset
	dd	P2_ResetRandom		 ;  75 -- random number generator reset
	dd	P2_ResetRandom		 ;  76 -- random number generator reset
	dd	P2_ResetRandom		 ;  77 -- random number generator reset
	dd	P2_NoIO			 ;  78 -- not used
	dd	P2_NoIO			 ;  79 -- not used
	dd	P2_NoIO			 ;  7a -- not used
	dd	P2_NoIO			 ;  7b -- not used
	dd	P2_NoIO			 ;  7c -- not used
	dd	P2_NoIO			 ;  7d -- not used
	dd	P2_NoIO			 ;  7e -- not used
	dd	P2_NoIO			 ;  7f -- not used

[section .code]

;*
;* Pitfall 2 initialization
;*

Init_P2:				 ;  <-- from init.asm

	clear_mem  P2_Start,  P2_End

 	mov	dword [P2_sreg],1 ; random # generator (must be non-zero)
	ret

SetPitfallII:				 ;  <-- from banks.asm
 	mov	dword [BSType],14
 	mov	dword [RomBank],01000h ; don't know if this is needed...
 	mov	byte [Pitfall2],1 ; tell RIOT to clock the music
	ret

;*
;* bankswitch entry points
;*

RBank8P2:
	test_hw_read
	cmp	esi,107fh
	jbe near R_P2
	SetBank_8  ;  F8 macro
	MapRomBank
	ret


WBank8P2:
	test_hw_write
	cmp	esi,107fh
	jbe near W_P2
	SetBank_8  ;  F8 macro
	ret

;*
;* read Pitfall 2 register
;*

R_P2:
	cmp	esi,1040h		 ;  read in range?
	jae near P2_NoIO			 ;    no
	and	esi,07fh
 	jmp	dword [P2_Vectors+esi*4]

;*
;* write Pitfall 2 register
;*

W_P2:
	cmp	esi,1040h		 ;  write in range?
	jb near P2_NoIO			 ; 	  no
	and	esi,07fh
 	jmp	dword [P2_Vectors+esi*4]

;*
;* Pitfall 2 register handlers
;*

;*
;* null register read/write
;*

P2_NoIO:
	mov	esi, P2_Null
	ret


;*
;* routine to tune the pitch of the music
;*
;* We use this to match the Pitfall II music clock to the TIA music clock.
;*
;* Due to the discrete nature of this stuff, since the two clocks are not 
;* integer multiples of one another, adjustments of the ratio can affect the
;* relative pitch of notes in a chord as well as the overall pitch.  So you 
;* need to make sure that the important chords sound *nice*.
;*

Tune_Music:
	push	eax
	push	ecx
	mov	al,dl
	xor	edx,edx
	mov	cl,129
	mul	cl
	mov	ecx,79
	div	ecx
	mov	edx,eax
	pop	ecx
	pop	eax

	ret

;*
;* write top register
;*

P2_WriteTop:
	and	esi,7
 	mov	dl,byte [WByte] ; pick up byte to write
 	mov	byte [P2_Top + esi],dl ; save in TOP
	cmp	esi,5
	jb near P2_WriteDone
	call	Tune_Music
 	mov	dword [P2_Music_Top + esi*4],edx

P2_WriteDone:
	ret

;*
;* write bottom register
;*

P2_WriteBottom:
	and	esi,7
 	mov	dl,byte [WByte] ; pick up byte to write
 	mov	byte [P2_Bottom + esi],dl ; save in BOTTOM
	cmp	esi,5
	jb near P2_WriteDone
	call	Tune_Music
 	mov	dword [P2_Music_Bottom + esi*4],edx
	ret

;*
;* write counter low
;*

P2_WriteCounterLow:
	and	esi,7
 	mov	edx,dword [P2_Counters + esi*4]
 	mov	dl,byte [WByte] ; pick up byte to write in LOW counter byte
	and	edx,07ffh			 ;  mask to 11 bits
 	mov	dword [P2_Counters + esi*4],edx
	cmp	esi,5
	jb near P2_WriteDone
	call	Tune_Music
 	mov	dword [P2_Music_Count + esi*4],edx
	ret

;*
;* write counter high AND music enable
;*

P2_WriteCounterHigh:
	and	esi,7
 	mov	edx,dword [P2_Counters + esi*4]
 	mov	dh,byte [WByte] ; pick up byte to write in HI counter byte
 	mov	byte [P2_Enable + esi],dh ; save whole thing in enable
	and	edx,07ffh			 ;  mask to 11 bits
 	mov	dword [P2_Counters + esi*4],edx
 	mov	byte [P2_Flags + esi],0 ; this also clears the FLAG
	ret

;*
;* reset the random number generator
;*

P2_ResetRandom:
 	mov	dword [P2_sreg],1
	ret

;*
;* read flags
;*

P2_ReadFlags:
	and	esi,7
	add	esi, P2_Flags
	ret

;*
;* macro to read data via data fetcher
;*

Read_DF:
	and	esi,7
	push	ebx
 	mov	edx,dword [P2_Counters + esi*4] ; use old counter value for flag test
 	dec	dword [P2_Counters + esi*4] ; decrement for current fetch
 	cmp	dl,byte [P2_Top + esi] ; equal to top value?
	je near P2_FlagOne			 ;    yes, set flag
 	cmp	dl,byte [P2_Bottom + esi] ; equal to bottom value?
	je near P2_FlagZero			 ;    yes, clear flag
	jmp	P2_Cont

P2_FlagOne:
 	mov	byte [P2_Flags + esi],0ffh ; set flag
	jmp	P2_Cont

P2_FlagZero:
 	mov	byte [P2_Flags + esi],0 ; clear flag

P2_Cont:
 	mov	ebx,dword [P2_Counters + esi*4] ; get current counter
	neg	ebx				 ;  fetch data

 	mov	dl,byte [CartRom + 027feh + ebx] ; yes it *is* magic

 	mov	byte [P2_Rbyte],dl ; save data
	pop	ebx
	ret



;*
;* read data via data fetcher
;*

P2_Read_DF:
	call	Read_DF
	mov	esi, P2_Rbyte		 ;  pointer for CPU
	ret

;*
;* read data via data fetcher ANDed with flag
;*

P2_Read_DF_Flag:
	call	Read_DF
 	mov	dl,byte [P2_Flags + esi] ; pick up flag
 	and	byte [P2_Rbyte],dl ; AND data
	mov	esi, P2_Rbyte		 ;  restore pointer for CPU
	ret

;*
;* Generate a sequence of pseudo-random numbers 255 numbers long
;* by emulating an 8-bit shift register with feedback taps at
;* positions 4, 5, 6, and 8.
;*

P2_Read_Random:
	push	eax

 	mov	eax,dword [P2_sreg]
	and	eax,1				 ;  isolate bit 8
 	mov	edx,dword [P2_sreg]
	and	edx,4
	shr	edx,2
	xor	eax,edx				 ;  xor with bit 6
 	mov	edx,dword [P2_sreg]
	and	edx,8
	shr	edx,3
	xor	eax,edx				 ;  xor with bit 5
 	mov	edx,dword [P2_sreg]
	and	edx,16
	shr	edx,4
	xor	eax,edx				 ;  xor with bit 4
	shl	eax,7				 ;  this is the new bit 1
 	shr	dword [P2_sreg],1 ; shift the register
 	or	dword [P2_sreg],eax ; or in the feedback

 	mov	edx,dword [P2_sreg]
 	mov	byte [P2_Rbyte],dl
	mov	esi, P2_Rbyte

	pop	eax
	ret	



;*
;* read sound stuff
;*

;*
;* read sound entry point
;*
;* This is just for show -- Pitfall 2 short-circuits AUDV.
;*

P2_Read_Sound:
	mov	esi, P2_AUDV
	ret


;*
;* clock a music channel
;*

;;; converted macro:
%macro Clock_Channel 1
; local ; MusicZero, ChannelDone

 	test	byte [P2_Enable + %1],010h ; channel enabled?
	jz near %%ChannelDone  ;  no
 	mov	edx,dword [P2_Music_Count + %1*4] ; use old counter value for flag test
 	dec	dword [P2_Music_Count + %1*4] ; decrement for current fetch
 	cmp	edx,dword [P2_Music_Bottom + %1*4] ; equal to bottom value?
	je near %%MusicZero  ;  yes, clear flag
	cmp	edx,-1  ;  time to reset?
	jnz near %%ChannelDone  ;  no
 	mov	edx,dword [P2_Music_Top + %1*4] ; yes, reset counter
 	mov	dword [P2_Music_Count + %1*4],edx
 	mov	byte [P2_Flags + %1],0ffh ; set flag
	jmp	%%ChannelDone

%%MusicZero:
 	mov	byte [P2_Flags + %1],0 ; clear flag

%%ChannelDone:
%endmacro



;*
;* clock music -- clock all channels
;*

Clock_Music:
	Clock_Channel  5
	Clock_Channel  6
	Clock_Channel  7

	ret


;*
;* build AUDV byte
;*

[section .data]

;*
;* sound mixing table
;* convert 3 sound channel bits into an AUDV value
;*

Mix_AUDV db 0, 6, 5, 0bh, 4, 0ah, 9, 0fh

[section .code]

;*
;* clock Pitfall 2 from TIA sound
;*


Clock_Pitfall2:
	push	ebx
	push	edx

	call	Clock_Music		 ;  clock P2

 	mov	bl,byte [P2_Flags + 5] ; Build AUDV
 	mov	dl,byte [P2_Flags + 6]
 	mov	dh,byte [P2_Flags + 7]
	and	ebx,1
	and	dl,2
	and	dh,4
	or	bl,dl
	or	bl,dh
 	mov	dl,byte [Mix_AUDV + ebx]
 	mov	byte [P2_AUDV],dl

ClockP2NoClock:
	pop	edx
	pop	ebx
	ret


;;; end merge of pitfall2.asm

;;; merged: 	include starpath.asm		; (32) Starpath Supercharger bank switch code
;*
;* Starpath Supercharger support for z26
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-04-02 -- 32-bit

[section .data]

; Starpath ROM Slices
SP_Scheme:  ; dword                   ; table of bankswitch schemes
        dd      2*800h,3*800h
        dd      0*800h,3*800h
        dd      2*800h,0*800h
        dd      0*800h,2*800h
        dd      2*800h,3*800h
        dd      1*800h,3*800h
        dd      2*800h,1*800h
        dd      1*800h,2*800h

SPSlice0        dd      0
SPSlice1        dd      3*800h

SP_PrevAdr      dd      0
SP_RamWord:  ; dword
SP_RamByte      db      0,0,0,0          ;  byte to write to RAM (pad to allow dword write)

Starpath        db      0                ;  global Starpath flag
SP_WriteEnable  db      0                ;  SC RAM write enabled

SP_PulseDelay   db      7                ;  # of cycles since last memory reference


[section .code]

;*
;* set bankswitch scheme from bx
;*

;;; converted macro:
%macro SP_SetScheme 0

        push    eax
        shr     ebx,2
         setc     [SP_WriteEnable]
        and     ebx,7
        shl     ebx,3
         mov     eax,dword [SP_Scheme+ebx]
         mov     dword [SPSlice0],eax
         mov     eax,dword [SP_Scheme+ebx+4]
         mov     dword [SPSlice1],eax
        pop     eax

%endmacro


;*
;* Starpath initialization
;*

; <-- from init.asm

Init_Starpath:
         mov     dword [SPSlice0],0
         mov     dword [SPSlice1],3*800h
         mov     byte [Starpath],0
         mov     byte [SP_WriteEnable],0
         mov     byte [SP_RamByte],0
         mov     byte [SP_PulseDelay],7
         mov     dword [SP_PrevAdr],0
        ret

; <-- from banks.asm

SetStarpath:
        push    ebx
         mov     dword [BSType],15
         mov     byte [Starpath],1
        mov     bl,0
        or      bl,040h
         mov     byte [RiotRam],bl ; Starpath loader does this I think

        SP_SetScheme

        pop     ebx
        ret

;*
;* Starpath exit routines
;*

StarpathLoadNotFound:
        popad
         mov     byte [MessageCode],1 ; Unable to find load
;       call    ShowMessage
        jmp     GoDOS

StarpathRealJAM:
        popad
         mov     eax,dword [reg_pc]
         mov     dword [cpu_pc],eax
         mov     byte [MessageCode],2 ; Starpath call @
;       call    ShowMessage
        jmp     GoDOS

;*
;* Starpath jam handler (game jumped to ROM)
;*

StarpathJAM:
        pushad
         mov     eax,dword [reg_pc]
        and     eax,01fffh
        cmp     eax,01ff0h
        jne near SPJ1
        push    esi
        mov     esi,000faH
        and     esi,0ffffh

         mov     byte [debugflag],1
        call    ReadHardware
         mov     byte [debugflag],0

         mov     al,byte [esi]
        pop     esi
         mov     byte [SC_ControlByte],al

        call    cli_LoadNextStarpath

         mov     eax,dword [SC_StartAddress]
        test    eax,eax
        je near StarpathLoadNotFound
         mov     dword [reg_pc],eax
         mov     bl,byte [SC_ControlByte] ; bank switch scheme at startup
        or      bl,040h
         mov     byte [RiotRam],bl ; Starpath loader does this I think

        SP_SetScheme

        popad
        ret

SPJ1:
        cmp     eax,01ff1h
        jne near StarpathRealJAM

        call    cli_ReloadStarpath

         mov     eax,dword [SC_StartAddress]
        test    eax,eax
        je near StarpathLoadNotFound
         mov     dword [reg_pc],eax
         mov     bl,byte [SC_ControlByte] ; bank switch scheme at startup
        or      bl,040h
         mov     byte [RiotRam],bl ; Starpath loader does this I think

        SP_SetScheme

        popad
        ret

;*
;* Starpath bankswitch macros
;*

;;; converted macro:
%macro SP_MapSlice 0 ; u v
        push    ebx  ;  1
        mov     ebx,esi  ;  1
        and     esi,07ffh  ;  1   mask low order bits
        and     ebx,0800h  ;  1
        add     esi, CartRom  ;  1
        shr     ebx,9  ;  1     slice # we're in *4
         add     esi,dword [SPSlice0 + ebx] ; 2     point to proper ROM slice
        pop     ebx  ;  1
  ;  5-6
%endmacro


;*
;* write byte to ram
;*

;;; converted macro:
%macro SP_WriteRam 0
; local ; done

         cmp     byte [SP_PulseDelay],5 ; pulse delay in range?
        jne near %%done  ;  no

        push    esi
        SP_MapSlice
         mov     bl,byte [SP_RamByte]

         mov     byte [SP_PulseDelay],7 ; cancel write in progress

         mov     byte [esi],bl ; write byte to memory
        pop     esi

         cmp     byte [TraceCount],0
        jz near %%done

        pushad
        call    ShowSCWrite
        popad

%%done:
%endmacro


;*
;* process current address
;*

;;; converted macro:
%macro SP_Q_Adr 0
; local ; done, notbank, notrambyte, pulsedone, prevdone

        push    ebx

        and     esi,01fffh
         cmp     byte [SP_PulseDelay],5 ; write pending?
        ja near pulse%%done  ;  no
         cmp     esi,dword [SP_PrevAdr] ; a new memory address?
        je near prev%%done  ;  no, don't count it
         inc     byte [SP_PulseDelay] ; yes, count it
         mov     dword [SP_PrevAdr],esi ; remember address for next time...
prev%%done:
        test    esi,01000h  ;  adr in ROM?
        jz near %%done  ;  no

%%notrambyte:
        cmp     esi,01ff8h  ;  bankswitch request ?
        jne near %%notbank  ;  no

         mov     bl,byte [SP_RamByte] ; yes
        SP_SetScheme  ;  setup bankswitch scheme
         mov     byte [SP_PulseDelay],7 ; cancel any pending writes
        jmp     %%done

pulse%%done:
  ;  cmp     esi,01ff8h              ; bankswitch request ?
  ;  jne near notbank                 ;   no

  ;  mov     bl,[SP_RamByte]         ;   yes
  ;  SP_SetScheme                    ; setup bankswitch scheme
  ;  mov     [SP_PulseDelay],7       ; cancel any pending writes
  ;  jmp     done

  ;  notbank:
        test    esi,01000h  ;  adr in ROM?
        jz near %%done  ;  no

  ;  cmp     [SP_PulseDelay],5       ; write pending?
  ;  jbe near notrambyte              ;   yes, don't reset pulse delay
        cmp     esi,010ffh  ;  triggering a RAM write?
        ja near %%notrambyte  ;  no

         mov     dword [SP_RamWord],esi ; yes, adr is the byte to write
         mov     byte [SP_PulseDelay],0 ; start up the pulse delay counter
         mov     dword [SP_PrevAdr],esi ; set up prev address
        jmp     %%done

%%notbank:
         cmp     byte [SP_WriteEnable],0 ; write enabled?
        jz near %%done  ;  no

        SP_WriteRam  ;  yes, write byte to memory

%%done:
        pop     ebx

%endmacro


;*
;* actual bankswitch code
;*

RBank_SP:
         cmp     byte [debugflag],0 ; ignore memory cycles from disassembler
        jnz near debugread
        SP_Q_Adr
debugread:
        test_hw_read
        SP_MapSlice
        ret

WBank_SP:
        SP_Q_Adr
        test_hw_write
        ret


;;; end merge of starpath.asm


;;; merged: 	include riot.asm		; (32) RIOT emu
;*
;* z26 RIOT emu
;*
;* 07-19-02 -- 32-bit
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

;*
;* I'm not really sure what mode the timer starts up in but it's not mode 1.
;* Otherwise blueprnt.bin doesn't come up and others as well.
;*

START_TIME equ 07fffh 			 ;  03ffffh

[section .data]

Timer		dd	START_TIME	 ;  the RIOT Timer
					 ;  (gets initialized in INIT.ASM now)
TimerReadVec	dd	ReadTimer1024	 ;  timer read vector
TimerByte	db	0		 ;  a return value
TimerIntReg	db	0		 ;  Timer Interrupt Register

; *EST* variables
DDR_A		db	0
DDR_B		db	0
IOPortA_read	db	0		 ;  generate IOportA value on SWCHA read
					 ;    when it needs some adjusting for some
					 ;    controllers

ALIGN 2
ReadRIOTTab:  ; dword
	dd	ReadPortA		 ;  280h PA Data
	dd	ReadDDR_A		 ;  281h PA Direction
	dd	ReadPortB		 ;  282h PB Data
	dd	ReadDDR_B		 ;  283h PB Direction
	dd	ReadTimer		 ;  284h Read Timer
	dd	ReadTimerIntReg		 ;  285h Read Timer Interrupt Register
	dd	ReadTimer		 ;  286h Read Timer
	dd	ReadTimerIntReg		 ;  287h Read Timer Interrupt Register
WriteRIOTTab:  ; dword
	dd	SetRIOTTimer1		 ;  294h
	dd	SetRIOTTimer8		 ;  295h
	dd	SetRIOTTimer64		 ;  296h
	dd	SetRIOTTimer1024	 ;  297h

; *EST* table
WriteRIOTTab2:  ; dword
	dd	WritePortA		 ;  280h
	dd	WriteDDR_A		 ;  281h
	dd	WriteNothing		 ;  282h
	dd	WriteDDR_B		 ;  283h

[section .code]


Init_Riot:
 	mov	dword [Timer],START_TIME
 	mov	dword [TimerReadVec], ReadTimer1024
 	mov	byte [TimerByte],0
 	mov	byte [TimerIntReg],0

	ret

;*
;* CPU wants to read a RIOT register
;*

ReadRIOT:
	and	esi,07h
 	jmp	dword [ReadRIOTTab + esi*4]

ReadDDR_A:				 ;  read data direction register A
	mov	esi, DDR_A
	ret

ReadDDR_B:				 ;  read data direction register B
	mov	esi, DDR_B
	ret

ReadPortB:				 ;  read console switches (port b)
	mov	esi, IOPortB
	ret

ReadPortA:				 ;  read hand controllers (port a)
	pushad
 	mov	eax,dword [ScanLine]
	push	eax
	call	UpdateTrakBall
	pop	eax
	popad
	push	eax
 	mov	al,byte [IOPortA_Controllers] ; pins grounded by controller ...
 	or	al,byte [IOPortA_UnusedBits] ; read 0 even on pins where HIGH ...
 	and	al,byte [IOPortA] ; was written to (see Star Raiders)
 	mov	byte [IOPortA_read],al
	pop	eax
	mov	esi, IOPortA_read
	ret

;*
;* CPU wants to write to a RIOT register
;* On entry, si contains the address and [WByte] contains the value
;*

WriteRIOT:
	test	esi,010h
	jnz near WR_EST2
	test	esi,04h
	jnz near WriteNothing

	and	esi,03h
 	jmp	dword [WriteRIOTTab2 + esi*4]
WR_EST2:
	test	esi,04h
	jz near WriteNothing

	and	esi,03h
 	jmp	dword [WriteRIOTTab + esi*4]
	

WriteNothing:
	ret


WritePortA:
	push	eax
 	mov	al,byte [WByte]
 	and	al,byte [DDR_A] ; make sure that only output bits
 	mov	ah,byte [DDR_A] ; get written to SWCHA *EST*
	xor	ah,0FFh			
 	and	ah,byte [IOPortA]		
	or	al,ah			

 	mov	byte [IOPortA],al

	pop	eax
	pushad
	call	ControlSWCHAWrite	 ;  update controllers on SWCHA write
					 ;  Keypad, Compumate, Mindlink
	popad
	ret
	

WriteDDR_A:
	push	eax
 	mov	al,byte [WByte]
 	mov	byte [DDR_A],al
	pop	eax
	ret

WriteDDR_B:
	push	eax
 	mov	al,byte [WByte]
 	mov	byte [DDR_B],al
	pop	eax
	ret

;*
;* CPU wants to set the timer by writing to one of the RIOT timer regs:
;*
;* 	$294 (TIM1T)
;* 	$295 (TIM8T)
;* 	$296 (TIM64T)
;* 	$297 (TIM1024T)
;*
;* On entry, si contains the address and [WByte] contains the value
;*

;;; converted macro:
%macro set_timer 2

SetRIOTTimer%2:
 	mov	byte [RCycles],0 ; don't clock this instruction
 	movzx	edx,byte [WByte]

	shl	edx,%1
 	mov	dword [Timer],edx
 	mov	dword [TimerReadVec], ReadTimer%2
	ret

%endmacro


	set_timer  0,1
	set_timer  3,8
	set_timer  6,64
	set_timer  10,1024


;*
;* CPU wants to read the RIOT timer
;*
;* return with si pointing to value to read from $284 (INTIM)
;*

;;; converted macro:
%macro read_timer 2

ReadTimer%2:
	shr	edx,%1
 	mov	byte [TimerByte],dl
	mov	esi, TimerByte

	ret

%endmacro


	read_timer  0,1
	read_timer  3,8
	read_timer  6,64
	read_timer  10,1024

ReadTimer:
 	movzx	edx,byte [RCycles] ; clock this instruction
 	sub	dword [Timer],edx
 	mov	byte [RCycles],0 ; prevent double clock

 	mov	edx,dword [Timer]
	test	edx,040000h		 ;  has the timer overflowed yet ?
	jnz near ReadOverflowed		 ; 	 yes
 	mov	esi,dword [TimerReadVec] ; no, do appropriate read
	jmp	esi			 ;  jmp [TimerReadVec] doesn't work in 16-bit segment 

ReadOverflowed:
 	mov	byte [TimerByte],dl ; return this value
	mov	esi, TimerByte
	ret

;*
;* CPU wants to read the RIOT Timer Interrupt Register
;*
;* return with si pointing to value to read from $285
;*

ReadTimerIntReg:
 	mov	edx,dword [Timer]
	shr	edx,24
	and	dl,080h			 ;  position the very top bit
 	mov	byte [TimerIntReg],dl ; return this value

;*
;* I don't exactly know how many bits to leave in the Timer counter
;* because I don't exactly know how long it is to the next interrupt.
;* But another interrupt *does* come.  (Otherwise lockchse.bin fails.)
;*

 	and	dword [Timer],START_TIME ; clear interrupt flag
	mov	esi, TimerIntReg
	ret

;*
;* macro to clock the RIOT timer (after every instruction)
;*

;;; converted macro:
%macro ClockRIOT 0
; local ; NoPF2

 	movzx	edx,byte [RCycles] ; # of cycles for this instruction
 	sub	dword [Timer],edx ; subtract from timer

%endmacro


;*
;* randomize RIOT timer
;*

RandomizeRIOTTimer:
;	mov	eax,314159265			; *** this could be better ***
;	and	eax,0ff00h
;	shl	eax,2
 	mov	eax,dword [Seconds] ; gets set in GLOBALS.C
	and	eax,0ffh
	shl	eax,10
 	mov	dword [Timer],eax ; see RIOT.ASM for details
	ret



;;; end merge of riot.asm

;;; merged: 	include cpu.asm			; (32) 6502 opcodes, macros and support routines
;*
;* 6507 CPU emulator for z26
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 06-27-98 -- new design
; 07-17-98 -- simplify
; 06-26-99 -- cycle perfect
; 08-04-02 -- 32-bit

; CPU doesn't use ecx, ebp, edi -- trashes eax, ebx, edx, esi

[section .data]
ALIGN 2
wreg_pc:  ; word			; a word sized alias to pc (for inc [wreg_pc])
reg_pc		dd	0		 ;  program counter
dwreg_sp:  ; dword			; a dword sized alias to the stack pointer
reg_sp		db	0,1,0,0		 ;  stack pointer

; the following locations must be in this order and next to each other

reg_a		db	0		 ;  accumulator (stored in AL)
flag_carry	db	0		 ;  carry bit   (stored in AH)
		db	0		 ;  pad to dword
		db	0

; the following two locations are padded with an extra byte 
; to allow 16-bit access (see _index)

reg_x		db	0		 ;  x register
		db	0		 ;  pad to dword
		db	0
		db	0
reg_y		db	0		 ;  y register
		db	0		 ;  pad to dword
		db	0
		db	0

; a value is stored in the following vars for later testing

RZTest		db	0		 ;  zero test value (Z set when 0)
RNTest		db	0		 ;  sign test value (N set when negative)

; these vars hold the values of flags other than Z and N

flag_D		db	0		 ;  decimal flag
flag_V		db	0		 ;  overflow flag
flag_I		db	0		 ;  interrupt disable flag
flag_B		db	0		 ;  break flag

; clock variables

RCycles		db	0		 ;  cycles per instruction
RClock		db	0		 ;  clock cycles

; some temporaries for use by decimal arith and ARR

_value		db	0
_reg_a		db	0
_flag_carry	db	0

; state of the data bus -- used in cpuhand.asm

BusState        db      0

[section .code]

Init_CPU:
 	mov	dword [reg_pc],0
 	mov	byte [reg_a],0
 	mov	byte [flag_carry],0
 	mov	word byte [reg_x],0
 	mov	word byte [reg_y],0
 	mov	byte [reg_sp],0
 	mov	byte [RZTest],0
 	mov	byte [RNTest],0
 	mov	byte [flag_D],0
 	mov	byte [flag_V],0
 	mov	byte [flag_I],0
 	mov	byte [flag_B],0
 	mov	byte [RCycles],0
	ret

;*
;* state saving macros
;*

;;; converted macro:
%macro SaveCPUState 0
	push	eax
	push	ebx
	push	edx
	push	esi
%endmacro


;;; converted macro:
%macro RestoreCPUState 0
	pop	esi
	pop	edx
	pop	ebx
	pop	eax
%endmacro



;*
;* timing macro
;*

;;; converted macro:
%macro bumpclock 0
 	inc	byte [RClock]
 	inc	byte [RCycles]
%endmacro


;*
;* memory accessing macros -- everything should go through here
;*

;;; converted macro:
%macro read_bank 0
	push	eax
	bumpclock
 	mov	eax, dword [BSType]

 	call	dword [RBankTab + eax*4] ; trashes eax

         mov     al,byte [esi]
         mov     byte [BusState],al ; remember last data on the bus
        pop     eax
%endmacro


;;; converted macro:
%macro write_bank 0
	push	eax
	bumpclock
 	mov	eax, dword [BSType]

 	call	dword [WBankTab + eax*4] ; trashes eax

         mov     al,byte [WByte]
         mov     byte [BusState],al ; remember last data on the bus
        pop     eax
%endmacro


;*
;* memory accessing macros -- get/put data via op2
;*

;;; converted macro:
%macro read 2 ; read memory
	mov	esi,%2
	read_bank
 	mov	%1,byte dword [esi]
%endmacro

      
;;; converted macro:
%macro readsx 2 ; sign extended
	mov	esi,%2
	read_bank
 	movsx	%1,byte byte [esi]
%endmacro


;;; converted macro:
%macro readzx 2 ; zero extended
	mov	esi,%2
	read_bank
 	movzx	%1,byte byte [esi]
%endmacro


;;; converted macro:
%macro slack_read 1 ; read and throw away result
	mov	esi,%1
	read_bank
%endmacro


;;; converted macro:
%macro write 2 ; write memory
	mov	esi,%2
 	mov	byte [WByte],%1
	write_bank
%endmacro


;;; converted macro:
%macro slack_write 2 ; write memory
	mov	esi,%2
 	mov	byte [WByte],%1
	write_bank
%endmacro


;*
;* opcode (and immediate data) fetching macros
;*

;;; converted macro:
%macro fetch 1
 	read  %1,dword [reg_pc]
 	inc	dword [wreg_pc] ;;; GUESSED dword
%endmacro


;;; converted macro:
%macro fetchsx 1
 	readsx  %1,dword [reg_pc]
 	inc	dword [wreg_pc] ;;; GUESSED dword
%endmacro


;;; converted macro:
%macro fetchzx 1
 	readzx  %1,dword [reg_pc]
 	inc	dword [wreg_pc] ;;; GUESSED dword
%endmacro


;;; converted macro:
%macro fetch_opcode 1 ; special fetchzx for trace logging
; local ; fo_1


%ifdef TRACE
 	test	byte [TraceCount],1
	jz near %%fo_1

	call	TraceInstruction

%%fo_1:	
%endif
 	mov	byte [RCycles],0
 	readzx  %1,dword [reg_pc]
 	inc	dword [wreg_pc] ;;; GUESSED dword
%endmacro


;;; converted macro:
%macro slack_fetch 0 ; read and throw away, don't inc PC
 	slack_read  dword [reg_pc]
%endmacro


;*
;* 6507 stack macros
;*

;;; converted macro:
%macro zpush 1
 	write  %1,dword [dwreg_sp] ;;; GUESSED dword ; write byte to top of stack
 	dec	byte [reg_sp] ; and decrement stack pointer
%endmacro


;;; converted macro:
%macro zpop 1
 	inc	byte [reg_sp] ; increment the	stack pointer
 	read  %1,dword [dwreg_sp] ;;; GUESSED dword ; and read the top byte
%endmacro


;;; converted macro:
%macro slack_pop 0 ; read stack and throw away, don't inc SP
 	slack_read  dword [dwreg_sp] ;;; GUESSED dword
%endmacro


;*
;* memory addressing helper macros
;*

;;; converted macro:
%macro absolute 0
	fetch  bl
	fetch  bh
%endmacro


;;; converted macro:
%macro zeropage 0
	fetchzx  ebx
%endmacro


;;; converted macro:
%macro readaddress 0 ; read data in bx -> bx
	and	ebx,0ffh  ;  must be in page zero
	read  dl,ebx
	inc	bl
	read  dh,ebx
	mov	ebx,edx
%endmacro


;*
;* memory addressing macros
;*

;;; converted macro:
%macro abs_read 0 ; Absolute addressing
	absolute
%endmacro


;;; converted macro:
%macro abs_rmw 0
	absolute
%endmacro


;;; converted macro:
%macro abs_write 0
	absolute
%endmacro



;;; converted macro:
%macro zero_read 0 ; Zero page addressing
	zeropage
%endmacro


;;; converted macro:
%macro zero_rmw 0
	zeropage
%endmacro


;;; converted macro:
%macro zero_write 0
	zeropage
%endmacro



;;; converted macro:
%macro zero_x_read 0 ; Zero page indexed addressing
	zeropage
	slack_read  ebx
 	add	bl,byte [reg_x]
%endmacro


;;; converted macro:
%macro zero_x_rmw 0
	zero_x_read
%endmacro


;;; converted macro:
%macro zero_x_write 0
	zero_x_read
%endmacro


;;; converted macro:
%macro zero_y_read 0
	zeropage
	slack_read  ebx
 	add	bl,byte [reg_y]
%endmacro


;;; converted macro:
%macro zero_y_write 0
	zero_y_read
%endmacro



;;; converted macro:
%macro abs_x_read 0 ; Absolute indexed addressing
; local ; done

	absolute
 	add	bl,byte [reg_x]
	jnc	%%done
	slack_read  ebx
	inc	bh
%%done:
%endmacro
	

;;; converted macro:
%macro abs_x_rmw 0
	absolute
	slack_read  ebx
 	add	ebx, dword dword [reg_x]
%endmacro


;;; converted macro:
%macro abs_x_write 0
	abs_x_rmw
%endmacro


;;; converted macro:
%macro abs_y_read 0
; local ; done

	absolute
 	add	bl,byte [reg_y]
	jnc	%%done
	slack_read  ebx
	inc	bh
%%done:
%endmacro


;;; converted macro:
%macro abs_y_rmw 0
	absolute
	slack_read  ebx
 	add	ebx, dword dword [reg_y]
%endmacro


;;; converted macro:
%macro abs_y_write 0
	abs_y_rmw
%endmacro



;;; converted macro:
%macro ind_x_read 0 ; Indexed indirect addressing
	zeropage
	slack_read  ebx
 	add	ebx, dword dword [reg_x]
	readaddress
%endmacro


;;; converted macro:
%macro ind_x_rmw 0
	ind_x_read
%endmacro


;;; converted macro:
%macro ind_x_write 0
	ind_x_read
%endmacro



;;; converted macro:
%macro ind_y_read 0 ; Indirect indexed addressing
; local ; done

	zeropage
	readaddress
 	add	bl,byte [reg_y]
	jnc	%%done
	slack_read  ebx
	inc	bh
%%done:
%endmacro


;;; converted macro:
%macro ind_y_rmw 0
	zeropage
	readaddress
	push	ebx
 	add	bl,byte [reg_y]
	slack_read  ebx
	pop	ebx
 	add	ebx, dword dword [reg_y]
%endmacro


;;; converted macro:
%macro ind_y_write 0
	ind_y_rmw
%endmacro


;*
;* opcode definition macros
;*

;;; converted macro:
%macro op_align 0
  ;  ALIGN 4
%endmacro


;;; converted macro:
%macro op_register 3
op_align
%1:	slack_fetch
	mov	dl,%3
	_%2
	mov	%3,dl
	ret
%endmacro


;;; converted macro:
%macro op_transfer 3
op_align
%1:	slack_fetch
	mov	dl,%3
	mov	%2,dl
	ret
%endmacro


;;; converted macro:
%macro op_transfertest 3
op_align
%1:	slack_fetch
	mov	dl,%3
	mov	%2,dl
	usetest  dl
	ret
%endmacro


;;; converted macro:
%macro op_immediate 2
op_align
%1:	fetch  dl
	_%2
	ret
%endmacro


;;; converted macro:
%macro op_read 3
op_align
%1:	%3_read
	read  dl,ebx
	_%2
	ret
%endmacro


;;; converted macro:
%macro op_rmw 3
op_align
%1:	%3_rmw
	read  dl,ebx
	slack_write  dl,ebx
	_%2
	write  dl,ebx
	ret
%endmacro


;;; converted macro:
%macro op_write 3
op_align
%1:	%3_write
	_%2
	write  dl,ebx
	ret
%endmacro


;;; converted macro:
%macro op_branch 4
op_align
%1:	fetchsx  edx ;  sign-extended branch offset into dx
	test	%2,%3
	%4	DoBranch
	ret
%endmacro


;;; converted macro:
%macro op_weird 2
op_align
%1:	_%2
	ret
%endmacro


;*
;* flag setting macros
;*

;;; converted macro:
%macro useztest 1 ; use to test Z
 	mov	byte [RZTest],%1
%endmacro


;;; converted macro:
%macro usentest 1 ; use to test N		 
 	mov	byte [RNTest],%1
%endmacro


;;; converted macro:
%macro usetest 1 ; use to test both N and Z (normal)
	useztest  %1
	usentest  %1
%endmacro


;*
;* compare macros
;*

;;; converted macro:
%macro CompDH 0 ; compare dh and dl
	sub	dh,dl
	usetest  dh
	setnc	ah
%endmacro


;;; converted macro:
%macro _CMP 0 ; compare al and dl
	mov	dh,al
	CompDH
%endmacro


;*
;*  CPU macros
;*
;* (al=accumulator, ah=carry, dl=operand)
;*

;;; converted macro:
%macro _ADC 0
	call	DoADC
%endmacro


DoADC: cmp	byte [flag_D],0
	jnz near ADCBCD
	shr	ah,1
	adc	al,dl
 	seto	 [flag_V]
	usetest  al
	setc	ah
	ret

ADCBCD:	push	ecx

 	mov	byte [_reg_a],al
 	mov	byte [_value],dl

	add	al,dl			 ;  set some flags using binary addition
 	seto	 [flag_V]
	add	al,ah			 ;  add carry
 	mov	byte [RZTest],al

 	mov	al,byte [_reg_a] ; now do decimal addition
	and	al,0fh
	and	dl,0fh			 ;  dl has _value
	add	al,dl			 ;  add bottom nybbles
	add	al,ah			 ;  add carry
	cmp	al,9			 ;  fixup bottom nybble
	jbe near ADCD_1
	add	al,6
ADCD_1:	mov	cl,al			 ;  save result with half carry
	and	eax,0fh
 	mov	dl,byte [_reg_a]
	and	edx,0f0h
	add	eax,edx			 ;  combine with top nybble of _reg_a
 	mov	dl,byte [_value]
	and	edx,0f0h
	add	edx,eax			 ;  add top nybble of _value
	cmp	cl,0fh			 ;  did lower nybble fixup overflow ?
	jbe near ADCD_3
	add	edx,010h		 ;    yes
ADCD_3: mov	byte [RNTest],dl ; set a flag
	mov	eax,edx			 ;  fixup top nybble
	and	edx,01f0h
	cmp	edx,090h
	jbe near ADCD_6
	add	eax,060h
ADCD_6:	test	ah,ah
	setnz	ah			 ;  set carry
 	mov	dl,byte [_value] ; ADC must preserve dl for RRA

	pop	ecx
	ret	

;;; converted macro:
%macro _ANC 0
	and	al,dl
	usetest  al
	test	al,080h
	setnz	ah
%endmacro


;;; converted macro:
%macro _AND 0
	and	al,dl
	usetest  al
%endmacro


;;; converted macro:
%macro _ANE 0
	or	al,0eeh
 	and	al,byte [reg_x]
	and	al,dl
	usetest  al
%endmacro


;;; converted macro:
%macro _ARR 0

  ;  algorithm based on 6510core.c by Ettore Perazzoli (ettore@comm2000.it)

	push	ebx
	push	ecx

	and	al,dl
	mov	bl,al

 	cmp	byte [flag_D],0
	je near ARR_4

 	mov	byte [RNTest],ah
 	shl	byte [RNTest],7

	mov	ecx,eax
	shr	ecx,1

 	setnz	byte [RZTest]

	mov	al,cl
	xor	al,bl
	and	al,64
 	setnz	byte [flag_V]

	mov	al,bl
	mov	dl,bl
	and	al,15
	and	dl,1
	add	al,dl
	cmp	al,5
	jbe near ARR_1
	mov	dl,cl
	and	cl,240
	add	dl,6
	and	dl,15
	or	cl,dl
ARR_1:	mov	al,bl
	and	eax,240
	and	ebx,16
	add	eax,ebx
	cmp	eax,80
	jbe near ARR_2
	mov	al,cl
	and	al,15
	mov	bl,cl
	add	bl,96
	and	bl,240
	or	al,bl
	mov	ah,1
	jmp	ARR_5

ARR_2:	xor	ah,ah
	mov	al,cl
	jmp	ARR_5

ARR_4:	shr	eax,1
	usetest  al

	mov	bl,al
	test	bl,64
	setnz	ah

	and	bl,32
	shl	bl,1
	mov	dl,al
	and	dl,64
	xor	bl,dl
 	setnz	byte [flag_V]
ARR_5:
	pop	ecx
	pop	ebx
%endmacro


;;; converted macro:
%macro _ASL 0
	shl	dl,1
	setc	ah
	usetest  dl
%endmacro


;;; converted macro:
%macro _ASR 0
	and	al,dl
	test	al,1
	setnz	ah
	shr	al,1
	usetest  al
%endmacro


;;; converted macro:
%macro _BIT 0
	test	dl,040h  ;  bit 6 is the overflow flag
 	setnz	byte [flag_V]
	usentest  dl ;  the memory bit 7 is the n flag
	and	dl,al  ;  this is the and result
	useztest  dl ;  use it to test for zero
%endmacro


;;; converted macro:
%macro _CPX 0
 	mov	dh,byte [reg_x]
	CompDH
%endmacro


;;; converted macro:
%macro _CPY 0
 	mov	dh,byte [reg_y]
	CompDH
%endmacro


;;; converted macro:
%macro _DCP 0
	dec	dl
	_CMP
%endmacro


;;; converted macro:
%macro _DEC 0
	dec	dl
	usetest  dl
%endmacro


;;; converted macro:
%macro _EOR 0
	xor	al,dl
	usetest  al
%endmacro


;;; converted macro:
%macro _INC 0
	inc	dl
	usetest  dl
%endmacro


;;; converted macro:
%macro _ISB 0
	inc	dl
	call	DoSBC
%endmacro


;;; converted macro:
%macro _LAS 0
 	and	dl,byte [reg_sp]
	mov	al,dl
 	mov	byte [reg_x],dl
 	mov	byte [reg_sp],dl
	usetest  dl
%endmacro


;;; converted macro:
%macro _LAX 0
 	mov	byte [reg_x],dl
	mov	al,dl
	usetest  dl
%endmacro


;;; converted macro:
%macro _LDA 0
	mov	al,dl
	usetest  dl
%endmacro


;;; converted macro:
%macro _LDX 0
 	mov	byte [reg_x],dl
	usetest  dl
%endmacro


;;; converted macro:
%macro _LDY 0
 	mov	byte [reg_y],dl
	usetest  dl
%endmacro


;;; converted macro:
%macro _LSR 0
	shr	dl,1
	setc	ah
	usetest  dl
%endmacro


;;; converted macro:
%macro _LXA 0
	or	al,0eeh
	and	al,dl
 	mov	byte [reg_x],al
	usetest  al
%endmacro


;;; converted macro:
%macro _NOP 0
%endmacro


;;; converted macro:
%macro _ORA 0
	or	al,dl
	usetest  al
%endmacro


;;; converted macro:
%macro _RLA 0
	shr	ah,1
	rcl	dl,1
	setc	ah
	and	al,dl
	usetest  al
%endmacro


;;; converted macro:
%macro _ROL 0
	shr	ah,1
	rcl	dl,1
	setc	ah
	usetest  dl
%endmacro


;;; converted macro:
%macro _ROR 0
	shr	ah,1
	rcr	dl,1
	setc	ah
	usetest  dl
%endmacro


;;; converted macro:
%macro _RRA 0
	shr	ah,1
	rcr	dl,1
	setc	ah
	call	DoADC
%endmacro


;;; converted macro:
%macro _SAX 0
	mov	dl,al
 	and	dl,byte [reg_x]
%endmacro


;;; converted macro:
%macro _SBC 0
	call	DoSBC
%endmacro


DoSBC: cmp	byte [flag_D],0
	jnz near SBCBCD
	shr	ah,1
	cmc			 ;  set carry
	sbb	al,dl
 	seto	 [flag_V]
	usetest  al
	setnc	ah
	ret

SBCBCD:	push	ecx

 	mov	byte [_reg_a],al
 	mov	byte [_value],dl

	xor	ah,1
	sahf
	sbb	al,dl		 ;  set flags using binary subtraction
	usetest  al
 	setnc	byte [_flag_carry]
 	seto	 [flag_V]

 	mov	al,byte [_reg_a] ; now do decimal subtraction
	and	edx,0fh
	add	dl,ah
	and	eax,0fh
	sub	eax,edx		 ;  subtract bottom nybbles with carry
	mov	ecx,eax		 ;  save result
 	mov	al,byte [_reg_a]
	and	eax,0f0h
 	mov	dl,byte [_value]
	and	edx,0f0h
	sub	eax,edx		 ;  subtract top nybbles
	test	ecx,010h		 ;  bottom nybble underflow ?
	je near SBCD_5
	add	eax,-16		 ; 	 yes, fixup
	mov	edx,ecx
	add	edx,-6
	jmp	SBCD_6

SBCD_5:	mov	edx,ecx
SBCD_6:	and	edx,0fh
	or	eax,edx		 ;  combine lower and upper nybble result
	test	eax,0100h	 ;  upper nybble underflow ?
	je near SBCD_7
	sub	eax,060h		 ; 	  yes, fixup
SBCD_7: mov	ah,byte [_flag_carry]
 	mov	dl,byte [_value] ; SBC must preserve dl for ISB

	pop	ecx
	ret	

;;; converted macro:
%macro _SBX 0
	mov	dh,al
 	and	dh,byte [reg_x]
	sub	dh,dl
	usetest  dh
	setnc	ah
 	mov	byte [reg_x],dh
%endmacro


;;; converted macro:
%macro _SHA 0
	mov	dl,bh
	inc	dl
 	and	dl,byte [reg_x]
	and	dl,al
%endmacro


;;; converted macro:
%macro _SHS 0
	mov	dl,bh
	inc	dl
 	and	dl,byte [reg_x]
	and	dl,al
	mov	dh,al
 	and	dh,byte [reg_x]
 	mov	byte [reg_sp],dh
%endmacro


;;; converted macro:
%macro _SHX 0
	mov	dl,bh
	inc	dl
 	and	dl,byte [reg_x]
%endmacro


;;; converted macro:
%macro _SHY 0
	mov	dl,bh
	inc	dl
 	and	dl,byte [reg_y]
%endmacro


;;; converted macro:
%macro _SLO 0
	shl	dl,1
	setc	ah
	or	al,dl
	usetest  al
%endmacro


;;; converted macro:
%macro _SRE 0
	mov	ah,1
	and	ah,dl
	shr	dl,1
	xor	al,dl
	usetest  al
%endmacro


;;; converted macro:
%macro _STA 0
	mov	dl,al
%endmacro


;;; converted macro:
%macro _STX 0
 	mov	dl,byte [reg_x]
%endmacro


;;; converted macro:
%macro _STY 0
 	mov	dl,byte [reg_y]
%endmacro


;*
;* weird opcodes
;*

;;; converted macro:
%macro _BRK 0
	slack_fetch

 	mov	byte [flag_B],1 ; set break flag
 	inc	dword [wreg_pc] ;;; GUESSED dword
 	mov	ebx,dword [reg_pc] ; push return address
	zpush  bh
	zpush  bl

	call	GetPSW  ;  get PSW in DL
	or	dl,010h  ;  force break flag
	zpush  dl

 	mov	byte [flag_I],1 ; disable interrupts
	mov	ebx,0FFFEh  ;  fetch	the vector

	push	eax
	read  al,ebx
	inc	ebx
	read  ah,ebx
	and	eax,0ffffh
 	mov	dword [reg_pc],eax ; and transfer control
	pop	eax
%endmacro


;;; converted macro:
%macro _JMPI 0
	fetch  bl ;  read the address of the the jump
	fetch  bh
	read  dl,ebx
	inc	bl  ;  stay in current page
	read  dh,ebx
	and	edx,0ffffh
 	mov	dword [reg_pc],edx ; and jump to it
%endmacro


;;; converted macro:
%macro _JMPW 0
	fetch  bl ;  fetch	the address
	fetch  bh
	and	ebx,0ffffh
 	mov	dword [reg_pc],ebx ; jump to it
%endmacro


;;; converted macro:
%macro _JSR 0
	fetch  bl ;  bottom byte of new PC

	slack_pop

	push	eax
 	mov	eax,dword [reg_pc] ; ax is	the return address
	zpush  ah ;  we are automatically pushing return-1
	zpush  al
	pop	eax

	fetch  bh ;  now we fetch the top byte of PC
	and	ebx,0ffffh
 	mov	dword [reg_pc],ebx ; transfer control
%endmacro


;;; converted macro:
%macro _PHA 0
	slack_fetch
	zpush  al
%endmacro


;;; converted macro:
%macro _PLA 0
	slack_fetch
	slack_pop
	zpop  al
	usetest  al
%endmacro


;;; converted macro:
%macro _PHP 0
	slack_fetch
	call	GetPSW  ;  get PSW in DL
	or	dl,010h  ;  force break flag
	zpush  dl
%endmacro


;;; converted macro:
%macro _PLP 0
	slack_fetch
	slack_pop
	zpop  dh ;  pull PSW from stack
	call	PutPSW
%endmacro


;;; converted macro:
%macro _RTI 0
	slack_fetch
	slack_pop
	zpop  dh ;  pull PSW from stack
	call	PutPSW  ;  and scatter the flags
	push	eax
	zpop  al
	zpop  ah ;  pull return address
	and	eax,0ffffh
 	mov	dword [reg_pc],eax ; transfer control
	pop	eax
%endmacro


;;; converted macro:
%macro _RTS 0
	slack_fetch
	slack_pop
	push	eax
	zpop  al
	zpop  ah ;  pull return address
	and	eax,0ffffh
 	mov	dword [reg_pc],eax ; transfer control
	pop	eax
	slack_fetch
 	inc	dword [wreg_pc] ;;; GUESSED dword
%endmacro



; load CPU registers

;;; converted macro:
%macro LoadRegs 0
 	mov	eax,dword dword [reg_a] ; mov al,[reg_a]; mov ah,[flag_carry]
%endmacro


; save CPU registers

;;; converted macro:
%macro SaveRegs 0
 	mov	dword dword [reg_a],eax ; mov [reg_a],al; mov [flag_carry],ah
%endmacro


;*
;* do a single instruction (just for show)
;*

do_Instruction:

	LoadRegs  ;  load the CPU registers

	fetch_opcode  ebx ;  (fetchzx) get the opcode
 	call 	dword [vectors + ebx*4] ; --> do the instruction
	ClockRIOT

	SaveRegs  ;  save the CPU registers

	ret

;*
;* Reset the CPU
;*

Reset:
 	mov	byte [reg_sp],0FFh ; SP initialises to 255
	mov	ebx,0fffch	 ;  get reset address
	read  dl,ebx
	inc	ebx
	read  dh,ebx
	and	edx,0ffffh
 	mov	dword [reg_pc],edx
 	mov	byte [RClock],0
	ret

;*
;* Handle relative jumps
;*

DoBranch:
 	mov	ebx,dword [reg_pc] ; bh is	the current page
 	add	edx,dword [reg_pc] ; destination address
	and	edx,0ffffh
 	mov	dword [reg_pc],edx ; set the program counter

	cmp	bh,dh		 ;  page changed ?
	je near dbjn		 ;    no

	xchg	bh,dh
	slack_fetch  ; 	  yes, another cycle
	xchg	bh,dh

dbjn:	slack_fetch  ;  branch is taken -- one extra cycle

	ret

;*
;* Build the PSW out of the various flags and the last register into DL
;*

GetPSW: mov	dl,byte [RNTest] ; dl = last result
	and	dl,128		 ;  use bit 7 of that for N
 	mov	dh,byte [flag_V] ; bit 6	is V
	shl	dh,6
	or	dl,dh
	or	dl,020H		 ;  bit 5	is always set
 	mov	dh,byte [flag_B] ; bit 4	is B
	shl	dh,4
	or	dl,dh
 	mov	dh,byte [flag_D] ; bit 3	is D
	shl	dh,3
	or	dl,dh
 	mov	dh,byte [flag_I] ; bit 2	is I
	shl	dh,2
	or	dl,dh
 	cmp	byte [RZTest],0 ; bit 1 is Z
	jnz near PSWZero
	or	dl,02h
PSWZero:or	dl,ah		 ;  bit 0	is C
	ret

;*
;* set various flags from PSW in dh
;*

PutPSW: mov	byte [RNTest],dh ; PSW will do for N
	mov	ah,dh
	and	ah,1		 ;  bit 0 is C
	test	dh,02h		 ;  bit 1 is Z
 	setz	byte [RZTest]
	test	dh,04h		 ;  bit 2 is I
 	setnz	byte [flag_I]
	test	dh,08h		 ;  bit 3 is D
 	setnz	byte [flag_D]
	test	dh,010h		 ;  bit 4 is B
 	setnz	byte [flag_B]
	test	dh,040h		 ;  bit 6 is V
 	setnz	byte [flag_V]
	ret

[section .data]

;*
;* opcode vector table
;*
;* note:  the jam handler should be defined externally
;*	  (since it is typically environment dependent)
;*
vectors:  ; dword
    dd _00,_01,jam,_03,_04,_05,_06,_07,_08,_09,_0a,_0b,_0c,_0d,_0e,_0f
    dd _10,_11,jam,_13,_14,_15,_16,_17,_18,_19,_1a,_1b,_1c,_1d,_1e,_1f
    dd _20,_21,jam,_23,_24,_25,_26,_27,_28,_29,_2a,_0b,_2c,_2d,_2e,_2f  ; _2b=_0b
    dd _30,_31,jam,_33,_34,_35,_36,_37,_38,_39,_3a,_3b,_3c,_3d,_3e,_3f
    dd _40,_41,jam,_43,_44,_45,_46,_47,_48,_49,_4a,_4b,_4c,_4d,_4e,_4f
    dd _50,_51,jam,_53,_54,_55,_56,_57,_58,_59,_5a,_5b,_5c,_5d,_5e,_5f
    dd _60,_61,jam,_63,_64,_65,_66,_67,_68,_69,_6a,_6b,_6c,_6d,_6e,_6f
    dd _70,_71,jam,_73,_74,_75,_76,_77,_78,_79,_7a,_7b,_7c,_7d,_7e,_7f
    dd _80,_81,_82,_83,_84,_85,_86,_87,_88,_89,_8a,_8b,_8c,_8d,_8e,_8f
    dd _90,_91,jam,_93,_94,_95,_96,_97,_98,_99,_9a,_9b,_9c,_9d,_9e,_9f
    dd _a0,_a1,_a2,_a3,_a4,_a5,_a6,_a7,_a8,_a9,_aa,_ab,_ac,_ad,_ae,_af
    dd _b0,_b1,jam,_b3,_b4,_b5,_b6,_b7,_b8,_b9,_ba,_bb,_bc,_bd,_be,_bf
    dd _c0,_c1,_c2,_c3,_c4,_c5,_c6,_c7,_c8,_c9,_ca,_cb,_cc,_cd,_ce,_cf
    dd _d0,_d1,jam,_d3,_d4,_d5,_d6,_d7,_d8,_d9,_da,_db,_dc,_dd,_de,_df
    dd _e0,_e1,_e2,_e3,_e4,_e5,_e6,_e7,_e8,_e9,_ea,_e9,_ec,_ed,_ee,_ef  ; _eb=_e9
    dd _f0,_f1,jam,_f3,_f4,_f5,_f6,_f7,_f8,_f9,_fa,_fb,_fc,_fd,_fe,_ff

[section .code]

;*
;* opcode handlers
;*

op_weird  _00,BRK
op_read  _01,ORA,ind_x

op_rmw  _03,SLO,ind_x
op_read  _04,NOP,zero
op_read  _05,ORA,zero
op_rmw  _06,ASL,zero
op_rmw  _07,SLO,zero
op_weird  _08,PHP
op_immediate  _09,ORA
op_register  _0a,ASL,al
op_immediate  _0b,ANC
op_read  _0c,NOP,abs
op_read  _0d,ORA,abs
op_rmw  _0e,ASL,abs
op_rmw  _0f,SLO,abs
 op_branch  _10,byte [RNTest],128,jz
op_read  _11,ORA,ind_y

op_rmw  _13,SLO,ind_y
op_read  _14,NOP,zero_x
op_read  _15,ORA,zero_x
op_rmw  _16,ASL,zero_x
op_rmw  _17,SLO,zero_x
op_transfer  _18,ah,0
op_read  _19,ORA,abs_y
op_transfer  _1a,al,al
op_rmw  _1b,SLO,abs_y
op_read  _1c,NOP,abs_x
op_read  _1d,ORA,abs_x
op_rmw  _1e,ASL,abs_x
op_rmw  _1f,SLO,abs_x
op_weird  _20,JSR
op_read  _21,AND,ind_x

op_rmw  _23,RLA,ind_x
op_read  _24,BIT,zero
op_read  _25,AND,zero
op_rmw  _26,ROL,zero
op_rmw  _27,RLA,zero
op_weird  _28,PLP
op_immediate  _29,AND
op_register  _2a,ROL,al

op_read  _2c,BIT,abs
op_read  _2d,AND,abs
op_rmw  _2e,ROL,abs
op_rmw  _2f,RLA,abs
 op_branch  _30,byte [RNTest],128,jnz
op_read  _31,AND,ind_y

op_rmw  _33,RLA,ind_y
op_read  _34,NOP,zero
op_read  _35,AND,zero_x
op_rmw  _36,ROL,zero_x
op_rmw  _37,RLA,zero_x
op_transfer  _38,ah,1
op_read  _39,AND,abs_y
op_transfer  _3a,al,al
op_rmw  _3b,RLA,abs_y
op_read  _3c,NOP,abs_x
op_read  _3d,AND,abs_x
op_rmw  _3e,ROL,abs_x
op_rmw  _3f,RLA,abs_x
op_weird  _40,RTI
op_read  _41,EOR,ind_x

op_rmw  _43,SRE,ind_x
op_read  _44,NOP,zero
op_read  _45,EOR,zero
op_rmw  _46,LSR,zero
op_rmw  _47,SRE,zero
op_weird  _48,PHA
op_immediate  _49,EOR
op_register  _4a,LSR,al
op_immediate  _4b,ASR
op_weird  _4c,JMPW
op_read  _4d,EOR,abs
op_rmw  _4e,LSR,abs
op_rmw  _4f,SRE,abs
 op_branch  _50,byte [flag_V],0ffh,jz
op_read  _51,EOR,ind_y

op_rmw  _53,SRE,ind_y
op_read  _54,NOP,zero_x
op_read  _55,EOR,zero_x
op_rmw  _56,LSR,zero_x
op_rmw  _57,SRE,zero_x
 op_transfer  _58,byte [flag_I],0
op_read  _59,EOR,abs_y
op_transfer  _5a,al,al
op_rmw  _5b,SRE,abs_y
op_read  _5c,NOP,abs_x
op_read  _5d,EOR,abs_x
op_rmw  _5e,LSR,abs_x
op_rmw  _5f,SRE,abs_x
op_weird  _60,RTS
op_read  _61,ADC,ind_x

op_rmw  _63,RRA,ind_x
op_read  _64,NOP,zero
op_read  _65,ADC,zero
op_rmw  _66,ROR,zero
op_rmw  _67,RRA,zero
op_weird  _68,PLA
op_immediate  _69,ADC
op_register  _6a,ROR,al
op_immediate  _6b,ARR
op_weird  _6c,JMPI
op_read  _6d,ADC,abs
op_rmw  _6e,ROR,abs
op_rmw  _6f,RRA,abs
 op_branch  _70,byte [flag_V],0ffh,jnz
op_read  _71,ADC,ind_y

op_rmw  _73,RRA,ind_y
op_read  _74,NOP,zero_x
op_read  _75,ADC,zero_x
op_rmw  _76,ROR,zero_x
op_rmw  _77,RRA,zero_x
 op_transfer  _78,byte [flag_I],1
op_read  _79,ADC,abs_y
op_transfer  _7a,al,al
op_rmw  _7b,RRA,abs_y
op_read  _7c,NOP,abs_x
op_read  _7d,ADC,abs_x
op_rmw  _7e,ROR,abs_x
op_rmw  _7f,RRA,abs_x
op_immediate  _80,NOP
op_write  _81,STA,ind_x
op_immediate  _82,NOP
op_write  _83,SAX,ind_x
op_write  _84,STY,zero
op_write  _85,STA,zero
op_write  _86,STX,zero
op_write  _87,SAX,zero
 op_register  _88,DEC,byte [reg_y]
op_immediate  _89,NOP
 op_transfertest  _8a,al,byte [reg_x]
op_immediate  _8b,ANE
op_write  _8c,STY,abs
op_write  _8d,STA,abs
op_write  _8e,STX,abs
op_write  _8f,SAX,abs
op_branch  _90,ah,ah,jz
op_write  _91,STA,ind_y

op_write  _93,SHA,ind_y
op_write  _94,STY,zero_x
op_write  _95,STA,zero_x
op_write  _96,STX,zero_y
op_write  _97,SAX,zero_y
 op_transfertest  _98,al,byte [reg_y]
op_write  _99,STA,abs_y
 op_transfer  _9a,byte [reg_sp],[reg_x]
op_write  _9b,SHS,abs_y
op_write  _9c,SHY,abs_x
op_write  _9d,STA,abs_x
op_write  _9e,SHX,abs_y
op_write  _9f,SHA,abs_y
op_immediate  _a0,LDY
op_read  _a1,LDA,ind_x
op_immediate  _a2,LDX
op_read  _a3,LAX,ind_x
op_read  _a4,LDY,zero
op_read  _a5,LDA,zero
op_read  _a6,LDX,zero
op_read  _a7,LAX,zero
 op_transfertest  _a8,byte [reg_y],al
op_immediate  _a9,LDA
 op_transfertest  _aa,byte [reg_x],al
op_immediate  _ab,LXA
op_read  _ac,LDY,abs
op_read  _ad,LDA,abs
op_read  _ae,LDX,abs
op_read  _af,LAX,abs
op_branch  _b0,ah,ah,jnz
op_read  _b1,LDA,ind_y

op_read  _b3,LAX,ind_y
op_read  _b4,LDY,zero_x
op_read  _b5,LDA,zero_x
op_read  _b6,LDX,zero_y
op_read  _b7,LAX,zero_y
 op_transfer  _b8,byte [flag_V],0
op_read  _b9,LDA,abs_y
 op_transfertest  _ba,byte [reg_x],[reg_sp]
op_read  _bb,LAS,abs_y
op_read  _bc,LDY,abs_x
op_read  _bd,LDA,abs_x
op_read  _be,LDX,abs_y
op_read  _bf,LAX,abs_y
op_immediate  _c0,CPY
op_read  _c1,CMP,ind_x
op_immediate  _c2,NOP
op_rmw  _c3,DCP,ind_x
op_read  _c4,CPY,zero
op_read  _c5,CMP,zero
op_rmw  _c6,DEC,zero
op_rmw  _c7,DCP,zero
 op_register  _c8,INC,byte [reg_y]
op_immediate  _c9,CMP
 op_register  _ca,DEC,byte [reg_x]
op_immediate  _cb,SBX
op_read  _cc,CPY,abs
op_read  _cd,CMP,abs
op_rmw  _ce,DEC,abs
op_rmw  _cf,DCP,abs
 op_branch  _d0,byte [RZTest],0ffh,jnz
op_read  _d1,CMP,ind_y

op_rmw  _d3,DCP,ind_y
op_read  _d4,NOP,zero_x
op_read  _d5,CMP,zero_x
op_rmw  _d6,DEC,zero_x
op_rmw  _d7,DCP,zero_x
 op_transfer  _d8,byte [flag_D],0
op_read  _d9,CMP,abs_y
op_transfer  _da,al,al
op_rmw  _db,DCP,abs_y
op_read  _dc,NOP,abs_x
op_read  _dd,CMP,abs_x
op_rmw  _de,DEC,abs_x
op_rmw  _df,DCP,abs_x
op_immediate  _e0,CPX
op_read  _e1,SBC,ind_x
op_immediate  _e2,NOP
op_rmw  _e3,ISB,ind_x
op_read  _e4,CPX,zero
op_read  _e5,SBC,zero
op_rmw  _e6,INC,zero
op_rmw  _e7,ISB,zero
 op_register  _e8,INC,byte [reg_x]
op_immediate  _e9,SBC
op_transfer  _ea,al,al

op_read  _ec,CPX,abs
op_read  _ed,SBC,abs
op_rmw  _ee,INC,abs
op_rmw  _ef,ISB,abs
 op_branch  _f0,byte [RZTest],0ffh,jz
op_read  _f1,SBC,ind_y

op_rmw  _f3,ISB,ind_y
op_read  _f4,NOP,zero_x
op_read  _f5,SBC,zero_x
op_rmw  _f6,INC,zero_x
op_rmw  _f7,ISB,zero_x
 op_transfer  _f8,byte [flag_D],1
op_read  _f9,SBC,abs_y
op_transfer  _fa,al,al
op_rmw  _fb,ISB,abs_y
op_read  _fc,NOP,abs_x
op_read  _fd,SBC,abs_x
op_rmw  _fe,INC,abs_x
op_rmw  _ff,ISB,abs_x


;;; end merge of cpu.asm

;;; merged: 	include cpujam.asm		; (32) jam handler
; z26 cpu jam handlers

; z26 is Copyright 1997-1999 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-04-02 -- 32-bit

[section .code]

;*
;* jam handler 
;*

jam: dec	dword [reg_pc] ; point at jam instruction
 	read  al,dword [reg_pc]
	cmp	al,052h		 ;  starpath jam?
	je near StarpathJAM

 	read  al,dword [reg_pc]
 	mov	byte [cpu_a],al ; hand over opcode to C display routine
 	mov	eax,dword [reg_pc]
 	mov	dword [cpu_pc],eax
 	mov	byte [MessageCode],3 ; Jam instruction $xx @ $xxxx
	jmp	GoDOS


;;; end merge of cpujam.asm

;;; merged: 	include cpuhand.asm		; (32) cpu memory & register handlers
;*
;* cpu memory and register handlers -- used by the CPU emulator
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-03-02 -- 32-bit

;*
;* Hardware I/O address bits
;*
;* Dan Boris' 2600 schematics show the TIA and RIOT chips hooked up to the
;* CPU with the following address lines hooked up.
;*
;*   12 | 11  10  09  08 | 07  06  05  04 | 03	02  01	00 
;* 
;*    X			    X					TIA
;*    X		   X		  X					    RIOT
;*
;* If the 1000h bit (bit 12) is set, it's a ROM access.	 This is handled
;* in banks.asm and we'll never come here.
;*
;* Otherwise it's a hardware access.
;*
;* If the 200h bit is		set and the 80h bit is	   set then it's a RIOT access.
;* If the 200h bit is not set and the 80h bit is     set then it's a RAM access.
;* If the 200h bit is not set and the 80h bit is not set then it's a TIA access.
;*

[section .data]
CH_Start:  ; byte			; <-- start clearing here

TIACollide	dd  0	 ;  Collision flag word.

RT_Reg		dd  0	 ;  TIA reg to read (ReadCollision)
RetWd		db  0	 ;  byte returned from hardware read

;*** keep these in order ***

; variables moved to C code

;_DumpPorts	times 4 db 0	; Input ports (inp0..3)

;InputLatch	db  0	; Input latch (inp4)
;		db  0	; Input latch (inp5)
CH_End:  ; byte			; <-- finish clearing here

[section .code]

;*
;* Initialization
;*

Init_CPUhand:
	clear_mem  CH_Start,  CH_End
 	mov	word byte [InputLatch],08080h
	ret

; *****************************************************************************
;  Memory Mapping - Read - 
;  For non-rom areas, esi contains the requested address. 
;  On exit ds:[esi] points to the actual required data.
; *****************************************************************************

ReadHardware:
	test	esi,0200h		 ;  possible RIOT read?
	jnz near ReadRiotMaybe		 ;    yes

ReadHardwarePage0:
	test	esi,080h		 ;  RAM Read?
	jz near ReadTIA			 ;    no
	and	esi,0ffh
	add	esi, RiotRam-128
	ret

ReadRiotMaybe:
	test	esi,080h
	jnz near ReadRIOT

ReadTIA:
	push	eax
 	mov	al,byte [BusState] ; set undefined bits depending
					 ;    on the state of the data bus
	and	eax,03fh		 ;  topmost two bits are always defined

ReadTIAZero:
	and	esi,0fh
 	mov	byte [RetWd],al ; results get OR'd into this
	pop	eax
	cmp	esi,08h			 ;  reading collision registers ???
	jb near ReadCollision
	cmp	esi,0Eh
	jb near ReadInputLatches

	mov	esi, RetWd	 ;  return noisy word
	ret

;*
;* read collision routine
;*

ReadCollision:				 ;  read the collision latch
 	mov	dword [RT_Reg],esi
	SaveCPUState
	mov	dl,0
	call	CatchUpPixels		 ;  render pixels up to the write clock

	push	ecx
 	mov	eax,dword [TIACollide]
 	mov	ecx,dword [RT_Reg] ; ecx = address
	shl	ecx,1			 ;  shift it right 2 x address
	shr	eax,cl			 ;  and do it....
	and	eax,3			 ;  eax is now the 7,6 collide bits
	shl	al,6			 ;  put them back in bits 7 and 6
 	or	byte [RetWd],al ; save word for returning
	pop	ecx

	RestoreCPUState

	mov	esi, RetWd
	ret


ReadInputLatches:			 ;  read the input latch
	cmp	esi,0ch
	jb near ReadDumped
	pushad
 	mov	eax,dword [ScanLine] ; push parameters for C function
	push	eax
 	movzx	eax,byte [RClock]
	push	eax
	call	TestLightgunHit		 ;  void TestLightgunHit(dd RClock, dd ScanLine)
					 ;  updates [InputLatch+x] on Lightgun hit
	pop	eax
	pop	eax			 ;  clean up stack after function call
	popad

	and	esi,1
	add	esi, InputLatch
	push	eax
 	mov	al,byte [esi]
 	or	byte [RetWd],al
	pop	eax
	mov	esi, RetWd
	ret
	
ReadDumped:
	and	esi,3
         mov     edx,dword [ChargeTrigger0 + esi*4]
 	cmp	edx,dword [ChargeCounter] ; this trigger expired ?
	jbe near TriggerExpired			 ; 	  yes
RetZero: or	byte [RetWd],0
	mov	esi, RetWd
	ret

TriggerExpired:
 	or	byte [RetWd],080h
	mov	esi, RetWd
	ret
	

; *****************************************************************************
;   Memory mapping - Write. 
;   On Entry , si contains the address and [WByte] the data.
; *****************************************************************************


WriteHardware:
	test	esi,0200h		 ;  possible RIOT write?
	jnz near WriteRiotMaybe		 ; 	 yes

WriteHardwarePage0:
	test	esi,080h		 ;  RAM write?
	jz near NewTIA			 ; 	 no
	and	esi,0ffh
 	mov	dl,byte [WByte] ; writing to RAM
 	mov	byte [RiotRam-128 + esi],dl
	ret

WriteRiotMaybe:
	test	esi,080h
	jnz near WriteRIOT
	jmp	NewTIA

;;; end merge of cpuhand.asm

;;; merged: 	include trace.asm		; (32) trace buffer stuff
; trace.asm -- z26 trace stuff

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 08-04-02 -- 32-bit


[section .data]

debugflag	db	0

[section .code]

;*
;* trace routines
;*
;* so trace code written in C can access the assembler language machinery
;*
global ReallyReadROM

ReallyReadROM:
	pushad
 	mov	esi,dword [cpu_MAR]

 	mov	byte [debugflag],1
 	mov	eax, dword [BSType]
 	call	dword [RBankTab + eax*4] ; trashes eax
 	mov	byte [debugflag],0

 	mov	al,byte [esi]
 	mov	byte [cpu_Rbyte],al

	popad
	ret
global ReallyReadRAM

ReallyReadRAM:
	pushad
 	mov	esi,dword [cpu_MAR]

 	mov	byte [debugflag],1
	call	ReadHardware
 	mov	byte [debugflag],0

 	mov	al,byte [esi]
 	mov	byte [cpu_Rbyte],al

	popad
	ret



;*
;* trace routine so assembler routine can
;* start the C trace routine
;*

TraceInstruction:
	pushad

 	mov	byte [cpu_a],al
 	mov	byte [cpu_carry],ah

 	mov	eax,dword [Frame]
 	mov	dword [frame],eax
 	mov	eax,dword [ScanLine]
 	mov	dword [line],eax
 	mov	al,byte [RClock]
 	mov	byte [cycle],al

 	mov	eax,dword [BL_Position]
 	mov	dword [BL_Pos],eax
 	mov	eax,dword [M0_Position]
 	mov	dword [M0_Pos],eax
 	mov	eax,dword [M1_Position]
 	mov	dword [M1_Pos],eax
 	mov	eax,dword [P0_Position]
 	mov	dword [P0_Pos],eax
 	mov	eax,dword [P1_Position]
 	mov	dword [P1_Pos],eax

 	mov	eax,dword [reg_pc]
 	mov	dword [cpu_pc],eax
 	mov	al,byte [reg_x]
 	mov	byte [cpu_x],al
 	mov	al,byte [reg_y]
 	mov	byte [cpu_y],al
 	mov	al,byte [reg_sp]
 	mov	byte [cpu_sp],al
 	mov	al,byte [RZTest]
 	mov	byte [cpu_ZTest],al
 	mov	al,byte [RNTest]
 	mov 	byte [cpu_NTest],al
 	mov	al,byte [flag_D]
 	mov	byte [cpu_D],al
 	mov	al,byte [flag_V]
 	mov	byte [cpu_V],al
 	mov	al,byte [flag_I]
 	mov	byte [cpu_I],al
 	mov	al,byte [flag_B]
 	mov	byte [cpu_B],al

	call	ShowRegisters
	call	ShowInstruction

	popad
	ret


;;; end merge of trace.asm

;;; merged: 	include tiatab.asm		; (32) various tables for TIA graphics emulation
;*
;* tiatab.asm -- tables needed for z26 TIA emulator
;*

; z26 is Copyright 1997-2002 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 09-07-02 -- 32-bit

[section .data]

ALIGN 2  ; was ALIGN 4 *EST*


;playfield counter to playfield bit table

;	  PF2		|	  PF1		|	  PF0		|
; 7  6	5  4  3	 2  1  0  7  6	5  4  3	 2  1  0  7  6	5  4  3	 2  1  0
;23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6	5  4  3	 2  1  0
;				  ECX					|
PFClockToBitReversed:  ; dword

	dd 1 << 4 		 ; 0	forward
	dd 1 << 5 		 ; 1
	dd 1 << 6 		 ; 2
	dd 1 << 7 		 ; 3
	dd 1 << 15 	 ; 4
	dd 1 << 14 	 ; 5
	dd 1 << 13 	 ; 6
	dd 1 << 12 	 ; 7
	dd 1 << 11 	 ; 8
	dd 1 << 10 	 ; 9
	dd 1 << 9 		 ; 10
	dd 1 << 8 		 ; 11
	dd 1 << 16 	 ; 12
	dd 1 << 17 	 ; 13
	dd 1 << 18 	 ; 14
	dd 1 << 19 	 ; 15
	dd 1 << 20 	 ; 16
	dd 1 << 21 	 ; 17
	dd 1 << 22 	 ; 18
	dd 1 << 23 	 ; 19
			  
	dd 1 << 23 	 ; 20	reversed
	dd 1 << 22 	 ; 21
	dd 1 << 21 	 ; 22
	dd 1 << 20 	 ; 23
	dd 1 << 19 	 ; 24
	dd 1 << 18 	 ; 25
	dd 1 << 17 	 ; 26
	dd 1 << 16 	 ; 27
	dd 1 << 8 		 ; 28
	dd 1 << 9 		 ; 29
	dd 1 << 10 	 ; 30
	dd 1 << 11 	 ; 31
	dd 1 << 12 	 ; 32
	dd 1 << 13 	 ; 33
	dd 1 << 14 	 ; 34
	dd 1 << 15 	 ; 35
	dd 1 << 7 		 ; 36
	dd 1 << 6 		 ; 37
	dd 1 << 5 		 ; 38
	dd 1 << 4 		 ; 39
PFClockToBitForward:  ; dword

	dd 1 << 4 		 ; 0	forward
	dd 1 << 5 		 ; 1
	dd 1 << 6 		 ; 2
	dd 1 << 7 		 ; 3
	dd 1 << 15 	 ; 4
	dd 1 << 14 	 ; 5
	dd 1 << 13 	 ; 6
	dd 1 << 12 	 ; 7
	dd 1 << 11 	 ; 8
	dd 1 << 10 	 ; 9
	dd 1 << 9 		 ; 10
	dd 1 << 8 		 ; 11
	dd 1 << 16 	 ; 12
	dd 1 << 17 	 ; 13
	dd 1 << 18 	 ; 14
	dd 1 << 19 	 ; 15
	dd 1 << 20 	 ; 16
	dd 1 << 21 	 ; 17
	dd 1 << 22 	 ; 18
	dd 1 << 23 	 ; 19
			  
	dd 1 << 4 		 ; 0	forward
	dd 1 << 5 		 ; 1
	dd 1 << 6 		 ; 2
	dd 1 << 7 		 ; 3
	dd 1 << 15 	 ; 4
	dd 1 << 14 	 ; 5
	dd 1 << 13 	 ; 6
	dd 1 << 12 	 ; 7
	dd 1 << 11 	 ; 8
	dd 1 << 10 	 ; 9
	dd 1 << 9 		 ; 10
	dd 1 << 8 		 ; 11
	dd 1 << 16 	 ; 12
	dd 1 << 17 	 ; 13
	dd 1 << 18 	 ; 14
	dd 1 << 19 	 ; 15
	dd 1 << 20 	 ; 16
	dd 1 << 21 	 ; 17
	dd 1 << 22 	 ; 18
	dd 1 << 23 	 ; 19


;
; pixel to collision word
;
TIAColTab:  ; dword
   dd 0		 ;  0
   dd 0		 ;  0
   dd 0		 ;  0
   dd 8192	 ;  2000
   dd 0		 ;  0
   dd 128	 ;  80
   dd 64	 ;  40
   dd 8384	 ;  20c0
   dd 0		 ;  0
   dd 2048	 ;  800
   dd 1024	 ;  400
   dd 11264	 ;  2c00
   dd 4		 ;  4
   dd 2180	 ;  884
   dd 1092	 ;  444
   dd 11460	 ;  2cc4
   dd 0		 ;  0
   dd 32	 ;  20
   dd 16	 ;  10
   dd 8240	 ;  2030
   dd 32768	 ;  8000
   dd 32928	 ;  80a0
   dd 32848	 ;  8050
   dd 41200	 ;  a0f0
   dd 8		 ;  8
   dd 2088	 ;  828
   dd 1048	 ;  418
   dd 11320	 ;  2c38
   dd 32780	 ;  800c
   dd 34988	 ;  88ac
   dd 33884	 ;  845c
   dd 44284	 ;  acfc
   dd 0		 ;  0
   dd 512	 ;  200
   dd 256	 ;  100
   dd 8960	 ;  2300
   dd 2		 ;  2
   dd 642	 ;  282
   dd 322	 ;  142
   dd 9154	 ;  23c2
   dd 16384	 ;  4000
   dd 18944	 ;  4a00
   dd 17664	 ;  4500
   dd 28416	 ;  6f00
   dd 16390	 ;  4006
   dd 19078	 ;  4a86
   dd 17734	 ;  4546
   dd 28614	 ;  6fc6
   dd 1		 ;  1
   dd 545	 ;  221
   dd 273	 ;  111
   dd 9009	 ;  2331
   dd 32771	 ;  8003
   dd 33443	 ;  82a3
   dd 33107	 ;  8153
   dd 41971	 ;  a3f3
   dd 16393	 ;  4009
   dd 18985	 ;  4a29
   dd 17689	 ;  4519
   dd 28473	 ;  6f39
   dd 49167	 ;  c00f
   dd 51887	 ;  caaf
   dd 50527	 ;  c55f
   dd 61439	 ;  efff
TIADisplayToColour:  ; byte
 db 0,1,4,4,2,2,2,2,2,2,2,2,2,2,2,2
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
;
TIADisplayToColour2:  ; byte
 db 0,1,4,1,2,1,4,1,2,1,4,1,2,1,4,1
 db 3,1,4,1,3,1,4,1,3,1,4,1,3,1,4,1
 db 3,1,4,1,3,1,4,1,3,1,4,1,3,1,4,1
 db 3,1,4,1,3,1,4,1,3,1,4,1,3,1,4,1


PF_Table	dd	PFClockToBitForward	 ;  current pointer to playfield mask bits
PixelColorTable	dd	TIADisplayToColour	 ;  pixel to color translation table


;*
;* sprite definitions
;*
;* The top bit of the delay byte is the triple flag.
;* This means subsequent RESPx outputs the leading sprite.
;*
;* Note:  There is an entry just before the first entry of a single-width 
;*	  player sprite that isn't there, that should have the triple flag
;*	  set.	That is there should be four entries with the triple flag set.
;* 

;;; converted macro:
%macro LeadingPlayer 0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		10
	db	0,		9
	db	10000000b,	8
	db	1000000b,	7
	db	100000b,	6
	db	10000b,		5
	db	1000b,		4
	db	100b,		3
	db	10b,		2
	db	1b,		1
	db	0,		0
%endmacro


;;; converted macro:
%macro BlankPlayer 0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		10
	db	0,		9
	db	0,		8
	db	0,		7
	db	0,		6
	db	0,		5
	db	0,		4
	db	0,		3
	db	0,		2
	db	0,		1
	db	0,		0
%endmacro


;;; converted macro:
%macro TrailingPlayer 0
	db	0,		0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		10
	db	0,		9
	db	10000000b,	8
	db	1000000b,	7
	db	100000b,	6
	db	10000b,		5
	db	1000b,		4
	db	100b,		3
	db	10b,		2
	db	1b,		1
	db	0,		0
%endmacro


;;; converted macro:
%macro LeadingMissile 0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		0
	db	10000000b,	8
	db	1000000b,	7
	db	100000b,	6
	db	10000b,		5
	db	1000b,		4
	db	100b,		3
	db	10b,		2
	db	1b,		1
	db	0,		0
%endmacro


;;; converted macro:
%macro BlankMissile 0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		0
	db	0,		8
	db	0,		7
	db	0,		6
	db	0,		5
	db	0,		4
	db	0,		3
	db	0,		2
	db	0,		1
	db	0,		0
%endmacro


;;; converted macro:
%macro TrailingMissile 0
	db	0,		0
	db	0,		0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		0
	db	10000000b,	8
	db	1000000b,	7
	db	100000b,	6
	db	10000b,		5
	db	1000b,		4
	db	100b,		3
	db	10b,		2
	db	1b,		1
	db	0,		0
%endmacro


;;; converted macro:
%macro MediumGap 0
	times 2*16 db (0)
%endmacro


;;; converted macro:
%macro WideGap 0
	times 6*16 db (0)
%endmacro


;*
;* Medium and wide players have an extra leading clock.
;* They have the extra triple flag too.
;*

;;; converted macro:
%macro MediumPlayer 0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		18
	db	0,		17
	db	10000000b,	16
	db	10000000b,	15
	db	1000000b,	14
	db	1000000b,	13
	db	100000b,	12
	db	100000b,	11
	db	10000b,		10
	db	10000b,		9
	db	1000b,		8
	db	1000b,		7
	db	100b,		6
	db	100b,		5
	db	10b,		4
	db	10b,		3
	db	1b,		2
	db	1b,		1
	db	0,		0
%endmacro



;;; converted macro:
%macro MediumBlankPlayer 0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		18
	db	0,		17
	db	0,		16
	db	0,		15
	db	0,		14
	db	0,		13
	db	0,		12
	db	0,		11
	db	0,		10
	db	0,		9
	db	0,		8
	db	0,		7
	db	0,		6
	db	0,		5
	db	0,		4
	db	0,		3
	db	0,		2
	db	0,		1
	db	0,		0
%endmacro



;;; converted macro:
%macro WidePlayer 0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		34
	db	0,		33
	db	10000000b,	32
	db	10000000b,	31
	db	10000000b,	30
	db	10000000b,	29
	db	1000000b,	28
	db	1000000b,	27
	db	1000000b,	26
	db	1000000b,	25
	db	100000b,	24
	db	100000b,	23
	db	100000b,	22
	db	100000b,	21
	db	10000b,		20
	db	10000b,		19
	db	10000b,		18
	db	10000b,		17
	db	1000b,		16
	db	1000b,		15
	db	1000b,		14
	db	1000b,		13
	db	100b,		12
	db	100b,		11
	db	100b,		10
	db	100b,		9
	db	10b,		8
	db	10b,		7
	db	10b,		6
	db	10b,		5
	db	1b,		4
	db	1b,		3
	db	1b,		2
	db	1b,		1
	db	0,		0
%endmacro



;;; converted macro:
%macro WideBlankPlayer 0
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		080h
	db	0,		34
	db	0,		33
	db	0,		32
	db	0,		31
	db	0,		30
	db	0,		29
	db	0,		28
	db	0,		27
	db	0,		26
	db	0,		25
	db	0,		24
	db	0,		23
	db	0,		22
	db	0,		21
	db	0,		20
	db	0,		19
	db	0,		18
	db	0,		17
	db	0,		16
	db	0,		15
	db	0,		14
	db	0,		13
	db	0,		12
	db	0,		11
	db	0,		10
	db	0,		9
	db	0,		8
	db	0,		7
	db	0,		6
	db	0,		5
	db	0,		4
	db	0,		3
	db	0,		2
	db	0,		1
	db	0,		0
%endmacro



;*
;* sprite size calculation macro
;*

;;; converted macro:
%macro SpriteSize 1
%1_Size equ ($-%1)/2-1 
%endmacro


;*
;* default sprite definitions
;*
P_0:  ; byte		; Player NUSIZ = 0
P0_Sprite:  ; byte
P1_Sprite:  ; byte	
	LeadingPlayer

SpriteSize  P_0

P0_SpriteSize equ 13 
P1_SpriteSize equ 13 
M_0:  ; byte		; Missile NUSIZ = 0
M_5:  ; byte		; Missile NUSIZ = 5
M_7:  ; byte		; Missile NUSIZ = 7
BL_Sprite:  ; byte
M0_Sprite:  ; byte
M1_Sprite:  ; byte
	LeadingMissile

SpriteSize  M_0
SpriteSize  M_5
SpriteSize  M_7

M0_SpriteSize equ 12 
M1_SpriteSize equ 12 
BL_SpriteSize equ 12 
P_1:  ; byte		; Player NUSIZ = 1
	LeadingPlayer
	TrailingPlayer

SpriteSize  P_1
M_1:  ; byte		; Missile NUSIZ = 1
	LeadingMissile
	TrailingMissile

SpriteSize  M_1
P_2:  ; byte		; Player NUSIZ = 2
	LeadingPlayer
	MediumGap
	TrailingPlayer

SpriteSize  P_2
M_2:  ; byte		; Missile NUSIZ = 2
	LeadingMissile
	MediumGap
	TrailingMissile

SpriteSize  M_2
P_3:  ; byte		; Player NUSIZ = 3
	LeadingPlayer
	TrailingPlayer
	TrailingPlayer

SpriteSize  P_3
M_3:  ; byte		; Missile NUSIZ = 3
	LeadingMissile
	TrailingMissile
	TrailingMissile

SpriteSize  M_3
P_4:  ; byte		; Player NUSIZ = 4
	LeadingPlayer
	WideGap
	TrailingPlayer

SpriteSize  P_4
M_4:  ; byte		; Missile NUSIZ = 4
	LeadingMissile
	WideGap
	TrailingMissile

SpriteSize  M_4
P_5:  ; byte		; Player NUSIZ = 5
	MediumPlayer

SpriteSize  P_5
P_6:  ; byte		; Player NUSIZ = 6
	LeadingPlayer
	MediumGap
	TrailingPlayer
	MediumGap
	TrailingPlayer

SpriteSize  P_6
M_6:  ; byte		; Missile NUSIZ = 6
	LeadingMissile
	MediumGap
	TrailingMissile
	MediumGap
	TrailingMissile

SpriteSize  M_6
P_7:  ; byte		; Player NUSIZ = 7
	WidePlayer

SpriteSize  P_7


;*
;* multi sprite definitions
;*	
MP_0:  ; byte		; Player NUSIZ = 0
	BlankPlayer
MM_0:  ; byte		; Missile NUSIZ = 0
MM_5:  ; byte		; Missile NUSIZ = 5
MM_7:  ; byte		; Missile NUSIZ = 7
	BlankMissile
MP_1:  ; byte		; Player NUSIZ = 1
	BlankPlayer
	TrailingPlayer
MM_1:  ; byte		; Missile NUSIZ = 1
	BlankMissile
	TrailingMissile
MP_2:  ; byte		; Player NUSIZ = 2
	BlankPlayer
	MediumGap
	TrailingPlayer
MM_2:  ; byte		; Missile NUSIZ = 2
	BlankMissile
	MediumGap
	TrailingMissile
MP_3:  ; byte		; Player NUSIZ = 3
	BlankPlayer
	TrailingPlayer
	TrailingPlayer
MM_3:  ; byte		; Missile NUSIZ = 3
	BlankMissile
	TrailingMissile
	TrailingMissile
MP_4:  ; byte		; Player NUSIZ = 4
	BlankPlayer
	WideGap
	TrailingPlayer
MM_4:  ; byte		; Missile NUSIZ = 4
	BlankMissile
	WideGap
	TrailingMissile
MP_5:  ; byte		; Player NUSIZ = 5
	MediumBlankPlayer
MP_6:  ; byte		; Player NUSIZ = 6
	BlankPlayer
	MediumGap
	TrailingPlayer
	MediumGap
	TrailingPlayer
MM_6:  ; byte		; Missile NUSIZ = 6
	BlankMissile
	MediumGap
	TrailingMissile
	MediumGap
	TrailingMissile
MP_7:  ; byte		; Player NUSIZ = 7
	WideBlankPlayer
P0_RegularTable:  ; dword
P1_RegularTable:  ; dword
	dd	P_0
	dd	P_1
	dd	P_2
	dd	P_3
	dd	P_4
	dd	P_5
	dd	P_6
	dd	P_7
P0_SizeTable:  ; byte
P1_SizeTable:  ; byte
	db	P_0_Size
	db	P_1_Size
	db	P_2_Size
	db	P_3_Size
	db	P_4_Size
	db	P_5_Size
	db	P_6_Size
	db	P_7_Size
M0_RegularTable:  ; dword
M1_RegularTable:  ; dword
	dd	M_0
	dd	M_1
	dd	M_2
	dd	M_3
	dd	M_4
	dd	M_5
	dd	M_6
	dd	M_7
M0_SizeTable:  ; byte
M1_SizeTable:  ; byte
	db	M_0_Size
	db	M_1_Size
	db	M_2_Size
	db	M_3_Size
	db	M_4_Size
	db	M_5_Size
	db	M_6_Size
	db	M_7_Size
P0_MultipleTable:  ; dword
P1_MultipleTable:  ; dword
	dd	MP_0
	dd	MP_1
	dd	MP_2
	dd	MP_3
	dd	MP_4
	dd	MP_5
	dd	MP_6
	dd	MP_7
M0_MultipleTable:  ; dword
M1_MultipleTable:  ; dword
	dd	MM_0
	dd	MM_1
	dd	MM_2
	dd	MM_3
	dd	MM_4
	dd	MM_5
	dd	MM_6
	dd	MM_7

M4 equ 0 	 ;  I'm not actually sure if this should be zero or -4.
DeepHMOVE:  ; byte
; 0
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-7,-7,-7,-7,-7,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-7,-7,-7,-7,-7,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 5, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; 1
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 8,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 7, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 5, 5, 5, 5, 5,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; 2
 db 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 8, 8,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 7, 7, 7,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; 3
 db 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0,10,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 9, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 8, 8, 8,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 7, 7, 7, 7, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 6, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; 4
 db 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0,11,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0,10,10,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 9, 9, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 8, 8, 8, 8, 8,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 7, 7, 7, 7, 7, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 6, 6, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; 5
 db 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0,12,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0,11,11,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0,10,10,10,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 9, 9, 9, 9, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 8, 8, 8, 8, 8, 8,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 7, 7, 7, 7, 7, 7, 7,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0, 6, 6, 6, 6, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; 6
 db 0,0,0,0,0,0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0,13,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0,12,12,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0,11,11,11,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0,10,10,10,10,10,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 9, 9, 9, 9, 9, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 8, 8, 8, 8, 8, 8, 8,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0, 7, 7, 7, 7, 7, 7, 7, 7, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0,0,0	 ;  f
; 7
 db 0,0,0,0,0,0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,99,99,M4, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0,14,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0,13,13,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0,12,12,12,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0,11,11,11,11,11,99,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0,10,10,10,10,10,10,99,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 9, 9, 9, 9, 9, 9, 9,99,99,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0, 8, 8, 8, 8, 8, 8, 8, 8, 8,99,99,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0,0,0	 ;  f
; 8
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; 9
 db 0,0,0,0,0,0,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0,-10,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-11,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-12,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-13,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-14,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-14,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; a
 db 0,0,0,0,0,0,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-10,-10,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-11,-11,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-12,-12,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-13,-13,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-13,-13,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; b
 db 0,0,0,0,0,0,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-9,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-10,-10,-10,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-11,-11,-11,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-12,-12,-12,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-12,-12,-12,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 2,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; c
 db 0,0,0,0,0,0,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-8,-8,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-9,-9,-9,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-10,-10,-10,-10,-10,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-11,-11,-11,-11,-11,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-11,-11,-11,-11,-11,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 1, 1, 1,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; d
 db 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-7,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-8,-8,-8,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-9,-9,-9,-9,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-10,-10,-10,-10,-10,-10,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-10,-10,-10,-10,-10,-10,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; e
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-7,-7,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-8,-8,-8,-8,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-9,-9,-9,-9,-9,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-9,-9,-9,-9,-9,-9,-9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 5,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 4, 4,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 2, 2, 2, 2, 2,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f
; f
 db 0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  0
 db 0,0,0,0,0,0,-2,-2,-2,-2,-2,-2,-2,-2,-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  1
 db 0,0,0,0,0,0,-3,-3,-3,-3,-3,-3,-3,-3,-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  2
 db 0,0,0,0,0,0,-4,-4,-4,-4,-4,-4,-4,-4,-4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  3
 db 0,0,0,0,0,0,-5,-5,-5,-5,-5,-5,-5,-5,-5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  4
 db 0,0,0,0,0,0,-6,-6,-6,-6,-6,-6,-6,-6,-6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  5
 db 0,0,0,0,0,0,-7,-7,-7,-7,-7,-7,-7,-7,-7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  6
 db 0,0,0,0,0,0,-8,-8,-8,-8,-8,-8,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  7
 db 0,0,0,0,0,0,-8,-8,-8,-8,-8,-8,-8,-8,-8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  8
 db 0,0,0,0,0,0, 6,99,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  9
 db 0,0,0,0,0,0, 5, 5,99,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  a
 db 0,0,0,0,0,0, 4, 4, 4,99,99,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  b
 db 0,0,0,0,0,0, 3, 3, 3, 3, 3,99,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  c
 db 0,0,0,0,0,0, 2, 2, 2, 2, 2, 2,99,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  d
 db 0,0,0,0,0,0, 1, 1, 1, 1, 1, 1, 1,99,99,M4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  e
 db 0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0	 ;  f


;;; end merge of tiatab.asm

;;; merged: 	include tiawrite.asm		; (32) handle writes to TIA registers
; new TIA write handlers

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 3-12-1999 -- break ground
; 09-07-02 -- 32-bit

[section .data]
TIARegHandler:  ; dword

	dd	H_VSYNC		 ;  00 -- VSYNC
	dd	H_VBLANK		 ;  01 -- VBLANK
	dd	H_WSYNC		 ;  02 -- WSYNC
	dd	H_Null		 ;  03 -- reset horizontal sync
					 ; 	  for factory testing only !

	dd	H_NUSIZ0		 ;  04 -- NUSIZ0
	dd	H_NUSIZ1		 ;  05 -- NUSIZ1
	dd	H_COLUP0		 ;  06 -- COLUP0
	dd	H_COLUP1		 ;  07 -- COLUP1
	dd	H_COLUPF		 ;  08 -- COLUPF
	dd	H_COLUBK		 ;  09 -- COLUBK
	dd	H_CTRLPF		 ;  0a -- CTRLPF
	dd	H_REFP0		 ;  0b -- REFP0
	dd	H_REFP1		 ;  0c -- REFP1
	dd	H_PF			 ;  0d -- PF0
	dd	H_PF			 ;  0e -- PF1
	dd	H_PF			 ;  0f -- PF2
	dd	H_RESP0		 ;  10 -- RESP0
	dd	H_RESP1		 ;  11 -- RESP1
	dd	H_RESM0		 ;  12 -- RESM0
	dd	H_RESM1		 ;  13 -- RESM1
	dd	H_RESBL		 ;  14 -- RESBL
	dd	H_AUDC0		 ;  15 -- AUDC0
	dd	H_AUDC1		 ;  16 -- AUDC1
	dd	H_AUDF0		 ;  17 -- AUDF0
	dd	H_AUDF1		 ;  18 -- AUDF1
	dd	H_AUDV0		 ;  19 -- AUDV0
	dd	H_AUDV1		 ;  1a -- AUDV1
	dd	H_GRP0		 ;  1b -- GRP0
	dd	H_GRP1		 ;  1c -- GRP1
	dd	H_ENAM0		 ;  1d -- ENAM0
	dd	H_ENAM1		 ;  1e -- ENAM1
	dd	H_ENABL		 ;  1f -- ENABL
	dd	H_HMP0		 ;  20 -- HMP0
	dd	H_HMP1		 ;  21 -- HMP1
	dd	H_HMM0		 ;  22 -- HMM0
	dd	H_HMM1		 ;  23 -- HMM1
	dd	H_HMBL		 ;  24 -- HMBL
	dd	H_VDELP0		 ;  25 -- VDELP0
	dd	H_VDELP1		 ;  26 -- VDELP1
	dd	H_VDELBL		 ;  27 -- VDELBL
	dd	H_RESMP0		 ;  28 -- RESMP0
 	dd	H_RESMP1		 ;  29 -- RESMP1
	dd	H_HMOVE		 ;  2a -- HMOVE
	dd	H_HMCLR		 ;  2b -- HMCLR
	dd	H_CXCLR		 ;  2c -- CXCLR

	dd	H_Null		 ;  2d -- these registers are undefined
	dd	H_Null		 ;  2e
	dd	H_Null		 ;  2f
	dd	H_Null		 ;  30
	dd	H_Null		 ;  31
	dd	H_Null		 ;  32
	dd	H_Null		 ;  33
	dd	H_Null		 ;  34
	dd	H_Null		 ;  35
	dd	H_Null		 ;  36
	dd	H_Null		 ;  37
	dd	H_Null		 ;  38
	dd	H_Null		 ;  39
	dd	H_Null		 ;  3a
	dd	H_Null		 ;  3b
	dd	H_Null		 ;  3c
	dd	H_Null		 ;  3d
	dd	H_Null		 ;  3e
	dd	H_Null		 ;  3f

	dd	H_Null

PFDelay db	4, 3, 2, 5	 ;  delays for writes to PF registers
BallSize:  ; byte
	db	10000000b
	db	11000000b
	db	11110000b
	db	11111111b
TIAReflect8:  ; byte
 db 0,128,64,192,32,160,96,224,16,144,80,208,48,176,112,240
 db 8,136,72,200,40,168,104,232,24,152,88,216,56,184,120,248
 db 4,132,68,196,36,164,100,228,20,148,84,212,52,180,116,244
 db 12,140,76,204,44,172,108,236,28,156,92,220,60,188,124,252
 db 2,130,66,194,34,162,98,226,18,146,82,210,50,178,114,242
 db 10,138,74,202,42,170,106,234,26,154,90,218,58,186,122,250
 db 6,134,70,198,38,166,102,230,22,150,86,214,54,182,118,246
 db 14,142,78,206,46,174,110,238,30,158,94,222,62,190,126,254
 db 1,129,65,193,33,161,97,225,17,145,81,209,49,177,113,241
 db 9,137,73,201,41,169,105,233,25,153,89,217,57,185,121,249
 db 5,133,69,197,37,165,101,229,21,149,85,213,53,181,117,245
 db 13,141,77,205,45,173,109,237,29,157,93,221,61,189,125,253
 db 3,131,67,195,35,163,99,227,19,147,83,211,51,179,115,243
 db 11,139,75,203,43,171,107,235,27,155,91,219,59,187,123,251
 db 7,135,71,199,39,167,103,231,23,151,87,215,55,183,119,247
 db 15,143,79,207,47,175,111,239,31,159,95,223,63,191,127,255
WeirdRespCorrection:  ; dword
 dd   0,  0,  0,  0,  0,  0,  1,  2,  2,  3
 dd   4,  5,  5,  6,  7,  8,  8,  9, 10, 11
 dd  11, 12, 13, 14, 14, 15

TempCFirst	dd	0


[section .code]


;*
;* blank the remainder of the display each frame
;*

TIABlank:
	pushad
	xor	eax,eax
 	mov	edi,dword [DisplayPointer]
	cmp	edi,15000
	jb near TIABRet
 	mov	ebx,dword [MaxLines]
	imul	ebx,160
TIABLoop:
	cmp	edi,ebx			 ;  reached end of display area?
	jae near TIABRet			 ;    yes, done
 	;gs_store  [edi],eax
	mov dword [edi], eax
	add	edi,4
	jmp	TIABLoop

TIABRet:
 	mov	dword [DisplayPointer],edi
	popad
	ret

;*
;* deep motion tracing macro
;*

;;; converted macro:
%macro CheckDeep 0
; local ; NotDeep, IsDeep, VeryDeep
%ifdef showdeep
 	test	byte [TraceCount],4
	jz near %%NotDeep

 	cmp	byte [RClock],25
	ja near %%NotDeep
 	cmp	byte [HMOVE_Cycle],0
	jne near %%IsDeep
 	cmp	byte [Last_HMOVE_Cycle],54
	ja near %%IsDeep
	jmp	%%NotDeep

%%IsDeep:
 	cmp	byte [HMOVE_Cycle],3
	jne near %%VeryDeep

	pushad
 	movzx	edx,byte [RClock]
	push	edx
 	movzx	edx,byte [TIA+esi]
	and	edx,0fh
	push	edx
 	mov	dl,byte [WByte]
	sar	dl,4
	movzx	edx,dl
	and	edx,0fh
	push	edx
	call	ShowDeep
	pop	edx
	pop	edx
	pop	edx
	popad

	jmp	%%NotDeep

%%VeryDeep:
	pushad
 	movzx	edx,byte [RClock]
	push	edx
 	movzx	edx,byte [TIA+esi]
	and	edx,0fh
	push	edx
 	mov	dl,byte [WByte]
	sar	dl,4
	movzx	edx,dl
	and	edx,0fh
	push	edx
	call	Show%%VeryDeep
	pop	edx
	pop	edx
	pop	edx
	popad

%%NotDeep:
%endif
%endmacro


;*
;* weird motion tracing macro
;*

;;; converted macro:
%macro CheckWeird 0
; local ; NotWeird
%ifdef showdeep
 	test	byte [TraceCount],2
	jz near %%NotWeird

 	cmp	byte [RClock],3
	je near %%NotWeird

	pushad
 	movzx	edx,byte [RClock]
	push	edx
	call	ShowWeird
	pop	edx
	popad

%%NotWeird:
%endif
%endmacro


;*
;* This is the TIA write handler.
;*
;* on entry:
;*
;*	si =	  TIA register to write to
;*	[WByte] = value to write
;*

NewTIA:	
	SaveCPUState
	and	esi,03fh
	call	VecTIA		 ;  call the write handler
	RestoreCPUState
	ret

VecTIA:
 	jmp	dword [TIARegHandler + esi*4]


;*
;* WSYNC -- wait for horizontal sync
;*

H_WSYNC:
 	cmp	byte [RClock],CYCLESPERSCANLINE ; did WSYNC come after end of line?
	ja near SetSkip				 ;    yes, skip a line (** check this **)

WsyncSimple:
	mov	edx,CYCLESPERSCANLINE
 	sub	dl,byte [RClock]
 	sub	dword dword [Timer],edx ; clock RIOT
 	mov	byte [RClock],CYCLESPERSCANLINE ; and CPU clock
	ret

SetSkip:
	mov	edx,2*CYCLESPERSCANLINE		 ;  skipping a line, bigger adjustment
 	sub	dl,byte [RClock]
 	sub	dword dword [Timer],edx ; clock RIOT
 	mov	byte [RClock],2*CYCLESPERSCANLINE ; and CPU clock
	ret

;*
;* VSYNC -- vertical sync set-clear
;*

H_VSYNC:
 	test	byte [WByte],2 ; if d1 is set then ....
	jz near ZRET
 	test	byte [VSyncFlag],2 ; somebody hitting Vsync more than necessary?
	jnz near VSyncAlreadySet		 ; 	  yep

 	mov	edx,dword [LinesInFrame]
 	mov	dword [PrevLinesInFrame],edx
 	mov	edx,dword [ScanLine]
 	mov	dword [LinesInFrame],edx ; *EST*
 	dec	dword [LinesInFrame]

DontUpdateLinesInFrame:
 	mov	dword [LooseColour],0ffffffffh
;	cmp	[PaletteNumber],1	; PAL palette?
;	jne near GrayFrame		;   no, don't simulate color loss
 	test	byte [SimColourLoss],1
	jz near GrayFrame
 	test	dword [LinesInFrame],1
	jz near GrayFrame
 	mov	dword [LooseColour],007070707h ; see tialine.asm
GrayFrame:
 	mov	dword [ScanLine],1 ; back to screen top

	cmp	edx,5			 ;  a quick double hit (pickpile)?
	jb near VSyncAlreadySet		 ; 	 yes, no new frame
 	inc	dword [Frame] ; new frame.

;*
;* automatic adjustment of game position (and video mode)
;*

 	mov	edx,dword [CFirst]
 	mov	dword [TempCFirst],edx ; to see how much we're changing by

 	cmp	dword [Frame],5
	je near AdjustUnstable		 ;  force adjustment of unstable games (pickpile)

 	mov	edx,dword [LinesInFrame]
 	cmp	edx,dword [PrevLinesInFrame]
	jne near AlreadyInPALMode	 ;  don't change video mode if not matching previous frame (quadrun)

 	test	byte [IOPortB],1 ; reset being pressed?
	jz near VSyncAlreadySet		 ; 	 yes, don't adjust

AdjustUnstable:
 	cmp	dword [LinesInFrame],282 ; NTSC game? (pharhcrs 296 when fire button pressed ...
					 ; 		    (... air_raid 292, zoofun 291, dumbo 286, curtiss 286,
					 ; 		    (... tps 285, galaga 282, tomboy 277)
	jb near AlreadyInPALMode	 ; 	 yes

 	cmp	byte [PaletteNumber],1 ; PAL mode already ?
	jz near AlreadyInPALMode	 ; 	 yes
 	cmp	byte [UserPaletteNumber],0ffh ; is there a palette override?
	jnz near AlreadyInPALMode	 ; 	  yes, don't switch

 	test	dword [Frame],0ffffff00h ; more than 256 frames passed?
	jnz near AlreadyInPALMode	 ;     yes, don't change TV type *EST*

 	mov	byte [PaletteNumber],1 ; set up PAL palette
	pushad
        call    position_game            ;  adjust starting line for PAL/NTSC
        call	srv_SetPalette		 ;  reset video mode for PAL games
	popad

AlreadyInPALMode:
 	cmp	dword [LinesInFrame],512 ; game ridiculously large?
	ja near VSyncAlreadySet		 ; 	 yes, no automatic adjustment
 	cmp	dword [LinesInFrame],220 ; game ridiculously small?
	ja near GameSizeOK		 ;    no
 	cmp	dword [BailoutLine],512 ; maybe BailoutLine is too small -- too big already?
	ja near GameSizeOK
 	mov	edx,dword [LinesInFrame]
	add	edx,4			 ;  match offset to below (aciddrop)
 	add	dword [BailoutLine],edx
	jmp	BailoutSet

GameSizeOK:
 	mov	edx,dword [LinesInFrame]
 	cmp	edx,dword [PrevLinesInFrame]
	jne near BailoutSet		 ;  don't reset BailoutLine if not matching previous frame (quadrun)
	add	edx,4			 ;  minimum 6 is needed for aciddrop or it flashes
 	mov	dword [BailoutLine],edx

BailoutSet:

VSyncAlreadySet:
 	mov	edx,dword [CFirst]
	cmp	edx,0			 ;  forcing first line ?
	jz near ZRET			 ;    no, let vblank take care of it

	call	TIABlank

DontBlank:
 	mov	dword [TopLine],edx
 	add	edx,dword [MaxLines]
 	mov	dword [BottomLine],edx
ZRET: mov	dl,byte [WByte]
 	mov	byte [VSyncFlag],dl	
 	Ret

;*
;* VBLANK -- vertical blank set-clear
;*

H_VBLANK:
	SaveCPUState
	mov	dl,1			 ;  VBlank delayed by 1 pixel
	call	CatchUpPixels		 ;  render pixels up to the write clock
	RestoreCPUState

 	mov	dl,byte [WByte]
 	mov	byte [VBlank],dl
	test	dl,2			 ;  setting or clearing ?
	jz near WVBClear		 ; 	  clearing

 	mov	edx,dword [ScanLine]
	cmp	edx,200
	jb near VBOnAlreadySet
 	mov	dword [VBlankOn],edx

VBOnAlreadySet:
 	cmp	dword [CFirst],0 ; VBlank triggering new frame ?
	je near WTB_1			 ; 	yes, don't mess with VBlanking
 	mov	dword [VBlanking],0
	jmp	HandleDumpedInputs

WTB_1:
 	mov	dword [TopLine],65535 ; setting -- turn off Tia
	call	TIABlank		 ;  clear rest of screen
	jmp	HandleDumpedInputs

WVBClear:
 	mov	edx,dword [ScanLine]
 	cmp	byte [PaletteNumber],1 ; NTSC game?
	jnz near DoNTSCTest		 ;    yes
	cmp	edx,78			 ;  allow penguin vblank
	ja near VBOffAlreadySet
 	mov	dword [VBlankOff],edx
	jmp	VBOffAlreadySet

DoNTSCTest:
	cmp	edx,58			 ;  allow brickick vblank
	ja near VBOffAlreadySet
 	mov	dword [VBlankOff],edx

VBOffAlreadySet:
 	cmp	dword [CFirst],0 ; VBlank triggering new frame ?
	je near WTB_2			 ; 	yes, don't mess with VBlanking
 	mov	dword [VBlanking],-1
	jmp	HandleDumpedInputs

WTB_2:
 	mov	edx,dword [ScanLine]
 	cmp	edx,dword [CFirst]
	jae near WVBPastMin
 	mov	edx,dword [CFirst]
WVBPastMin:
	inc	edx
 	mov	dword [TopLine],edx
 	add	edx,dword [MaxLines]
 	mov	dword [BottomLine],edx
	jmp	HandleDumpedInputs	 


HandleDumpedInputs:
 	test	byte [VBlank],080h ; discharging capacitors ?
	jz near HandleLatchedInputs	 ;    no
 	mov	dword dword [ChargeCounter],0 ; yes, zero the line counter

HandleLatchedInputs:
	ret




;*
;* some support code for TIA registers
;*

;*
;* get object position into bx
;*

[section .code]

;;; converted macro:
%macro PositionObject 1
; local ; HBLnowrap, HBLdone, HBLnotweird, HBLinrange, HBLhandle78

 	movzx	ebx,byte [RClock]
	sub	ebx,CYCLESPERSCANLINE  ;  beyond end of scanline?
	jb near %%HBLnowrap  ;  no
%%HBLnotweird:
 	lea	ebx, [ebx+ebx*2]
	cmp	bl,67  ;  positioned in HBLANK area?
	ja near %%HBLdone  ;  no
	mov	bl,226
	jmp	%%HBLdone

%%HBLnowrap:
	add	ebx,CYCLESPERSCANLINE

 	cmp	byte [HMOVE_Cycle],3 ; HMOVE happening?
	jne near %%HBLnotweird  ;  no

	cmp	bl,24  ;  affected by weirdness?
	ja near %%HBLnotweird  ;  no
 	mov	ebx,dword [WeirdRespCorrection+4*ebx]
 	sub	ebx,dword [%1_Motion]
	add	ebx,226
	cmp	ebx,234
	jbe near %%HBLinrange
	mov	ebx,234
%%HBLinrange:	
	cmp	ebx,228
	jb near %%HBLdone
	sub	ebx,160

%%HBLdone:
%endmacro


;*
;* object rendering macros
;*
;* they should OR their respective bits into BL
;* AX, DL and SI are free registers that these routines can use
;*


;*
;* table update support macro
;*

;;; converted macro:
%macro UpdateTable 1
; local ; regular_ok

 	movzx	esi,byte [TIA+NUSIZ%1]
	and	esi,7
 	movzx	edx,byte [%1_SizeTable+esi]
 	mov	dword [%1_Size],edx
 	mov	edx,dword [%1_RegularTable+esi*4] ; assume regular table
 	cmp	byte [%1_TripleFlag],0 ;;; GUESSED dword, changed to byte
	jnz near %%regular_ok
 	mov	edx,dword [%1_MultipleTable+esi*4] ; use multiple table

%%regular_ok:
 	mov	dword [%1_Table],edx
%endmacro



;;; converted macro:
%macro SetObjectBit 1
; local ; done, nowrap

	movzx	esi,cl
 	sub	esi,dword [%1_Position]
	jae near %%nowrap
	add	esi,160
%%nowrap:	
 	cmp	esi,dword [%1_Size]
	ja near %%done
	add	esi,esi  ;  index into table
	AddTablePointer  %1
 	mov	al,byte [%1_Graphics]
 	test	al,[esi]
	jz near %%done
	or	bl,%1_BIT
%%done:
%endmacro


;*
;* get dl = object delay
;*     al = triple flag
;*     bx = object position
;*

;;; converted macro:
%macro GetObjectDelay 1
; local ; done, nowrap

	PositionObject  %1
	mov	esi,ebx

	xor	dl,dl  ;  assume delay 0
	xor	al,al  ;  assume no triple flag

 	sub	esi,dword [%1_Position] ; where the object is
	jae near %%nowrap
	add	esi,160			
%%nowrap:	
 	cmp	esi,dword [%1_Size] ; beyond it's size?
	ja near %%done  ;  yes, no delay
	add	esi,esi  ;  index into table
	inc	esi  ;  point at delay byte
	AddTablePointer  %1
 	mov	dl,byte [esi] ; get delay byte
	test	dl,080h  ;  triple flag set?
	setnz	al  ;  set al if so
	and	dl,07fh  ;  delay value
%%done:
%endmacro




;*
;* Object activation/deactivation
;*
;* bit to activate/deactivate in al
;*

;;; converted macro:
%macro ActivateObject 1
 	or	dword [ActiveObjects],%1
%endmacro


;;; converted macro:
%macro DeactivateObject 1
 	and	dword [ActiveObjects], ~%1
%endmacro



;*
;* update playfield color
;*
;* call before every pixel run (lots of things can affect PF color)
;*

doUpdatePlayfieldColor:
 	mov	dl,byte [TIA+COLUPF]
	mov	dh,dl			 ;  16-bit playfield color
	shl	edx,8
	mov	dl,dh
	shl	edx,8
	mov	dl,dh			 ;  32-bit playfield color
 	mov	dword [BL_Color],edx ; ball is always this color
 	mov	dword [PF_Color],edx ; assume *normal* state of affairs

	mov	edx, TIADisplayToColour
 	test	byte [TIA+CTRLPF],PFP ; does playfield have priority?
	jz near UPFC_CheckScore		 ; 	 no
	mov	edx, TIADisplayToColour2
 	mov	dword [PixelColorTable],edx ; yes, update pixel to color translation table
	jmp	UPFC_done		 ;  don't pay attention to score mode...

UPFC_CheckScore:
 	mov	dword [PixelColorTable],edx ; update pixel to color translation table
 	test	byte [TIA+CTRLPF],SCORE ; in score mode?
	jz near UPFC_done		 ;    no
 	mov	edx,dword [P0_Color] ; assume Player 0 color
	cmp	cl,147			 ;  right side of playfield?
	jbe near UPFC_SetReg		 ;    no
 	mov	edx,dword [P1_Color] ; yes, use Player 1 color
UPFC_SetReg:
 	mov	dword [PF_Color],edx ; update the register

UPFC_done:
	ret


;;; converted macro:
%macro UpdatePlayfieldColor 0
	call	doUpdatePlayfieldColor
%endmacro



;*
;* update playfield reflection
;*
;* call at mid-line, and when CTRLPF is updated
;*

;;; converted macro:
%macro UpdatePlayfieldReflection 0
; local ; UPFR_Ret

 	mov	dword [PF_Table], PFClockToBitForward
 	test	byte [TIA+CTRLPF],REF ; playfield reflected?
	jz near %%UPFR_Ret  ;  no
 	mov	dword [PF_Table], PFClockToBitReversed
%%UPFR_Ret:

%endmacro



;*
;* update ball graphics
;*

UpdateBallGraphics:
	
 	mov	dl,byte [TIA+ENABL] ; assume regular ball
 	test	byte [TIA+VDELBL],1 ; using delayed register?
	jz near UBGtestball		 ;    no
 	mov	dl,byte [BL_Delayed] ; yes, use delayed ball

UBGtestball:
	test	dl,2			 ;  ball turned on?
	jz near UBGnoball		 ;    no
	ActivateObject  BL_BIT ;    yes, ActivateObject
	mov	dl,030h			 ;  mask ball size
 	and	dl,byte [TIA+CTRLPF]
	movzx	esi,dl
	shr	esi,4
 	mov	dl,byte [BallSize + esi] ; look up in table
 	mov	byte [BL_Graphics],dl ; set graphics register
	ret


UBGnoball:
	DeactivateObject  BL_BIT ;  no ball, DeactivateObject
 	mov	byte [BL_Graphics],0 ;;; GUESSED dword (changed to byte) ; clear the graphics register

	ret


;*
;* player graphics support macro
;*

;;; converted macro:
%macro UpdatePlayerGraphics 1
; local ; UPnodelay, UPdone

 	mov	dl,byte [TIA+GR%1] ; assume regular graphics
 	test	byte [TIA+VDEL%1],1 ; using delayed register?
	jz near %%UPnodelay  ;  no
 	mov	dl,byte [%1_Delayed] ; yes, use delayed graphics
%%UPnodelay:
	DeactivateObject  %1_BIT ;  assume not active
	test	dl,dl  ;  graphics active?
	jz near %%UPdone  ;  no, done
	ActivateObject  %1_BIT ;  yes, ActivateObject
 	test	byte [TIA+REF%1],08h ; reflected?
	jz near %%UPdone  ;  no
	movzx	esi,dl  ;  yes
 	mov	dl,byte [TIAReflect8+esi] ; reflect it
%%UPdone:
 	mov	byte [%1_Graphics],dl ; update register
%endmacro



;*
;* update P0 graphics
;*

UpdateP0Graphics:

	UpdatePlayerGraphics  P0

	ret


;*
;* update P1 graphics
;*

UpdateP1Graphics:

	UpdatePlayerGraphics  P1

	ret

;*
;* missile graphics support macro
;*

RESM0P equ RESMP0 
RESM1P equ RESMP1 

;;; converted macro:
%macro UpdateMissileGraphics 1
; local ; noMissile

	DeactivateObject  %1_BIT ;  assume inactive
 	mov	byte [%1_Graphics],0 ;;; GUESSED dword  (changed to byte); clear register
 	test	byte [TIA+RES%1P],2 ; missile locked to player?
	jnz near %%noMissile  ;  yes, no missile
 	test	byte [TIA+ENA%1],2 ; missile enabled?
	jz near %%noMissile  ;  no
	ActivateObject  %1_BIT ;  yes, ActivateObject
 	movzx	esi,byte [TIA+NUSIZ%1] ; size is here
	and	esi,030h  ;  mask size bits
	shr	esi,4
 	mov	dl,byte [BallSize + esi] ; look up in table
 	mov	byte [%1_Graphics],dl ; update register
%%noMissile:
%endmacro



;*
;* update M0 graphics
;*

UpdateM0Graphics:

	UpdateMissileGraphics  M0

	ret

;*
;* update M1 graphics
;*

UpdateM1Graphics:

	UpdateMissileGraphics  M1

	ret

;*
;* update P0 Table
;*

UpdateP0Table:

	UpdateTable  P0

	ret

;*
;* update P1 Table
;*

UpdateP1Table:

	UpdateTable  P1

	ret

;*
;* update M0 Table
;*

UpdateM0Table:

	UpdateTable  M0

	ret

;*
;* update M1 Table
;*

UpdateM1Table:

	UpdateTable  M1

	ret

;*
;* set up multi-sprite trick
;* call at beginning of each scanline
;*

SetupMultiSpriteTrick:
 	cmp	byte [M0_TripleFlag],1 ;;; GUESSED dword, changed to byte
	je near SMS_M1
 	mov	byte [M0_TripleFlag],1 ;;; GUESSED dword, changed to byte
	call	UpdateM0Table

SMS_M1: cmp	byte [M1_TripleFlag],1 ;;; GUESSED dword, changed to byte
	je near SMS_P0
 	mov	byte [M1_TripleFlag],1 ;;; GUESSED dword, changed to byte
	call	UpdateM1Table

SMS_P0: cmp	dword [P0_TripleFlag],1 ;;; GUESSED dword, changed to byte
	je near SMS_P1
 	mov	byte [P0_TripleFlag],1 ;;; GUESSED dword, changed to byte
	call	UpdateP0Table

SMS_P1: cmp	dword [P1_TripleFlag],1 ;;; GUESSED dword, changed to byte
	je near SMS_done
 	mov	byte [P1_TripleFlag],1 ;;; GUESSED dword, changed to byte
	call	UpdateP1Table

SMS_done:	
	ret


;*
;* missile locking support macro
;*

[section .data]
MissileOffset db 5, 5, 5, 5, 5, 8, 5, 12
[section .code]

;;; converted macro:
%macro LockMissile 2
; local ; nowrap

	push	esi
 	movzx	esi,byte [TIA+NUSIZ%1]
	and	esi,7
 	movzx	edx,byte [MissileOffset+esi]
	pop	esi

 	add	edx,dword [%2_Position]
	cmp	edx,227
	jbe near %%nowrap
	sub	edx,160
%%nowrap:
 	mov	byte [TIA+RES%1],dl
 	mov	dword [%1_Position],edx

%endmacro


;*
;* update M0 locking
;*

UpdateM0Locking:
 	test	byte [TIA+RESMP0],2
	jz near M0nolock

	LockMissile  M0,  P0

M0nolock:
	ret

;*
;* update M1 locking
;*

UpdateM1Locking:
 	test	byte [TIA+RESMP1],2
	jz near M1nolock

	LockMissile  M1,  P1

M1nolock:
	ret

;*
;* a do nothing TIA register write
;*

H_Null:	ret				 ;  a null TIA register write


;*
;* color setting support macro
;*

;;; converted macro:
%macro SetColor 1
	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
	shr	dl,1  ;  pre shift right 1 bit
 	mov	byte [TIA+COLU%1],dl ; update the register
	mov	dh,dl
	shl	edx,8
	mov	dl,dh
	shl	edx,8
	mov	dl,dh

%endmacro


;*
;* a TIA color register write
;*

H_COLUP0:
	SetColor  P0
 	mov	dword [P0_Color],edx

	ret

H_COLUP1:
	SetColor  P1
 	mov	dword [P1_Color],edx

	ret

H_COLUBK:
	SetColor  BK
 	mov	dword [BK_Color],edx	

	ret

H_COLUPF:
	SetColor  PF

	ret


;*
;* CTRLPF write
;*

H_CTRLPF:
	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+CTRLPF],dl

HCPFdone:
	call	UpdateBallGraphics
	ret

;*
;* a TIA playfield bit write
;*
;* Delays are set to make sure all 4 pixels of a playfield bit go 
;* out unchanged even if the write occurs in middle of 4 bit group.
;* Plus there is additional delay if write occurs on last pixel 
;* of a 4 bit group.  The next group uses the old value.
;*

H_PF:
 	mov	bl,byte [RClock]
	add	bl,bl
 	add	bl,byte [RClock] ; write occurred here

	and	ebx,3
 	mov	dl,byte [PFDelay+ebx] ; render this far into the future

	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+esi],dl ; update the register

	DeactivateObject  PF_BIT
 	test	dword byte [TIA+PF0],0ffffffh ; test playfield bits
	jz near H_PFRet
	ActivateObject  PF_BIT

H_PFRet:
	ret

;*
;* horizontal motion support macro
;*

;;; converted macro:
%macro DoMotion 1
; local ; positive, done

 	mov	edx,dword [%1_Motion]
 	sub	dword [%1_Position],edx
 	cmp	dword [%1_Position],68 ;;; GUESSED dword, looks OK
	jae near %%positive
 	add	dword [%1_Position],160 ;;; GUESSED dword, looks OK
	jmp	%%done

%%positive:
 	cmp	dword [%1_Position],228 ;;; GUESSED dword, looks OK
	jb near %%done
 	sub	dword [%1_Position],160 ;;; GUESSED dword, looks OK
%%done:
%endmacro


;*
;* HMOVE
;*

;*
;* this could be called at beginning of a scanline
;* but it's called at register write time
;*

doHMOVE:
 	cmp	byte [HMOVE_Pending],0
	jz near noHMOVE

	DoMotion  P0
	DoMotion  P1
	DoMotion  M0
	DoMotion  M1
	DoMotion  BL

	call	UpdateM0Locking
	call	UpdateM1Locking

 	mov	byte [HMOVE_Pending],0

noHMOVE:
	ret

;*
;* macro to set up amount of motion for HMOVES near beginning of scan line
;*

[section .data]
MaxMotion:  ; byte
 db   7,  7,  7,  7,  6,  5,  5,  4,  3,  2
 db   2,  1,  0, -1, -1, -2, -3, -4, -4, -5
 db  -6

[section .code]

;;; converted macro:
%macro FixupMotionLow 1
; local ; MotionOK

 	movsx	edx,byte [TIA+HM%1]
	push	ebx
 	movzx	ebx,byte [RClock]
 	movsx	ebx,byte [MaxMotion+ebx]
	cmp	edx,ebx
	jl near %%MotionOK
	mov	edx,ebx
 	mov	dword [%1_Motion],edx
%%MotionOK:
	pop	ebx
%endmacro


;*
;* this is called at register write time
;*	

H_HMOVE:
	mov	dl,0
	call	CatchUpPixels

	CheckWeird
	
 	mov	dl,byte [RClock]
 	mov	byte [HMOVE_Cycle],dl ; remember where HMOVE was (cosmic)
 	cmp	byte [M0_Confused],0
	jz near WasntConfused

 	mov	byte [M0_Confused],0 ; HMOVE cancels confusion
	call	UpdateM0Graphics

WasntConfused:
 	movsx	edx,byte [TIA+HMP0] ; xx_Motion is different from HMxx
 	mov	dword [P0_Motion],edx ; in case we decide to doHMOVE 
 	movsx	edx,byte [TIA+HMP1] ; somewhere else
 	mov	dword [P1_Motion],edx
 	movsx	edx,byte [TIA+HMM0]
 	mov	dword [M0_Motion],edx
 	movsx	edx,byte [TIA+HMM1]
 	mov	dword [M1_Motion],edx
 	movsx	edx,byte [TIA+HMBL]
 	mov	dword [BL_Motion],edx

 	mov	byte [HMOVE_Pending],1 ; also in case we doHMOVE elsewhere

 	cmp	byte [RClock],20
	ja near HiBlank
 	cmp	byte [RClock],3
	jbe near LoBlank

DoBlank:
	FixupMotionLow  P0
	FixupMotionLow  P1
	FixupMotionLow  M0
	FixupMotionLow  M1
	FixupMotionLow  BL
LoBlank:
 	mov	byte [HBlanking],0 ; set up the HMOVE blank
	call	doHMOVE
	ret

HiBlank:
 	cmp	byte [RClock],54
	jbe near NoMotion
 	cmp	byte [RClock],74
	jbe near NoBlank
 	mov	byte [SetHBlanking],1

	call	doHMOVE
	ret	

[section .data]

HiTable db 14, 13, 12, 12, 11, 10, 9, 9, 8, 7, 6, 6, 5, 4, 3, 3, 2, 1, 0, 0

[section .code]

;;; converted macro:
%macro FixupMotionHi 1
; local ; SetMotion

 	movsx	edx,byte [TIA+HM%1]
	add	edx,8
	push	ebx
 	movzx	ebx,byte [RClock]
	sub	ebx,55
 	movsx	ebx,byte [HiTable+ebx]
	sub	edx,ebx
	cmp	edx,0
	jg near %%SetMotion
	mov	edx,0

%%SetMotion:
 	mov	dword [%1_Motion],edx
	pop	ebx
%endmacro




NoBlank:
	FixupMotionHi  P0
	FixupMotionHi  P1
	FixupMotionHi  M0
	FixupMotionHi  M1
	FixupMotionHi  BL

	call	doHMOVE
	ret

NoMotion:
	ret


;*
;* RESBL
;*


H_RESBL:
	GetObjectDelay  BL

;*
;* mind master cheat
;*

 	cmp	byte [Starpath],0 ; if you don't do this, the cheat breaks keystone.bin
	jz near RBL_goahead
	cmp	bl,69			 ;  other than that, you don't want to know...
	je near RBL_handle69
	cmp	bl,226
	jne near RBL_goahead

RBL_handle69:
 	cmp	byte [HMOVE_Cycle],5
	je near RBL_isweird
 	cmp	byte [HMOVE_Cycle],0
	jne near RBL_goahead
 	cmp	byte [Last_HMOVE_Cycle],78
	jne near RBL_goahead

RBL_isweird:
	mov	bl,74			 ;  if we're cheating, the ball lands here

;*
;* end of cheat
;*

RBL_goahead:
	push	ebx			 ;  save object position
	call	CatchUpPixels
	pop	ebx			 ;  restore object position

 	mov	byte [TIA+RESBL],bl
 	mov	dword [BL_Position],ebx

	ret


;*
;* a positioning cheat for Kool Aide
;*

;;; converted macro:
%macro CheatKoolAidePosition 3
; local ; done

 	cmp	byte [KoolAide],0 ; doing Kool Aide cheat?
	jz near %%done  ;  no
 	cmp	dword [ScanLine],%1
	jne near %%done
	cmp	ebx,%2+68-5
	jne near %%done

	mov	ebx,%3+68-5  ;  yes, do the cheat

%%done:
%endmacro



;*
;* RESP0
;*

H_RESP0:
	GetObjectDelay  P0
	push	ebx			 ;  save object position
 	mov	byte [P0_TripleFlag],al
	call	CatchUpPixels
	call	UpdateP0Table
	pop	ebx			 ;  restore object position

	CheatKoolAidePosition  40,  54,  52
	CheatKoolAidePosition  49,  63,  61

 	mov	byte [TIA+RESP0],bl
 	mov	dword [P0_Position],ebx

	call	UpdateM0Locking

	ret


;*
;* RESP1
;*

H_RESP1:
	GetObjectDelay  P1
	push	ebx			 ;  save object position
 	mov	byte [P1_TripleFlag],al
	call	CatchUpPixels
	call	UpdateP1Table
	pop	ebx			 ;  restore object position

	CheatKoolAidePosition  40,  63,  65
	CheatKoolAidePosition  49,  72,  74

 	mov	byte [TIA+RESP1],bl
 	mov	dword [P1_Position],ebx

	call	UpdateM1Locking

	ret

;*
;* RESM0
;*

H_RESM0:
 	test	byte [TIA+RESMP0],2 ; missile locked to player ?
	jnz near noRESM0			 ;    yes, don't position

	GetObjectDelay  M0
	push	ebx			 ;  save object position
 	mov	byte [M0_TripleFlag],al
	call	CatchUpPixels
	call	UpdateM0Table
	pop	ebx			 ;  restore object position

 	mov	byte [TIA+RESM0],bl
 	mov	dword [M0_Position],ebx

noRESM0:
	ret


;*
;* RESM1
;*

H_RESM1:
 	test	byte [TIA+RESMP1],2 ; missile locked to player ?
	jnz near noRESM1			 ;    yes, don't position

	GetObjectDelay  M1
	push	ebx			 ;  save object position
 	mov	byte [M1_TripleFlag],al
	call	CatchUpPixels
	call	UpdateM1Table
	pop	ebx			 ;  restore object position

 	mov	byte [TIA+RESM1],bl
 	mov	dword [M1_Position],ebx

noRESM1:
	ret


;*
;* ENABL
;*

H_ENABL:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+ENABL],dl

	call	UpdateBallGraphics
	ret


;*
;* ENAM0
;*

H_ENAM0:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+ENAM0],dl

	call	UpdateM0Graphics
	ret


;*
;* ENAM1
;*

H_ENAM1:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+ENAM1],dl

	call	UpdateM1Graphics
	ret

;*
;* macro to handle writes to NUSIZ register
;*

;;; converted macro:
%macro DoNUSIZ 1
; local ; NoCatchup, CatchupWide, NoCheat, done

	GetObjectDelay  M%1
	call	CatchUpPixels  ;  render any missile in progress
	
 	mov	dl,byte [TIA+NUSIZ%1]
	and	dl,7
	cmp	dl,7  ;  quad wide player?
	je near %%CatchupWide  ;  yes
	cmp	dl,5  ;  double wide player?
	je near %%CatchupWide  ;  yes

	GetObjectDelay  P%1 ;  no
	call	CatchUpPixels  ;  complete the player in progress
	jmp	%%NoCatchup

%%CatchupWide:
	GetObjectDelay  P%1
	test	dl,dl  ;  are we in the wide sprite?
	jz near %%NoCatchup  ;  no
	mov	dl,4  ;  (4 for sentinel)
	call	CatchUpPixels  ;  render a few trailing pixels

%%NoCatchup:
 	mov	dl,byte [WByte]
 	mov	byte [TIA+NUSIZ%1],dl ; switch to new NUSIZ

	call	UpdateM%1Graphics  ;  update things
	call	UpdateP%1Table
	call	UpdateM%1Table

 	mov	dl,byte [P%1_Graphics]
	push	edx  ;  save current player graphics
 	mov	byte [P%1_Graphics],0 ;;; GUESSED dword, changed to byte ; set to zero to render nothing
	GetObjectDelay  P%1
	test	dl,dl  ;  would table switch land us in a sprite?
	jz near %%done  ;  no

 	cmp	byte [RSBoxing],0 ; doing RSBOXING cheat?
	jz near %%NoCheat  ;  no
	sub	dl,2  ;  yes, don't render completely thru new sprite

%%NoCheat:
	call	CatchUpPixels  ;  yes, render nothing thru new sprite
  ;  (** messes up rsboxing a little bit -- too far into future **)
  ;  (** if I ever fix this right, it might fix PROWREST too **)

%%done:
	pop	edx
 	mov	byte [P%1_Graphics],dl ; restore player graphics
%endmacro



;*
;* NUSIZ0
;*

H_NUSIZ0:
	DoNUSIZ  0
	ret


;*
;* NUSIZ1
;*

H_NUSIZ1:
	DoNUSIZ  1
	ret


;*
;* VDELBL
;*

H_VDELBL:
	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+VDELBL],dl

	call	UpdateBallGraphics
	ret


;*
;* VDELP0
;*

H_VDELP0:
	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+VDELP0],dl

	call	UpdateP0Graphics
	ret


;*
;* VDELP1
;*

H_VDELP1:
	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+VDELP1],dl

	call	UpdateP1Graphics
	ret

;*
;* GRP0
;*

H_GRP0:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+GRP0],dl

 	mov	dl,byte [TIA+GRP1]
 	mov	byte [P1_Delayed],dl
	call	UpdateP0Graphics
	call	UpdateP1Graphics

	ret


;*
;* GRP1
;*

H_GRP1:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+GRP1],dl

 	mov	dl,byte [TIA+ENABL]
 	mov	byte [BL_Delayed],dl
 	mov	dl,byte [TIA+GRP0]
 	mov	byte [P0_Delayed],dl
	call	UpdateBallGraphics
	call	UpdateP0Graphics
	call	UpdateP1Graphics

	ret

;*
;* handle a non-M0 motion register
;*

;;; converted macro:
%macro HandleMotion 1
; local ; NormalMotion

	push	ebx

 	cmp	byte [HMOVE_Cycle],3
	jne near %%NormalMotion

 	cmp	byte [RClock],26
	jae near %%NormalMotion
 	movzx	ebx,byte [TIA+HM%1]
	and	ebx,0fh
	shl	ebx,4
 	movzx	edx,byte [WByte]
	shr	edx,4
	and	edx,0fh
	add	ebx,edx
	shl	ebx,5
 	movzx	edx,byte [RClock]
	and	edx,01fh
	add	ebx,edx
 	mov	dl,byte [DeepHMOVE + ebx]
	test	dl,dl
	jz near %%NormalMotion
	cmp	dl,99
	je near %%NormalMotion  ;  cosmic is normal for now
	movsx	edx,dl
	neg	edx
 	mov	dword [%1_Motion],edx
	DoMotion  %1
 	cmp	byte [TraceCount],0
	jz near %%NormalMotion

	pushad
	call	ShowAdjusted
	popad

%%NormalMotion:
 	mov	dl,byte [WByte]
	sar	dl,4  ;  pre-shift right 4 bits (preserve sign)
 	mov	byte [TIA+HM%1],dl
	pop	ebx

%endmacro



H_HMP0:
	CheckDeep
	HandleMotion  P0
	ret

H_HMP1:
	CheckDeep
	HandleMotion  P1
	ret

H_HMM1:
	CheckDeep
	HandleMotion  M1
	ret

H_HMBL:
	CheckDeep
	HandleMotion  BL
	ret

;*
;* HMM0
;*

H_HMM0:
	CheckDeep
 	cmp	byte [HMOVE_Cycle],3
	jne near NotConfused
 	cmp	byte [RClock],24
	jne near NotConfused
 	cmp	dword [M0_Motion],7 ;;; GUESSED dword, looks OK
	jne near NotConfused
 	cmp	byte [WByte],060h
	jne near NotConfused
 	mov	byte [M0_Confused],1
 	mov	dword [CosmicScanLine],1
 	mov	dword [M0_Motion],2 ;;; GUESSED dword, looks OK
	DoMotion  M0

NotConfused:
	HandleMotion  M0
	ret

;*
;* HMCLR
;*

H_HMCLR:
 	mov	dl,byte [WByte]
	push	edx
 	mov	byte [WByte],0

	CheckDeep

 	cmp	byte [HMOVE_Cycle],3
	jne near HMC_NotConfused
 	cmp	byte [RClock],23
	jne near HMC_NotConfused
 	cmp	dword [M0_Motion],7 ;;; GUESSED dword, looks OK
	jne near HMC_NotConfused
 	mov	byte [M0_Confused],1
 	mov	dword [CosmicScanLine],1

HMC_NotConfused:
	HandleMotion  M0
	HandleMotion  M1
	HandleMotion  P0
	HandleMotion  P1
	HandleMotion  BL

	pop	edx
 	mov	byte [WByte],dl
	jmp	HMCLR_Done

HMCLR_NotWeird:
 	mov	byte [TIA+HMP0],0
 	mov	byte [TIA+HMP1],0
 	mov	byte [TIA+HMM0],0
 	mov	byte [TIA+HMM1],0
 	mov	byte [TIA+HMBL],0

HMCLR_Done:
	ret


;*
;* CXCLR
;*

H_CXCLR:
	mov	dl,0
	call	CatchUpPixels

 	mov	dword [TIACollide],0
	ret



;*
;* REFP0
;*

H_REFP0:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+REFP0],dl
	call	UpdateP0Graphics
	ret



;*
;* REFP1
;*

H_REFP1:
	mov	dl,1
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+REFP1],dl
	call	UpdateP1Graphics
	ret

;*
;* RESMP0
;*

H_RESMP0:

	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+RESMP0],dl

	call	UpdateM0Locking
	call	UpdateM0Graphics

	ret

;*
;* RESMP1
;*

H_RESMP1:

	mov	dl,0
	call	CatchUpPixels

 	mov	dl,byte [WByte]
 	mov	byte [TIA+RESMP1],dl

	call	UpdateM1Locking
	call	UpdateM1Graphics

	ret

;;; end merge of tiawrite.asm

;;; merged: 	include tialine.asm		; (32) TIA graphics generation
;*     
;*  generate a raster line	  
;*
;*  3-18-99  -- break ground
;* 09-07-02 -- 32-bit
;*

; z26 is Copyright 1997-2000 by John Saeger and is a derived work with many
; contributors.	 z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; magic numbers:
;
;   HBLANK starts at zero, ends at 67.
;   Left Playfield starts at 68, ends at 147.
;   Right Playfield starts at 148, ends at 227.
;   HMOVE blank starts at 68, ends at 75.

; register usage:
;
;   CPU doesn't use cx, bp, di --  trashes ax, bx, dx, si
;
;   di -- display pointer
;   cl -- TIARenderPointer
;   ch -- LastPixelPointer


[section .data]

LooseColour	dd	0ffffffffh    ;  and this with pixels to turn
				      ; 	  frame gray *EST*
				      ; 	  see tiawrite.asm

;*
;* Table of low level rendering routines.
;* Index with the ActiveObjects variable.
;*
;* note:  If any delays are in effect, be sure to set the DL_BIT in the
;*	  ActiveObjects variable to ensure that delays are processed
;*	  correctly.
;*

align 2

;PF_BIT = 1
;BL_BIT = 2
;P1_BIT = 4
;M1_BIT = 8
;P0_BIT = 16
;M0_BIT = 32
RenderingRoutine:  ; dword

	dd	RenderBackground	 ;   0
	dd	RenderPlayfield		 ;   1

	dd	BK_BL			 ;   2
	dd	PF_BL			 ;   3

	dd	BK_P1			 ;   4
	dd	PF_P1			 ;   5
	dd	BK_P1_BL		 ;   6
	dd	PF_P1_BL		 ;   7

	dd	BK_M1			 ;   8
	dd	PF_M1			 ;   9
	dd	BK_M1_BL		 ;  10
	dd	PF_M1_BL		 ;  11
	dd	BK_M1_P1		 ;  12
	dd	PF_M1_P1		 ;  13
	dd	BK_M1_P1_BL		 ;  14
	dd	PF_M1_P1_BL		 ;  15

	dd	BK_P0			 ;  16
	dd	PF_P0			 ;  17
	dd	BK_P0_BL		 ;  18
	dd	PF_P0_BL		 ;  19
	dd	BK_P0_P1		 ;  20
	dd	PF_P0_P1		 ;  21
	dd	BK_P0_P1_BL		 ;  22
	dd	PF_P0_P1_BL		 ;  23
	dd	BK_P0_M1		 ;  24
	dd	PF_P0_M1		 ;  25
	dd	BK_P0_M1_BL		 ;  26
	dd	PF_P0_M1_BL		 ;  27
	dd	BK_P0_M1_P1		 ;  28
	dd	PF_P0_M1_P1		 ;  29
	dd	BK_P0_M1_P1_BL		 ;  30
	dd	PF_P0_M1_P1_BL		 ;  31

	dd	BK_M0			 ;  32
	dd	PF_M0			 ;  33
	dd	BK_M0_BL		 ;  34
	dd	PF_M0_BL		 ;  35
	dd	BK_M0_P1		 ;  36
	dd	PF_M0_P1		 ;  37
	dd	BK_M0_P1_BL		 ;  38
	dd	PF_M0_P1_BL		 ;  39
	dd	BK_M0_M1		 ;  40
	dd	PF_M0_M1		 ;  41
	dd	BK_M0_M1_BL		 ;  42
	dd	PF_M0_M1_BL		 ;  43
	dd	BK_M0_M1_P1		 ;  44
	dd	PF_M0_M1_P1		 ;  45
	dd	BK_M0_M1_P1_BL		 ;  46
	dd	PF_M0_M1_P1_BL		 ;  47
	dd	BK_M0_P0		 ;  48
	dd	PF_M0_P0		 ;  49
	dd	BK_M0_P0_BL		 ;  50
	dd	PF_M0_P0_BL		 ;  51
	dd	BK_M0_P0_P1		 ;  52
	dd	PF_M0_P0_P1		 ;  53
	dd	BK_M0_P0_P1_BL		 ;  54
	dd	PF_M0_P0_P1_BL		 ;  55
	dd	BK_M0_P0_M1		 ;  56
	dd	PF_M0_P0_M1		 ;  57
	dd	BK_M0_P0_M1_BL		 ;  58
	dd	PF_M0_P0_M1_BL		 ;  59
	dd	BK_M0_P0_M1_P1		 ;  60
	dd	PF_M0_P0_M1_P1		 ;  61
	dd	BK_M0_P0_M1_P1_BL	 ;  62
	dd	PF_M0_P0_M1_P1_BL	 ;  63


;*
;* private color registers
;*
;* we use old normal translation table to index into these (TIADisplayToColour)
;* update registers to handle SCORE and PFP
;*
ColorValue:  ; dword

BK_Color	dd	0	 ;  \ 
PF_Color	dd	0	 ; 	 \  keep these in order so we can use
P1_Color	dd	0	 ; 	 /  the old color translation table
P0_Color	dd	0	 ;  /
BL_Color	dd	0	 ;  ball color -- this is new

RenderingHBLANK	db	-1

ActiveObjects	dd	0
CosmicScanLine	dd	0
HBlanking	db	0
SetHBlanking	db	0
Invisible	db	0
HMOVE_Pending	db	0
HMOVE_Cycle	db	0	 ;  remember cycle of last HMOVE
Last_HMOVE_Cycle db	0
M0_Confused	db	0


CosmicGraphicsTable	db	040h,040h,0c0h,0


;*
;* sprite related stuff
;*

;;; converted macro:
%macro DefineObjectVars 1
ALIGN 2
%1_Table	  dd	%1_Sprite
%1_Position	  dd	0
%1_Size	  dd	%1_SpriteSize
%1_Motion	  dd	0
%1_Graphics	  db	0
%1_Delayed	  db	0
%1_TripleFlag  db	0
%endmacro


DefineObjectVars  BL
DefineObjectVars  M0
DefineObjectVars  M1
DefineObjectVars  P0
DefineObjectVars  P1

[section .code]


;*
;* TIA initialization code
;*

Init_TIA:
 	mov	dword [ActiveObjects],0
 	mov	dword [PF_Table], PFClockToBitForward
 	mov	dword [BK_Color],0
 	mov	dword [PF_Color],0
 	mov	dword [P0_Position],228-68 ;;; GUESSED dword, looks OK
 	mov	dword [P1_Position],228-68 ;;; GUESSED dword, looks OK
 	mov	dword [M0_Position],228-68 ;;; GUESSED dword, looks OK
 	mov	dword [M1_Position],228-68 ;;; GUESSED dword, looks OK
 	mov	dword [BL_Position],228-68 ;;; GUESSED dword, looks OK

 	mov	byte [M0_Confused],0

 	mov	byte [RenderingHBLANK],-1
	ret

;;; converted macro:
%macro _BL 0
	SetObjectBit  BL
%endmacro


;;; converted macro:
%macro _M0 0
	SetObjectBit  M0
%endmacro


;;; converted macro:
%macro _M1 0
	SetObjectBit  M1
%endmacro


;;; converted macro:
%macro _P0 0
	SetObjectBit  P0
%endmacro



;;; converted macro:
%macro _P1 0
	SetObjectBit  P1
%endmacro



;*
;* RenderPixel -- render pixel with multiple objects
;*

;;; converted macro:
%macro RenderPixel 6
; local ; BKPFonly

	movzx	ebx,dh  ;  PF bit

	%1
	%2
	%3
	%4
	%5
	%6

	cmp	bl,2
	jb near %%BKPFonly
 	mov	eax,dword [TIAColTab+ebx*4]
 	mov	esi,dword [PixelColorTable]
 	or	dword [TIACollide],eax
 	mov	bl,byte [ebx+esi]

%%BKPFonly:
 	mov	al,byte [ColorValue+ebx*4]
 	and	al,byte [LooseColour] ; *EST*
	inc	edi
 	and	al,byte [RenderingHBLANK]
	inc	cl
 	gs_store  [edi-1],al
	cmp	cl,ch

%endmacro



;*
;* macro for rendering multiple objects against a playfield
;*

;;; converted macro:
%macro PF_PixelLoop 6
; local ; PF_loop, PIX_loop, done
ALIGN 2

	movzx	ebp,cl
	and	ebp,0fch
 	add	ebp,dword [PF_Table]
	sub	ebp,68

%%PF_loop:
	xchg	ebp,esi
 	mov	edx,dword [TIA+PF0]
 	test	edx,dword [esi]
	setnz	dh
	add	esi,4
	xchg	ebp,esi
%%PIX_loop:
	RenderPixel  %1,  %2,  %3,  %4,  %5,  %6
	ja near %%done

	test	edi,3
	jnz near %%PIX_loop

	jmp	%%PF_loop

%%done:
	ret

%endmacro


;*
;* macro for rendering multiple objects against a background (no playfield)
;*

;;; converted macro:
%macro BK_PixelLoop 6
; local ; BK_Loop, done
ALIGN 2

	xor	dh,dh

%%BK_Loop:
	RenderPixel  %1,  %2,  %3,  %4,  %5,  %6
	jbe near %%BK_Loop

%%done:
	ret

%endmacro



;*
;* Here are the low-level rendering routines.
;*

PF_M0_P0_M1_P1_BL:	PF_PixelLoop  _M0,  _P0,  _M1,  _P1,  _BL ;  63
BK_M0_P0_M1_P1_BL:	BK_PixelLoop  _M0,  _P0,  _M1,  _P1,  _BL ;  62
PF_M0_P0_M1_P1:		PF_PixelLoop  _M0,  _P0,  _M1,  _P1 ;  61
BK_M0_P0_M1_P1:		BK_PixelLoop  _M0,  _P0,  _M1,  _P1 ;  60
PF_M0_P0_M1_BL:		PF_PixelLoop  _M0,  _P0,  _M1,  _BL ;  59
BK_M0_P0_M1_BL:		BK_PixelLoop  _M0,  _P0,  _M1,  _BL ;  58
PF_M0_P0_M1:		PF_PixelLoop  _M0,  _P0,  _M1 ;  57
BK_M0_P0_M1:		BK_PixelLoop  _M0,  _P0,  _M1 ;  56
PF_M0_P0_P1_BL:		PF_PixelLoop  _M0,  _P0,  _P1,  _BL ;  55
BK_M0_P0_P1_BL:		BK_PixelLoop  _M0,  _P0,  _P1,  _BL ;  54
PF_M0_P0_P1:		PF_PixelLoop  _M0,  _P0,  _P1 ;  53
BK_M0_P0_P1:		BK_PixelLoop  _M0,  _P0,  _P1 ;  52
PF_M0_P0_BL:		PF_PixelLoop  _M0,  _P0,  _BL ;  51
BK_M0_P0_BL:		BK_PixelLoop  _M0,  _P0,  _BL ;  50
PF_M0_P0:		PF_PixelLoop  _M0,  _P0 ;  49
BK_M0_P0:		BK_PixelLoop  _M0,  _P0 ;  48
PF_M0_M1_P1_BL:		PF_PixelLoop  _M0,  _M1,  _P1,  _BL ;  47
BK_M0_M1_P1_BL:		BK_PixelLoop  _M0,  _M1,  _P1,  _BL ;  46
PF_M0_M1_P1:		PF_PixelLoop  _M0,  _M1,  _P1 ;  45
BK_M0_M1_P1:		BK_PixelLoop  _M0,  _M1,  _P1 ;  44
PF_M0_M1_BL:		PF_PixelLoop  _M0,  _M1,  _BL ;  43
BK_M0_M1_BL:		BK_PixelLoop  _M0,  _M1,  _BL ;  42
PF_M0_M1:		PF_PixelLoop  _M0,  _M1 ;  41
BK_M0_M1:		BK_PixelLoop  _M0,  _M1 ;  40	
PF_M0_P1_BL:		PF_PixelLoop  _M0,  _P1,  _BL ;  39
BK_M0_P1_BL:		BK_PixelLoop  _M0,  _P1,  _BL ;  38
PF_M0_P1:		PF_PixelLoop  _M0,  _P1 ;  37
BK_M0_P1:		BK_PixelLoop  _M0,  _P1 ;  36
PF_M0_BL:		PF_PixelLoop  _M0,  _BL ;  35
BK_M0_BL:		BK_PixelLoop  _M0,  _BL ;  34
PF_M0:			PF_PixelLoop  _M0 ;  33
BK_M0:			BK_PixelLoop  _M0 ;  32

PF_P0_M1_P1_BL:		PF_PixelLoop  _P0,  _M1,  _P1,  _BL ;  31
BK_P0_M1_P1_BL:		BK_PixelLoop  _P0,  _M1,  _P1,  _BL ;  30
PF_P0_M1_P1:		PF_PixelLoop  _P0,  _M1,  _P1 ;  29
BK_P0_M1_P1:		BK_PixelLoop  _P0,  _M1,  _P1 ;  28
PF_P0_M1_BL:		PF_PixelLoop  _P0,  _M1,  _BL ;  27
BK_P0_M1_BL:		BK_PixelLoop  _P0,  _M1,  _BL ;  26
PF_P0_M1:		PF_PixelLoop  _P0,  _M1 ;  25
BK_P0_M1:		BK_PixelLoop  _P0,  _M1 ;  24
PF_P0_P1_BL:		PF_PixelLoop  _P0,  _P1,  _BL ;  23
BK_P0_P1_BL:		BK_PixelLoop  _P0,  _P1,  _BL ;  22
PF_P0_P1:		PF_PixelLoop  _P0,  _P1 ;  21
BK_P0_P1:		BK_PixelLoop  _P0,  _P1 ;  20
PF_P0_BL:		PF_PixelLoop  _P0,  _BL ;  19
BK_P0_BL:		BK_PixelLoop  _P0,  _BL ;  18
PF_P0:			PF_PixelLoop  _P0 ;  17
BK_P0:			BK_PixelLoop  _P0 ;  16

PF_M1_P1_BL:		PF_PixelLoop  _M1,  _P1,  _BL ;  15
BK_M1_P1_BL:		BK_PixelLoop  _M1,  _P1,  _BL ;  14
PF_M1_P1:		PF_PixelLoop  _M1,  _P1 ;  13
BK_M1_P1:		BK_PixelLoop  _M1,  _P1 ;  12
PF_M1_BL:		PF_PixelLoop  _M1,  _BL ;  11
BK_M1_BL:		BK_PixelLoop  _M1,  _BL ;  10
PF_M1:			PF_PixelLoop  _M1 ;  9
BK_M1:			BK_PixelLoop  _M1 ;  8	

PF_P1_BL:		PF_PixelLoop  _P1,  _BL ;  7
BK_P1_BL:		BK_PixelLoop  _P1,  _BL ;  6
PF_P1:			PF_PixelLoop  _P1 ;  5
BK_P1:			BK_PixelLoop  _P1 ;  4

PF_BL:			PF_PixelLoop  _BL ;  3
BK_BL:			BK_PixelLoop  _BL ;  2

;PF:			PF_PixelLoop				; 1 (used if delay set)
;BK:			BK_PixelLoop				; 0 (used if delay set)


;*
;* render playfield pixels from current cl through ch
;* leaves cl pointing to ch + 1
;*

ALIGN 2

RenderPlayfield:
	push	ecx			 ;  save old start and finish pointers
	sub	ch,cl
	inc	ch			 ;  pixel count

	movzx	esi,cl			 ;  compute pointer into playfield bit mask table
	and	esi,0fch
 	add	esi,dword [PF_Table]
	sub	esi,68

 	mov	ebp,dword dword [TIA+PF0] ; get playfield bits

 	mov	eax,dword [BK_Color]
 	and	eax,dword [LooseColour] ; *EST*

 	mov	edx,dword [PF_Color]
 	and	edx,dword [LooseColour] ; *EST*

NextPFTest:
 	test	ebp,dword [esi] ; setting a playfield bit ?
	jnz near PFLoop			 ; 	  yes

BKLoop:
 	gs_store  dword [edi],al
	inc	edi
	dec	ch			 ;  done?
	jz near RenderPlayfieldDone	 ;    yes
	test	edi,3			 ;  more odd pixels to do?
	jz near NextPFQuad		 ;    no
	jmp	BKLoop

PFLoop:
 	gs_store  dword [edi],dl
	inc	edi
	dec	ch			 ;  done?
	jz near RenderPlayfieldDone	 ;    yes
	test	edi,3			 ;  more odd pixels to do?
	jz near NextPFQuad		 ;    no
	jmp	PFLoop

NextPFQuad:
	add	esi,4
	test	ch,0fch			 ;  any more quads to do?
	jz near NextPFTest		 ;    no, check for more singles
 	test	ebp,dword [esi] ; setting a playfield bit?
	jnz near DoPFQuad		 ;    yes

 	;gs_store  [edi],eax ; render BK quad
	mov dword [edi], eax
	add	edi,4
	sub	ch,4			 ;  done?
	jnz near NextPFQuad		 ;    no, keep going
	jmp	RenderPlayfieldDone

DoPFQuad:
 	;gs_store  [edi],edx ; render PF quad	
	mov dword [edi], edx
	add	edi,4
	sub	ch,4			 ;  done?
	jnz near NextPFQuad		 ;    no, keep going


RenderPlayfieldDone:
	pop	ecx			 ;  done, restore old start and finish pointers
	mov	cl,ch
	inc	cl			 ;  point start at finish + 1

	ret


;*
;* render background pixels from current cl through ch
;* leaves cl pointing to ch + 1
;*

ALIGN 2

RenderBackground:
 	mov	eax,dword [BK_Color]
 	and	eax,dword [LooseColour] ; *EST*

RenderSolid:				 ;  << enter here to render EAX
	push	ecx
	sub	ch,cl
	movzx	ecx,ch
	inc	cl			 ;  pixel count
	test	cl,1			 ;  any odd pixels?
	jz near SolidDouble		 ;    no
 	gs_store  dword [edi],al ; yes, render single pixel
	inc	edi
	dec	ecx			 ;  done?
	jz near SolidDone		 ;    yes

SolidDouble:
	shr	ecx,1			 ;  do the double pixels
	gs_rep_stosw  ;  ** 16-bit routine **

SolidDone:
	pop	ecx			 ;  restore old start and finish pointers
	mov	cl,ch
	inc	cl			 ;  point start at finish + 1
	ret


;*
;* render HBLANK
;*

ALIGN 2

RenderHBLANK:
 	cmp	dword [ActiveObjects],2
	jb near RenderNothing
 	mov	esi,dword [ActiveObjects]
	and	esi,63
 	mov	byte [RenderingHBLANK],0
 	call	dword [RenderingRoutine + esi*4] ; call rendering routine
 	mov	byte [RenderingHBLANK],-1
	ret

;*
;*  render blackness
;*
;*  note:  This approach causes collisions not to be processed during
;*	   vertical blanks.	This may not be correct.
;*

ALIGN 2

RenderNothing:
	xor	eax,eax
	jmp	RenderSolid


;*
;* RenderPixels
;*
;* Since the underlying routines are not capable of dealing with a change of
;* the state of HBlanking, we split calls to RenderPixels if necessary.
;*
;* We do the same thing at mid-playfield to update playfield color translation.
;*

ALIGN 2

RenderPixels:

	cmp	cl,ch
	ja near RenderDone		 ;  protect rep stosw

 	cmp	byte [HBlanking],-1 ; doing HBlanking?
	je near RenderMiddle		 ;    no, don't split out HBlank area

	cmp	cl,75			 ;  render pointer past HBlank?
	ja near RenderMiddle		 ;    yes
	cmp	ch,75			 ;  final pointer before end of HBlank?
	jbe near RenderHBLANK		 ;    yes, render blackness

	mov	al,ch			 ; 	 no, render pixels through HBlank
	push	eax
	mov	ch,75
	call	RenderHBLANK
	pop	eax
	mov	ch,al

 	mov	byte [HBlanking],-1 ; turn off HBlanking

RenderMiddle:
	cmp	ch,227			 ;  final request for this line?
	jne near RenderPartial		 ; 	no
 	test	dword [ActiveObjects],3 ; PF or Ball active ?
	jz near RenderShortcutBK	 ; 	 no, take a shortcut

RenderPartial:
	cmp	cl,147			 ;  render pointer past mid-playfield?
	ja near RenderFinal		 ;    yes
	cmp	ch,147			 ;  final pointer before mid-playfield?
	jbe near RenderFinal		 ;    yes

	mov	al,ch			 ;    no, render pixels through mid-playfield
	push	eax
	mov	ch,147
	call	DoRender
	pop	eax
	mov	ch,al

RenderFinal:
	cmp	cl,148			 ;  at mid-playfield?
	jne near DoRender		 ;    no

	UpdatePlayfieldReflection  ;    yes, update reflection table

DoRender:
	UpdatePlayfieldColor  ;  every pixel run with PF active

RenderShortcutBK:

 	cmp	dword [VBlanking],0 ; doing VBlanking?
	je near RenderNothing		 ;    yes, render blackness

 	mov	esi,dword [ActiveObjects]
	and	esi,63
 	jmp	dword [RenderingRoutine + esi*4] ; call rendering routine

RenderDone:
	ret


;*
;* render pixels from cl through RClock 
;*
;* points ch to RClock (RClock*3 - 1 + offset parameter in dl)
;* leaves cl pointing to ch + 1
;*
;* Normally the offset parameter should be zero, but this is where we can make
;* small adjustments for register writes that need some additional delays,
;* providing the delays don't need to straddle a line.
;*
;* note: Ignoring invisible regions might cause off-screen collisions to be 
;*	 missed.
;*

ALIGN 2

CatchUpPixels:
 	cmp	byte [Invisible],0 ; are we visible?
	jne near CatchupDone		 ;    no, don't render anything

 	mov	ch,byte [RClock]
	cmp	ch,CYCLESPERSCANLINE	 ;  beyond end of line?
	ja near CatchupLast		 ;    yes, limit to 227
	add	ch,ch
 	add	ch,byte [RClock] ; no, compute last clock to render
	dec	ch
	add	ch,dl			 ; 		    add the extra offset

	cmp	ch,227			 ;  request too many pixels?
	jbe near CatchupGo		 ;    no

CatchupLast:
	mov	ch,227			 ; 	  yes, limit to 227
CatchupGo:
	push	esi			 ;  for the sake of TIA write handlers
	call	RenderPixels
	pop	esi

CatchupDone:
	ret


;*
;* do some instructions until RClock >= CYCLESPERSCANLINE
;*

ALIGN 2

;;; converted macro:
%macro nDoInstructions 0
; local ; InstructionLoop, InstructionsDone

	LoadRegs  ;  load the CPU registers

 	cmp	byte [RClock],CYCLESPERSCANLINE ; check if we need to skip a line *EST*
	jae near %%InstructionsDone  ;  (for WSYNC at cycle 74/75 fix)

%%InstructionLoop:
	fetch_opcode  ebx ;  (fetchzx) get the opcode
 	call	dword [vectors + ebx*4] ; --> do the instruction
	ClockRIOT  ;  clock the RIOT timer

 	cmp	byte [RClock],CYCLESPERSCANLINE
	jb near %%InstructionLoop

%%InstructionsDone:
	SaveRegs  ;  save the CPU registers
%endmacro



;*
;* TIALineTo -- the actual raster line code
;*

ALIGN 2

nTIALineTo:
	call	QueueSoundBytes		 ;  put another 2 bytes in the sound queue

 	mov	dl,byte [HMOVE_Cycle]
 	mov	byte [Last_HMOVE_Cycle],dl
 	mov	byte [HMOVE_Cycle],0 ; forget where last HMOVE was (cosmic)

 	cmp	byte [M0_Confused],0
	jz near NotCosmic

 	push	dword [M0_Motion] ;;; GUESSED dword, looks OK
 	mov	dword [M0_Motion],17 ;;; GUESSED dword ; (17), looks OK
	DoMotion  M0
 	pop	dword [M0_Motion] ;;; GUESSED dword, looks OK
 	mov	ebx,dword [CosmicScanLine]
 	inc	dword [CosmicScanLine]
	and	ebx,3
 	mov	dl,byte [CosmicGraphicsTable+ebx]
 	mov	byte [M0_Graphics],dl

NotCosmic:
 	mov	ebx,dword [ScanLine]
 	cmp	ebx,dword [TopLine] ; line before first displayable?
	jb near nTIANoGenerate		 ; 	yes, don't render
 	cmp	ebx,dword [BottomLine] ; line after last displayable?
	jae near nTIANoGenerate		 ; 	 yes, don't render

 	mov	eax,dword [MaxLines]
 	lea	eax, [eax+eax*4]
	shl	eax,5			 ;  *160

 	add	eax,dword [ScreenBuffer]

 	cmp	dword [DisplayPointer],eax ; render pointer past end of displayable?
	jae near nTIANoGenerate		 ; 	 yes, don't render

	push	ebp			 ;  rendering -- free up a register

 	mov	edi,dword [DisplayPointer]
	mov	cl,68			 ;  point TIARenderPointer at beginning of playfield

 	mov	byte [HBlanking],-1 ; assume we're not HBlanking
 	cmp	byte [SetHBlanking],0 ; should we be HBlanking?
	je near NoColumnBlank		 ;    no
 	mov	byte [HBlanking],0 ; yes, start HBlanking

NoColumnBlank:
 	mov	byte [SetHBlanking],0 ; clear the set HBlanking flag

	call	SetupMultiSpriteTrick

 	cmp	byte [RClock],CYCLESPERSCANLINE ; done before we started ?
	jae near nLastPixels		    ; 	 yes, WSYNC straddled a line
					 ; 		   render pixels w/o CPU

 	mov	byte [Invisible],0 ; tell CatchUpPixels to render pixels
	nDoInstructions  ;  do a line full of instructions

nLastPixels:
	mov	ch,227			 ;  line done, render any left over pixels
	call	RenderPixels

nTIAExit:				 ;  we've finished the scanline...
 	mov	dword [DisplayPointer],edi

	pop	ebp
	ret


;*
;* do a blank line (outside of display area)
;*

nTIANoGenerate:

 	mov	byte [Invisible],1 ; tell CatchUpPixels not to render any pixels
	nDoInstructions  ;  do a line full of instructions

	ret


;;; end merge of tialine.asm

;;; merged: 	include tiasnd.asm		; (32) asm version of Ron Fries' TIASound
; tiasnd.asm -- z26 sound generation routines
;               based on TIASound (c) 1996-1997 by Ron Fries
;		please see the end of this file for Ron's banner

; z26 is Copyright 1997-2003 by John Saeger and is a derived work with many
; contributors.  z26 is released subject to the terms and conditions of the 
; GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
; Please see COPYING.TXT for details.

; 04-08-98 -- first release
; 04-19-99 -- added sound queue
; 07-27-02 -- 32-bit
; 12-08-03 -- polynomials adapted to Adam Wozniak's description

[section .data]

sreg	dd	1		 ;  initialize shift register to non-zero val

; Initialze the bit patterns for the polynomials.

; The 4bit and 5bit patterns are the identical ones used in the tia chip.
; Though the patterns could be packed with 8 bits per byte, using only a
; single bit per byte keeps the math simple, which is important for
; efficient processing.

;Bit4    db      1,1,0,1,1,1,0,0,0,0,1,0,1,0,0
;Bit5    db      0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0,1,0,0,0,0,1
Bit4    db      0,1,1,0,0,1,0,1,0,0,0,0,1,1,1
Bit5    db      0,0,0,0,0,1,1,1,0,0,1,0,0,0,1,0,1,0,1,1,1,1,0,1,1,0,1,0,0,1,1

; 1 = toggle output in 5 bit poly - used when poly5 clocks other outputs
Bit5T   db      1,0,0,0,0,1,0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0

; The 'Div by 31' counter is treated as another polynomial because of
; the way it operates.  It does not have a 50% duty cycle, but instead
; has a 13:18 ratio (of course, 13+18 = 31).  This could also be
; implemented by using counters.

Div31   db      0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0

Div6    db      0,1,0,0,1,0

; The sample output is treated as another divide by N counter.
; For better accuracy, the Samp_n_cnt has a fixed binary decimal point
; which has 8 binary digits to the right of the decimal point.

Samp_n_cnt	dd	0
Samp_n_max	dd	0
TS_Start:  ; byte			; <-- start clearing here

D6              db      0,0
P4              db      0,0
P5		db	0,0
AUDC		db	0,0
AUDF		db	0,0
AUDV		db	0,0
Outvol		db	0,0
Div_n_cnt 	db	0,0
Div_n_max 	db	0,0
TS_End:  ; byte			; <-- finish clearing here

P9_sreg		dd	1,1


new_val		dd	0

prev_sample	dd	0
next_sample	db	0
AUDC_Jumptab:  ; dword	; HEX  D3 D2 D1 D0    Clock Source    Clock Modifier    Source Pattern
				 ;  --- -------------  --------------  ----------------  ----------------
	dd	TSB_Ch0done	 ;   0    0  0  0  0    3.58 MHz/114 ->  none  (pure)  ->      none
	dd	TSB_Poly4	 ;   1    0  0  0  1    3.58 MHz/114 ->  none  (pure)  ->   4-bit poly
	dd	TSB_Div31_Poly4	 ;   2    0  0  1  0    3.58 MHz/114 ->  divide by 31  ->   4-bit poly
	dd	TSB_Poly5_Poly4	 ;   3    0  0  1  1    3.58 MHz/114 ->   5-bit poly   ->   4-bit poly
	dd	TSB_Pure	 ;   4    0  1  0  0    3.58 MHz/114 ->  none  (pure)  ->   pure  (~Q)
	dd	TSB_Pure	 ;   5    0  1  0  1    3.58 MHz/114 ->  none  (pure)  ->   pure  (~Q)
	dd	TSB_Div31_Pure	 ;   6    0  1  1  0    3.58 MHz/114 ->  divide by 31  ->   pure  (~Q)
;        dd      TSB_Poly5_Pure  ;  7    0  1  1  1    3.58 MHz/114 ->   5-bit poly   ->   pure  (~Q)
        dd      TSB_Poly5        ;   7    0  1  1  1    3.58 MHz/114 ->  none  (pure)  ->   5-bit poly
	dd	TSB_Poly9	 ;   8    1  0  0  0    3.58 MHz/114 ->  none  (pure)  ->   9-bit poly
	dd	TSB_Poly5	 ;   9    1  0  0  1    3.58 MHz/114 ->  none  (pure)  ->   5-bit poly
;        dd      TSB_Div31_Poly5 ;  A    1  0  1  0    3.58 MHz/114 ->  divide by 31  ->   5-bit poly
        dd      TSB_Div31_Pure   ;   A    1  0  1  0    3.58 MHz/114 ->  divide by 31  ->   pure  (~Q)
	dd	TSB_Poly5_Poly5	 ;   B    1  0  1  1    3.58 MHz/114 ->   5-bit poly   ->   5-bit poly
        dd      TSB_Div6_Pure    ;   C    1  1  0  0    3.58 MHz/114 ->  divide by 6   ->   pure  (~Q)
        dd      TSB_Div6_Pure    ;   D    1  1  0  1    3.58 MHz/114 ->  divide by 6   ->   pure  (~Q)
        dd      TSB_Div31_Div6   ;   E    1  1  1  0    3.58 MHz/114 ->  divide by 31  ->   divide by 6
        dd      TSB_Poly5_Div6   ;   F    1  1  1  1    3.58 MHz/114 ->   5-bit poly   ->   divide by 6

[section .code]
;*
;* handle the power-up initialization functions
;* these functions should only be executed on a cold-restart
;*

Init_Tiasnd:

; calculate the sample 'divide by N' value based on the playback freq

	mov	eax,31400
	shl	eax,8
	mov	ebx,31400
	xor	edx,edx
	div	ebx			 ;  ax = (_sample_freq<<8)/_playback_freq
 	mov	dword [Samp_n_max],eax
 	mov	dword [Samp_n_cnt],0

	clear_mem  TS_Start,  TS_End

 	mov	dword [P9_sreg],1
 	mov	dword [P9_sreg+4],1

	ret	


;*
;* routine to get kid-vid sound byte
;*

KidVid_Sound_Byte:

         test    byte [KidVid],0ffH
        jz near NoSamplePlay

	pushad
        call    kv_GetNextSampleByte
	popad
 	movzx	eax,byte [SampleByte]

NoSamplePlay:

	ret


;*
;* generate a sequence of pseudo-random bits 511 bits long
;* by emulating a 9-bit shift register with feedback taps at
;* positions 5 and 9.
;*

ShiftRegister9:
 	mov	eax,dword [sreg]
	mov	edx,eax
	and	eax,1		 ;  bit 9 (register output & return val)
	and	edx,16
	shr	edx,4		 ;  position bit 5 at bottom
	xor	edx,eax		 ;  xor with bit 9 = new bit 1
 	shr	dword [sreg],1 ; shift the register
	shl	edx,8		 ;  position the feedback bit
 	or	dword [sreg],edx ; or it in
	ret	

;*
;* update TIA sound registers
;*

H_AUDC0:
 	mov	al,byte [WByte]
	and	al,15
 	mov	byte [AUDC],al
	jmp	UTS_Chan0

H_AUDC1:
 	mov	al,byte [WByte]
	and	al,15
 	mov	byte [AUDC+1],al
	jmp	UTS_Chan1

H_AUDF0:
 	mov	al,byte [WByte]
	and	al,31
 	mov	byte [AUDF],al
	jmp	UTS_Chan0

H_AUDF1:
 	mov	al,byte [WByte]
	and	al,31
 	mov	byte [AUDF+1],al
	jmp	UTS_Chan1

H_AUDV0:
 	mov	al,byte [WByte]
	and	al,15
	shl	al,3
 	mov	byte [AUDV],al

UTS_Chan0:
	xor	ebx,ebx
	jmp	UTS_RegSet

H_AUDV1:
 	mov	al,byte [WByte]
	and	al,15
	shl	al,3
 	mov	byte [AUDV+1],al

UTS_Chan1:
	mov	ebx,1

; the output value has changed

UTS_RegSet:
 	cmp	byte [AUDC+ebx],0 ; AUDC value of zero is a special case
	jne near UTS_rs1
 	mov	dword [new_val],0 ; indicate clock is zero so ...
 	mov	al,byte [AUDV+ebx] ; ... no processing will occur
 	mov	byte [Outvol+ebx],al ; and set output to selected volume

	jmp	UTS_rs2

UTS_rs1:
 	movzx	eax,byte [AUDF+ebx] ; calc the 'div by N' value
	inc	eax
 	mov	dword [new_val],eax
;        mov     al,[AUDC+ebx]
;        and     al,12
;        cmp     al,12
;        jne near UTS_rs2                 ; if bits 2 and 3 are set ...
;        mov     eax,[_new_val]          ; ... multiply by three
;        add     eax,eax
;        add     [_new_val],eax

UTS_rs2: movzx	eax,byte [Div_n_max+ebx] ; only reset channels that have changed
 	cmp	eax,dword [new_val]
	je near UTS_Done
 	mov	al,byte [new_val]
 	mov	byte [Div_n_max+ebx],al ; reset 'div by N' counters
 	cmp	byte [Div_n_cnt+ebx],0
	je near UTS_rs3			 ;  if channel is now volume only ...
 	cmp	dword [new_val],0
	jne near UTS_Done		 ;  ... or was volume only ...

UTS_rs3: mov	al,byte [new_val]
 	mov	byte [Div_n_cnt+ebx],al ; ... reset the counter 
				 	 ;      (otherwise complete previous)

UTS_Done:
	ret	

;*
;* generate a sound byte based on the TIA chip parameters
;*

;;; converted macro:
%macro inc_mod 2
; local ; done

 	inc	byte [%1] ;;; GUESSED dword
 	cmp	byte [%1],%2 ;;; GUESSED dword
	jne near %%done
 	mov	byte [%1],0 ;;; GUESSED dword
%%done:
%endmacro



TIA_Sound_Byte:

TSB_ProcessLoop:

	xor	edi,edi			 ;  process channel 0 first

 	cmp	byte [Pitfall2],0 ; doing Pitfall2?
	jz near TSB_ProcessChannel	 ;    no
	inc	edi			 ;    yes, only do channel 1

TSB_ProcessChannel:
 	cmp	byte [Div_n_cnt + edi],1 ; if div by N counter can count down ...
	jb near TSB_Ch0done		 ;    zero is special case, means AUDC==0 -- fast exit
	je near TSB_1
 	dec	byte [Div_n_cnt + edi] ; ... decrement ...
	jmp	TSB_Ch0done		 ;  ... and do next channel

TSB_1: mov	al,byte [Div_n_max + edi] ; otherwise reset the counter and process this channel
 	mov	byte [Div_n_cnt + edi],al

 	movzx	esi,byte [AUDC + edi] ; AUDC = index into branch table

	inc_mod  P5+edi,31 ;  P5 channel has multiple uses (Div31 & P5), inc it here
 	movzx	ebx,byte [P5 + edi]

 	jmp	dword [AUDC_Jumptab + esi*4] ; process sound changes based on AUDC


TSB_Div6_Pure:
        inc_mod  D6+edi,6 ;  inc Div6 counter
         movzx   ebx,byte [D6 + edi]
         cmp     byte [Div6+ebx],0 ; if div 6 bit set ...
	jnz near TSB_Pure		 ;  ... do pure
	jmp	TSB_Ch0done

TSB_Div31_Div6:
 	cmp	byte [Div31+ebx],0 ; if div 31 bit set ...
        jnz near TSB_Div6_Pure            ;  ... do div 6
        jmp     TSB_Ch0done

TSB_Div31_Pure:
 	cmp	byte [Div31+ebx],0 ; if div 31 bit set ...
	jnz near TSB_Pure		 ;  ... do pure
	jmp	TSB_Ch0done

;TSB_Poly5_Pure:
;        cmp     [Bit5+ebx],0             ; if div 5 bit set ...
;        jz near TSB_Ch0done             ; ... do pure

TSB_Pure:
 	cmp	byte [Outvol + edi],0 ; toggle the output
	je near TSB_VolumeOn
	jmp	TSB_VolumeOff


TSB_Poly9:	
 	mov	edx,dword [P9_sreg+4*edi]
 	mov	dword [sreg],edx ; set shift reg to this channel's shift reg
	call	ShiftRegister9		 ;  calculate next bit
 	mov	edx,dword [sreg] ; save shift reg to our channel
 	mov	dword [P9_sreg+4*edi],edx
	test	al,1			 ;  shift reg bit on?
	je near TSB_VolumeOff		 ;    no
	jmp	TSB_VolumeOn		 ;    yes


;TSB_Div31_Poly5:
;        cmp     [Div31+ebx],0            ; if div 31 bit set ...
;        jnz near TSB_Poly5               ; ... do Poly5
;        jmp     TSB_Ch0done

TSB_Poly5_Div6:
         cmp     byte [Bit5T+ebx],0 ; if Bit5 output changed ...
        jnz near TSB_Div6_Pure            ;  ... do Div 6
	jmp	TSB_Ch0done

TSB_Poly5_Poly5:
 	cmp	byte [Bit5+ebx],0 ; if Poly5 bit set ...
	jz near TSB_Ch0done		 ;  ... do Poly5

TSB_Poly5:
 	movzx	ebx,byte [P5 + edi] ; set the output bit
 	cmp	byte [Bit5+ebx],0
	je near TSB_VolumeOff
	jmp	TSB_VolumeOn


TSB_Div31_Poly4:
 	cmp	byte [Div31+ebx],0 ; if div 31 bit set ...
	jnz near TSB_Poly4		 ;  ... do Poly4
	jmp	TSB_Ch0done

TSB_Poly5_Poly4:                         ;  changed from Bit5 to Bit5T *EST*
         cmp     byte [Bit5T+ebx],0 ; if Poly5 bit set ...
	jz near TSB_Ch0done		 ;  ... do Poly4

TSB_Poly4:
	inc_mod  P4+edi,15 ;  inc P4 counter
 	movzx	ebx,byte [P4 + edi]

 	cmp	byte [Bit4+ebx],0 ; and set the output bit
	je near TSB_VolumeOff

TSB_VolumeOn:
 	mov	al,byte [AUDV + edi]
 	mov	byte [Outvol + edi],al
	jmp	TSB_Ch0done

TSB_VolumeOff:
 	mov	byte [Outvol + edi],0

TSB_Ch0done:
	inc	edi			 ;  to next channel
	cmp	edi,1			 ;  done ?
	jbe near TSB_ProcessChannel	 ;    not yet

 	sub	dword [Samp_n_cnt],256 ; decrement sample count
					 ;  (256 since lower byte is 
					 ;   fractional part)
 	cmp	dword [Samp_n_cnt],256 ; if count has reached zero ...
	jae near TSB_ProcessLoop
 	mov	eax,dword [Samp_n_max] ; ... adjust the sample counter
 	add	dword [Samp_n_cnt],eax

 	cmp	byte [Pitfall2],0 ; running Pitfall 2?
	jz near TSB_NotPitfall2		 ;    no

	call	Clock_Pitfall2		 ;    yes, clock P2 music clock (and build AUDV)
 	mov	al,byte [Outvol+1] ; channel 1
 	mov	ah,byte [P2_AUDV]
	and	ah,15
	shl	ah,3
	add	al,ah			 ;  add in Pitfall 2 AUDV byte
	jmp	TSB_Pitfall2_Done

TSB_NotPitfall2:
 	mov	al,byte [Outvol+0] ; not Pitfall 2, do normal mixing
 	add	al,byte [Outvol+1] ; sum the channels

TSB_Pitfall2_Done:
 	cmp	byte [GamePaused],0 ; if game paused
	jz near TSB_NoSilence
	mov	al,080h			 ;  fill buffer with silence
TSB_NoSilence:

 	test	byte [dsp],0ffh ; doing digital signal processing ?
	jz near TSB_ProcessDone		 ;    no, just store it
 	mov	byte [next_sample],al ; yes, take edge off square wave
	xor	eax,eax
 	mov	al,byte [next_sample]
 	add	eax,dword [prev_sample]
	shr	eax,1
 	mov	dword [prev_sample],eax ; dsp=2, scaled moving average

 	cmp	byte [dsp],1
	jne near TSB_ProcessDone
 	movzx	esi,byte [next_sample] ; dsp=1, simple moving average
 	mov	dword [prev_sample],esi

TSB_ProcessDone:
	and	eax,0ffh		 ;  return 32-bit sample
	ret	

; /*****************************************************************************/
; /*                                                                           */
; /*                 License Information and Copyright Notice                  */
; /*                 ========================================                  */
; /*                                                                           */
; /* TiaSound is Copyright(c) 1996 by Ron Fries                                */
; /*                                                                           */
; /* This library is free software; you can redistribute it and/or modify it   */
; /* under the terms of version 2 of the GNU Library General Public License    */
; /* as published by the Free Software Foundation.                             */
; /*                                                                           */
; /* This library is distributed in the hope that it will be useful, but       */
; /* WITHOUT ANY WARRANTY; without even the implied warranty of                */
; /* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library */
; /* General Public License for more details.                                  */
; /* To obtain a copy of the GNU Library General Public License, write to the  */
; /* Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.   */
; /*                                                                           */
; /* Any permitted reproduction of these routines, in whole or in part, must   */
; /* bear this legend.                                                         */
; /*                                                                           */
; /*****************************************************************************/



;;; end merge of tiasnd.asm


;;; merged: 	include tail.asm		; (32) the END
	END


;;; end merge of tail.asm
