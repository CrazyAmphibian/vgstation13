
/proc/setupgenetics()

	for(var/type in typesof(/datum/amino_acid)) //setup amino acids first
		var/datum/amino_acid/AA=new type()
		if(!amino_encodings[amino_id])
			amino_encodings[amino_id]=list()
		amino_encodings[amino_id]+=AA.encodings
		if(!(AA.amino_id in all_amino_acids))
			all_amino_acids+=AA.amino_id
		
		all_amino_encodings+=AA.encodings
		if(AA.position==AMINO_POSITION_START)
			starter_amino_encodings+=AA.encodings
		else if(AA.position==AMINO_POSITION_END)
			ending_amino_encodings+=AA.encodings
		else
			if(!(AA.amino_id in standard_amino_acids))
				standard_amino_acids+=AA.amino_id
			standard_amino_encodings+=AA.encodings

	for(var/type in typesof(/datum/mutation)) //then mutations
		if(type!=/datum/mutation && type!=/datum/mutation/filler)
			master_mutation_data += new type()
	for(var/type in typesof(/datum/geneblock)) //then geneblocks
		if(type!=/datum/geneblock)
			list_all_geneblocks+=type


// Run AFTER genetics setup and AFTER species setup.
/proc/setup_species()
	// SPECIES GENETICS FUN
	for(var/name in all_species)
		// I hate BYOND.  Can't just call while it's in the list.
		var/datum/species/species = all_species[name]
		if(species.default_block_names.len>0)
//			testing("Setting up genetics for [species.name] (needs [english_list(species.default_block_names)])")
			species.default_blocks.len = 0

			for(var/block=1;block<DNA_SE_LENGTH;block++)
				if(assigned_blocks[block] in species.default_block_names)
//					testing("  Found [assigned_blocks[block]] ([block])")
					species.default_blocks.Add(block)

			if(species.default_blocks.len)
				all_species[name]=species
