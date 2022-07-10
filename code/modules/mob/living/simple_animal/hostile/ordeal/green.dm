// Green dawn
/mob/living/simple_animal/hostile/ordeal/green_bot
	name = "doubt"
	desc = "A slim robot with a spear in place of its hand."
	icon = 'ModularTegustation/Teguicons/32x48.dmi'
	icon_state = "green_bot"
	icon_living = "green_bot"
	icon_dead = "green_bot_dead"
	faction = list("green_ordeal")
	maxHealth = 500
	health = 500
	speed = 2
	move_to_delay = 4
	robust_searching = TRUE
	stat_attack = HARD_CRIT
	melee_damage_lower = 22
	melee_damage_upper = 26
	attack_verb_continuous = "stabs"
	attack_verb_simple = "stab"
	attack_sound = 'sound/effects/ordeals/green/stab.ogg'
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0.8, WHITE_DAMAGE = 1.3, BLACK_DAMAGE = 2, PALE_DAMAGE = 1)

	/// Can't move/attack when it's TRUE
	var/finishing = FALSE

/mob/living/simple_animal/hostile/ordeal/green_bot/CanAttack(atom/the_target)
	if(finishing)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/ordeal/green_bot/Move()
	if(finishing)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/ordeal/green_bot/AttackingTarget()
	. = ..()
	if(.)
		if(!istype(target, /mob/living/carbon/human))
			return
		var/mob/living/carbon/human/TH = target
		if(TH.health < 0)
			finishing = TRUE
			TH.Stun(4 SECONDS)
			forceMove(get_turf(TH))
			for(var/i = 1 to 7)
				if(!targets_from.Adjacent(TH) || QDELETED(TH)) // They can still be saved if you move them away
					finishing = FALSE
					return
				TH.attack_animal(src)
				for(var/mob/living/carbon/human/H in view(7, get_turf(src)))
					H.apply_damage(3, WHITE_DAMAGE, null, H.run_armor_check(null, WHITE_DAMAGE), spread_damage = TRUE, forced = TRUE)
				SLEEP_CHECK_DEATH(2)
			if(!targets_from.Adjacent(TH) || QDELETED(TH))
				finishing = FALSE
				return
			playsound(get_turf(src), 'sound/effects/ordeals/green/final_stab.ogg', 50, 1)
			TH.gib()
			for(var/mob/living/carbon/human/H in view(7, get_turf(src)))
				H.apply_damage(20, WHITE_DAMAGE, null, H.run_armor_check(null, WHITE_DAMAGE), spread_damage = TRUE, forced = TRUE)
			finishing = FALSE

// Green dawn
/mob/living/simple_animal/hostile/ordeal/green_bot_big
	name = "process of understanding"
	desc = "A big robot with a saw and a machinegun in place of its hands."
	icon = 'ModularTegustation/Teguicons/48x48.dmi'
	icon_state = "green_bot"
	icon_living = "green_bot"
	icon_dead = "green_bot_dead"
	faction = list("green_ordeal")
	pixel_x = -8
	base_pixel_x = -8
	maxHealth = 1000
	health = 1000
	speed = 3
	move_to_delay = 5
	robust_searching = TRUE
	stat_attack = HARD_CRIT
	melee_damage_lower = 26 // Full damage is done on the entire turf of target
	melee_damage_upper = 30
	attack_verb_continuous = "slices"
	attack_verb_simple = "slice"
	attack_sound = 'sound/effects/ordeals/green/saw.ogg'
	ranged = 1
	rapid = 6
	rapid_fire_delay = 3
	projectiletype = /obj/projectile/bullet/c9x19mm
	projectilesound = 'sound/effects/ordeals/green/fire.ogg'
	deathsound = 'sound/effects/ordeals/green/noon_dead.ogg'
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0.8, WHITE_DAMAGE = 1.3, BLACK_DAMAGE = 2, PALE_DAMAGE = 0.8)

	/// Can't move/attack when it's TRUE
	var/reloading = FALSE
	/// When at 10 - it will start "reloading"
	var/fire_count = 0

/mob/living/simple_animal/hostile/ordeal/green_bot_big/CanAttack(atom/the_target)
	if(reloading)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/ordeal/green_bot_big/Move()
	if(reloading)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/ordeal/green_bot_big/OpenFire(atom/A)
	if(reloading)
		return FALSE
	..()
	fire_count += 1
	if(fire_count >= 10)
		StartReloading()

/mob/living/simple_animal/hostile/ordeal/green_bot_big/AttackingTarget()
	. = ..()
	if(.)
		if(!istype(target, /mob/living))
			return
		var/turf/T = get_turf(target)
		for(var/i = 1 to 4)
			new /obj/effect/temp_visual/saw_effect(T)
			for(var/mob/living/L in T.contents)
				if(faction_check_mob(L))
					continue
				L.apply_damage(8, RED_DAMAGE, null, L.run_armor_check(null, RED_DAMAGE), spread_damage = TRUE)
			SLEEP_CHECK_DEATH(1)

/mob/living/simple_animal/hostile/ordeal/green_bot_big/proc/StartReloading()
	reloading = TRUE
	icon_state = "green_bot_reload"
	playsound(get_turf(src), 'sound/effects/ordeals/green/cooldown.ogg', 50, FALSE)
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0.4, WHITE_DAMAGE = 0.65, BLACK_DAMAGE = 1, PALE_DAMAGE = 0.4)
	for(var/i = 1 to 5)
		new /obj/effect/temp_visual/green_noon_reload(get_turf(src))
		SLEEP_CHECK_DEATH(8)
	fire_count = 0
	reloading = FALSE
	icon_state = icon_living
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0.8, WHITE_DAMAGE = 1.3, BLACK_DAMAGE = 2, PALE_DAMAGE = 0.8)
