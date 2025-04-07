@echo off
setlocal
pushd %~dp0

@echo on

..\..\luajit ..\..\tes3dec.lua "Morrowind Patch v1.6.3.esm" 1252 raw > MorrowindPatch1.6.3.txt

pause
