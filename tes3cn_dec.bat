@echo off
setlocal
pushd %~dp0

rem luajit tes3dec.lua Morrowind.esm 1252 raw > Morrowind.txt
rem luajit tes3dec.lua Tribunal.esm  1252 raw > Tribunal.txt
rem luajit tes3dec.lua Bloodmoon.esm 1252 raw > Bloodmoon.txt

@echo on

luajit tes3dec.lua tes3cn_Morrowind.esp gbk raw > tes3cn_Morrowind.txt
luajit tes3dec.lua tes3cn_Tribunal.esp  gbk raw > tes3cn_Tribunal.txt
luajit tes3dec.lua tes3cn_Bloodmoon.esp gbk raw > tes3cn_Bloodmoon.txt

pause
