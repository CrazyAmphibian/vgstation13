//Religious-based chemicals

/datum/reagent/holywater
	name = "Holy Water"
	id = HOLYWATER
	description = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#8497A9" //rgb: 52, 59, 63
	custom_metabolism = 2
	specheatcap = 4.183
	alpha = 128
	plant_watering = 2
	fission_absorbtion=5000
	fission_time = 1800 //30 minutes

/datum/reagent/holywater/on_mob_life(mob/living/M)
	if(..())
		return 1
	M.immune_system.ApplyAntipathogenics(100, list(ANTIGEN_CULT), 2)

/datum/reagent/holywater/reaction_mob(var/mob/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	//Put out fire
	if(method == TOUCH)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/datum/disease2/effect/E = C.has_active_symptom(/datum/disease2/effect/thick_skin)
			C.make_visible(INVISIBLESPRAY,FALSE)
			if(E)
				E.multiplier = max(E.multiplier - rand(1,3), 1)
				to_chat(C, "<span class='notice'>The water quenches your dry skin.</span>")
		else
			M.make_visible(INVISIBLESPRAY)
		if(isliving(M))
			var/mob/living/L = M
			L.extinguish()

	//Water now directly damages slimes instead of being a turf check
	if(isslime(M))
		var/mob/living/L = M
		L.adjustToxLoss(rand(15, 20))

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species && H.species.anatomy_flags & ACID4WATER) //oof ouch, water is spicy now
			if(method == TOUCH)
				if(H.check_body_part_coverage(EYES|MOUTH))
					to_chat(H, "<span class='warning'>Your face is protected from a splash of water!</span>")
					return
				if(prob(15) && volume >= 30)
					var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
					if(head_organ)
						if(head_organ.take_damage(0, 25))
							H.UpdateDamageIcon(1)
						head_organ.disfigure("burn")
						H.audible_scream()
				else
					H.take_organ_damage(0, min(15, volume * 2))

		else if(isslimeperson(H))

			H.adjustToxLoss(rand(1,3))
	if(method == TOUCH)
		M.clean_act(CLEANLINESS_WATER)

/datum/reagent/holywater/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(volume >= 1)
		O.bless()

	O.clean_act(CLEANLINESS_WATER)//removes glue and extinguishes fire

/datum/reagent/holywater/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1
	if(volume >= 5)
		T.bless()

	T.clean_act(CLEANLINESS_WATER)

/datum/reagent/holywater/reaction_animal(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
	..()

	if(volume >= 5)
		if(istype(M,/mob/living/simple_animal/construct) || istype(M,/mob/living/simple_animal/shade))
			var/mob/living/simple_animal/C = M
			C.purge = 3
			C.adjustBruteLoss(5)
			C.visible_message("<span class='danger'>The [src] erodes \the [M].</span>")


/datum/reagent/holywater/sacredwater
	name = "Sacred Water"
	id = SACREDWATER
	description = "Water-like liquid that combusts when thrown upon a floor. The flames produced only harm the unholy."
	color = "#017AFF" //rgb: 1, 122, 255

/datum/reagent/holywater/sacredwater/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 1)
		var/obj/effect/overlay/sacred_flames/flames = locate() in T
		if (flames)
			flames.lifetime = initial(flames.lifetime)
		else
			new /obj/effect/overlay/sacred_flames(T)

/datum/reagent/holywater/sacredwater/special_behaviour()
	//I sure hope allowing castlevania chaplains to produce infinite sacred flames doesn't turn out to be a bad idea
	for (var/datum/reagent/R in holder.reagent_list)
		if (R.id == HOLYWATER)
			var/added_volume = R.volume
			holder.del_reagent(R.id)
			volume += added_volume

////////////////////////////////////////////////////////////////////////////////
/obj/effect/overlay/sacred_flames
	mouse_opacity = 0
	icon = 'icons/effects/fireblue.dmi'
	icon_state = "1"
	plane = OBJ_PLANE
	layer = BELOW_OBJ_LAYER
	var/lifetime = 3//seconds

