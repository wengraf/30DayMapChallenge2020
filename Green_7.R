# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(Rcpp, pkgconfig, tidyverse, plyr, downloader, dplyr, hexbin, proj4, rlist, nngeo, kableExtra, tmap, tmaptools, extrafont, rmapshaper, pryr, mapedit, sf, ggmap)

wd <- getwd()

sf <- st_read("./green/OS Open Greenspace (GPKG) GB/data/opgrsp_gb.gpkg", layer = "GreenspaceSite")
st_crs(sf) = 27700
green.sf <- st_zm(sf)
rm(sf)

boundary.sf <- st_read(paste0(wd, "/borough/Data/GB/district_borough_unitary_region.shp"))
st_crs(boundary.sf) = 27700
boundary.sf <- st_zm(boundary.sf)
boundary.sf <- subset(boundary.sf, boundary.sf$AREA_CODE == "LBO")

green.sf <- st_intersection(green.sf, boundary.sf)
green.sf[,2:21] <- NULL

TidalWater <- st_read(paste0(wd, "/water/data/opmplc_gb.gpkg"), layer = "TidalWater")
st_crs(TidalWater) = 27700
TidalWater <- st_intersection(TidalWater, boundary.sf)

g2 <- ggplot() +
    geom_sf(data = boundary.sf, fill = NA, color = "grey", size = 0.1) +
    geom_sf(data = green.sf, fill = "green", color = NA) +
    geom_sf(data = TidalWater, fill = "#006994", color = NA) +
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
          legend.position = "none") +
    ggtitle("The green space of London")
  
ggsave("Green_7.jpg", g2)

