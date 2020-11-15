# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(Rcpp, pkgconfig, tidyverse, plyr, downloader, dplyr, hexbin, proj4, rlist, tmap, tmaptools, extrafont, rmapshaper, pryr, mapedit, sf, ggmap)

wd <- getwd()

tubelines <- st_read("London Train Lines.kml")
st_crs(tubelines) = 4326
tubelines <- st_zm(tubelines)
circle <- subset(tubelines, grepl("Circle -", tubelines$Name))
circle <- st_transform(circle, 27700)
plot(circle)

circle.buffer <- st_buffer(circle, 500)

circle.buffer.bbox <- st_as_sf(st_as_sfc(st_bbox(circle.buffer)), 27700)
plot(circle.buffer.bbox)
wkt <- st_as_text(st_geometry(circle.buffer.bbox))

rm(tubelines)

st_layers(paste0(wd, "/water/data/opmplc_gb.gpkg"))

important.sf <- st_read(paste0(wd, "/water/data/opmplc_gb.gpkg"), layer = "ImportantBuilding", wkt_filter = wkt)
st_crs(important.sf) = 27700
important.sf <- st_zm(important.sf)

important.sf <- st_intersection(important.sf, circle.buffer)
important.sf[,2:6] <- NULL
important.sf$Description <- NULL

building.sf <- st_read(paste0(wd, "/water/data/opmplc_gb.gpkg"), layer = "Building", wkt_filter = wkt)
st_crs(building.sf) = 27700
building.sf <- st_zm(building.sf)

building.sf <- st_intersection(building.sf, circle.buffer)
building.sf[,2:4] <- NULL

g2 <- ggplot() +
    geom_sf(data = building.sf, fill = "grey", color = NA) +
    geom_sf(data = important.sf, fill = "black", color = NA) +
    geom_sf(data = circle, color = "#ffd429") +
    theme_classic() +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.line.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.line.y=element_blank(),
          legend.position = "none") +
    ggtitle("The Circle Line")

ggsave("yellow_8.jpg", g2)
       
       
       