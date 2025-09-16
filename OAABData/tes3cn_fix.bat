@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3fix.lua tes3cn_OAAB_Data.ext.txt

pause
