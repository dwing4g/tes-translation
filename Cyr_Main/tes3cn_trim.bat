@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3trim.lua Cyr_Main.txt > Cyr_Main.trim.txt

rem move /y Cyr_Main.trim.txt Cyr_Main.txt

..\luajit ..\tes3trim.lua tes3cn_Cyr_Main.txt > tes3cn_Cyr_Main.trim.txt

move /y tes3cn_Cyr_Main.trim.txt tes3cn_Cyr_Main.txt

pause