/obj/effect/overlay/sacred_flames/New()
	..()
	icon_state = pick("1","2","3")
	add_particles(PS_CROSS_DUST)
	adjust_particles(PVAR_VELOCITY, list(0,4), PS_CROSS_DUST)
	add_particles(PS_SACRED_FLAME)
	add_particles(PS_SACRED_FLAME2)
	set_light(3,0.5,"#1414A4")
	spawn()
		process_flames()

/obj/effect/overlay/sacred_flames/proc/process_flames()
	set waitfor = 0
	while(lifetime > 0)
		harm_unholy()
		lifetime--
		sleep(1 SECONDS)
	set_light(0)
	icon = 'icons/effects/32x32.dmi'
	icon_state = "blank"
	adjust_particles(PVAR_SPAWNING, 0)
	sleep(1 SECONDS)
	qdel(src)

/obj/effect/overlay/sacred_flames/proc/harm_unholy()
	var/turf/T = get_turf(src)
	for (var/mob/living/L in T)
		if (L.isUnholy())
			L.take_overall_damage(0,15)
////////////////////////////////////////////////////////////////////////////////

/datum/reagent/holysalts
	name = "Holy Salts"
	id = HOLYSALTS
	description = "Blessed salts have been used for centuries as a sacramental. Pouring it on the floor in large enough quantity will offer protection from sources of evil and mend boundaries."
	reagent_state = REAGENT_STATE_SOLID
	color = "#C1CCD7" //rgb: 80, 80, 84
	density = 2.09
	specheatcap = 1.65
	plant_nutrition = 5
	plant_watering = -5
	plant_pests = -10
	plant_weeds = -20
	plant_toxins = 8
	plant_health = -2
	fission_absorbtion=5000
	fission_time = 1800 //30 minutes

/datum/reagent/holysalts/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1
	if(volume >= 1)
		O.bless()

/datum/reagent/holysalts/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1
	if(!T.has_dense_content() && volume >= 10 && !(locate(/obj/effect/decal/cleanable/salt/holy) in T))
		if(!T.density)
			T.bless()
			new /obj/effect/decal/cleanable/salt/holy(T)

/datum/reagent/holysalts/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	var/list/borers = M.get_brain_worms()
	if(borers)
		for(var/mob/living/simple_animal/borer/B in borers)
			B.health -= 1
			to_chat(B, "<span class='warning'>Something in your host's bloodstream burns you!</span>")

/datum/reagent/holysalts/reaction_animal(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
	..()
	if(volume >= 5)
		if(istype(M,/mob/living/simple_animal/construct) || istype(M,/mob/living/simple_animal/shade))
			var/mob/living/simple_animal/C = M
			C.purge = 3
			C.adjustBruteLoss(5)
			C.visible_message("<span class='danger'>The [src] erodes \the [M].</span>")

/datum/reagent/incense
	id = EXPLICITLY_INVALID_REAGENT_ID
	reagent_state = REAGENT_STATE_GAS
	density = 3.214
	specheatcap = 1.34
	color = "#E0D3D3" //rgb: 224, 211, 211
	data = list("source" = null)

/datum/reagent/incense/on_introduced(var/data)
	..()
	if(!src.data["source"]) //src is necessary because of this terrible var name, but consistency!
		src.data["source"] = holder.my_atom

/datum/reagent/incense/proc/OnDisperse(var/turf/location)

/datum/reagent/incense/harebells//similar effects as holy water to cultists and vampires
	name = "Holy Incense"
	id = INCENSE_HAREBELLS
	description = "An incense used in holy rituals. Can be used to impede the occult."

/datum/reagent/incense/poppies//similar effects as chill wax and paracetamol
	name = "Opium Incense"
	id = INCENSE_POPPIES
	description = "A pleasing fragrance that soothes the nerves and removes pain."
	pain_resistance = 60
	custom_metabolism = 0.15

/datum/reagent/incense/poppies/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.pain_level < BASE_CARBON_PAIN_RESIST)
			C.pain_shock_stage--
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.druggy = max(H.druggy, 5)
			H.Dizzy(2)
			if(prob(5))
				H.emote(pick("stare", "giggle"), null, null, TRUE)
			if(prob(5))
				to_chat(H, "<span class='notice'>[pick("You feel at peace with the world.","Everyone is nice, everything is awesome.","You feel high and ecstatic.")]</span>")
			if(prob(2))
				to_chat(H, "<span class='notice'>You doze off for a second.</span>")
				H.sleeping += 1

