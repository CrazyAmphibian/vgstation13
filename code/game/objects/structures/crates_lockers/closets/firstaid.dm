/obj/structure/closet/jungle_first_aid
	name = "First Aid Cabinet"
	desc = "Filled with medicine for extreme ouchies and boo-boos."
	icon_state = "firstaid"
	icon_closed = "firstaid"
	icon_opened = "firstaidopen"
	req_access = list(access_medical)


/obj/structure/closet/jungle_first_aid/atoms_to_spawn()
	return list(
		/obj/item/weapon/storage/firstaid/regular = 3,
		/obj/item/weapon/storage/firstaid/fire = 1,
		/obj/item/weapon/storage/firstaid/toxin = 2,
		/obj/item/weapon/storage/firstaid/vox = 1,
		
	)