tasm -w-ass -dmodule=1 /ml z26.asm
tasm /ml guicore.asm
tcc -v- -ml -O -a -w-par -w-pia -ez26.exe z.c z26.obj guicore.obj
