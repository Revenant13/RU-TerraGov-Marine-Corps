// ***************************************
// *********** Runner's Pounce
// ***************************************
#define RUNNER_POUNCE_RANGE 6 // in tiles
#define RUNNER_SAVAGE_DAMAGE_MINIMUM 15

/datum/action/xeno_action/activable/pounce/runner
	desc = "Leap at your target, tackling and disarming them. Alternate use toggles Savage off or on."
	action_icon_state = "pounce_savage_on"
	plasma_cost = 10
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RUNNER_POUNCE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_TOGGLE_SAVAGE,
	)
	pounce_range = RUNNER_POUNCE_RANGE
	/// Whether Savage is active or not.
	var/savage_activated = TRUE

/datum/action/xeno_action/activable/pounce/runner/alternate_action_activate()
	savage_activated = !savage_activated
	owner.balloon_alert(owner, "Savage [savage_activated ? "activated" : "deactivated"]")
	action_icon_state = "pounce_savage_[savage_activated? "on" : "off"]"
	update_button_icon()

/datum/action/xeno_action/activable/pounce/runner/mob_hit(datum/source, mob/living/living_target)
	. = ..()
	if(!savage_activated)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/savage_cost = RUNNER_SAVAGE_DAMAGE_MINIMUM * 2
	if(xeno_owner.plasma_stored < savage_cost)
		owner.balloon_alert(owner, "Not enough plasma to Savage")
		return
	living_target.attack_alien_harm(xeno_owner, max(RUNNER_SAVAGE_DAMAGE_MINIMUM, xeno_owner.plasma_stored * 0.15))
	xeno_owner.use_plasma(savage_cost)
	GLOB.round_statistics.runner_savage_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_savage_attacks")
	M.attack_alien_harm(src, extra_dam, FALSE, TRUE, TRUE, TRUE) //Inflict a free attack on pounce that deals +1 extra damage per 4 plasma stored, up to 35 or twice the max damage of an Ancient Runner attack.
	use_plasma(extra_dam * 2)
	savage_used = TRUE
	addtimer(CALLBACK(src, PROC_REF(savage_cooldown)), xeno_caste.savage_cooldown)

	return TRUE

/mob/living/carbon/xenomorph/proc/savage_cooldown()
	if(!savage_used)//sanity check/safeguard
		return
	savage_used = FALSE
	to_chat(src, span_xenowarning("<b>We can now savage our victims again.</b>"))
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	update_action_buttons()

// ***************************************
// *********** Pouncey
// ***************************************
/datum/action/xeno_action/activable/pounce
	name = "Pounce"
	action_icon_state = "pounce"
	desc = "Leap at your target, tackling and disarming them."
	ability_name = "pounce"
	plasma_cost = 10
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_POUNCE,
	)
	use_state_flags = XACT_USE_BUCKLED
	///How far can we pounce.
	var/range = 6
	///For how long will we stun the victim
	var/victim_paralyze_time = 2 SECONDS
	///For how long will we freeze upon hitting our target
	var/freeze_on_hit_time = 0.5 SECONDS

// TODO: merge defender/ravager pounces into this typepath since they are essentially the same thing
/datum/action/xeno_action/activable/pounce/proc/pounce_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENO_LIVING_THROW_HIT))
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_POUNCE_END)

/datum/action/xeno_action/activable/pounce/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	target.hitby(owner, speed)
	pounce_complete()

