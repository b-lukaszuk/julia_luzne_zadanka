dna = read("./dna_seq_template_strand.txt", String)
dna = replace(dna, " " => "", "\n" => "")

# https://en.wikipedia.org/wiki/Complementarity_(molecular_biology)
dna2mrna = Dict(
    'c' => 'g',
    'g' => 'c',
    'a' => 'u',
    't' => 'a'
)
mrna = map(base -> get(dna2mrna, base, base), dna)
mrna = uppercase(mrna)

# https://en.wikipedia.org/wiki/DNA_and_RNA_codon_tables#Translation_table_1
codon2aa = Dict(
    "UUU"=> "Phe",
    "UUC"=> "Phe",
    "UUA" => "Leu",
    "UUG" => "Leu",
    "CUU" => "Leu",
    "CUC" => "Leu",
    "CUA" => "Leu",
    "CUG" => "Leu",
    "AUU" => "Ile",
    "AUC" => "Ile",
    "AUA" => "Ile",
    "AUG" => "Met",
    "GUU" => "Val",
    "GUC" => "Val",
    "GUA" => "Val",
    "GUG" => "Val",
    "UCU" => "Ser",
    "UCC" => "Ser",
    "UCA" => "Ser",
    "UCG" => "Ser",
    "CCU" => "Pro",
    "CCC" => "Pro",
    "CCA" => "Pro",
    "CCG" => "Pro",
    "ACU" => "Thr",
    "ACC" => "Thr",
    "ACA" => "Thr",
    "ACG" => "Thr",
    "GCU" => "Ala",
    "GCC" => "Ala",
    "GCA" => "Ala",
    "GCG" => "Ala",
    "UAU" => "Tyr",
    "UAC" => "Tyr",
    "UAA" => "Stop",
    "UAG" => "Stop",
    "CAU" => "His",
    "CAC" => "His",
    "CAA" => "Gln",
    "CAG" => "Gln",
    "AAU" => "Asn",
    "AAC" => "Asn",
    "AAA" => "Lys",
    "AAG" => "Lys",
    "GAU" => "Asp",
    "GAC" => "Asp",
    "GAA" => "Glu",
    "GAG" => "Glu",
    "UGU" => "Cys",
    "UGC" => "Cys",
    "UGA" => "Stop",
    "UGG" => "Trp",
    "CGU" => "Arg",
    "CGC" => "Arg",
    "CGA" => "Arg",
    "CGG" => "Arg",
    "AGU" => "Ser",
    "AGC" => "Ser",
    "AGA" => "Arg",
    "AGG" => "Arg",
    "GGU" => "Gly",
    "GGC" => "Gly",
    "GGA" => "Gly",
    "GGG" => "Gly"
)

aa2iupac = Dict(
    "Ala" => "A",
    "Arg" => "R",
    "Asn" => "N",
    "Asp" => "D",
    "Cys" => "C",
    "Gln" => "Q",
    "Glu" => "E",
    "Gly" => "G",
    "His" => "H",
    "Ile" => "I",
    "Leu" => "L",
    "Lys" => "K",
    "Met" => "M",
    "Phe" => "F",
    "Pro" => "P",
    "Ser" => "S",
    "Thr" => "T",
    "Trp" => "W",
    "Tyr" => "Y",
    "Val" => "V",
    "Stop" => "Stop"
)

function getAA(codon::String)::String
    aaAbbrev::String = get(codon2aa, codon, "???")
    aaIUPAC::String = get(aa2iupac, aaAbbrev, "???")
    return aaIUPAC
end

triples = [i:(i+2) for i in 1:3:length(mrna)]
aas = map(t -> getAA(mrna[t]), triples)
stopInd = findfirst(x -> x == "Stop", aas)
aas = aas[1:(stopInd-1)]
aas = join(aas)
