@echo off
setlocal
pushd %~dp0

@echo on

luajit tes3dec.lua tes3cn_Morrowind.esp gbk raw > tes3cn_Morrowind.txt
luajit tes3dec.lua tes3cn_Tribunal.esp  gbk raw > tes3cn_Tribunal.txt
luajit tes3dec.lua tes3cn_Bloodmoon.esp gbk raw > tes3cn_Bloodmoon.txt

pause
