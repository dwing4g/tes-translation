@echo off
setlocal
pushd %~dp0

rem luajit tes3trim.lua Morrowind.txt > Morrowind.trim.txt
rem luajit tes3trim.lua Tribunal.txt  > Tribunal.trim.txt
rem luajit tes3trim.lua Bloodmoon.txt > Bloodmoon.trim.txt

rem move /y Morrowind.trim.txt Morrowind.txt
rem move /y Tribunal.trim.txt  Tribunal.txt
rem move /y Bloodmoon.trim.txt Bloodmoon.txt

@echo on

luajit tes3trim.lua tes3cn_Morrowind.txt > tes3cn_Morrowind.trim.txt
luajit tes3trim.lua tes3cn_Tribunal.txt  > tes3cn_Tribunal.trim.txt
luajit tes3trim.lua tes3cn_Bloodmoon.txt > tes3cn_Bloodmoon.trim.txt

move /y tes3cn_Morrowind.trim.txt tes3cn_Morrowind.txt
move /y tes3cn_Tribunal.trim.txt  tes3cn_Tribunal.txt
move /y tes3cn_Bloodmoon.trim.txt tes3cn_Bloodmoon.txt

pause
