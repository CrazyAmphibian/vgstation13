
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

/turf/unsimulated/floor/jungle/path_plated
	name="Plated Soil"
	desc="Compressed soil which has plated atop it to protect items underneath it."
	icon='icons/turf/floors.dmi'
	icon_state = "asteroidfloor"


//walls






	