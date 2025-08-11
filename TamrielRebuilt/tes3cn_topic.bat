@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\check_topic.lua topics.txt TR_Mainland.txt TR_Mainland.txt TR_Mainland.fix.txt

..\luajit ..\check_topic.lua topics_TD_TR.txt TR_Mainland.txt tes3cn_TR_Mainland.txt tes3cn_TR_Mainland.fix.txt > errors.txt

if %errorlevel% == 0 (
move /y tes3cn_TR_Mainland.fix.txt tes3cn_TR_Mainland.txt
echo tes3cn_TR_Mainland.txt UPDATED!
)

pause
