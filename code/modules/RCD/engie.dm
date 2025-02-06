/obj/item/device/rcd/matter/engineering
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_airlock,
	/datum/rcd_schematic/con_window,
	)
	var/current_menu="deconstruct"
	var/list/schem_groups=null
	var/list/settings //for stuff like window directions and construction options.
	var/datum/rcd_grouped_schematic/selected_schem=null


/obj/item/device/rcd/matter/engineering/New()
	. = ..()
	rcd_list += src
	schem_groups=new()
	settings=new()
	
	var/datum/rcd_scematic_grouping/destroy/dest_g = new(src)
	dest_g.schematics+= new /datum/rcd_grouped_schematic/destroy_all(src)
	
	var/datum/rcd_scematic_grouping/build_wall/wall_g = new(src)
	wall_g.schematics+= new /datum/rcd_grouped_schematic/normalwall(src)
	wall_g.schematics+= new /datum/rcd_grouped_schematic/woodwall(src)
	
	var/datum/rcd_scematic_grouping/build_floors/floor_g = new(src)
	floor_g.schematics+= new /datum/rcd_grouped_schematic/floor(src)
	floor_g.schematics+= new /datum/rcd_grouped_schematic/plating(src)
	floor_g.schematics+= new /datum/rcd_grouped_schematic/glassfloor(src)
	
	var/datum/rcd_scematic_grouping/build_windows/window_g = new(src)
	window_g.schematics+= new /datum/rcd_grouped_schematic/glass/weak(src)
	window_g.schematics+= new /datum/rcd_grouped_schematic/glass/reinforced(src)
	
	var/datum/rcd_scematic_grouping/build_airlock/airlock_g=new(src)
	airlock_g.schematics+= new /datum/rcd_grouped_schematic/airlock(src)
	
	
	schem_groups+=dest_g
	schem_groups+=wall_g
	schem_groups+=floor_g
	schem_groups+=airlock_g
	schem_groups+=window_g
	
	current_menu=schem_groups[1].name
	schem_groups[1].switch_to()
	

/obj/item/device/rcd/matter/engineering/Destroy()
	. = ..()
	rcd_list -= src

/obj/item/device/rcd/matter/engineering/afterattack(var/atom/A, var/mob/user)
	if(malf_rcd_disable)
		return

	return ..()
	
/obj/item/device/rcd/matter/engineering/attack_self(var/mob/user)
	rebuild_ui()
	interface.show(user)	
	
	for(var/client/client in interface.clients)
		for(var/datum/rcd_scematic_grouping/schemgroup in schem_groups)
			schemgroup.send_assets(client)
			for(var/datum/rcd_grouped_schematic/sch)
				sch.send_assets(client)
	interface.hide(user)
	interface.show(user)


/obj/item/device/rcd/matter/engineering/Topic(var/href, var/list/href_list)
	for(var/i in href_list)
		world.log << "[i] = [href_list[i]]"
		
	if(href_list["set_group"])
		for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
			if(schem_group.name==href_list["set_group"])
				current_menu=href_list["set_group"]
				schem_group.switch_to()
				do_spark()
				rebuild_ui()
				return
	if(href_list["set_schematic"])
		var/datum/rcd_scematic_grouping/group
		for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
			if(schem_group.name==current_menu)
				group=schem_group
				break
		if(group)
			for(var/datum/rcd_grouped_schematic/schm in group.schematics)
				if(schm.name==href_list["set_schematic"])
					selected_schem=schm
					do_spark()
					rebuild_ui()
					break
		return			
	if(href_list["set_arg"])
		if(href_list["value_togglelist"])
			var/val =  href_list["value_isnum"]=="yes" ? text2num(href_list["value"]) : href_list["value"]
			var/found=FALSE
			for(var/n in settings[href_list["set_arg"]])
				if(n==val)
					found=TRUE
					break
			if( found )
				settings[href_list["set_arg"]] -= val
			else
				settings[href_list["set_arg"]] += val
		else if(href_list["value_resetlist"])
			settings[href_list["set_arg"]]=new /list()
		else if(href_list["value_toggle"] )
			settings[href_list["set_arg"]] = ! settings[href_list["set_arg"]]
		else if (href_list["value_input"])
			var/tx=""
			for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
				if(schem_group.name==current_menu)
					tx=schem_group.selectiondialogue
					break
			settings[href_list["set_arg"]] = input(usr, tx, src, "[selected_schem?.name]")
		else
			settings[href_list["set_arg"]] = href_list["value_isnum"]=="yes" ? text2num(href_list["value"]) : href_list["value"]
		rebuild_ui()
		return
		
	return

