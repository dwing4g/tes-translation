@echo off
setlocal
pushd %~dp0

..\luajit ..\check_topic.lua ..\topics.txt TR_Mainland.txt tes3cn_TR_Mainland.txt tes3cn_TR_Mainland.fix.txt > errors.txt

if %errorlevel% == 0 (
move /y tes3cn_TR_Mainland.fix.txt tes3cn_TR_Mainland.txt
echo tes3cn_TR_Mainland.txt UPDATED!
)

pause
