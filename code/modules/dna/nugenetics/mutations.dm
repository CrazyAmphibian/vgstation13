var/global/master_mutation_data=list()

/datum/mutation
	var/name=""
	var/minlength=3 //minimum number of amino acids that the mutation requires
	var/maxlength=5 //and the maximum.
	var/forgiveness=1 //how many amino acids are allowed to be wrong before the effect occurs.
	var/list/amino_string=null //what amino acids are required to activate it as a list
	var/length=0
	var/gene_group=GENE_GROUP_IGNORE //lumps similar mutations together
	var/inverted_activation=FALSE //if true, the mutation string is inserted into the gene when it generates, and will trigger its effect if not valid. useful for disabilities and punishing genetic damage.
	var/msg_activate=null
	var/msg_deactivate=null
	var/disability=null
	var/sdisability=null //mob.sdisabilities
	var/mutation=null //mob.mutations
	var/spell/spelltype=null //mob.spell_list

/datum/mutation/New()
	var/chosenlength=rand(minlength,maxlength)
	amino_string=list()
	length=chosenlength
	for(var/i=1,i<=chosenlength,i++)
		amino_string+=pick(standard_amino_acids)
	

/datum/mutation/proc/is_active(var/datum/gene/G)
	for(var/list/S in G.get_active_amino_strings()) //for each active amino string in the gene...
		S.cut(S.len,S.len)
		S.cut(1,1) //remove the start and stop codons
		var/offset=0
		while(offset<S.len-amino_string.len) // make sure we have enough space. ABCD -> AB BC CD / ABC BCD
			var/counter=0
			var/mistakes=0
			while(counter<amino_string.len)
				if (S[counter+offset+1]!=amino_string[counter+1])
					mistakes++
				if(mistakes>forgiveness)
					break	
				counter++
				if(counter==amino_string.len)
					return !inverted_activation
			offset++
		
	return inverted_activation


/datum/mutation/proc/on_activation(var/datum/gene/G,var/mob/M)
	if(msg_activate)
		to_chat(M, msg_activate)
	if(disability)
		M.disabilities |= disability
	if(sdisability)
		M.sdisabilities |= sdisability
	if(mutation)
		M.mutations.Add(mutation)
	if(spelltype)
		M.add_spell(new spelltype, "genetic_spell_ready", /obj/abstract/screen/movable/spell_master/genetic)

/datum/mutation/proc/on_deactivation(var/datum/gene/G,var/mob/M)
	if(msg_deactivate)
		to_chat(M, msg_deactivate)
	if(disability)
		M.disabilities &= ~disability
	if(sdisability)
		M.sdisabilities &= ~sdisability
	if(mutation)	
		M.mutations.Remove(mutation)
	if(spelltype)
		var/spell/S=locate(spelltype) in M.spell_list
		if(S)
			M.remove_spell(S)
			qdel(S)
	

//for filling genes with useless genetic code.
/datum/mutation/filler
	minlength=0
	maxlength=0

/datum/mutation/filler/New(var/desired_len=0)	
	if(desired_len<1) //if there's no space, then don't generate anything. we'll then only add the start+stop or just stop codons if we're cramped for space.
		length=desired_len
		amino_string=list()
		return
	minlength = desired_len
	maxlength = desired_len
	return ..()

