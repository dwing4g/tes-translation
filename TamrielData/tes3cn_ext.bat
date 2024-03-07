@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3ext.lua Tamriel_Data.txt tes3cn_Tamriel_Data.txt topics_TD.txt tes3cn_Tamriel_Data.ext.txt

pause
