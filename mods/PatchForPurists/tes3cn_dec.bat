@echo off
setlocal
pushd %~dp0

@echo on

..\..\luajit ..\..\tes3dec.lua "Patch for Purists.esm" 1252 raw > "Patch for Purists.txt"

pause
