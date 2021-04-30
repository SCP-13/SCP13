
/mob/living/carbon/scp/UnarmedAttack(atom/A, has_proximity, modifiers)
	if(lying_angle)
		return FALSE

	changeNext_move(CLICK_CD_MELEE)

	var/atom/S = A.handle_barriers(src)

