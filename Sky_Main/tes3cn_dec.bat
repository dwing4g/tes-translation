@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3dec.lua Sky_Main.esm 1252 raw > Sky_Main.txt

..\luajit ..\tes3dec.lua tes3cn_Sky_Main.esp gbk raw > tes3cn_Sky_Main.txt

pause
