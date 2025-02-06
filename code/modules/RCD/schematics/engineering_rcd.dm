/datum/rcd_scematic_grouping/destroy
	name="deconstruct"
	headerimage="RCD_HEADER_DESTROY.png"
	
/datum/rcd_scematic_grouping/destroy/generate_html()
	return ..()

/datum/rcd_scematic_grouping/destroy/send_assets(var/client/client)
	register_asset("RCD_HEADER_DESTROY.png", new/icon('icons/effects/condecon.dmi', "decon" ))
	send_asset(client, "RCD_HEADER_DESTROY.png")	

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
	headerimage="RCD_HEADER_WALLS.png"
	
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

/datum/rcd_scematic_grouping/build_wall/send_assets(var/client/client)
	register_asset("floor_RCD.png", new/icon('icons/turf/floors.dmi', "floor" ))
	send_asset(client, "floor_RCD.png")	
	
	register_asset("wall_RCD.png", new/icon('icons/turf/walls.dmi', "metal0" ))
	send_asset(client, "wall_RCD.png")	
	
	register_asset("rwall_RCD.png", new/icon('icons/turf/walls.dmi', "rwall0" ))
	send_asset(client, "rwall_RCD.png")	
	
	register_asset("woodwall_RCD.png", new/icon('icons/turf/walls.dmi', "wood0" ))
	send_asset(client, "woodwall_RCD.png")	
	
	register_asset("RCD_HEADER_WALLS.png", new/icon('icons/turf/walls.dmi', "metal0" ))
	send_asset(client, "RCD_HEADER_WALLS.png")	
	
	
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
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='wall_RCD.png'></a></td><td>[a][cost+1]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'></a></td></tr>"




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
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='rwall_RCD.png'></a></td><td>[a][cost+1+3]</a></td><td>[a]4</a></td><td>[a]<img src='floor_RCD.png'><img src='wall_RCD.png'></a></td></tr>"


/datum/rcd_grouped_schematic/woodwall
	name="wooden wall"
	cost=2


/datum/rcd_grouped_schematic/woodwall/build(var/atom/A, var/mob/user)
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
			T.ChangeTurf(/turf/simulated/wall/mineral/wood)
			return costtouse
	else
		to_chat(user, "You cannot build a wall here!")
	
	return 0

/datum/rcd_grouped_schematic/woodwall/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return ""
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name];'>"
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='woodwall_RCD.png'></a></td><td>[a][cost+1]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'></a></td></tr>"


/datum/rcd_scematic_grouping/build_floors
	name="floors"
	headerimage="RCD_HEADER_FLOORS.png"
	
	
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

/datum/rcd_scematic_grouping/build_floors/send_assets(var/client/client)
	register_asset("floor_RCD.png", new/icon('icons/turf/floors.dmi', "floor" ))
	send_asset(client, "floor_RCD.png")	
	
	register_asset("plating_RCD.png", new/icon('icons/turf/floors.dmi', "plating" ))
	send_asset(client, "plating_RCD.png")	

	register_asset("rfloor_RCD.png", new/icon('icons/turf/floors.dmi', "engine" ))
	send_asset(client, "rfloor_RCD.png")	
	
	register_asset("glassfloor_RCD.png", new/icon('icons/turf/overlays.dmi', "glass_floor" ))
	send_asset(client, "glassfloor_RCD.png")	
	
	register_asset("RCD_HEADER_FLOORS.png", new/icon('icons/turf/floors.dmi', "floor" ))
	send_asset(client, "RCD_HEADER_FLOORS.png")	
	
	
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
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='floor_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]&emsp;</a></td></tr>"		
	
	
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
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='plating_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]&emsp;</a></td></tr>"		


/datum/rcd_grouped_schematic/rfloor
	name="reinforced floor"
	cost=1
	
