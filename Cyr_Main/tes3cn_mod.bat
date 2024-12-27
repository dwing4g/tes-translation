@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3mod.lua Cyr_Main.txt tes3cn_Cyr_Main.ext.txt topics_Cyr_Main.txt tes3cn_Cyr_Main.txt

pause
