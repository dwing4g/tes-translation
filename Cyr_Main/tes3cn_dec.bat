@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3dec.lua Cyr_Main.esm 1252 raw > Cyr_Main.txt

..\luajit ..\tes3dec.lua tes3cn_Cyr_Main.esp gbk raw > tes3cn_Cyr_Main.txt

pause
