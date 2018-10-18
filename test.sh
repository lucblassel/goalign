########### Test Suite for Goalign command line tools ##############

set -e
set -u
set -o pipefail


echo "->goalign addid"
cat > expected <<EOF
>prefix_Seq0000_suffix
GATTAATTTGCCGTAGGCCAGAATCTGAAGATCGAACACTTTAAGTTTTCACTTCTAATGGAGAGGACTAGTTCATACTT
TTTAAACACTTTTACATCGA
>prefix_Seq0001_suffix
TGTCGGACCTAAGTATTGAGTACAACGGTGTATTCCAGCGGTGGAGAGGTCTATTTTTCCGGTTGAAGGACTCTAGAGCT
GTAAAGGGTATGGCCATGTG
>prefix_Seq0002_suffix
CTAAGCGCGGGCGGATTGCTGTTGGAGCAAGGTTAAATACTCGGCAATGCCCCATGATCCCCCAAGGACAATAAGAGCGA
AGTTAGAACAAATGAACCCC
>prefix_Seq0003_suffix
GAGTGGAGGCTTTATGGCACAAGGTATTAGAGACTGAGGGGCACCCCGGCATGGTAAGCAGGAGCCATCGCGAAGGCTTC
AGGTATCTTCCTGTGTTACC
>prefix_Seq0004_suffix
CATAGCCCCTGATGCCCTGACCCGTGTCGCGGCAACGTCTACATTTCACGATAAATACTCCGCTGCTAGTCGGCTCTAGA
TGCTTTTCTTCCAGATCTGG
EOF
goalign random --seed 10 -n 5 | goalign addid -n prefix_ | goalign addid -n _suffix -r > result
diff result expected
rm -f expected result mapfile


echo "->goalign clean sites"
cat > expected <<EOF
>Seq0000
ATATGGCGATCAAAGTTCCAATGAGATACTTCCTTTACG
>Seq0001
GCGATTATACTCCGAGGTTTTCCGAATAGTTGTTGGAGT
>Seq0002
TACGTTCGTATAAGCTGCCATCCCGGTGCAGACAATACC
>Seq0003
ATGAGGAAAAATGACGGCTAGCAGCAGGTCGCTCTGTAC
>Seq0004
AACCCCGCCGCACATACGTACTCGCTGTAAGTTCCATTG
>Seq0005
GTGAGCGCTTATGCTTAAGTGATTTGCGTTATATTTCAA
>Seq0006
CCACATTCGTATCTTCCGCCCCCCGGTCCACGCTGCTTC
>Seq0007
TGAACTTTCAGACCAGCGTGCTTTGACACCTGGCTCGGC
>Seq0008
CTAAAACCCTAATCCCTTGCTTCTATCCGCCTGGAGCCT
>Seq0009
CTCGCACGACCAGAGAACTAGGCCGGTTCCGGATATCTA
EOF
cat > expectedlog <<EOF
[Warning] in cmd/clean.go (line 55), message: Alignment (0) length before cleaning=100
[Warning] in cmd/clean.go (line 56), message: Alignment (0) length after cleaning=39
[Warning] in cmd/clean.go (line 57), message: Alignment (0) number of gaps=61
EOF
goalign random --seed 10 | goalign mutate gaps -n 1 -r 0.1 --seed 10 |  goalign clean sites > result 2>log
diff result expected
rm -f expected result mapfile log expectedlog

echo "->goalign clean seqs"
cat > expected <<EOF
>Seq0000
GATTAATTTGCCGTAGGCCAGAATCTGAAGATCGAACACTTTAAGTTTTCACTTCTAATGGAGAGGACTAGTTCATACTT
TTTAAACACTTTTACATCGA
>Seq0003
GAGTGGAGGCTTTATGGCACAAGGTATTAGAGACTGAGGGGCACCCCGGCATGGTAAGCAGGAGCCATCGCGAAGGCTTC
AGGTATCTTCCTGTGTTACC
>Seq0005
AGTTTGACTATGAGCGCCGGCTTAGTGCTGACAGTGATGCTCCGTTGTAAGGGTCCTGATGTTCTTGTGCTCGCGCATAT
TAGAGCTGAGTTTCCCAAAG
>Seq0007
CTGGTAATACCTGCGCTATTTCGTCAGTTCGTGTACGGGTAACGATAGCGGTTAATGCTTATTCCGATCAGCTCACACCC
ATGAAGGTGGCTCTGGAGCC
>Seq0009
ACCTACGGCTCTAGACAGCTGAAGTCCGGTTCCGAGCACTGTACGGAAACTTGAAAAGGCTCGACGGAGGCTTGTTCCGC
AGAGTGGGACTATAACATAC
EOF
cat > expectedlog <<EOF
[Warning] in cmd/cleanseqs.go (line 36), message: Alignment (0) #seqs before cleaning=10
[Warning] in cmd/cleanseqs.go (line 37), message: Alignment (0) #seqs after cleaning=5
[Warning] in cmd/cleanseqs.go (line 38), message: Alignment (0) removed sequences=5
EOF
goalign random --seed 10 | goalign mutate gaps -n 0.5 -r 0.7 --seed 10 |  goalign clean seqs > result 2>log
diff result expected
rm -f expected result mapfile log expectedlog

echo "->goalign random"
cat > expected <<EOF
>Seq0000
GATTAATTTGCCGTAGGCCA
>Seq0001
GAATCTGAAGATCGAACACT
>Seq0002
TTAAGTTTTCACTTCTAATG
>Seq0003
GAGAGGACTAGTTCATACTT
>Seq0004
TTTAAACACTTTTACATCGA
>Seq0005
TGTCGGACCTAAGTATTGAG
>Seq0006
TACAACGGTGTATTCCAGCG
>Seq0007
GTGGAGAGGTCTATTTTTCC
>Seq0008
GGTTGAAGGACTCTAGAGCT
>Seq0009
GTAAAGGGTATGGCCATGTG
EOF
goalign random --seed 10 -l 20 > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat fasta"
cat > expected <<EOF
>Seq0000
GATTA
>Seq0001
ATTTG
>Seq0002
CCGTA
>Seq0003
GGCCA
>Seq0004
GAATC
EOF
goalign random -n 5 -l 5 --seed 10 -p | goalign reformat fasta -p > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat fasta strict"
cat > expected <<EOF
>Seq0000
GATTA
>Seq0001
ATTTG
>Seq0002
CCGTA
>Seq0003
GGCCA
>Seq0004
GAATC
EOF
goalign random -n 5 -l 5 --seed 10 -p --input-strict | goalign reformat fasta -p > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat fasta names with spaces"
cat > input <<EOF
> Seq0000
GATTA
> Seq0001
ATTTG
> Seq0002
CCGTA
> Seq0003
GGCCA
> Seq0004
GAATC
EOF
cat > expected <<EOF
>Seq0000
GATTA
>Seq0001
ATTTG
>Seq0002
CCGTA
>Seq0003
GGCCA
>Seq0004
GAATC
EOF
goalign reformat fasta -i input -o result
diff result expected
rm -f expected input result

echo "->goalign reformat fasta sequences with spaces"
cat > input <<EOF
>    Seq0000
GA    T TA
>    Seq0001
A     TT TG
>    Seq0002
CC G TA
>    Seq0003
GG CC A
>    Seq0004
G AA T C
EOF
cat > expected <<EOF
>Seq0000
GATTA
>Seq0001
ATTTG
>Seq0002
CCGTA
>Seq0003
GGCCA
>Seq0004
GAATC
EOF
goalign reformat fasta -i input -o result
diff result expected
rm -f expected input result

echo "->goalign reformat phylip"
cat > expected <<EOF
   5   75
Seq0000  GATTAATTTG CCGTAGGCCA GAATCTGAAG ATCGAACACT TTAAGTTTTC ACTTCTAATG
Seq0001  TACTTTTTAA ACACTTTTAC ATCGATGTCG GACCTAAGTA TTGAGTACAA CGGTGTATTC
Seq0002  CTATTTTTCC GGTTGAAGGA CTCTAGAGCT GTAAAGGGTA TGGCCATGTG CTAAGCGCGG
Seq0003  AGCAAGGTTA AATACTCGGC AATGCCCCAT GATCCCCCAA GGACAATAAG AGCGAAGTTA
Seq0004  GAGTGGAGGC TTTATGGCAC AAGGTATTAG AGACTGAGGG GCACCCCGGC ATGGTAAGCA

   GAGAGGACTA GTTCA
   CAGCGGTGGA GAGGT
   GCGGATTGCT GTTGG
   GAACAAATGA ACCCC
   GGAGCCATCG CGAAG
EOF
goalign random -n 5 -l 75 --seed 10 | goalign reformat phylip > result
diff result expected
rm -f expected result mapfile


echo "->goalign reformat phylip --one-line"
cat > expected <<EOF
   5   75
