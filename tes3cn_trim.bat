@echo off
setlocal
pushd %~dp0

rem luajit tes3trim.lua Morrowind.txt > Morrowind.txt.new
rem luajit tes3trim.lua Tribunal.txt  > Tribunal.txt.new
rem luajit tes3trim.lua Bloodmoon.txt > Bloodmoon.txt.new

rem move /y Morrowind.txt.new Morrowind.txt
rem move /y Tribunal.txt.new  Tribunal.txt
rem move /y Bloodmoon.txt.new Bloodmoon.txt

@echo on

luajit tes3trim.lua tes3cn_Morrowind.txt > tes3cn_Morrowind.txt.new
luajit tes3trim.lua tes3cn_Tribunal.txt  > tes3cn_Tribunal.txt.new
luajit tes3trim.lua tes3cn_Bloodmoon.txt > tes3cn_Bloodmoon.txt.new

move /y tes3cn_Morrowind.txt.new tes3cn_Morrowind.txt
move /y tes3cn_Tribunal.txt.new  tes3cn_Tribunal.txt
move /y tes3cn_Bloodmoon.txt.new tes3cn_Bloodmoon.txt

pause
