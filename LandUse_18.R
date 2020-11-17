# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, downloader, sf, osmdata)

# Get working directory
wd <- getwd()

# get motorcycle parking polygons
motorcycle_parking <- opq(bbox = 'greater london uk') %>%
  add_osm_feature(key = 'amenity', value = 'motorcycle_parking') %>%
  osmdata_sf()
motorcycle_parking <- motorcycle_parking$osm_polygons
motorcycle_parking[,2:11] <- NULL

# get parking polygons
parking <- opq(bbox = 'greater london uk') %>%
  add_osm_feature(key = 'amenity', value = 'parking') %>%
  osmdata_sf()
parking.poly <- parking$osm_polygons
parking.poly[,2:170] <- NULL
parking.multipoly <- parking$osm_multipolygons
parking.multipoly[,2:27] <- NULL 

# get parking building polygons
parkingbuilding <- opq(bbox = 'greater london uk') %>%
  add_osm_feature(key = 'building', value = 'parking') %>%
  osmdata_sf()
parkingbuilding <- parking$osm_polygons
parkingbuilding[,2:170] <- NULL

rm(parking, bbox)
parking.sf <- bind_rows(motorcycle_parking, parking.poly, parking.multipoly, parkingbuilding)

# get London boundary
boundary.sf <- st_read(paste0(wd, "/borough/Data/GB/district_borough_unitary_region.shp"))
st_crs(boundary.sf) = 27700
boundary.sf <- subset(boundary.sf, boundary.sf$AREA_CODE == "LBO")

parking.sf <- st_transform(parking.sf, 27700)
parking.sf <- parking.sf[boundary.sf,]

# get the Thames
TidalWater <- st_read(paste0(wd, "/water/data/opmplc_gb.gpkg"), layer = "TidalWater")
st_crs(TidalWater) = 27700
TidalWater <- st_intersection(TidalWater, boundary.sf)

# Merge Local Authorities
boundary.sf <- st_as_sf(st_union(boundary.sf))

# Make map
map.gg <- ggplot() +
  geom_sf(data = boundary.sf, fill = NA, color = "black", size = 0.1) +
  geom_sf(data = parking.sf, fill = "black", color = NA) +
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
  ggtitle('Parking in London (source: OSM)')

ggsave("LandUse_18.jpg", dpi = 'retina', map.gg)
