#define CODON_A "A"
#define CODON_C "C"
#define CODON_T "T"
#define CODON_G "G"
#define CODON_LIST list(CODON_A,CODON_C,CODON_T,CODON_G)

#define GENE_GROUP_IGNORE 0 //not listed. special. won't be included in any genes, ever.
#define GENE_GROUP_VISION 1 //affecting what you see
#define GENE_GROUP_SPEACH 2 //affecting what you say
#define GENE_GROUP_METABOLISM 3 //affecting what you eat
#define GENE_GROUP_TEMPERATURE 4 //affecting your body temp in some way

/datum/geneblock
	var/list/codons=list()
	var/size=30 //remember that there are 3 codons in an amino, so this should be a multiple of 3. this number affects how many mutations are able to be active at once, since there won't always be space. try to keep it a reasonable number. to calculate a decent number, go through all eligible mutations, sum their maxlength plus 2. then take that number and multiply it by 1/2. then, multiply by 3 (since 3 codons per amino acid). of course, you should just use your noggin when setting these numbers.
	var/name=""
	var/list/aminos=list() //cached list derived from codons. contains the amino acids
	var/list/aminoposdata=list()  //same as above, but contains positional data.
	var/group=GENE_GROUP_IGNORE
	var/list/activemutations=list()
	var/mob/body=null


/datum/geneblock/New(var/list/force_encode_mutations=list())
	codons.len=size
	
	var/list/coded_mutations=list()
	var/allocated_size=0
	for(var/datum/mutation/M in master_mutation_data)
		if(!M.gene_group || M.gene_group!=group) //check if the mutation is matched to our group
			continue
		if(M.inverted_activation)
			coded_mutations+=M
			allocated_size+=M.amino_string+2 //+2 for the start and stop
		else if(M.type in force_encode_mutations)
			coded_mutations+=M
			allocated_size+=M.amino_string+2
	var/remaining_space=(size/3)-allocated_size
	if (remaining_space<0) //ah shit, you added too many spawned mutations. increase gene size, asshole!
		size=remaining_space*3
		codons.len=size
	
	while(remaining_space)
		var/n=min(max(rand(1,ceil(remaining_space/2)),4),remaining_space)-2 //generate space between 4 and half the remaining length. capped to not exceed the remaining space size.
		var/datum/mutation/filler/F=new(n)
		coded_mutations+=F
		remaining_space-=n
	
	var/pointer=1
	while(coded_mutations.len) //randomly pick mutation strings to insert, to shuffle the order.
		var/datum/mutation/M=pick(coded_mutations)
		coded_mutations-=M
		if(M.length>=0)//if we have the space, add the start codon
			add_amino_at_position(AMINO_ANY_START,pointer)
			pointer++
		for(var/i=1,M.length,i++) //add acids according to the length var, not list.len
			add_amino_at_position(amino_string[i],pointer)
			pointer++
		add_amino_at_position(AMINO_ANY_END,pointer) //force end codon
		pointer++
		if(M.type==/datum/mutation/filler)
			qdel(M)

	recompile_basedata()

/datum/geneblock/proc/recompile_basedata()
	aminos=list()
	aminoposdata=list()
	
	for(var/i=1,i<size,i+=3) //split codon list into 3 members each
		var/codon=codons[i] + codons[i+1] + codons[i+2]
		for(var/datum/amino_acid/A in typesof(/datum/amino_acid) ) //then look for the matching amino acid
			if(codon in A.encodings)
				aminos+=A.amino_id
				aminoposdata+=A.position
				break
	
	for(var/datum/mutation/M in master_mutation_data)
		if(!M.gene_group || M.gene_group!=group) //check if the mutation is matched to our group
			continue
		var/active = M.is_active(src)
		if(active && !(M.type in activemutations) ) //if active, and we don't have it, activate it
			activemutations+=M.type
			M.on_activation(src,body)
		else if(!active && (M.type in activemutations)) //if inactive, and we have it, deactivate it
			activemutations-=M.type
			M.on_deactivation(src,body)
			

/datum/geneblock/proc/get_active_amino_strings() //returns a list of lists of amino acid ids. includes the start and stop codons.
	var/reading=FALSE
	var/list/returndata=list()
	var/list/buffer=list()
	for(var/i=1,i*3<=size,i++)
		if(!reading && aminoposdata[i]==AMINO_POSITION_START)
			reading=TRUE
			buffer+=aminos[i]
		if(!reading)
			continue
		if(aminoposdata[i]==AMINO_POSITION_END)
			buffer+=aminos[i]
			returndata+=buffer
			buffer=list()
			reading=FALSE
		else
			buffer+=aminos[i]
	return returndata


/datum/geneblock/proc/get_active_base_strings() //more or less the same as get_active_amino_strings, but instead of amino acid ids, it's the base codons.
	var/reading=FALSE
	var/list/returndata=list()
	var/list/buffer=list()
	for(var/i=1,i*3<=size,i++)
		if(!reading && aminoposdata[i]==AMINO_POSITION_START)
			reading=TRUE
			buffer+=codons[i]
			buffer+=codons[i+1]
			buffer+=codons[i+2]
		if(!reading)
			continue
		if(aminoposdata[i]==AMINO_POSITION_END)
			buffer+=codons[i]
			buffer+=codons[i+1]
			buffer+=codons[i+2]
			returndata+=buffer
			buffer=list()
			reading=FALSE
		else
			buffer+=codons[i]
			buffer+=codons[i+1]
			buffer+=codons[i+2]
	return returndata


/datum/geneblock/proc/mutate_rand(var/n=1)
	while(bases)
		codons[rand(1,size)]=pick(CODON_LIST) //randomize a random codon
		bases--
	recompile_basedata()


/datum/geneblock/proc/add_amino_at_position(var/amino_id,var/amino_position=1)
	if(amino_position*3>size-2) //don't add out of bounds
		return
	var/encoding=pick(amino_encodings[amino_id])
	var/truepos=(amino_position-1)*3+1
	codons[truepos]=encoding[1]
	codons[truepos+1]=encoding[2]
	codons[truepos+2]=encoding[3]
	