md .\releases\%1
copy z26.exe .\releases\%1
copy z26.ico .\releases\%1
copy readme.txt .\releases\%1
copy copying.txt .\releases\%1
copy starpath.das .\releases\%1
copy *.asm .\releases\%1
copy *.c .\releases\%1
copy *.f8 .\releases\%1
copy mm.bat .\releases\%1
copy mmn.bat .\releases\%1
copy release.bat .\releases\%1
cd .\releases\%1
pkzip z26%1s.zip *.c *.asm *.f8 *.das *.bat copying.txt
pkzip z26%1x.zip *.exe *.txt z26.ico
