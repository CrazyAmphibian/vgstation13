/datum/rcd_scematic_grouping/destroy
	name="deconstruct"
	
	
/datum/rcd_scematic_grouping/destroy/generate_html()
	return ..()

/datum/rcd_scematic_grouping/destroy/New()
	..()
	if(istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
		RCD.settings["decon_walls"]=1
		RCD.settings["decon_floors"]=1
		RCD.settings["decon_airlocks"]=1
		RCD.settings["decon_windows"]=1
		


/datum/rcd_scematic_grouping/switch_to()
	var/found=FALSE
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	
	for(var/datum/rcd_grouped_schematic/S in src)
		if(istype(S,/datum/rcd_grouped_schematic/destroy_all))
			RCD.selected_schem=S
			found=TRUE
			break;
	if(!found)
		RCD.selected_schem=new /datum/rcd_grouped_schematic/destroy_all(linked_rcd)

/datum/rcd_grouped_schematic/destroy_all
	name="all"
	cost=5
	
/datum/rcd_grouped_schematic/destroy_all/generate_html()
	var/dat=""
	var/list/options=new()
	if(istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
		options=RCD.settings
	
	
	dat+="Deconstruction settings:<br><ul style='line-height:150%;'>"
	dat+="<li><span class='[options["decon_walls"]?"schem_selected":"schem"]'><a href='?src=\ref[linked_rcd.interface];set_arg=decon_walls;value=[ options["decon_walls"] ? "0" : "1"];value_isnum=yes;'  >Walls</a></span><br></li>"
	
	dat+="<li><span class='[options["decon_floors"]?"schem_selected":"schem"]'><a href='?src=\ref[linked_rcd.interface];set_arg=decon_floors;value=[ options["decon_floors"] ? "0" : "1"];value_isnum=yes;' >Floors</a></span><br></li>"
	
	dat+="<li><span class='[options["decon_airlocks"]?"schem_selected":"schem"]'><a href='?src=\ref[linked_rcd.interface];set_arg=decon_airlocks;value=[ options["decon_airlocks"] ? "0" : "1"];value_isnum=yes;' >Airlocks</a></span><br></li>"
	
	dat+="<li><span class='[options["decon_windows"]?"schem_selected":"schem"]'><a href='?src=\ref[linked_rcd.interface];set_arg=decon_windows;value=[ options["decon_windows"] ? "0" : "1"];value_isnum=yes;' >Windows</a></span><br></li>"
	
	dat+="</ul>"
	return dat

/datum/rcd_grouped_schematic/destroy_all/build(var/atom/A, var/mob/user)
	var/list/options=new()
	options["decon_walls"]=1
	options["decon_floors"]=1
	options["decon_airlocks"]=1
	options["decon_windows"]=1 //fall back to everything enabled.
	if(istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
		options=RCD.settings
	
	if(istype(A, /turf/simulated/wall) && options["decon_walls"])
		var/turf/simulated/wall/T = A
		if(istype(T, /turf/simulated/wall/r_wall)  || istype(T, /turf/simulated/wall/invulnerable))
			return "it cannot deconstruct reinforced walls!"

		to_chat(user, "Deconstructing \the [T]...")
		playsound(linked_rcd, 'sound/machines/click.ogg', 50, 1)

		if(linked_rcd.delay(user, T, 4 SECONDS))
			if(linked_rcd.get_energy(user) < cost)
				return 0

			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			T.ChangeTurf(/turf/simulated/floor/plating)
			return cost

	else if(istype(A, /turf/simulated/floor) && options["decon_floors"])
		var/turf/simulated/floor/T = A
		to_chat(user, "Deconstructing \the [T]...")
		if(linked_rcd.delay(user, T, 5 SECONDS))
			if(linked_rcd.get_energy(user) < cost)
				return 0

			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			add_gamelogs(user, "deconstructed \the [T] with \the [linked_rcd]", admin = TRUE, tp_link = TRUE, tp_link_short = FALSE, span_class = "danger")
			T.investigation_log(I_RCD,"was deconstructed by [user]")
			T.ChangeTurf(T.get_underlying_turf())
			return cost

	else if(istype(A, /obj/machinery/door/airlock) && options["decon_airlocks"])
		var/obj/machinery/door/airlock/D = A
		to_chat(user, "Deconstructing \the [D]...")
		if(linked_rcd.delay(user, D, 5 SECONDS))
			if(linked_rcd.get_energy(user) < cost)
				return 0

			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			D.investigation_log(I_RCD,"was deconstructed by [user]")
			qdel(D)
			return cost

	else if(istype(A,/obj/structure/window) && options["decon_windows"])
		var/obj/structure/window/W = A
		if(is_type_in_list(W, list(/obj/structure/window/plasma,/obj/structure/window/reinforced/plasma,/obj/structure/window/full/plasma,/obj/structure/window/full/reinforced/plasma)) )
			return "it cannot deconstruct plasma glass!"
		to_chat(user, "Deconstructing \the [W]...")
		if(linked_rcd.delay(user, W, 5 SECONDS))
			if(linked_rcd.get_energy(user) < cost)
				return 0

			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			for(var/obj/structure/grille/G in W.loc)
				if(!istype(G,/obj/structure/grille/invulnerable)) // No more breaking out in places like lamprey
					G.investigation_log(I_RCD,"was deconstructed by [user]")
					qdel(G)
			for(var/obj/structure/window/WI in W.loc)
				if(is_type_in_list(W, list(/obj/structure/window/plasma,/obj/structure/window/reinforced/plasma,/obj/structure/window/full/plasma,/obj/structure/window/full/reinforced/plasma)) )
					continue
				if(WI != W)
					WI.investigation_log(I_RCD,"was deconstructed by [user]")
					qdel(WI)
			W.investigation_log(I_RCD,"was deconstructed by [user]")
			qdel(W)
			return cost
	return 0
	



/datum/rcd_scematic_grouping/build_wall
	name="walls"
	
/datum/rcd_scematic_grouping/build_wall/generate_html()
	var/dat=""
	dat+="<table class='clickabletable'><tr><th>wall</th><th>matter cost</th><th>construction time</th><th>upgradable from</th></tr>"
	for(var/datum/rcd_grouped_schematic/schem in schematics)
		dat+=schem.generate_html()
	dat+="</table>"
	return dat
	
/datum/rcd_scematic_grouping/build_wall/switch_to()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	RCD.selected_schem = schematics[1]

	
/datum/rcd_grouped_schematic/normalwall
	name="wall"
	cost=3

/datum/rcd_grouped_schematic/normalwall/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/costtouse=0
	
	if(!linked_rcd)
		return 0
	
	if(istype(T,/turf/simulated/floor))
		costtouse=cost
	else
		if(istype(T,/turf/space))
			costtouse=cost+1 //add cost to make the floor
		else
			costtouse=0
			
	if(costtouse)
		playsound(linked_rcd, 'sound/machines/click.ogg', 50, 1)
		if(linked_rcd.delay(user, A, 2 SECONDS))
			if(linked_rcd.get_energy(user) < costtouse)
				to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
				return 0
			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			T.ChangeTurf(/turf/simulated/wall)
			return costtouse
	else
		to_chat(user, "You cannot build a wall here!")
	
	return 0

/datum/rcd_grouped_schematic/normalwall/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return ""
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]wall</a></td><td>[a][cost+1]</a></td><td>[a]2</a></td><td>[a]floor</a></td></tr>"




/datum/rcd_grouped_schematic/rwall
	name="reinforced wall"
	cost=5

/datum/rcd_grouped_schematic/rwall/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/costtouse=0
	var/timetaken= 2 SECONDS
	if(!linked_rcd)
		return 0
	
	if(istype(T,/turf/simulated/floor))
		costtouse=cost+3 //add cost to make a regular wall
		timetaken = 4 SECONDS
	else
		if(istype(T,/turf/space))
			costtouse=cost+1+3 //add cost to make the floor and the wall
			timetaken = 4 SECONDS
		else
			if(istype(T,/turf/simulated/wall))
				costtouse=cost
			else
				costtouse=0
			
	if(costtouse)
		playsound(linked_rcd, 'sound/machines/click.ogg', 50, 1)
		if(linked_rcd.delay(user, A, timetaken))
			if(linked_rcd.get_energy(user) < costtouse)
				to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
				return 0
			playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
			T.ChangeTurf(/turf/simulated/wall/r_wall)
			return costtouse
	else
		to_chat(user, "You cannot build a wall here!")
	
	return 0

/datum/rcd_grouped_schematic/rwall/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return ""
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]reinforced wall</a></td><td>[a][cost+1+3]</a></td><td>[a]4</a></td><td>[a]wall floor</a></td></tr>"


/datum/rcd_scematic_grouping/build_floors
	name="floors"
	
	
/datum/rcd_scematic_grouping/build_floors/generate_html()
	var/dat=""
	dat+="<table class='clickabletable'><tr><th>floor</th><th>matter cost</th><th>construction time</th><th>upgradable from</th></tr>"
	for(var/datum/rcd_grouped_schematic/schem in schematics)
		dat+=schem.generate_html()
	dat+="</table>"
	return dat
	
/datum/rcd_scematic_grouping/build_floors/switch_to()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	RCD.selected_schem = schematics[1]	
	
	
/datum/rcd_grouped_schematic/floor
	name="floor"
	cost=1
	
/datum/rcd_grouped_schematic/floor/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	if(!istype(T,/turf/space))
		to_chat(user, "You can only build this floor in space!")
		return 0
	if(linked_rcd.get_energy(user) < cost)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	T.ChangeTurf(/turf/simulated/floor)
	return cost

/datum/rcd_grouped_schematic/floor/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return ""
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]floor</a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]&emsp;</a></td></tr>"		
	
	
/datum/rcd_grouped_schematic/plating
	name="plating"
	cost=1
	
