@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3ext.lua Sky_Main.txt tes3cn_Sky_Main.txt topics_Sky_Main.txt tes3cn_Sky_Main.ext.txt

pause