Seq0000  GATTAATTTG CCGTAGGCCA GAATCTGAAG ATCGAACACT TTAAGTTTTC ACTTCTAATG GAGAGGACTA GTTCA
Seq0001  TACTTTTTAA ACACTTTTAC ATCGATGTCG GACCTAAGTA TTGAGTACAA CGGTGTATTC CAGCGGTGGA GAGGT
Seq0002  CTATTTTTCC GGTTGAAGGA CTCTAGAGCT GTAAAGGGTA TGGCCATGTG CTAAGCGCGG GCGGATTGCT GTTGG
Seq0003  AGCAAGGTTA AATACTCGGC AATGCCCCAT GATCCCCCAA GGACAATAAG AGCGAAGTTA GAACAAATGA ACCCC
Seq0004  GAGTGGAGGC TTTATGGCAC AAGGTATTAG AGACTGAGGG GCACCCCGGC ATGGTAAGCA GGAGCCATCG CGAAG
EOF
goalign random -n 5 -l 75 --seed 10 | goalign reformat phylip --one-line > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat phylip --no-block --one-line"
cat > expected <<EOF
   5   75
Seq0000  GATTAATTTGCCGTAGGCCAGAATCTGAAGATCGAACACTTTAAGTTTTCACTTCTAATGGAGAGGACTAGTTCA
Seq0001  TACTTTTTAAACACTTTTACATCGATGTCGGACCTAAGTATTGAGTACAACGGTGTATTCCAGCGGTGGAGAGGT
Seq0002  CTATTTTTCCGGTTGAAGGACTCTAGAGCTGTAAAGGGTATGGCCATGTGCTAAGCGCGGGCGGATTGCTGTTGG
Seq0003  AGCAAGGTTAAATACTCGGCAATGCCCCATGATCCCCCAAGGACAATAAGAGCGAAGTTAGAACAAATGAACCCC
Seq0004  GAGTGGAGGCTTTATGGCACAAGGTATTAGAGACTGAGGGGCACCCCGGCATGGTAAGCAGGAGCCATCGCGAAG
EOF
goalign random -n 5 -l 75 --seed 10 | goalign reformat phylip --one-line --no-block > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat phylip --no-block"
cat > expected <<EOF
   5   75
Seq0000  GATTAATTTGCCGTAGGCCAGAATCTGAAGATCGAACACTTTAAGTTTTCACTTCTAATG
Seq0001  TACTTTTTAAACACTTTTACATCGATGTCGGACCTAAGTATTGAGTACAACGGTGTATTC
Seq0002  CTATTTTTCCGGTTGAAGGACTCTAGAGCTGTAAAGGGTATGGCCATGTGCTAAGCGCGG
Seq0003  AGCAAGGTTAAATACTCGGCAATGCCCCATGATCCCCCAAGGACAATAAGAGCGAAGTTA
Seq0004  GAGTGGAGGCTTTATGGCACAAGGTATTAGAGACTGAGGGGCACCCCGGCATGGTAAGCA

   GAGAGGACTAGTTCA
   CAGCGGTGGAGAGGT
   GCGGATTGCTGTTGG
   GAACAAATGAACCCC
   GGAGCCATCGCGAAG
EOF
goalign random -n 5 -l 75 --seed 10 | goalign reformat phylip --no-block > result
diff result expected
rm -f expected result mapfile


echo "->goalign reformat phylip spaces tabs"
cat > expected <<EOF
   5   5
S-e-q-0-0-00  GATTA
Se-q00-0-1  ATTTG
Se-q00-0-2  CCGTA
Seq00-03  GGCCA
Seq-0004  GAATC
EOF
cat > input.fa <<EOF
> S e q 0	0	00
GATTA
> 	 Se    q00 0 1    	 
ATTTG
>	 Se    q00 0 2    	 	
CCGTA
>		Seq00     03
GGCCA
>Seq		0004
GAATC
EOF
goalign reformat phylip -i input.fa --clean-names > result
diff result expected
rm -f expected result mapfile input.fa


echo "->goalign reformat fasta spaces tabs"
cat > expected <<EOF
>S-e-q-0-0-00-
GATTA
>Se-q00-0-2-
CCGTA
>Seq00-03-
GGCCA
>Se-q-0004
GAATC
EOF
cat > input.fa <<EOF
> S e q 0	0	00[]();.,
GATTA
>	 Se    q00 0 2    	 	[]();.,
CCGTA
>		Seq00     03[]();.,
GGCCA
>Se		q[]();.,0004
GAATC
EOF
goalign reformat fasta -i input.fa --clean-names > result
diff result expected
rm -f expected result mapfile input.fa

echo "->goalign reformat fasta spaces tabs"
cat > expected <<EOF
>seq1-A-simple-comment-to-be-removed?-
GATTA
>seq2-A-second-comment-Maybe-a-wrong-sequence-to-be-updated?-
CCGTA
EOF
cat > input.fa <<EOF
> seq1 [A simple comment; to be removed?]
GATTA
> seq2 [A second comment] (Maybe a wrong sequence: to be updated?)
CCGTA
EOF
goalign reformat fasta -i input.fa --clean-names > result
diff result expected
rm -f expected result mapfile input.fa

echo "->goalign reformat phylip strict"
cat > expected <<EOF
   5   5
Seq0000   GATTA
Seq0001   ATTTG
Seq0002   CCGTA
Seq0003   GGCCA
Seq0004   GAATC
EOF
goalign random -n 5 -l 5 --seed 10 | goalign reformat phylip --output-strict > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat nexus"
cat > expected <<EOF
#NEXUS
begin data;
dimensions ntax=5 nchar=5;
format datatype=dna;
matrix
Seq0000 GATTA
Seq0001 ATTTG
Seq0002 CCGTA
Seq0003 GGCCA
Seq0004 GAATC
;
end;
EOF
goalign random -n 5 -l 5 --seed 10 | goalign reformat nexus > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat fasta from clustal"
## Sample file from t-coffee:
## https://github.com/cbcrg/tcoffee/blob/master/examples/sample_aln2.aln
cat > input <<EOF
CLUSTAL W (1.83) multiple sequence alignment

1cms            --GEVASVPLTNYLDSQYFGKIYLGTPPQEFTVLFDTGSSDFWVPSIYCK
4pep            ----IGDEPLENYLDTEYFGTIGIGTPAQDFTVIFDTGSSNLWVPSVYCS
4ape            -STGSATTTPIDSLDDAYITPVQIGTPAQTLNLDFDTGSSDLWVFSSETT
3app            AASGVATNTPTAN-DEEYITPVTIG--GTTLNLNFDTGSADLWVFSTELP
2apr            AGVGTVPMTDYGN-DIEYYGQVTIGTPGKKFNLDFDTGSSDLWIASTLCT
1cms_1          -----------------YTGSLHWVPVTVQQYWQFTVDS---VTISGVVV
                                 *   :            * ..*      *    

1cms            SNACKNHQRFDPR-KSSTFQNLGKPLSIHYGTG-SMQGILGYDTVTVSNI
4pep            SLACSDHNQFNPD-DSSTFEATSQELSITYGTG-SMTGILGYDTVQVGGI
4ape            ASEVDGQTIYTPSKSTTAKLLSGATWSISYGDGSSSSGDVYTDTVSVGGL
3app            ASQQSGHSVYNP--SATGKELSGYTWSISYGDGSSASGNVFTDSVTVGGV
2apr            NCG-SGQTKYDPN-QSSTYQADGRTWSISYGDGSSASGILAKDNVNLGGL
1cms_1          ACEGGCQAILDTG-TSKLVGPSSDILNIQQAIG-ATQNQYGEFDIDCDNL
                      :    .   :.     .   .*  . * :  .      :  ..:

1cms            VDIQQTVGLSTQEPGDVFTYAEFDGILGMAYPSLASEY---SIPVFDNMM
4pep            SDTNQIFGLSETEPGSFLYYAPFDGILGLAYPSISASG---ATPVFDNLW
4ape            TVTGQAVESAKKVSSSFTEDSTIDGLLGLAFSTLNTVSPTQQKTFFDNAK
3app            TAHGQAVQAAQQISAQFQQDTNNDGLLGLAFSSINTVQPQSQTTFFDTVK
2apr            LIKGQTIELAKREAASFASGPN-DGLLGLGFDTITTVR--GVKTPMDNLI
1cms_1          SYMPTVVFEINGKMYPLTPSAYTSQDQGFCTSGFQSEN------HSQKWI
                      .         .   .  .   *:    : :          :.  

1cms            NRHLVAQDLFSVYMDRNGQE--SMLTLGAIDPSY
4pep            DQGLVSQDLFSVYLSSNDDSG-SVVLLGGIDSSY
4ape            AS--LDSPVFTADLGYHAPG---TYNFGFIDTTA
3app            SS--LAQPLFAVALKHQQPG---VYDFGFIDSSK
2apr            SQGLISRPIFGVYLGKAKNGGGGEYIFGGYDSTK
1cms_1          LGDVFIREYYSVFDRANNLVG----LAKAI----
                    .    : .                      


