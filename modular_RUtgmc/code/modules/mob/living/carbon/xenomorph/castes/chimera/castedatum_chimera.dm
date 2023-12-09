/datum/xeno_caste/chimera
	caste_name = "Chimera"
	display_name = "Chimera"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/xenomorph/chimera
	caste_desc = "A slim, deadly alien creature. It has two additional arms with mantis blades."
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "chimera" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 25
	attack_delay = 7

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 50

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/wraith

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 55, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 40, FIRE = 50, ACID = 40)

	minimap_icon = "chimera"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/blink,
	)

/datum/xeno_caste/chimera/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/chimera/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/blink,
	)
