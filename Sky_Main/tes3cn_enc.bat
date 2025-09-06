@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3enc.lua tes3cn_Sky_Main.txt tes3cn_Sky_Main.esp

pause
