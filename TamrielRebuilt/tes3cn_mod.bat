@echo off
setlocal
pushd %~dp0

@echo on

..\luajit ..\tes3mod.lua TR_Mainland.txt tes3cn_TR_Mainland.ext.txt tes3cn_TR_Mainland.txt

pause