/datum/rcd_grouped_schematic/rfloor/build(var/atom/A, var/mob/user)
	var/turf/T=get_turf(A)
	var/cc=cost
	if(T.type==/turf/simulated/floor/engine)
		to_chat(user, "The floor is already a [name]!")
		return 0
	if(istype(T,/turf/space))
		cc=cost+1
	else
		if(T.type==/turf/simulated/floor || T.type==/turf/simulated/floor/plating )
			cc=cost
		
	if(!cc)
		to_chat(user, "You connot build this floor here!")
		return 0
		
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
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='rfloor_RCD.png'></a></td><td>[a][cost+1]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'><img src='plating_RCD.png'></a></td></tr>"		
	

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
	return "<tr class='[RCD.selected_schem==src ? "schem_selected" : "schem"]'><td>[a]<img src='glassfloor_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]0</a></td><td>[a]&emsp;</a></td></tr>"		



/datum/rcd_scematic_grouping/build_windows
	name="windows"
	headerimage="RCD_HEADER_WINDOWS.png"
	
/datum/rcd_scematic_grouping/build_windows/generate_html()
	var/dat=""
	
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return ""
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	
	var/build_n=RCD.settings["window_north"]
	var/build_s=RCD.settings["window_south"]
	var/build_e=RCD.settings["window_east"]
	var/build_w=RCD.settings["window_west"]
	var/build_c=RCD.settings["window_center"]
	var/skipgrile=RCD.settings["window_nogrille"]
	
	dat+="<table><tr><td> <span class='[skipgrile ? "schem" : "schem_selected"]'><a href='?src=\ref[linked_rcd.interface];set_arg=window_nogrille;value_toggle=yes;'>place grille</a></span></td>"
	
	dat+={"<td> <table class='clickabletable' >
	<tr><td></td><td style='width:3em;height:1em;' class='[build_n ? "schem_selected" : "schem" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=window_north;value_toggle=yes;'/></td><td></td></tr>
	<tr><td class='[build_w ? "schem_selected" : "schem" ]' style='width:1em;height:3em;'><a href='?src=\ref[linked_rcd.interface];set_arg=window_west;value_toggle=yes;'/></td><td style='width:3em;height:3em;' class='[build_c ? "schem_selected" : "schem" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=window_center;value_toggle=yes;'/></td><td style='width:1em;height:3em;' class='[build_e ? "schem_selected" : "schem" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=window_east;value_toggle=yes;'/></td></tr>
	<tr><td></td><td style='width:3em;height:1em;' class='[build_s ? "schem_selected" : "schem" ]'><a href='?src=\ref[linked_rcd.interface];set_arg=window_south;value_toggle=yes;'/></td><td></td></tr>
	</table> </td>"}

	dat+="</tr></table>"
	
	dat+="<table class='clickabletable'><tr><th>material</th><th>matter cost</th><th>construction time</th><th>upgradable from</th></tr>"
	for(var/datum/rcd_grouped_schematic/schem in schematics)
		dat+=schem.generate_html()
	dat+="</table>"
	return dat
	
/datum/rcd_scematic_grouping/build_windows/switch_to()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	RCD.selected_schem = schematics[1]		


/datum/rcd_scematic_grouping/build_windows/send_assets(var/client/client)
	register_asset("floor_RCD.png", new/icon('icons/turf/floors.dmi', "floor" ))
	send_asset(client, "floor_RCD.png")	
	
	register_asset("glass_RCD.png", new/icon('icons/obj/stacks_sheets.dmi', "sheet-glass" ))
	send_asset(client, "glass_RCD.png")	
	
	register_asset("rglass_RCD.png", new/icon('icons/obj/stacks_sheets.dmi', "sheet-rglass" ))
	send_asset(client, "rglass_RCD.png")	
	
	register_asset("pglass_RCD.png", new/icon('icons/obj/stacks_sheets.dmi', "sheet-plasmaglass" ))
	send_asset(client, "pglass_RCD.png")	
	
	register_asset("rpglass_RCD.png", new/icon('icons/obj/stacks_sheets.dmi', "sheet-plasmarglass" ))
	send_asset(client, "rpglass_RCD.png")	
	
	register_asset("RCD_HEADER_WINDOWS.png", new/icon('icons/obj/window_grille_spawner.dmi', "rwindowgrille" ))
	send_asset(client, "RCD_HEADER_WINDOWS.png")	
	
	

/datum/rcd_grouped_schematic/glass
	var/obj/structure/window/windowtype=null
	var/obj/structure/window/full/fullwindowtype=null
	var/list/canupgrade_windows=null
	var/list/canupgrade_fullwindows=null
	var/upgrade_refund=0
	var/construct_delay = 2 SECONDS

/datum/rcd_grouped_schematic/glass/New()
	..()
	canupgrade_windows=new()
	canupgrade_fullwindows=new()
	

/datum/rcd_grouped_schematic/glass/build(var/atom/A, var/mob/user)
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	
	var/build_n=RCD.settings["window_north"]
	var/build_s=RCD.settings["window_south"]
	var/build_e=RCD.settings["window_east"]
	var/build_w=RCD.settings["window_west"]
	var/build_c=RCD.settings["window_center"] //store window directions.
	var/skipgrile=RCD.settings["window_nogrille"]
	
	var/nowindows=!(build_n || build_s || build_e || build_w)
	if(nowindows && skipgrile)
		return 0
	
	var/cc=0
	var/refund=0
	var/turf/T=get_turf(A)
	if(!T)
		return 0
	if(istype(T,/turf/simulated/floor))
		cc=(nowindows ? 1 : cost)
	if(istype(T,/turf/space))
		cc=(nowindows ? 1 : cost)+1
	
	if(!cc)
		to_chat(user, "You can't place a [name] here!")
		return 0		
	if(linked_rcd.get_energy(user) < cc)
		to_chat(user, "The [linked_rcd] doesn't have enough charge to build a [name]!")
		return 0			
	if(!linked_rcd.delay(user, A, construct_delay))
		return 0
		
	playsound(linked_rcd, 'sound/items/Deconstruct.ogg', 50, 1)
	
	if(istype(T,/turf/space))
		T.ChangeTurf(/turf/simulated/floor)
	if( (!locate(/obj/structure/grille) in T.contents) && !skipgrile)
		new /obj/structure/grille(T)
	if(build_n)
		var/shouldbuild=TRUE
		for(var/obj/structure/window/R in T.contents)
			if(R.dir == NORTH && R.type==windowtype)
				shouldbuild=FALSE
				break
		if(shouldbuild)
			for(var/obj/structure/window/R in T.contents) // "upgrade" windows by destroying the old one. not elegant, but it works.
				if(R.dir == NORTH && R.type in canupgrade_windows)
					qdel(R)
					refund=upgrade_refund
					break
			var/obj/structure/window/nwin=new windowtype(T)
			nwin.change_dir(NORTH)
			nwin.update_nearby_tiles()
	if(build_s)
		var/shouldbuild=TRUE
		for(var/obj/structure/window/R in T.contents)
			if(R.dir == SOUTH && R.type==windowtype)
				shouldbuild=FALSE
				break
		if(shouldbuild)
			for(var/obj/structure/window/R in T.contents)
				if(R.dir == SOUTH && R.type in canupgrade_windows)
					qdel(R)
					refund=upgrade_refund
					break
			var/obj/structure/window/nwin=new windowtype(T)
			nwin.change_dir(SOUTH)
			nwin.update_nearby_tiles()
	if(build_e)
		var/shouldbuild=TRUE
		for(var/obj/structure/window/R in T.contents)
			if(R.dir == EAST && R.type==windowtype)
				shouldbuild=FALSE
				break
		if(shouldbuild)
			for(var/obj/structure/window/R in T.contents)
				if(R.dir == EAST && R.type in canupgrade_windows)
					qdel(R)
					refund=upgrade_refund
					break
			var/obj/structure/window/nwin=new windowtype(T)
			nwin.change_dir(EAST)
			nwin.update_nearby_tiles()
	if(build_w)
		var/shouldbuild=TRUE
		for(var/obj/structure/window/R in T.contents)
			if(R.dir == WEST && R.type==windowtype)
				shouldbuild=FALSE
				break
		if(shouldbuild)
			for(var/obj/structure/window/R in T.contents)
				if(R.dir == WEST && R.type in canupgrade_windows)
					qdel(R)
					refund=upgrade_refund
					break
			var/obj/structure/window/nwin=new windowtype(T)
			nwin.change_dir(WEST)
			nwin.update_nearby_tiles()
	if(build_c)
		if(!locate(fullwindowtype) in T.contents)
			var/obj/structure/window/nwin=new fullwindowtype(T)
			nwin.update_nearby_tiles()	
	return cc-refund


/datum/rcd_grouped_schematic/glass/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name]'>"
	return "<tr class='[RCD.selected_schem==src? "schem_selected" : "schem"]'><td>[a][name]</a></td><td>[a][cost]</a></td><td>[a]2</a></td><td>[a]floor</a></td></tr>"
	
