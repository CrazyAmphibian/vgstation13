/*
===============================================
==vaults exclusive to junglestation's surface==
===============================================
*/
/datum/map_element/junglevault
	type_abbreviation = "JV"
	var/base_turf_type = /turf/unsimulated/floor/jungle/grass
	var/count=0 //how many are added to the list to pick from.

/datum/map_element/junglevault/initialize(list/objects)
	..(objects)
	existing_vaults.Add(src)

	var/zlevel_base_turf_type = get_base_turf(location.z)
	if(!zlevel_base_turf_type)
		zlevel_base_turf_type = /turf/space

	for(var/turf/new_turf in objects)
		if(new_turf.type == base_turf_type) //New turf is vault's base turf
			if(new_turf.type != zlevel_base_turf_type) //And vault's base turf differs from zlevel's base turf
				new_turf.ChangeTurf(zlevel_base_turf_type)

		new_turf.turf_flags |= NO_MINIMAP //Makes the spawned turfs invisible on minimaps

	
/datum/map_element/junglevault/test
	file_path = "maps/randomvaults/jungle/test.dmm"
	can_rotate=FALSE
	count=10
/datum/map_element/junglevault/test/load(var/vault_x, var/vault_y, var/vault_z, var/vault_rotate, var/overwrites)
	world.log << "test vault loaded at [vault_x], [vault_y], [vault_z]."
	message_admins("test vault loaded at [vault_x], [vault_y], [vault_z].")
	return ..()




	