tasm -dmodule=1 /ml z26.asm
tcc -O -a -ez26.exe z.c z26.obj
tasm -dmodule=1 -dtrace=1 /ml z26.asm
tcc -O -a -ez26t.exe z.c z26.obj
