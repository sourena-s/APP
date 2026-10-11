# Zoom panels on super-conserved regions (43 residues each), species ordered by divergence
source("fig5.R")   # builds M, hum, cls, inv, sp, long ...
icons <- c("🧑","🐒","🐭","🐔","🐸","🐟","🐠","🐠","🐡","🦈","🐍","🐟","✴️","🐌","🦑","🪰","🪱")
sp$ilabel <- sp$label
icon_img <- lapply(sprintf("icons_sci/%02d.png", 1:17), png::readPNG)
long$ilabel <- factor(sp$ilabel[long$row], levels = rev(sp$ilabel))
fills <- c(`invariant in all species` = "#00A651", `conserved in 16/17` = "#9BD7A8",
           `identical to human` = "#F4A582", human = "#B2182B", different = "grey88", gap = "white", `isolated match (lamprey/invertebrates)` = "#A0A0A0")

zoom <- function(from, box, boxlab, title, file, dom_lab, highlight = integer(0), hl_lab = NULL, dim_from = NULL) {
  zr <- from:(from + 42)                       # 43 residues, same width as every panel
  Z <- long[long$pos %in% zr, ]
  if (!is.null(dim_from)) Z$cls[Z$row >= dim_from & Z$cls == "identical to human"] <- "isolated match (lamprey/invertebrates)"
  Z$txtcol <- ifelse(Z$cls %in% c("human", "invariant in all species"), "white", "black")
  Z$hl <- Z$pos %in% highlight
  nr <- nrow(M)
  p <- ggplot(Z, aes(pos, ilabel, fill = cls)) +
    geom_tile(colour = "white", linewidth = .4) +
    geom_text(data = subset(Z, !hl), aes(label = aa, colour = txtcol),
              family = "mono", size = 3.4, fontface = "bold") +
    geom_text(data = subset(Z, hl), aes(label = aa), colour = "black",
              family = "mono", size = 5.2, fontface = "bold") +
    scale_colour_identity() +
    annotate("rect", xmin = min(box) - .5, xmax = max(box) + .5, ymin = .5, ymax = nr + .5,
             fill = NA, colour = "black", linewidth = .9) +
    annotate("text", x = mean(box), y = nr + 1.1, label = boxlab, fontface = "bold", size = 3.6) +
    annotate("rect", xmin = min(zr) - .5, xmax = max(zr) + .5, ymin = nr + 1.75, ymax = nr + 2.35, fill = "grey80") +
    annotate("text", x = mean(zr), y = nr + 2.05, label = dom_lab, size = 3) +
    scale_fill_manual(values = fills, name = NULL,
                      breaks = c("invariant in all species","conserved in 16/17","identical to human","isolated match (lamprey/invertebrates)","different","gap")) +
    scale_x_continuous(breaks = zr, labels = ifelse(zr %in% c(box, highlight) | (zr %% 5 == 0 & sapply(zr, function(z) min(abs(z - box)) > 2)), zr, ""), expand = c(0, 0)) +
    scale_y_discrete(expand = expansion(add = c(.5, 2.7))) +
    coord_cartesian(xlim = range(zr) + c(-.5, .5), clip = "off") +
    labs(x = "Human APP770 residue", y = NULL, title = title,
         subtitle = paste0("43 residues; species ordered by divergence from the human lineage",
                           if (!is.null(hl_lab)) paste0("; ", hl_lab) else "")) +
    theme_minimal(base_size = 10) +
    theme(panel.grid = element_blank(), legend.position = "bottom",
          axis.text.x = element_text(size = 7), axis.text.y = element_text(size = 9),
          plot.background = element_rect(fill = "white", colour = NA))
  for (i in seq_len(nr)) {
    yy <- nr - i + 1
    p <- p + annotation_custom(grid::rasterGrob(icon_img[[i]], interpolate = TRUE),
                               xmin = min(zr) - 10.6, xmax = min(zr) - 9.4, ymin = yy - .42, ymax = yy + .42)
  }
  p <- p + theme(axis.text.y = element_text(size = 9, margin = margin(r = 4)), plot.margin = margin(5, 5, 5, 90))
  pt <- tree_panel(ylim = c(0.5, nr + 2.7))
  ggsave(file, pt + p + plot_layout(widths = c(1.3, 8.7)), width = 14.5, height = 6.8, dpi = 300, device = ragg::agg_png)
}

zoom(728, 756:762, "GYENPTY (756-762)", "AICD: MQ and GYENPTY, invariant from worm to human", "zoomF_GYENPTY.png",
     "AICD (cytoplasmic tail, continues from 724)", highlight = 757,
     hl_lab = "large black Y757 = phosphorylated tyrosine (Y682 in APP695)")
zoom(148, 186:188, "CCP (186-188)", "CuBD: invariant C158, C174, F179, G181 and the C186-C187-P188 run", "zoomB_CCP.png",
     "Copper-binding domain (CuBD, 124-189)")
zoom(671, c(672, 713), "Abeta1-42 (APP770 672-713)", "Abeta region: conservation of human Abeta1-42 across APP orthologues",
     "zoomAbeta.png", "Abeta1-42 with start of the transmembrane domain (700-723)",
     hl_lab = "Abeta1 = APP770 D672; Abeta42 = A713",
     dim_from = 11)
