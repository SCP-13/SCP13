/datum/action/scp_action
	var/mechanics_text = "This ability not found in codex." //codex. If you are going to add an explanation for an ability. don't use stats, give a very brief explanation of how to use it.
	var/use_state_flags = NONE // bypass use limitations checked by can_use_action()
	var/last_use
	var/cooldown_timer
	var/ability_name
	var/keybind_flags
	var/image/cooldown_image
	var/keybind_signal
	var/cooldown_id
	var/target_flags = NONE

/datum/action/scp_action/New(Target)
	. = ..()
	name = "[name]"
	button.overlays += image('icons/mob/actions.dmi', button, action_icon_state)
	cooldown_image = image('icons/effects/progressicons.dmi', null, "busy_clock")
	cooldown_image.pixel_y = 7
	cooldown_image.appearance_flags = RESET_COLOR|RESET_ALPHA

/datum/action/scp_action/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/scp/S = L
	S.scp_abilities += src
	if(keybind_signal)
		RegisterSignal(L, keybind_signal, .proc/keybind_activation)

/datum/action/scp_action/remove_action(mob/living/L)
	if(keybind_signal)
		UnregisterSignal(L, keybind_signal)
	if(cooldown_id)
		deltimer(cooldown_id)
	var/mob/living/carbon/scp/S = L
	S.scp_abilities -= src
	return ..()


/datum/action/scp_action/proc/keybind_activation()
	SIGNAL_HANDLER
	if(can_use_action())
		INVOKE_ASYNC(src, .proc/action_activate)
	return COMSIG_KB_ACTIVATED

/datum/action/scp_action/can_use_action(silent = FALSE, override_flags)
	var/mob/living/carbon/scp/S = owner
	if(!S)
		return FALSE
	var/flags_to_check = use_state_flags|override_flags

	if(!(flags_to_check & SACT_IGNORE_COOLDOWN) && !action_cooldown_check())
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't use [ability_name] yet, we must wait [cooldown_remaining()] seconds!</span>")
		return FALSE

	if(!(flags_to_check & SACT_USE_INCAP) && S.incapacitated())
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this while incapacitated!</span>")
		return FALSE

	if(!(flags_to_check & SACT_USE_LYING) && S.lying_angle)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this while lying down!</span>")
		return FALSE

	if(!(flags_to_check & SACT_USE_BUCKLED) && S.buckled)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this while buckled!</span>")
		return FALSE

	if(!(flags_to_check & SACT_USE_STAGGERED) && S.stagger)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this while staggered!</span>")
		return FALSE

	if(!(flags_to_check & SACT_USE_NOTTURF) && !isturf(S.loc))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do this here!</span>")
		return FALSE

	if(!(flags_to_check & SACT_USE_BUSY) && S.do_actions)
		if(!silent)
			to_chat(owner, "<span class='warning'>We're busy doing something right now!</span>")
		return FALSE

	return TRUE

/datum/action/scp_action/fail_activate()
	update_button_icon()

//checks if the linked ability is on some cooldown.
//The action can still be activated by clicking the button
/datum/action/scp_action/proc/action_cooldown_check()
	return !cooldown_id


/datum/action/scp_action/proc/clear_cooldown()
	if(!cooldown_id)
		return
	deltimer(cooldown_id)
	on_cooldown_finish()


/datum/action/scp_action/proc/get_cooldown()
	return cooldown_timer


/datum/action/scp_action/proc/add_cooldown(cooldown_override = 0)
	SIGNAL_HANDLER
	var/cooldown_length = get_cooldown()
	if(cooldown_override)
		cooldown_length = cooldown_override
	if(cooldown_id || !cooldown_length) // stop doubling up or waiting on zero
		return
	last_use = world.time
	cooldown_id = addtimer(CALLBACK(src, .proc/on_cooldown_finish), cooldown_length, TIMER_STOPPABLE)
	button.overlays += cooldown_image
	update_button_icon()


/datum/action/scp_action/proc/cooldown_remaining()
	return timeleft(cooldown_id) * 0.1


//override this for cooldown completion.
/datum/action/scp_action/proc/on_cooldown_finish()
	cooldown_id = null
	if(!button)
		CRASH("no button object on finishing xeno action cooldown")
	button.overlays -= cooldown_image
	update_button_icon()

