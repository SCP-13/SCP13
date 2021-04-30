/datum/scp_status
	var/name = "Normal"
	var/scpnumber = SCP_NORMAL
	var/color = null
	var/prefix = ""
	var/list/list/scp_by_typepath
	var/list/list/scp_by_tier
	var/list/dead_scps // scp that are still assigned to this hive but are dead.
	var/list/ssd_scps
	var/list/list/scps_by_zlevel
	///Queue of all observer wanting to join scp side
	var/list/mob/dead/observer/candidate

// ***************************************
// *********** Init
// ***************************************
/datum/scp_status/New()
	. = ..()
	scp_by_typepath = list()
	scp_by_tier = list()
	dead_scps = list()
	scps_by_zlevel = list()
	LAZYINITLIST(candidate)

	for(var/t in subtypesof(/mob/living/carbon/scp))
		var/mob/living/carbon/scp/S = t
		scp_by_typepath[initial(S.caste_base_type)] = list()

	for(var/tier in GLOB.scptiers)
		scp_by_tier[tier] = list()

// ***************************************
// *********** Status changes
// ***************************************
/datum/scp_status/proc/on_scp_logout(mob/living/carbon/scp/ssd_scp)
	if(ssd_scp.stat == DEAD)
		return
	LAZYADD(ssd_scps, ssd_scp)

/datum/scp_status/proc/on_scp_login(mob/living/carbon/scp/reconnecting_scp)
	LAZYREMOVE(ssd_scps, reconnecting_scp)

/datum/scp_status/proc/scp_z_changed(mob/living/carbon/scp/S, old_z, new_z)
	SIGNAL_HANDLER
	LAZYREMOVE(scps_by_zlevel["[old_z]"], S)
	LAZYADD(scps_by_zlevel["[new_z]"], S)

// ***************************************
// *********** List getters
// ***************************************
/datum/scp_status/proc/get_all_scp(queen = TRUE)
	var/list/scps = list()
	for(var/typepath in scp_by_typepath)
		scps += scp_by_typepath[typepath]
	return scps

// doing this by type means we get a pseudo sorted list
/datum/scp_status/proc/get_watchable_scps()
	var/list/xenos = list()
	for(var/typepath in scp_by_typepath)
		for(var/i in scp_by_typepath[typepath])
			var/mob/living/carbon/scp/S = i
			if(is_centcom_level(S.z))
				continue
			xenos += S
	return xenos

// doing this by type means we get a pseudo sorted list
/datum/scp_status/proc/get_leaderable_scps()
	var/list/scps = list()
	for(var/typepath in scp_by_typepath)
		for(var/i in scp_by_typepath[typepath])
			var/mob/living/carbon/scp/S = i
			if(is_centcom_level(S.z))
				continue
			scps += S
	return scps

/datum/scp_status/proc/get_ssd_scps(only_away = FALSE)
	var/list/scps = list()
	for(var/i in ssd_scps)
		var/mob/living/carbon/xenomorph/ssd_scp = i
		if(is_centcom_level(ssd_scp.z))
			continue
		if(isclientedaghost(ssd_scp)) //To prevent adminghosted xenos to be snatched.
			continue
		if(only_away && ssd_scp.afk_status == MOB_RECENTLY_DISCONNECTED)
			continue
		scps += ssd_scp
	return scps

// ***************************************
// *********** Scp messaging
// ***************************************

/*

This is for scp-wide announcements like the queen dying

The force parameter is for messages that should ignore a dead queen

to_chat will check for valid clients itself already so no need to double check for clients

*/

///Used for Hive Message alerts
/datum/scp_status/proc/scp_message(message = null, span_class = "scpannounce", size = 5, force = FALSE, atom/target = null, sound = null, apply_preferences = FALSE, filter_list = null, arrow_type = /obj/screen/arrow/leader_tracker_arrow, arrow_color, report_distance)

	if(!force)
		return

	var/list/final_list = get_all_scp()

	if(filter_list) //Filter out Spcs in the filter list if applicable
		final_list -= filter_list

	for(var/mob/living/carbon/scp/S AS in final_list)

		if(S.stat) // dead/crit cant hear
			continue

		if(!S.client) // If no client, there's no point; also runtime prevention
			continue

		if(sound) //Play sound if applicable
			S.playsound_local(S, sound, max(size * 20, 60), 0, 1)

		if(target) //Apply tracker arrow to point to the subject of the message if applicable
			var/obj/screen/arrow/arrow_hud = new arrow_type
			//Prepare the tracker object and set its parameters
			arrow_hud.add_hud(S, target)
			if(arrow_color) //Set the arrow to our custom colour if applicable
				arrow_hud.color = arrow_color
			new /obj/effect/temp_visual/xenomorph/xeno_tracker_target(target, target) //Ping the source of our alert

		if(report_distance)
			var/distance = get_dist(S, target)
			message += " Distance: [distance]"

		to_chat(S, "<span class='[span_class]'><font size=[size]> [message]</font></span>")

// This is to simplify the process of talking in hivemind, this will invoke the receive proc of all xenos in this hive
/datum/scp_status/proc/scp_mind_message(mob/living/carbon/scp/sender, message)
	for(var/i in get_all_scp())
		var/mob/living/carbon/scp/S = i
		S.receive_scpmind_message(sender, message)
