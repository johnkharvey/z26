### Preamble - a note about this github z26 project

z26 is an open-source Atari 2600 emulator whose first release (v0.8) was Aug. 28, 1997 and latest release (v4.07) was August 31, 2019. The author still hosts the source code on their own website here: http://www.whimsey.com/z26/

As far as I can tell, it has never been ported to github as a thorough historical backup "just in case". It is not my intention to maintain this code, but instead to keep it as an archive for history.

This repository contains tagged commits that are snapshots in time containing every single public release, as well as release artifacts. Note that the final commit on the main branch just contains this README.md file was not a part of the original project.

Note that some binaries referenced in specific releases have been captured in: https://github.com/johnkharvey/z26-extras

The license type is the GNU General Public License Version 2 (June 1991) and can be found at ./src/doc/copying.txt.

------

### z26 -- An Atari 2600 Emulator (4.07)

August 31, 2019

http://www.whimsey.com/z26
Copyright/License

z26 is Copyright ©1997-2019 by John Saeger and contributors. z26 is released subject to the terms and conditions of the GNU General Public License Version 2 (GPL). z26 comes with no warranty. Please see the included COPYING.TXT for details. Source code for the current release is available at the home page listed above.
What's new in version 4.07?

    Wide dynamic range, tunable palettes for NTSC and PAL video. We are now emulating the color tuning controls that are found inside the Atari 2600. So just like owners of real hardware can experiment with different color tunings, users of z26 can also experiment with different color tunings. By default we set the NTSC phase shift to 26.2 degrees and the PAL phase shift to 21.5 degrees which are good matches to the original z26 palettes.

    Brightness and “warmth” controls. The warmth control allows better matching to vintage CRT TV sets from the 1980s which had a little more red and maybe a little less blue than “modern” CRT TV sets from the 1990s or early 2000s.

    The original z26 palettes have been retained as custom options, and since our tunable color model was inspired by mame 0.212, we also include the mame palettes as custom options.

    The palette selection and these new options may be found in the video menu.

Software Requirements

This version of z26 is known to work on Windows 10, Linux, and Intel Macintoshes. As this version of z26 is written in C, it is possible to compile and run this version of z26 on 64-bit Linux systems as well as the Raspberry Pi, but your system needs to support OpenGL.
Hardware Requirements

A computer with reasonably fast processors, hardware support for OpenGL, and a working vsync. A Raspberry Pi version 1 or a Raspberry Pi Zero should be fast enough.
Windows Installation

Unzip the z26 archive. You can leave it in the download directory if you want. You will need a copy of SDL2.dll either in the z26 directory, or in the Windows directory. This .dll is included in the .zip file along with the z26 executable. If you like you can pin z26 to the taskbar. Then you can click to run it.
Macintosh Installation

Unzip the archive. You can leave the folder in the download directory if you want. Or you can move the app to the applications folder. Then if you like, just drag the app to the dock. Click to run.
Linux Installation

First, you need the build tools and the SDL 2.0 library. On a debian based system open a terminal and type:

     sudo apt-get install build-essential
     sudo apt-get install libsdl2-dev

Otherwise use the method from your distro to install these packages. Don’t worry if build-essential is already installed. It is becoming more common for that package to be installed out of the box. Unzip the z26 source archive, open a terminal in the resulting source directory and type:

     make linux

If all goes well, when it's done you'll have an executable named z26 that you can put where you like. To run z26, open a terminal in the directory you put z26 and type ./z26 at the command line prompt. This should make z26 available in your menu system and can be run from there for future uses. You should also be able to put a launcher on the desktop or in an application launcher like other linux desktop apps.
Setting up the Raspberry Pi

First, we want to make sure your system is up to date. Open a terminal and type:

     sudo apt-get update
     sudo apt-get dist-upgrade

Reboot your system. Then install the dependencies. You need the build tools and the SDL 2.0 development library.

     sudo apt-get install build-essential
     sudo apt-get install libsdl2-dev

Don’t worry if build-essential is already installed. It is becoming more common for that package to be installed out of the box. Unzip the z26 source archive, open a terminal in the resulting source directory and type:

     make linux

