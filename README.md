# APP family evolution: orthologues, paralogues and conserved residues

Comparative analysis of the amyloid precursor protein (APP) family from *C. elegans* APL-1 to human APP, including the vertebrate paralogues APLP1 and APLP2.

![Overview](figures/fig7_overview_with_zooms.png)

## Sequences

29 UniProt entries (`analysis/verified.fasta`). Every sequence was checked against UniProt's CRC64 checksum and length (`analysis/parse.py`).

| Group | Species |
|---|---|
| APP orthologues (17) | human, chimpanzee, mouse, chicken, *Xenopus tropicalis*, coelacanth, zebrafish appa/appb, fugu, ghost shark, sea lamprey; APP-like in amphioxus, sea urchin, *Aplysia*, squid, *Drosophila* (APPL), *C. elegans* (APL-1) |
| APLP1 (5) | human, mouse, *Xenopus*, zebrafish, coelacanth |
| APLP2 (7) | human, mouse, chicken, *Xenopus*, zebrafish, coelacanth, ghost shark |

Some unreviewed entries are fragments or contain likely gene-model artefacts. Coelacanth APP H2ZW72 and chicken APP A0A8V0Y745 are N-terminally truncated, and the chicken entry also has an internal insertion.

## Methods

- **Alignment:** MAFFT L-INS-i (`--localpair --maxiterate 1000`)
  - all 29 sequences → `all_aln.fasta`
  - the 17 APP orthologues → `app_aln.fasta`
- **Tree:** IQ-TREE 2, LG+G4, 1000 ultrafast bootstraps (`tree.contree`). Rooted on the protostome APP-like proteins.
- **Conservation:** each orthologue is compared to human APP770 at every human residue. "Invariant" means identical in all 17 APP orthologues.
- **Divergence times:** approximate published estimates of when each lineage split from ours, used only to order the rows.

## Key results

- **Invariant residues:** 27 human APP residues are identical in all 17 orthologues. They cluster in:
  - the copper-binding domain cysteines and the C186–C187–P188 run
  - the E2 domain (W413, D427 and the metal-binding H457/H507/H514)
  - the cytoplasmic tail: M752–Q753 and the full **GYENPTY** motif (756–762)
- **GYENPTY:** also identical in every APLP1 and APLP2 sequence, i.e. all 29 proteins. Y757 (Y682 in APP695) is the phosphorylated tyrosine.
- **Aβ1–42:** conserved across jawed vertebrates (83–100% identity to human). It is absent from APLP1, APLP2 and the invertebrate APP-like proteins. Mouse differs from human at R5G, Y10F and H13R.

## Figures

| File | Content |
|---|---|
| `fig1_tree.png` | ML tree of the APP family |
| `fig2_conservation.png` | Rolling identity to human along APP770 |
| `fig3_abeta_alignment.png` | Aβ region across all 29 sequences |
| `fig4_abeta_logo.png` | Aβ1–42 sequence logo, vertebrate APP |
| `fig5_conservation_map.png` | Full-length orthologue map, species ordered by divergence |
| `zoomB_CCP.png`, `zoomF_GYENPTY.png` | 43-residue zooms on contiguous invariant runs |
| `zoomAbeta.png` | Abeta1-42 (APP770 672-713) across the 17 orthologues |
| `fig7_overview_with_zooms.png` | Composite of the map and both zooms |

## Reproduce

All of these steps run from `analysis/`.

**Requirements:**
- R ≥ 4.3 with Biostrings, ggplot2, ape, ggseqlogo, ggrepel, patchwork, ragg and png
- MAFFT and IQ-TREE 2
- Python 3 with Biopython and Pillow

**Commands:**
```bash
python3 parse.py                       # verify sequences -> verified.fasta
mafft --localpair --maxiterate 1000 verified.fasta > all_aln.fasta
mafft --localpair --maxiterate 1000 app_only.fasta > app_aln.fasta
iqtree2 -s all_aln.fasta -m LG+G4 -B 1000 -T AUTO --prefix tree
Rscript analysis.R                     # fig1-4 + conservation CSV
Rscript zooms.R                        # fig5 + zoom panels (sources fig5.R)
python3 compose.py                     # fig7 composite
```

Organism icons are rendered from Noto Color Emoji (Apache 2.0).