/datum/reagent/incense/sunflowers//flavor text, does nothing
	name = "Incense"
	id = INCENSE_SUNFLOWERS
	description = "While it smells really nice, incense is known to increase the risk of lung cancer."

/datum/reagent/incense/mustardplant //same as sunflower, no connection to mustard gas
	name = "Mustardplant Incense"
	id = INCENSE_MUSTARDPLANT
	description = "A sweet scent with a tinge of clover." //i have no idea what these smell like, im going off of forum posts, if anyone does know please edit the desc

/datum/reagent/incense/moonflowers//Basically mindbreaker
	name = "Hallucinogenic Incense"
	id = INCENSE_MOONFLOWERS
	description = "This fragrance is so unsettling that it makes you question reality."
	custom_metabolism = 0.15

/datum/reagent/incense/moonflowers/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if (M.hallucination < 22)
		M.hallucination += 10

/datum/reagent/incense/novaflowers//Converts itself to hyperzine, but makes you hungry
	name = "Hyperactivity Incense"
	id = INCENSE_NOVAFLOWERS
	description = "This fragrance helps you focus and pull into your energy reserves to move quickly."
	nutriment_factor = -5 * REAGENTS_METABOLISM
	custom_metabolism = 0.15

/datum/reagent/incense/novaflowers/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(holder.get_reagent_amount(HYPERZINE) < 2)
		holder.add_reagent(HYPERZINE, 0.5)

/datum/reagent/incense/banana
	name = "Banana Incense"
	id = INCENSE_BANANA
	description = "This fragrance helps you be more clumsy, so you can laugh at yourself."

/datum/reagent/incense/banana/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(prob(5))
		to_chat(M,"<span class='warning'>[pick("You feel like giggling!", "You feel clumsy!", "You want to honk!")]</span>")

/datum/reagent/incense/leafy
	name = "Leafy Incense"
	id = INCENSE_LEAFY
	description = "This fragrance smells of fresh greens, delicious to most animals."

/datum/reagent/incense/leafy/reagent_deleted()
	if(..())
		return 1
	if(!holder)
		return
	var/mob/M =  holder.my_atom
	walk(M,0) //Cancel walk if it ran out

/datum/reagent/incense/leafy/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(isanimal(M) || ismonkey(M))
		if(istype(M,/mob/living/simple_animal/hostile))
			var/mob/living/simple_animal/hostile/H = M
			switch(H.stance)
				if(HOSTILE_STANCE_ATTACK,HOSTILE_STANCE_ATTACKING)
					if(istype(M,/mob/living/simple_animal/hostile/retaliate/goat))
						var/mob/living/simple_animal/hostile/retaliate/goat/G = M
						G.Calm()
					else
						return
		M.start_walk_to(get_turf(data["source"]),1,6)

/datum/reagent/incense/booze
	name = "Alcoholic Incense"
	id = INCENSE_BOOZE
	description = "This fragrance is dense with the odor of ethanol."

/datum/reagent/incense/booze/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(M.slurring < 22)
		M.slurring += 10
	if(M.eye_blurry < 22)
		M.eye_blurry += 10

/datum/reagent/incense/vapor
	name = "Airy Incense"
	id = INCENSE_VAPOR
	description = "It burns your nostrils a little. The incense smells... clean."

/datum/reagent/incense/vapor/OnDisperse(var/turf/location)
	for(var/turf/simulated/T in view(2,location))
		if(T.is_wet())
			T.dry(TURF_WET_LUBE)
			T.turf_animation('icons/effects/water.dmi',"dry_floor",0,0,TURF_LAYER)

/datum/reagent/incense/dense
	name = "Dense Incense"
	id = INCENSE_DENSE
	description = "This isn't really a fragrance so much as tactical smoke."
	custom_metabolism = 0.25

/datum/reagent/incense/dense/OnDisperse(var/turf/location)
	var/datum/effect/system/smoke_spread/smoke = new /datum/effect/system/smoke_spread()
	smoke.set_up(2, 0, location) //Make 2 drifting clouds of smoke, direction
	smoke.start()

/datum/reagent/incense/dense/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")

