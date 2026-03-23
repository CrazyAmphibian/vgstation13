/**
* DNA 2: The Spaghetti Strikes Back
*
* @author N3X15 <nexisentertainment@gmail.com>
*/

var/global/list/datum/dna/gene/dna_genes[0]

var/global/list/good_blocks[0]
var/global/list/bad_blocks[0]

var/global/list/skin_styles_female_list = list() //Unused

// Hair Lists //////////////////////////////////////////////////

var/global/list/hair_styles_list				= list()
var/global/list/hair_styles_male_list			= list()
var/global/list/hair_styles_female_list			= list()
var/global/list/facial_hair_styles_list			= list()
var/global/list/facial_hair_styles_male_list	= list()
var/global/list/facial_hair_styles_female_list	= list()

/proc/buildHairLists()
	var/list/paths
	var/datum/sprite_accessory/hair/H
	paths = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	for(. in paths)
		H = new .
		hair_styles_list[H.name] = H
		switch(H.gender)
			if(MALE)
				hair_styles_male_list += H.name
			if(FEMALE)
				hair_styles_female_list += H.name
			else
				hair_styles_male_list += H.name
				hair_styles_female_list += H.name
	paths = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	for(. in paths)
		H = new .
		facial_hair_styles_list[H.name] = H
		switch(H.gender)
			if(MALE)
				facial_hair_styles_male_list += H.name
			if(FEMALE)
				facial_hair_styles_female_list += H.name
			else
				facial_hair_styles_male_list += H.name
				facial_hair_styles_female_list += H.name
	return

/datum/dna
	// READ-ONLY, GETS OVERWRITTEN
	// DO NOT FUCK WITH THESE OR BYOND WILL EAT YOUR FACE
	var/uni_identity="" // Encoded UI
	var/unique_enzymes="" // MD5 of player name

	// Okay to read, but you're an idiot if you do.
	// BLOCK = VALUE
	var/list/UI[DNA_UI_LENGTH]

	// From old dna.
	var/b_type = "A+"  // Should probably change to an integer => string map but I'm lazy.
	var/mutantrace = null  // The type of mutant race the player is, if applicable (i.e. potato-man)
	var/real_name          // Stores the real name of the person who originally got this dna datum. Used primarily for changelings,
	var/flavor_text

	// New stuff
	var/species = "Human"

	var/list/dormant_genes = list()

// Make a copy of this strand.
// USE THIS WHEN COPYING STUFF OR YOU'LL GET CORRUPTION!
/datum/dna/proc/Clone()
	var/datum/dna/new_dna = new()
	new_dna.unique_enzymes = unique_enzymes
	new_dna.struc_enzymes = struc_enzymes
	new_dna.b_type = b_type
	new_dna.mutantrace = mutantrace
	new_dna.real_name = real_name
	new_dna.flavor_text = flavor_text
	new_dna.species = species
	return new_dna

///////////////////////////////////////
// UNIQUE IDENTITY
///////////////////////////////////////

// Create random UI.
/datum/dna/proc/ResetUI(var/defer=0)
	for(var/i=1,i<=DNA_UI_LENGTH,i++)
		switch(i)
			if(DNA_UI_SKIN_TONE)
				SetUIValueRange(DNA_UI_SKIN_TONE,rand(1,220),220,1) // Otherwise, it gets fucked
			else
				UI[i]=rand(0,4095)
	if(!defer)
		UpdateUI()

/datum/dna/proc/ResetUIFrom(var/mob/living/carbon/human/character)
	// INITIALIZE!
	ResetUI(1)
	// Hair
	// FIXME:  Species-specific defaults pls
	if(!character.my_appearance.h_style)
		character.my_appearance.h_style = "Skinhead"
	var/list/species_hair = valid_sprite_accessories(hair_styles_list, null, character.species.name)
	var/hair = species_hair.Find(character.my_appearance.h_style)

	// Facial Hair
	if(!character.my_appearance.f_style)
		character.my_appearance.f_style = "Shaved"
	var/list/species_facial_hair = valid_sprite_accessories(facial_hair_styles_list, null, character.species.name)
	var/beard = species_facial_hair.Find(character.my_appearance.f_style)

	SetUIValueRange(DNA_UI_HAIR_R,    character.my_appearance.r_hair,    255,    1)
	SetUIValueRange(DNA_UI_HAIR_G,    character.my_appearance.g_hair,    255,    1)
	SetUIValueRange(DNA_UI_HAIR_B,    character.my_appearance.b_hair,    255,    1)

	SetUIValueRange(DNA_UI_BEARD_R,   character.my_appearance.r_facial,  255,    1)
	SetUIValueRange(DNA_UI_BEARD_G,   character.my_appearance.g_facial,  255,    1)
	SetUIValueRange(DNA_UI_BEARD_B,   character.my_appearance.b_facial,  255,    1)

	SetUIValueRange(DNA_UI_EYES_R,    character.my_appearance.r_eyes,    255,    1)
	SetUIValueRange(DNA_UI_EYES_G,    character.my_appearance.g_eyes,    255,    1)
	SetUIValueRange(DNA_UI_EYES_B,    character.my_appearance.b_eyes,    255,    1)

	if (character.species)
		if (character.species.anatomy_flags & HAS_SKIN_TONE)
			SetUIValueRange(DNA_UI_SKIN_TONE, 35-character.my_appearance.s_tone, 220,    1)
		else
			SetUIValueRange(DNA_UI_SKIN_TONE, character.my_appearance.s_tone, character.species.max_skin_tone,    1)
	else
		SetUIValueRange(DNA_UI_SKIN_TONE, 35-character.my_appearance.s_tone, 220,    1)

	SetUIState(DNA_UI_GENDER,         character.gender!=MALE,        1)

	SetUIValueRange(DNA_UI_HAIR_STYLE,  hair,  species_hair.len,       1)
	SetUIValueRange(DNA_UI_BEARD_STYLE, beard, species_facial_hair.len,1)

	UpdateUI()

