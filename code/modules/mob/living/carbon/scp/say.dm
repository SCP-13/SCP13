/mob/living/carbon/scp/proc/render_hivemind_message(message)
	return message


/mob/living/carbon/scp/proc/hivemind_talk(message)
	if(!message || stat)
		return
	if(!scp)
		return

	message = render_hivemind_message(message)

	log_talk(message, LOG_HIVEMIND)

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/S = i
		if(!S?.client?.prefs || !(S.client.prefs.toggles_chat & CHAT_GHOSTHIVEMIND))
			continue
		var/track = FOLLOW_LINK(S, src)
		S.show_message("[track] <span class='message'>telepathy, '[message]'</span>", 2)

	scp.scp_mind_message(src, message)

	return TRUE


/mob/living/carbon/scp/proc/receive_scpmind_message(mob/living/carbon/scp/S, message)
	show_message("<span class='message'>telepathy, '[message]'</span>", 2)

/mob/living/carbon/scp/get_saymode(message, talk_key)
	if(copytext(message, 1, 2) == ";")
		return SSradio.saymodes["d"]
	else if(copytext(message, 1, 3) == ".d" || copytext(message, 1, 3) == ":d")
		return SSradio.saymodes["d"]
	else
		return SSradio.saymodes[talk_key]