EOF
cat > expected <<EOF
>1cms
--GEVASVPLTNYLDSQYFGKIYLGTPPQEFTVLFDTGSSDFWVPSIYCKSNACKNHQRFDPR-KSSTFQNLGKPLSIHY
GTG-SMQGILGYDTVTVSNIVDIQQTVGLSTQEPGDVFTYAEFDGILGMAYPSLASEY---SIPVFDNMMNRHLVAQDLF
SVYMDRNGQE--SMLTLGAIDPSY
>4pep
----IGDEPLENYLDTEYFGTIGIGTPAQDFTVIFDTGSSNLWVPSVYCSSLACSDHNQFNPD-DSSTFEATSQELSITY
GTG-SMTGILGYDTVQVGGISDTNQIFGLSETEPGSFLYYAPFDGILGLAYPSISASG---ATPVFDNLWDQGLVSQDLF
SVYLSSNDDSG-SVVLLGGIDSSY
>4ape
-STGSATTTPIDSLDDAYITPVQIGTPAQTLNLDFDTGSSDLWVFSSETTASEVDGQTIYTPSKSTTAKLLSGATWSISY
GDGSSSSGDVYTDTVSVGGLTVTGQAVESAKKVSSSFTEDSTIDGLLGLAFSTLNTVSPTQQKTFFDNAKAS--LDSPVF
TADLGYHAPG---TYNFGFIDTTA
>3app
AASGVATNTPTAN-DEEYITPVTIG--GTTLNLNFDTGSADLWVFSTELPASQQSGHSVYNP--SATGKELSGYTWSISY
GDGSSASGNVFTDSVTVGGVTAHGQAVQAAQQISAQFQQDTNNDGLLGLAFSSINTVQPQSQTTFFDTVKSS--LAQPLF
AVALKHQQPG---VYDFGFIDSSK
>2apr
AGVGTVPMTDYGN-DIEYYGQVTIGTPGKKFNLDFDTGSSDLWIASTLCTNCG-SGQTKYDPN-QSSTYQADGRTWSISY
GDGSSASGILAKDNVNLGGLLIKGQTIELAKREAASFASGPN-DGLLGLGFDTITTVR--GVKTPMDNLISQGLISRPIF
GVYLGKAKNGGGGEYIFGGYDSTK
>1cms_1
-----------------YTGSLHWVPVTVQQYWQFTVDS---VTISGVVVACEGGCQAILDTG-TSKLVGPSSDILNIQQ
AIG-ATQNQYGEFDIDCDNLSYMPTVVFEINGKMYPLTPSAYTSQDQGFCTSGFQSEN------HSQKWILGDVFIREYY
SVFDRANNLVG----LAKAI----
EOF
goalign reformat fasta -i input -u > result
diff result expected
rm -f expected result input

echo "->goalign reformat fasta from clustal (2)"
cat > input <<EOF
CLUSTALW

1cms     --GEVASVPLTNYLDSQYFGKIYLGTPPQE 30
4pep     ----IGDEPLENYLDTEYFGTIGIGTPAQD 30
4ape     -STGSATTTPIDSLDDAYITPVQIGTPAQT 30
3app     AASGVATNTPTAN-DEEYITPVTIG--GTT 30
2apr     AGVGTVPMTDYGN-DIEYYGQVTIGTPGKK 30
1cms_1   -----------------YTGSLHWVPVTVQ 30
                          *   :        
EOF
cat > expected <<EOF
>1cms
--GEVASVPLTNYLDSQYFGKIYLGTPPQE
>4pep
----IGDEPLENYLDTEYFGTIGIGTPAQD
>4ape
-STGSATTTPIDSLDDAYITPVQIGTPAQT
>3app
AASGVATNTPTAN-DEEYITPVTIG--GTT
>2apr
AGVGTVPMTDYGN-DIEYYGQVTIGTPGKK
>1cms_1
-----------------YTGSLHWVPVTVQ
EOF
goalign reformat fasta -i input -u | sed 's/ (goalign version.*//g'> result
diff result expected
rm -f expected result input


echo "->goalign reformat clustal from fasta"
cat > input <<EOF
>1cms
--GEVASVPLTNYLDSQYFGKIYLGTPPQE
>4pep
----IGDEPLENYLDTEYFGTIGIGTPAQD
>4ape
-STGSATTTPIDSLDDAYITPVQIGTPAQT
>3app
AASGVATNTPTAN-DEEYITPVTIG--GTT
>2apr
AGVGTVPMTDYGN-DIEYYGQVTIGTPGKK
>1cms_1
-----------------YTGSLHWVPVTVQ
EOF
cat > expected <<EOF
CLUSTAL W

1cms     --GEVASVPLTNYLDSQYFGKIYLGTPPQE 30
4pep     ----IGDEPLENYLDTEYFGTIGIGTPAQD 30
4ape     -STGSATTTPIDSLDDAYITPVQIGTPAQT 30
3app     AASGVATNTPTAN-DEEYITPVTIG--GTT 30
2apr     AGVGTVPMTDYGN-DIEYYGQVTIGTPGKK 30
1cms_1   -----------------YTGSLHWVPVTVQ 30
                          *   :        
EOF
goalign reformat clustal -i input | sed 's/ (goalign version.*//g'> result
diff result expected
rm -f expected result input

echo "->goalign reformat tnt"
cat > expected <<EOF
xread

'Tnt input file'

5 5
Seq0000 GATTA
Seq0001 ATTTG
Seq0002 CCGTA
Seq0003 GGCCA
Seq0004 GAATC
;
EOF
goalign random -n 5 -l 5 --seed 10 | goalign reformat tnt > result
diff result expected
rm -f expected result mapfile


echo "->goalign reformat tnt auto"
cat > expected <<EOF
xread

'Tnt input file'

5 5
Seq0000 GATTA
Seq0001 ATTTG
Seq0002 CCGTA
Seq0003 GGCCA
Seq0004 GAATC
;
EOF
goalign random -n 5 -l 5 --seed 10 | goalign reformat tnt --auto-detect > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat auto from nexus"
cat > expected <<EOF
#NEXUS
begin data;
dimensions ntax=5 nchar=5;
format datatype=dna;
matrix
Seq0000 GATTA
Seq0001 ATTTG
Seq0002 CCGTA
Seq0003 GGCCA
Seq0004 GAATC
;
end;
EOF
goalign random -n 5 -l 5 --seed 10 -x | goalign reformat nexus --auto-detect > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat auto from phylip strict"
cat > expected <<EOF
   5   5
Seq0000   GATTA
Seq0001   ATTTG
Seq0002   CCGTA
Seq0003   GGCCA
Seq0004   GAATC
EOF
goalign random -n 5 -l 5 --seed 10 | goalign reformat phylip --output-strict | goalign reformat phylip --output-strict --auto-detect > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat auto from phylip"
cat > expected <<EOF
   5   5
Seq0000  GATTA
Seq0001  ATTTG
Seq0002  CCGTA
Seq0003  GGCCA
Seq0004  GAATC
EOF
goalign random -n 5 -l 5 --seed 10 -p | goalign reformat phylip --auto-detect > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat auto from fasta"
cat > expected <<EOF
>Seq0000
GATTA
>Seq0001
ATTTG
>Seq0002
CCGTA
>Seq0003
GGCCA
>Seq0004
GAATC
EOF
goalign random -n 5 -l 5 --seed 10 | goalign reformat fasta --auto-detect > result
diff result expected
rm -f expected result mapfile

echo "->goalign reformat paml from phylip"
cat > input.test <<EOF
   5   5
Seq0000  GATTA
Seq0001  ATTTG
Seq0002  CCGTA
Seq0003  GGCCA
Seq0004  GAATC
EOF
cat > expected <<EOF
  5 5  I
Seq0000
Seq0001
Seq0002
Seq0003
Seq0004

GATTA
ATTTG
CCGTA
GGCCA
GAATC
EOF
goalign reformat paml -i input.test -p > output.paml
diff output.paml expected
rm -f expected output.paml intput.test

echo "->goalign compute distance -m f81"
cat > expected <<EOF
5
Tip4	0.000000000000	0.174911845895	0.192803956978	0.232646053483	0.235379041630
Tip0	0.174911845895	0.000000000000	0.082364641962	0.128396525775	0.142776083476
Tip3	0.192803956978	0.082364641962	0.000000000000	0.071285264523	0.086842665158
Tip2	0.232646053483	0.128396525775	0.071285264523	0.000000000000	0.111961817720
Tip1	0.235379041630	0.142776083476	0.086842665158	0.111961817720	0.000000000000
EOF
goalign compute distance -m f81 -i tests/data/test_distance.phy.gz -p > result
diff result expected
rm -f expected result mapfile


echo "->goalign compute distance -m rawdist"
cat > expected <<EOF
5
Tip4	0.000000000000	4.000000000000	3.000000000000	3.000000000000	4.000000000000
Tip0	4.000000000000	0.000000000000	1.000000000000	1.000000000000	2.000000000000
Tip3	3.000000000000	1.000000000000	0.000000000000	0.000000000000	1.000000000000
Tip2	3.000000000000	1.000000000000	0.000000000000	0.000000000000	1.000000000000
Tip1	4.000000000000	2.000000000000	1.000000000000	1.000000000000	0.000000000000
EOF
goalign compute distance -m rawdist -i tests/data/test_rawdistance.phy.gz -p > result
diff result expected
rm -f expected result mapfile

