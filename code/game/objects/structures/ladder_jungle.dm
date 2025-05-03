//subtype used in junglestation for tunnels. do NOT spawn it normally.

/obj/structure/ladder/jungle_tunnel


/obj/structure/ladder/jungle_tunnel/ex_act()
	return
/obj/structure/ladder/jungle_tunnel/singularity_act()
	return 0

	
/obj/structure/ladder/jungle_tunnel/Destroy()
	..()
	if(up)
		qdel(up)
	if(down)
		qdel(down)
	var/turf/T = loc
	if(T.type==/turf/unsimulated/floor/jungle/bedrock)
		var/turf/unsimulated/floor/jungle/bedrock/TT=T
		TT.hashole=null
		TT.icon_state="mariahive_noanimation"
	if(T.type==/turf/unsimulated/floor/jungle/dirt)
		var/turf/unsimulated/floor/jungle/dirt/TT=T
		TT.hashole=null
	
	