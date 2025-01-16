# Hit & Miss Indicators

## Links

Source code: https://gitlab.com/MorleyDev/openmw_hitormissindicators

## Requirements

OpenMW 0.49+

## Installation

* Place in Data Files directory or equivalent via OpenMW Data Directories
* Enable HitAndMissIndicators.omwscripts in OpenMW Launcher

## Known Issues/Flaws

* Until OpenMW gets the On Hit API, Hit/Miss calculation has to be done via checking for the various sound effects associated with a weapon swing and a hit on the player and the current crosshair target. This is not 100% reliable, and also adds a slight delay to the Miss appearing (as the swoosh sound can sometimes finish before the hit sound starts playing).
* Since hit/miss is determined via sound effects on actors, if another actor hits the target at the same time as the player it will show up as a hit/punch
* Hit/Miss/Punch indicators only appear for Player Attacks
* Active fatigue or health damage effects on the target can impact the number shown in the hit calculation, as the delta of the targets health and fatigue between the swoosh and the hit sound is used to calculate damage applied

## Things todo

* When OpenMW gets an OnHit API for Lua, use that instead of the current sound-driven approach used in scripts/HitAndMissIndicators/events.lua

## Compatibility

Whilst nothing should break, any mod that alters the hit chance calculations will result in an incorrect percentage being shown on the Miss indicator

## Credits

Safebox's Hit Chance UI for the Hit Chance calculation logic (https://www.nexusmods.com/morrowind/mods/53930)
