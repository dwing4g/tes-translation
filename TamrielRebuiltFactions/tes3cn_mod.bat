@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3mod.lua TR_Factions.txt tes3cn_TR_Factions.ext.txt topics_TD_TR_F.txt tes3cn_TR_Factions.txt

pause
