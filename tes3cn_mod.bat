@echo off
setlocal
pushd %~dp0

@echo on

luajit tes3mod.lua Morrowind.txt tes3cn_Morrowind.ext.txt tes3cn_Morrowind.mod.txt
luajit tes3mod.lua Tribunal.txt  tes3cn_Tribunal.ext.txt  tes3cn_Tribunal.mod.txt
luajit tes3mod.lua Bloodmoon.txt tes3cn_Bloodmoon.ext.txt tes3cn_Bloodmoon.mod.txt

@echo off

rem FOR TEST
rem luajit tes3mod.lua Morrowind.txt tes3cn_Morrowind.ext2.txt tes3cn_Morrowind.mod2.txt
rem luajit tes3mod.lua Tribunal.txt  tes3cn_Tribunal.ext2.txt  tes3cn_Tribunal.mod2.txt
rem luajit tes3mod.lua Bloodmoon.txt tes3cn_Bloodmoon.ext2.txt tes3cn_Bloodmoon.mod2.txt

rem fc /b tes3cn_Morrowind.mod.txt tes3cn_Morrowind.mod2.txt
rem fc /b tes3cn_Tribunal.mod.txt  tes3cn_Tribunal.mod2.txt
rem fc /b tes3cn_Bloodmoon.mod.txt tes3cn_Bloodmoon.mod2.txt

pause
