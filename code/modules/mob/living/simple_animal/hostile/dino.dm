/mob/living/simple_animal/hostile/dinosaur
	name="Dinosaur"
	desc="boom boom acka lacka boom boom"
	icon_gib=null
	icon_living="dino"
	icon_dead="dino_dead"
	icon_state="dino"
	var/walking=FALSE

/mob/living/simple_animal/hostile/dinosaur/Life()
	walking=FALSE
	var/wc=0
	var/wt=0
	var/list/l=view(vision_range, src)
	for( var/mob/living/carbon/human/h in l)
		if (h.resting) //get on the floor
			wc++
		wt++
	if(wc && wc==wt)
		walking=TRUE
	..()
	if(walking) //more active, since mob ticks are 2 seconds.
		openthedoor()
		spawn(5) openthedoor()
		spawn(10) openthedoor()
		spawn(15) openthedoor()
	
	



/mob/living/simple_animal/hostile/dinosaur/ListTargets()
	if(walking)
		return list()
	else
		..()

/mob/living/simple_animal/hostile/dinosaur/proc/openthedoor()
	if(!walking)
		return
		
	var/list/l=view(vision_range, src)

	var/dn=floor((world.time / 5)%4)
	switch(dn)
		if(0)
			dir=NORTH
		if(1)
			dir=EAST
		if(2)
			dir=SOUTH
		if(3)
			dir=WEST
	if(prob(10))
		var/nloc=get_step_rand(src.loc)
		if(nloc)
			Move(nloc)
	for( var/mob/living/carbon/human/h in l)
		h.dir=pick(list(NORTH,SOUTH,EAST,WEST))