echo "->goalign compute distance -m rawdist2"
cat > expected <<EOF
5
Tip4	0.000000000000	4.000000000000	3.000000000000	3.000000000000	4.000000000000
Tip0	4.000000000000	0.000000000000	0.000000000000	0.000000000000	1.000000000000
Tip3	3.000000000000	0.000000000000	0.000000000000	0.000000000000	1.000000000000
Tip2	3.000000000000	0.000000000000	0.000000000000	0.000000000000	1.000000000000
Tip1	4.000000000000	1.000000000000	1.000000000000	1.000000000000	0.000000000000
EOF
goalign compute distance -m rawdist -i tests/data/test_rawdistance2.phy.gz -p > result
diff result expected
rm -f expected result mapfile


echo "->goalign compute distance -m pdist"
cat > expected <<EOF
5
Tip4	0.000000000000	0.156000000000	0.170000000000	0.200000000000	0.202000000000
Tip0	0.156000000000	0.000000000000	0.078000000000	0.118000000000	0.130000000000
Tip3	0.170000000000	0.078000000000	0.000000000000	0.068000000000	0.082000000000
Tip2	0.200000000000	0.118000000000	0.068000000000	0.000000000000	0.104000000000
Tip1	0.202000000000	0.130000000000	0.082000000000	0.104000000000	0.000000000000
EOF
goalign compute distance -m pdist -i tests/data/test_distance.phy.gz -p > result
diff result expected
rm -f expected result mapfile

echo "->goalign compute distance -m jc"
cat > expected <<EOF
5
Tip4	0.000000000000	0.174895415376	0.192783827242	0.232616196228	0.235348439687
Tip0	0.174895415376	0.000000000000	0.082361149505	0.128387859288	0.142765296368
Tip3	0.192783827242	0.082361149505	0.000000000000	0.071282661515	0.086838774745
Tip2	0.232616196228	0.128387859288	0.071282661515	0.000000000000	0.111955277061
Tip1	0.235348439687	0.142765296368	0.086838774745	0.111955277061	0.000000000000
EOF
goalign compute distance -m jc -i tests/data/test_distance.phy.gz -p > result
diff result expected
rm -f expected result mapfile


echo "->goalign compute distance -m k2p"
cat > expected <<EOF
5
Tip4	0.000000000000	0.175065910654	0.193245190192	0.233028942469	0.235571330668
Tip0	0.175065910654	0.000000000000	0.082453892766	0.128434558659	0.142789108437
Tip3	0.193245190192	0.082453892766	0.000000000000	0.071292715047	0.086845484497
Tip2	0.233028942469	0.128434558659	0.071292715047	0.000000000000	0.111966480828
Tip1	0.235571330668	0.142789108437	0.086845484497	0.111966480828	0.000000000000
EOF
goalign compute distance -m k2p -i tests/data/test_distance.phy.gz -p > result
diff result expected
rm -f expected result mapfile


echo "->goalign compute distance -m f84"
cat > expected <<EOF
5
Tip4	0.000000000000	0.175078537680	0.193258659612	0.233050782717	0.235595781888
Tip0	0.175078537680	0.000000000000	0.082456191295	0.128441770138	0.142798708889
Tip3	0.193258659612	0.082456191295	0.000000000000	0.071294953075	0.086849003947
Tip2	0.233050782717	0.128441770138	0.071294953075	0.000000000000	0.111972393604
Tip1	0.235595781888	0.142798708889	0.086849003947	0.111972393604	0.000000000000
EOF
goalign compute distance -m f84 -i tests/data/test_distance.phy.gz -p > result
diff result expected
rm -f expected result mapfile


echo "->goalign compute distance -m tn93"
cat > expected <<EOF
5
Tip4	0.000000000000	0.175562323963	0.193263808045	0.233468379444	0.236008401698
Tip0	0.175562323963	0.000000000000	0.082492772223	0.128715806962	0.142896903086
Tip3	0.193263808045	0.082492772223	0.000000000000	0.071294993201	0.086849459942
Tip2	0.233468379444	0.128715806962	0.071294993201	0.000000000000	0.112213623285
Tip1	0.236008401698	0.142896903086	0.086849459942	0.112213623285	0.000000000000
EOF
goalign compute distance -m tn93 -i tests/data/test_distance.phy.gz -p > result
diff result expected
rm -f expected result mapfile

echo "->goalign compute entropy"
cat > expected <<EOF
Alignment	Site	Entropy
0	0	0.000
0	1	0.000
0	2	0.000
0	3	0.000
0	4	0.000
0	5	0.000
0	6	0.000
0	7	0.000
0	8	0.000
0	9	0.000
0	10	0.500
0	11	0.000
0	12	0.000
0	13	0.500
0	14	0.500
0	15	0.000
0	16	0.000
0	17	0.000
0	18	0.000
EOF
goalign compute entropy -i tests/data/test_distance.phy.gz -p > restmp
head -n 20 restmp > result
diff result expected
rm -f expected result restmp


echo "->goalign compute pssm logo"
cat > expected <<EOF
	A	C	G	T
1	0.004	1.953	0.004	0.004
2	1.953	0.004	0.004	0.004
3	1.953	0.004	0.004	0.004
4	0.004	0.004	0.004	1.953
5	0.004	0.004	1.953	0.004
6	0.004	0.004	0.004	1.953
7	0.004	1.953	0.004	0.004
8	0.004	1.953	0.004	0.004
9	0.004	1.953	0.004	0.004
10	0.004	1.953	0.004	0.004
11	0.002	0.997	0.251	0.002
12	1.953	0.004	0.004	0.004
13	1.953	0.004	0.004	0.004
14	0.002	0.002	0.997	0.251
15	0.002	0.251	0.997	0.002
16	1.953	0.004	0.004	0.004
17	0.004	1.953	0.004	0.004
18	0.004	1.953	0.004	0.004
19	0.004	1.953	0.004	0.004
EOF
goalign compute pssm -n 4 -i tests/data/test_distance.phy.gz -p -c 0.01  > restmp
head -n 20 restmp > result
diff result expected
rm -f expected result restmp


echo "->goalign concat 1"
cat > expected <<EOF
>Seq0000
GATTAATTTGGATTAATTTG
>Seq0001
CCGTAGGCCACCGTAGGCCA
>Seq0002
GAATCTGAAGGAATCTGAAG
>Seq0003
ATCGAACACTATCGAACACT
>Seq0004
TTAAGTTTTCTTAAGTTTTC
>Seq0005
ACTTCTAATGACTTCTAATG
>Seq0006
GAGAGGACTAGAGAGGACTA
>Seq0007
GTTCATACTTGTTCATACTT
>Seq0008
TTTAAACACTTTTAAACACT
>Seq0009
TTTACATCGATTTACATCGA
EOF
goalign random -l 10 --seed 10 | goalign concat  <(goalign random -l 10 --seed 10 | goalign shuffle seqs) > result
diff result expected
rm -f expected result

echo "->goalign concat 2"
cat > expected <<EOF
>Seq0000
GATTAATTTGGATTAATTTG
>Seq0001
CCGTAGGCCACCGTAGGCCA
>Seq0002
GAATCTGAAGGAATCTGAAG
>Seq0003
ATCGAACACTATCGAACACT
>Seq0004
TTAAGTTTTCTTAAGTTTTC
>Seq0005
ACTTCTAATGACTTCTAATG
>Seq0006
GAGAGGACTAGAGAGGACTA
>Seq0007
GTTCATACTTGTTCATACTT
>Seq0008
TTTAAACACTTTTAAACACT
>Seq0009
TTTACATCGATTTACATCGA
EOF
goalign random -l 10 --seed 10 | goalign concat  <(goalign random -l 10 --seed 10 | goalign shuffle seqs) > result
diff result expected
rm -f expected result

echo "->goalign concat (missing sequences in 1)"
cat > input1 <<EOF
>Seq0000
GACATGGCAG
>Seq0001
AATAGAATAG
>Seq0002
TCGATGTCTT
>Seq0003
CGCGAGCCTC
>Seq0004
AGAAGCTTTA
EOF
cat > input2 <<EOF
>Seq0000
GATTAATTTG
>Seq0001
CCGTAGGCCA
>Seq0002
GAATCTGAAG
>Seq0003
ATCGAACACT
>Seq0004
TTAAGTTTTC
>Seq0005
ACTTCTAATG
>Seq0006
GAGAGGACTA
>Seq0007
GTTCATACTT
>Seq0008
TTTAAACACT
>Seq0009
TTTACATCGA
EOF
cat > expected <<EOF
>Seq0000
GACATGGCAGGATTAATTTG
>Seq0001
AATAGAATAGCCGTAGGCCA
>Seq0002
TCGATGTCTTGAATCTGAAG
>Seq0003
CGCGAGCCTCATCGAACACT
>Seq0004
AGAAGCTTTATTAAGTTTTC
>Seq0005
----------ACTTCTAATG
>Seq0006
----------GAGAGGACTA
>Seq0007
----------GTTCATACTT
>Seq0008
----------TTTAAACACT
>Seq0009
----------TTTACATCGA
EOF
goalign concat -i none input1 input2 > result
diff result expected
rm -f expected result input1 input2

