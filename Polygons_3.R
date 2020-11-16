# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, downloader, sf)

# Get working directory
wd <- getwd()

# Load OpenLocal shapefiles to make polygons
files <- list.files("./water/data", pattern = ".gpkg", recursive = TRUE)
sf <- st_read(paste0(wd, "/water/data/", files), layer = "ImportantBuilding")
st_crs(sf) = 27700
church.sf <- subset(sf, sf$buildingTheme == "Religious Buildings")

# Load OpenLocal shapefiles to make polygons
files <- list.files("./water/data", pattern = ".gpkg", recursive = TRUE)
sf <- st_read(paste0(wd, "/water/data/", files), layer = "TidalWater")
st_crs(sf) = 27700
water.sf <- st_zm(sf)

# Download Boundary data
url <- "https://parlvid.mysociety.org/os/boundary-line/bdline_gb-2020-10.zip"
download(url, dest="map.zip", mode="wb")
filelist <- unzip("map.zip", list = TRUE)
filelist <- subset(filelist, grepl("district_borough_unitary_region", filelist$Name))
filelist <- as.vector(filelist$Name)
unzip("map.zip", files = filelist, exdir = "./borough")

files <- list.files("./borough/Data/GB", pattern = ".shp")
boundary.sf <- st_read(paste0(wd, "/borough/Data/GB/", files))
st_crs(boundary.sf) = 27700
boundary.sf <- st_zm(boundary.sf)
boundary.sf <- subset(boundary.sf, boundary.sf$NAME == "City and County of the City of London")
boundarybuffer.sf <- st_buffer(boundary.sf, 500)

sf <- st_intersection(church.sf, boundary.sf)
sf <- subset(sf, !grepl("Synagogue", sf$distinctiveName))
water.sf <- st_intersection(water.sf, boundarybuffer.sf)

f <- 8

map.gg <- ggplot() +
    geom_sf(data = sf, color = NA, fill = "red") +
    geom_sf(data = water.sf, color = "#d3effc", fill = "#d3effc") +
    geom_sf(data = boundary.sf, color = NA, fill = alpha("grey",0.2)) +
    theme_classic(base_size = f, base_family = "Transport") +
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
    ggtitle("Churches of the 'City and County of the City of London'")

ggsave("polygons_3.jpg", dpi = 'retina', plot = map.gg)
