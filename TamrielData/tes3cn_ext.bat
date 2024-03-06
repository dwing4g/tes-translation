@echo off
setlocal
pushd %~dp0

cd ..

luajit tes3ext.lua TamrielData\Tamriel_Data.txt TamrielData\tes3cn_Tamriel_Data.txt TamrielData\tes3cn_Tamriel_Data.ext.txt

pause
