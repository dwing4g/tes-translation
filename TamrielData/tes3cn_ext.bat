@echo off
setlocal
pushd %~dp0

@echo on

..\luajit ..\tes3ext.lua Tamriel_Data.txt tes3cn_Tamriel_Data.txt tes3cn_Tamriel_Data.ext.txt

pause
