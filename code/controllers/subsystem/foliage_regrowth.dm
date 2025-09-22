var/datum/subsystem/foliage_regrow/SSFoliageRegrow

var/global/list/turf/TURFS_TO_REGROW=list()

/datum/subsystem/foliage_regrow
	name          = "Foliage Regrowth System"
	init_order    = SS_INIT_FOLIAGE_REGROW
	display_order = SS_DISPLAY_FOLIAGE_REGROW
	priority      = SS_PRIORITY_FOLIAGE_REGROW
	wait          = 2 MINUTES
	var/next_firetime=0


/datum/subsystem/foliage_regrow/New()
	..()
	NEW_SS_GLOBAL(SSFoliageRegrow)

/datum/subsystem/foliage_regrow/Initialize()
	..()

/datum/subsystem/foliage_regrow/fire(resumed = FALSE)
	if(world.time < next_firetime)
		return
	var/i=0

	while(i<TURFS_TO_REGROW.len)
		if(MC_TICK_CHECK)
			break
		i++
		var/turf/T=TURFS_TO_REGROW[i]//first in, last out
		if(!T || T.type!=/turf/unsimulated/floor/jungle/grass) //don't use istype, since we don't care about the noflora subtype.
			continue
		var/turf/unsimulated/floor/jungle/grass/G=T
		if(/obj/structure/flora in G.contents)
			continue
		if((G.regrowticks <= world.time-(5 MINUTES)) && prob(95)) //5 minute delay to regrowth
			if(!G.generate_foliage())
				TURFS_TO_REGROW+=G
	
	if(TURFS_TO_REGROW.len && i)
		TURFS_TO_REGROW.Cut(1,i) 
			
	next_firetime=world.time +	wait