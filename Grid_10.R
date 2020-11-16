# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, sf)

wd <- getwd()

important.sf <- st_read(paste0(wd, "/water/data/opmplc_gb.gpkg"), layer = "ElectricityTransmissionLine")
st_crs(important.sf) = 27700
important.sf <- st_zm(important.sf)
important.sf$featureCode <- NULL

plot(important.sf)

g2 <- ggplot() +
    geom_sf(data = st_buffer(important.sf, 200), color = alpha("white", 0.2)) +
    geom_sf(data = important.sf, color = "white", size = 0.1) +
    theme_classic() +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.line.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.line.y=element_blank(),
          plot.title = element_text(hjust = 0.5),
          panel.background = element_rect(fill='black',colour='black'),
          legend.position = "none",
          plot.margin=grid::unit(c(2,2,2,2), "mm")) +
    ggtitle("The electricity transmission lines of GB")
    
ggsave("Grid_10.jpg", dpi = 1200, g2)

