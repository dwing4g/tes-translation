@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3fix.lua tes3cn_TR_Factions.ext.txt

pause
