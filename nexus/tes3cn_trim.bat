@echo off
setlocal
pushd %~dp0

@echo on

..\luajit ..\tes3trim.lua tes3cn_Morrowind.txt > tes3cn_Morrowind.trim.txt
..\luajit ..\tes3trim.lua tes3cn_Tribunal.txt  > tes3cn_Tribunal.trim.txt
..\luajit ..\tes3trim.lua tes3cn_Bloodmoon.txt > tes3cn_Bloodmoon.trim.txt

move /y tes3cn_Morrowind.trim.txt tes3cn_Morrowind.txt
move /y tes3cn_Tribunal.trim.txt  tes3cn_Tribunal.txt
move /y tes3cn_Bloodmoon.trim.txt tes3cn_Bloodmoon.txt

pause
