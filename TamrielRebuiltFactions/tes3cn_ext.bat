@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3ext.lua TR_Factions.txt tes3cn_TR_Factions.txt topics_TD_TR_F.txt tes3cn_TR_Factions.ext.txt

pause
