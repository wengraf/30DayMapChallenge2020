# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(Rcpp, pkgconfig, tidyverse, plyr, downloader, dplyr, proj4, rlist, nngeo, kableExtra, tmap, tmaptools, extrafont, rmapshaper, pryr, mapedit, sf)

# Get working directory
wd <- getwd()

study.name <- "Ivo "

# Download OpenNames data
url <- "https://parlvid.mysociety.org/os/opname_csv_gb.zip"
download(url, dest="map.zip", mode="wb")
filelist <- unzip("map.zip", list = TRUE)
filelist <- subset(filelist, grepl("DATA/", filelist$Name))
filelist <- subset(filelist, grepl(".csv", filelist$Name))
filelist <- as.vector(filelist$Name)
unzip("map.zip", files = filelist, exdir = "./names")

# Load OpenNames CSVs to make Names list
files <- list.files("./names/DATA", pattern = ".csv")

roadlist <- list()
for(i in 1:length(files)){
  sf <- read.csv(paste0(wd, "/names/DATA/", files[i]), header = FALSE)
  sf$V1 <- NULL
  sf$V2 <- NULL
  sf <- st_as_sf(sf, coords = c("V9", "V10"), crs = 27700)
  sf <- subset(sf,  grepl(study.name, sf$V3) |
                    grepl(study.name, sf$V4) |
                    grepl(study.name, sf$V5) |
                    grepl(study.name, sf$V6))
  sf <- st_zm(sf)
  if(nrow(sf) == 0) {next()}
  roadlist[[i]] <- sf
  print(i)
}

roadlist <- purrr::compact(roadlist)
name.sf <- mapedit:::combine_list_of_sf(roadlist)
st_crs(name.sf) = 27700

name.sf <- subset(name.sf, name.sf$V7 == "transportNetwork")

rm(roadlist, sf, filelist, files, i, url)

name.sf <- subset(name.sf, name.sf$V8 == "Named Road")
name.sf$V19[name.sf$V19 == ""] <- NA
summary(as.factor(name.sf$V3))                    

name.sf$namelayer <- paste0(name.sf$V3, "\n", name.sf$V19, " ", name.sf$V17)
 
name.sf$V4 <- NULL
name.sf$V5 <- NULL
name.sf$V6 <- NULL
name.sf$V7 <- NULL
name.sf$V8 <- NULL
name.sf$V21 <- NULL
name.sf$V22 <- NULL
name.sf$V23 <- NULL
name.sf$V25 <- NULL
name.sf$V26 <- NULL
name.sf$V27 <- NULL
name.sf$V11 <- NULL
name.sf$V12 <- NULL
name.sf$V15 <- NULL
name.sf$V16 <- NULL
name.sf$V18 <- NULL
name.sf$V20 <- NULL
name.sf$V24 <- NULL
name.sf$V29 <- NULL
name.sf$V30 <- NULL
name.sf$V31 <- NULL
name.sf$V32 <- NULL
name.sf$V33 <- NULL
name.sf$V34 <- NULL

name.sf <- name.sf %>% arrange(desc(V14))
name.buffer <- st_buffer(name.sf, 500)
st_crs(name.buffer) = 27700

# Download OpenLocal data
url <- "https://parlvid.mysociety.org/os/opmplc_gpkg_gb.zip"
download(url, dest="map.zip", mode="wb")
filelist <- unzip("map.zip", list = TRUE)
filelist <- subset(filelist, grepl("SurfaceWater_Area", filelist$Name) |
                             grepl("TidalWater", filelist$Name))
filelist <- as.vector(filelist$Name)
unzip("map.zip", files = filelist, exdir = "./water")

# Load OpenLocal shapefiles to make water polygons
files <- list.files("./water/data", pattern = ".gpkg", recursive = TRUE)
roadlist <- list()

for(i in 1:length(files)){
  sf <- st_read(paste0(wd, "/water/data/", files[i]), layer = "SurfaceWater_Area")
  st_crs(sf) = 27700
  sf <- st_zm(sf)
  sf <- st_intersection(sf, name.buffer)
  if(nrow(sf) == 0) {next()}
  roadlist[[i]] <- sf
  print(i)
}

roadlist <- purrr::compact(roadlist)
surfacewater.sf <- mapedit:::combine_list_of_sf(roadlist)
st_crs(surfacewater.sf) = 27700

