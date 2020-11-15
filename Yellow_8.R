# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, sf)

# Get Working Directory
wd <- getwd()

# Using the Tube lines data from doogal.co.uk, map the Circle Line
tubelines <- st_read("London Train Lines.kml")
st_crs(tubelines) = 4326
tubelines <- st_zm(tubelines)
circle <- subset(tubelines, grepl("Circle -", tubelines$Name))
circle <- st_transform(circle, 27700)

# Make a buffer around the Circle Line (500m either side of it)
circle.buffer <- st_buffer(circle, 500)

# Make a bounding box around the buffer, and then a WKT of this bbox, so that you don't have to read in all of the GB buildings data
circle.buffer.bbox <- st_as_sf(st_as_sfc(st_bbox(circle.buffer)), 27700)
wkt <- st_as_text(st_geometry(circle.buffer.bbox))
rm(tubelines)

# Read in ImportantBuildings from the OS OpenMap Local dataset, which I've saved in a sub-folder
important.sf <- st_read(paste0(wd, "/water/data/opmplc_gb.gpkg"), layer = "ImportantBuilding", wkt_filter = wkt)
st_crs(important.sf) = 27700

important.sf <- st_intersection(important.sf, circle.buffer)
important.sf[,2:6] <- NULL
important.sf$Description <- NULL

# Do the same for Buildings...
building.sf <- st_read(paste0(wd, "/water/data/opmplc_gb.gpkg"), layer = "Building", wkt_filter = wkt)
st_crs(building.sf) = 27700

building.sf <- st_intersection(building.sf, circle.buffer)
building.sf[,2:4] <- NULL

map.gg <- ggplot() +
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

ggsave("yellow_8.jpg", map.gg, scale = 2, dpi = 'retina')
       
       
       