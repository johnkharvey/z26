
### Attention Windows users: If you don't have a UNIX-emulation
### environment set up (e.g. Cygwin or MSys), you won't be able
### to use this Makefile. Instead, you can just run MM.BAT in this
### directory, to build Z26.EXE (Obviously, you still need GCC and
### NASM on your PATH).


### Build environment. Tweak to match your setup:

# What compiler? Only tested with gcc-2.95.3 and gcc-3.2 so far
# CC=/usr/local/gcc32/bin/gcc
CC=gcc

# Tested SDL 1.2.3 and 1.2.7, same results with either.
# SDLCONFIG=/home/urchlay/sdl_static/bin/sdl-config
SDLCONFIG=sdl-config

## sdl-config doesn't set -O2 for us, but we want it
CFLAGS=-O2

## To build a static binary:
## ...except the static build is broken right now, sorry!
# CFLAGS=-O2 -static

# For a debugging build:
# CFLAGS=-g -Wall -pedantic

## shouldn't need anything here (sdl-config does it for us)
LDFLAGS=

## Also need this for a static bin
# LDFLAGS=-static

## Tested with nasm version 0.98.33
NASM=nasm
NASMFLAGS=-felf

# for Win32 try this if -felf doesn't work:
# NASMFLAGS=-felf --prefix _

### No user-serviceable parts below (unless you know what you're doing!)
all: z26

z26: z26.o z26core.o
	$(CC) $(LDFLAGS) `$(SDLCONFIG) --libs` z26.o z26core.o -o z26 

z26.o: config.h bintoasm.c carts.c cli.c controls.c ct.c \
	genclr.c globals.c kidvid.c mt.c palette.c pcx.c \
	pixcopy.c sdlsrv.c text.c trace.c tracex.c winsrv.c z26.c
	$(CC) $(CFLAGS) `$(SDLCONFIG) --cflags` -c z26.c

z26core.o: z26core.asm
	$(NASM) $(NASMFLAGS) -o z26core.o z26core.asm

pixcopy.c: pixcopy.m4
	m4 pixcopy.m4 > pixcopy.c

clean:
	rm -f *.o z26
