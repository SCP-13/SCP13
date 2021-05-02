
/mob/living/carbon/scp/scp096
	caste_base_type = /mob/living/carbon/scp/scp096
	name = "SCP-096"
	caste_name = "SCP096"
	desc = ""
	icon_state = "SCP096 Walking"
	health = 1500
	maxHealth = 1500
	tier = SCP_EUCLID
	speed = 1
	mob_size = MOB_SIZE_HUMAN
	gib_chance = 0
	drag_delay = 4 //pulling a big dead scp is hard

	// *** Darksight *** ///
	see_in_dark = 8

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 0, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 30)

	action_list = list(
	)

	var/list/humans_watched = list() //SPECIAL FOR SCP 096

/mob/living/carbon/scp/scp096/proc/IsWatched()
	for(var/mob/living/carbon/human/H in view(src, 7))
		if(H.species.name == "Zombie") //SCP-049-1
			continue
		if(is_blind(H) || H.eye_blind > 0)
			continue
		if(H.stat != CONSCIOUS)
			continue
		if(HAS_TRAIT(H, TRAIT_VISION_BLOCKED))
			continue
		if(H in humans_watched)
			continue
		humans_watched += H
		playsound(src, 'sound/effects/scp096triger.ogg', 15, 1) //Triger
	if(length(humans_watched) == 0 && is_charging)
		is_charging = FALSE

/mob/living/carbon/scp/scp096/Move(NewLoc, direct)
	IsWatched()
	return ..(NewLoc, direct)
