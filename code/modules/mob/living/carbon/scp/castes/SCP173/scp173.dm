/mob/living/carbon/scp/scp173
	caste_base_type = /mob/living/carbon/scp/scp173
	name = "SCP173"
	caste_name = "SCP173"
	desc = ""
	icon_state = "SCP173 Walking"
	health = 200
	maxHealth = 200
	speed = -1
	mob_size = MOB_SIZE_BIG
	gib_chance = 0
	drag_delay = 6 //pulling a big dead scp is hard

	// *** Darksight *** ///
	see_in_dark = 20

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 0, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 30)

	action_list = list(
		/datum/action/scp_action/charge,
		/datum/action/scp_action/activable/snap,
	)

/mob/living/carbon/scp/scp173/Initialize()
	. = ..()
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_SCP173)

/mob/living/carbon/scp/scp173/proc/IsBeingWatched()
	// Am I being watched by anyone else?
	for(var/mob/living/carbon/human/H in view(src, 7))
		if(is_blind(H) || H.eye_blind > 0)
			continue
		if(H.stat != CONSCIOUS)
			continue
		if(!HAS_TRAIT(H, TRAIT_VISION_BLOCKED))
			return TRUE
	return FALSE

/mob/living/carbon/scp/scp173/Move(NewLoc, direct)
	if(IsBeingWatched())
		return FALSE
	return ..(NewLoc, direct)
