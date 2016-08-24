package phylip

import (
	"bytes"
	"fmt"
	"github.com/fredericlemoine/goalign/align"
)

const (
	PHYLIP_LINE  = 60
	PHYLIP_BLOCK = 10
)

func min_int(a int, b int) int {
	if a < b {
		return a
	}
	return b
}

func WriteAlignment(al align.Alignment) string {
	var buf bytes.Buffer
	var header bool = true
	cursize := 0
	buf.WriteString(fmt.Sprintf("  %d   %d\n", al.NbSequences(), al.Length()))
	for cursize < al.Length() {
		if cursize > 0 {
			buf.WriteString("\n")
		}
		al.Iterate(func(name string, seq string) {
			if header {
				buf.WriteString(name)
				buf.WriteString("  ")
			}

			for i := cursize; i < cursize+PHYLIP_LINE && i < len(seq); i += PHYLIP_BLOCK {
				if i > cursize {
					buf.WriteString(" ")
				}
				end := min_int(i+PHYLIP_BLOCK, len(seq))
				buf.WriteString(seq[i:end])
			}
			buf.WriteString("\n")
		})
		cursize += PHYLIP_LINE
		header = false
	}
	return buf.String()
}
