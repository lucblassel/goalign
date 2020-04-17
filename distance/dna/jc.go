package dna

import (
	"fmt"
	"math"

	"github.com/evolbioinfo/goalign/align"
)

type JCModel struct {
	numSites      float64 // Number of selected sites (no gaps)
	selectedSites []bool  // true for selected sites
	removegaps    bool    // If true, we will remove posision with >=1 gaps
	gamma         bool
	alpha         float64
	sequenceCodes [][]int // Sequences converted into int codes
}

func NewJCModel(removegaps bool) *JCModel {
	return &JCModel{
		0,
		nil,
		removegaps,
		false,
		0.,
		nil,
	}
}

/* computes JC69 distance between 2 sequences */
func (m *JCModel) Distance(seq1 []int, seq2 []int, weights []float64) (float64, error) {
	var dist float64
	diff, total := countDiffs(seq1, seq2, m.selectedSites, weights)
	diff = diff / total
	b := 1. - 4.*diff/3.
	if m.gamma {
		dist = .75 * m.alpha * (math.Pow(b, -1./m.alpha) - 1.)
	} else {
		dist = -.75 * math.Log(b)
	}
	if dist > 0 {
		return dist, nil
	} else {
		return 0, nil
	}
}

func (m *JCModel) InitModel(al align.Alignment, weights []float64, gamma bool, alpha float64) (err error) {
	m.gamma = gamma
	m.alpha = alpha
	m.numSites, m.selectedSites = selectedSites(al, weights, m.removegaps)
	m.sequenceCodes, err = alignmentToCodes(al)
	return
}

// Sequence returns the ith sequence of the alignment
// encoded in int
func (m *JCModel) Sequence(i int) (seq []int, err error) {
	if i < 0 || i >= len(m.sequenceCodes) {
		err = fmt.Errorf("This sequence does not exist: %d", i)
		return
	}
	seq = m.sequenceCodes[i]
	return
}
