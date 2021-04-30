
///Send a message to all scps. Force forces the message whether or not the scpmind is intact. Target is an atom that is pointed out to the scp. Filter list is a list of scps we don't message.
/proc/scp_message(message = null, span_class = "scpannounce", size = 5, scpnumber = XENO_HIVE_NORMAL, force = FALSE, atom/target = null, sound = null, apply_preferences = FALSE, filter_list = null, arrow_type, arrow_color, report_distance = FALSE)
	if(!message)
		return

	if(!GLOB.scp_datums[scpnumber])
		CRASH("scp_message called with invalid scpnumber")

	var/datum/scp_status/HS = GLOB.scp_datums[scpnumber]
	HS.scp_message(message, span_class, size, force, target, sound, apply_preferences, filter_list, arrow_type, arrow_color, report_distance)
