@echo off
setlocal
pushd %~dp0

cd ..

luajit tes3ext.lua TamrielRebuilt\TR_Mainland.txt TamrielRebuilt\tes3cn_TR_Mainland.txt TamrielRebuilt\tes3cn_TR_Mainland.ext.txt

pause
