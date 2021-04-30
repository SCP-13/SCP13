// ***************************************
// *********** Charge
// ***************************************

/datum/action/scp_action/charge
	name = "Charge"
	action_icon_state = "toggle_long_range"
	mechanics_text = "CHARGE."
	cooldown_timer = 1 MINUTES
	keybind_signal = COMSIG_XENOABILITY_LONG_RANGE_SIGHT

/datum/action/scp_action/charge/action_activate()
	for(var/mob/living/carbon/human/H in view(owner, 7))
		SEND_SIGNAL(H, COMSIG_MOB_BLINCK, time_animation = 20 SECONDS, force = TRUE)
	playsound(owner, 'sound/effects/scp173scare.ogg', 70, 1)
	add_cooldown()

/datum/action/scp_action/activable/snap
	name = "Snap"
	action_icon_state = "screech"
	mechanics_text = "Bye bye human"
	cooldown_timer = 20 SECONDS

/datum/action/scp_action/activable/snap/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!owner.Adjacent(A) || !isliving(A))
		return FALSE
	var/mob/living/L = A
	if(L.stat == DEAD) //no bully
		return FALSE

	var/turf/S = get_turf(owner)
	if(get_dist(A, S) > 1)
		if(!silent)
			to_chat(owner, "<span class='warning'>You can snap target on distance 1 tile.</span>")
		return FALSE

/datum/action/scp_action/activable/snap/use_ability(atom/A)
	var/mob/living/carbon/scp/scp173/S = owner
	var/mob/living/carbon/human/H = A

	if(!can_use_ability(H, FALSE))
		return fail_activate()

	H.stat = DEAD //FAST dead
	H.set_resting(TRUE, TRUE)

	var/sound = pick(list(
				'sound/effects/scp173snap1.ogg',
				'sound/effects/scp173snap2.ogg',
				'sound/effects/scp173snap3.ogg'
	))
	playsound(S, sound, 50, 1)
	add_cooldown()
