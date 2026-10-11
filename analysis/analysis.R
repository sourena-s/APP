# APP family evolution: tree, conservation, Abeta alignment
# Inputs: all_aln.fasta (APP+APLP1+APLP2, MAFFT L-INS-i), app_aln.fasta (APP orthologues only),
#         tree.contree (IQ-TREE LG+G4, 1000 ultrafast bootstraps)
suppressPackageStartupMessages({library(ape); library(Biostrings); library(ggplot2)
  library(ggseqlogo); library(patchwork)})

short <- function(h) {             # "P05067|APP|Homo sapiens" -> "APP Homo sapiens"
  p <- strsplit(h, "|", fixed = TRUE)[[1]]; paste(p[2], p[3]) }
fam <- function(h) ifelse(grepl("APLP1", h), "APLP1", ifelse(grepl("APLP2", h), "APLP2",
              ifelse(grepl("-like|APPL|APL-1", h), "Invertebrate APP-like", "APP")))
cols <- c(APP = "#B2182B", APLP1 = "#2166AC", APLP2 = "#1B7837", `Invertebrate APP-like` = "#6A3D9A")

## ---------- 1. Phylogenetic tree ----------
tr <- read.tree("tree.contree")
out <- grep("Caenorhabditis|Drosophila|Aplysia|Doryteuthis", tr$tip.label, value = TRUE)
tr <- tryCatch(root(tr, outgroup = out, resolve.root = TRUE),
               error = function(e) { message("outgroup not monophyletic; midpoint root"); phangorn::midpoint(tr) })
tr <- ladderize(tr)
hdrs <- names(readAAStringSet("all_aln.fasta"))
acc <- sub("\\|.*", "", hdrs); names(hdrs) <- acc
tacc <- sub("[|_].*", "", tr$tip.label)
tipfam <- fam(hdrs[tacc])
tr$tip.label <- vapply(hdrs[tacc], short, "")
png("fig1_tree.png", width = 2400, height = 2600, res = 300)
par(mar = c(1, 1, 3, 1))
plot(tr, tip.color = cols[tipfam], cex = 0.75, label.offset = 0.02, no.margin = FALSE,
     main = "APP gene family: maximum-likelihood tree (IQ-TREE, LG+G4)")
bs <- suppressWarnings(as.numeric(tr$node.label))
nodelabels(ifelse(!is.na(bs) & bs >= 70, bs, ""), frame = "none", cex = 0.55, adj = c(1.2, -0.4), col = "grey30")
add.scale.bar(cex = 0.7)
legend("topright", legend = names(cols), text.col = cols, bty = "n", cex = 0.8)
mtext("Rooted on protostome APP-like proteins; node labels = UFBoot support >= 70", cex = 0.7)
dev.off()

## ---------- 2. Conservation along human APP ----------
aln <- readAAStringSet("app_aln.fasta")
m <- as.matrix(aln); rownames(m) <- vapply(names(aln), short, "")
hrow <- grep("APP Homo sapiens", rownames(m))
keep <- m[hrow, ] != "-"
hum  <- m[hrow, keep]; sub <- m[, keep, drop = FALSE]
isvert <- !grepl("-like|APPL|APL-1", names(aln))
idall  <- colMeans(sub == matrix(hum, nrow(sub), length(hum), byrow = TRUE))
idvert <- colMeans(sub[isvert, ] == matrix(hum, sum(isvert), length(hum), byrow = TRUE))
df <- data.frame(pos = seq_along(hum), aa = hum, all = idall, vert = idvert)
df$inv_all  <- df$all == 1; df$inv_vert <- df$vert == 1
roll <- function(x, k = 15) as.numeric(stats::filter(x, rep(1/k, k), sides = 2))
df$roll_all <- roll(df$all); df$roll_vert <- roll(df$vert)
write.csv(df, "APP_conservation_by_residue.csv", row.names = FALSE)

dom <- data.frame(name = c("GFLD", "CuBD", "Acidic", "KPI", "E2", "Abeta", "TM", "AICD"),
  start = c(28, 124, 190, 291, 374, 672, 700, 724), end = c(123, 189, 290, 341, 565, 713, 723, 770))
