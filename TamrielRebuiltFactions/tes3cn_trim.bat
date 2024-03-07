@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3trim.lua TR_Factions.txt > TR_Factions.trim.txt

rem move /y TR_Factions.trim.txt TR_Factions.txt

..\luajit ..\tes3trim.lua tes3cn_TR_Factions.txt > tes3cn_TR_Factions.trim.txt

move /y tes3cn_TR_Factions.trim.txt tes3cn_TR_Factions.txt

pause