/datum/action/xeno_action/activable/pounce/proc/mob_hit(datum/source, mob/living/M)
	SIGNAL_HANDLER
	if(M.stat || isxeno(M))
		return
	var/mob/living/carbon/xenomorph/X = owner
	if(ishuman(M) && (M.dir in reverse_nearby_direction(X.dir)))
		var/mob/living/carbon/human/H = M
		if(!H.check_shields(COMBAT_TOUCH_ATTACK, 30, "melee"))
			X.Paralyze(6 SECONDS)
			X.set_throwing(FALSE) //Reset throwing manually.
			return COMPONENT_KEEP_THROWING

	X.visible_message(span_danger("[X] pounces on [M]!"),
					span_xenodanger("We pounce on [M]!"), null, 5)

	if(victim_paralyze_time)
		M.Paralyze(victim_paralyze_time)

	X.forceMove(get_turf(M))
	if(freeze_on_hit_time)
		X.Immobilize(freeze_on_hit_time)
	if(X.savage) //If Runner Savage is toggled on, attempt to use it.
		if(!X.savage_used)
			if(X.plasma_stored >= 10)
				INVOKE_ASYNC(X, TYPE_PROC_REF(/mob/living/carbon/xenomorph, Savage), M)
			else
				X.balloon_alert(X, "Cannot savage, no plasma")
				to_chat(X, span_xenodanger("We attempt to savage our victim but we need at least [10-X.plasma_stored] more plasma."))
		else
			X.balloon_alert(X, "Cannot savage, not ready")

	playsound(X.loc, 'sound/voice/alien_pounce.ogg', 25, TRUE)

	pounce_complete()

/datum/action/xeno_action/activable/pounce/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!A || A.layer >= FLY_LAYER)
		return FALSE

/datum/action/xeno_action/activable/pounce/proc/prepare_to_pounce()
	if(owner.layer == XENO_HIDING_LAYER) //Xeno is currently hiding, unhide him
		owner.layer = MOB_LAYER
		var/datum/action/xeno_action/xenohide/hide_action = owner.actions_by_path[/datum/action/xeno_action/xenohide]
		hide_action?.button?.cut_overlay(mutable_appearance('modular_RUtgmc/icons/Xeno/actions.dmi', "selected_purple_frame", ACTION_LAYER_ACTION_ICON_STATE, FLOAT_PLANE)) // Removes Hide action icon border // RUTGMC edit - icon change
	if(owner.buckled)
		owner.buckled.unbuckle_mob(owner)

/datum/action/xeno_action/activable/pounce/get_cooldown()
	var/mob/living/carbon/xenomorph/X = owner
	return X.xeno_caste.pounce_delay

/datum/action/xeno_action/activable/pounce/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We're ready to pounce again."))
	playsound(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	var/mob/living/carbon/xenomorph/X = owner
	X.usedPounce = FALSE
	return ..()

/datum/action/xeno_action/activable/pounce/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	RegisterSignal(X, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(obj_hit))
	RegisterSignal(X, COMSIG_XENO_LIVING_THROW_HIT, PROC_REF(mob_hit))
	RegisterSignal(X, COMSIG_MOVABLE_POST_THROW, PROC_REF(pounce_complete))

	prepare_to_pounce()

	X.visible_message(span_xenowarning("\The [X] pounces at [A]!"), \
	span_xenowarning("We pounce at [A]!"))

	SEND_SIGNAL(X, COMSIG_XENOMORPH_POUNCE)

	succeed_activate()
	add_cooldown()
	X.usedPounce = TRUE // this is needed for throwing code
	X.pass_flags |= PASS_LOW_STRUCTURE|PASS_FIRE
	X.throw_at(A, range, 2, X) //Victim, distance, speed

	addtimer(CALLBACK(X, TYPE_PROC_REF(/mob/living/carbon/xenomorph, reset_allow_pass_flags)), 6)

	return TRUE

/mob/living/carbon/xenomorph/proc/reset_allow_pass_flags()
	if(!xeno_caste.hardcore)
		pass_flags = initial(pass_flags) //Reset the PASS_LOW_STRUCTURE.
	else
		pass_flags = NONE //Reset the PASS_LOW_STRUCTURE.

	//AI stuff
/datum/action/xeno_action/activable/pounce/ai_should_start_consider()
	return TRUE


// ***************************************
// *********** Evasion
// ***************************************
#define RUNNER_EVASION_DURATION 2 //seconds
#define RUNNER_EVASION_MAX_DURATION 6 //seconds
#define RUNNER_EVASION_RUN_DELAY 0.5 SECONDS // If the time since the Runner last moved is equal to or greater than this, its Evasion ends.
#define RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD 120 // If we dodge this much damage times our streak count plus 1 while evading, refresh the cooldown of Evasion.

/datum/action/xeno_action/evasion
	name = "Evasion"
	action_icon_state = "evasion_on"
	desc = "Take evasive action, forcing non-friendly projectiles that would hit you to miss for a short duration so long as you keep moving. Alternate use toggles Auto Evasion off or on."
	plasma_cost = 75
	cooldown_timer = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EVASION,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_AUTO_EVASION,
	)
	/// Whether auto evasion is on or off.
	var/auto_evasion = TRUE
	/// Whether evasion is currently active
	var/evade_active = FALSE
	/// How long our Evasion will last.
	var/evasion_duration = 0
	/// Current amount of Evasion stacks.
	var/evasion_stacks = 0

