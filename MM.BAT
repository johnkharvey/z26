ml /coff /Fl /c /Cp /Zm /Zi z26core.asm
gcc -c z26.c
gcc z26.o z26core.obj -lmingw32 -lSDLmain -lSDL -mwindows -o z26.exe
strip z26.exe
