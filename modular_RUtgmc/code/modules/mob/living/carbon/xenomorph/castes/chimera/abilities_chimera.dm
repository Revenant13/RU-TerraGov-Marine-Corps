/datum/action/ability/xeno_action/phantom
	name = "Phantom"
	action_icon_state = ""
	desc = ""
	cooldown_duration = 20 SECONDS
	ability_cost = 100
	keybinding_signals = list()
	var/stealth_duration = 5 SECONDS
	var/mob/living/carbon/xenomorph/chimera/ai/phantom
	var/clone_duration = 7 SECONDS

/datum/action/ability/xeno_action/phantom/on_cooldown_finish()
	to_chat(owner, span_xenodanger(""))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/xeno_action/phantom/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/chimera/X = owner

	X.alpha = HUNTER_STEALTH_STILL_ALPHA
	addtimer(CALLBACK(src, PROC_REF(uncloak)), stealth_duration)

	RegisterSignals(X, list(
		COMSIG_XENOMORPH_GRAB,
		COMSIG_XENOMORPH_THROW_HIT,
		COMSIG_LIVING_IGNITED,
		COMSIG_XENOMORPH_ATTACK_OBJ,
		COMSIG_XENOMORPH_ATTACK_LIVING,
		COMSIG_XENO_LIVING_THROW_HIT,
		COMSIG_XENOMORPH_DISARM_HUMAN), PROC_REF(uncloak))

	ADD_TRAIT(X, TRAIT_TURRET_HIDDEN, STEALTH_TRAIT)

	phantom = new /mob/living/carbon/xenomorph/chimera/ai(get_turf(X))
	addtimer(CALLBACK(phantom, TYPE_PROC_REF(/mob, gib)), clone_duration)

	add_cooldown()

/datum/action/ability/xeno_action/phantom/proc/uncloak()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/chimera/X = owner
	X.alpha = 255

	UnregisterSignal(X, list(
		COMSIG_XENOMORPH_GRAB,
		COMSIG_XENOMORPH_THROW_HIT,
		COMSIG_LIVING_IGNITED,
		COMSIG_XENOMORPH_ATTACK_OBJ,
		COMSIG_XENOMORPH_ATTACK_LIVING,
		COMSIG_XENO_LIVING_THROW_HIT,
		COMSIG_XENOMORPH_DISARM_HUMAN,))

	REMOVE_TRAIT(X, TRAIT_TURRET_HIDDEN, STEALTH_TRAIT)

/datum/action/ability/xeno_action/phantom/ai_should_start_consider()
	return FALSE

/datum/action/ability/xeno_action/phantom/ai_should_use(target)
	return FALSE

/datum/action/ability/activable/xeno/pounce/abduction
	name = "Abduction"
	action_icon_state = ""
	desc = ""
	cooldown_duration = 20 SECONDS
	ability_cost = 100
	keybinding_signals = list()
	var/turf/initial_turf

/datum/action/ability/activable/xeno/pounce/abduction/use_ability(atom/A)
	initial_turf = get_turf(owner)
	return ..()

/datum/action/ability/activable/xeno/pounce/abduction/mob_hit(datum/source, mob/living/living_target)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(abduct), living_target)

/datum/action/ability/activable/xeno/pounce/abduction/proc/abduct(mob/living/target)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(movement_fx))
	if(!do_after(xeno_owner, 0.5 SECONDS))
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		return
	xeno_owner.throw_at(initial_turf, pounce_range, XENO_POUNCE_SPEED, xeno_owner)
	target.throw_at(initial_turf, pounce_range, XENO_POUNCE_SPEED, xeno_owner)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/datum/action/ability/xeno_action/supernova
	name = ""
	action_icon_state = ""
	desc = ""
	cooldown_duration = 10 SECONDS
	ability_cost = 500
	keybinding_signals = list()
