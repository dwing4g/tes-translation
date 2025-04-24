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

md OblivionRemastered-Windows-zh-HansPatch\OblivionRemastered\Content\Localization\Game\zh-Hans 2>nul

UE4localizationsTool import Game.locres.txt
move /y Game_NEW.locres OblivionRemastered-Windows-zh-HansPatch\OblivionRemastered\Content\Localization\Game\zh-Hans\Game.locres

rem UnrealLocres import Game.locres Game.csv
rem move /y Game.locres.new OblivionRemastered-Windows-zh-HansPatch\OblivionRemastered\Content\Localization\Game\zh-Hans\Game.locres

repak pack OblivionRemastered-Windows-zh-HansPatch

pause
