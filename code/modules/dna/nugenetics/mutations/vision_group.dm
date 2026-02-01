/datum/gene/vision
	name="Ocular Functions"
	size=60
	group=GENE_GROUP_VISION


/datum/mutation/blindness
	name="Blindness"
	minlength=4
	maxlength=6
	forgiveness=3
	gene_group=GENE_GROUP_VISION
	inverted_activation=TRUE
	msg_activate="<span class='warning'>You can't seem to see anything.</span>"
	msg_deactivate="<span class='warning'>You can see again.</span>"
	sdisability=BLIND

/datum/mutation/xray
	name="X-Ray Vision"
	minlength=5
	maxlength=7
	gene_group=GENE_GROUP_VISION
	msg_activate="<span class='warning'>The walls suddenly disappear.</span>"
	msg_deactivate="<span class='warning'>The walls suddenly appear.</span>"
	mutation=M_XRAY

/datum/mutation/farsight
	name="Farsight"
	minlength=4
	maxlength=6
	gene_group=GENE_GROUP_VISION
	msg_activate="<span class='warning'>Your eyes focus.</span>"
	msg_deactivate="<span class='warning'>Your eyes return to normal.</span>"
	spelltype = /spell/targeted/farsight

/datum/mutation/nearsightedness
	name="Nearsightedness"
	minlength=3
	maxlength=5
	forgiveness=2
	gene_group=GENE_GROUP_VISION
	inverted_activation=TRUE
	msg_activate="<span class='warning'>Your eyes feel weird...</span>"
	msg_deactivate="<span class='warning'>Your eyes no longer feel weird.</span>"
	disability=NEARSIGHTED

/datum/mutation/nearsightedness/on_activation(var/datum/gene/G,var/mob/M)
	..()
	M.nearsightedness += 3

/datum/mutation/nearsightedness/on_deactivation(var/datum/gene/G,var/mob/M)
	..()
	M.nearsightedness -= 3


#define NOIR_ANIM_TIME 170
/datum/mutation/noir
	name="Noir"
	minlength=3
	maxlength=4
	gene_group=GENE_GROUP_VISION
	inverted_activation=TRUE
	msg_activate="<span class='notice'>The vibrant colors of the station hit your eyes for the last time before fading into a more appropriate tone. Something's off about this place, but you can't quite put your finger on it. You're compelled to check out the bar, maybe get to the bottom of what's going on in this godforsaken place.</span>"
	msg_deactivate="<span class='warning'>You now feel soft-boiled.</span>"
	mutation=M_NOIR

/datum/mutation/noir/on_activation(var/datum/gene/G,var/mob/M)
	..()
	M.update_colour(NOIR_ANIM_TIME)
	if(M.client) // wow it's almost like non-client mobs can get mutations!
		M << sound('sound/misc/noirdarkcoffee.ogg')

/datum/mutation/noir/on_deactivation(var/datum/gene/G,var/mob/M)
	..()
	M.update_colour(NOIR_ANIM_TIME)
	if(M.client)
		M.disable_noir()