echo "->goalign concat (missing sequences in 2)"
cat > input2 <<EOF
>Seq0000
GACATGGCAG
>Seq0001
AATAGAATAG
>Seq0002
TCGATGTCTT
>Seq0003
CGCGAGCCTC
>Seq0004
AGAAGCTTTA
EOF
cat > input1 <<EOF
>Seq0000
GATTAATTTG
>Seq0001
CCGTAGGCCA
>Seq0002
GAATCTGAAG
>Seq0003
ATCGAACACT
>Seq0004
TTAAGTTTTC
>Seq0005
ACTTCTAATG
>Seq0006
GAGAGGACTA
>Seq0007
GTTCATACTT
>Seq0008
TTTAAACACT
>Seq0009
TTTACATCGA
EOF
cat > expected <<EOF
>Seq0000
GATTAATTTGGACATGGCAG
>Seq0001
CCGTAGGCCAAATAGAATAG
>Seq0002
GAATCTGAAGTCGATGTCTT
>Seq0003
ATCGAACACTCGCGAGCCTC
>Seq0004
TTAAGTTTTCAGAAGCTTTA
>Seq0005
ACTTCTAATG----------
>Seq0006
GAGAGGACTA----------
>Seq0007
GTTCATACTT----------
>Seq0008
TTTAAACACT----------
>Seq0009
TTTACATCGA----------
EOF
goalign concat -i none input1 input2 > result
diff result expected
rm -f expected result input1 input2

echo "->goalign concat (missing sequences in both)"
cat > input2 <<EOF
>Seq0000
GACATGGCAG
>Seq0001
AATAGAATAG
>Seq0002
TCGATGTCTT
>Seq0003
CGCGAGCCTC
>Seq0004
AGAAGCTTTA
EOF
cat > input1 <<EOF
>Seq0004
TTAAGTTTTC
>Seq0005
ACTTCTAATG
>Seq0006
GAGAGGACTA
>Seq0007
GTTCATACTT
>Seq0008
TTTAAACACT
>Seq0009
TTTACATCGA
EOF
cat > expected <<EOF
>Seq0004
TTAAGTTTTCAGAAGCTTTA
>Seq0005
ACTTCTAATG----------
>Seq0006
GAGAGGACTA----------
>Seq0007
GTTCATACTT----------
>Seq0008
TTTAAACACT----------
>Seq0009
TTTACATCGA----------
>Seq0000
----------GACATGGCAG
>Seq0001
----------AATAGAATAG
>Seq0002
----------TCGATGTCTT
>Seq0003
----------CGCGAGCCTC
EOF
goalign concat -i none input1 input2 > result
diff result expected
rm -f expected result input1 input2


echo "->goalign divide"
cat > expected <<EOF
>Seq0000
GATTAATTTG
>Seq0000
GATTAATTTG
>Seq0000
GATTAATTTG
>Seq0000
GATTAATTTG
>Seq0000
GATTAATTTG
>Seq0000
GATTAATTTG
>Seq0000
GATTAATTTG
>Seq0000
GATTAATTTG
>Seq0000
GATTAATTTG
>Seq0000
GATTAATTTG
EOF
rm -f input
for i in {1..10}
do
    goalign random -n 1 -l 10 --seed 10 -p >> input
done
goalign divide -i input -p -o divprefix -f
cat divprefix_* > result
diff result expected
rm -f expected result divprefix* input


echo "->goalign mutate gaps"
cat > expected <<EOF
>Seq0000
GATTAATTTGCCGTAGGCCA
>Seq0001
G-ATCTGAAGA-CGAACACT
>Seq0002
TTAAGTTTT-ACT-CTAATG
>Seq0003
GAGAGGACTAGTTCATACTT
>Seq0004
TTTAAACA-TTTTACA-CGA
>Seq0005
TGTCGGACCTAAGTATTGAG
>Seq0006
TAC-ACG-TGTATTCCAGCG
>Seq0007
GTGGAGAGGTCTATTTTTCC
>Seq0008
GGTTGAAGGACT-TAGAGC-
>Seq0009
GTAAAGGGTATGGCCATGTG
EOF
goalign random --seed 10 -l 20 | goalign mutate gaps --seed 10 > result
diff result expected
rm -f expected result


echo "->goalign mutate snvs"
cat > expected <<EOF
>Seq0000
GATTAATTTCCCGTAGGCCA
>Seq0001
GAATCTGAATATCGAACTAT
>Seq0002
TTAAGTTTTCACTTCTAATG
>Seq0003
GAGAGGACTAGTTCATAATT
>Seq0004
TTTTAACACTTTTACATCGA
>Seq0005
TGTCGGACCTAAGTTTTGTG
>Seq0006
TGCAACGATGTACTCCAGCG
>Seq0007
GTGGAGAGGTCTATTTTTGC
>Seq0008
GGTTAAAGGACTCTATAGCT
>Seq0009
GAAAAGGGTATGGCCATGTG
EOF
goalign random --seed 10 -l 20 | goalign mutate snvs --seed 10 > result
diff result expected
rm -f expected result


echo "->goalign rename"
cat > mapfile <<EOF
Seq0000	New0000
Seq0001	New0001
Seq0002	New0002
Seq0003	New0003
Seq0004	New0004
EOF
cat > expected <<EOF
>New0000
GATTAATTTGCCGTAGGCCA
>New0001
GAATCTGAAGATCGAACACT
>New0002
TTAAGTTTTCACTTCTAATG
>New0003
GAGAGGACTAGTTCATACTT
>New0004
TTTAAACACTTTTACATCGA
EOF
goalign random --seed 10 -l 20 -n 5 | goalign rename -m mapfile > result
diff result expected
rm -f expected result mapfile

echo "->goalign rename regexp"
cat > mapfile <<EOF
Seq0000	New0000
Seq0001	New0001
Seq0002	New0002
Seq0003	New0003
Seq0004	New0004
EOF
cat > expected <<EOF
>New0000
GATTAATTTGCCGTAGGCCA
>New0001
GAATCTGAAGATCGAACACT
>New0002
TTAAGTTTTCACTTCTAATG
>New0003
GAGAGGACTAGTTCATACTT
>New0004
TTTAAACACTTTTACATCGA
EOF
goalign random --seed 10 -l 20 -n 5 | goalign rename --regexp 'Seq(\d+)' --replace 'New$1' -m mapfile2 > result
diff result expected
diff <(sort mapfile) <(sort mapfile2)
rm -f expected result mapfile mapfile2

echo "->goalign sample seqs"
cat > expected <<EOF
>Seq0001
CCGTAGGCCA
>Seq0002
GAATCTGAAG
>Seq0008
TTTAAACACT
EOF
goalign random -l 10 --seed 10 | goalign sample seqs -n 3 --seed 10 > result
diff result expected
rm -f expected result



echo "->goalign sample sites"
cat > expected <<EOF
>Seq0000
TTAAT
>Seq0001
GTAGG
>Seq0002
ATCTG
>Seq0003
CGAAC
>Seq0004
AAGTT
>Seq0005
TTCTA
>Seq0006
GAGGA
>Seq0007
TCATA
>Seq0008
TAAAC
>Seq0009
TACAT
EOF
goalign random -l 10 --seed 10 | goalign sample sites -l 5 --seed 10 > result
diff result expected
rm -f expected result



echo "->goalign shuffle recomb"
cat > expected <<EOF
>Seq0000
GATTAATTTG
>Seq0001
CCGTAGGCCA
>Seq0002
GAATCTGAAG
>Seq0003
ATCGATGAAG
>Seq0004
TTAAGTTTTC
>Seq0005
AAGAGGAATG
>Seq0006
GAGAGGACTA
>Seq0007
GTTCATACTT
>Seq0008
TTTAAACACT
>Seq0009
TTTACATCGA
EOF
goalign random -l 10 --seed 10 | goalign shuffle recomb -l 0.5 -n 0.25 --seed 11 > result
diff result expected
rm -f expected result

echo "->goalign shuffle recomb"
cat > expected <<EOF
>Seq0000
GATTAATTTG
>Seq0001
CCGTAGGCCA
>Seq0002
GAATCTGAAG
>Seq0003
ATCGATGAAG
>Seq0004
TTAAGTTTTC
>Seq0005
AAGAGGAATG
>Seq0006
GAGAGGACTA
>Seq0007
GTTCATACTT
>Seq0008
TTTAAACACT
>Seq0009
TTTACATCGA
EOF
goalign random -l 10 --seed 10 | goalign shuffle recomb -l 0.5 -n 0.25 --seed 11 > result
diff result expected
rm -f expected result


