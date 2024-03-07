@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3mod.lua TR_Mainland.txt tes3cn_TR_Mainland.ext.txt topics_TD_TR.txt tes3cn_TR_Mainland.txt

pause
