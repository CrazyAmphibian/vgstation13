#define ANIMAL_BEHAVIOR_PREDATORY	(1<<0)	//if we will attack other mobs
#define ANIMAL_BEHAVIOR_TERRITORIAL	(1<<1)	//if we attack when approached
#define ANIMAL_BEHAVIOR_PACK_DYNAMICS	(1<<2)	//if we stay by others of our kind
#define ANIMAL_BEHAVIOR_AVOID_PRED	(1<<3)	//avoid predatory animals, not counting our own kind, of course.
#define ANIMAL_BEHAVIOR_RETALIATE	(1<<4)	//if we are attacked, we fight back.
#define ANIMAL_BEHAVIOR_DESTRUCTIVE	(1<<5)	//destroy objects in the environment. you'll probably want big bad animals to have this flag (eg, bears)
#define ANIMAL_BEHAVIOR_AVOID_CAPTURE	(1<<6) //try to escape containment (lockers, chairs). also see above.
#define ANIMAL_BEHAVIOR_UNDESIRABLE	(1<<7) //if predators should avoid us for whatever reason. not a hard stance, but it'll tilt the scale. eg, a creature which is poisonous.

#define ANIMAL_HERBIVORE	(1<<0)	//we can eat plants
#define ANIMAL_CARNIVORE	(1<<1)	//we can eat meat. combine with ANIMAL_HERBIVORE for an omnivore. you also need ANIMAL_BEHAVIOR_PREDATORY if you want it to hunt, otherwise it's just an opportunistic carnivore.

#define ANIMAL_FOODPRIORITY_CANNIBAL -5	//she rips out my bones just like i'm an animal
#define ANIMAL_FOODPRIORITY_PRECOOKED 5	//why would you eat a plant when you could eat a tasty donut or burger?
#define ANIMAL_FOODPRIORITY_PLANTS 2	//omnivores prefer not picking a fight. mildly, because we still want some action
#define ANIMAL_FOODPRIORITY_CORPSES 3	//no need to beat a dead horse. we should be eating it instead.
#define ANIMAL_FOODPRIORITY_SIZEDIFF_LARGER -5	//bigger=more dangerous, right?
#define ANIMAL_FOODPRIORITY_SIZEDIFF_SMALLER -2	//prefer bigger meals
#define ANIMAL_FOODPRIORITY_FAMILY -5	//hi ma :)
#define ANIMAL_FOODPRIORITY_UNDESIRABLE -5	//poison... poison... tasty fish!

#define ANIMAL_STATE_IDLE 0	//hanging around.
#define ANIMAL_STATE_HUNTING 1	//when we hongry
#define ANIMAL_STATE_DEFENDING 2	//from territorial
#define ANIMAL_STATE_ATTACKING 3	//from retaliation
#define ANIMAL_STATE_FLEEING 4	//oh SHIT
#define ANIMAL_STATE_MATING 5	//the birds and the birds. why would they try it with a bee? you sicken me.
#define ANIMAL_STATE_SPECIAL 6 //for special behaviors for the mob to do

/mob/living/complex_animal
	size=0
	icon='icons/mob/animal.dmi'
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	var/armor=list(melee=0,bullet=0,laser=0,energy=0,bomb=0,bio=0,rad=0)
	var/behavior_flags=0
	nutrition = 50
	var/max_food = 50
	var/food_per_tick = 0.00666666 //how much of max_food should be deducted from food per tick. This number gives us about 300 seconds until hungry
	var/food_flags = 0
	var/behavior_state = ANIMAL_STATE_IDLE
	var/mob_age = 0
	var/mob_max_age = 300 //10 minutes. above this, the mob will start rolling to die of old age.
	var/atom/target = null
	var/turf/territory=null //turf location
	var/list/family = list() //list of mobs. avoid attacking them and whatnot. also can be used for taming.
	var/base_damage=0
	var/damage_variance=0
	var/movespeed=5 //lower=faster.
	var/pacify_aura=FALSE
	var/kin_check_type_path=null //for mobs with many subtypes. set to the parent mob type. leave null if not needed
	var/petable=FALSE
	
	var/icon_living = ""
	var/icon_dead = ""
	
	var/healthregen=0.01
	var/lasthealth=0.0
	

/mob/living/complex_animal/New(var/loc)
	..()
	nutrition = rand(ceil(max_food/2),max_food)
	gender="female"
	if(prob(50))
		gender="male"
	territory=locate(x,y,z) //store turf where we were born/created
	

