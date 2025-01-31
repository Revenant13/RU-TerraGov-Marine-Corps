/datum/action/ability/xeno_action/watch_xeno
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_AGILITY

/datum/action/ability/activable/xeno/screech
	cooldown_duration = 60 SECONDS

/datum/action/ability/activable/xeno/screech/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/queen/X = owner

	var/datum/action/ability/xeno_action/heal_screech = X.actions_by_path[/datum/action/ability/activable/xeno/heal_screech]
	if(heal_screech)
		heal_screech.add_cooldown(5 SECONDS)
	var/datum/action/ability/xeno_action/plasma_screech = X.actions_by_path[/datum/action/ability/activable/xeno/plasma_screech]
	if(plasma_screech)
		plasma_screech.add_cooldown(5 SECONDS)
	var/datum/action/ability/xeno_action/frenzy_screech = X.actions_by_path[/datum/action/ability/activable/xeno/frenzy_screech]
	if(frenzy_screech)
		frenzy_screech.add_cooldown(5 SECONDS)

/datum/action/ability/activable/xeno/heal_screech
	name = "Heal Screech"
	action_icon_state = "heal_screech"
	desc = "Screech that heals nearby xenos."
	ability_cost = 250
	cooldown_duration = 30 SECONDS
	var/screech_range = 5
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HEAL_SCREECH,
	)

/datum/action/ability/activable/xeno/heal_screech/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/queen/X = owner

	for(var/mob/living/carbon/xenomorph/affected_xeno in cheap_get_xenos_near(X, screech_range))
		affected_xeno.apply_status_effect(/datum/status_effect/healing_infusion, HIVELORD_HEALING_INFUSION_DURATION / 3, HIVELORD_HEALING_INFUSION_TICKS / 2)

	playsound(X.loc, 'modular_RUtgmc/sound/voice/alien_heal_screech.ogg', 75, 0)
	X.visible_message(span_xenohighdanger("\The [X] emits an ear-splitting guttural roar!"))

	succeed_activate()
	add_cooldown()

	var/datum/action/ability/xeno_action/screech = X.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(screech)
		screech.add_cooldown(5 SECONDS)
	var/datum/action/ability/xeno_action/plasma_screech = X.actions_by_path[/datum/action/ability/activable/xeno/plasma_screech]
	if(plasma_screech)
		plasma_screech.add_cooldown(5 SECONDS)
	var/datum/action/ability/xeno_action/frenzy_screech = X.actions_by_path[/datum/action/ability/activable/xeno/frenzy_screech]
	if(frenzy_screech)
		frenzy_screech.add_cooldown(5 SECONDS)

/datum/action/ability/activable/xeno/plasma_screech
	name = "Plasma Screech"
	action_icon_state = "plasma_screech"
	desc = "Screech that increases plasma regeneration for nearby xenos."
	ability_cost = 250
	cooldown_duration = 30 SECONDS
	var/screech_range = 5
	var/bonus_regen = 0.5
	var/duration = 20 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PLASMA_SCREECH,
	)

/datum/action/ability/activable/xeno/plasma_screech/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/queen/X = owner

	for(var/mob/living/carbon/xenomorph/affected_xeno in cheap_get_xenos_near(X, screech_range))
		if(!(affected_xeno.xeno_caste.can_flags & CASTE_CAN_BE_GIVEN_PLASMA))
			continue
		affected_xeno.apply_status_effect(/datum/status_effect/plasma_surge, affected_xeno.xeno_caste.plasma_max / 2, bonus_regen, duration)

	playsound(X.loc, 'modular_RUtgmc/sound/voice/alien_plasma_screech.ogg', 75, 0)
	X.visible_message(span_xenohighdanger("\The [X] emits an ear-splitting guttural roar!"))

	succeed_activate()
	add_cooldown()

	var/datum/action/ability/xeno_action/screech = X.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(screech)
		screech.add_cooldown(5 SECONDS)
	var/datum/action/ability/xeno_action/heal_screech = X.actions_by_path[/datum/action/ability/activable/xeno/heal_screech]
	if(heal_screech)
		heal_screech.add_cooldown(5 SECONDS)
	var/datum/action/ability/xeno_action/frenzy_screech = X.actions_by_path[/datum/action/ability/activable/xeno/frenzy_screech]
	if(frenzy_screech)
		frenzy_screech.add_cooldown(5 SECONDS)

/datum/action/ability/activable/xeno/frenzy_screech
	name = "Frenzy Screech"
	action_icon_state = "frenzy_screech"
	desc = "Screech that increases damage for nearby xenos."
	ability_cost = 250
	cooldown_duration = 30 SECONDS
	var/screech_range = 5
	var/buff_duration = 10 SECONDS
	var/buff_damage_modifier = 0.1
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FRENZY_SCREECH,
	)

/datum/action/ability/activable/xeno/frenzy_screech/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/queen/X = owner

	for(var/mob/living/carbon/xenomorph/affected_xeno in cheap_get_xenos_near(X, screech_range))
		affected_xeno.apply_status_effect(/datum/status_effect/frenzy_screech, buff_duration, buff_damage_modifier)

	playsound(X.loc, 'modular_RUtgmc/sound/voice/alien_frenzy_screech.ogg', 75, 0)
	X.visible_message(span_xenohighdanger("\The [X] emits an ear-splitting guttural roar!"))

	succeed_activate()
	add_cooldown()

	var/datum/action/ability/xeno_action/screech = X.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(screech)
		screech.add_cooldown(5 SECONDS)
	var/datum/action/ability/xeno_action/heal_screech = X.actions_by_path[/datum/action/ability/activable/xeno/heal_screech]
	if(heal_screech)
		heal_screech.add_cooldown(5 SECONDS)
	var/datum/action/ability/xeno_action/plasma_screech = X.actions_by_path[/datum/action/ability/activable/xeno/plasma_screech]
	if(plasma_screech)
		plasma_screech.add_cooldown(5 SECONDS)
