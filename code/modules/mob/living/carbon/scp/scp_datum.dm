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

// ***************************************
// *********** Helpers
// ***************************************
/datum/scp_status/proc/post_add(mob/living/carbon/scp/S)
	S.color = color

/datum/scp_status/proc/post_removal(mob/living/carbon/scp/S)
	S.color = null

// for clean transfers between scps
/mob/living/carbon/scp/proc/transfer_to_scp(scpnumber)
	if (scp.scpnumber == scpnumber)
		return // If we are in that hive already
	if(!GLOB.scp_datums[scpnumber])
		CRASH("invalid scpnumber passed to transfer_to_scp")

	var/datum/scp_status/SS = GLOB.scp_datums[scpnumber]
	if(scpnumber != SCP_NONE)
		remove_from_scp()

	add_to_scp(SS)

// ***************************************
// *********** Adding scps
// ***************************************
/datum/scp_status/proc/add_scp(mob/living/carbon/scp/S) // should only be called by add_to_scp below
	if(S.stat == DEAD)
		dead_scps += S
	else
		add_to_lists(S)

	post_add(S)
	return TRUE

// helper function
/datum/scp_status/proc/add_to_lists(mob/living/carbon/scp/S)
	LAZYADD(scps_by_zlevel["[S.z]"], S)
	RegisterSignal(S, COMSIG_MOVABLE_Z_CHANGED, .proc/scp_z_changed)

	if(!scp_by_typepath[S.caste_base_type])
		stack_trace("trying to add an invalid typepath into scpstatus list [S.caste_base_type]")
		return FALSE

	if(S.afk_status != MOB_CONNECTED)
		LAZYADD(ssd_scps, S)

	scp_by_typepath[S.caste_base_type] += S

	return TRUE

/mob/living/carbon/scp/proc/add_to_scp(datum/scp_status/SS, force=FALSE)
	if(!force && scpnumber != SCP_NONE)
		CRASH("trying to do a dirty add_to_scp")

	if(!istype(SS))
		CRASH("invalid scp_status passed to add_to_scp()")

	if(!SS.add_scp(src))
		CRASH("failed to add scp to a scp")

	scp = SS
	scpnumber = SS.scpnumber // just to be sure

	SSdirection.start_tracking(SS.scpnumber, src)

// ***************************************
// *********** Removing scps
// ***************************************
/datum/scp_status/proc/remove_scp(mob/living/carbon/scp/S) // should only be called by remove_from_scp
	if(S.stat == DEAD)
		if(!dead_scps.Remove(S))
			stack_trace("failed to remove a dead scp from hive status dead list, nothing was removed!?")
			return FALSE
	else
		remove_from_lists(S)

	post_removal(S)
	return TRUE

// helper function
/datum/scp_status/proc/remove_from_lists(mob/living/carbon/scp/S)
	// Remove() returns 1 if it removes an element from a list

	if(!scp_by_tier[S.tier].Remove(S))
		stack_trace("failed to remove a scp from scp status tier list, nothing was removed!?")
		return FALSE

	if(!scp_by_typepath[S.caste_base_type])
		stack_trace("trying to remove an invalid typepath from scpstatus list")
		return FALSE

	if(!scp_by_typepath[S.caste_base_type].Remove(S))
		stack_trace("failed to remove a scp from hive status typepath list, nothing was removed!?")
		return FALSE

	LAZYREMOVE(ssd_scps, S)
	LAZYREMOVE(scps_by_zlevel["[S.z]"], S)

	UnregisterSignal(S, COMSIG_MOVABLE_Z_CHANGED)

	return TRUE

/mob/living/carbon/scp/proc/remove_from_scp()
	if(!istype(scp))
		CRASH("tried to remove a scp from a scp that didnt have a scp to be removed from")

	if(!scp.remove_scp(src))
		CRASH("failed to remove scp from a scp")

	SSdirection.stop_tracking(scp.scpnumber, src)

	scp = null
	scpnumber = SCP_NONE // failsafe value
