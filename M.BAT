gcc -c %1.c
gcc %1.o -lmingw32 -lSDLmain -lSDL -mwindows -o%1.exe
strip %1.exe
