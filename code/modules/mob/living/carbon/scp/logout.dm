/mob/living/carbon/scp/Logout()
	. = ..()
	if(!key)
		set_afk_status(MOB_DISCONNECTED)
	else if(!isclientedaghost(src))
		set_afk_status(MOB_RECENTLY_DISCONNECTED, SCP_AFK_TIMER)
	if(scp) //This can happen after the mob is destroyed.
		scp.on_scp_logout(src)
