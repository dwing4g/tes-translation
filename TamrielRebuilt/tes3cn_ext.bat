@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3ext.lua TR_Mainland.txt tes3cn_TR_Mainland.txt topics_TD_TR.txt tes3cn_TR_Mainland.ext.txt

pause
