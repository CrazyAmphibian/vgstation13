
//floors

/turf/unsimulated/floor/jungle
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	plane = PLATING_PLANE
	intact=0

//returns 0.0 if it cannot. otherwise, returns a number as the object's tool speed.
/turf/unsimulated/floor/jungle/proc/item_terraforming_ispickaxe(obj/item/C)
	if(istype(C,/obj/item/weapon/pickaxe) && !istype(C,/obj/item/weapon/pickaxe/shovel))
		return 1.0
	if(istype(C,/obj/item/tool/crowbar)) 
		if(istype(C,/obj/item/tool/crowbar/halligan)) //halligans have a pick end.
			return 0.75
		return 0.5
	if(istype(C,/obj/item/weapon/kitchen/utensil/knife))  //for those daring prison escapes, also because it's funny.
		return 0.1
	return 0.0
	
/turf/unsimulated/floor/jungle/proc/item_terraforming_isshovel(obj/item/C)
	if(istype(C,/obj/item/weapon/pickaxe/shovel))
		return 1.0
	if(istype(C,/obj/item/weapon/kitchen/utensil/spoon) || istype(C,/obj/item/weapon/kitchen/utensil/spork))  //see above
		return 0.1
	return 0.0	
	

/turf/unsimulated/floor/jungle/grass
	name="Jungle Grass"
	desc="A thick and lush carpet of various plant species, sustained by a regular supply to water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass_alt1"
	turf_speed_multiplier=1.1 // tall grass.
	
/turf/unsimulated/floor/jungle/grass/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	var/s=0.0
	s=item_terraforming_ispickaxe(C)
	if(s>0.0)
		to_chat(user, "<span class='notice'>You start breaking up the soil</span>")
		if(do_after(user, src, 20/s ))
			ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
			new /obj/item/stack/tile/grass(src,1)
	
	
/turf/unsimulated/floor/jungle/grass/ex_act(severity)	
	switch(severity)
		if(1.0)
			ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(2.0)
			if(prob(70))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(3.0)
			if(prob(40))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)

/turf/unsimulated/floor/jungle/grass/New()
	..()
	icon_state="grass_alt[rand(1,4)]"


/turf/unsimulated/floor/jungle/mud
	name="Mud"
	desc="A viscous mixture of water and soil."
	turf_speed_multiplier=2 //mud is difficult to travel over
	icon_state = "ironsand1"

/turf/unsimulated/floor/jungle/mud/New()
	..()
	icon_state="ironsand[rand(1,15)]"	


/turf/unsimulated/floor/jungle/concrete
	name="Concrete"
	desc="Or is it asphalt?"
	icon='icons/turf/new_snow.dmi'
	icon_state = "concrete"

/turf/unsimulated/floor/jungle/concrete/ex_act(severity)	
	switch(severity)
		if(1.0)
			if(prob(50))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(2.0)
			if(prob(25))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(3.0)
			if(prob(5))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)


/turf/unsimulated/floor/jungle/dirt
	name="Soil"
	desc="A mixture of sediments, clays, and decomposed matter."
	icon='icons/turf/walls.dmi'
	icon_state = "rock(high)"


/turf/unsimulated/floor/jungle/dirt/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	if(C.type== /obj/item/stack/tile/grass)
		var/obj/item/stack/tile/T = C
		if(T.use(1))
			ChangeTurf(/turf/unsimulated/floor/jungle/grass)
	var/s=0.0
	s=item_terraforming_isshovel(C)
	if(s>0.0)
		to_chat(user, "<span class='notice'>You start packing down the soil</span>")
		if(do_after(user, src, 20/s ))
			ChangeTurf(/turf/unsimulated/floor/jungle/path)
			

/turf/unsimulated/floor/jungle/path
	name="Compressed Dirt"
	desc="Soil which has been pressed down into a hard, smooth surface."
	icon='icons/turf/floors.dmi'
	icon_state = "asteroid0"	

/turf/unsimulated/floor/jungle/path/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	if(C.type== /obj/item/stack/tile/metal)
		var/obj/item/stack/tile/T = C
		if(T.use(1))
			ChangeTurf(/turf/unsimulated/floor/jungle/path_plated)
			plane=TURF_PLANE
			remove_paint_overlay()
			update_icon()
			update_paint_overlay()
			levelupdate()
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			return
	var/s=0.0
	s=item_terraforming_ispickaxe(C)
	if(s>0.0)
		to_chat(user, "<span class='notice'>You start breaking up the soil</span>")
		if(do_after(user, src, 20/s ))
			ChangeTurf(/turf/unsimulated/floor/jungle/dirt)

