# NPxY windows (+/-10) anchored on N; one reference row, every other row coloured by identity to it.
suppressPackageStartupMessages({library(Biostrings); library(ggplot2)})
fl <- 10
win <- function(seq, p) sapply((p - fl):(p + 3 + fl), function(i) if (i < 1 || i > nchar(seq)) "-" else substr(seq, i, i))
scan_tail <- function(gene, seq, tm_end) {
  tail <- substr(seq, tm_end + 1, nchar(seq)); h <- gregexpr("(?=NP.Y)", tail, perl = TRUE)[[1]]
  if (h[1] == -1) return(NULL)
  do.call(rbind, lapply(seq_along(h), function(k) { p <- tm_end + h[k]
    data.frame(gene = gene, motif = k, nmot = length(h), pos = p, dist = h[k], col = seq_len(2 * fl + 4), aa = win(seq, p)) }))
}

plot_npxy <- function(D, ref_id, file, title, subtitle) {
  D$id <- paste(D$gene, D$motif)
  D$label <- with(D, sprintf("%s  NPxY%s   N%d  (TM+%d)", gene, ifelse(nmot > 1, motif, ""), pos, dist))
  D$label[D$id == ref_id] <- paste0(D$label[D$id == ref_id], "  [ref]")
  ids <- unique(D$id[order(D$id != ref_id, D$dist)])
  D$label <- factor(D$label, levels = rev(unique(D$label[match(ids, D$id)])))
  ref <- setNames(D$aa[D$id == ref_id], D$col[D$id == ref_id])
  mot <- (fl + 1):(fl + 4); expct <- c("N", "P", "-", "Y")
  D$cls <- ifelse(D$id == ref_id, "reference",
           ifelse(D$aa == "-", "gap", ifelse(D$aa == ref[as.character(D$col)], "identical to reference", "different")))
  core <- D$col %in% mot[c(1, 2, 4)]
  D$cls[core & D$aa == expct[pmax(1, pmin(4, D$col - fl))]] <- "NPxY core (N, P, Y)"
  D$txt <- ifelse(D$cls %in% c("NPxY core (N, P, Y)", "reference"), "white", "black")
  D$big <- D$col == mot[4]
  nr <- length(ids); lab_x <- c(-(fl):-1, "N", "P", "x", "Y", 1:fl)
  p <- ggplot(D, aes(col, label, fill = cls)) +
    geom_tile(colour = "white", linewidth = .5) +
    geom_text(data = subset(D, !big), aes(label = aa, colour = txt), family = "mono", fontface = "bold", size = 4) +
    geom_text(data = subset(D, big), aes(label = aa), colour = "black", family = "mono", fontface = "bold", size = 5.6) +
    scale_colour_identity() +
    annotate("rect", xmin = min(mot) - .5, xmax = max(mot) + .5, ymin = .5, ymax = nr + .5, fill = NA, colour = "black", linewidth = 1) +
    annotate("text", x = mean(mot), y = nr + .95, label = "NPxY", fontface = "bold", size = 4.2) +
    geom_hline(yintercept = nr - .5, linewidth = .9, colour = "grey30") +
    scale_fill_manual(values = c(`NPxY core (N, P, Y)` = "#00A651", reference = "#B2182B",
                                 `identical to reference` = "#F4A582", different = "grey88", gap = "white"),
                      breaks = c("NPxY core (N, P, Y)", "reference", "identical to reference", "different"), name = NULL) +
    scale_x_continuous(breaks = seq_along(lab_x), labels = lab_x, expand = c(0, 0)) +
    scale_y_discrete(expand = expansion(add = c(.5, 1.6))) +
    coord_cartesian(xlim = c(.5, length(lab_x) + .5), clip = "off") +
    labs(x = "Position relative to NPxY (residues)", y = NULL, title = title, subtitle = subtitle) +
    theme_minimal(base_size = 11) +
    theme(panel.grid = element_blank(), legend.position = "bottom", axis.text.y = element_text(family = "mono", size = 10),
          plot.background = element_rect(fill = "white", colour = NA))
  ggsave(file, p, width = 12, height = 1.6 + .5 * nr + 1.2, dpi = 300, device = ragg::agg_png)
}

## ---- LRP family: two figures, one per LRP1 motif ----
s <- readAAStringSet("../lrp/lrp_verified.fasta"); names(s) <- sub(".*\\|", "", names(s))
tm_end <- c(LRP1=4444, LRP1B=4467, LRP2=4446, LRP3=517, LRP4=1746, LRP5=1407, LRP6=1393,
            LRP8=847, LRP10=461, LRP11=473, LRP12=513, VLDLR=819, SORL1=2158)
L <- do.call(rbind, lapply(names(tm_end), function(g) scan_tail(g, as.character(s[[g]]), tm_end[[g]])))
absentL <- setdiff(names(tm_end), unique(L$gene))
subL <- paste0("Human paralogues. +/-10-residue windows anchored on each NPxY.\nNo NPxY in tail: ", paste(absentL, collapse = ", "), ".")
plot_npxy(L, "LRP1 1", "fig8a_LRP_NPxY_ref_LRP1-NPxY1.png",
          "LRP-family NPxY motifs compared with LRP1 NPxY1 (N4470PTY)", subL)
plot_npxy(L, "LRP1 2", "fig8b_LRP_NPxY_ref_LRP1-NPxY2.png",
          "LRP-family NPxY motifs compared with LRP1 NPxY2 (N4504PVY)", subL)

## ---- Integrins, APP as reference ----
b <- readAAStringSet("itgb_verified.fasta")
I <- do.call(rbind, lapply(names(b), function(h) { f <- strsplit(h, "\\|")[[1]]
  scan_tail(f[2], as.character(b[[h]]), as.integer(f[3])) }))
app <- as.character(readAAStringSet("../verified.fasta")[[1]])
A <- data.frame(gene = "APP", motif = 1, nmot = 1, pos = 759, dist = 759 - 723, col = seq_len(2 * fl + 4), aa = win(app, 759))
absentI <- c(setdiff(c("ITGB1","ITGB2","ITGB3","ITGB4","ITGB5","ITGB6","ITGB7","ITGB8"), unique(I$gene)), "all 18 alpha subunits")
plot_npxy(rbind(A, I), "APP 1", "fig9_integrin_NPxY_ref_APP.png",
          "Integrin NPxY motifs compared with APP (G-Y-E-N759PTY)",
          paste0("Human integrin subunits; +/-10-residue windows anchored on each NPxY in the cytoplasmic tail.\nNo NPxY: ",
                 paste(absentI, collapse = ", "), " (ITGB2 has NPLF/NPKF)."))
write.csv(unique(rbind(L, I)[, c("gene","motif","pos","dist")]), "NPxY_positions_LRP_integrin.csv", row.names = FALSE)
