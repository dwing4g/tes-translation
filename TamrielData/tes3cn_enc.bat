@echo off
setlocal
pushd %~dp0

@echo on

..\luajit ..\tes3enc.lua tes3cn_Tamriel_Data.txt tes3cn_Tamriel_Data.esp

pause
