@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3ext.lua OAAB_Data.txt OAAB_Data.txt topics.txt tes3cn_OAAB_Data.ext.txt

..\luajit ..\tes3ext.lua OAAB_Data.txt tes3cn_OAAB_Data.txt topics_OD.txt tes3cn_OAAB_Data.ext.txt

pause