/datum/rcd_grouped_schematic/plating/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	if(!istype(T,/turf/space))
		to_chat(user, "You can only build this floor in space!")
		return 0
	if(linked_rcd.get_energy(user) < cost)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	T.ChangeTurf(/turf/simulated/floor/plating)
	return cost

/datum/rcd_grouped_schematic/plating/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return ""
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]plating</a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]&emsp;</a></td></tr>"		


/datum/rcd_grouped_schematic/rfloor
	name="reinforced floor"
	cost=1
	
/datum/rcd_grouped_schematic/rfloor/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/cc=cost
	if(istype(T,/turf/space))
		cc=cost+1
	else
		if(T.type==/turf/simulated/floor || T.type==/turf/simulated/floor/plating )
			cc=cost
		
	if(!cc)
		to_chat(user, "You connot build this floor here!")
		return
		
	if(linked_rcd.delay(user, A, 2 SECONDS))
		if(linked_rcd.get_energy(user) < cost)
			to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
			return 0
		playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
		T.ChangeTurf(/turf/simulated/floor/engine)
		return cc
	return 0

/datum/rcd_grouped_schematic/rfloor/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return ""
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]reinforced floor</a></td><td>[a][cost+1]</a></td><td>[a]0</a></td><td>[a]floor plating</a></td></tr>"		
	

/datum/rcd_grouped_schematic/glassfloor
	name="glass floor"
	cost=1
	
/datum/rcd_grouped_schematic/glassfloor/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	if(!istype(T,/turf/space))
		to_chat(user, "You can only build this floor in space!")
		return 0
	if(linked_rcd.get_energy(user) < cost)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	T.ChangeTurf(/turf/simulated/floor/glass/airless)
	return cost

/datum/rcd_grouped_schematic/glassfloor/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return ""
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a = "<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]glass floor</a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]&emsp;</a></td></tr>"		
	