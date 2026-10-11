# Full-length APP orthologue map: human on top, species ordered by divergence from human
suppressPackageStartupMessages({library(Biostrings); library(ggplot2); library(ggrepel); library(patchwork)})
source("species_tree.R")
aln <- readAAStringSet("app_aln.fasta"); m <- as.matrix(aln)
acc <- sub("\\|.*", "", names(aln)); rownames(m) <- acc
# Order + approximate divergence time from the human lineage (TimeTree-style medians, Mya)
sp <- data.frame(acc = c("P05067","Q5IS80","P12023","A0A8V0Y745","Q6DJB6","H2ZW72",
                         "Q6NUZ1","Q8UUR9","O93279","V9KDA3","A0ACM8ADC4","A0A9J7KQQ6",
                         "A0A7M7NBE8","E2QDB4","Q06BR2","P14599","Q10651"),
  lab = c("Human APP","Chimpanzee","Mouse","Chicken","Frog (X. tropicalis)","Coelacanth",
          "Zebrafish appa","Zebrafish appb","Fugu","Ghost shark","Sea lamprey","Amphioxus",
          "Sea urchin","Sea hare (Aplysia)","Squid","Fruit fly APPL","C. elegans APL-1"),
  mya = c(0, 6.4, 87, 319, 352, 413, 429, 429, 429, 462, 600, 684, 690, 694, 694, 694, 694))
sp$label <- ifelse(sp$mya == 0, sp$lab, sprintf("%s  ~%g Mya", sp$lab, sp$mya))
m <- m[sp$acc, ]
h <- m["P05067", ]; keep <- h != "-"
M <- m[, keep]; hum <- h[keep]; n <- ncol(M)
same <- M == matrix(hum, nrow(M), n, byrow = TRUE)
frac <- colMeans(same)
inv  <- frac == 1                       # identical in all 17
near <- frac >= 0.9 & !inv              # identical in >=90% (16/17)
cls <- matrix("different", nrow(M), n)
cls[same] <- "identical to human"
cls[M == "-"] <- "gap"
cls[, inv][same[, inv]] <- "invariant in all species"
cls[1, ] <- ifelse(inv, "invariant in all species", ifelse(near, "conserved in 16/17", "human"))
cls[-1, near][same[-1, near]] <- "conserved in 16/17"
long <- data.frame(row = rep(seq_len(nrow(M)), n), pos = rep(seq_len(n), each = nrow(M)),
                   cls = as.vector(cls), aa = as.vector(M))
long$label <- factor(sp$label[long$row], levels = rev(sp$label))
dom <- data.frame(name = c("GFLD","CuBD","Acidic","KPI","E2","Abeta","TM","AICD"),
  start = c(28,124,190,291,374,672,700,724), end = c(123,189,290,341,565,713,723,770))
ytop <- nrow(M) + 1
invd <- data.frame(pos = which(inv), aa = hum[inv])
p <- ggplot(long, aes(pos, label, fill = cls)) +
  geom_tile(height = .9) +
  geom_rect(data = dom, inherit.aes = FALSE, aes(xmin = start - .5, xmax = end + .5,
            ymin = ytop - .45, ymax = ytop + .45), fill = "grey80", colour = "white") +
  geom_text(data = dom, inherit.aes = FALSE, aes(x = (start + end)/2, y = ytop, label = name), size = 3) +
  geom_text(data = invd, inherit.aes = FALSE, aes(x = pos, y = nrow(M) + .0, label = aa),
            size = 1.9, family = "mono", fontface = "bold", colour = "white") +
  geom_text_repel(data = invd, inherit.aes = FALSE, aes(x = pos, y = ytop + .5, label = paste0(aa, pos)),
            nudge_y = 2.2, direction = "x", angle = 90, hjust = 0, size = 2.4, colour = "#00692F",
            segment.colour = "#00A651", segment.size = .25, min.segment.length = 0,
            box.padding = .12, force = 2, max.overlaps = Inf, seed = 1) +
  scale_fill_manual(values = c(`invariant in all species` = "#00A651", `conserved in 16/17` = "#9BD7A8",
                               `identical to human` = "#F4A582", human = "#B2182B",
                               different = "grey88", gap = "white"), name = NULL,
                    breaks = c("invariant in all species","conserved in 16/17","identical to human","different","gap")) +
  scale_x_continuous(breaks = seq(0, 770, 50), expand = c(0, 0)) +
  scale_y_discrete(expand = expansion(add = c(.5, 7))) +
  coord_cartesian(clip = "off") +
  labs(x = "Human APP770 residue", y = NULL,
       title = "APP orthologues ordered by divergence from the human lineage",
       subtitle = sprintf("Green: identical to human in all %d species (%d residues); light green: in 16/17 (%d). Divergence times approximate.",
                          nrow(M), sum(inv), sum(near))) +
  theme_minimal(base_size = 10) +
  theme(panel.grid = element_blank(), legend.position = "bottom",
        plot.background = element_rect(fill = "white", colour = NA))
