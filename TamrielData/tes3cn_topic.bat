@echo off
setlocal
pushd %~dp0

..\luajit ..\check_topic.lua topics_TD.txt Tamriel_Data.txt tes3cn_Tamriel_Data.txt tes3cn_Tamriel_Data.fix.txt > errors.txt

if %errorlevel% == 0 (
move /y tes3cn_Tamriel_Data.fix.txt tes3cn_Tamriel_Data.txt
echo tes3cn_Tamriel_Data.txt UPDATED!
)

pause
