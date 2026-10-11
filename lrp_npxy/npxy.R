# NPxY motifs in the cytoplasmic tails of human LRP-family receptors (+ VLDLR, SORL1)
# Windows of +/-10 residues anchored on N of each NPxY (ungapped, motif-anchored alignment).
suppressPackageStartupMessages({library(Biostrings); library(ggplot2)})
s <- readAAStringSet("lrp_verified.fasta"); names(s) <- sub(".*\\|", "", names(s))
app <- "MLPGLALLLLAAWTARALEVPTDGNAGLLAEPQIAMFCGRLNMHMNVQNGKWDSDPSGTKTCIDTKEGILQYCQEVYPELQITNVVEANQPVTIQNWCKRGRKQCKTHPHFVIPYRCLVGEFVSDALLVPDKCKFLHQERMDVCETHLHWHTVAKETCSEKSTNLHDYGMLLPCGIDKFRGVEFVCCPLAEESDNVDSADAEEDDSDVWWGGADTDYADGSEDKVVEVAEEEEVAEVEEEEADDDEDDEDGDEVEEEAEEPYEEATERTTSIATTTTTTTESVEEVVREVCSEQAETGPCRAMISRWYFDVTEGKCAPFFYGGCGGNRNNFDTEEYCMAVCGSAMSQSLLKTTQEPLARDPVKLPTTAASTPDAVDKYLETPGDENEHAHFQKAKERLEAKHRERMSQVMREWEEAERQAKNLPKADKKAVIQHFQEKVESLEQEAANERQQLVETHMARVEAMLNDRRRLALENYITALQAVPPRPRHVFNMLKKYVRAEQKDRQHTLKHFEHVRMVDPKKAAQIRSQVMTHLRVIYERMNQSLSLLYNVPAVAEEIQDEVDELLQKEQNYSDDVLANMISEPRISYGNDALMPSLTETKTTVELLPVNGEFSLDDLQPWHSFGADSVPANTENEVEPVDARPAADRGLTTRPGSGLTNIKTEEISEVKMDAEFRHDSGYEVHHQKLVFFAEDVGSNKGAIIGLMVGGVVIATVIVITLVMLKKKQYTSIHHGVVEVDAAVTPEERHLSKMQQNGYENPTYKFFEQMQN"
tm_end <- c(LRP1=4444, LRP1B=4467, LRP2=4446, LRP3=517, LRP4=1746, LRP5=1407, LRP6=1393,
            LRP8=847, LRP10=461, LRP11=473, LRP12=513, VLDLR=819, SORL1=2158)
fl <- 10
rows <- list(); absent <- c()
for (g in names(tm_end)) {
  seq <- as.character(s[[g]]); tail <- substr(seq, tm_end[g] + 1, nchar(seq))
  hits <- gregexpr("(?=NP.Y)", tail, perl = TRUE)[[1]]
  if (hits[1] == -1) { absent <- c(absent, g); next }
  for (k in seq_along(hits)) {
    p <- unname(tm_end[g]) + hits[k]                      # position of N
    w <- sapply((p - fl):(p + 3 + fl), function(i) if (i < 1 || i > nchar(seq)) "-" else substr(seq, i, i))
    rows[[length(rows) + 1]] <- data.frame(gene = g, motif = k, nmot = length(hits), pos = p,
      dist = hits[k], col = seq_along(w), aa = w)
  }
}
D <- do.call(rbind, rows)
# Two blocks, each compared with its LRP1 motif: membrane-proximal (motif 1 / single motif) and distal (motif 2)
D$block <- ifelse(D$motif == 2, "distal", "proximal")
D$isref <- D$gene == "LRP1"
D$label <- with(D, sprintf("%s%s  NPxY%s   N%d  (TM+%d)", gene, ifelse(isref, " (ref)", ""),
                           ifelse(nmot > 1, motif, ""), pos, dist))
