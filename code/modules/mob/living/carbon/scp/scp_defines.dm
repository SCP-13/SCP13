/mob/living/carbon/scp
	name = "SCP-DELETED"
	var/caste_name = "SCP173"
	desc = "What the hell is THAT?"
	icon = 'icons/SCP/1x1_SCP.dmi'
	icon_state = "SCP173 Moving"
	attack_sound = null
	wall_smash = FALSE
	health = 5
	maxHealth = 5
	rotate_on_lying = FALSE
	mob_size = MOB_SIZE_XENO
	hand = 1 //Make right hand active by default. 0 is left hand, mob defines it as null normally
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_SELF|SEE_OBJS|SEE_TURFS|SEE_MOBS
	appearance_flags = TILE_BOUND|PIXEL_SCALE|KEEP_TOGETHER
	see_infrared = TRUE
	hud_type = /datum/hud/scp
	hud_possible = list()
	buckle_flags = NONE
	faction = FACTION_SCP
	initial_language_holder = /datum/language_holder/scp
	gib_chance = 5
	light_system = MOVABLE_LIGHT

	var/list/stomach_contents

	///What negative health amount they die at.
	var/crit_health = -100

	var/speed = 1

	var/scpnumber = SCP_NORMAL
	var/tier = null

	var/datum/scp_status/scp

	var/sunder = 0 // sunder affects armour values and does a % removal before dmg is applied. 50 sunder == 50% effective armour values

	//Charge vars
	var/is_charging = CHARGE_OFF //Will the mob charge when moving ? You need the charge verb to change this

	var/list/datum/action/scp_abilities = list()
	var/list/action_list = list()
	var/datum/action/scp_action/activable/selected_ability

	var/wound_type = "scp"

	var/list/overlays_standing[X_TOTAL_LAYERS]
	var/atom/movable/vis_obj/scp_wounds/wound_overlay
	var/datum/scp_caste/scp_caste
	var/caste_base_type
	var/language = "SCP"
	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/head/head = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null

	COOLDOWN_DECLARE(scp_health_alert_cooldown)