/mob/living/complex_animal/Life()
	if(!..())
		return 0
	if(stat == DEAD)
		return 0
	icon_state=icon_living
	nutrition-=max_food*food_per_tick
	
	if(lasthealth<=health && health<maxHealth)
		health=min(maxHealth,health+maxHealth*healthregen)
		nutrition-=max_food*food_per_tick*0.25 //use extra food when regaining health
	lasthealth=health
	
	if(nutrition<0 && prob(20))
		emote("deathgasp")
		health=0
		stat=DEAD
		return 0
	if(mob_max_age && mob_age > mob_max_age)
		var/chancetokeelover = (mob_age-mob_max_age)/mob_max_age
		chancetokeelover = 1-(1/(chancetokeelover+1))
		// math formula: 1-\frac{1}{\frac{\left(x-m\right)}{m}+1}
		//basically, the older you are, the more likley you are to die.
		//if you are twice as old as the max age, you have a 50% chance to die.
		//this is ran every tick, by the way, so the probabilities add up.
		if(rand() < chancetokeelover)
			emote("deathgasp")
			health=0
			stat=DEAD
			return 0
	mob_age++
	
	escape()
	
	switch(behavior_state)
		if(ANIMAL_STATE_IDLE)
			target=null
			if(nutrition<max_food*0.5)
				emote("me",MESSAGE_SEE,"looks hungry")
				behavior_state=ANIMAL_STATE_HUNTING
			//attempt reproduction only while full
			if(nutrition >= (max_food- get_offspring_cost()*2) && get_offspring_cost() && prob(20))
				behavior_state=ANIMAL_STATE_MATING
			var/distraction=FALSE
			var/list/nearby_objects=view(7,src)
			for(var/mob/living/M in nearby_objects) //check for danger and flee
				if(determine_isthreat(M))
					get_flee_msg(M)
					behavior_state = ANIMAL_STATE_FLEEING
					target=M
					distraction=TRUE
					break
			if(!distraction)
				for(var/mob/living/M in nearby_objects) //if not, check for trespassers
					if(behavior_flags & ANIMAL_BEHAVIOR_TERRITORIAL && get_dist(M,territory)<10 && determine_tresspass(M) )
						get_tesspass_msg(M)
						behavior_state = ANIMAL_STATE_DEFENDING
						target=M
						distraction=TRUE
						break
			if(!distraction)
				get_idle_sounds()
			if(!distraction) //if none, randomly move the territory
				if(territory && prob(50))
					walk_to(src,locate(territory.x+rand(-2,2),territory.y+rand(-2,2),territory.z),0,movespeed)
					if(prob(33)) //sometimes, randomly mess with the territory to shift where we are
						territory = locate(territory.x+rand(-5,5),territory.y+rand(-5,5),territory.z)
					if(behavior_flags & ANIMAL_BEHAVIOR_PACK_DYNAMICS) //if we are running as a pack, shift our territory towards another kin's
						for(var/mob/living/complex_animal/M in nearby_objects)
							if(is_kin(M) && prob(20))
								var/traversedir = get_dir(territory,M.territory)
								for(var/i=0,i<3,i++)
									var/turf/T=get_step(M.territory,traversedir)
									if(T)
										territory =T
								break
				else
					walk_to(src,locate(x+rand(-2,2),y+rand(-2,2),z),0,movespeed)
					territory=get_turf(src)
				
		if(ANIMAL_STATE_HUNTING)
			fuckshitup()
			if(!target || target.z!=z || get_dist(src,target)>20)
				target=null
				var/list/possible=rank_foodsources(get_food())
				var/list/pickfrom=list()
				var/highestprio=-9999999999999999999999999999
				for(var/atom/A in possible) //get the highest ranked objects
					var/rank=possible[A]
					if(rank>highestprio)
						pickfrom=list(A)
						highestprio=rank
					else if(rank==highestprio)
						pickfrom+=A
				if(pickfrom.len)
					target=pick(pickfrom)
				if(highestprio<0 && nutrition>max_food*0.2) //avoid disliked targets, unless we are really desperate for food.
					target=null
				if(highestprio<-4 && nutrition>max_food*0.05) //I NEEEEEEEED IIIIIIIIT
					target=null
				if(!target) //if we can't find a suitable target, move around randomly
					walk_to(src,locate(x+rand(-15,15),y+rand(-15,15),z),0,movespeed)
				else
					get_hunting_msg(target)
					aggro_drawn(target,ANIMAL_STATE_HUNTING)
			else
				if(get_dist(src,target)>1)
					walk_to(src,target,0,movespeed)
				else //attack em!
					tryeat(target)
			if(nutrition>max_food*0.75)
				behavior_state=ANIMAL_STATE_IDLE
		if(ANIMAL_STATE_DEFENDING)
			if(!target || target.z!=src.z)
				target=null
				behavior_state=ANIMAL_STATE_IDLE
			else
				if(get_dist(territory,target)>10)
					target=null
					behavior_state=ANIMAL_STATE_IDLE
					walk_to(src,territory,0,movespeed)
				else if(get_dist(src,target)>1)
					walk_to(src,target,0,movespeed)
				else //attack em!
					attack(target)
				if(istype(target,/mob/living/))
					var/mob/living/L=target
					if(L.stat==DEAD)
						target=null
						behavior_state=ANIMAL_STATE_IDLE
						walk_to(src,territory,0,movespeed)
		if(ANIMAL_STATE_ATTACKING)
			fuckshitup()
			if(!target || target.z!=src.z || get_dist(src,target)>15)
				target=null
				behavior_state=ANIMAL_STATE_IDLE
			else
				if(get_dist(src,target)>1)
					walk_to(src,target,0,movespeed)
				else //attack em!
					attack(target)
				aggro_drawn(target,ANIMAL_STATE_ATTACKING)
				if(istype(target,/mob/living/))
					var/mob/living/L=target
					if(L.stat==DEAD)
						target=null
						behavior_state=ANIMAL_STATE_IDLE
		if(ANIMAL_STATE_FLEEING)
			fuckshitup()
			if(!target || target.z!=src.z)
				target=null
				behavior_state=ANIMAL_STATE_IDLE
				walk(src,0)
			else
				if(get_dist(src,target)<10)
					walk_away(src,target,10,movespeed)
				else
					walk(src,0)
					target=null
					behavior_state=ANIMAL_STATE_IDLE
				if(istype(target,/mob/living))
					var/mob/living/L=target
					if(L.stat==DEAD)
						walk(src,0)
						target=null
						behavior_state=ANIMAL_STATE_IDLE
		if(ANIMAL_STATE_MATING)
			if(!target)
				var/list/nearby_objects=view(7,src)
				for(var/atom/A in nearby_objects)
					if(istype(A,/mob/living/complex_animal))
						var/mob/living/complex_animal/CA=A
						if(can_offspring(CA) && CA.can_offspring(src) && CA.behavior_state==ANIMAL_STATE_MATING && !CA.target) //you better believe we're going to enforce the communicative property.
							emote("me",MESSAGE_SEE,"looks lovingly at \the [CA]")
							target=CA
							CA.emote("me",MESSAGE_SEE,"looks lovingly at \the [src]")
							CA.target=src
			else
				if(istype(target,/mob/living/complex_animal))
					var/mob/living/complex_animal/M=target
					if(!M || M.stat==DEAD) //my wife is dead
						target=null
						behavior_state=ANIMAL_STATE_IDLE
					else
						if(get_dist(src,M)>1)
							walk_to(src,M,0,movespeed)
						else
							if(gender=="female")
								if(generate_offspring(M))
									M.nutrition-=M.get_offspring_cost()
									M.behavior_state=ANIMAL_STATE_IDLE
									M.target=null
								
									nutrition-=get_offspring_cost()
									behavior_state=ANIMAL_STATE_IDLE
									target=null
				else
					target=null
	return 1