icon_img <- lapply(sprintf("icons_sci/%02d.png", 1:17), png::readPNG)
pt <- tree_panel(ylim = c(0.5, nrow(M) + 7), icons = icon_img)
ggsave("fig5_conservation_map.png", pt + p + plot_layout(widths = c(1.35, 8.65)), width = 17.5, height = 6.5, dpi = 300)
cat("invariant:", sum(inv), " 16/17:", sum(near), "\n")
cat(paste0(hum[near], which(near)), "\n")

## ---------- Zoom: C-terminal tail around YENPTY ----------
zr <- 728:770
Z <- long[long$pos %in% zr, ]
yen <- 757:762
pz <- ggplot(Z, aes(pos, label, fill = cls)) +
  geom_tile(colour = "white", linewidth = .4) +
  geom_text(aes(label = aa, colour = cls %in% c("human", "invariant in all species")),
            family = "mono", size = 3.4, fontface = "bold") +
  annotate("rect", xmin = min(yen) - .5, xmax = max(yen) + .5, ymin = .5, ymax = nrow(M) + .5,
           fill = NA, colour = "black", linewidth = .8) +
  annotate("text", x = mean(yen), y = nrow(M) + 1.1, label = "YENPTY (757-762)", fontface = "bold", size = 3.6) +
  annotate("rect", xmin = 727.5, xmax = 770.5, ymin = nrow(M) + 1.7, ymax = nrow(M) + 2.3, fill = "grey80") +
  annotate("text", x = 749, y = nrow(M) + 2, label = "AICD (cytoplasmic tail, continues from 724)", size = 3) +
  scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "black"), guide = "none") +
  scale_fill_manual(values = c(`invariant in all species` = "#00A651", `conserved in 16/17` = "#9BD7A8",
                               `identical to human` = "#F4A582", human = "#B2182B",
                               different = "grey88", gap = "white"), name = NULL,
                    breaks = c("invariant in all species","conserved in 16/17","identical to human","different","gap")) +
  scale_x_continuous(breaks = zr, labels = ifelse(zr %% 5 == 0 | zr %in% yen, zr, ""), expand = c(0, 0)) +
  scale_y_discrete(expand = expansion(add = c(.5, 2.6))) +
  coord_cartesian(xlim = range(zr) + c(-.5, .5), clip = "off") +
  labs(x = "Human APP770 residue", y = NULL,
       title = "C-terminal tail of APP: zoom on the YENPTY motif (human 728-770)",
       subtitle = "Species ordered by divergence from the human lineage; green = identical in all 17 APP orthologues") +
  theme_minimal(base_size = 10) +
  theme(panel.grid = element_blank(), legend.position = "bottom",
        axis.text.x = element_text(size = 7),
        plot.background = element_rect(fill = "white", colour = NA))
ggsave("fig6_yenpty_zoom.png", pz, width = 13, height = 6.5, dpi = 300)
