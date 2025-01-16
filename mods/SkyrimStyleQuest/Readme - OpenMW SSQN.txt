OpenMW Skyrim Style Quest Notifications
---------------------------------------
version 1.24	by taitechnic

Original MWSE mod by nazz190.

This mod requires OpenMW version 0.49 or better

Displays a popup notification with quest name and matching icon and plays a sound effect, when starting or finishing a quest. Additional icons can be added, by adding entries to the iconlist.lua file.


Installation
------------

Extract the files to your Data Files folder

SSQN.omwscripts should be in Data Files\
player.lua  iconlist.lua  qnamelist.lua  files should end up in Data Files\Scripts\SSQN\
all other .lua files should be in Data Files\Scripts\SSQN\iconlists
sound files in Data Files\Sound\SSQN\
icons in Data Files\Icons\SSQN\

Use the OpenMW launcher to enable the "SSQN.omwscripts" file, or manually add an entry into the openmw.cfg file in your user folder


Playing
-------

Should just work on loading a game/starting a new game.

A preferences screen can be found in Settings in the Scripts section under the heading Skyrim Style Quest Notifications. Options include enable/disable the popup notification, choose whether it is transparent and where it is placed on the screen, how long it displays for, and what sound is played, both for quest Started and separately quest Finished.

There is also a test mode, that once enabled, will repeatedly display the notification on screen so you can preview what it will look like.

All vanilla quests in Morrowind/Tribunal/Bloodmoon should show their correct quest name. Any mod created quest will display only their QuestID, unless you add their names into the qnamelist.lua file.


** NEW! **
If you're using a version of OpenMW 0.49 released on May 10th 2024 or later, needing an updated qnamelist.lua file will no longer be needed. Quest notifications should always show the correct Quest name, even for newly released Mods.

For older versions of OpenMW, SSQN will still work as normal, but you will continue to need an updated qnamelist.lua file for any new Mods.


If a downloaded Mod comes with its own .lua file containing custom icon lists for OpenMW SSQN, this can be placed in the "iconlists" folder, so they can show their own unique icons for their quest notifications.

Additionally, these mods will also have their quest names show properly :

	Tamriel Rebuilt
	Skyrim: Home of the Nords
	AFFresh
	The Doors of Oblivion
	Ebonheart Underworks
	Tamriel Rebuilt Introduction Quest
	The Mysterious Affair of Sara Shenk
	Rise of House Telvanni
	Imperial Legion Expansion
	Census and Excise Office Faction
	Astrologian's Guild
	Join the Dark Brotherhood
	Quest for Clans and Vampire Legends
	Uvirith's Legacy
	Building Up Uvirith's Legacy
	The Adamantium Helm of Tohan
	Siege at Firemoth
	The Master Index
	OAAB Shipwrecks
	Sadrith Mora BCOM Plus Module
	Fargoth Says Hello
	The Mananaut's Message
	Secrets of the Crystal City
	Greymarch Dawn
	Caldera Mine Expanded
	The Search for the White Wave
	Aspect of Azura
	Investigations at Tel Eurus
	Lord of Rebirth
	Frozen in Time
	Aether Pirate's Discovery
	Silent Island
	Mudcrab Imports
	Caldera Priory and the Depths of Blood and Bone
	Terror of Tel Amur
	A Cold Cell
	Galen's Quest for Truth
	Welcome to the Arena
	Early Transport to Mournhold
	Keelhouse
	Immersive Imperial Skirt
	Sorcerer of Alteration
	Something in the Water
	Vivec Lighthouse Keeper
	Ancient Foes
	Apothecary's Demise
	Temple Master
	Ranis Athrys - Let Go and Begin Again
	OAAB Brother Junipers Twin Lamps
	Mages Guild Stronghold - Nchagalelft
	PlayerHomes
	Signpost Fast Travel
	Red Wisdom
	Imperial Employment Office


Credits
-------

nazz190 for the original mod, and the many others who helped contribute extra content to it that was also used in this mod

TeodoroBagwell for added script logic and the Tamriel Rebuilt entries for the quest names file

settyness for sorting through many popular mods and supplying their quest names for entry into the quest name file