/mob/living/complex_animal/proc/is_kin(var/mob/target)
	if(!istype(target,/mob))
		return FALSE
	if(target in family)
		return TRUE
	if(target.faction == src.faction && src.faction!="neutral")
		return TRUE
	if(kin_check_type_path)
		if(istype(target,kin_check_type_path))
			return TRUE
	else
		if(istype(target,src.type) || istype(src,target.type))
			return TRUE
	return FALSE

//return a list of valid salad
/mob/living/complex_animal/proc/get_food()
	var/list/foodsources=list()
	var/list/nearby_objects=view(7,src)
	for(var/atom/A in nearby_objects)
		if(food_flags & ANIMAL_HERBIVORE)
			if(istype(A,/obj/structure/flora) && !istype(A,/obj/structure/flora/tree) && !istype(A,/obj/structure/flora/rock))
				foodsources+=A
				continue
			if(istype(A,/turf/unsimulated/floor/jungle/grass))
				foodsources+=A
				continue
		if(food_flags & ANIMAL_CARNIVORE)
			if(istype(A,/mob/living/carbon) || istype(A,/mob/living/simple_animal))
				var/mob/living/M=A
				if(M.stat!=DEAD)
					if(!is_pacified() && behavior_flags & ANIMAL_BEHAVIOR_PREDATORY)
						foodsources+=M
						continue
				else
					if(M.nutrition>-50)
						foodsources+=M
						continue
		//no easy way to check if it's meat. oh well.
		if(istype(A,/obj/item/weapon/reagent_containers/food/snacks))
			foodsources+=A
			continue
	return foodsources

