// ***************************************
// *********** The touch of death
// ***************************************

/datum/action/scp_action/activable/touch_of_death
	name = "The touch of death"
	action_icon_state = "screech"
	mechanics_text = "Time to heal humans"
	cooldown_timer = 10 SECONDS

/datum/action/scp_action/activable/touch_of_death/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!owner.Adjacent(A) || !isliving(A))
		return FALSE
	var/mob/living/L = A
	if(L.stat == DEAD) //no bully
		return FALSE

	if(HAS_TRAIT(L, TRAIT_FAKEDEATH))
		return FALSE

	var/turf/S = get_turf(owner)
	if(get_dist(A, S) > 1)
		if(!silent)
			to_chat(owner, "<span class='warning'>You can touch target on distance 1 tile.</span>")
		return FALSE

/datum/action/scp_action/activable/touch_of_death/use_ability(atom/A)
	var/mob/living/carbon/scp/scp049/S = owner
	var/mob/living/carbon/human/H = A

	if(!can_use_ability(H, FALSE))
		return fail_activate()

	ADD_TRAIT(H, TRAIT_ZOMBIE, S)
	H.set_resting(TRUE, TRUE)

	playsound(S, 'sound/effects/scp049deathtouch.ogg', 40, 1)
	add_cooldown()

/datum/action/scp_action/activable/touch_of_heal
	name = "The touch of heal"
	action_icon_state = "screech"
	mechanics_text = "Time to heal humans"
	cooldown_timer = 20 SECONDS

/datum/action/scp_action/activable/touch_of_heal/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!owner.Adjacent(A) || !isliving(A))
		return FALSE
	var/mob/living/carbon/human/L = A
	if(L.stat != DEAD || !HAS_TRAIT(L, TRAIT_ZOMBIE) || L.species.name == "Zombie")
		return FALSE


	var/turf/S = get_turf(owner)
	if(get_dist(A, S) > 1)
		if(!silent)
			to_chat(owner, "<span class='warning'>You can touch target on distance 1 tile.</span>")
		return FALSE

/datum/action/scp_action/activable/touch_of_heal/use_ability(atom/A)
	var/mob/living/carbon/scp/scp049/S = owner
	var/mob/living/carbon/human/H = A

	if(!can_use_ability(H, FALSE))
		return fail_activate()

	REMOVE_TRAIT(H, TRAIT_ZOMBIE, S)
	if(H.stat == DEAD)
		H.revive(TRUE)
	playsound(H.loc, 'sound/hallucinations/wail.ogg', 25, 1)
	H.set_species("Zombie")

	to_chat(H,"<span class='warning'>You SCP-049-1</span>")

	playsound(S, 'sound/effects/scp049healtouch.ogg', 40, 1)
	add_cooldown()
