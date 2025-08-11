@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3ext.lua TR_Mainland.txt TR_Mainland.txt topics.txt tes3cn_TR_Mainland.ext.txt

..\luajit ..\tes3ext.lua TR_Mainland.txt tes3cn_TR_Mainland.txt topics_TD_TR.txt tes3cn_TR_Mainland.ext.txt

pause
