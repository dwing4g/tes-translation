************************************************************************************************
Graphic Herbalism: MWSE and OpenMW Edition
by Greatness7 and Stuporstar

Version 1.04
Requires MGE XE and MWSE 2.1 dev or OpenMW's latest nightly
Requires Morrowind, Tribunal, and Bloodmoon

Contact: sarahdimento@gmail.com
@Stuporstar#1172 https://discord.me/mwmods

Live tech support is available on the Morrowind Modding Discord: https://discord.gg/vnsgE35
************************************************************************************************
************************************************************************************************
It's finally time to ditch the scripts with the new Graphic Herbalism!
The old scripted containers were one of the largest CPU sinks you could add to your game. Without the scripts, this new GH is optimal. All the old meshes have been optimized as well.

Automatically harvests herbs just like the old Graphic Herbalism, but using the container's leveled lists. This means it's compatible with any mod that alters the contents or containers leveled lists, without patches.

************************************************************************************************
MWSE Features (not currently available in OpenMW version)
************************************************************************************************
The MWSE script adds tooltips so you can see what ingredients you're picking. It even hides effects depending on your alchemy skill.

Has MCM configuration menu, so you can tweak settings easily in-game. Current features include:
Turn tooltips on and off - if you're running another mod, like Quickloot, turning GH tooltips off will default to whichever mod handles tooltips next in the list
Turn message boxes on or off.
Adjust volume of harvesting sound
Blacklist and Whitelist tabs - pulls from all currently loaded mods to seach for organic containers

************************************************************************************************
Installation & Load Order
************************************************************************************************
First make sure you have installed the following:
MGEXE - https://www.nexusmods.com/morrowind/mods/41102

MWSE 2.1 Development version - https://nullcascade.com/mwse/mwse-dev.zip

Easy MCM is no longer required because it's been merged into MWSE itself.

Install the core mod and then install the smoothed meshes if you prefer. Optional meshes for replacers are included in separate downloads.
Install GH meshes AFTER you've installed all your mods that include flora and ore replacers. This includes Morrowind Rebirth!
If you get an error message to update MWSE, use the MWSE-Update.exe. Same goes for MCM in the Mod Config menu.
This mod will run without Easy MCM, but you won't be able to configure it in the mod config menu - the extra trouble is worth it.

The optional package includes meshes from many popular replacers, packaged so you can pick and choose in any installer.

They are ordered to overwrite each other with the optimum load order.
In most cases YOU MUST DOWNLOAD THE ORIGINAL MODS FOR THEIR TEXTURES.
Diverse UV Correct Ore does not need the original esp, as it needed bug-fixing for this mod, so it's included in the Patches and Replacers archive.

DON'T INSTALL EVERY OPTION WITHOUT CHECKING THEIR REQUIREMENTS, LIKE A TOTAL NUMPTY - SEE REPLACER README FOR REQUIREMENTS.


If using a replacer that includes the NEW switch-noded Graphic Herbalism meshes, load those after this mod.

#############################################
BEST INSTALLATION ORDER FOR OPTIMIZED VANILLA:

00 Vanilla Meshes (includes necessary textures and Correct UV Ore Diversity)
Glowing Bitter Coast (only if you use that mod)
Atlas - Vanilla BC Mushrooms (make sure you have the right atlas textures)
Atlas - Glowing Bitter Coast Patch (if you use that option)

#######################################
MY RECOMMENDED SMOOTHED INSTALLATION ORDER:

00 Vanilla Meshes (includes necessary textures and Correct UV Ore Diversity)
01 Smoothed Meshes (includes some upscaled GH textures)
Diverse UV Correct Ore and one of the esps (optional)
Pherim's Replacers (make sure you install Pherim's textures)
Pherim Pulsing Kwama (personal preference)
Vurt's Chokeweed & Roobrush (if you want more lush plants/are using Vurt's textures, if not - smoothed vanilla ones are already covered in the smoothed meshes folder)
Less Epic Plants (includes textures)
Glowing Bitter Coast (only if you use that mod)
Atlas - Smoothed BC Mushrooms (make sure you have the right atlas textures)
Atlas - Smoothed Glowmap Patch (if you use that option)

The rest are not ones I use personally, but they're all numbered in the right installation order

