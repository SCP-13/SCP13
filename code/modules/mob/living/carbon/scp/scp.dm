/mob/living/carbon/scp/Initialize(mapload)
	. = ..()

	var/datum/action/minimap/xeno/mini = new
	mini.give_action(src)

	create_reagents(1000)
	gender = NEUTER

	switch(stat)
		if(CONSCIOUS)
			GLOB.alive_scp_list += src
		if(UNCONSCIOUS)
			GLOB.alive_scp_list += src

	GLOB.scp_mob_list += src

	if(is_centcom_level(z) && scpnumber == SCP_NORMAL)
		scpnumber = SCP_ADMEME //so admins can safely spawn xenos in Thunderdome for tests.

	wound_overlay = new(null, src)
	vis_contents += wound_overlay

	regenerate_icons()

	update_action_button_icons()

	SSminimaps.add_marker(src, z, hud_flags = MINIMAP_FLAG_XENO, iconstate = "xeno")

/mob/living/carbon/scp/examine(mob/user)
	..()
	if(isscp(user) && desc)
		to_chat(user, desc)

	if(stat == DEAD)
		to_chat(user, "It is DEAD. Kicked the bucket. Off to that great hive in the sky.")
	else if(stat == UNCONSCIOUS)
		to_chat(user, "It quivers a bit, but barely moves.")
	else
		var/percent = (health / maxHealth * 100)
		switch(percent)
			if(95 to 101)
				to_chat(user, "It looks quite healthy.")
			if(75 to 94)
				to_chat(user, "It looks slightly injured.")
			if(50 to 74)
				to_chat(user, "It looks injured.")
			if(25 to 49)
				to_chat(user, "It bleeds with sizzling wounds.")
			if(1 to 24)
				to_chat(user, "It is heavily injured and limping badly.")

	if(scpnumber != SCP_NORMAL)
		var/datum/scp_status/scp = GLOB.scp_datums[scpnumber]
		to_chat(user, "It appears to belong to the [scp.prefix]scp")
	return

/mob/living/carbon/scp/Moved(atom/newloc, direct)
	return ..()

/mob/living/carbon/scp/ghostize(can_reenter_corpse)
	. = ..()
	if(!. || can_reenter_corpse)
		return
	set_afk_status(MOB_RECENTLY_DISCONNECTED, 5 SECONDS)
