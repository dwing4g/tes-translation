@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3trim.lua TR_Mainland.txt > TR_Mainland.trim.txt

rem move /y TR_Mainland.trim.txt TR_Mainland.txt

..\luajit ..\tes3trim.lua tes3cn_TR_Mainland.txt > tes3cn_TR_Mainland.trim.txt

move /y tes3cn_TR_Mainland.trim.txt tes3cn_TR_Mainland.txt

pause