If all goes well, when it's done you'll have an executable named z26 that you can put where you like. Before running z26, you need to enable the OpenGL drivers by running:

     sudo raspi-config

Choose option 7 – Advanced Options. Then choose option A7 – GL Driver. Then choose option G1 – GL (Full KMS). Exit the config program by pressing escape until you reach the command line prompt and reboot your system.

To run z26, open a terminal in the directory you put z26 and type ./z26 at the command line prompt. This should make z26 available in your menu system and can be run from there for future uses. You should also be able to put a launcher on the desktop or in an application launcher or panel like other linux desktop apps.
Main Menu

After launching z26, you will be presented with the Main Menu. The current selection is highlighted. You can navigate the list with the vertical arrow keys, and you can make a selection by pressing the <enter> key or the <right arrow> key.

z26 -- An Atari 2600 Emulator

         Play a Game

         Game
         Video
         Sound
         Interface
         Tweaks
         Debug
         About

         Exit

Play a Game Menu

Initially, the contents of the startup directory are shown. You can navigate to other directories which are shown with a / following the name. You can go upwards in a directory tree by selecting the ../ entry. If you press a letter of the alphabet, the file list shows the first game starting with that letter at the top of the list, with successive keypresses narrowing the search.

../
aciddrop.bin
atlantis.bin
breakout.bin
demonatk.bin
enduro.bin
oystr29.bin
phasor.bin
quadrun.bin
solaris.bin
spcshutl.bin
vidchess.bin

If you run a game with the game launcher, you can exit the game by pressing <escape> and you return to the game launcher. If you press <escape> again you return to the Main Menu.
Game Menu

Navigate the menu with the up/down arrows and select with left/right arrows, the enter key or the space bar. Press <escape> to return to the Main Menu.

Game Options – e5e657da              Recently run game CRC shown in hex.

         P0 Difficulty...: Easy      Player 0 difficulty -- easy or hard.
         P1 Difficulty...: Easy      Player 1 difficulty -- easy or hard.
         Console B/W.....: Color     Console B/W switch  -- color or B/W.

         Bankswitch......: Auto      Atari, Tigervision, Spectravideo, etc.
         Left Controller.: Auto      Joystick, paddle, keypad, etc.
         Right Controller: Auto      Joystick, paddle, keypad, etc.
         Swap Ports......: Auto      Swap left and right controllers.
         Allow All 4 Dir.: Auto      All 4 joystick directions simultaneously.

         Exit                        Return to Main Menu.

Navigate the menu with the up/down arrows and select with left/right arrows, the enter key or the space bar. Press <escape> .
It is also possible to specify the bankswitch scheme as the filename extension. You can use one of the abbreviations shown in square brackets below. You may use lower case or upper case.

The following bankswitch schemes are supported:

[2K] or [4K] – 2K or 4K Atari [CV] CommaVid [F8S] 8K Superchip [E0] 8K Parker Bros. [3F] 8K Tigervision [FE] 8K Activision (flat) [F6S] 16K Superchip [E7] 16K M-Network [F4S] 32K Superchip [F8] 8K Atari swapped [CM] Compumate [3F+] 32-512K Tigervision+ [UA] 8K United Appliance [EF] 64K Homestar Runner (Paul Slocum) [3E] 32-512K 3F + 32K ram (Andrew Davie Krokodile cart) [AR] Starpath [F6] 16K Atari [F4] 32K Atari [MB] 64K Megaboy [FA] 12K CBS [F8] 8K Atari [DPC] or [P2] 8K+DPC Pitfall2 [4A5] supercat (John Payson) [084] EconoBanking

The following controllers are supported:

Joystick Paddle Keypad Driving LightGun Compumate KidVid MindLink ST Mouse TrakBall AmigaMouse
Video Menu

By default z26 runs full-screen at the resolution of your desktop since OpenGL vsync usually works best when run full-screen. A windowed display is provided, but it's not guaranteed to give smooth gaming performance.

