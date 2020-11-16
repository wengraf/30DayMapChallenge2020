# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, sf)

wd <- getwd()

# Load OpenLocal
files <- list.files("./water/data", pattern = ".gpkg", recursive = TRUE)
Highwater <- st_read(paste0(wd, "/water/data/", files), layer = "TidalBoundary")
st_crs(Highwater) = 27700

Portland <- as.data.frame(t(c(368750,74125)))
colnames(Portland) <- c("easting", "northing")

Portland <- st_as_sf(Portland, coords = c("easting", "northing"), crs = 27700)
km <- 30
st_crs(Portland) = 27700
Portland.buffer <- st_buffer(Portland, km*1000)

water.clip <- st_intersection(Highwater,Portland.buffer)

# Read in FlightRadar24 data
plane <- st_read("258445ec.kml", layer = "Trail")
plane <- st_transform(plane, 27700)
plane <- st_zm(plane)
plane.clip <- st_intersection(plane,Portland.buffer)

map.gg <- ggplot() +
  geom_sf(data = subset(water.clip, water.clip$classification == "High Water Mark"), color = "#DA291C", size = 0.1) +
  geom_sf(data = plane.clip, color = "#DA291C", fill = "#DA291C", size = 0.3) +
  geom_sf(data = Portland.buffer, color = "#DA291C", fill = NA, size = .5) +
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
  ggtitle("Flight path of G-FIFA (OS Lidar) around Portland, 16/9/20")

ggsave("Red_6.jpg", map.gg, dpi = 'retina')

