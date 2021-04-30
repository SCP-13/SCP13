
/mob/living/carbon/scp/proc/add_abilities()
	for(var/action_path in action_list)
		var/datum/action/scp_action/action = new action_path()
		action.give_action(src)


/mob/living/carbon/scp/proc/remove_abilities()
	for(var/action_datum in scp_abilities)
		qdel(action_datum)