echo "->goalign shuffle sites"
cat > expected <<EOF
>Seq0000
GATTGGATCCCGGGGTGCGACACTCGTTCGAGTGTAAATTGCTGCTTTGC
>Seq0001
ACTATTAACGGAGAAGACTAGTTCATGCTTGTGAAGCACTCTGCAAACGA
>Seq0002
TGTATGACGGAAGTACTGCGTACAACTGTGTACTCCAGTGAAACGGAGCT
>Seq0003
CTACGTTTGAGGTTCTAGGACTATAGAGGTGTATACGCCATGGTGACGTG
>Seq0004
CTATACTCCCGCGGTGTGCTGTGGGAGCTAGGATAACGTCTTAACATTCC
>Seq0005
CCCACGATCTCCCACGGAGAATGAGATCAAAGTCATTAGATCGTAACCGC
>Seq0006
CAGGATCGTCTTTTGCGCAAAATGTGAAGGTGCTAGATCGACAACTTGGC
>Seq0007
ATGAGAAGTGGAAAGCATAGGGAAGAGCACTGCAAGAGCCCTTGACCACC
>Seq0008
GTTTTAACCTGGTTAACTCTCCCGTTCTACATTTTTGTATTTGGTTTAGG
>Seq0009
AAATGCGCTCCCCGAGTACCCGACTCGAGAAGTAAACTCTGCAGCTCTTG
EOF

cat > rogueexpected <<EOF
Seq0000
Seq0006
Seq0009
Seq0008
Seq0007
EOF

goalign random -l 50 --seed 10 | goalign shuffle sites -r 0.5 --seed 10 --rogue 0.5 --rogue-file rogues.txt > result
diff result expected
diff rogueexpected rogues.txt
rm -f expected result rogueexpected rogues.txt

echo "->goalign shuffle sites rogues stables"
cat > expected <<EOF
>Seq0000
CATTTATTTGCGGACGTCGTGAAAGTGTAGTTCAAACACATCAAACTGGC
>Seq0001
CCTTATACCGGAGGATACAAATGGAATAATATTTAGATCTTCAGAAAGCC
>Seq0002
AGTCGCAGCTAAGTATGGGTGATCTCTCTGAATACTATCCGAGTCAAGGG
>Seq0003
CTATGTTTCCGCTGTCGGGGCTCGAGGTCTGTAGAAGGTTTGGCGATAGG
>Seq0004
ATGAGCGCGGGGTAAATGCCCTTTAGACGAAGTCAGCGATTCACCGTTTA
>Seq0005
GCGAGGATCCCCCTCGAAAAATATTAAGGATGTTATCACTATTGTTCATC
>Seq0006
GAATTGAAGCTGTTACGCTATACCGTGGTGGGAATAGAGGGTGACACCCT
>Seq0007
ATAGTAAGCAGTAAGGCTCGCGAATGCCTCAGGTACACTGCTGTCTTCGC
>Seq0008
CACAAGCCTTGCGTGGATCAGCCGGAGCACGGCTACTGCCACTGATCTCC
>Seq0009
TTTACTACTCCACGGCTACACGGACCTAGATGCTTGATTACTAGGTCTGG
EOF

cat > rogueexpected <<EOF
Seq0001
Seq0002
Seq0008
Seq0004
Seq0006
EOF

goalign random -l 50 --seed 10 | goalign shuffle sites -r 0.5 --seed 10 --rogue 0.5 --rogue-file rogues.txt --stable-rogues  > result
goalign random -l 30 --seed 11 | goalign shuffle sites -r 0.5 --seed 10 --rogue 0.5 --rogue-file rogues2.txt --stable-rogues  > /dev/null
diff result expected
diff rogueexpected rogues.txt
# Should be the same list of rogues, even if random gen seed is
# different and length is different (initial seq order is the same)
diff rogues.txt rogues2.txt
rm -f expected result rogueexpected rogues.txt

echo "->goalign stats"
cat > expected <<EOF
length	10
nseqs	10
avgalleles	3.6000
variable sites	10
char	nb	freq
A	31	0.310000
C	18	0.180000
G	17	0.170000
T	34	0.340000
alphabet	nucleotide
EOF
goalign random -l 10 --seed 10 | goalign stats > result
diff result expected
rm -f expected result


echo "->goalign subseq"
cat > expected <<EOF
>Seq0000
ATTTGCCGTA
>Seq0001
ACTGCGCCGC
>Seq0002
CCATACTCGT
>Seq0003
GCTGTGGAGC
EOF
goalign random -n 4 --seed 10 -l 10000 | goalign subseq -l 10 -s 5 > result
diff result expected
rm -f expected result

echo "->goalign subseq window phylip"
cat > input <<EOF
   10   5
Seq0000  GGAGT
Seq0001  AAGTA
Seq0002  ACGGT
Seq0003  GCACA
Seq0004  AGTAC
Seq0005  GAAGG
Seq0006  CCTTA
Seq0007  AGCAC
Seq0008  GTACG
Seq0009  GAATA
   10   5
Seq0000  AGAGT
Seq0001  AAGTT
Seq0002  ACGGT
Seq0003  ACACT
Seq0004  AGTAT
Seq0005  AAAGT
Seq0006  ACTTT
Seq0007  AGCAT
Seq0008  ATACT
Seq0009  AAATT
EOF
cat > expected.1 <<EOF
   10   4
Seq0000  GGAG
Seq0001  AAGT
Seq0002  ACGG
Seq0003  GCAC
Seq0004  AGTA
Seq0005  GAAG
Seq0006  CCTT
Seq0007  AGCA
Seq0008  GTAC
Seq0009  GAAT
EOF
cat > expected.2 <<EOF
   10   4
Seq0000  GAGT
Seq0001  AGTA
Seq0002  CGGT
Seq0003  CACA
Seq0004  GTAC
Seq0005  AAGG
Seq0006  CTTA
Seq0007  GCAC
Seq0008  TACG
Seq0009  AATA
EOF
cat > expected.3 <<EOF
   10   4
Seq0000  AGAG
Seq0001  AAGT
Seq0002  ACGG
Seq0003  ACAC
Seq0004  AGTA
Seq0005  AAAG
Seq0006  ACTT
Seq0007  AGCA
Seq0008  ATAC
Seq0009  AAAT
EOF
cat > expected.4 <<EOF
   10   4
Seq0000  GAGT
Seq0001  AGTT
Seq0002  CGGT
Seq0003  CACT
Seq0004  GTAT
Seq0005  AAGT
Seq0006  CTTT
Seq0007  GCAT
Seq0008  TACT
Seq0009  AATT
EOF
goalign subseq -i input -p -l 4 -s 0 --step 1 -o output.phylip
diff output.phylip expected.1
diff output_sub1.phylip expected.2
diff output_al1.phylip expected.3
diff output_al1_sub1.phylip expected.4
rm -f input expected.{1,2,3,4} \
   output.phylip output_sub1.phylip \
   output_al1.phylip output_al1_sub1.phylip

echo "->goalign subset"
cat > expected <<EOF
>Seq0001
CCGTAGGCCA
>Seq3999
CGGGGCCGAC
EOF
goalign random -n 4000 --seed 10 -l 10 | goalign subset Seq0001 Seq3999 > result
diff result expected
rm -f expected result


echo "->goalign trim name"
cat > expected <<EOF
>S01
GATTA
>S02
ATTTG
>S03
CCGTA
>S04
GGCCA
EOF
cat > expectedmap <<EOF
Seq0002	S03
Seq0003	S04
Seq0000	S01
Seq0001	S02
EOF
goalign random --seed 10 -n 4 -l 5 | goalign trim name -n 3 -m mapfile > result
diff result expected
diff <(sort mapfile) <(sort expectedmap)
rm -f expected result expectedmap mapfile


echo "->goalign trim name auto"
cat > expected <<EOF
>S1
GATTA
>S2
ATTTG
>S3
CCGTA
>S4
GGCCA
EOF
cat > expectedmap <<EOF
Seq0002	S3
Seq0003	S4
Seq0000	S1
Seq0001	S2
EOF
goalign random --seed 10 -n 4 -l 5 | goalign trim name -a -m mapfile > result
diff result expected
diff <(sort mapfile) <(sort expectedmap)
rm -f expected result expectedmap mapfile


echo "->goalign trim name auto several ali"
cat > input <<EOF
  4 5
Seq0001 GATTA
Seq0002 ATTTG
Seq0003 CCGTA
Seq0004 GGCCA
  4 5
Seq0005 GATTA
Seq0002 ATTTG
Seq0003 CCGTA
Seq0006 GGCCA
  4 5
Seq0001 GATTA
Seq0006 ATTTG
Seq0007 CCGTA
Seq0005 GGCCA
EOF
cat > expected <<EOF
   4   5
S1  GATTA
S2  ATTTG
S3  CCGTA
S4  GGCCA
   4   5
S5  GATTA
S2  ATTTG
S3  CCGTA
S6  GGCCA
   4   5
S1  GATTA
S6  ATTTG
S7  CCGTA
S5  GGCCA
EOF
cat > mapfile <<EOF
Seq0003	S3
Seq0004	S4
Seq0001	S1
Seq0002	S2
Seq0005	S5
Seq0006	S6
Seq0007	S7
EOF
goalign trim name -i input -a -m mapfile2 -p > result
diff result expected
diff <(sort mapfile) <(sort mapfile2)
rm -f expected result mapfile input mapfile2