// Set a DNA UI block's raw value.
/datum/dna/proc/SetUIValue(var/block,var/value,var/defer=0)
	if (block<=0)
		return
	ASSERT(value>=0)
	ASSERT(value<=4095)
	UI[block]=value
	if(!defer)
		UpdateUI()

// Get a DNA UI block's raw value.
/datum/dna/proc/GetUIValue(var/block)
	if (block<=0)
		return 0
	return UI[block]

// Set a DNA UI block's value, given a value and a max possible value.
// Used in hair and facial styles (value being the index and maxvalue being the len of the hairstyle list)
/datum/dna/proc/SetUIValueRange(var/block,var/value,var/maxvalue,var/defer=0)
	if (block<=0)
		return
	ASSERT(maxvalue<=4095)
	var/mapped_value = round(map_range(value, 0, max(maxvalue,1), 0, 0xFFF), 1)
	SetUIValue(block, mapped_value, defer)

// Getter version of above.
/datum/dna/proc/GetUIValueRange(var/block,var/maxvalue)
	if (block<=0)
		return 0
	var/value = GetUIValue(block)
	return round(map_range(value, 0, 0xFFF, 0, maxvalue), 1)

// Is the UI gene "on" or "off"?
// For UI, this is simply a check of if the value is > 2050.
/datum/dna/proc/GetUIState(var/block)
	if (block<=0)
		return
	return UI[block] > 2050


// Set UI gene "on" (1) or "off" (0)
/datum/dna/proc/SetUIState(var/block,var/on,var/defer=0)
	if (block<=0)
		return
	var/val
	if(on)
		val=rand(2050,4095)
	else
		val=rand(1,2049)
	SetUIValue(block,val,defer)

// Get a hex-encoded UI block.
/datum/dna/proc/GetUIBlock(var/block)
	return EncodeDNABlock(GetUIValue(block))

// Do not use this unless you absolutely have to.
// Set a block from a hex string.  This is inefficient.  If you can, use SetUIValue().
// Used in DNA modifiers.
/datum/dna/proc/SetUIBlock(var/block,var/value,var/defer=0)
	if (block<=0)
		return
	return SetUIValue(block,hex2num(value),defer)

// Get a sub-block from a block.
/datum/dna/proc/GetUISubBlock(var/block,var/subBlock)
	return copytext(GetUIBlock(block),subBlock,subBlock+1)

// Do not use this unless you absolutely have to.
// Set a block from a hex string.  This is inefficient.  If you can, use SetUIValue().
// Used in DNA modifiers.
/datum/dna/proc/SetUISubBlock(var/block,var/subBlock, var/newSubBlock, var/defer=0)
	if (block<=0)
		return
	var/oldBlock=GetUIBlock(block)
	var/newBlock=""
	for(var/i=1, i<=length(oldBlock), i++)
		if(i==subBlock)
			newBlock+=newSubBlock
		else
			newBlock+=copytext(oldBlock,i,i+1)
	SetUIBlock(block,newBlock,defer)


/proc/EncodeDNABlock(var/value)
	if(!isnum(value))
		warning("Expected a number, got [value]")
		return "0"
	return num2hex(value, 3)

/datum/dna/proc/UpdateUI()
	src.uni_identity=""
	for(var/block in UI)
		uni_identity += EncodeDNABlock(block)

// BACK-COMPAT!
//  Just checks our character has all the crap it needs.
/datum/dna/proc/check_integrity(var/mob/living/carbon/human/character)
	if(character)
		if(UI.len != DNA_UI_LENGTH)
			ResetUIFrom(character)

		if(character.real_name != "unknown")
			unique_enzymes = md5(character.real_name)
		else if(real_name && real_name != "unknown")
			unique_enzymes = md5(real_name)
		else
			unique_enzymes = md5(capitalize(pick(first_names_male)))
	else
		if(length(uni_identity) != 3*DNA_UI_LENGTH)
			uni_identity = "00600200A00E0110148FC01300B0095BD7FD3F4"
		unique_enzymes = md5(capitalize(pick(first_names_male)))


// BACK-COMPAT!
//  Initial DNA setup.
/datum/dna/proc/ready_dna(mob/living/carbon/human/character)
	ResetUIFrom(character)
	check_integrity(character)

	reg_dna[unique_enzymes] = character.real_name
	if(character.species)
		species = character.species.name
	character.copy_dna_data_to_blood_reagent()
	for (var/obj/item/weapon/card/id/card in character)
		card.SetOwnerDNAInfo(character)