/datum/rcd_grouped_schematic/glass/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name]'>"
	return "<tr class='[RCD.selected_schem==src? "schem_selected" : "schem"]'><td>[a]<img src='glass_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'></a></td></tr>"


/datum/rcd_grouped_schematic/glass/weak
	name="window"
	cost=1
	windowtype=/obj/structure/window
	fullwindowtype=/obj/structure/window/full


/datum/rcd_grouped_schematic/glass/reinforced
	name="reinforced window"
	cost=2
	windowtype=/obj/structure/window/reinforced
	fullwindowtype=/obj/structure/window/full/reinforced
	upgrade_refund=1
	
/datum/rcd_grouped_schematic/glass/reinforced/New()
	..()
	canupgrade_windows+=/obj/structure/window
	canupgrade_fullwindows+=/obj/structure/window/full

/datum/rcd_grouped_schematic/glass/reinforced/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name]'>"
	return "<tr class='[RCD.selected_schem==src? "schem_selected" : "schem"]'><td>[a]<img src='rglass_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'><img src='glass_RCD.png'></a></td></tr>"
	
/datum/rcd_grouped_schematic/glass/plasma
	name="plasma glass window"
	cost=6
	windowtype=/obj/structure/window/plasma
	fullwindowtype=/obj/structure/window/full/plasma
	upgrade_refund=1
	construct_delay= 3 SECONDS

