/mob/living/complex_animal/bear
	name="Bear"
	desc="Does it shit in the woods?"
	icon_state="brownbear"
	icon_living = "brownbear"
	icon_dead = "brownbear_dead"
	size=SIZE_BIG
	health=60
	maxHealth=60
	armor=list(melee=20,bullet=20,laser=20,energy=0,bomb=0,bio=0,rad=0)
	max_food=100
	food_flags = ANIMAL_CARNIVORE | ANIMAL_HERBIVORE
	base_damage = 25
	damage_variance = 5
	behavior_flags = ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_PACK_DYNAMICS
	movespeed=5
	kin_check_type_path=/mob/living/complex_animal/bear

/mob/living/complex_animal/bear/get_idle_sounds()
	if(prob(20))
		var/i=rand(1,2)
		switch(i)
			if(1)
				emote("me", MESSAGE_HEAR, "growls")
			if(2)
				emote("me", MESSAGE_HEAR, "roars")

/mob/living/complex_animal/bear/get_attack_msg(var/individual)
	var/i=rand(1,3)
	switch(i)
		if(1)
			emote("me", MESSAGE_SEE, "bites \the [individual].")
		if(2)
			emote("me", MESSAGE_SEE, "swings at \the [individual].")
		if(3)
			emote("me", MESSAGE_SEE, "claws \the [individual].")

/mob/living/complex_animal/bear/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/brownbear, /datum/butchering_product/teeth/lots)


/mob/living/complex_animal/bear/spare
	name="Spare Bear"
	desc="This bear has adapted a form of camouflage from generations of natural selection in which the omnivores scavenge from space stations and their dumpsters. Its golden skin fools card scanners into opening the door."
	icon_state="sparebear"
	icon_living = "sparebear"
	icon_dead = "sparebear_dead"
	health=250
	maxHealth=250
	armor=list(melee=10,bullet=30,laser=40,energy=0,bomb=0,bio=0,rad=0)
	max_food=200
	food_per_tick = 0.00333333
	base_damage = 35
	damage_variance = 5
	behavior_flags = ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_TERRITORIAL | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_PACK_DYNAMICS
	movespeed=4

/mob/living/complex_animal/bear/spare/can_offspring(var/mob/living/complex_animal/mate)
	return FALSE

/mob/living/complex_animal/bear/spare/GetAccess()
	return get_all_accesses()

/mob/living/complex_animal/bear/spare/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/spare, /datum/butchering_product/teeth/lots)



/mob/living/complex_animal/bear/panda
	name="Panda Bear"
	desc="Endangered even in space."
	icon_state="panda"
	icon_living = "panda"
	icon_dead = "panda_dead"
	behavior_flags = ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_PACK_DYNAMICS
	movespeed=6
	food_per_tick=0.0075
	

/mob/living/complex_animal/bear/panda/can_offspring(var/mob/living/complex_animal/mate)
	.=..()
	if(prob(75))
		return FALSE

/mob/living/complex_animal/bear/panda/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/panda, /datum/butchering_product/teeth/lots)
	
/mob/living/complex_animal/bear/polar
	name="Polar Bear"
	desc="Its eyes are souless and cold."
	icon_state="polarbear"
	icon_living = "polarbear"
	icon_dead = "polarbear_dead"
	behavior_flags = ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_TERRITORIAL | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_PACK_DYNAMICS
	base_damage=35
	damage_variance=10
	food_per_tick=0.0075
	health=70
	maxHealth=70
	

/mob/living/complex_animal/bear/polar/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/polarbear, /datum/butchering_product/teeth/lots)


/mob/living/complex_animal/bear/polar/chef
	name="Chef Bear"
	desc="Not to be confused with Chief Bear, the leader of bear tribe. This one just likes to cook."
	behavior_flags = ANIMAL_BEHAVIOR_TERRITORIAL | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_PACK_DYNAMICS | ANIMAL_BEHAVIOR_DESTRUCTIVE | ANIMAL_BEHAVIOR_AVOID_CAPTURE
	movespeed=4
	health=100
	base_damage=35
	damage_variance=15
	maxHealth=100
	