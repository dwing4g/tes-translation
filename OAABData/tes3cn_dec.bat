@echo off
setlocal
pushd %~dp0

rem ..\luajit ..\tes3dec.lua OAAB_Data.esm 1252 raw > OAAB_Data.txt

..\luajit ..\tes3dec.lua tes3cn_OAAB_Data.esp gbk raw > tes3cn_OAAB_Data.txt

pause
