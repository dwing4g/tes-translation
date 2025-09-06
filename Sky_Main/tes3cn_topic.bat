@echo off
setlocal
pushd %~dp0

..\luajit ..\check_topic.lua topics_Sky_Main.txt Sky_Main.txt tes3cn_Sky_Main.txt tes3cn_Sky_Main.fix.txt > errors.txt

if %errorlevel% == 0 (
move /y tes3cn_Sky_Main.fix.txt tes3cn_Sky_Main.txt
echo tes3cn_Sky_Main.txt UPDATED!
)

pause
