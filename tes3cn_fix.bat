@echo off
setlocal
pushd %~dp0

@echo on

luajit tes3fix.lua tes3cn_Morrowind.ext.txt
luajit tes3fix.lua tes3cn_Tribunal.ext.txt
luajit tes3fix.lua tes3cn_Bloodmoon.ext.txt

pause
