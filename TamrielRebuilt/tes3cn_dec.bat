@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3dec.lua TR_Mainland.esm 1252 raw > TR_Mainland.txt

@echo on

..\luajit ..\tes3dec.lua tes3cn_TR_Mainland.esp gbk raw > tes3cn_TR_Mainland.txt

pause
