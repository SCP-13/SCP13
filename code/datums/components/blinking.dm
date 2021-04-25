/*
BLICNKNG CONTROLLER COMPONENT
*/

#define BLINCKING_TIME 25 SECONDS
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
	after_blincking = next_blincking + AFTER_BLINCKING_TIME
	START_PROCESSING(SSprocessing, src)

//Check blicking
/datum/component/blincking/process()
	if(!isliving(parent))
		qdel(src)

	if(world.time >= next_blincking)
		var/mob/living/player = parent
		ADD_TRAIT(player, TRAIT_VISION_BLOCKED, src)
		player.overlay_fullscreen_timer(AFTER_BLINCKING_TIME, 6, "blincking", /obj/screen/fullscreen/black, start_animated = 6)

		next_blincking = world.time + BLINCKING_TIME + 12
		player.next_blinck = next_blincking

	if(world.time >= after_blincking)
		var/mob/player = parent
		REMOVE_TRAIT(player, TRAIT_VISION_BLOCKED, src)

		after_blincking = next_blincking + AFTER_BLINCKING_TIME

//Destroy proccess if player dead.
/datum/component/blicking/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()
