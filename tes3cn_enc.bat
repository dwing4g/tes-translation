@echo off
setlocal
pushd %~dp0

@echo on

luajit tes3enc.lua tes3cn_Morrowind.txt tes3cn_Morrowind.esp.new
luajit tes3enc.lua tes3cn_Tribunal.txt  tes3cn_Tribunal.esp.new
luajit tes3enc.lua tes3cn_Bloodmoon.txt tes3cn_Bloodmoon.esp.new

pause
