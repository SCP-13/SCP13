/*
Contains most of the procs that are called when a scp is attacked by something
*/

/mob/living/carbon/scp/has_smoke_protection()
	return TRUE

/mob/living/carbon/scp/smoke_contact(obj/effect/particle_effect/smoke/S)
	var/protection = max(1 - get_permeability_protection() * S.bio_protection) //0.2 by default
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_EXTINGUISH))
		ExtinguishMob()
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		adjustFireLoss(12 * (protection + 0.6))
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.reagents?.reaction(src, TOUCH, S.fraction)

/mob/living/carbon/scp/Stun(amount, updating, ignore_canstun)
	amount *= 0.5 // half length
	return ..()

/mob/living/carbon/scp/Paralyze(amount, updating, ignore_canstun)
	amount *= 0.2 // replaces the old knock_down -5
	return ..()
