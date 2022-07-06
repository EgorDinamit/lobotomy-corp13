// Crimson dawn
/mob/living/simple_animal/hostile/ordeal/crimson_clown
	name = "cheers for the start"
	desc = "A tiny humanoid creature in jester's attire."
	icon = 'ModularTegustation/Teguicons/tegumobs.dmi'
	icon_state = "crimson_clown"
	icon_living = "crimson_clown"
	icon_dead = "crimson_clown_dead"
	faction = list("crimson_ordeal")
	maxHealth = 100
	health = 100
	speed = 1
	density = FALSE
	search_objects = TRUE
	wanted_objects = list(/obj/machinery/computer/abnormality)
	damage_coeff = list(BRUTE = 0.8, RED_DAMAGE = 1.3, WHITE_DAMAGE = 1.2, BLACK_DAMAGE = 1.3, PALE_DAMAGE = 2)

	/// When it hits console 15 times - reduce qliphoth and teleport
	var/console_attack_counter = 0

/mob/living/simple_animal/hostile/ordeal/crimson_clown/CanAttack(atom/the_target)
	if(istype(the_target, /obj/machinery/computer/abnormality))
		var/obj/machinery/computer/abnormality/CA = the_target
		if(CA.meltdown || !CA.datum_reference || !CA.datum_reference.current || !CA.datum_reference.qliphoth_meter)
			return FALSE
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/ordeal/crimson_clown/AttackingTarget()
	if(istype(target, /obj/machinery/computer/abnormality))
		var/obj/machinery/computer/abnormality/CA = target
		if(console_attack_counter < 15)
			console_attack_counter += 1
			visible_message("<span class='warning'>[src] hits [CA]'s buttons at random!</span>")
			playsound(get_turf(CA), "sound/machines/terminal_button0[rand(1,8)].ogg", 50, 1)
		else
			console_attack_counter = 0
			visible_message("<span class='warning'>[CA]'s screen produces an error!</span>")
			playsound(get_turf(CA), 'sound/machines/terminal_error.ogg', 50, 1)
			CA.datum_reference.qliphoth_change(-1, src)
			TeleportAway()
		return
	return ..()

/mob/living/simple_animal/hostile/ordeal/crimson_clown/death(gibbed)
	animate(src, transform = matrix()*1.8, color = "#FF0000", time = 15)
	addtimer(CALLBACK(src, .proc/DeathExplosion), 15)
	..()

/mob/living/simple_animal/hostile/ordeal/crimson_clown/proc/TeleportAway()
	var/list/potential_computers = list()
	for(var/obj/machinery/computer/abnormality/CA in GLOB.abnormality_consoles)
		if(!CanTeleportTo(CA))
			continue
		potential_computers += CA
	if(LAZYLEN(potential_computers))
		var/obj/machinery/computer/abnormality/teleport_computer = pick(potential_computers)
		var/turf/T = get_step(get_turf(teleport_computer), SOUTH)
		var/matrix/init_transform = transform
		animate(src, transform = transform*0.01, time = 5, easing = BACK_EASING)
		SLEEP_CHECK_DEATH(5)
		console_attack_counter = 0
		forceMove(T)
		target = teleport_computer
		animate(src, transform = init_transform, time = 5, easing = BACK_EASING)

/mob/living/simple_animal/hostile/ordeal/crimson_clown/proc/CanTeleportTo(obj/machinery/computer/abnormality/CA)
	if(CA.meltdown || !CA.datum_reference || !CA.datum_reference.current || !CA.datum_reference.qliphoth_meter)
		return FALSE
	if(type in view(5, get_turf(CA))) // There's already a similar clown nearby
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/ordeal/crimson_clown/proc/DeathExplosion()
	if(QDELETED(src))
		return
	visible_message("<span class='danger'>[src] suddenly explodes!</span>")
	for(var/mob/living/L in view(5, src))
		if(!faction_check_mob(L))
			L.apply_damage(15, RED_DAMAGE, null, L.run_armor_check(null, RED_DAMAGE))
	gib()