If you are using Articus Epic Plants, I recommend installing Epic Plants first and the GH meshes after, which work fine with his textures.
Epic Plants meshes for Graphic Herbalism will be maintained on Articus' Epic Plants Download Page, so they're not included.
If you prefer Articus' Ascadian Isle flora, those are the only ones significantly different from the smoothed meshes already included in this mod (smoothed meshes, atlas, and Pherim's cover just about everything)
If you do use the GH Epic Plants meshes, make sure they are the new versions with the HerbalismSwitch, not the old GH picked meshes he also included.
Be aware that many Epic Plants meshes are excessively high poly, so I suggest reinstalling these GH meshes if your performance is significantly hit.

OpenMW Users DO NOT USE the following:

Pherim Reflection Mapped
Pherim Pulsing Kwama Reflect
Apel's Mucksponge Bumpmapped
Trama Bumpmapped

Reflection maps have removed from Pherim and Apel's base folders.

************************************************************************************************
Compatibility
************************************************************************************************
OpenMW - Fully compatible with the lastest nightly's native Graphic Herbalism.
You only need the meshes, not the MWSE scripts.

Quickloot - requires the latest version of mort's quickloot. Older versions are not compatible.
Expanded Sounds - all scripted flora have been whitelisted, so it should be compatible.
Happy Harvesting - no conflict, but HH is redundant.
Pearls Enhanced - 100% Compatible, no patches necessary.
MW Inhabitants - has scripted flora, but Expanded Sounds whitelist seems to have taken care of that, so it's compatible.

Morrowind Rebirth - install Graphic Herbalism after installing Rebirth and it should be fine.
Morrowind Crafting - Compatibilty meshes are included in main mod.
Diverse UV Correct Ores - Compatibilty meshes are and fixed esp are included in optional Patches and Replacers archive. No need to download the original mod.
Tamriel Rebuilt and Project Tamriel - meshes included in separate download. Please contact me if I missed or messed up any meshes, but meshes not implemented yet are a continual WIP.
Solstheim Overhaul: Tomb of the Snow Prince - meshes will be included on the Solstheim Overhaul Patch Project page, maintained by abot: https://abitoftaste.altervista.org/morrowind/sopp/
Doors of Oblivion: Coming soon.
ST Alchemy: folder for vanilla meshes and a couple replacers are in the GH Patches and Replacers archive.


MWSE Graphic Herbalism requires compatible meshes to replace the original MW meshes.
If your preferred mesh replacer does not have a HerbalismSwitch, it must be converted in Nifskope, otherwise it will not function with this mod.

Replacers included in optional download:

Correct UV Ore (Diversity) - meshes and patched esp, along with an optional version that respawns like vanilla ores.
Pherim's replacers - all versions require Pherim's original textures, not included. Fire fern can be used with Articus' Epic Plants textures instead.
Project Atlas: BC Mushrooms - all versions require atlas textures, not included so they don't overwrite ones you generated yourself.
Remiros HD Bungler's Bane and Hypha Facia - require original textures, not included.
Glowing Bitter Coast - all versions require the glowmaps, not included.
Glass Glowset Ores - require the glowmaps from Glass Glowset.
Vurt's Chokeweed and Roobrush - work fine without Grazelands II textures.
Less Epic Plants - are my own replacers and include the textures.
Slightly Less Epic Plants - alternate versions require Less Epic Plants folder - alpha blended options are better-looking but can hit performance quite bad
Trama Bumpmapped - require original bumpmaps. Also covers trama root in saran wrap . Even though I included these (because people will complain) I don't recommend them.
Apel's Azura's Coast - require Apel's textures, not included.
Underwater Static Replacer - kelp replacer for Morrowind Crafting or ST Alchemy. Don't bother if you don't use any of these mods.
Ascadian Isle's Plants - require original textures. Comberry not included because it was too horrible a mess to convert. Use Pherim's instead.
Meshes for MC or STA - Morrowing Crafting and ST Alchemy. The first folder is vanilla and the next are replacer patches.

Epic Plants is not included, as Articus is hosting them on his own download page.

************************************************************************************************
Incompatibility
************************************************************************************************
This mod doesn't work on scripted containers unless they're whitelisted, which is not a good idea if it uses OnActivate.

