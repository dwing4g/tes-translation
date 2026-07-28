-- quickloot has three states, and most scripts want the third:
--   whitelisted  the handler never runs, quickloot loots straight from the hud
--   blacklisted  no quickloot at all, the player activates it by hand
--   in neither   quickloot activates it once through the engine on first look, exactly as opening it would


-- the handler runs on activation, but nothing is lost by never running it
qlScriptWhitelist = {
["ao_containers_scr_barrel"] = true,
["ao_containers_scr_barrelf"] = true,
["ao_containers_scr_basket"] = true,
["ao_containers_scr_chest"] = true,
["ao_containers_scr_chest_dwemer"] = true,
["ao_containers_scr_closet"] = true,
["ao_containers_scr_closet_dwemer"] = true,
["ao_containers_scr_crate"] = true,
["ao_containers_scr_cratef"] = true,
["ao_containers_scr_cupboard"] = true,
["ao_containers_scr_drawer_dwemer"] = true,
["ao_containers_scr_drawers"] = true,
["ao_containers_scr_sack"] = true,
["ao_containers_scr_small_chest"] = true,
["ao_containers_scr_steel_keg"] = true,
["ao_containers_scr_stone_chest"] = true,
["ao_containers_scr_urn"] = true,

["chargendialoguemessage"] = true, -- no onactivate handler at all, only a proximity messagebox
["tr_m4_q_treram_chest"] = true, -- the whole onactivate block is commented out, dead code
["tr_m7_ctsewerguard"] = true, -- no onactivate on this npc, the checks belong to the two sewer doors
}

