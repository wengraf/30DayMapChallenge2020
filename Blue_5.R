# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(Rcpp, pkgconfig, tidyverse, plyr, downloader, dplyr, hexbin, proj4, rlist, nngeo, kableExtra, tmap, tmaptools, extrafont, rmapshaper, pryr, mapedit, sf, ggmap)

# Get working directory
wd <- getwd()

# Load OpenLocal
files <- list.files("./water/data", pattern = ".gpkg", recursive = TRUE)
Foreshore <- st_read(paste0(wd, "/water/data/", files), layer = "Foreshore")
SurfaceWater_Area <- st_read(paste0(wd, "/water/data/", files), layer = "SurfaceWater_Area")
TidalWater <- st_read(paste0(wd, "/water/data/", files), layer = "TidalWater")
Foreshore$featureCode <- "Foreshore"
SurfaceWater_Area$featureCode <- "SurfaceWater_Area"
TidalWater$featureCode <- "TidalWater"
st_crs(Foreshore) = 27700
st_crs(SurfaceWater_Area) = 27700
st_crs(TidalWater) = 27700

water <- rbind(Foreshore, SurfaceWater_Area, TidalWater)
rm(Foreshore, SurfaceWater_Area, TidalWater)

OnetheThames <- as.data.frame(t(c(589868,176060)))
colnames(OnetheThames) <- c("easting", "northing")
OnetheThames.sf <- st_as_sf(OnetheThames, coords = c("easting", "northing"), crs = 27700)
km <- 10
OnetheThames.sf.buffer <- st_buffer(OnetheThames.sf, km*1000)

water.clip <- st_intersection(water,OnetheThames.sf.buffer)

g2 <- ggplot() +
  geom_sf(data = subset(water.clip, water.clip$featureCode == "TidalWater"), color = NA, fill = "#006994") +
  geom_sf(data = subset(water.clip, water.clip$featureCode == "SurfaceWater_Area"), color = NA, fill = "#d3effc") +
  geom_sf(data = subset(water.clip, water.clip$featureCode == "Foreshore"), color = NA, fill = alpha("#0099ff",0.2)) +
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
  ggtitle(paste0("Water and Foreshore within ", km, "km of '1, The Thames' (Grain Fort, Kent)"))

ggsave("Blue_5.jpg", dpi = 600, plot = g2)

