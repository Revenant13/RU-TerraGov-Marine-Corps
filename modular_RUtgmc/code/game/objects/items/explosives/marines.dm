/obj/item/explosive/grenade/sticky
	icon_state_mini = "grenade_sticky"

/obj/item/explosive/grenade/sticky/trailblazer
	icon_state_mini = "grenade_trailblazer"
	var/fire_level = 25
	var/burn_level = 25
	var/fire_color = "red"
	var/our_fire_stacks = 0
	var/our_fire_damage = 0

/obj/item/explosive/grenade/sticky/trailblazer/stuck_to(atom/hit_atom)
	. = ..()
	RegisterSignal(stuck_to, COMSIG_MOVABLE_MOVED, PROC_REF(make_fire))
	var/turf/T = get_turf(src)
	T.ignite(fire_level, burn_level, fire_color, our_fire_stacks, our_fire_damage)

/obj/item/explosive/grenade/sticky/trailblazer/proc/make_fire(datum/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER
	var/turf/T = get_turf(src)
	T.ignite(fire_level, burn_level, fire_color, our_fire_stacks, our_fire_damage)

/obj/item/explosive/grenade/sticky/trailblazer/phosphorus
	name = "\improper M45 Phosphorus trailblazer grenade"
	desc = "Capsule based grenade that sticks to sufficiently hard surfaces, causing a trail of air combustable gel to form. But with phosphorus. It is set to detonate in 5 seconds."
	icon = 'modular_RUtgmc/icons/obj/items/grenade.dmi'
	icon_state = "grenade_sticky_phosphorus"
	item_state = "grenade_sticky_phosphorus"
	icon_state_mini = "grenade_trailblazer_phosphorus"
	fire_level = 50
	burn_level = 50
	fire_color = "blue"

/obj/item/explosive/grenade/sticky/trailblazer/phosphorus/activate(mob/user)
	. = ..()
	if(!.)
		return FALSE
	user?.record_war_crime()

/obj/item/explosive/grenade/sticky/trailblazer/phosphorus/prime()
	flame_radius(0.5, get_turf(src), colour = "blue")
	playsound(loc, "incendiary_explosion", 35)
	if(stuck_to)
		clean_refs()
	qdel(src)
