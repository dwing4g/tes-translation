@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3enc.lua tes3cn_OAAB_Data.txt tes3cn_OAAB_Data.esp

pause
