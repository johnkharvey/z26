echo off
masm /Ml guicore.asm;
if errorlevel 1 goto fail
masm /Ml z26core.asm;
if errorlevel 1 goto fail
tcc -c -v- -ml -O -a -w-par -w-pia z26.c
if errorlevel 1 goto fail
tlink -LC:\OLDDRIVE\TC\LIB -3 -m C0l z26 z26core guicore,z26,z26,Cl;
if errorlevel 1 goto fail
echo z26 build O.K.
goto exit
:fail
echo z26 build failed.
:exit

