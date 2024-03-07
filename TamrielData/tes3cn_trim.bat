@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3trim.lua Tamriel_Data.txt > Tamriel_Data.trim.txt

rem move /y Tamriel_Data.trim.txt Tamriel_Data.txt

..\luajit ..\tes3trim.lua tes3cn_Tamriel_Data.txt > tes3cn_Tamriel_Data.trim.txt

move /y tes3cn_Tamriel_Data.trim.txt tes3cn_Tamriel_Data.txt

pause
