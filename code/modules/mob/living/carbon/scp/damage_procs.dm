/mob/living/carbon/scp/fire_act()
	if(status_flags & GODMODE)
		return
	return ..()

/mob/living/carbon/scp/ex_act(severity)
	if(status_flags & (INCORPOREAL|GODMODE))
		return

	if(severity < EXPLODE_LIGHT) //Actually means higher.
		for(var/i in stomach_contents)
			var/mob/living/carbon/prey = i
			prey.ex_act(severity + 1)
	var/bomb_armor = soft_armor.getRating("bomb")
	var/b_loss = 0
	var/f_loss = 0
	switch(severity)
		if(EXPLODE_DEVASTATE)
			switch(bomb_armor)
				if(SCP_BOMB_RESIST_4 to INFINITY)
					add_slowdown(2)
					return
				if(SCP_BOMB_RESIST_3 to SCP_BOMB_RESIST_4)
					b_loss = rand(70, 80)
					f_loss = rand(70, 80)
					add_slowdown(3)
					adjust_sunder(80)
				if(SCP_BOMB_RESIST_2 to SCP_BOMB_RESIST_3)
					b_loss = rand(75, 85)
					f_loss = rand(75, 85)
					adjust_stagger(4)
					add_slowdown(4)
					adjust_sunder(90)
				if(SCP_BOMB_RESIST_1 to SCP_BOMB_RESIST_2)
					b_loss = rand(80, 90)
					f_loss = rand(80, 90)
					adjust_stagger(5)
					add_slowdown(5)
					adjust_sunder(100)
				else //Lower than SCP_BOMB_RESIST_1
					return gib()
		if(EXPLODE_HEAVY)
			switch(bomb_armor)
				if(SCP_BOMB_RESIST_4 to INFINITY)
					add_slowdown(1)
					return
				if(SCP_BOMB_RESIST_3 to SCP_BOMB_RESIST_4)
					b_loss = rand(50, 60)
					f_loss = rand(50, 60)
					add_slowdown(2)
					adjust_sunder(35)
				if(SCP_BOMB_RESIST_2 to SCP_BOMB_RESIST_3)
					b_loss = rand(55, 55)
					f_loss = rand(55, 55)
					adjust_stagger(1)
					add_slowdown(3)
					adjust_sunder(40)
				if(SCP_BOMB_RESIST_1 to SCP_BOMB_RESIST_2)
					b_loss = rand(60, 70)
					f_loss = rand(60, 70)
					adjust_stagger(4)
					add_slowdown(4)
					adjust_sunder(45)
				else //Lower than SCP_BOMB_RESIST_1
					b_loss = rand(65, 75)
					f_loss = rand(65, 75)
					adjust_stagger(5)
					add_slowdown(5)
					adjust_sunder(50)
		if(EXPLODE_LIGHT)
			switch(bomb_armor)
				if(SCP_BOMB_RESIST_4 to INFINITY)
					return //Immune
				if(SCP_BOMB_RESIST_3 to SCP_BOMB_RESIST_4)
					b_loss = rand(30, 40)
					f_loss = rand(30, 40)
				if(SCP_BOMB_RESIST_2 to SCP_BOMB_RESIST_3)
					b_loss = rand(35, 45)
					f_loss = rand(35, 45)
					add_slowdown(1)
				if(SCP_BOMB_RESIST_1 to SCP_BOMB_RESIST_2)
					b_loss = rand(40, 50)
					f_loss = rand(40, 50)
					adjust_stagger(2)
					add_slowdown(2)
				else //Lower than SCP_BOMB_RESIST_1
					b_loss = rand(45, 55)
					f_loss = rand(45, 55)
					adjust_stagger(4)
					add_slowdown(4)

	apply_damage(b_loss, BRUTE, updating_health = TRUE)
	apply_damage(f_loss, BURN, updating_health = TRUE)


/mob/living/carbon/scp/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE)
	if(status_flags & (GODMODE))
		return
	var/hit_percent = (100 - blocked) * 0.01

	if(hit_percent <= 0) //total negation
		return 0

	damage *= CLAMP01(hit_percent) //Percentage reduction

	if(!damage) //no damage
		return 0

	//We still want to check for blood splash before we get to the damage application.
	var/chancemod = 0
	if(sharp)
		chancemod += 10
	if(edge) //Pierce weapons give the most bonus
		chancemod += 12
	if(def_zone != "chest") //Which it generally will be, vs xenos
		chancemod += 5

	SEND_SIGNAL(src, COMSIG_SCP_TAKING_DAMAGE, damage)

	if(stat == DEAD)
		return FALSE

	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage)
		if(BURN)
			adjustFireLoss(damage)

	if(updating_health)
		updatehealth()

	if(!damage) //If we've actually taken damage, check whether we alert the hive
		return

	if(!COOLDOWN_CHECK(src, scp_health_alert_cooldown))
		return
	//If we're alive and health is less than either the alert threshold, or the alert trigger percent, whichever is greater, and we're not on alert cooldown, trigger the hive alert
	if(stat == DEAD || (health > max(SCP_HEALTH_ALERT_TRIGGER_THRESHOLD, maxHealth * SCP_HEALTH_ALERT_TRIGGER_PERCENT)))
		return

	var/list/filter_list = list()
	for(var/i in scp.get_all_scp())

		var/mob/living/carbon/scp/S = i
		if(!S.client) //Don't bother if they don't have a client; also runtime filters
			continue

		if(S == src) //We don't need an alert about ourself.
			filter_list += S //Add the scp to the filter list

		if(S.client.prefs.mute_xeno_health_alert_messages) //Build the filter list; people who opted not to receive health alert messages
			filter_list += S //Add the scp to the filter list

	scp_message("Our sister [name] is badly hurt with <font color='red'>([health]/[maxHealth])</font> health remaining at [AREACOORD_NO_Z(src)]!", "scpannounce", 5, scpnumber, FALSE, src, 'sound/voice/alien_help1.ogg', TRUE, filter_list, /obj/screen/arrow/silo_damaged_arrow)
	COOLDOWN_START(src, scp_health_alert_cooldown, SCP_HEALTH_ALERT_COOLDOWN) //set the cooldown.

	return damage


/mob/living/carbon/scp/adjustBruteLoss(amount, updating_health = FALSE)
	var/list/amount_mod = list()
	SEND_SIGNAL(src, COMSIG_SCP_BRUTE_DAMAGE, amount, amount_mod)
	for(var/i in amount_mod)
		amount -= i

	bruteloss = clamp(bruteloss + amount, 0, maxHealth - crit_health)

	if(updating_health)
		updatehealth()
