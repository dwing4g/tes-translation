@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3trim.lua Sky_Main.txt > Sky_Main.trim.txt

rem move /y Sky_Main.trim.txt Sky_Main.txt

..\luajit ..\tes3trim.lua tes3cn_Sky_Main.txt > tes3cn_Sky_Main.trim.txt

move /y tes3cn_Sky_Main.trim.txt tes3cn_Sky_Main.txt

pause
