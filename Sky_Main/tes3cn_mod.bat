@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3mod.lua Sky_Main.txt tes3cn_Sky_Main.ext.txt topics_TD_Sky_Main.txt tes3cn_Sky_Main.txt

pause
