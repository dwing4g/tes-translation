@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\check_topic.lua topics.txt OAAB_Data.txt OAAB_Data.txt OAAB_Data.fix.txt

..\luajit ..\check_topic.lua topics_OD.txt OAAB_Data.txt tes3cn_OAAB_Data.txt tes3cn_OAAB_Data.fix.txt > errors.txt

if %errorlevel% == 0 (
move /y tes3cn_OAAB_Data.fix.txt tes3cn_OAAB_Data.txt
echo tes3cn_OAAB_Data.txt UPDATED!
)

pause
