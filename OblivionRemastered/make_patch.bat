@echo off
setlocal
pushd %~dp0

rem repak.exe: https://github.com/trumank/repak
rem repak unpack OblivionRemastered-Windows.pak
rem repak pack OblivionRemastered-Windows

rem UE4localizationsTool.exe+Csv.dll: https://github.com/amrshaheen61/UE4LocalizationsTool
rem Game.locres                 => Game.locres.txt: UE4localizationsTool export Game.locres
rem Game.locres+Game.locres.txt => Game_NEW.locres: UE4localizationsTool import Game.locres.txt

rem UnrealLocres: https://github.com/akintos/UnrealLocres
rem Game.locres          => Game.csv       : UnrealLocres export Game.locres
rem Game.locres+Game.csv => Game.locres.new: UnrealLocres import Game.locres Game.csv

rem ..\luajit tes4ext.lua Game.en.locres.txt Game.locres.txt Game.ext.txt

rem font: OblivionRemastered\Content\Art\Fonts\NotoSerif_SimplifiedChinese\NotoSerifSC-Regular.ufont+NotoSerifSC-Bold.ufont 14.1M*2

md zh-Hans_P\OblivionRemastered\Content\Localization\Game\zh-Hans 2>nul

UE4localizationsTool import Game.locres.txt
move /y Game_NEW.locres zh-Hans_P\OblivionRemastered\Content\Localization\Game\zh-Hans\Game.locres

rem UnrealLocres import Game.locres Game.csv
rem move /y Game.locres.new zh-Hans_P\OblivionRemastered\Content\Localization\Game\zh-Hans\Game.locres

repak pack zh-Hans_P

pause