for(i in 1:length(files)){
  sf <- st_read(paste0(wd, "/water/data/", files[i]), layer = "TidalWater")
  st_crs(sf) = 27700
  sf <- st_zm(sf)
  sf <- st_intersection(sf, name.buffer)
  if(nrow(sf) == 0) {next()}
  roadlist[[i]] <- sf
  print(i)
}

roadlist <- purrr::compact(roadlist)
tidalwater.sf <- mapedit:::combine_list_of_sf(roadlist)
st_crs(tidalwater.sf) = 27700

# Download GreenSpace data
url <- "https://parlvid.mysociety.org/os/opgrsp_gpkg_gb.zip"
download(url, dest="map.zip", mode="wb")
filelist <- unzip("map.zip", list = TRUE)
filelist <- subset(filelist, grepl("GB_GreenspaceSite", filelist$Name))
filelist <- as.vector(filelist$Name)
unzip("map.zip", files = filelist, exdir = "./green")

sf <- st_read("./green/OS Open Greenspace (GPKG) GB/data/opgrsp_gb.gpkg", layer = "GreenspaceSite")
st_crs(sf) = 27700
sf <- st_zm(sf)
sf <- st_intersection(sf, name.buffer)
green.sf <- sf
rm(sf)

# Download Openroads data
url <- "https://parlvid.mysociety.org/os/oproad_gpkg_gb.zip"
download(url, dest="map.zip", mode="wb")
filelist <- unzip("map.zip", list = TRUE)
filelist <- subset(filelist, grepl("oproad", filelist$Name))
filelist <- as.vector(filelist$Name)
unzip("map.zip", files = filelist, exdir = "./roads")

# Load OpenRoads shapefiles to make network
files <- list.files("./roads/data", pattern = ".gpkg")
files <- subset(files, grepl("oproad", files))

roadlist <- list()

for(i in 1:length(files)){
  sf <- st_read(paste0(wd, "/roads/data/", files[i]), layer = "RoadLink")
  st_crs(sf) = 27700
  sf <- st_zm(sf)
  sf$fictitious <- NULL
  sf$loop <- NULL
  sf$startNode <- NULL
  sf$endNode <- NULL
  sf$roadNumber <- NULL
  sf$name1_lang <- NULL
  sf$name2_lang <- NULL
  sf$formOfWay <- NULL
  sf$numberTOID <- NULL
  sf$name2 <- NULL
  sf$length <- NULL
  sf$nameTOID <- NULL
  sf$function. <- NULL
  sf$structure <- NULL
  sf <- st_intersection(sf, name.buffer)
  if(nrow(sf) == 0) {next()}
  roadlist[[i]] <- sf
  print(i)
}

roadlist <- purrr::compact(roadlist)
road.sf <- mapedit:::combine_list_of_sf(roadlist)
st_crs(road.sf) = 27700
rm(roadlist, files, sf, i)

road.sf$buffervalue[road.sf$roadFunction == "Motorway" |
                    road.sf$roadFunction == "A Road"] <- 5

road.sf$buffervalue[road.sf$primaryRoute == TRUE] <- 5

road.sf$buffervalue[road.sf$trunkRoad == TRUE] <- 5

road.sf$buffervalue[road.sf$roadFunction == "B Road"] <- 4

road.sf$buffervalue[is.na(road.sf$buffervalue)] <- 3

road.sf <- st_buffer(road.sf, road.sf$buffervalue, endCapStyle = "FLAT")

green.sf$type <- "green"
road.sf$type <- "road"
water.sf <- rbind(surfacewater.sf, tidalwater.sf)
water.sf$type <- "water"

save.image("~/Documents/NameMap/1.RData")

water.sf$roadcol <- "#d3effc"

water.sf <- water.sf[c("namelayer", "roadcol", "geometry", "type")]

greenlist <- list()
for(i in 1:nrow(name.buffer)){
  water <- water.sf[water.sf$namelayer == name.buffer$namelayer[i],]
  green <- green.sf[green.sf$namelayer == name.buffer$namelayer[i],]
  if(nrow(water) == 0 & nrow(green) != 0) {greenlist[[i]] <- green}
  if(nrow(green) == 0) {next()}
  if(nrow(green) != 0 & nrow(water) != 0) {
    green <- st_difference(green, water)
    greenlist[[i]] <- green}
  print(i)
  rm(water, green)
}
greenlist <- purrr::compact(greenlist)
green.sf <- mapedit:::combine_list_of_sf(greenlist)
st_crs(green.sf) = 27700

