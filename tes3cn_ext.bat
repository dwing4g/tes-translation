@echo off
setlocal
pushd %~dp0

@echo on

luajit tes3ext.lua Morrowind.txt tes3cn_Morrowind.txt tes3cn_Morrowind.ext.txt
luajit tes3ext.lua Tribunal.txt  tes3cn_Tribunal.txt  tes3cn_Tribunal.ext.txt
luajit tes3ext.lua Bloodmoon.txt tes3cn_Bloodmoon.txt tes3cn_Bloodmoon.ext.txt

pause
