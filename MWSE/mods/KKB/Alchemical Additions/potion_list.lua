--Format is e[effect id]{_[stat_id]}, then a table with bargain/cheap/standard/quality/exclusive ids.
--All ids are 0-indexed.
--Potion ids taken from https://en.uesp.net/wiki/Morrowind:Potions
local potions =
{
	--Alteration
	e7={b="p_burden_b",c="p_burden_c",s="p_burden_s",q="p_burden_q",e="p_burden_e"},
	e8={b="p_feather_b",c="p_feather_c",s=nil,q="p_feather_q",e="p_feather_e"},
	e4={b="p_fire_shield_b",c="p_fire_shield_c",s="p_fire_shield_s",q="p_fire_shield_q",e="p_fire_shield_e"},
	e6={b="p_frost_shield_b",c="p_frost_shield_c",s="p_frost_shield_s",q="p_frost_shield_q",e="p_frost_shield_e"},
	e9={b="p_jump_b",c="p_jump_c",s="p_jump_s",q="p_jump_q",e="p_jump_e"},
	e10={b="p_levitation_b",c="p_levitation_c",s="p_levitation_s",q="p_levitation_q",e="p_levitation_e"},
	e5={b="p_lightning shield_b",c="p_lightning shield_c",s="p_lightning shield_s",q="p_lightning shield_q",e="p_lightning shield_e"},
	e11={b=nil,c=nil,s="p_slowfall_s",q=nil,e=nil},
	e1={b="p_swift_swim_b",c="p_swift_swim_c",s=nil,q="p_swift_swim_q",e="p_swift_swim_e"},
	e0={b=nil,c=nil,s="p_water_breathing_s",q=nil,e=nil},
	e2={b=nil,c=nil,s="p_water_walking_s",q=nil,e=nil},

	--Destruction
	--G7's Poison Crafting poisons -> remove if using something else!
	e25={b="g7a_p_damage_fatigue_b",c="g7a_p_damage_fatigue_c",s="g7a_p_damage_fatigue_s",q="g7a_p_damage_fatigue_q",e="g7a_p_damage_fatigue_e"},
	e23={b="g7a_p_damage_health_b",c="g7a_p_damage_health_c",s="g7a_p_damage_health_s",q="g7a_p_damage_health_q",e="g7a_p_damage_health_e"},
	e24={b="g7a_p_damage_magicka_b",c="g7a_p_damage_magicka_c",s="g7a_p_damage_magicka_s",q="g7a_p_damage_magicka_q",e="g7a_p_damage_magicka_e"},
		--Drain attribute
		e19_0={b="g7a_p_drain_strength_b",c="g7a_p_drain_strength_c",s="g7a_p_drain_strength_s",q="g7a_p_drain_strength_q",e="g7a_p_drain_strength_e"},
		e19_1={b="g7a_p_drain_intelligence_b",c="g7a_p_drain_intelligence_c",s="g7a_p_drain_intelligence_s",q="g7a_p_drain_intelligence_q",e="g7a_p_drain_intelligence_e"},
		e19_2={b="g7a_p_drain_willpower_b",c="g7a_p_drain_willpower_c",s="g7a_p_drain_willpower_s",q="g7a_p_drain_willpower_q",e="g7a_p_drain_willpower_e"},
		e19_3={b="g7a_p_drain_agility_b",c="g7a_p_drain_agility_c",s="g7a_p_drain_agility_s",q="g7a_p_drain_agility_q",e="g7a_p_drain_agility_e"},
		e19_4={b="g7a_p_drain_speed_b",c="g7a_p_drain_speed_c",s="g7a_p_drain_speed_s",q="g7a_p_drain_speed_q",e="g7a_p_drain_speed_e"},
		e19_5={b="g7a_p_drain_endurance_b",c="g7a_p_drain_endurance_c",s="g7a_p_drain_endurance_s",q="g7a_p_drain_endurance_q",e="g7a_p_drain_endurance_e"},
		e19_6={b="g7a_p_drain_personality_b",c="g7a_p_drain_personality_c",s="g7a_p_drain_personality_s",q="g7a_p_drain_personality_q",e="g7a_p_drain_personality_e"},
		e19_7={b="g7a_p_drain_luck_b",c="g7a_p_drain_luck_c",s="g7a_p_drain_luck_s",q="g7a_p_drain_luck_q",e="g7a_p_drain_luck_e"},

	--Illusion
	e40={b="p_chameleon_b",c="p_chameleon_c",s="p_chameleon_s",q="p_chameleon_q",e="p_chameleon_e"},
	e39={b="p_invisibility_b",c="p_invisibility_c",s="p_invisibility_s",q="p_invisibility_q",e="p_invisibility_e"},
	e41={b="p_light_b",c="p_light_c",s="p_light_s",q="p_light_q",e="p_light_e"},
	e43={b="p_night-eye_b",c="p_night-eye_c",s="p_night-eye_s",q="p_night-eye_q",e="p_night-eye_e"},
	e45={b="p_paralyze_b",c="p_paralyze_c",s="p_paralyze_s",q="p_paralyze_q",e="p_paralyze_e"},
	e46={b="p_silence_b",c="p_silence_c",s="p_silence_s",q="p_silence_q",e="p_silence_e"},
	--G7's Poison Crafting poisons -> remove if using something else!
	e47={b="g7a_p_blind_b",c="g7a_p_blind_c",s="g7a_p_blind_s",q="g7a_p_blind_q",e="g7a_p_blind_e"},
	e48={b="g7a_p_sound_b",c="g7a_p_sound_c",s="g7a_p_sound_s",q="g7a_p_sound_q",e="g7a_p_sound_e"},

	--Mysticism
	e63={b="p_almsivi_intervention_s",c="p_almsivi_intervention_s",s="p_almsivi_intervention_s",q="p_almsivi_intervention_s",e="p_almsivi_intervention_s"},
	e64={b=nil,c=nil,s="p_detect_creatures_s",q=nil,e=nil},
	e65={b=nil,c=nil,s="p_detect_enchantment_s",q=nil,e=nil},
	e66={b=nil,c=nil,s="p_detect_key_s",q=nil,e=nil},
	e57={b=nil,c=nil,s="p_dispel_s",q=nil,e=nil},
	e60={b="p_mark_s",c="p_mark_s",s="p_mark_s",q="p_mark_s",e="p_mark_s"},
	e61={b="p_recall_s",c="p_recall_s",s="p_recall_s",q="p_recall_s",e="p_recall_s"},
	e68={b="p_reflection_b",c="p_reflection_c",s="p_reflection_s",q="p_reflection_q",e="p_reflection_e"},
	e67={b="p_spell_absorption_b",c="p_spell_absorption_c",s="p_spell_absorption_s",q="p_spell_absorption_q",e="p_spell_absorption_e"},
	e59={b=nil,c=nil,s="p_telekinesis_s",q=nil,e=nil},

	--Restoration
	e70={b="p_cure_blight_s",c="p_cure_blight_s",s="p_cure_blight_s",q="p_cure_blight_s",e="p_cure_blight_s"},
	e69={b="p_cure_common_s",c="p_cure_common_s",s="p_cure_common_s",q="p_cure_common_s",e="p_cure_common_s"},
	e73={b="p_cure_paralyzation_s",c="p_cure_paralyzation_s",s="p_cure_paralyzation_s",q="p_cure_paralyzation_s",e="p_cure_paralyzation_s"},
	e72={b="p_cure_poison_s",c="p_cure_poison_s",s="p_cure_poison_s",q="p_cure_poison_s",e="p_cure_poison_s"},
	e117={b=nil,c=nil,s=nil,q=nil,e="p_fortify_attack_e"},
		--Fortify Attribute
		e79_0={b="p_fortify_strength_b",c="p_fortify_strength_c",s="p_fortify_strength_s",q="p_fortify_strength_q",e="p_fortify_strength_e"},
		e79_1={b="p_fortify_intelligence_b",c="p_fortify_intelligence_c",s="p_fortify_intelligence_s",q="p_fortify_intelligence_q",e="p_fortify_intelligence_e"},
		e79_2={b="p_fortify_willpower_b",c="p_fortify_willpower_c",s="p_fortify_willpower_s",q="p_fortify_willpower_q",e="p_fortify_willpower_e"},
		e79_3={b="p_fortify_agility_b",c="p_fortify_agility_c",s="p_fortify_agility_s",q="p_fortify_agility_q",e="p_fortify_agility_e"},
		e79_4={b="p_fortify_speed_b",c="p_fortify_speed_c",s="p_fortify_speed_s",q="p_fortify_speed_q",e="p_fortify_speed_e"},
		e79_5={b="p_fortify_endurance_b",c="p_fortify_endurance_c",s="p_fortify_endurance_s",q="p_fortify_endurance_q",e="p_fortify_endurance_e"},
		e79_6={b="p_fortify_personality_b",c="p_fortify_personality_c",s="p_fortify_personality_s",q="p_fortify_personality_q",e="p_fortify_personality_e"},
		e79_7={b="p_fortify_luck_b",c="p_fortify_luck_c",s="p_fortify_luck_s",q="p_fortify_luck_q",e="p_fortify_luck_e"},
	e82={b="p_fortify_fatigue_b",c="p_fortify_fatigue_c",s="p_fortify_fatigue_s",q="p_fortify_fatigue_q",e="p_fortify_fatigue_e"},
	e80={b="p_fortify_health_b",c="p_fortify_health_c",s="p_fortify_health_s",q="p_fortify_health_q",e="p_fortify_health_e"},
	e81={b="p_fortify_magicka_b",c="p_fortify_magicka_c",s="p_fortify_magicka_s",q="p_fortify_magicka_q",e="p_fortify_magicka_e"},
	e94={b="p_disease_resistance_b",c="p_disease_resistance_c",s="p_disease_resistance_s",q="p_disease_resistance_q",e="p_disease_resistance_e"},
	e90={b="p_fire_resistance_b",c="p_fire_resistance_c",s="p_fire resistance_s",q="p_fire_resistance_q",e="p_fire_resistance_e"},
	e91={b="p_frost_resistance_b",c="p_frost_resistance_c",s="p_frost_resistance_s",q="p_frost_resistance_q",e="p_frost_resistance_e"},
	e93={b="p_magicka_resistance_b",c="p_magicka_resistance_c",s="p_magicka_resistance_s",q="p_magicka_resistance_q",e="p_magicka_resistance_e"},
	e97={b="p_poison_resistance_b",c="p_poison_resistance_c",s="p_poison_resistance_s",q="p_poison_resistance_q",e="p_poison_resistance_e"},
	e92={b="p_shock_resistance_b",c="p_shock_resistance_c",s="p_shock_resistance_s",q="p_shock_resistance_q",e="p_shock_resistance_e"},
		--Restore Attribute
		e74_0={b="p_restore_strength_b",c="p_restore_strength_c",s="p_restore_strength_s",q="p_restore_strength_q",e="p_restore_strength_e"},
		e74_1={b="p_restore_intelligence_b",c="p_restore_intelligence_c",s="p_restore_intelligence_s",q="p_restore_intelligence_q",e="p_restore_intelligence_e"},
		e74_2={b="p_restore_willpower_b",c="p_restore_willpower_c",s="p_restore_willpower_s",q="p_restore_willpower_q",e="p_restore_willpower_e"},
		e74_3={b="p_restore_agility_b",c="p_restore_agility_c",s="p_restore_agility_s",q="p_restore_agility_q",e="p_restore_agility_e"},
		e74_4={b="p_restore_speed_b",c="p_restore_speed_c",s="p_restore_speed_s",q="p_restore_speed_q",e="p_restore_speed_e"},
		e74_5={b="p_restore_endurance_b",c="p_restore_endurance_c",s="p_restore_endurance_s",q="p_restore_endurance_q",e="p_restore_endurance_e"},
		e74_6={b="p_restore_personality_b",c="p_restore_personality_c",s="p_restore_personality_s",q="p_restore_personality_q",e="p_restore_personality_e"},
		e74_7={b="p_restore_luck_b",c="p_restore_luck_c",s="p_restore_luck_s",q="p_restore_luck_q",e="p_restore_luck_e"},
	e77={b="p_restore_fatigue_b",c="p_restore_fatigue_c",s="p_restore_fatigue_s",q="p_restore_fatigue_q",e="p_restore_fatigue_e"},
	e75={b="p_restore_health_b",c="p_restore_health_c",s="p_restore_health_s",q="p_restore_health_q",e="p_restore_health_e"},
	e76={b="p_restore_magicka_b",c="p_restore_magicka_c",s="p_restore_magicka_s",q="p_restore_magicka_q",e="p_restore_magicka_e"},
}
return potions