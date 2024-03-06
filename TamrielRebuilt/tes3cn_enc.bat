@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3enc.lua tes3cn_TR_Mainland.txt tes3cn_TR_Mainland.esp

pause
