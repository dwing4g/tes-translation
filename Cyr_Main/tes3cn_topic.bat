@echo off
setlocal
pushd %~dp0

..\luajit ..\check_topic.lua topics_Cyr_Main.txt Cyr_Main.txt tes3cn_Cyr_Main.txt tes3cn_Cyr_Main.fix.txt > errors.txt

if %errorlevel% == 0 (
move /y tes3cn_Cyr_Main.fix.txt tes3cn_Cyr_Main.txt
echo tes3cn_Cyr_Main.txt UPDATED!
)

pause
