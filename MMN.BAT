echo off
ml /c /Cp /Zm guicore.asm
if errorlevel 1 goto fail
ml /c /Cp /Zm z26core.asm
if errorlevel 1 goto fail
tcc -IC:\DOSTOOLS\TC\INCLUDE -j5 -c -v- -ml -O -a -w-par -w-pia z26.c
if errorlevel 1 goto fail
tlink -LC:\DOSTOOLS\TC\LIB -3 -m C0l z26 z26core guicore,z26,z26,Cl;
if errorlevel 1 goto fail
echo z26 build O.K.
goto exit
:fail
echo z26 build failed.
:exit