Note that syncing the game to vsync is the only method provided for controlling game speed. Normally this is not a problem since OpenGL does a great job providing this feature and normally the refresh rate of the monitor is 60 Hz automatically. This is the correct speed for NTSC games which most Atari 2600 ROM images are. If however you are a serious gamer and you have a high performance monitor and like to set it to a higher frame rate like 100 Hz, 120 Hz or even 144 Hz, you will need to manually adjust the refresh rate of your monitor to 60 Hz to get correct game speed on NTSC games. PAL and SECAM games are best run at 50 Hz. My main Linux system supports changing the monitor refresh rate to 50 Hz which is pretty nice. I can play PAL games at the proper speed. But this feature is not necessarily supported on your platform and so far I’ve not found it on the Raspberry Pi. So your mileage may vary, and frankly, running PAL games at 60 Hz is not such a terrible thing to do.

A number of textures are provided to give control over game detail and sharpness. Width is continuously variable and the scanline effect has variable depth. So you can control the display much as you might control the display on a real 2600 connected to an old-school TV set. Scanline display requires normal or HD textures to be enabled. HD gives the best scanlines but also requires the most CPU resources.

f you have selected a normal or HD texture you get an expanded menu with the ability to set scanline options, if you choose a fast texture you get a simplified video menu without these options.

The palette option allows manual selection of the colors from a variety of options including the original vintage z26 palettes. Since our tunable color model was inspired by the model found in mame 0.212, we include the original palettes from that version of mame as well. There are also brightness and warmth controls. The warmth control allows for possibly better color matching with vintage TV sets from the 1980s which may have had a color balance slightly tilted toward the red. Increase it to get a little more red in the display. There are also phase adjustments to allow color tuning like real hardware. The Atari 2600 has a “phase adjustment” inside the box which allows variations on the colors being displayed. By default we approximately match the original z26 palettes, but now you can experiment with different tunings or match your own hardware. We gave the phase adjustment a wide enough range that you can set the color of the water in Atlantis to be green, which was popular back in the day, although by default in z26, the color of the water in Atlantis is rather bluish, and with the new wide dynamic range palettes, that shade of blue is a bit deeper than before. In the NTSC palette, the background color in the default interface theme which is named “aqua” is set to the color of Atlantis water so you can adjust the color tuning of the NTSC palette conveniently.

Video Options

       Display............: Full Screen   Full Screen or Window.
       Texture............: Normal Sharp  Fast, normal, and HD – blurry or sharp.
       Width..............: 100           Continuously variable.
       Line Mode..........: Normal        Normal or Scanline.
       Scanline Depth.....: 60            Continuously variable.
       Vsync..............: Yes           Turn Vsync on or off.

       Palette............: Auto          Auto, NTSC, PAL, SECAM, vintage NTSC,
                                          vintage PAL, mame 0.212 NTSC or mame 0.212 PAL.
       Brightness.........: 1.00          Brightness.
       Warmth.............: 0.00          Warmth.
       NTSC Phase.(26.2)..: 26.20         NTSC color adjustment (degrees).
       PAL Phase..(21.5)..: 21.50         PAL color adjustment (degrees).

       Exit                               Return to Main Menu.

Sound Menu

You can turn the sound on and off with this menu.

Sound Options

         Quiet......: No             Disable sound.

         Exit                        Return to Main Menu.

Interface Menu

Here you can tune the user inputs to the game. You can also choose to turn on the scanline and framerate display, as well as set the GUI color scheme.

Interface Options

         Show FPS....: No            Show framerate on game display.
         Theme.......: 5-aqua        Choose colour scheme for GUI.

         Keyboard....: Yes           Enable/Disable Keyboard.
         Mouse.......: Yes           Enable/Disable Mouse.
         Joystick....: Yes           Enable/Disable Joystick.

         Exit                        Return to Main Menu.

Controller Tweaks Menu

Here you can fine-tune how the emulator behaves.

