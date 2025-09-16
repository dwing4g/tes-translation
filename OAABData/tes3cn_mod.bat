@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3mod.lua OAAB_Data.txt tes3cn_OAAB_Data.ext.txt topics_OD.txt tes3cn_OAAB_Data.txt

pause
