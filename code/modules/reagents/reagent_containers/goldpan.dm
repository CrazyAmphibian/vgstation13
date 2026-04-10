// gold pans. not nescicarily made of gold.
// used to sift useful materials from sand.

/obj/item/weapon/reagent_containers/glass/goldpan
	name = "gold pan"
	desc = "separates valuable minerals from fine rock using water."
	w_class = W_CLASS_SMALL
	volume = 25
	icon = 'icons/obj/chemical.dmi'
	icon_state = "goldpan"
	health=null
	breakable_flags=0
	var/pantime=4.0 SECONDS
	var/panning=FALSE
	var/heldsand=0
	var/maxsand=10

/obj/item/weapon/reagent_containers/glass/goldpan/New()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/goldpan/is_open_container()
	return TRUE

/obj/item/weapon/reagent_containers/glass/goldpan/fits_in_iv_drip()
	return FALSE
	
/obj/item/weapon/reagent_containers/glass/goldpan/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/S=I
		var/tadd=min(maxsand-heldsand,S.amount)
		S.use(tadd)
		heldsand+=tadd
		if(tadd)
			to_chat(user,"<span class='notice'>You add [tadd] clumps of [S] to \the [src].</span>")
		else
			to_chat(user,"<span class='notice'>\The [src] cannot fit any more [S]!</span>")
		return TRUE
	return ..()

/obj/item/weapon/reagent_containers/glass/goldpan/examine(var/mob/user)
	.=..()
	if(heldsand>0.5*maxsand)
		to_chat(user,"<span class='notice'>It's mostly filled with sand.</span>")
	else if(heldsand)
		to_chat(user,"<span class='notice'>There is some sand in it.</span>")
	else
		to_chat(user,"<span class='notice'>There is no sand in it.</span>")

/obj/item/weapon/reagent_containers/glass/goldpan/attack_self(var/mob/living/user)
	var/drops=alist(
		/obj/item/stack/ore/iron = 10,
		/obj/item/stack/ore/silver = 5,
		/obj/item/stack/ore/gold = 4,
		/obj/item/stack/ore/uranium = 4,
	)
	if(!panning)
		if(!heldsand)
			to_chat(user,"<span class='notice'>There's no sand to pan with!</span>")
			return FALSE
		if(reagents.total_volume<2)
			to_chat(user,"<span class='notice'>There's no water to pan with!</span>")
			return FALSE
		panning=TRUE
		to_chat(user,"<span class='notice'>You sift \the [src] around.</span>")
		var/foundstuff=FALSE
		if(do_after(user,src,pantime))
			while(heldsand && reagents.total_volume>=2)
				if(0.87055<user.lucky_prob_rand()) //12.9% chance at base, made it so there's a roughly 50% chance of 5 sand dropping a single ore.
					var/path=pickweight(drops)
					new path(src.loc.loc,1)
					foundstuff=TRUE
				heldsand--
				reagents.remove_any(2)
		if(foundstuff)
			to_chat(user,"<span class='notice'>Some minerals fall out of suspension...</span>")
		else
			to_chat(user,"<span class='notice'>The sand leaves nothing behind...</span>")
		panning=FALSE
		return TRUE


/obj/item/weapon/reagent_containers/glass/goldpan/wood
	name = "wooden gold pan"
	color= "#777700"
	w_type=RECYK_WOOD

/obj/item/weapon/reagent_containers/glass/goldpan/metal
	name = "metal gold pan"
	color= "#777777"
	w_type=RECYK_METAL

/obj/item/weapon/reagent_containers/glass/goldpan/plastic
	name = "plastic gold pan"
	color= "#777777"
	w_type=RECYK_PLASTIC

