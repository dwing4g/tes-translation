@echo off
setlocal
pushd %~dp0

luajit check_topic.lua topics.txt > errors.txt

if %errorlevel% == 0 (
move /y tes3cn_Morrowind.fix.txt tes3cn_Morrowind.txt
move /y tes3cn_Tribunal.fix.txt  tes3cn_Tribunal.txt
move /y tes3cn_Bloodmoon.fix.txt tes3cn_Bloodmoon.txt
echo tes3cn_*.txt UPDATED!
)

pause