/datum/action/xeno_action/evasion/on_cooldown_finish()
	. = ..()
	owner.balloon_alert(owner, "Evasion ready")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)

/datum/action/xeno_action/evasion/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.on_fire)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "Can't while on fire!")
		return FALSE

/datum/action/xeno_action/evasion/alternate_action_activate()
	auto_evasion = !auto_evasion
	owner.balloon_alert(owner, "Auto Evasion [auto_evasion ? "activated" : "deactivated"]")
	action_icon_state = "evasion_[auto_evasion? "on" : "off"]"
	update_button_icon()

/datum/action/xeno_action/evasion/action_activate()
	succeed_activate()
	add_cooldown()
	if(evade_active)
		evasion_stacks = 0
		evasion_duration = min(evasion_duration + RUNNER_EVASION_DURATION, RUNNER_EVASION_MAX_DURATION)
		owner.balloon_alert(owner, "Extended evasion: [evasion_duration]s.")
		return
	evade_active = TRUE
	evasion_duration = RUNNER_EVASION_DURATION
	owner.balloon_alert(owner, "Begin evasion: [evasion_duration]s.")
	to_chat(owner, span_highdanger("We take evasive action, making us impossible to hit."))
	START_PROCESSING(SSprocessing, src)
	RegisterSignals(owner, list(COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER,
		COMSIG_LIVING_IGNITED), PROC_REF(evasion_debuff_check))
	RegisterSignal(owner, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(evasion_dodge))
	RegisterSignal(owner, COMSIG_ATOM_BULLET_ACT, PROC_REF(evasion_flamer_hit))
	RegisterSignal(owner, COMSIG_LIVING_PRE_THROW_IMPACT, PROC_REF(evasion_throw_dodge))
	GLOB.round_statistics.runner_evasions++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_evasions")

/datum/action/xeno_action/evasion/process()
	if(evasion_duration <= 0)
		evasion_deactivate()
		return
	evasion_duration--
	var/mob/living/carbon/xenomorph/runner/runner_owner = owner
	runner_owner.hud_set_evasion(evasion_duration)

