/*
BLICNKNG CONTROLLER COMPONENT
*/

#define BLINCKING_TIME 20 SECONDS
#define AFTER_BLINCKING_TIME 2.5 SECONDS

/datum/component/blincking
	var/next_blincking
	var/after_blincking

//Initialize blicking
/datum/component/blincking/Initialize()
	if(!isliving(parent)) //WORKS only with lives
		return COMPONENT_INCOMPATIBLE
	var/mob/living/player = parent
	next_blincking = world.time + BLINCKING_TIME
	player.next_blinck = next_blincking
	after_blincking = next_blincking + AFTER_BLINCKING_TIME + 12
	START_PROCESSING(SSprocessing, src)

//Check blicking
/datum/component/blincking/process()
	if(!isliving(parent))
		qdel(src)

	if(world.time >= next_blincking)
		blinck()

	if(world.time >= after_blincking)
		after_blinck()

/datum/component/blincking/proc/blinck(time_animation = AFTER_BLINCKING_TIME, time_end_animation = 6, time_start_animation = 6, force = FALSE)
	if(force)
		after_blincking = world.time + AFTER_BLINCKING_TIME
	var/mob/living/player = parent
	ADD_TRAIT(player, TRAIT_VISION_BLOCKED, src)
	player.overlay_fullscreen_timer(time_animation, time_end_animation, "blincking", /obj/screen/fullscreen/black, start_animated = time_start_animation)

	next_blincking = world.time + BLINCKING_TIME + time_animation + time_end_animation + time_start_animation
	player.next_blinck = next_blincking

/datum/component/blincking/proc/after_blinck(time_animation = AFTER_BLINCKING_TIME)
	REMOVE_TRAIT(parent, TRAIT_VISION_BLOCKED, src)

	after_blincking = next_blincking + time_animation

//Destroy proccess if player dead.
/datum/component/blicking/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()