//take the list from get_food, and create an associated list ranking our affinity for them
/mob/living/complex_animal/proc/rank_foodsources(var/list/sources)
	var/list/out=list() //associate list time!!!!!!!!!! I LOVE BYOND!!!!111!
	for(var/atom/A in sources)
		var/p=rand(-2,2) // randomize it for a bit of spice
		if(istype(A,/mob/living))
			var/mob/M=A
			if(M.stat==DEAD)
				p+=ANIMAL_FOODPRIORITY_CORPSES
			if(is_kin(M))
				p+=ANIMAL_FOODPRIORITY_CANNIBAL
			if(M.size > src.size) //we avoid attacking things bigger than us
				p+=ANIMAL_FOODPRIORITY_SIZEDIFF_LARGER
			if(M.size < src.size-2) //smaller things ain't worth our time
				p+=ANIMAL_FOODPRIORITY_SIZEDIFF_SMALLER
			if(M in family)
				p+=ANIMAL_FOODPRIORITY_FAMILY
			if(istype(A,/mob/living/simple_animal))
				var/mob/living/simple_animal/SA=A
				if(SA.is_poisonous)
					p+=ANIMAL_FOODPRIORITY_UNDESIRABLE
			if(istype(A,/mob/living/complex_animal))
				var/mob/living/complex_animal/CA=A
				if(CA.behavior_flags & ANIMAL_BEHAVIOR_UNDESIRABLE)
					p+=ANIMAL_FOODPRIORITY_UNDESIRABLE
		if(istype(A,/obj/item/weapon/reagent_containers/food/snacks))
			p+=ANIMAL_FOODPRIORITY_PRECOOKED
		if(istype(A,/obj/structure/flora))
			p+=ANIMAL_FOODPRIORITY_PLANTS
		out[A]=p
	return out


/mob/living/complex_animal/proc/aggro_drawn(var/victim,var/state=ANIMAL_STATE_ATTACKING)
	if(!victim)
		return
	target=victim
	behavior_state=state
	get_aggro_msg(victim)
	if( !(behavior_flags & ANIMAL_BEHAVIOR_PACK_DYNAMICS) && !family.len)
		return
	if(istype(target,/mob/living))
		var/mob/living/T=target
		if(T.stat!=DEAD)
			var/list/nearby_objects=view(7,src)
			for(var/mob/living/complex_animal/M in nearby_objects)
				if( (behavior_flags & ANIMAL_BEHAVIOR_PACK_DYNAMICS) || (M in family))
					if(is_kin(M) && !M.is_kin(target)) //rally the pack to us, if the target is not kin
						if(M.behavior_state!=state) //if the pack member is not engaged in similar activity
							M.aggro_drawn(victim,state) //do this recursively for each. don't kick the bee hive.
	

/mob/living/complex_animal/proc/attack(var/victim)
	if(is_pacified())
		return FALSE
	if(!victim)
		return FALSE
	return UnarmedAttack(victim,Adjacent(victim))

