# Time-scaled species tree whose tips line up with the alignment rows (top = human)
# Topology: accepted metazoan relationships; node ages approximate (Mya).
# Zebrafish appa/appb are paralogues from the teleost genome duplication; drawn as a short fork.
library(ape)
species_tree_df <- function(nr = 17) {
  H  <- "((Human:6.4,Chimpanzee:6.4):80.6,Mouse:87)"
  A  <- sprintf("(%s:232,Chicken:319)", H)
  Tt <- sprintf("(%s:33,Frog:352)", A)
  S  <- sprintf("(%s:61,Coelacanth:413)", Tt)
  Ac <- "((ZfA:15,ZfB:15):215,Fugu:230)"
  O  <- sprintf("(%s:16,%s:199)", S, Ac)
  G  <- sprintf("(%s:33,Shark:462)", O)
  V  <- sprintf("(%s:138,Lamprey:600)", G)
  C  <- sprintf("(%s:84,Amphioxus:684)", V)
  D  <- sprintf("(%s:6,Urchin:690)", C)
  P  <- "((Aplysia:550,Squid:550):100,(Fly:600,Worm:600):50)"
  nwk <- sprintf("(%s:4,%s:44);", D, P)
  tr <- read.tree(text = nwk)
  rowmap <- c(Human=1, Chimpanzee=2, Mouse=3, Chicken=4, Frog=5, Coelacanth=6, ZfA=7, ZfB=8, Fugu=9,
              Shark=10, Lamprey=11, Amphioxus=12, Urchin=13, Aplysia=14, Squid=15, Fly=16, Worm=17)
  nt <- Ntip(tr); depth <- node.depth.edgelength(tr); root_age <- max(depth)
  age <- root_age - depth                         # 0 at tips
  y <- numeric(nt + tr$Nnode)
  y[1:nt] <- nr - rowmap[tr$tip.label] + 1        # same y as tile rows
  # internal y = mean of children, computed bottom-up
  repeat {                                       # resolve any nodes whose children were not ready
    todo <- setdiff(unique(tr$edge[, 1]), which(y != 0)); if (!length(todo)) break
    for (node in todo) { kids <- tr$edge[tr$edge[, 1] == node, 2]
      if (all(y[kids] != 0)) y[node] <- mean(range(y[kids])) }
  }
  h <- data.frame(x = -age[tr$edge[, 1]], xend = -age[tr$edge[, 2]], y = y[tr$edge[, 2]], yend = y[tr$edge[, 2]])
  v <- do.call(rbind, lapply(unique(tr$edge[, 1]), function(node) {
    kids <- tr$edge[tr$edge[, 1] == node, 2]
    data.frame(x = -age[node], xend = -age[node], y = min(y[kids]), yend = max(y[kids])) }))
  list(seg = rbind(h, v), root = root_age)
}

tree_panel <- function(ylim, nr = 17, base = 10) {
  st <- species_tree_df(nr)
  ggplot(st$seg) +
    geom_segment(aes(x = x, xend = xend, y = y, yend = yend), linewidth = .45, lineend = "square") +
    geom_segment(data = data.frame(y = seq_len(nr)), aes(x = 0, xend = 25, y = y, yend = y),
                 linewidth = .2, linetype = "dotted", colour = "grey55") +
    scale_x_continuous(breaks = c(-600, -400, -200, 0), labels = c("600", "400", "200", "0"),
                       expand = c(0, 0), limits = c(-st$root - 15, 25)) +
    coord_cartesian(ylim = ylim, expand = FALSE, clip = "off") +
    labs(x = "Mya", y = NULL) +
    theme_minimal(base_size = base) +
    theme(panel.grid = element_blank(), axis.text.y = element_blank(),
          axis.title.x = element_text(size = base * .7), axis.text.x = element_text(size = base * .6),
          plot.background = element_rect(fill = "white", colour = NA))
}
