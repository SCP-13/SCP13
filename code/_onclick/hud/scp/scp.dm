/obj/screen/scp
	icon = 'icons/mob/screen/scp.dmi'

/obj/screen/scp/Click()
	if(!isscp(usr))
		return FALSE
	return TRUE

/datum/hud/scp/New(mob/living/carbon/scp/owner, ui_style, ui_color, ui_alpha = 230)
	..()
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/act_intent/corner()
	using.alpha = ui_alpha
	using.icon_state = owner.a_intent
	static_inventory += using
	action_intent = using

	inv_box = new /obj/screen/inventory/hand/right()
	inv_box.icon = 'icons/mob/screen/scp.dmi'
	using.alpha = ui_alpha
	if(owner && !owner.hand)	//This being 0 or null means the right hand is in use
		using.add_overlay("hand_active")
	inv_box.slot_id = SLOT_R_HAND
	r_hand_hud_object = inv_box
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.icon = 'icons/mob/screen/scp.dmi'
	using.alpha = ui_alpha
	if(owner?.hand)	//This being 1 means the left hand is in use
		inv_box.add_overlay("hand_active")
	inv_box.slot_id = SLOT_L_HAND
	l_hand_hud_object = inv_box
	static_inventory += inv_box

	using = new /obj/screen/swap_hand()
	using.icon = 'icons/mob/screen/scp.dmi'
	using.alpha = ui_alpha
	static_inventory += using

	using = new /obj/screen/swap_hand/right()
	using.icon = 'icons/mob/screen/scp.dmi'
	using.alpha = ui_alpha
	static_inventory += using

/datum/hud/scp/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/scp/H = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		if(H.r_hand)
			H.r_hand.screen_loc = ui_rhand
			H.client.screen += H.r_hand
		if(H.l_hand)
			H.l_hand.screen_loc = ui_lhand
			H.client.screen += H.l_hand
	else
		if(H.r_hand)
			H.r_hand.screen_loc = null
		if(H.l_hand)
			H.l_hand.screen_loc = null