/**
 * Called when the owner is hit by a flamethrower projectile.
 * Reduces evasion stacks based on the damage received.
*/
/datum/action/xeno_action/evasion/proc/evasion_flamer_hit(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER
	if(!(proj.ammo.flags_ammo_behavior & AMMO_FLAME))
		return
	evasion_stacks = max(0, evasion_stacks - proj.damage) // We lose evasion stacks equal to the burn damage.
	if(evasion_stacks)
		owner.balloon_alert(owner, "Evasion reduced, damaged")
		to_chat(owner, span_danger("The searing fire compromises our ability to dodge![RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks > 0 ? " We must dodge [RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks] more projectile damage before Evasion's cooldown refreshes." : ""]"))
	else // If we have no stacks left, disable Evasion.
		evasion_deactivate()

/**
 * Called after getting hit with an Evasion disabling debuff.
 * Checks if evasion is active, and if the debuff inflicted any stacks, disabling Evasion if so.
*/
/datum/action/xeno_action/evasion/proc/evasion_debuff_check(datum/source, amount)
	SIGNAL_HANDLER
	if(!(amount > 0) || !evade_active)
		return
	evasion_deactivate()

/// Deactivates Evasion, clearing signals, vars, etc.
/datum/action/xeno_action/evasion/proc/evasion_deactivate()
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(owner, list(
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER,
		COMSIG_LIVING_IGNITED,
		COMSIG_XENO_PROJECTILE_HIT,
		COMSIG_LIVING_PRE_THROW_IMPACT,
		COMSIG_ATOM_BULLET_ACT
		))
	evade_active = FALSE
	evasion_stacks = 0
	owner.balloon_alert(owner, "Evasion ended")
	owner.playsound_local(owner, 'sound/voice/hiss5.ogg', 50)
	var/mob/living/carbon/xenomorph/runner/runner_owner = owner
	runner_owner.hud_set_evasion(evasion_duration)

/// Determines whether or not a thrown projectile is dodged while the Evasion ability is active
/datum/action/xeno_action/evasion/proc/evasion_throw_dodge(datum/source, atom/movable/proj)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!evade_active) //If evasion is not active we don't dodge
		return NONE
	if((xeno_owner.last_move_time < (world.time - RUNNER_EVASION_RUN_DELAY))) //Gotta keep moving to benefit from evasion!
		return NONE
	if(isitem(proj))
		var/obj/item/I = proj
		evasion_stacks += I.throwforce //Add to evasion stacks for the purposes of determining whether or not our cooldown refreshes equal to the thrown force
	evasion_dodge_fx(proj)
	return COMPONENT_PRE_THROW_IMPACT_HIT

/// This is where the dodgy magic happens
/datum/action/xeno_action/evasion/proc/evasion_dodge(datum/source, obj/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER
	if(!evade_active) //If evasion is not active we don't dodge
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if((xeno_owner.last_move_time < (world.time - RUNNER_EVASION_RUN_DELAY))) //Gotta keep moving to benefit from evasion!
		return FALSE
	if(xeno_owner.issamexenohive(proj.firer)) //We automatically dodge allied projectiles at no cost, and no benefit to our evasion stacks
		return COMPONENT_PROJECTILE_DODGE
	if(proj.ammo.flags_ammo_behavior & AMMO_FLAME) //We can't dodge literal fire
		return FALSE
	if(!(proj.ammo.flags_ammo_behavior & AMMO_SENTRY) && !xeno_owner.fire_stacks) //We ignore projectiles from automated sources/sentries for the purpose of contributions towards our cooldown refresh; also fire prevents accumulation of evasion stacks
		evasion_stacks += proj.damage //Add to evasion stacks for the purposes of determining whether or not our cooldown refreshes
	evasion_dodge_fx(proj)
	return COMPONENT_PROJECTILE_DODGE

/// Handles dodge effects and visuals for the Evasion ability.
/datum/action/xeno_action/evasion/proc/evasion_dodge_fx(atom/movable/proj)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.visible_message(span_warning("[xeno_owner] effortlessly dodges the [proj.name]!"), \
	span_xenodanger("We effortlessly dodge the [proj.name]![(RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks) > 0 && evasion_stacks > 0 ? " We must dodge [RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks] more projectile damage before [src]'s cooldown refreshes." : ""]"))
	xeno_owner.add_filter("runner_evasion", 2, gauss_blur_filter(5))
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/atom, remove_filter), "runner_evasion"), 0.5 SECONDS)
	xeno_owner.do_jitter_animation(4000)
	if(evasion_stacks >= RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD && cooldown_remaining()) //We have more evasion stacks than needed to refresh our cooldown, while being on cooldown.
		clear_cooldown()
		if(auto_evasion && xeno_owner.plasma_stored >= plasma_cost)
			action_activate()
	var/turf/current_turf = get_turf(xeno_owner) //location of after image SFX
	playsound(current_turf, pick('sound/effects/throw.ogg','sound/effects/alien_tail_swipe1.ogg', 'sound/effects/alien_tail_swipe2.ogg'), 25, 1) //sound effects
	var/obj/effect/temp_visual/xenomorph/afterimage/after_image
	for(var/i=0 to 2) //number of after images
		after_image = new /obj/effect/temp_visual/xenomorph/afterimage(current_turf, owner) //Create the after image.
		after_image.pixel_x = pick(rand(xeno_owner.pixel_x * 3, xeno_owner.pixel_x * 1.5), rand(0, xeno_owner.pixel_x * -1)) //Variation on the X position


// ***************************************
// *********** Snatch
// ***************************************
/datum/action/xeno_action/activable/snatch
	name = "Snatch"
	action_icon_state = "snatch"
	desc = "Take an item equipped by your target in your mouth, and carry it away."
	plasma_cost = 75
	cooldown_timer = 60 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SNATCH,
	)
	target_flags = XABB_MOB_TARGET
	///If the runner have an item
	var/obj/item/stolen_item = FALSE
	///Mutable appearance of the stolen item
	var/mutable_appearance/stolen_appearance
	///A list of slot to check for items, in order of priority
	var/static/list/slots_to_steal_from = list(
		SLOT_S_STORE,
		SLOT_BACK,
		SLOT_SHOES,
	)

/datum/action/xeno_action/activable/snatch/action_activate()
	if(!stolen_item)
		return ..()
	drop_item()

/datum/action/xeno_action/activable/snatch/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(!owner.Adjacent(A))
		if(!silent)
			owner.balloon_alert(owner, "Cannot reach")
		return FALSE
	if(!ishuman(A))
		if(!silent)
			owner.balloon_alert(owner, "Cannot snatch")
		return FALSE
	var/mob/living/carbon/human/target = A
	if(target.stat == DEAD)
		if(!silent)
			owner.balloon_alert(owner, "Cannot snatch")
		return FALSE
	if(target.status_flags & GODMODE)
		if(!silent)
			owner.balloon_alert(owner, "Cannot snatch")
		return FALSE

/datum/action/xeno_action/activable/snatch/use_ability(atom/A)
	succeed_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(!do_after(owner, 0.5 SECONDS, FALSE, A, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner, TYPE_PROC_REF(/mob, break_do_after_checks), list("health" = X.health))))
		return FALSE
	var/mob/living/carbon/human/victim = A
	stolen_item = victim.get_active_held_item()
	if(!stolen_item)
		stolen_item = victim.get_inactive_held_item()
		for(var/slot in slots_to_steal_from)
			stolen_item = victim.get_item_by_slot(slot)
			if(stolen_item)
				break
	if(!stolen_item)
		victim.balloon_alert(owner, "Snatch failed, no item")
		return fail_activate()
	playsound(owner, 'sound/voice/alien_pounce2.ogg', 30)
	victim.dropItemToGround(stolen_item, TRUE)
	stolen_item.forceMove(owner)
	stolen_appearance = mutable_appearance(stolen_item.icon, stolen_item.icon_state)
	stolen_appearance.layer = ABOVE_OBJ_LAYER
	addtimer(CALLBACK(src, PROC_REF(drop_item), stolen_item), 3 SECONDS)
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(owner_turned))
	owner.add_movespeed_modifier(MOVESPEED_ID_SNATCH, TRUE, 0, NONE, TRUE, 2)
	owner_turned(null, null, owner.dir)
	add_cooldown()

