@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3fix.lua tes3cn_Cyr_Main.ext.txt

pause