/datum/reagent/incense/vale
	name = "Sporty Incense"
	id = INCENSE_CRAVE
	description = "This has what you crave. Electrolytes."
	sport = SPORTINESS_SPORTS_DRINK
	custom_metabolism = 0.15

/datum/reagent/incense/cornoil
	name = "Corn Oil Incense"
	id = INCENSE_CORNOIL
	description = "This fragrance reminds you of a nice home-cooked meal, and sometimes even feels like it fills you up."

/datum/reagent/incense/cornoil/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(prob(5))
		to_chat(M,"<span class='warning'>[pick("You feel fuller.", "You no longer feel snackish.")]</span>")
		M.reagents.add_reagent(NUTRIMENT, 2)


/datum/reagent/holiestwater
	name = "Divine Elixir"
	id = HOLIESTWATER
	description = "A substance which brings light to those devoted to the dark."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#abd447" //rgb: 171,212,713
	specheatcap = 4.183
	alpha = 128
	fission_absorbtion=0
	fission_time=null

//what?
/datum/reagent/holiestwater/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1
	T.bless()
	playsound(holder.my_atom, 'sound/misc/holyhandgrenade.ogg', 100, 0)
	spawn(18) hallelujah(T)
	
//damn you BYOND
/datum/reagent/holiestwater/proc/hallelujah(var/turf/simulated/T)
	var/obj/lords_vengeance/V = new(T,volume)
	V.adjacent_spread=1 //the origin should spread out for a consistent AoE in a 3x3 grid.
	V.spread_prob=100

/datum/reagent/holiestwater/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1
		
	O.bless()

/datum/reagent/holiestwater/on_mob_life(mob/living/M)
	if(..())
		return 1
	M.immune_system.ApplyAntipathogenics(100, list(ANTIGEN_CULT), 5)

	
/obj/lords_vengeance
	name="Lord's Vengeance"
	desc="The path of the righteous man is beset on all sides by the inequities of the selfish and the tyranny of evil men."
	icon='icons/obj/holiestwater.dmi'
	icon_state="normal"
	var/say_what_again=0
	density=0
	var/adjacent_spread=0.8 //how much of our power to spread to other tiles
	var/spread_prob = 50 // the probability each adjacent tile will be picked
	var/transferance_penalty=0.8 // how much of the spread power will be taken from us when we spread. (lower numbers = longer lasting)

/obj/lords_vengeance/New(var/loc,var/amt_splashed=0)
	if(!amt_splashed) //it needs reagents to do stuff with.
		qdel(src)
		return
	fast_objects+=src
	say_what_again=amt_splashed
	set_light(3,5,rgb(255,255,200))

/obj/lords_vengeance/Destroy()
	fast_objects-=src
	..()

/obj/lords_vengeance/process()
	
	for(var/obj/O in loc.contents)
		O.bless()
	loc.bless()
	for(var/mob/living/M in loc.contents)
		M.immune_system.ApplyAntipathogenics(100, list(ANTIGEN_CULT), say_what_again)
		if(M.mind && (M.mind.GetRole(CULTIST) || M.mind.GetRole(VAMPIRE)) )
			M.adjustFireLoss(2.5*sqrt(max(0,say_what_again)))

	say_what_again-=0.5
	if(say_what_again<=0)
		qdel(src)
		return
	
	var/list/DirPicks=list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	for(var/i=1,i<DirPicks.len,i++) //shuffle the list to randomize the order
		DirPicks.Swap(i,rand(1,DirPicks.len))

	for(var/D in DirPicks)
		var/turf/T=get_step(loc,D)
		if(!T) //no turf? that's bad.
			continue
		if(!prob(spread_prob))
			continue
		if(T.density) //no wallbangs, buddy
			continue
		var/obj/lords_vengeance/Match=(locate(/obj/lords_vengeance) in T.contents)
		if(Match) //if we find another instance in the turf
			if(Match.say_what_again < say_what_again) //give it extra power by taking from our own to match ours.
				var/diff=say_what_again - Match.say_what_again
				Match.say_what_again+=diff*adjacent_spread
				say_what_again-=diff*adjacent_spread*transferance_penalty
		else //otherwise, spawn a new one
			new/obj/lords_vengeance(T,say_what_again*adjacent_spread)
			say_what_again-=say_what_again*adjacent_spread*transferance_penalty

			
	