echo "->goalign trim seq"
cat > expected <<EOF
>Seq0000
ATTTG
>Seq0001
GGCCA
>Seq0002
TGAAG
>Seq0003
ACACT
EOF
goalign random --seed 10 -n 4 -l 10 | goalign trim seq -n 5 -s > result
diff result expected
rm -f expected result 


echo "->goalign unalign"
cat > expected <<EOF
>Seq0000
GATTAATTTGCCGTAGGCCAGAATCTGAAGATCGAACACTTTAAGTTTTCACTTCTAATGGAGAGGACTAGTTCATACTT
TTTAAACACTTTTACATCGA
>Seq0001
GTCGGACCTAAGATTGAGTACAACGGTGATTCCAGCGGGGAGAGGTCTTTTTTCCGGTGAAGGACTCTAGGCTGTAAAGT
ATGGCATGTG
>Seq0002
CTAACGCGGGCGGATTCTGTGGACAAGGTTAAATACCGGCAATGCCCATGATCCCCCAGGACATAAGAGCGAAGTTAACA
AATGAACCCC
>Seq0003
GAGTGGAGGCTTTATGGCACAAGGTATTAGAGACTGAGGGGCACCCCGGCATGGTAAGCAGGAGCCATCGCGAAGGCTTC
AGGTATCTTCCTGTGTTACC
>Seq0004
CATAGCCCCATGCCGACCGTGTCGCGGCAACGTCTACATTCACGATAAAACTCCGTGCTAGTCGGCTCAGATGCTTTTCT
TCCAATCTGG
>Seq0005
AGTTTGACTATGAGCGCCGGCTTAGTGCTGACAGTGATGCTCCGTTGTAAGGGTCCTGATGTTCTTGTGCTCGCGCATAT
TAGAGCTGAGTTTCCCAAAG
>Seq0006
TCGCACGGGTGGAATGTACGTTATGCATAATCAGCGCTTTCCCGACATGCCCCCTCCGTGGCTCCTTCGCCACGGCGGAC
CTGCGGTTCG
>Seq0007
CTGGTAATACCTGCGCTATTTCGTCAGTTCGTGTACGGGTAACGATAGCGGTTAATGCTTATTCCGATCAGCTCACACCC
ATGAAGGTGGCTCTGGAGCC
>Seq0008
TCGTTAACCCACTCTAACCACCTCTGGCGACATCGGTCTCGGCTTGGATACCTTCTCTATTGGACCCCAGGCTCAACTCG
TGAGCTCTCT
>Seq0009
ACCTACGGCTCTAGACAGCTGAAGTCCGGTTCCGAGCACTGTACGGAAACTTGAAAAGGCTCGACGGAGGCTTGTTCCGC
AGAGTGGGACTATAACATAC
EOF
goalign random --seed 10 -p | goalign mutate gaps --seed 10 -p | goalign unalign -p > result
diff result expected
rm -f expected result 


echo "->goalign reformat nexus 1"
cat > nexus <<EOF
#NEXUS
BEGIN TAXA;
      TaxLabels fish frog snake mouse;
END;

BEGIN CHARACTERS;
      Dimensions NChar=40;
      Format DataType=DNA;
      Matrix
        fish   ACATA GAGGG TACCT CTAAA
        frog   ACATA GAGGG TACCT CTAAC
        snake  ACATA GAGGG TACCT CTAAG
        mouse  ACATA GAGGG TACCT CTAAT

        fish   ACATA GAGGG TACCT CTAAG
        frog   CCATA GAGGG TACCT CTAAG
        snake  GCATA GAGGG TACCT CTAAG
        mouse  TCATA GAGGG TACCT CTAAG
;
END;

BEGIN TREES;
      Tree best=(fish, (frog, (snake, mouse)));
END;
EOF
cat > expected <<EOF
>fish
ACATAGAGGGTACCTCTAAAACATAGAGGGTACCTCTAAG
>frog
ACATAGAGGGTACCTCTAACCCATAGAGGGTACCTCTAAG
>snake
ACATAGAGGGTACCTCTAAGGCATAGAGGGTACCTCTAAG
>mouse
ACATAGAGGGTACCTCTAATTCATAGAGGGTACCTCTAAG
EOF
goalign reformat fasta -i nexus -x -o result
diff expected result
rm -f expected result nexus


echo "->goalign reformat nexus 2"
cat > nexus <<EOF
#NEXUS
BEGIN TAXA;
      TaxLabels fish frog snake mouse;
END;

BEGIN CHARACTERS;
      Dimensions NChar=40;
      Format DataType=DNA;
      Matrix
        fish   ACATA GAGGG TACCT CTAAA
        fish   ACATA GAGGG TACCT CTAAG

        frog   ACATA GAGGG TACCT CTAAC
        frog   CCATA GAGGG TACCT CTAAG

        snake  ACATA GAGGG TACCT CTAAG
        snake  GCATA GAGGG TACCT CTAAG

        mouse  ACATA GAGGG TACCT CTAAT
        mouse  TCATA GAGGG TACCT CTAAG
;
END;

BEGIN TREES;
      Tree best=(fish, (frog, (snake, mouse)));
END;
EOF
cat > expected <<EOF
>fish
ACATAGAGGGTACCTCTAAAACATAGAGGGTACCTCTAAG
>frog
ACATAGAGGGTACCTCTAACCCATAGAGGGTACCTCTAAG
>snake
ACATAGAGGGTACCTCTAAGGCATAGAGGGTACCTCTAAG
>mouse
ACATAGAGGGTACCTCTAATTCATAGAGGGTACCTCTAAG
EOF
goalign reformat fasta -i nexus -x -o result
diff expected result
rm -f expected result nexus


echo "->goalign sort"
cat > expected <<EOF
>Seq0000
GATTAATTTG
>Seq0001
CCGTAGGCCA
>Seq0002
GAATCTGAAG
>Seq0003
ATCGAACACT
>Seq0004
TTAAGTTTTC
EOF
goalign random --seed 10 -l 10 -n 5 | goalign shuffle seqs | goalign sort > result
diff expected result
rm -f expected result

echo "->goalign translate"
cat > input <<EOF
>allcodons
GCTGCCGCAGCGTTATTGCTTCTCCTACTGCGTCGCCGACGGAGAAGGAAAAAGAATAACATG
GATGACTTTTTCTGTTGCCCTCCCCCACCGCAACAGTCTTCCTCATCGAGTAGCGAAGAGACT
ACCACAACGGGTGGCGGAGGGTGGCATCACTATTACATTATCATAGTTGTCGTAGTGTAATGA
TAG
EOF
cat > expected <<EOF
>allcodons
AAAALLLLLLRRRRRRKKNNMDDFFCCPPPPQQSSSSSSEETTTTGGGGWHHYYIIIVVVV***
EOF
goalign translate -i input --phase 0 -o result
diff expected result
rm -f input expected result

echo "->goalign translate unaligned"
cat > input <<EOF
>allcodons
GCTGCCGCAGCGTTATTGCTTCTCCTACTGCGTCGCCGACGGAGAAGGAAAAAGAATAACATG
GATGACTTTTTCTGTTGCCCTCCCCCACCGCAACAGTCTTCCTCATCGAGTAGCGAAGAGACT
ACCACAACGGGTGGCGGAGGGTGGCATCACTATTACATTATCATAGTTGTCGTAGTGTAATGA
TAG
>allcodons2
GCTGCAGCGTTATTGCTTCTCCTACTGCGTCGCCGACGGAGAAGGAAAAAGAATAACATG
GATGACTTTTTCTGTTGCCCTCCCCCACCGCAACAGTCTTCCTCATCGAGTAGCGAAGAGACT
ACCACAACGGGTGGCGGAGGGTGGCATCACTATTACATTATCATAGTTGTCGTATAATGA
EOF
cat > expected <<EOF
>allcodons
AAAALLLLLLRRRRRRKKNNMDDFFCCPPPPQQSSSSSSEETTTTGGGGWHHYYIIIVVVV***
>allcodons2
AAALLLLLLRRRRRRKKNNMDDFFCCPPPPQQSSSSSSEETTTTGGGGWHHYYIIIVVV**
EOF
goalign translate -i input --phase 0 --unaligned -o result
diff expected result
rm -f input expected result


echo "->goalign dedup"
cat > input <<EOF
  5   6
1 AAAAAA
2 CCCCCC
3 GGGGGG
4 GGGGGG
4 GGGGGG
EOF
cat > expected <<EOF
   3   6
1  AAAAAA
2  CCCCCC
3  GGGGGG
EOF
goalign dedup -i input -o result -p
diff expected result
rm -f input expected result

echo "->goalign dedup /2"
cat > input <<EOF
   6   6
3  GGGGGG
1  AAAAAA
1  AAAAAC
2  CCCCCC
4  GGGGGG
4  GGGGGG
EOF
cat > expected <<EOF
   4   6
3  GGGGGG
1  AAAAAA
1_0001  AAAAAC
2  CCCCCC
EOF
goalign dedup -i input -o result -p
diff expected result
rm -f input expected result

