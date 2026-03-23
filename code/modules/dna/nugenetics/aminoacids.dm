#define AMINO_ACID_BASE 1
#define AMINO_ACID_ACID 2
#define AMINO_ACID_POLAR 3
#define AMINO_ACID_NONPOLAR 4
#define AMINO_ACID_SPECIAL 5

#define AMINO_ANY_START -1
#define AMINO_ANY_END -2

#define AMINO_INVALID 0
#define AMINO_ALANINE 1
#define AMINO_CYSTEINE 2
#define AMINO_ASPARTICACID 3
#define AMINO_GLUTAMICACID 4
#define AMINO_PHENYLALANINE 5
#define AMINO_GLYCINE 6
#define AMINO_HISTIDINE 7
#define AMINO_ISOLEUCINE 8
#define AMINO_LYSINE 9
#define AMINO_LEUCINE 10
#define AMINO_METHIONINE 11
#define AMINO_ASPARAGINE 12
#define AMINO_PROLINE 13
#define AMINO_GLUTAMINE 14
#define AMINO_ARGININE 15
#define AMINO_SERINE 16
#define AMINO_THREONINE 17
#define AMINO_VALINE 18
#define AMINO_TRYPTOPHAN 19
#define AMINO_TYROSINE 20
#define AMINO_OCHRE 21 //stop codons. not technically an amino acid. i know, shut up.
#define AMINO_AMBER 22
#define AMINO_OPAL 23
//selenocystine and pyrrolysine only conditionally exist (and replace stop codons) so we ignore them for the sake of simplicity. 

#define AMINO_POSITION_START 1
#define AMINO_POSITION_END 2

// this will help you out: https://en.wikipedia.org/wiki/DNA_and_RNA_codon_tables

var/global/amino_encodings=list() //associative amino_id=[encoding1,encoding2,...]

var/global/all_amino_acids=list() //stores all amino acids in form of AMINO_ defines
var/global/standard_amino_acids=list() //as above, but excludes stop codons
var/global/all_amino_encodings=list() //stores all encodings (GCAT) for all aminmo acids
var/global/standard_amino_encodings=list() //you get the idea.
var/global/starter_amino_encodings=list() //list of encodings for possible starting amino acids
var/global/ending_amino_encodings=list() //etc.

/datum/amino_acid
	var/position=0
	var/amino_id=AMINO_INVALID
	var/name="INVALID"
	var/shortname="???" //3 letters
	var/letter="?"
	var/list/encodings=list()
	var/aminotype=AMINO_ACID_SPECIAL //for coloring the UI


/datum/amino_acid/phenylalanine
	name="Phenylalanine"
	shortname="Phe"
	letter="F"
	aminotype=AMINO_ACID_NONPOLAR
	amino_id=AMINO_PHENYLALANINE
	encodings=list("TTT","TTC")

/datum/amino_acid/leucine
	name="Leucine"
	shortname="Leu"
	letter="L"
	aminotype=AMINO_ACID_NONPOLAR
	amino_id=AMINO_LEUCINE
	encodings=list("TTA","CTT","CTC","CTA","CTG")

/datum/amino_acid/leucine/start
	position=AMINO_POSITION_START
	encodings=list("TTG")

/datum/amino_acid/isoleucine
	name="Isoleucine"
	shortname="Ile"
	letter="I"
	aminotype=AMINO_ACID_NONPOLAR
	amino_id=AMINO_ISOLEUCINE
	encodings=list("ATT","ATC","ATA")

/datum/amino_acid/methionine
	position=AMINO_POSITION_START
	name="Methionine"
	shortname="Met"
	letter="M"
	aminotype=AMINO_ACID_NONPOLAR
	amino_id=AMINO_METHIONINE
	encodings=list("ATG")

/datum/amino_acid/valine
	name="Valine"
	shortname="Val"
	letter="V"
	aminotype=AMINO_ACID_NONPOLAR
	amino_id=AMINO_VALINE
	encodings=list("GTT","GTC","GTA")

/datum/amino_acid/valine/start
	position=AMINO_POSITION_START
	encodings=list("GTG")

/datum/amino_acid/serine
	name="Serine"
	shortname="Ser"
	letter="S"
	aminotype=AMINO_ACID_POLAR
	amino_id=AMINO_SERINE
	encodings=list("TCT","TCC","TCA","TCG")

/datum/amino_acid/proline 
	name="Proline"
	shortname="Pro"
	letter="P"
	aminotype=AMINO_ACID_NONPOLAR
	amino_id=AMINO_PROLINE
	encodings=list("CCT","CCC","CCA","CCG")