/datum/rcd_grouped_schematic/glass/plasma/New()
	..()
	canupgrade_windows+=/obj/structure/window
	canupgrade_fullwindows+=/obj/structure/window/full


/datum/rcd_grouped_schematic/glass/plasma/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name]'>"
	return "<tr class='[RCD.selected_schem==src? "schem_selected" : "schem"]'><td>[a]<img src='pglass_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'><img src='glass_RCD.png'></a></td></tr>"
	

/datum/rcd_grouped_schematic/glass/rplas
	name="reinforced plasma glass window"
	cost=7
	windowtype=/obj/structure/window/reinforced/plasma
	fullwindowtype=/obj/structure/window/full/reinforced/plasma
	upgrade_refund=2 //probably explotable with regular windows in some way, but i don't think it's going to matter
	construct_delay= 4 SECONDS

/datum/rcd_grouped_schematic/glass/rplas/New()
	..()
	canupgrade_windows+=/obj/structure/window/reinforced
	canupgrade_fullwindows+=/obj/structure/window/full/reinforced

/datum/rcd_grouped_schematic/glass/rplas/generate_html()
	if(!istype(linked_rcd,/obj/item/device/rcd/matter/engineering))
		return
	var/obj/item/device/rcd/matter/engineering/RCD=linked_rcd
	var/a="<a href='?src=\ref[linked_rcd.interface];set_schematic=[name]'>"
	return "<tr class='[RCD.selected_schem==src? "schem_selected" : "schem"]'><td>[a]<img src='rpglass_RCD.png'></a></td><td>[a][cost]</a></td><td>[a]2</a></td><td>[a]<img src='floor_RCD.png'><img src='rglass_RCD.png'></a></td></tr>"










