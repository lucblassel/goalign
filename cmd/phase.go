package cmd

import (
	"fmt"
	"os"
	"strings"

	"github.com/fredericlemoine/goalign/align"
	"github.com/fredericlemoine/goalign/io"
	"github.com/spf13/cobra"
)

var phaseOutput string
var phaseAAOutput string
var phaseLogOutput string
var orfsequence string
var lencutoff float64
var matchcutoff float64
var phasereverse bool
var phasecutend bool

// translateCmd represents the addid command
var phaseCmd = &cobra.Command{
	Use:   "phase",
	Short: "Find best ATGs and set them as new start positions",
	Long: `Find best ATGs and set them as new start positions.

if --unaligned is set, format options are ignored (phylip, nexus, etc.), and
only Fasta is accepted.

If input sequences are not nucleotidic, then returns an error.

Output files:

1) --output : unaligned set of phased sequences in fasta
2) --aa-output: unaligned set of phased aa sequencs in fasta

Phase command will:
1. Search for the longest ORF in the dataset if no reference orf is given;
1. Translate the given ORF in aminoacids;
2. For each sequence of the dataset: translate it in the 3 phases (forward strand only),
   align it with the translated orf, and take the phase giving the best alignment; If no phase
   gives a good alignment (>80% orf length, and starting at first position of the ORF), then
   the sequence is discarded;
3. For each sequence, take the Start corresponding to the Start of the ORF, and remove
   nucleotides before;
4. Return the trimmed nucleotidic sequences (phased), the corresponding amino-acid sequences (phasedaa)
   and the positions of starts in the nucleotidic sequences.
`,
	RunE: func(cmd *cobra.Command, args []string) (err error) {
		var f, aaf, logf *os.File
		var phased chan align.PhasedSequence
		var inseqs align.SeqBag
		var reforf align.SeqBag
		var orf align.Sequence

		if f, err = openWriteFile(phaseOutput); err != nil {
			io.LogError(err)
			return
		}
		defer closeWriteFile(f, phaseOutput)

		if aaf, err = openWriteFile(phaseAAOutput); err != nil {
			io.LogError(err)
			return
		}
		defer closeWriteFile(aaf, phaseAAOutput)

		if unaligned {
			if inseqs, err = readsequences(infile); err != nil {
				io.LogError(err)
				return
			}
		} else {
			var aligns align.AlignChannel

			if aligns, err = readalign(infile); err != nil {
				io.LogError(err)
				return
			}
			inseqs = (<-aligns.Achan).Unalign()
		}

		if orfsequence != "none" {
			if reforf, err = readsequences(orfsequence); err != nil {
				io.LogError(err)
				return
			}
			if reforf.NbSequences() < 1 {
				err = fmt.Errorf("Reference ORF file should contain at least one sequence")
				io.LogError(err)
				return
			}
		} else {
			// We detect the orf
			if orf, err = inseqs.LongestORF(phasereverse); err != nil {
				io.LogError(err)
				return
			}
			orf.SetName(orf.Name() + "_LongestORF")
			reforf = align.NewSeqBag(align.UNKNOWN)
			reforf.AddSequenceChar(orf.Name(), orf.SequenceChar(), orf.Comment())
			reforf.AutoAlphabet()
		}

		phaser := align.NewPhaser()
		phaser.SetLenCutoff(lencutoff)
		phaser.SetMatchCutoff(matchcutoff)
		phaser.SetReverse(phasereverse)
		phaser.SetCutEnd(phasecutend)
		phaser.SetCpus(rootcpus)
		phaser.SetTranslate(true)

		if phased, err = phaser.Phase(reforf, inseqs); err != nil {
			io.LogError(err)
			return
		}

		if logf, err = openWriteFile(phaseLogOutput); err != nil {
			io.LogError(err)
			return
		}
		defer closeWriteFile(logf, phaseLogOutput)

		fmt.Fprintf(logf, "Detected/Given ORF: %s\n", reforf.String())
		fmt.Fprintf(logf, "SeqName\tStartPosition\tExtractedSequenceLength\tFirstStop\n")
		phasedseqs := align.NewSeqBag(align.UNKNOWN)
		phasedseqsaa := align.NewSeqBag(align.UNKNOWN)
		for p := range phased {
			if p.Err != nil {
				err = p.Err
				io.LogError(p.Err)
				return
			}
			if p.Removed {
				fmt.Fprintf(logf, "%s\tRemoved\tN/A\n", p.NtSeq.Name())
			} else {
				phasedseqs.AddSequence(p.NtSeq.Name(), p.NtSeq.Sequence(), p.NtSeq.Comment())
				phasedseqsaa.AddSequence(p.AaSeq.Name(), p.AaSeq.Sequence(), p.AaSeq.Comment())
				fmt.Fprintf(logf, "%s\t%d\t%d\t%d\n", p.NtSeq.Name(), p.Position, p.AaSeq.Length(), strings.Index(p.AaSeq.Sequence(), "*"))
			}
		}

		writeSequences(phasedseqs, f)
		writeSequences(phasedseqsaa, aaf)

		return
	},
}

func init() {
	RootCmd.AddCommand(phaseCmd)
	phaseCmd.PersistentFlags().StringVarP(&phaseOutput, "output", "o", "stdout", "Output ATG \"phased\" FASTA file")
	phaseCmd.PersistentFlags().StringVar(&phaseAAOutput, "aa-output", "none", "Output Met \"phased\" aa FASTA file")
	phaseCmd.PersistentFlags().StringVarP(&phaseLogOutput, "log", "l", "none", "Output log: positions of the considered ATG for each sequence")
	phaseCmd.PersistentFlags().Float64Var(&lencutoff, "len-cutoff", -1.0, "Length cutoff, over orf length, to consider sequence hits (-1==No cutoff)")
	phaseCmd.PersistentFlags().Float64Var(&matchcutoff, "match-cutoff", .5, "Nb Matches cutoff, over alignment length, to consider sequence hits (-1==No cutoff)")
	phaseCmd.PersistentFlags().BoolVar(&unaligned, "unaligned", false, "Considers sequences as unaligned and only format fasta is accepted (phylip, nexus,... options are ignored)")
	phaseCmd.PersistentFlags().BoolVar(&phasereverse, "reverse", false, "Search ALSO in the reverse strand (in addition to the forward strand)")
	phaseCmd.PersistentFlags().BoolVar(&phasecutend, "cut-end", false, "Iftrue, then also remove the end of sequences that do not align with orf")
	phaseCmd.PersistentFlags().StringVar(&orfsequence, "ref-orf", "none", "Reference ORF to phase against (if none is given, then will try to get the longest orf in the input data)")
}