/datum/action/scp_action/update_button_icon()
	if(!can_use_action(TRUE, SACT_IGNORE_COOLDOWN))
		button.color = "#80000080" // rgb(128,0,0,128)
	else if(!action_cooldown_check())
		button.color = "#f0b400c8" // rgb(240,180,0,200)
	else
		button.color = "#ffffffff" // rgb(255,255,255,255)



/datum/action/scp_action/activable
	///Alternative keybind signal, that will always select the ability, even ignoring keybind flag
	var/alternate_keybind_signal

/datum/action/scp_action/activable/New()
	. = ..()

/datum/action/scp_action/activable/give_action(mob/living/L)
	. = ..()
	if(alternate_keybind_signal)
		RegisterSignal(L, alternate_keybind_signal, .proc/select_action)

/datum/action/scp_action/activable/Destroy()
	var/mob/living/carbon/scp/S = owner
	if(S.selected_ability == src)
		deselect()
	return ..()

///Wrapper proc to activate the action and not having sleep issues
/datum/action/scp_action/activable/proc/select_action()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/action_activate)

/datum/action/scp_action/activable/action_activate()
	var/mob/living/carbon/scp/S = owner
	if(S.selected_ability == src)
		return
	if(S.selected_ability)
		S.selected_ability.deselect()
	select()

/datum/action/scp_action/activable/keybind_activation()
	. = COMSIG_KB_ACTIVATED
	if(CHECK_BITFIELD(keybind_flags, SACT_KEYBIND_USE_ABILITY))
		if(can_use_ability(null, FALSE, SACT_IGNORE_SELECTED_ABILITY))
			use_ability()
		return

	if(can_use_action(FALSE, NONE, TRUE)) // just for selecting
		action_activate()

/datum/action/scp_action/activable/proc/deselect()
	var/mob/living/carbon/scp/S = owner
	remove_selected_frame()
	S.selected_ability = null
	on_deactivation()

/datum/action/scp_action/activable/proc/select()
	var/mob/living/carbon/scp/S= owner
	add_selected_frame()
	S.selected_ability = src
	on_activation()

/datum/action/scp_action/activable/action_activate()
	var/mob/living/carbon/scp/S = owner
	if(S.selected_ability == src)
		to_chat(S, "You will no longer use [ability_name] with [(S.client.prefs.toggles_gameplay & MIDDLESHIFTCLICKING) ? "middle-click" :"shift-click"].")
		deselect()
	else
		to_chat(S, "You will now use [ability_name] with [(S.client.prefs.toggles_gameplay & MIDDLESHIFTCLICKING) ? "middle-click" :"shift-click"].")
		if(S.selected_ability)
			S.selected_ability.deselect()
		select()
	return ..()


/datum/action/scp_action/activable/remove_action(mob/living/carbon/scp/S)
	if(S.selected_ability == src)
		S.selected_ability = null
	return ..()


///the thing to do when the selected action ability is selected and triggered by middle_click
/datum/action/scp_action/activable/proc/use_ability(atom/A)
	return

/datum/action/scp_action/activable/can_use_action(silent = FALSE, override_flags, selecting = FALSE)
	if(selecting)
		return ..(silent, SACT_IGNORE_COOLDOWN|SACT_USE_STAGGERED)
	return ..()

//override this
/datum/action/scp_action/activable/proc/can_use_ability(atom/A, silent = FALSE, override_flags)
	if(QDELETED(owner))
		return FALSE

	var/flags_to_check = use_state_flags|override_flags

	var/mob/living/carbon/scp/S = owner
	if(!CHECK_BITFIELD(flags_to_check, SACT_IGNORE_SELECTED_ABILITY) && S.selected_ability != src)
		return FALSE
	. = can_use_action(silent, override_flags)
	if(!CHECK_BITFIELD(flags_to_check, SACT_TARGET_SELF) && A == owner)
		return FALSE

/datum/action/scp_action/activable/proc/can_activate()
	return TRUE

/datum/action/scp_action/activable/proc/on_activation()
	return

/datum/action/scp_action/activable/proc/on_deactivation()
	return