Controller Tweaks

         Mouse Paddle X....: Auto    Paddle to control with mouse X-axis.
         Mouse Paddle Y....: Auto    Paddle to control with mouse Y-axis.
         Paddle Sensitivity: Auto    Sensitivity when controlled by keyboard.
         Paddle Adjust.....: Auto    Paddle delay in scanlines.
         Lightgun cycles...: Auto    Adjust lightgun by N cycles.
         Lightgun scanlines: Auto    Adjust lightgun by N scanlines.

         Exit                        Return to Main Menu.

Debug Menu

Here you can turn on or turn off the debug trace log.

Debug Options

         Trace Log....: Disabled     Write a code trace to z26.log.

         Exit                        Return to Main Menu.

About Menu

 4.xx -- http://www.whimsey.com/z26

         Exit                        Return to Main Menu.

Restoring Defaults

Delete the file z26.gui from the startup directory.
Console Controls

To control the switches on the main console box, use the function keys on the keyboard as follows:

   F1 -- Reset
   F2 -- Select
   F3 -- B/W
   F4 -- Color
   F5 -- Player 0 easy
   F6 -- Player 0 hard
   F7 -- Player 1 easy
   F8 -- Player 1 hard

Paddles

z26 supports the use of the mouse or PC trackball to play paddle games. If you want to change which paddle is emulated with the mouse use the Controller Tweaks Menu. You can change which direction the mouse must be moved in to get paddle motion by pressing the <Tab> key on the keyboard while you're playing a game. You can emulate two paddles with a mouse with one paddle on each axis. You can use the keyboard to play paddle games. If z26 doesn't automatically support a game as a paddle game you may specify which controllers are paddle controllers in the Game Options menu.

Paddles may be controlled from the keyboard as follows:

  Ctrl -- fire paddle 0 Use left and right arrows to move
RShift -- fire paddle 1 Use up and down arrows to move
     n -- fire paddle 2 Use 's' and 'f' to move
     v -- fire paddle 3 Use 'e' and 'd' to move

Joystick

PC or USB joysticks and gamepads are supported to the extent that the operating system and SDL supports them for playing joystick games. The mouse and PC keyboard may also be used. Some games like raiders.bin use the "wrong" joystick. To reverse the joysticks, reverse the ports under the Game Options Menu. Joysticks may be controlled from the keyboard as follows:
Player 0

  Ctrl -- fire  Use the arrow keys to move.
     / -- trigger (booster grip)
RShift -- booster (booster grip)

Player 1

    n -- fire
    s -- left
    e -- up
    f -- right
    d -- down
    b -- trigger (booster grip)
    v -- booster (booster grip)

Driving Controller

z26 suppports the game that uses the driving controller (Indy 500) from the keyboard as follows:
Player 0

       Ctrl -- accelerate
right arrow -- turn clockwise
 left arrow -- turn counter-clockwise

Player 1

          n -- accelerate
          f -- turn clockwise
          s -- turn counter-clockwise

Keyboard Controllers

       Left Port                     Right Port
7 -- 1   8 -- 2   9 -- 3      1 -- 1   2 -- 2   3 -- 3
u -- 4   i -- 5   o -- 6      q -- 4   w -- 5   e -- 6
j -- 7   k -- 8   l -- 9      a -- 7   s -- 8   d -- 9
m -- *   , -- 0   . -- #      z -- *   x -- 0   c -- #

Compumate Keyboard

Use PC keyboard columns 1 - 0

  Ctrl -- FUNC
LShift – SHIFT

Mindlink Controller

Use the mouse to move horizontally.

button -- start the game
   Tab -- switch between player 0 and player 1

Mouse Handling in Paddle emulation

   Tab -- switch between horiz. normal, vert. normal
          and horiz. reversed, and vert reversed

Kid Vid Controller

Use keys 1 2 3 to start the corresponding tape.

F1 stops and rewinds the tape.
Trak-Ball Controllers

Atari sold a Trak-Ball that could be used to play joystick games. z26 supports the use of a mouse or PC trakball to do the same thing for joystick games. Optical trackballs like the Logitech Marble Mouse are great for this. Also z26 emulates the various types of Atari Trak-Balls in their native modes.
Light Gun

z26 supports light gun games (Sentinel, Shooting Gallery) with the mouse.
Keyboard Controllers

