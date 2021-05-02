
/mob/living/carbon/scp/scp049
	caste_base_type = /mob/living/carbon/scp/scp049
	name = "SCP-049"
	caste_name = "SCP049"
	desc = ""
	icon_state = "SCP049 Walking"
	health = 800
	maxHealth = 800
	tier = SCP_EUCLID
	speed = 1
	mob_size = MOB_SIZE_HUMAN
	gib_chance = 0
	drag_delay = 3

	// *** Darksight *** ///
	see_in_dark = 8

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 0, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 30)

	action_list = list(
		/datum/action/scp_action/activable/touch_of_death,
		/datum/action/scp_action/activable/touch_of_heal
	)
