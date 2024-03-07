@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3dec.lua TR_Factions.esm 1252 raw > TR_Factions.txt

..\luajit ..\tes3dec.lua tes3cn_TR_Factions.esp gbk raw > tes3cn_TR_Factions.txt

pause
