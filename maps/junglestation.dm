#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Junglestation
//**************************************************************

/datum/map/active
	nameShort = "Jungle"
	nameLong = "Jungle Station"
	map_dir = "junglestation"

	zMainStation = 1
	zAdditionalStationZlevel = 2
	zCentcomm = 3
	zAsteroid = 4
	zDerelict = 5

	zDeepSpace = -1
	zTCommSat = -1

	zLevels = list(
		/datum/zLevel/junglesurface,
		/datum/zLevel/jungleunderground,
		/datum/zLevel/centcomm,
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "derelict" ;
			},
		)
	enabled_jobs = list(/datum/job/trader)
	event_blacklist = list(/datum/event/radiation_storm,/datum/event/carp_migration,/datum/event/rogue_drone,/datum/event/immovable_rod,
						/datum/event/meteor_wave,/datum/event/meteor_shower,/datum/event/thing_storm/meaty_gore,/datum/event/thing_storm/blob_shower,
						/datum/event/thing_storm/blob_storm,/datum/event/thing_storm/fireworks)
	load_map_elements = list(
	)

	skip_hobo_shack=TRUE
	can_enlarge=FALSE

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 182
	center_y = 163

/datum/map/active/New()
	..()
	world.name = "NT Colony Gamma-8"
	station_name="NT Colony Gamma-8"
	daynight_z_lvls=list(1)

/****************************
**	Day and Night Lighting **
**	See: daynightcycle.dm  **
****************************/

/datum/subsystem/daynightcycle
	var/solartime=0 //start at 0. set not like that for debugging. or manually set next_firetime with varedit.

/datum/subsystem/daynightcycle/process_lighting()
	flags&=(0^SS_FIRE_IN_LOBBY) //we don't want this one firing in lobby constantly, as we've tweaked the lighting to be just right on startup. we still want it to fire once though.
	
	// YCbCr is a superior colorspace. fight me.
	var/luma=0.0
	var/chroma_b=0.0
	var/chroma_r=0.0

	//orbit 1: fast, red dwarf:: roughly 33 minutes, red-orange colors.
	//this is the primary star we are orbiting, so it's fairly simple
	var/power=((sin(solartime*32.4-12.5)+1)/2)**2.25
	//what the math is: makes a sine function that goes from 0-1 instead of -1 to 1. avoid max() because that creates hard cutoffs which don't look too good. we take it to the 2.25th power to make the transitions between day and night sharper, and to reduce the overall amount of daylight since we have 2 stars.
	luma+=0.64*power //red dwarves are weak stars.
	chroma_r+=0.70*power //they also would give off fuckhuge solar flares.
	chroma_b-=0.40*power // but that's a problem for silicons to deal with.
	
	//long-wave atmospheric absorption when the star is at a sharper angle (this is why sunsets are red)
	chroma_r+=0.2*(1-power)*power
	chroma_b-=0.3*(1-power)*power
	//what the math is: inverts the power first, because less power also means a sharper angle. then, multiply by power again, because we should only adjust it by the amount of light being given off.

	//orbit 2: slow, blue giant. more distant, but more power. i hope you brought sunscreen.
	power=((sin(solartime*11.023+6.918)+1)/2)**2.25 // about 117 minutes. a bit of offset, too.
	luma+=power
	chroma_r-=0.20*power
	chroma_b+=0.70*power

	chroma_r+=0.2*(1-power)*power
	chroma_b-=0.3*(1-power)*power


	luma+=0.02 // minimum light level so it's not pitch black everywhere. atmospheric scattering would cause this.
	chroma_b-=0.1
	chroma_r+=0.04 // chroma shift so light appears a bit green to account for shortwave atmospheric absorption.


	//all numbers above this are completely arbitrary and are there to insure that the day/night cycle looks as cool as possible, meaning we have a lot of color variety and a satisfying progression between light and dark, and that it changes not too fast and not too slow. change them however you want.
	
	luma=luma**(1/2.2) //apply standard gamma correction

	//constants defined by ITU-R BT.2020
	var/r = luma + 1.659 * chroma_r
	var/g = luma - (0.396 * chroma_b) - (0.775 * chroma_r)
	var/b = luma + 2.034 * chroma_b

	/*
	why do this? because it makes brighter colors look better.
	Also, because it simulates bright light desaturating colors
	muh immulsions.
	*/
	for(var/n=0,n<3,n++) //3 smoothing passes seems good. This isn't particularly heavy math, anyways.
		if (r>1)
			var/redist=(r-1)
			redist*=0.1 //increasing this will make bright colors more washed out, lowering it makes the brightness more selective towards each color channel. that 255, 0, 0 light goes hard.
			r-=2*redist/3
			g+=redist/3
			b+=redist/3
		if (g>1)
			var/redist=(g-1)
			redist*=0.1
			g-=2*redist/3
			r+=redist/3
			b+=redist/3
		if (b>1)
			var/redist=(b-1)
			redist*=0.1
			b-=2*redist/3
			g+=redist/3
			r+=redist/3


	//clip to bounds
	r=min(r,1)
	g=min(g,1)
	b=min(b,1)

	//convert from 0-1 to 0-255
	r=floor(r*255)
	g=floor(g*255)
	b=floor(b*255)


	next_light_power=luma*7.5

	message_admins("Jungle day/night system beginning new phase at [world.time], cycle #[solartime], with light stats of [luma] [chroma_b] [chroma_r] -> [next_light_power] [r],[g],[b]")

	current_timeOfDay=rgb(r,g,b)


	next_firetime=world.time + 4 MINUTES //station is too big to tick at 2 minutes. not without severe sever raep, at least.
	solartime++

/datum/subsystem/daynightcycle/play_globalsound()
	return

/datum/subsystem/foliage_regrow_junga
	flags=0


////////////////////////////////////////////////////////////////
#include "junglestation.dmm"
#endif