/turf/unsimulated/floor/jungle/path/ex_act(severity)	
	switch(severity)
		if(1.0)
			ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(2.0)
			if(prob(66))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(3.0)
			if(prob(33))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)


/turf/unsimulated/floor/jungle/path_plated
	name="Plated Soil"
	desc="Compressed soil which has plated atop it to protect items underneath it."
	icon='icons/turf/floors.dmi'
	icon_state = "asteroidfloor"
	plane = TURF_PLANE


/turf/unsimulated/floor/jungle/path_plated/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	if(iscrowbar(C))
		ChangeTurf(/turf/unsimulated/floor/jungle/path)
		new /obj/item/stack/tile/metal(src,1)
		plane=PLATING_PLANE
		remove_paint_overlay()
		update_icon()
		update_paint_overlay()
		levelupdate()
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)

/turf/unsimulated/floor/jungle/path_plated/ex_act(severity)
	switch(severity)
		if(1.0)
			ChangeTurf(/turf/unsimulated/floor/jungle/path)
		if(2.0)
			if(prob(50))
				ChangeTurf(/turf/unsimulated/floor/jungle/path)
		if(3.0)
			if(prob(20))
				ChangeTurf(/turf/unsimulated/floor/jungle/path)



/turf/unsimulated/floor/jungle/water
	name="Water"
	desc="It's about knee-height. Probably not safe to drink from."
	icon = 'icons/misc/beach.dmi'
	icon_state = "water5"
	turf_speed_multiplier=1.75
	plane = ABOVE_OBJ_PLANE

/turf/unsimulated/floor/jungle/water_deep
	name="Deep Water"
	desc="It's nearly up to your shoulders. Probably not safe to drink from."
	icon = 'icons/misc/beach.dmi'
	icon_state = "water2"
	turf_speed_multiplier=2.5
	plane = MOB_PLANE


/turf/unsimulated/floor/jungle/sand
	name="Sand"
	desc="Rocks which have been eroded over countless centuries into a fine powder. A wonderful material for castles!"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	
	
/turf/unsimulated/floor/jungle/underground
	name="Packed Soil"
	density=1
	opacity=1
	desc="Solid dirt as far as the eye can see."
	icon='icons/turf/walls.dmi'
	icon_state = "gingerbread15"	
	var/loosened=FALSE // you dig with a pickaxe, too, dumbass.
	

/turf/unsimulated/floor/jungle/underground/ex_act(severity)
	switch(severity)
		if(1.0)
			ChangeTurf(/turf/unsimulated/floor/jungle/bedrock)
		if(2.0)
			if(prob(50))
				ChangeTurf(/turf/unsimulated/floor/jungle/bedrock)
			else
				loosened=TRUE
		if(3.0)
			if(prob(75))
				loosened=TRUE


/turf/unsimulated/floor/jungle/underground/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	var/s=0.0
	s=item_terraforming_ispickaxe(C)
	if(s>0.0)
		if (loosened)
			to_chat(user, "<span class='notice'>The soil is already loose.</span>")
		else
			to_chat(user, "<span class='notice'>You start to loosen the soil...</span>")
			if(do_after(user, src, 20/s ))
				loosened=TRUE
	s=item_terraforming_isshovel(C)			
	if(s>0.0)
		to_chat(user, loosened ? "<span class='notice'>You begin to break apart the soil...</span>" : "<span class='notice'>You struggle to break up the soil...</span>")
		if(do_after(user, src, (loosened ? 20 : 60)/s ))
			ChangeTurf(/turf/unsimulated/floor/jungle/bedrock)
			new/obj/item/stack/ore/glass(src,50) //theres no dirt, so we use sand instead.
	
	
/turf/unsimulated/floor/jungle/bedrock
	name="Bedrock"
	desc="A very dense rock. Nothing seems to be able to dig through it."
	icon='icons/turf/walls.dmi'
	icon_state = "mariahive_noanimation"	

/turf/unsimulated/floor/jungle/bedrock/New(var/loc) //todo: when we make a new bedrock tile, update adjacent tiles to visualize the foundation.	
	
/turf/unsimulated/floor/jungle/bedrock/ex_act(severity)	
	return
	
/turf/unsimulated/floor/jungle/foundation	
	name="Foundation"
	density=1
	opacity=1
	desc="a very hard metal structure. you don't think you'll be able to get through it, no matter what."
	icon='icons/turf/walls.dmi'
	icon_state = "cave_wall"
	
/turf/unsimulated/floor/jungle/foundation/ex_act(severity)	
	return	