///Signal handler to update the item overlay when the owner is changing dir
/datum/action/xeno_action/activable/snatch/proc/owner_turned(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(!new_dir || new_dir == old_dir)
		return
	owner.overlays -= stolen_appearance
	var/matrix/new_transform = stolen_appearance.transform
	switch(old_dir)
		if(NORTH)
			new_transform.Translate(-15, -12)
		if(SOUTH)
			new_transform.Translate(-15, 12)
		if(EAST)
			new_transform.Translate(-35, 0)
		if(WEST)
			new_transform.Translate(5, 0)
	switch(new_dir)
		if(NORTH)
			new_transform.Translate(15, 12)
		if(SOUTH)
			new_transform.Translate(15, -12)
		if(EAST)
			new_transform.Translate(35, 0)
		if(WEST)
			new_transform.Translate(-5, 0)
	stolen_appearance.transform = new_transform
	owner.overlays += stolen_appearance

///Force the xeno owner to drop the stolen item
/datum/action/xeno_action/activable/snatch/proc/drop_item()
	if(!stolen_item)
		return
	owner.remove_movespeed_modifier(MOVESPEED_ID_SNATCH)
	stolen_item.forceMove(get_turf(owner))
	stolen_item = null
	owner.overlays -= stolen_appearance
	playsound(owner, 'sound/voice/alien_pounce2.ogg', 30, frequency = -1)
	UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)

