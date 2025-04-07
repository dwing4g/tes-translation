@echo off
setlocal
pushd %~dp0

@echo on

..\..\luajit ..\..\tes3trim.lua MorrowindPatch1.6.3.txt > MorrowindPatch1.6.3.trim.txt

move /y MorrowindPatch1.6.3.trim.txt MorrowindPatch1.6.3.txt

pause
