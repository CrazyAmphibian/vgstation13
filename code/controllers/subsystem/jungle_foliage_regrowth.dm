var/datum/subsystem/foliage_regrow_junga/SSFoliageRegrow

var/global/list/turf/TURFS_TO_REGROW=list()

/datum/subsystem/foliage_regrow_junga
	name          = "Foliage Regrowth System"
	init_order    = SS_INIT_FOLIAGE_REGROW
	display_order = SS_DISPLAY_FOLIAGE_REGROW
	priority      = SS_PRIORITY_FOLIAGE_REGROW
	wait          = 30 SECONDS
	var/next_firetime=0


/datum/subsystem/foliage_regrow_junga/New()
	..()
	NEW_SS_GLOBAL(SSFoliageRegrow)

/datum/subsystem/foliage_regrow_junga/Initialize()
	..()

/datum/subsystem/foliage_regrow_junga/fire(resumed = FALSE)
	if(world.time < next_firetime)
		return
	var/i=0
	//var/callcount=0
	//var/fl=TURFS_TO_REGROW.len
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
		if((G.regrowticks <= world.time-(5 MINUTES)) && prob(75)) //5 minute delay to regrowth
			//callcount++
			if(!G.generate_foliage())
				TURFS_TO_REGROW+=G
	
	if(TURFS_TO_REGROW.len && i)
		TURFS_TO_REGROW.Cut(1,i) 
			
	//world.log << "[name] === [i] iterations, [callcount] calls. remaining: [TURFS_TO_REGROW.len] ([fl])"
	next_firetime=world.time +	wait