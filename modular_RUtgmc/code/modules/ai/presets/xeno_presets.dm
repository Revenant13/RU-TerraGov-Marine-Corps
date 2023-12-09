/mob/living/carbon/xenomorph/facehugger/ai

/mob/living/carbon/xenomorph/facehugger/ai/Initialize(mapload)
	. = ..()
	GLOB.hive_datums[hivenumber].facehuggers -= src
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/chimera/ai

/mob/living/carbon/xenomorph/chimera/ai/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/chimera/aiclone

/mob/living/carbon/xenomorph/chimera/aiclone/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)
	addtimer(CALLBACK(src, PROC_REF(gib)), 7 SECONDS)
