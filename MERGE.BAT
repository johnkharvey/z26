ren z26core.asm x26core.asm
copy head.asm+extern.asm+defs.asm+init.asm+service.asm+position.asm z1.asm
copy paddle.asm+keyboard.asm+mouse.asm z2.asm
copy main.asm+banks.asm+pitfall2.asm+starpath.asm z3.asm
copy riot.asm+cpu.asm+cpujam.asm+cpuhand.asm z4.asm
copy trace.asm+tiatab.asm+tiawrite.asm+tialine.asm+tiasnd.asm+tail.asm z5.asm
copy z1.asm+z2.asm+z3.asm+z4.asm+z5.asm z26core.asm
del z1.asm
del z2.asm
del z3.asm
del z4.asm
del z5.asm
