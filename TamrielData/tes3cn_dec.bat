@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3dec.lua Tamriel_Data.esm 1252 raw > Tamriel_Data.txt

@echo on

..\luajit ..\tes3dec.lua tes3cn_Tamriel_Data.esp gbk raw > tes3cn_Tamriel_Data.txt

pause
