@echo off
setlocal
pushd %~dp0

repak unpack JY_TraditionalChinese_P.pak
UE4localizationsTool export JY_TraditionalChinese_P\OblivionRemastered\Content\Localization\Game\ja\Game.locres
..\luajit tes4ext.lua Game.en.locres.txt JY_TraditionalChinese_P\OblivionRemastered\Content\Localization\Game\ja\Game.locres.txt Game.tc.ext.txt

pause
