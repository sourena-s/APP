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
pa <- 759  # APP770 N of NPTY
w <- strsplit(substr(app, pa - fl, pa + 3 + fl), "")[[1]]
ref <- data.frame(gene = "APP", motif = 1, nmot = 1, pos = pa, dist = pa - 723, col = seq_along(w), aa = w)
D <- rbind(ref, do.call(rbind, rows))
D$label <- with(D, ifelse(gene == "APP", sprintf("APP (reference)   N%d", pos),
                   sprintf("%s  NPxY%s   N%d  (TM+%d)", gene, ifelse(nmot > 1, motif, ""), pos, dist)))
ord <- unique(D[order(D$gene != "APP", D$motif, D$dist), "label"])
D$label <- factor(D$label, levels = rev(ord))

# colour: motif core, residue = column consensus (among receptors), different
mot <- (fl + 1):(fl + 4)
rec <- subset(D, gene != "APP")
cons <- tapply(rec$aa, rec$col, function(a) names(which.max(table(a[a != "-"]))))
frac <- tapply(seq_len(nrow(rec)), rec$col, function(i) mean(rec$aa[i] == cons[as.character(rec$col[i[1]])]))
D$cls <- ifelse(D$col %in% mot[c(1, 2, 4)], "NPxY core (N, P, Y)",
          ifelse(D$col == mot[3], "x position",
          ifelse(D$aa == cons[as.character(D$col)] & frac[as.character(D$col)] >= .5, "matches family consensus",
          ifelse(D$aa == "-", "gap", "divergent"))))
expct <- c("N","P","-","Y"); core <- D$col %in% mot[c(1, 2, 4)]
D$cls[core][D$aa[core] != expct[D$col[core] - fl]] <- "divergent"
D$txt <- ifelse(D$cls == "NPxY core (N, P, Y)", "white", "black")
D$big <- D$col == mot[4]

nr <- length(ord)
lab_x <- c(-(fl):-1, "N", "P", "x", "Y", 1:fl)
p <- ggplot(D, aes(col, label, fill = cls)) +
  geom_tile(colour = "white", linewidth = .5) +
  geom_text(data = subset(D, !big), aes(label = aa, colour = txt), family = "mono", fontface = "bold", size = 4) +
  geom_text(data = subset(D, big), aes(label = aa), colour = "black", family = "mono", fontface = "bold", size = 5.6) +
  scale_colour_identity() +
  annotate("rect", xmin = min(mot) - .5, xmax = max(mot) + .5, ymin = .5, ymax = nr + .5, fill = NA, colour = "black", linewidth = 1) +
  annotate("text", x = mean(mot), y = nr + .95, label = "NPxY", fontface = "bold", size = 4.2) +
  geom_hline(yintercept = nr - .5, linewidth = .6, colour = "grey40") +
  scale_fill_manual(values = c(`NPxY core (N, P, Y)` = "#00A651", `x position` = "#9BD7A8",
                               `matches family consensus` = "#F4A582", divergent = "grey88", gap = "white"),
                    breaks = c("NPxY core (N, P, Y)", "x position", "matches family consensus", "divergent"), name = NULL) +
  scale_x_continuous(breaks = seq_along(lab_x), labels = lab_x, expand = c(0, 0)) +
  scale_y_discrete(expand = expansion(add = c(.5, 1.6))) +
  coord_cartesian(clip = "off") +
  labs(x = "Position relative to NPxY (residues)", y = NULL,
       title = "NPxY motifs in the cytoplasmic tails of human LRP-family receptors",
       subtitle = paste0("Human paralogues, not species. Windows anchored on each NPxY (+/-", fl,
                         " residues).\nSalmon = matches the receptor-family consensus at that position. ",
                         "No NPxY in tail: ", paste(absent, collapse = ", "), ".")) +
  theme_minimal(base_size = 11) +
  theme(panel.grid = element_blank(), legend.position = "bottom",
        axis.text.y = element_text(family = "mono", size = 10),
        plot.background = element_rect(fill = "white", colour = NA))
ggsave("fig8_LRP_NPxY.png", p, width = 12, height = 6, dpi = 300, device = ragg::agg_png)
write.csv(unique(D[, c("gene","motif","pos","dist")]), "NPxY_positions.csv", row.names = FALSE)
print(unique(D[, c("gene","motif","pos","dist")])); cat("absent:", absent, "\n")
