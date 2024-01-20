@echo off
setlocal
pushd %~dp0

@echo on

luajit tes3trim.lua tes3cn_Morrowind.txt > tes3cn_Morrowind.txt.new
luajit tes3trim.lua tes3cn_Tribunal.txt  > tes3cn_Tribunal.txt.new
luajit tes3trim.lua tes3cn_Bloodmoon.txt > tes3cn_Bloodmoon.txt.new

move /y tes3cn_Morrowind.txt.new tes3cn_Morrowind.txt
move /y tes3cn_Tribunal.txt.new  tes3cn_Tribunal.txt
move /y tes3cn_Bloodmoon.txt.new tes3cn_Bloodmoon.txt

pause
