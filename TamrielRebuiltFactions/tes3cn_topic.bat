@echo off
setlocal
pushd %~dp0

..\luajit ..\check_topic.lua topics_TD_TR_F.txt TR_Factions.txt tes3cn_TR_Factions.txt tes3cn_TR_Factions.fix.txt > errors.txt

if %errorlevel% == 0 (
move /y tes3cn_TR_Factions.fix.txt tes3cn_TR_Factions.txt
echo tes3cn_TR_Factions.txt UPDATED!
)

pause
