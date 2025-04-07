@echo off
setlocal
pushd %~dp0

@echo on

..\..\luajit ..\..\tes3ext.lua "..\..\Morrowind.txt+..\..\Tribunal.txt+..\..\Bloodmoon.txt" MorrowindPatch1.6.3.txt ..\..\topics.txt MorrowindPatch1.6.3.diff.txt

pause