z26 enables the keyboard/touch pad/keypad for recognized games that use them.
Booster Grip

z26 supports the booster grip game (Omega Race) from the keyboard and the PC joystick with 3 or more buttons.
Scrolling the Screen

If you don’t like how we’ve positioned the game on the screen you can move it around. These days the relevant keys are the versions of the keys that are not on the ten key pad. I guess you call them the keys on the “nav-cluster.”

 PgUp -- Scroll the screen up.
 PgDn -- Scroll the screen down.
 Home -- Return to the default screen position.

Trace Mode

You can start trace mode by launching z26 from the command line with the -t command line switch, or by enabling it in the Debug menu. It automatically builds a text file called z26.log in your home directory. This file is a log of all instructions executed and shows some other interesting things like the (frame number, scanline number, cpu cycle, tia clock), object positions (P0, P1, M0, M1, BL), cpu flags, registers (A, X, Y, SP), the program counter, the current instruction in hex, and a disassembled listing of the instruction.

Emulator performance slows down quite a bit while writing out this file so you can turn off writing with F12 and turn it back on with F11 to make it easier to get to the part of the game that you're interested in.
Counting Scan Lines and Showing FPS

By enabling the Show FPS option in the Interface Options menu, thee number of scan lines that a game is using as well as its play speed in frames per second (FPS) to be displayed. This is useful for testing PAL games so you can avoid the PAL color loss bug. Of course you can also enable the color loss by turning on the Colour Loss option in the Video Options menu. The display may be toggled with the <Alt-D> key combination.
Inactivating PC controller support

Some Atari controllers are simulated with more than one PC controller. If you are experiencing problems with this, you can disable one or more PC controllers for these Atari controller simulations. For example you might want to disable the PC mouse when you use the keyboard to play an Atari-joystick game, so that accidently pushing the mouse doesn't cause any unwanted movement. Also you might want to disable the PC joystick for paddle games, because the PC joystick always overrides all other PC controllers in the paddle simulation when one is plugged into the PC. Please look at the following table to find out which Atari controllers are simulated with which PC controller.

Atari/PC          keyboard  mouse  joystick
-------------------------------------------
joystick     JS      x        x       x
paddle       PC      x        x       x
keypad       KP      x        -       -
driving      DC      x        x       x
lightgun     LG      -        x       -
Compumate    CM      x        -       -
Kid Vid      KV      x        -       -
Mindlink     ML      -        x       -
ST mouse     ST      -        x       -
Trak-Ball    TB      -        x       -
Amiga mouse  AM      -        x       -

Please note that inactivating the PC controller only works for Atari controllers that are simulated by more than one PC controller.
Colors (palettes)

z26 supports three different sets of colors or palettes. The most common games shipped in North America use the so called NTSC colors. Games shipped in other parts of the world use the so called PAL colors. z26 typically detects the correct colors, but you can override the colors chosen by z26 with the Palette option in the Game Options menu.

z26 also supports the bug in PAL consoles that causes the display to display a monochrome image if a game has the wrong number of scanlines. This feature is enabled with the Colour Loss option in the Video Options menu. Some of the 32-in-1 games which were poorly done PAL hacks show this effect.

SECAM colors can be selected with Palette option in the Game Menu. In the time before the crash Atari created most of it's PAL games in such a way that the B/W switch would enable SECAM compatible colors. So nostalgic gamers from France can play PAL ROMs by selecting this option.
Forcing Black and White mode

You can force a game to start in black and white mode with the Console B/W option in the Game Options menu. Note that this doesn't mean that the game will actually be in black and white, this merely sets the console B/W switch which the game may or may not ignore.
Starpath Games

For most Starpath games, the .bin file must be a multiple of 8448 bytes big. To run multiload games you must concatenate the .bin files. Under Windows, a command like this will do the trick:

     copy /b load1.bin+load2.bin+load3.bin+load4.bin mload.bin

Under Linux something like this will work:

     cat load1.bin load2.bin load3.bin load4.bin > mload.bin

Then run mload.bin in the emulator. z26 supports a maximum of 61 loads.

