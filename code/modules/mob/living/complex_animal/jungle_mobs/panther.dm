/mob/living/complex_animal/panther
	name="Panther"
	desc="That's a big kitty!"
	icon_state="panther"
	icon_living = "panther"
	icon_dead = "panther_dead"
	size=SIZE_BIG
	health=40
	maxHealth=40
	armor=list(melee=15,bullet=10,laser=0,energy=0,bomb=0,bio=0,rad=0)
	max_food=100
	food_flags = ANIMAL_CARNIVORE
	base_damage = 30
	damage_variance = 8
	behavior_flags = ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_TERRITORIAL | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_AVOID_CAPTURE
	movespeed=2


/mob/living/complex_animal/panther/get_idle_sounds()
	if(prob(20))
		var/i=rand(1,3)
		switch(i)
			if(1)
				emote("me", MESSAGE_HEAR, "meows")
			if(2)
				emote("me", MESSAGE_HEAR, "purrs")
			if(3)
				emote("me", MESSAGE_HEAR, "hisses")

/mob/living/complex_animal/panther/get_attack_msg(var/individual)
	var/i=rand(1,3)
	switch(i)
		if(1)
			emote("me", MESSAGE_SEE, "bites \the [individual].")
		if(2)
			emote("me", MESSAGE_SEE, "swipes at \the [individual].")
		if(3)
			emote("me", MESSAGE_SEE, "claws \the [individual].")

/mob/living/complex_animal/panther/is_kin(var/mob/target)
	if(istype(target,/mob/living/simple_animal/cat) && !istype(target,/mob/living/simple_animal/cat/snek))
		return TRUE
	return ..()
