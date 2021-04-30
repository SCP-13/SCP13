//There has to be a better way to define this shit. ~ Z
//can't equip anything
/mob/living/carbon/scp/attack_ui(slot_id)
	return

/mob/living/carbon/scp/attack_animal(mob/living/M as mob)

	if(isanimal(M))
		var/mob/living/simple_animal/S = M
		if(!S.melee_damage)
			M.do_attack_animation(src)
			S.emote("me", EMOTE_VISIBLE, "[S.friendly] [src]")
		else
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			visible_message("<span class='danger'>[S] [S.attacktext] [src]!</span>", null, null, 5)
			var/damage = S.melee_damage
			apply_damage(damage, BRUTE)
			UPDATEHEALTH(src)
			log_combat(S, src, "attacked")

/mob/living/carbon/scp/attack_paw(mob/living/carbon/human/user)
	. = ..()

	switch(user.a_intent)

		if(INTENT_HELP)
			help_shake_act(user)
		else
			if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
				return 0
			if(health > 0)
				user.do_attack_animation(src, ATTACK_EFFECT_BITE)
				playsound(loc, 'sound/weapons/bite.ogg', 25, 1)
				visible_message("<span class='danger'>\The [user] bites \the [src].</span>", \
				"<span class='danger'>We are bit by \the [user].</span>", null, 5)
				apply_damage(rand(1, 3), BRUTE)
				UPDATEHEALTH(src)

/mob/living/carbon/scp/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		return

	if(status_flags & INCORPOREAL) //Incorporeal xenos cannot attack
		return

	var/mob/living/carbon/human/H = user

	H.changeNext_move(7)
	switch(H.a_intent)

		if(INTENT_HELP)
			if(stat == DEAD)
				H.visible_message("<span class='warning'>\The [H] pokes \the [src], but nothing happens.</span>", \
				"<span class='warning'>You poke \the [src], but nothing happens.</span>", null, 5)
			else
				H.visible_message("<span class='notice'>\The [H] pets \the [src].</span>", \
					"<span class='notice'>You pet \the [src].</span>", null, 5)

		if(INTENT_GRAB)
			if(H == src || anchored)
				return 0

			H.start_pulling(src)

		if(INTENT_DISARM, INTENT_HARM)
			var/datum/unarmed_attack/attack = H.species.unarmed
			if(!attack.is_usable(H))
				attack = H.species.secondary_unarmed
			if(!attack.is_usable(H))
				return FALSE

			if(!H.melee_damage)
				H.do_attack_animation(src)
				playsound(loc, attack.miss_sound, 25, TRUE)
				visible_message("<span class='danger'>[H] tried to [pick(attack.attack_verb)] [src]!</span>", null, null, 5)
				return FALSE

			H.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
			playsound(loc, attack.attack_sound, 25, TRUE)
			visible_message("<span class='danger'>[H] [pick(attack.attack_verb)]ed [src]!</span>", null, null, 5)
			apply_damage(melee_damage + attack.damage, BRUTE, "chest", soft_armor.getRating("melee"), updating_health = TRUE)