/datum/amino_acid/threonine
	name="Threonine"
	shortname="Thr"
	letter="T"
	aminotype=AMINO_ACID_POLAR
	amino_id=AMINO_SERINE
	encodings=list("ACT","ACC","ACA","ACG")

/datum/amino_acid/alanine
	name="Alanine"
	shortname="Ala"
	letter="A"
	aminotype=AMINO_ACID_NONPOLAR
	amino_id=AMINO_ALANINE
	encodings=list("GCT","GCC","GCA","GCG")

/datum/amino_acid/tyrosine
	name="Tyrosine"
	shortname="Tyr"
	letter="Y"
	aminotype=AMINO_ACID_POLAR
	amino_id=AMINO_SERINE
	encodings=list("TAT","TAC")
	
/datum/amino_acid/ochre
	position=AMINO_POSITION_END
	name="STOP (Ochre)"
	shortname="STOP"
	letter="]"
	aminotype=AMINO_ACID_SPECIAL
	amino_id=AMINO_OCHRE
	encodings=list("TAA")	
	
/datum/amino_acid/amber
	position=AMINO_POSITION_END
	name="STOP (Amber)"
	shortname="STOP"
	letter="]"
	aminotype=AMINO_ACID_SPECIAL
	amino_id=AMINO_AMBER
	encodings=list("TAG")	

/datum/amino_acid/histidine
	name="Histidine"
	shortname="His"
	letter="H"
	aminotype=AMINO_ACID_BASE
	amino_id=AMINO_HISTIDINE
	encodings=list("CAT","CAC")

/datum/amino_acid/glutamine
	name="Glutamine"
	shortname="Gln"
	letter="Q"
	aminotype=AMINO_ACID_POLAR
	amino_id=AMINO_GLUTAMINE
	encodings=list("CAA","CAG")

/datum/amino_acid/asparagine
	name="Asparagine"
	shortname="Asn"
	letter="N"
	aminotype=AMINO_ACID_POLAR
	amino_id=AMINO_ASPARAGINE
	encodings=list("AAT","AAC")
	
/datum/amino_acid/lysine
	name="Lysine"
	shortname="Lys"
	letter="K"
	aminotype=AMINO_ACID_BASE
	amino_id=AMINO_LYSINE
	encodings=list("AAA","AAG")

/datum/amino_acid/aspartic_acid 
	name="Aspartic acid"
	shortname="Asp"
	letter="D"
	aminotype=AMINO_ACID_ACID
	amino_id=AMINO_ASPARTICACID
	encodings=list("GAT","GAC")

/datum/amino_acid/glutamic_acid 
	name="Glutamic acid"
	shortname="Glu"
	letter="E"
	aminotype=AMINO_ACID_ACID
	amino_id=AMINO_GLUTAMICACID
	encodings=list("GAA","GAG")
	
/datum/amino_acid/cysteine
	name="Cysteine"
	shortname="Cys"
	letter="C"
	aminotype=AMINO_ACID_POLAR
	amino_id=AMINO_CYSTEINE
	encodings=list("TGT","TGC")

/datum/amino_acid/opal
	position=AMINO_POSITION_END
	name="STOP (Opal)"
	shortname="STOP"
	letter="]"
	aminotype=AMINO_ACID_SPECIAL
	amino_id=AMINO_OPAL
	encodings=list("TGA")		

/datum/amino_acid/tryptophan
	name="Tryptophan"
	shortname="Trp"
	letter="W"
	aminotype=AMINO_ACID_NONPOLAR
	amino_id=AMINO_TRYPTOPHAN
	encodings=list("TGG")

/datum/amino_acid/arginine
	name="Arginine"
	shortname="Arg"
	letter="R"
	aminotype=AMINO_ACID_BASE
	amino_id=AMINO_ARGININE
	encodings=list("CGT","CGC","CGA","CGG","AGA","AGG")

/datum/amino_acid/serine
	name="Serine"
	shortname="Ser"
	letter="S"
	aminotype=AMINO_ACID_POLAR
	amino_id=AMINO_SERINE
	encodings=list("AGT","AGC")

/datum/amino_acid/glycine
	name="Glycine"
	shortname="Gly"
	letter="G"
	aminotype=AMINO_ACID_NONPOLAR
	amino_id=AMINO_GLYCINE
	encodings=list("GGT","GGC","GGA","GGG")


