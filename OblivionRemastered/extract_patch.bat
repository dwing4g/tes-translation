@echo off
setlocal
pushd %~dp0

repak unpack OblivionRemastered-Windows-zh-HansPatch_P.pak
UE4localizationsTool export OblivionRemastered-Windows-zh-HansPatch_P\OblivionRemastered\Content\Localization\Game\zh-Hans\Game.locres
..\luajit tes4ext.lua Game.en.locres.txt OblivionRemastered-Windows-zh-HansPatch_P\OblivionRemastered\Content\Localization\Game\zh-Hans\Game.locres.txt Game.fix.ext.txt

pause
