@echo off
setlocal
pushd %~dp0

@echo on

..\..\luajit ..\..\tes3trim.lua "Patch for Purists.txt" > "Patch for Purists.trim.txt"
..\..\luajit ..\..\tes3ext.lua "..\..\Morrowind.txt+..\..\Tribunal.txt+..\..\Bloodmoon.txt" "Patch for Purists.trim.txt" ..\..\topics.txt "Patch for Purists.diff.txt"

pause