green.sf$roadcol <- "#E4FEB7"
green.sf <- green.sf[c("namelayer", "roadcol", "geometry", "type")]

road.sf$roadcol <- NA
for(i in 1:nrow(road.sf)){
  if(is.na(road.sf$name1[i])){next()}
  if(grepl(study.name, road.sf$name1[i])){road.sf$roadcol[i] <- "#fe0093"}
  if(as.character(road.sf$name1[i]) == as.character(road.sf$V3[i])){road.sf$roadcol[i] <- "#fe0093"}
  print(i/nrow(road.sf))
}
road.sf$roadcol[is.na(road.sf$roadcol)] <- "black"

road.sf$type <- "road"
road.sf <- road.sf[c("namelayer", "roadcol", "geometry", "type")]

road.sf <- rbind(road.sf, water.sf, green.sf)
st_crs(road.sf) = 27700

land.sf <- name.buffer
land.sf[,1:6] <- NULL
land.sf <- st_cast(land.sf, "MULTILINESTRING")

land.sf <- st_buffer(land.sf, 4)
land.sf$roadcol <- "black"
land.sf$type <- "border"
land.sf <- land.sf[c("namelayer", "roadcol", "geometry", "type")]
road.sf2 <- rbind(road.sf, land.sf)

rm(land.sf, name.buffer, name.sf, road.sf, water.sf, green.sf, greenlist)

#Remove namelayers where it isn't in OpenRoads.
road.sf2 <- subset(road.sf2, road.sf2$namelayer != "Grace Close\nRugby CV22" &
                     road.sf2$namelayer != "Grace Close\nHaslington CW1" &
                     road.sf2$namelayer != "Grace Close\nLondon HA8" &
                     road.sf2$namelayer != "Grace Court\nMangotsfield BS16" &
                     road.sf2$namelayer != "Grace Mews\nBeckenham BR3" &
                     road.sf2$namelayer != "Grace Road\nBasildon SS13" &
                     road.sf2$namelayer != "Grace Gardens\nPoole BH12" &
                     road.sf2$namelayer != "Grace Court\nAnnfield Plain DH9" &
                     road.sf2$namelayer != "Grace Court\nBurton Latimer NN15" &
                     road.sf2$namelayer != "Grace Road South\nExeter EX2" &
                     road.sf2$namelayer != "Grace Road West\nExeter EX2")

road.sf2$namelayer[road.sf2$namelayer == "Grace Road Central\nExeter EX2"] <- "Grace Road\nExeter EX2"
save.image("~/Documents/NameMap/2.RData")

road.sf2$roadcol[road.sf2$roadcol == "black"] <- "#000000"

MyColour <- c("#000000","#FE0093", "#D3EFFC", "#E4FEB7")
names(MyColour) <- c("#000000", "#fe0093", "#d3effc", "#E4FEB7")

font_import(prompt = FALSE)
loadfonts()

namelist <- sort(unique(road.sf2$namelayer))

f <- 8

for(i in 1:length(namelist)){
  print("starting...")
g2 <- ggplot() +
  geom_sf(data = filter(road.sf2[road.sf2$type == "green",], namelayer == namelist[i]), aes(fill = roadcol, color = roadcol)) +
  geom_sf(data = filter(road.sf2[road.sf2$type == "water",], namelayer == namelist[i]), aes(fill = roadcol, color = roadcol)) +
  geom_sf(data = filter(road.sf2[road.sf2$type == "road",], namelayer == namelist[i]), aes(fill = roadcol, color = roadcol)) +
  geom_sf(data = filter(road.sf2[road.sf2$type == "border",], namelayer == namelist[i]), aes(fill = roadcol, color = roadcol)) +
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
        legend.position = "none",
        plot.margin=grid::unit(c(2,2,2,2), "mm")) +
  scale_fill_manual(values=MyColour, labels = NULL) +
  scale_color_manual(values=MyColour, labels = NULL) +
  ggtitle(namelist[i])
assign(paste0("p", i), g2)
ggsave(paste0("map_",study.name, i, "_", f, ".png"), plot = g2)
print(i/length(namelist))
}

devtools::install_github("thomasp85/patchwork")

library(patchwork)
output <- p1 + 
          p2 + 
          plot_layout()

plot(output)

ggsave("Lines_2.jpg", output)