/obj/item/device/rcd/matter/engineering/rebuild_ui()
	var/dat=""
	
	dat+="Compressed Matter: [matter]/[max_matter]<hr>"
	
	//that's right, you can embed a stylesheet in the html body, and you better believe i'm going to do this instead of setting up a whole new file for like 2 rules.
	dat+={"<style> 
	.grouplisting{
	text-align:center;
	font-size:100%;
	}
	.grouplisting img {
	width:64px;
	height:64px;
	}
	
	.grouplisting a{
	width:100%;
	height:100%;
	display:block;
	background:revert;
	}
	
	.clickabletable td{
		text-align:center;
	}
	
	.clickabletable a{
		width:100%;
		height:100%;
		display:block;
	}
	
	img, .clickabletable img, .grouplisting img {
		border:none;
		background:none;
		image-rendering:pixelated;
	}
	
	</style>"}
	
	dat+="<table class='grouplisting'><tr>"
	for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
		dat+="<td class='[schem_group.name==current_menu ? "schem_selected" : "schem" ]'><a href='?src=\ref[interface];set_group=[schem_group.name]'><img src='[schem_group.headerimage]'><br>[schem_group.name]</a></td>"
	dat+="</tr></table><hr>"
	
	
	for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
		if(schem_group.name==current_menu)
			var/t=schem_group.generate_html()
			dat+=t
			break
			
	
	interface.updateLayout(dat)

/obj/item/device/rcd/matter/engineering/afterattack(var/atom/A, var/mob/user)
	if(!selected_schem)
		return 1
	if( !(user.Adjacent(A) && A.Adjacent(user)) )
		return 1
	if(get_dist(A, user) > 1)
		return 1

	var/c=selected_schem.build(A,user)
	if(!c)
		to_chat(user, "<span class='warning'>\The [src]'s error light flickers.</span>")
	else
		use_energy(c, user)
		rebuild_ui()
	return 1
	

/obj/item/device/rcd/matter/engineering/suicide_act(var/mob/living/user)
	visible_message("<span class='danger'>[user] is using the deconstruct function on \the [src] on \himself! It looks like \he's trying to commit suicide!</span>")
	user.death(1)
	return SUICIDE_ACT_CUSTOM

/obj/item/device/rcd/matter/engineering/pre_loaded/New() //Comes with max energy
	..()
	matter = max_matter

/obj/item/device/rcd/borg/engineering
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_airlock/borg,
	/datum/rcd_schematic/con_window/borg,
	)

/obj/item/device/rcd/matter/engineering/pre_loaded/adv
	name = "advanced Rapid-Construction-Device (RCD)"
	icon_state = "arcd"
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_rfloors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_rwalls,
	/datum/rcd_schematic/con_airlock,
	/datum/rcd_schematic/con_window,
	)
	matter = 90
	max_matter = 90
	origin_tech = Tc_ENGINEERING + "=5;" + Tc_MATERIALS + "=4;" + Tc_PLASMATECH + "=4"
	mech_flags = MECH_SCAN_FAIL
	slimeadd_message = "You put the slime extract on the SRCTAG's compressed matter slot"
	slimes_accepted = SLIME_DARKPURPLE
	slimeadd_success_message = "It gains a distinct plasma pink hue"

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/New()
	..()
	for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
		if(istype(schem_group,/datum/rcd_scematic_grouping/build_wall) )
			schem_group.schematics+=new /datum/rcd_grouped_schematic/rwall(src)
		if(istype(schem_group,/datum/rcd_scematic_grouping/build_floors) )
			schem_group.schematics+= new/datum/rcd_grouped_schematic/rfloor(src)
	
/obj/item/device/rcd/matter/engineering/pre_loaded/adv/slime_act(primarytype, mob/user)
	. = ..()
	if(. && (slimes_accepted & primarytype))
		var/datum/rcd_schematic/con_pwindow/P = new(src)
		if(!schematics[P.category])
			schematics[P.category] = list()
		schematics[P.category] += P
		
		for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
			if(istype(schem_group,/datum/rcd_scematic_grouping/build_windows) )
				schem_group.schematics+=new /datum/rcd_grouped_schematic/glass/plasma(src)
				schem_group.schematics+=new /datum/rcd_grouped_schematic/glass/rplas(src)
		rebuild_ui()
			

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/delay(var/mob/user, var/atom/target, var/amount)
	return do_after(user, target, amount/2)

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/admin
	name = "experimental Rapid-Construction-Device (RCD)"
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_rfloors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_rwalls,
	/datum/rcd_schematic/con_airlock,
	/datum/rcd_schematic/con_window,
	/datum/rcd_schematic/con_pwindow,
	)
	has_slimes = SLIME_DARKPURPLE // just so this doesn't cause anything off

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/admin/afterattack(var/atom/A, var/mob/user)
	if(!user.check_rights(R_ADMIN))
		visible_message("\The [src] disappears into nothing.")
		qdel(src)
		return
	return ..()

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/admin/delay(var/mob/user, var/atom/target, var/amount)
	return TRUE