Old Graphic Herbalism mods are not compatible, and neither is GH Extra or GH No-Glow.
Immersive Mining is not currently compatible.
Kwama Eggs Enhanced is not compatible (but I'll look into rolling it into our own GH Extra mod). You can use them together, but GH won't do its thing.
Animated Containers - will override kollop behavior.

************************************************************************************************
Features Planned for Future Releases
************************************************************************************************
- Easier configuration for messageboxes so they can be altered/translated easier.
- Individual sounds for specific containers like mucksponge, mining, kollops, etc.

MWSE Graphic Herbalism Extra:
- Require tools for mining, muck shoveling, kollop prying, etc.
- Possible buffs and debuffs for certain successful or failed picks.
- Possibly add harvesting skill to game.
************************************************************************************************
Changelog
************************************************************************************************
Version 1.04
Fixed pixellation problem on mucksponges in main mod and replacers.
Fixed pixellation on glowmaps in Glowing Bitter Coast and Glass Glowset Ores patches.

Version 1.03
Fix for MWSE bug that makes organic containers disappear on respawn until cell is reloaded.
Fixed wrong MCM labels on whitelist.
Updated instructions in old GH save cleaner readme.

Version 1.02
Warning message for out of date MWSE version fixed.
Added warning message for out of date Quickloot.
Added esp patch for missing organic flag on tramaroot_06 as a separate download.

Version 1.01
Removed collision from chokeweed and roobrush because it's annoying.
Fixed marshmerrow_03 - both vanilla and smoothed version.
Fixed kwama egg sac.
Made picked kreshweed more obvious, cutting all their leaves instead of a few.
Uprooted corkbulb instead of making it disappear.
Removed more leaves from Apel's picked kreshweed.
Removed collision from Vurt's chokeweed and roobrush and removed some leaves from the chokeweed.
Updated MWSE scripts

************************************************************************************************
Converting your own meshes
************************************************************************************************
This can be done in Nifskope if the mesh is separated into different parts. If it can't be broken into picked/unpicked parts, the quick solution is to make the whole plant disable.

1. To make a single part disable, rename the Trishape node NORMAL.
2. Right-click on the same node and select Attach Parent Node and Select NISwitchNode.
3. Name the switch node HerbalismSwitch.
4. Right-click on HerbalismSwitch and select Attach Node. Select NiNode.
5. Name new node HARVESTED.
6. Save mesh.

Make sure the NORMAL node comes before the HARVESTED node, otherwise they'll work the other way around in-game, since it checks for node order, not node names.

7. To disable multiple parts of a mesh, if they already exist inside a node, rename the node NORMAL and follow the prior instructions.
8. If the mesh parts aren't bundled inside a node, add a parent NiNode to one of the parts and name it NORMAL.
9. Copy/paste the other parts inside the same node.
10. Delete the original mesh parts.
11. Go to the Spells menu, select Optimize, and click on Combine Properties.
12. Follow steps 2-6.

If the plant has parts that shouldn't disable that can't be parted from the parts you want to disable, it needs to be done in Blender. Best to disable whole plant (or leave it if it's a tree or something) and request a proper mesh be made from it from either the original modder or me.

************************************************************************************************
Credits & Permissions
************************************************************************************************
You may adapt and use any part of this mod so long as the original modders are credited. Please see individual credits for who did what.

Greatness7 invented all the scripts for this mod
Nullcascade for his continued work on MWSE who worked closely with us on this mod

Petethegoat - script help and testing, and also trimmed the chokeweed and roobrush meshes

Sveng - feedback and playtesting
Merlord - MCM

Remiros - MOP meshes (used as base for half the vanilla meshes)

Stuporstar - main mesh adaptor, as well as any smoothed meshes textures not listed below

Manauser and Scrawafunda - picked textures for comberry, holly, and lloramor

GrunTella - picked texture for heather, smoothed trama root, smoothed stoneflower

Moranar - many of the smoothed meshes were adapted from Better Flora
Tyddy - smoothed chokeweed and roobrush (with further smoothing and UV adjustments by me)
DassiD - alpha maps for picked moss (used in ST Alchemy patch) were made from Morrowind Enhanced Textures
Articus - wickwheat leaves included in mesh replacer package

Thanks for Manauser and Skrawafunda for their work on the original Graphic Herbalism
Thanks to Nich and CJW-Craigor for original UV Correct Ores and Ore Diversity