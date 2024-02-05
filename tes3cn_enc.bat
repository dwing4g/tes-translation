@echo off
setlocal
pushd %~dp0

@echo on

luajit tes3enc.lua tes3cn_Morrowind.txt tes3cn_Morrowind.enc.esp
luajit tes3enc.lua tes3cn_Tribunal.txt  tes3cn_Tribunal.enc.esp
luajit tes3enc.lua tes3cn_Bloodmoon.txt tes3cn_Bloodmoon.enc.esp

pause
