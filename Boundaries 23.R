# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, downloader, sf, osmdata, ggmap)

# Get working directory
wd <- getwd()

# get boundaries
boundary.sf <- opq(bbox = 'Baarle Nassau Netherlands') %>%
  add_osm_feature(key = 'boundary', value = 'administrative') %>%
  osmdata_sf()

boundary.sf <- boundary.sf$osm_polygons

roads.sf <- opq(bbox = 'Baarle Nassau Netherlands') %>%
  add_osm_feature(key = 'highway') %>%
  osmdata_sf()

roads.sf <- roads.sf$osm_lines

bbox <- opq(bbox = 'Baarle Nassau Netherlands')
bbox <- bbox$bbox

bbox <- st_bbox(c(xmin = 4.895, xmax = 4.96, ymin = 51.42, ymax = 51.4636933), crs = st_crs(4326))

mapview::mapview(roads.sf)

boundary.sf <- st_crop(boundary.sf, bbox)
roads.sf <- st_crop(roads.sf, bbox)

map.gg <- ggplot() +
  geom_sf(data = roads.sf, fill = "grey", color = "grey", size = 0.1) +
  geom_sf(data = boundary.sf, fill = "NA", color = "black", size = 0.3) +
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
  ggtitle('Baarle-Nassau (NL) and Baarle-Hertog (BE) (source: OSM)')

ggsave("Boundaries_23.jpg", dpi = 'retina', map.gg)
