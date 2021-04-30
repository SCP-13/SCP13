#define DEBUG_SCP_LIFE	0
#define SCP_RESTING_HEAL 1.1
#define SCP_STANDING_HEAL 0.2
#define SCP_CRIT_DAMAGE 5

/mob/living/carbon/scp/Life()

	if(!loc)
		return

	..()

	if(notransform) //If we're in true stasis don't bother processing life
		return

	if(stat == DEAD) //Dead, nothing else to do but this.
		SSmobs.stop_processing(src)
		return

	handle_living_sunder_updates()
	handle_living_health_updates()
	update_action_button_icons()
	update_icons()

///Handles sunder modification/recovery during life.dm for xenos
/mob/living/carbon/scp/proc/handle_living_sunder_updates()

	if(!sunder || on_fire) //No sunder, no problem; or we're on fire and can't regenerate.
		return

	var/sunder_recov = 0.5 * -0.5 //Baseline

	if(resting) //Resting doubles sunder recovery
		sunder_recov *= 2

	SEND_SIGNAL(src, COMSIG_SCP_SUNDER_REGEN, src)

	adjust_sunder(sunder_recov)

/mob/living/carbon/scp/proc/handle_critical_health_updates()
	adjustBruteLoss(SCP_CRIT_DAMAGE) //Warding can heavily lower the impact of bleedout. Halved at 5.

/mob/living/carbon/scp/proc/handle_living_health_updates()
	if(health < 0)
		handle_critical_health_updates()
		return
	if((health >= maxHealth) || on_fire) //can't regenerate.
		updatehealth() //Update health-related stats, like health itself (using brute and fireloss), health HUD and status.
		return
	var/turf/T = loc
	if(!T || !istype(T))
		return

	updatehealth()

/mob/living/carbon/scp/adjust_stagger(amount)
	if(is_charging >= CHARGE_ON) //If we're charging we don't accumulate more stagger stacks.
		return FALSE
	return ..()
