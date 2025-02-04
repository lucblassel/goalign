package cmd

import (
	"github.com/evolbioinfo/goalign/align"
	"github.com/evolbioinfo/goalign/io"
	"github.com/evolbioinfo/goalign/io/utils"
	"github.com/spf13/cobra"
)

var recombNb float64
var recombProp float64

// recombCmd represents the recomb command
var recombCmd = &cobra.Command{
	Use:   "recomb",
	Short: "Recombine sequences in the input alignment",
	Long: `Recombine of sequences in the input alignment.

It may take Fasta or Phylip input alignment.

If the input alignment contains several alignments, will process all of them

Two options:
1 - The proportion of recommbining sequences. It will take n sequences 
    and will copy/paste a portion of another n sequences;
2 - The proportion of the sequence length to recombine.

Recombine 25% of sequences by 50%:

s1 CCCCCCCCCCCCCC    s1 CCCCCCCCCCCCCC
s2 AAAAAAAAAAAAAA => s2 AAAATTTTTTTAAA
s3 GGGGGGGGGGGGGG    s3 GGGGGGGGGGGGGG
s4 TTTTTTTTTTTTTT    s4 TTTTTTTTTTTTTT

Example of usage:

goalign shuffle recomb -i align.phylip -p -n 1 -l 0.5
goalign shuffle recomb -i align.fasta -r 0.5 -n 1 -l 0.5
`,
	RunE: func(cmd *cobra.Command, args []string) (err error) {
		var aligns *align.AlignChannel
		var f utils.StringWriterCloser

		if aligns, err = readalign(infile); err != nil {
			io.LogError(err)
			return
		}
		if f, err = utils.OpenWriteFile(shuffleOutput); err != nil {
			io.LogError(err)
			return
		}
		defer utils.CloseWriteFile(f, shuffleOutput)

		for al := range aligns.Achan {
			al.Recombine(recombNb, recombProp)
			writeAlign(al, f)
		}

		if aligns.Err != nil {
			err = aligns.Err
			io.LogError(err)
		}
		return
	},
}

func init() {
	shuffleCmd.AddCommand(recombCmd)

	recombCmd.PersistentFlags().Float64VarP(&recombNb, "prop-seq", "n", 0.5, "Proportion of the  sequences to recombine")
	recombCmd.PersistentFlags().Float64VarP(&recombProp, "prop-length", "l", 0.5, "Proportion of length of sequences to recombine")
}
