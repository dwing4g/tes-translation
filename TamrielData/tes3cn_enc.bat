@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3enc.lua tes3cn_Tamriel_Data.txt tes3cn_Tamriel_Data.esp

pause
