
//floors

/turf/unsimulated/floor/jungle
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	plane = PLATING_PLANE


/turf/unsimulated/floor/jungle/grass
	name="Jungle Grass"
	desc="A thick and lush carpet of various plant species, sustained by a regular supply to water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass_alt1"
	turf_speed_multiplier=1.1 // tall grass.
	
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
	plane = PLATING_PLANE


/turf/unsimulated/floor/jungle/path_plated/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	if(iscrowbar(C))
		ChangeTurf(/turf/unsimulated/floor/jungle/path)
		new /obj/item/stack/tile/metal(src,1)

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