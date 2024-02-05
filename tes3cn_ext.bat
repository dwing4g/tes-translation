@echo off
setlocal
pushd %~dp0

@echo on

luajit tes3ext.lua Morrowind.txt tes3cn_Morrowind.txt tes3cn_Morrowind.ext.txt
luajit tes3ext.lua Tribunal.txt  tes3cn_Tribunal.txt  tes3cn_Tribunal.ext.txt
luajit tes3ext.lua Bloodmoon.txt tes3cn_Bloodmoon.txt tes3cn_Bloodmoon.ext.txt

@echo off

rem FOR TEST
rem luajit tes3ext.lua Morrowind.txt tes3cn_Morrowind.mod.txt tes3cn_Morrowind.ext2.txt
rem luajit tes3ext.lua Tribunal.txt  tes3cn_Tribunal.mod.txt  tes3cn_Tribunal.ext2.txt
rem luajit tes3ext.lua Bloodmoon.txt tes3cn_Bloodmoon.mod.txt tes3cn_Bloodmoon.ext2.txt

rem fc /b tes3cn_Morrowind.ext.txt tes3cn_Morrowind.ext2.txt
rem fc /b tes3cn_Tribunal.ext.txt  tes3cn_Tribunal.ext2.txt
rem fc /b tes3cn_Bloodmoon.ext.txt tes3cn_Bloodmoon.ext2.txt

pause