D <- D[order(D$block != "proximal", !D$isref, D$dist), ]
ord <- unique(D$label)
D$label <- factor(D$label, levels = rev(ord))
refaa <- with(subset(D, isref), setNames(aa, paste(block, col)))
D$refaa <- refaa[paste(D$block, D$col)]
mot <- (fl + 1):(fl + 4)
D$cls <- ifelse(D$isref, "LRP1 reference",
          ifelse(D$aa == "-", "gap",
          ifelse(D$aa == D$refaa, "identical to LRP1", "different from LRP1")))
D$cls[D$col %in% mot[c(1, 2, 4)] & D$aa == c("N","P","-","Y")[pmax(1, pmin(4, D$col - fl))]] <- "NPxY core (N, P, Y)"
D$txt <- ifelse(D$cls %in% c("NPxY core (N, P, Y)", "LRP1 reference"), "white", "black")
D$big <- D$col == mot[4]
nprox <- length(unique(D$label[D$block == "proximal"]))
nr <- length(ord)
lab_x <- c(-(fl):-1, "N", "P", "x", "Y", 1:fl)
p <- ggplot(D, aes(col, label, fill = cls)) +
  geom_tile(colour = "white", linewidth = .5) +
  geom_text(data = subset(D, !big), aes(label = aa, colour = txt), family = "mono", fontface = "bold", size = 4) +
  geom_text(data = subset(D, big), aes(label = aa), colour = "black", family = "mono", fontface = "bold", size = 5.6) +
  scale_colour_identity() +
  annotate("rect", xmin = min(mot) - .5, xmax = max(mot) + .5, ymin = .5, ymax = nr + .5, fill = NA, colour = "black", linewidth = 1) +
  annotate("text", x = mean(mot), y = nr + .95, label = "NPxY", fontface = "bold", size = 4.2) +
  geom_hline(yintercept = nr - nprox + .5, linewidth = .9, colour = "grey30") +
  annotate("text", x = length(lab_x) + 1, y = nr - nprox / 2 + .5, label = "membrane-proximal", angle = -90, size = 3.3, colour = "grey30") +
  annotate("text", x = length(lab_x) + 1, y = (nr - nprox) / 2 + .5, label = "distal", angle = -90, size = 3.3, colour = "grey30") +
  scale_fill_manual(values = c(`NPxY core (N, P, Y)` = "#00A651", `LRP1 reference` = "#B2182B",
                               `identical to LRP1` = "#F4A582", `different from LRP1` = "grey88", gap = "white"),
                    breaks = c("NPxY core (N, P, Y)", "LRP1 reference", "identical to LRP1", "different from LRP1"), name = NULL) +
  scale_x_continuous(breaks = seq_along(lab_x), labels = lab_x, expand = c(0, 0)) +
  scale_y_discrete(expand = expansion(add = c(.5, 1.6))) +
  coord_cartesian(xlim = c(.5, length(lab_x) + .5), clip = "off") +
  labs(x = "Position relative to NPxY (residues)", y = NULL,
       title = "NPxY motifs in the cytoplasmic tails of human LRP-family receptors",
       subtitle = paste0("Human paralogues, not species. Windows anchored on each NPxY (+/-", fl,
                         " residues).\nEach block is compared with its LRP1 motif (red). ",
                         "No NPxY in tail: ", paste(absent, collapse = ", "), ".")) +
  theme_minimal(base_size = 11) +
  theme(panel.grid = element_blank(), legend.position = "bottom", plot.margin = margin(5, 30, 5, 5),
        axis.text.y = element_text(family = "mono", size = 10),
        plot.background = element_rect(fill = "white", colour = NA))
ggsave("fig8_LRP_NPxY.png", p, width = 12, height = 6, dpi = 300, device = ragg::agg_png)
write.csv(unique(D[, c("gene","motif","pos","dist","block")]), "NPxY_positions.csv", row.names = FALSE)
print(unique(D[, c("gene","motif","pos","dist")])); cat("absent:", absent, "\n")
