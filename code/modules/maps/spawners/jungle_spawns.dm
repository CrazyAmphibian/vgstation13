//things that try to kill you.
var/list/junglemobs_hostile=list(
	/mob/living/simple_animal/hostile/giant_spider/jungle,
	/mob/living/simple_animal/hostile/bear/dinosaur, //duplicated entries for more commonality.
	/mob/living/simple_animal/hostile/bear/dinosaur,
	/mob/living/simple_animal/hostile/bear/panther,
	/mob/living/simple_animal/hostile/bear/panther,
	/mob/living/simple_animal/hostile/bear/brownbear/jungle,
)


//things that won't attack you
var/list/junglemobs_passive=list(
/mob/living/simple_animal/hostile/lizard/frog,
/mob/living/simple_animal/hostile/lizard/frog/poison,
/mob/living/simple_animal/parrot/jungle,
/mob/living/carbon/monkey,
)
//they don't kill you, but also are less frequent. capy bappies are here because the pacify aura is quite strong and funny. so we limit that, because we HATE fun.
var/list/junglemobs_passive_rare=list(
/mob/living/simple_animal/capybara/jungle,
)

//any wildlife, be it fren-shaped or not.
/obj/abstract/map/spawner/jungle_any
	icon_state="jungle_mob_random"

/obj/abstract/map/spawner/jungle_any/New()
	var/rng=rand()
	if(rng < .65) //65% chance of friendly mobs
		amount=rand(3,6)
		if(prob(20)) //20% chance for rare (13% overall)
			amount = floor((1.0+amount)/3.0) //between 1 and 2 of em
			to_spawn = pick(junglemobs_passive_rare)
		else
			var/list/pickfrom=list()
			pickfrom+=junglemobs_dangerous
			pickfrom+=junglemobs_passive
			to_spawn = pick(pickfrom)
	else
		amount=rand(2,5)
		to_spawn = pick(junglemobs_hostile)
	..()


//random peaceful wildlife. :)
/obj/abstract/map/spawner/jungle_fren
	icon_state="jungle_mob_fren"
	
/obj/abstract/map/spawner/jungle_fren/New()
	amount=rand(3,6)
	if(prob(20))
		to_spawn = pick(junglemobs_passive_rare)
		amount = floor((1.0+amount)/3.0) //between 1 and 2 of em
	else
		to_spawn = pick(junglemobs_passive)
	..()


//random hostile wildlife. >:(
/obj/abstract/map/spawner/jungle_hostile
	icon_state="jungle_mob_hostile"
	
/obj/abstract/map/spawner/jungle_hostile/New()
	amount=rand(3,6)
	to_spawn = pick(junglemobs_hostile)
	..()