/mob/living/complex_animal/proc/tryeat(var/victim)
	if(!victim)
		return FALSE
	if(istype(target,/mob/living))
		var/mob/living/M=target
		if(M.stat!=DEAD)
			return attack(victim)
		else
			if(UnarmedAttack(victim,Adjacent(victim)))
				M.nutrition-=5
				nutrition+=5
				emote("me",MESSAGE_SEE,"chomps on \the [target]")
				return TRUE
	else if(istype(target,/obj/structure/flora))
		if(prob(20))
			qdel(target)
		nutrition+=5
		emote("me",MESSAGE_SEE,"nibbles at \the [target]")
	else if (istype(target,/turf))
		nutrition+=1
		emote("me",MESSAGE_SEE,"nibbles at \the [target]")
	else if(istype(target,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/F=target
		emote("me",MESSAGE_SEE,"take a bite out of \the [F]")
		F.consume(src)
	return TRUE

//stolen from simple_animal/hostile
/mob/living/complex_animal/proc/escape()
	if(!(behavior_flags & ANIMAL_BEHAVIOR_AVOID_CAPTURE))
		return
	if(locked_to)
		UnarmedAttack(locked_to, Adjacent(locked_to))
	if(!isturf(src.loc) && src.loc != null)
		var/atom/A = src.loc
		UnarmedAttack(A, Adjacent(A))

//stolen from simple_animal/hostile
/mob/living/complex_animal/proc/fuckshitup()
	if(!target)
		return
	if(!(behavior_flags & ANIMAL_BEHAVIOR_DESTRUCTIVE))
		return
	var/list/smash_dirs = list(0)
	var/targdir = get_dir(src, target)
	smash_dirs |= widen_dir(targdir) //otherwise smash towards the target
	for(var/dir in smash_dirs)
		var/turf/T = get_step(src, dir)
		for(var/atom/A in T)
			var/static/list/destructible_objects = list(/obj/structure/window,
				 /obj/structure/closet,
				 /obj/structure/table,
				 /obj/structure/grille,
				 /obj/structure/girder,
				 /obj/structure/rack,
				 /obj/structure/railing,
				 /obj/machinery/door/window,
				 /obj/item/tape,
				 /obj/item/toy/balloon/inflated/decoy,
				 /obj/machinery/door/airlock,
				 /obj/machinery/door/firedoor)
			if(is_type_in_list(A, destructible_objects) && Adjacent(A))
				if(istype(A, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/AIR = A
					if(!AIR.density || AIR.locked || AIR.welded || AIR.operating)
						continue
				if(istype(A, /obj/machinery/door/firedoor))
					var/obj/machinery/door/firedoor/FIR = A
					if(!FIR.density || FIR.blocked || FIR.operating)
						continue
				UnarmedAttack(A, Adjacent(A))


//only fired when the mob is within our territory, and we have the TERRITORIAL flag
/mob/living/complex_animal/proc/determine_tresspass(var/mob/trespasser)
	if(trespasser.stat==DEAD)
		return FALSE
	if(is_pacified())
		return FALSE
	if(istype(trespasser,/mob/living/simple_animal))
		var/mob/living/simple_animal/A=trespasser
		if(A.pacify_aura)
			return FALSE
	if(istype(trespasser,/mob/living/complex_animal))
		var/mob/living/complex_animal/A=trespasser
		if(A.pacify_aura || (A.behavior_flags & ANIMAL_BEHAVIOR_UNDESIRABLE) )
			return FALSE
	return !is_kin(trespasser)

//only fired when the mob is seen by us, and we have the AVOID_PRED flag
/mob/living/complex_animal/proc/determine_isthreat(var/mob/individual)
	if(is_kin(individual))
		return FALSE
	if(istype(individual,/mob/living/carbon))
		return !(behavior_flags & ANIMAL_BEHAVIOR_TERRITORIAL)
	if(istype(individual,/mob/living/silicon))
		return !(behavior_flags & ANIMAL_BEHAVIOR_TERRITORIAL)
	if(istype(individual,/mob/living/simple_animal))
		return istype(individual,/mob/living/simple_animal/hostile)
	if(istype(individual,/mob/living/complex_animal))
		var/mob/living/complex_animal/A = individual
		return A.behavior_flags & (ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_TERRITORIAL)
	return FALSE


/mob/living/complex_animal/proc/get_aggro_msg(var/individual)
	emote("me",MESSAGE_SEE,"stares alertly at \the [individual].")

/mob/living/complex_animal/proc/get_flee_msg(var/individual)
	emote("me",MESSAGE_SEE,"stares at \the [individual] and runs away.")

/mob/living/complex_animal/proc/get_tesspass_msg(var/individual)
	emote("me",MESSAGE_SEE,"stares alertly at \the [individual].")

/mob/living/complex_animal/proc/get_hunting_msg(var/individual)
	
	emote("me",MESSAGE_SEE,"stares hungrily at \the [individual].")

/mob/living/complex_animal/proc/get_attack_msg(var/individual)
	emote("me",MESSAGE_SEE,"attacks \the [individual].")

/mob/living/complex_animal/proc/get_idle_sounds()
	if(prob(20))
		emote("me",MESSAGE_HEAR, "vocalizes.")


/mob/living/complex_animal/proc/get_offspring_cost()
	return size*5

// if you don't want offspring, then return FALSE here.
/mob/living/complex_animal/proc/can_offspring(var/mob/living/complex_animal/mate)
	if(!mate)
		return FALSE
	if(mate.type!=src.type)
		return FALSE
	if((src.gender=="male" && mate.gender=="female") || (mate.gender=="male" && src.gender=="female"))
		return TRUE
	return FALSE

//this proc is ran on the mother only.
/mob/living/complex_animal/proc/generate_offspring(var/mob/living/complex_animal/father)
	var/mob/living/complex_animal/child=new src.type(loc)
	child.faction=faction
	child.nutrition=child.max_food*0.5
	family+=child
	father.family+=child
	child.family+=src
	child.family+=father
	if(!child)
		return FALSE
	return child
	
	
	
/mob/living/complex_animal/get_unarmed_damage(var/atom/victim)
	return base_damage+ (damage_variance ? rand(-damage_variance,damage_variance) : 0)

/mob/living/complex_animal/death(gibbed) //stolen from simple_animal
	if((status_flags & BUDDHAMODE) || stat == DEAD)
		return

	if(!gibbed)
		emote("deathgasp", message = TRUE)
	health = 0 
	stat = DEAD
	icon_state = icon_dead
	setDensity(FALSE)

/mob/living/complex_animal/attack_hand(var/mob/living/carbon/human/H)
	. = ..()
	H.delayNextAttack(2 SECONDS)
	if(H.a_intent==I_HURT)
		if(behavior_flags & ANIMAL_BEHAVIOR_RETALIATE)
			behavior_state=behavior_state=ANIMAL_STATE_ATTACKING
			aggro_drawn(H,ANIMAL_STATE_ATTACKING)
			H.UnarmedAttack(src,H.Adjacent(src))
			if(health<=0)
				death()
		else
			get_flee_msg(H)
			behavior_state = ANIMAL_STATE_FLEEING
			target=H
	else if(H.a_intent==I_HELP)
		trypet(H)

/mob/living/complex_animal/proc/trypet(var/mob/living/carbon/human/H)
	if(petable)
		H.emote("me",MESSAGE_SEE,"pets \the [src]")
		var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
		heart.plane = ABOVE_HUMAN_PLANE
		flick_overlay(heart, list(H.client), 20)
		
/mob/living/complex_animal/attackby(var/obj/item/I, var/mob/user, var/no_delay = 0, var/originator = null, var/def_zone = null)
	if(user.a_intent == I_HELP)
		user.visible_message("<span class='notice'>[user] [pick(list("pokes","prods","taps"))] \the [src] with \the [I]</span>")
		to_chat(user, "<span class='notice'>You [pick(list("poke","prod","tap"))] \the [src] with \the [I]</span>")
	else
		..()
		user.visible_message("<span class='danger'>[user] hits \the [src] with \the [I]</span>")
		to_chat(user, "<span class='danger'>You hit \the [src] with \the [I]</span>")
		if(health<=0)
			death()
		if(behavior_flags & ANIMAL_BEHAVIOR_RETALIATE)
			behavior_state=behavior_state=ANIMAL_STATE_ATTACKING
			aggro_drawn(user,ANIMAL_STATE_ATTACKING)
		else
			get_flee_msg(user)
			behavior_state = ANIMAL_STATE_FLEEING
			target=user


/mob/living/complex_animal/assaulted_by(var/mob/M,var/weak_assault=FALSE)	
	if(behavior_flags & ANIMAL_BEHAVIOR_RETALIATE)
		behavior_state=behavior_state=ANIMAL_STATE_ATTACKING
		aggro_drawn(M,ANIMAL_STATE_ATTACKING)
	else
		get_flee_msg(M)
		behavior_state = ANIMAL_STATE_FLEEING
		target=M
	return ..()


/mob/living/complex_animal/getarmor(var/def_zone, var/type)
	return armor[type] || 0
