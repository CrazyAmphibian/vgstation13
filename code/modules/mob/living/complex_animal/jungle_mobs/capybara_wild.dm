/mob/living/complex_animal/capybara_wild
	name="Wild Capybara"
	desc="The capybara is the largest of the rodents. This one is unaccustomed to human contact."
	icon_state="capybara"
	icon_living = "capybara"
	icon_dead = "capybara-dead"
	size=SIZE_SMALL
	health=25
	maxHealth=25
	max_food=30
	food_flags = ANIMAL_HERBIVORE
	behavior_flags = ANIMAL_BEHAVIOR_PACK_DYNAMICS | ANIMAL_BEHAVIOR_AVOID_CAPTURE
	movespeed=1
	pacify_aura = TRUE
	base_damage=5
	damage_variance=2


/mob/living/complex_animal/capybara_wild/Life()
	if(!..())
		return 0
		
	if(behavior_state==ANIMAL_STATE_IDLE && prob(33))
		visible_message("\the [src] starts resting")
		behavior_state=ANIMAL_STATE_SPECIAL
		icon_state="capybara-rest"
		walk(src,0)
	else if(behavior_state==ANIMAL_STATE_SPECIAL)
		icon_state="capybara-rest"
		if(prob(20))
			behavior_state=ANIMAL_STATE_IDLE
			icon_state="capybara"
			visible_message("\the [src] gets back up")
		
	return 1

/mob/living/complex_animal/capybara_wild/determine_isthreat(var/mob/individual)
	return FALSE

/mob/living/complex_animal/capybara_wild/get_flee_msg(var/individual)
	..()
	icon_state="capybara"


/mob/living/complex_animal/capybara_wild/get_idle_sounds()
	return

/mob/living/complex_animal/capybara_wild/get_attack_msg(var/individual)
	var/i=rand(1,2)
	switch(i)
		if(1)
			emote("me", MESSAGE_SEE, "nibbles \the [individual].")
		if(2)
			emote("me", MESSAGE_SEE, "scratches \the [individual].")