-- firing the handler on sight is materially worse than firing it on open
qlScriptBlacklist = {
["ab_comdisplay_s"] = true, -- lid toggle that never opens the window, probing it just creaks the case open and shut
["ab_dwrvproxmine_s"] = true, -- one shot proximity mine, hud loot pulls the gyro and disarms it at range
["ab_kwamaeggblighted_s"] = true, -- chance of ash-chancre scaled by blight resistance, then activates
["ab_kwamaeggbomb_s"] = true, -- one shot bomb egg, hud loot defuses it unasked
["bill_gts_cursed_chest"] = true, -- disables the two corpse containers and enables the skeleton guards
["bill_marksdaedrasummon"] = true, -- placeatpc drops a dremora lord on the player
["bill_marksspiritsummon"] = true, -- placeatpc drops an ancestor ghost on the player
["chargenboatnpc"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["chargenboatwomen"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["chargenclassnpc"] = true, -- disableplayercontrols then the chargen class menu chain
["chargennamenpc"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["chargenracenpc"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["chargenwalknpc"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["nopickup"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["pc_m1_anv_dispcashasi_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["pc_m1_anv_dispcasisel_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["pc_m1_anv_dispcasnadia_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["pc_m1_anv_dispcasvarive_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["pc_m1_cha_dispcassunsh_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["pc_m1_gld_dispcasmaste1_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["pc_m1_gld_dispcassecre1_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["pc_m1_k1_rp1_jar_sc"] = true, -- handler breaks the jar and disables the object itself
["pc_m1_sal_sc"] = true, -- modal feed prompt armed inside the handler, pops a frame later
["sky_qre_dh4_beten_sc"] = true, -- handler fires startcombat, larrik on the spriggan
["sky_qre_dse2_boar_sc"] = true, -- eats the player apple and disables the boar unasked
["sky_qre_ha3_sack_sc"] = true, -- modal poison prompt armed inside the handler
["sky_qre_kw9_trap_sc"] = true, -- trap chest that never activates, modcurrenthealth -30 and a message every time you hold the key
["sky_qre_kwmg4_d_ravos_sc"] = true, -- handler sets the returned global that disables the corpse the same frame
["sky_qre_kwtg6_chest_sc"] = true, -- modal yes/no to plant the forged map
["sky_qre_mai2_sack_sc"] = true, -- swaps conall's note for the lucky charm inside the handler, probe takes it unasked
["t_sccrea_butterflycyr_01"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_butterflycyr_02"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_butterflycyr_03"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_butterflycyr_04"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_butterflycyr_05"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_butterflycyr_06"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_butterflysky_01"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_butterflysky_02"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_butterflysky_03"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_butterflysky_04"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothancestor"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothantler"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_motharrow"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothash"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothblight"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothbuck"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothclearwing"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothcusp"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothlute"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothmoon"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothrosy"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothumber"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mothyellow"] = true, -- handler kills disables and deletes the creature, the wings exist only inside it
["t_sccrea_mummyrise_02"] = true, -- dormant mummy wakes and starts combat when activated
["t_scobj_cardhortbox"] = true, -- modal card game prompt
["t_scobj_detombspiritsummon"] = true, -- spawns an ancestor ghost next to the player on activation
["t_scobj_displaycaseimp1"] = true, -- lid toggle that never opens the window, hovering flapped the case open and shut
["tr_fm_companion_sc"] = true, -- forcegreeting when sneaking opens the dialogue window
["tr_i2_303_poisonbarrel"] = true, -- one shot poison cast on the player before it opens
["tr_i3_531_eggcrate_scn"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m1_fw_dispcascollege_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["tr_m1_fw_dispcasgalleon_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["tr_m1_il_deadguar"] = true, -- modal choice on the corpse
["tr_m1_ito_fw_dcjeweler_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["tr_m1_no_activation"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["tr_m1_q_rangirthchestscript"] = true, -- swaps the two guards for skeletons on activation, one shot ambush
["tr_m1_script_c_curse_i62"] = true, -- summons a random daedra at the player and casts trap_paralyze00, one shot trap
["tr_m2_jeela"] = true, -- forcegreeting on a stand-in npc
["tr_m2_mothrivra_mimic_sc"] = true, -- player->positioncell teleports the player into tel mothrivra prison
["tr_m2_q_14_nalethchest_sc"] = true, -- forcegreeting from the chest owner
["tr_m2_q_4_sorendremora_sc"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["tr_m3-239_rugs"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m3-239_tapestry"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m3-591_moraelynurn_script"] = true, -- spawns moraelyn's lich behind the player on first activation, one shot ambush
["tr_m3_dilavesadummiescript"] = true, -- disables itself and placeatme spawns the undead plus an explosion
["tr_m3_hh_gm_veloth_reset_scr"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["tr_m3_npc_jebyn"] = true, -- modal examine prompt on the corpse
["tr_m3_npc_ulvo_telvor"] = true, -- handler hands over the claw and swaps the glove, the probe takes them unasked
["tr_m3_npc_yontuskushummu"] = true, -- modal gold prompt armed inside the handler
["tr_m3_oe_tg_antiowounded"] = true, -- forcegreeting, deliberately blocks searching him
["tr_m3_oe_tindalosscript"] = true, -- journal 20 and positioncell teleports galug into the sewers, one shot, and never activates
["tr_m3_q_6_edryon"] = true, -- waking him starts the state machine that teleports folvalie and disables him for good
["tr_m3_q_a7_yannibscript"] = true, -- modal prompt before the fatigue restore
["tr_m3_q_a9_strandedpilgrim"] = true, -- modal choice the player has to answer
["tr_m3_q_bartolomaeus"] = true, -- modal yes/no to resurrect him
["tr_m3_sadrynsleep_scp"] = true, -- forcegreeting on her double unless sneaking
["tr_m4-349_watertrap_sc"] = true, -- one shot trap, locks the door and floods the room on activation
["tr_m4_431_cryptdoor"] = true, -- casts frostbloom on the player once, then activates, sits on a kollop despite the id
["tr_m4_aa_sehutumummyscp"] = true, -- modal kill or leave prompt
["tr_m4_ando_dispcasvendi_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["tr_m4_ando_faulerchestscript"] = true, -- forcegreeting when hemmette catches you
["tr_m4_armun_dead_caravan_script"] = true, -- activation flags the corpse to disable itself once the player walks off
["tr_m4_cr_saylenusramaril_scp"] = true, -- forcegreeting saylenus
["tr_m4_cr_strayguar_scp"] = true, -- random branch startcombats the player or kills the guar outright
["tr_m4_npc_borgas_too-sure"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["tr_m4_npc_jubal_d"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m4_npc_sathasa_andas"] = true, -- modal choice gates searching the body
["tr_m4_npc_ushudead"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m4_npc_veersinbrine"] = true, -- handler disables the corpse itself before the player ever opens it
["tr_m4_npc_vodunius_nuccius"] = true, -- journal tr_m4_t_nuccius 1002 on the sewer corpse, and never activates so the body cannot be searched
["tr_m4_tt_ulmon_dead_sc"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["tr_m4_vm_rilasroma_body_scp"] = true, -- reads onactivate and never activates, permanently inert, nothing for a probe to find
["tr_m7_alanius_calatus_sc"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m7_camilliachora_slp_sc"] = true, -- modal hemlock prompt
["tr_m7_eec_brandysmash"] = true, -- modal smash prompt armed inside the handler
["tr_m7_hlaalu2_wraithtrapscript"] = true, -- placeatpc spawns a wraith on the player, one shot trap
["tr_m7_ho_tt_npc_ulsheranoscp"] = true, -- forcegreeting while he is still alive
["tr_m7_nars_dispcascons_sc"] = true, -- simulated lock with no activate, probing replays the lockedchest sound every few seconds
["tr_m7_npc_darius_maximius"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m7_npc_ernasiviranslp"] = true, -- forcegreeting from the real npc while he sleeps
["tr_m7_ns_arenanonlethal_sc"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m7_ns_arenatodeath_sc"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m7_ns_il_4_skeletonsc"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m7_ns_mg_alt_nelvana_sc"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_m7_selar_adryn_sc"] = true, -- messagebox and no activate, the probe can only re-fire it every few seconds
["tr_sh01_tomb02_ghost_spawn"] = true, -- first activation spawns a greater ancestor ghost next to the player
}

------------------------------ effect only ------------------------------
-- blacklisted, but the handler's whole player facing effect is one spell or one hit
-- the first three call activate afterwards, so replicating the effect in lua would hand
-- them back to the probe. the fourth never activates and stays unreachable either way
-- ab_kwamaeggblighted_s  spell:ash-chancre  chance scaled by blight resistance, then activates
-- tr_i2_303_poisonbarrel  spell:poisonbloom  casts on the player once, then activates
-- tr_m4_431_cryptdoor  spell:frostbloom  casts on the player once, then activates, on a kollop
-- sky_qre_kw9_trap_sc  damage:health30  fires every time you hold the key, never activates