z26 also supports the 6144 byte Starpath format.

The Extended Tigervision (#11) bankswitch scheme allows ROMs up to 512K in size keeping the last bank fixed. All ROM images that are bigger than 64K and not a multiple of 8448 default to this scheme.

The original Tigervision (#4) bankswitch scheme also supports up to 512K games but with $1800-$1FFF as the fixed bank. This allows compatibility with the Cuttle Cart for games up to 64K in size.
Kid Vid Tapes

z26 supports the Kid Vid games (Smurfs Save the Day and Berenstain Bears) automatically.

Press 1, 2, or 3 to select the corresponding tape. F1 rewinds the tape. In addition to the rom images, you need the wave files with the music in the same directory as z26.

The files may be found at http://www.atariage.com/2600/archives/KidVidAudio/. They are named:

Berenstain Bears:

KVB1.WAV, KVB2.WAV, KVB3.WAV

Smurfs Save the Day:

KVS1.WAV, KVS2.WAV, KVS3.WAV

Both:

KVSHARED.WAV

You can also play the games without the music, but it's much less fun.
Command-line Switches

For information on how the command line switches work, please see the source file cli.c.
Troubleshooting
z26 runs too fast.

It’s possible that your hardware vsync isn’t working but it’s more likely that you’ve set the refresh rate of your monitor too high. Try setting the refresh rate to 60 Hz for NTSC games or to 50 Hz for PAL or SECAM games.
z26 runs too slowly.

Try a faster texture. HD textures are very demanding.
z26 sounds bad.

Turn off the sound in the Sound Menu.
Warranty

Because the program is licensed free of charge, there is no warranty for the program, to the extent permitted by applicable law. Except when otherwise stated in writing the copyright holders and/or other parties provide the program "as is" without warranty of any kind, either expressed or implied, including, but not limited to, the implied warranties of merchantability and fitness for a particular purpose. The entire risk as to the quality and performance of the program is with you. Should the program prove defective, you assume the cost of all necessary servicing, repair or correction. In no event unless required by applicable law or agreed to in writing will any copyright holder, or any other party who may modify and/or redistribute the program as permitted above, be liable to you for damages, including any general, special, incidental or consequential damages arising out of the use or inability to use the program (including but not limited to loss of data or data being rendered inaccurate or losses sustained by you or third parties or a failure of the program to operate with any other programs), even if such holder or other party has been advised of the possibility of such damages.
Tools

On a mac, z26 is built with clang, otherwise z26 is built with GCC. On Windows we use MinGW/Msys. Fonts were designed with CSEDIT by Matt Pritchard.
Credits

Thanks to Yaroslav Stavnichiy from the Stack Overflow community for the mkpath() routine (4.06). Thanks to fluxit for help with directory paths in linux desktop integration (4.06). Thanks to MAME 0.212 for ROM signature code and signatures in vcs_slot.c (4.06). Thanks to Stella for 3E, 3F and E7 ROM signatures (4.06). Thanks to fluxit for help with -no-pie command line switch (4.05). Thanks to “Mike” from the Stack Overflow community for code to find the program launch directory on linux (4.05). Thanks to s0c7 for help with a compiler switch (4.04). Thanks to alex_79 for reporting the problem with the F4 key (4.04). Thanks to MrMaddog for help with the kidvid games (4.03). Thanks to Karl-Heinz Versl for help working out square textures on vintage machines (4.01). Thanks to “Clifford” from the Stack Overflow community for the stristr() routine (4.00).

The following people have made valuable suggestions for new features and/or have helped to identify bugs in z26 3.0: maiki, Thomas Jentzsch, mwalden, Keatah, flammingcowz, SpiceWare, Silvio Mogno.

Eckhard Stolberg has made contributions to z26 that are too numerous to count. He has been involved since the very early days and the high quality emulation that z26 provides would certainly not have been possible without his participation. The TIA and CPU engines in the 3.0 version of z26 were written by Eckhard.

Brian Watson made the 32-bit version of z26 possible and laid the foundation for the GUI.

     Paul Robson -- Wrote original A26.
       Ron Fries -- Original TIA sound emulation.
Ettore Perazzoli -- 6502 undocumented instructions.
   Andreas Boose -- Also 6502 undocumented instructions.
Wolfgang Lorentz -- 6502 diagnostics.
     Bob Colbert -- Object wrapping.
    Piero Cavina -- Multiple missiles.
     Erik Mooney -- HMOVE blanks.
    Kevin Horton -- Bankswitching and Quadrun voice.
       Dan Boris -- Atari 2600 schematics.
  Matt Pritchard -- Font design tools.
      Matt Conte -- Quadrun voice.
     John Dullea -- Fast elegant graphics and Pitfall II.
   Bradford Mott -- Object positioning (weird HMOVE).
   Chris Wilkson -- Pitfall II.
     Lee Krueger -- Kid Vid support, rare carts, and documentation.
 Thomas Jentzsch -- Trace mode, Kid Vid support and fast video routines.
 Henning Mueller -- CompuMate.
 Christian Bogey -- SECAM colors.
   Oliver Achten -- PAL colors.
    Andrew Davie -- Extended Tigervision bankswitch demos.
     Paul Slocum -- Provided EF bankswitch demo.
       Billy Eno -- Provided interleaved display demo.
    Adam Wozniac -- Helped with TIA sound polynomials.
   Matt Matthews -- Linux consulting.
    Brian Watson -- Helped with Linux port, 32-bit ASM-code, GUI framework.
 James Wilkinson -- Helped with BeOS port.
Eckhard Stolberg -- Contributions too numerous to mention.

Thanks to everyone else who has helped with comments, suggestions, bug reports, information, supplies and testing:

Junky, Kevin White, The Boatwrights, Miguel Guzman Centeno, Peter, Jay C. Heil, Zoop, Rob Anderson, Zophar, Peter Vogels, Stephan, Xahji, Ricardo Martinez Garza, Stephano Camarri, Peter Betz, Piero Cavina (Oystron! Helped find multiple missile bug.), Nick S. Bensema, Erik Mooney, Glenn Saunders, Abraham Velazquez, Christian Schaefers (Z-Type), Freirias, Brian Deuel, Chris Platt, Israel Geron T., jose roberto rodrigues, Dan Meyer, Martin Schaefer, Ummagumma, Digitoxin, Michael Walden Jr. (The most elaborate suggestion list!), Gilamonster, Gerald Gorman, Francisco Athens, Lex Nesta, Ben, Gerald Gray, Jose Pedro, Tadd Underhill, Ejber Ozkan, Lord Mhath, Larry Scott, Brad Komgenick, Michael J. Mika, Ettore Perazzoli (VICE), Stephan Eder, Andreas Boose (VICE), David Gray, jimnav, Dr. Simone Zanella, Brad Thomas, Jeff Cockayne, Sam Miller, EmrldSword, justin martin, Justin Scott, Jason Berk, Luis Graterol, Ricardo Soto, Brian Smith, Sam Hard, Keith Merizalde, Nate Marigoni, Kurt Woloch, GreenImp, M. C. Silvius, Matthew Conte (Nofrendo), Jason Barisoff, Rick Vasquez, Marco Turconi, Kalik, Christopher Warren, Curt Vendel, Roberto Sidney Teixeira, raverpup, iCeFiRe, Chism, Sascha Reuter, Craig Tildesley, Michael Prentler, Cody B, Thom Rechak, Cam, Jason, Keith Weisshar, Robin Gravel, Thom Bone, Mrfriend, Edwin Helsloot, C J Biro, Michael Monson, Justin Rodriguez, Francesco Azzurri, Greg Bendokus, Bruce Clarke, John Dullea (PCAE), Tim Boston, Chris Ainsley, Ricardo Henrique Tabone, and Seth Kintigh.

And thanks to Len Shikowitz for *complaining* well beyond the call of duty. Definitely "the most obstinate, yet sincere, tester." :)

At some point I stopped keeping the list of everyone who have sent me suggestions up to date. I apologize for that. But thanks to the folks who have continued to send in suggestions, even though they didn't make the list.

Thanks!!!
