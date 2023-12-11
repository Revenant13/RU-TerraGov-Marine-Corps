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
	max_health = 350

	// *** Evolution *** //
	// upgrade_threshold = TIER_THREE_THRESHOLD // RUTGMC DELETION

	deevolves_to = /mob/living/carbon/xenomorph/wraith

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 55, LASER = 50, ENERGY = 50, BOMB = 0, BIO = 40, FIRE = 50, ACID = 40)

	wraith_blink_range = 5

	minimap_icon = "chimera"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/blink,
		/datum/action/ability/xeno_action/phantom,
		/datum/action/ability/activable/xeno/pounce/abduction,
		/datum/action/ability/activable/xeno/body_swap,
		/datum/action/ability/xeno_action/supernova,
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
		/datum/action/ability/xeno_action/phantom,
		/datum/action/ability/activable/xeno/pounce/abduction,
		/datum/action/ability/activable/xeno/body_swap,
		/datum/action/ability/xeno_action/supernova,
		/datum/action/ability/xeno_action/crippling_strike,
	)