p2 <- ggplot(df, aes(pos)) +
  geom_rect(data = dom, inherit.aes = FALSE, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            fill = "grey90") +
  geom_text(data = dom, inherit.aes = FALSE, aes(x = (start + end)/2, y = 1.08, label = name), size = 3) +
  geom_line(aes(y = roll_vert, colour = sprintf("Vertebrates (n=%d)", sum(isvert))), linewidth = .7, na.rm = TRUE) +
  geom_line(aes(y = roll_all, colour = sprintf("All animals (n=%d)", nrow(sub))), linewidth = .7, na.rm = TRUE) +
  geom_point(data = subset(df, inv_all), aes(y = -0.04), shape = 124, size = 3, colour = "#B2182B") +
  scale_colour_manual(values = c("#B2182B", "#2166AC"), name = NULL) +
  scale_y_continuous(limits = c(-0.06, 1.12), breaks = seq(0, 1, .25)) +
  labs(x = "Human APP770 residue", y = "Identity to human (15-aa rolling mean)",
       title = "Conservation of APP orthologues mapped onto human APP",
       subtitle = "Red ticks: residues invariant across all APP orthologues, worm to human") +
  theme_minimal(base_size = 11) + theme(legend.position = "top", plot.background = element_rect(fill = "white", colour = NA))
ggsave("fig2_conservation.png", p2, width = 12, height = 4.5, dpi = 300)

## ---------- 3. Abeta region alignment (all 29 sequences) ----------
A <- readAAStringSet("all_aln.fasta"); M <- as.matrix(A)
rownames(M) <- vapply(names(A), short, ""); ff <- fam(names(A))
hcol <- which(cumsum(M["APP Homo sapiens", ] != "-") %in% 662:723 & M["APP Homo sapiens", ] != "-")
first <- min(hcol); last <- max(hcol)
cols_keep <- (first:last)[M["APP Homo sapiens", first:last] != "-"]
R <- M[, cols_keep]
hpos <- cumsum(M["APP Homo sapiens", ] != "-")[cols_keep]
ord <- order(factor(ff, levels = names(cols)), rownames(R))
R <- R[ord, ]; ffo <- ff[ord]
ref <- R["APP Homo sapiens", ]
long <- expand.grid(row = seq_len(nrow(R)), col = seq_len(ncol(R)))
long$aa <- R[cbind(long$row, long$col)]
long$same <- long$aa == ref[long$col] & long$aa != "-"
long$label <- factor(rownames(R)[long$row], levels = rev(rownames(R)))
abeta <- range(which(hpos %in% 672:713 & ref != "-"))
xl <- ifelse(ref != "-" & (hpos - 671) %in% c(1, 10, 20, 30, 40, 42), hpos - 671, "")
p3 <- ggplot(long, aes(col, label)) +
  geom_tile(aes(fill = ifelse(aa == "-", "gap", ifelse(same, "identical to human", "different"))),
            colour = "white", linewidth = .2) +
  geom_text(aes(label = aa), size = 2.3, family = "mono") +
  annotate("rect", xmin = abeta[1] - .5, xmax = abeta[2] + .5, ymin = .5, ymax = nrow(R) + .5,
           fill = NA, colour = "black", linewidth = .6) +
  scale_fill_manual(values = c(`identical to human` = "#F4A582", different = "grey95", gap = "white"), name = NULL) +
  scale_x_continuous(breaks = seq_along(ref), labels = xl, expand = c(0, 0)) +
  labs(x = "Abeta residue (human numbering; box = Abeta1-42)", y = NULL,
       title = "Abeta region across the APP family",
       subtitle = "Human APP 662-723 (columns where human has a gap removed); APLP1/2 and invertebrates lack a conserved Abeta") +
  theme_minimal(base_size = 9) +
  theme(panel.grid = element_blank(), legend.position = "top", plot.background = element_rect(fill = "white", colour = NA),
        axis.text.y = element_text(colour = cols[rev(ffo)]))
ggsave("fig3_abeta_alignment.png", p3, width = 12, height = 7, dpi = 300)

# Sequence logo of Abeta1-42 across APP orthologues only
appr <- which(ffo == "APP")
ab <- apply(R[appr, abeta[1]:abeta[2]], 1, paste, collapse = "")
p4 <- ggseqlogo(ab, seq_type = "aa", method = "prob") +
  labs(title = sprintf("Abeta1-42 sequence logo across %d vertebrate APP orthologues", length(ab)),
       x = "Abeta position (alignment column)") + theme(legend.position = "none", plot.background = element_rect(fill = "white", colour = NA))
ggsave("fig4_abeta_logo.png", p4, width = 11, height = 3, dpi = 300)

## ---------- console summary ----------
cat(sprintf("Invariant across all %d APP orthologues: %d of %d human residues\n",
            nrow(sub), sum(df$inv_all), nrow(df)))
cat(paste0(df$aa[df$inv_all], df$pos[df$inv_all], collapse = " "), "\n")
cat(sprintf("Invariant across %d vertebrate APPs: %d residues\n", sum(isvert), sum(df$inv_vert)))
ab42 <- 672:713
cat("Abeta1-42 identity to human per species:\n")
hab <- R["APP Homo sapiens", abeta[1]:abeta[2]]
print(sort(round(apply(R[, abeta[1]:abeta[2]], 1, function(r) mean(r == hab)), 2), decreasing = TRUE))