echo "->goalign build seqboot"
cat > expected.1 <<EOF
>Seq0000
ATTAT
>Seq0001
GTTGT
>Seq0002
ATGAT
>Seq0003
ACCAC
EOF
cat > expected.2 <<EOF
>Seq0000
AAGGT
>Seq0001
GGAAT
>Seq0002
AACCT
>Seq0003
AAGGC
EOF
goalign random --seed 10 -l 5 -n 4 -o orig.fa
goalign build seqboot --seed 10 -i orig.fa -n 2 -o boot
diff boot0.fa expected.1
diff boot1.fa expected.2
diff orig.fa expected.1 > /dev/null || echo "expected.1 ok"
diff orig.fa expected.2 > /dev/null || echo "expected.2 ok"
if [[ $(ls boot*.fa| wc -l) -ne 2 ]]; then echo "Wrong number of bootstrap alignments"; exit 1; fi
rm -f boot0.fa boot1.fa expected.2 expected.1 orig.fa

echo "->goalign build seqboot gz"
cat > expected.1 <<EOF
>Seq0000
ATTAT
>Seq0001
GTTGT
>Seq0002
ATGAT
>Seq0003
ACCAC
EOF
cat > expected.2 <<EOF
>Seq0000
AAGGT
>Seq0001
GGAAT
>Seq0002
AACCT
>Seq0003
AAGGC
EOF
goalign random --seed 10 -l 5 -n 4 -o orig.fa
goalign build seqboot --seed 10 -i orig.fa -n 2 -o boot --gz
diff <(gunzip -c boot0.fa.gz) expected.1
diff <(gunzip -c boot1.fa.gz) expected.2
if [[ $(ls boot*.fa.gz| wc -l) -ne 2 ]]; then echo "Wrong number of bootstrap alignments"; exit 1; fi
rm -f boot0.fa.gz boot1.fa.gz expected.2 expected.1 orig.fa

echo "->goalign build seqboot tar gz"
cat > expected.1 <<EOF
>Seq0000
ATTAT
>Seq0001
GTTGT
>Seq0002
ATGAT
>Seq0003
ACCAC
EOF
cat > expected.2 <<EOF
>Seq0000
AAGGT
>Seq0001
GGAAT
>Seq0002
AACCT
>Seq0003
AAGGC
EOF
goalign random --seed 10 -l 5 -n 4 -o orig.fa
goalign build seqboot --seed 10 -i orig.fa -n 2 -o boot --gz --tar
tar -xzf boot.tar.gz
diff boot0.fa expected.1
diff boot1.fa expected.2
if [[ $(ls boot*.fa | wc -l) -ne 2 ]]; then echo "Wrong number of bootstrap alignments"; exit 1; fi
rm -f boot0.fa boot1.fa boot.tar.gz  expected.2 expected.1 orig.fa

echo "->goalign codonalign"
cat > input.aa <<EOF
>Seq0000
D*-AVGQNLK
>Seq0001
IE-FKF-LLM
>Seq0002
ERTSSYFLNT
EOF

cat > input.nt <<EOF
>Seq0000
GATTAAGCCGTAGGCCAGAATCTGAAG
>Seq0001
ATCGAATTTAAGTTTCTTCTAATG
>Seq0002
GAGAGGACTAGTTCATACTTTTTAAACACT
EOF

cat > expected <<EOF
>Seq0000
GATTAA---GCCGTAGGCCAGAATCTGAAG
>Seq0001
ATCGAA---TTTAAGTTT---CTTCTAATG
>Seq0002
GAGAGGACTAGTTCATACTTTTTAAACACT
EOF

goalign codonalign -i input.aa -f input.nt -o result
diff expected result
rm -f expected result input.aa input.nt

echo "->goalign identical"
cat > input1 <<EOF
>Seq0000
GATTAA---GCCGTAGGCCAGAATCTGAAG
>Seq0001
ATCGAA---TTTAAGTTT---CTTCTAATG
>Seq0002
GAGAGGACTAGTTCATACTTTTTAAACACT
EOF

cat > input2 <<EOF
>Seq0001
ATCGAA---TTTAAGTTT---CTTCTAATG
>Seq0000
GATTAA---GCCGTAGGCCAGAATCTGAAG
>Seq0002
GAGAGGACTAGTTCATACTTTTTAAACACT
EOF

cat > input3 <<EOF
>Seq0001
GATTAA---GCCGTAGGCCAGAATCTGAAG
>Seq0000
ATCGAA---TTTAAGTTT---CTTCTAATG
>Seq0002
GAGAGGACTAGTTCATACTTTTTAAACACT
EOF

cat > input4 <<EOF
>Seq0000
GATTAA---GCCGTAGGCCAGAATCTGAAG
>Seq0001
ATCGAA---TTTAAGTTT---CTTCTAATG
>Seq0002
GAGAGGACTAGTTCATACTTTTTAAACACT
>Seq0003
ACGACGACACGACGACGACGAGCAGCAGCA
EOF


cat > expected1 <<EOF
true
EOF

cat > expected2 <<EOF
false
EOF

goalign identical -i input1 -c input2 > result
diff expected1 result

goalign identical -i input1 -c input3 > result
diff expected2 result

goalign identical -i input1 -c input4 > result
diff expected2 result

rm -f input1 input2 input3 input4 expected1 expected2 results


echo "->goalign phase"
cat > input <<EOF
>allcodons
GCTGCCGCAGCGTTATTGCTTCTCCTACTGCGTCGCCGACGGAGAAGGAAAAAGAATAACATG
GATGACTTTTTCTGTTGCCCTCCCCCACCGCAACAGTCTTCCTCATCGAGTAGCGAAGAGACT
ACCACAACGGGTGGCGGAGGGTGGCATCACTATTACATTATCATAGTTGTCGTAGTGTAATGA
TAGC
>allcodons2
GCTGCAGCGTTATTGCTTCTCCTACTGCGTCGCCGACGGAGAAGGAAAAAGAATAACATG
GATGACTTTTTCTGTTGCCCTCCCCCACCGCAACAGTCTTCCTCATCGAGTAGCGAAGAGACT
ACCACAACGGGTGGCGGAGGGTGGCATCACTATTACATTATCATAGTTGTCGTATAATGA
EOF
cat > expected <<EOF
>allcodons
ATGGATGACTTTTTCTGTTGCCCTCCCCCACCGCAACAGTCTTCCTCATCGAGTAGCGAAGAGACTACCACAACGGGTGG
CGGAGGGTGGCATCACTATTACATTATCATAGTTGTCGTAGTGTAATGATAGC
>allcodons2
ATGGATGACTTTTTCTGTTGCCCTCCCCCACCGCAACAGTCTTCCTCATCGAGTAGCGAAGAGACTACCACAACGGGTGG
CGGAGGGTGGCATCACTATTACATTATCATAGTTGTCGTATAATGA
EOF

cat > expected.aa <<EOF
>allcodons
MDDFFCCPPPPQQSSSSSSEETTTTGGGGWHHYYIIIVVVV***
>allcodons2
MDDFFCCPPPPQQSSSSSSEETTTTGGGGWHHYYIIIVVV**
EOF

goalign phase -i input --unaligned -o result --aa-output result.aa
diff expected result
diff expected.aa result.aa
rm -f input expected result expected.aa result.aa

echo "->goalign sw (smith & waterman)"
cat > input <<EOF
>allcodons
GCTGCCGCAGCGTTATTGCTTCTCCTACTGCGTCGCCGACGGAGAAGGAAAAAGAATAACATG
GATGACTTTTTCTGTTGCCCTCCCCCACCGCAACAGTCTTCCTCATCGAGTAGCGAAGAGACT
ACCACAACGGGTGGCGGAGGGTGGCATCACTATTACATTATCATAGTTGTCGTAGTGTAATGA
TAGC
>allcodons2
GCTGCAGCGTTATTGCTTCTCCTACTGCGTCGCCGACGGAGAAGGAAAAAGAATAACATG
GATGACTTTTTCTGTTGCCCTCCCCCACCGCAACAGTCTTCCTCATCGAGTAGCGAAGAGACT
ACCACAACGGGTGGCGGAGGGTGGCATCACTATTACATTATCATAGTTGTCGTATAATGA
EOF
cat > expected <<EOF
   2   189
allcodons  GCTGCCGCAG CGTTATTGCT TCTCCTACTG CGTCGCCGAC GGAGAAGGAA AAAGAATAAC
allcodons2  GCTGC---AG CGTTATTGCT TCTCCTACTG CGTCGCCGAC GGAGAAGGAA AAAGAATAAC

   ATGGATGACT TTTTCTGTTG CCCTCCCCCA CCGCAACAGT CTTCCTCATC GAGTAGCGAA
   ATGGATGACT TTTTCTGTTG CCCTCCCCCA CCGCAACAGT CTTCCTCATC GAGTAGCGAA

   GAGACTACCA CAACGGGTGG CGGAGGGTGG CATCACTATT ACATTATCAT AGTTGTCGTA
   GAGACTACCA CAACGGGTGG CGGAGGGTGG CATCACTATT ACATTATCAT AGTTGTCGTA

   GTGTAATGA
   -T--AATGA
EOF

goalign sw -i input -o result -p
diff expected result
rm -f input expected result

