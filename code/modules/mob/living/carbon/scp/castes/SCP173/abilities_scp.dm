// ***************************************
// *********** Charge
// ***************************************

/datum/action/scp_action/charge
	name = "Charge"
	action_icon_state = "toggle_long_range"
	mechanics_text = "CHARGE."
	keybind_signal = COMSIG_XENOABILITY_LONG_RANGE_SIGHT

/datum/action/scp_action/charge/get_cooldown()
	return 1 MINUTES

/datum/action/scp_action/charge/action_activate()
	for(var/mob/living/carbon/human/H in view(owner, 7))
		SEND_SIGNAL(H)
