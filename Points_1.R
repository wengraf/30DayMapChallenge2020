if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, readr, sf, downloader, tmap, tmaptools)

# Download Naptan data
url <- "http://naptan.app.dft.gov.uk/DataRequest/Naptan.ashx?format=csv"
download(url, dest="./naptan.zip", mode="wb")
filelist <- unzip("./naptan.zip", list = TRUE)
filelist <- as.vector(filelist$Name)
unzip("./naptan.zip", files = filelist, exdir = "./naptan")
files <- list.files("./naptan", pattern = ".csv")

# Read in the Naptan data as an sf, then filter out the non-bus/coach/tram related stuff.
sf <- st_as_sf(read.csv(paste0("./naptan/", files[15])), coords = c("Easting", "Northing"), crs = 27700)
sf <- subset(sf, sf$StopType == "BCE" |
               sf$StopType == "BST" |
               sf$StopType == "BCT" |
               sf$StopType == "BCS" |
               sf$StopType == "BCQ")
sf <- sf[,2]

# Download BoundaryLine data
url <- "https://opendata.arcgis.com/datasets/1ac7244cbae64f35ad8e9c640a0e9d27_0.zip?outSR=%7B%22latestWkid%22%3A27700%2C%22wkid%22%3A27700%7D"
download(url, dest="./map.zip", mode="wb")
filelist <- unzip("./map.zip", list = TRUE)
filelist <- as.vector(filelist$Name)
unzip("./map.zip", files = filelist, exdir = "./map")
files <- list.files("./map", pattern = ".shp")

# Read in BoundaryLine data
boundary.sf <- st_read(paste0("./map/", files[1]))
st_crs(boundary.sf) = 27700

# Loop through for each boundary row, checking to see if the stops are within or without the high water mark
list.bus <- list()
for(i in 1:nrow(boundary.sf)){
  stop_in_country <- sf[boundary.sf[i,],]
  list.bus[[i]] <- stop_in_country
  print(i/nrow(boundary.sf))
}

stop_in_country <- mapedit:::combine_list_of_sf(list.bus)
st_crs(stop_in_country) = 27700

stop_not_in_country <- subset(sf, !(sf$NaptanCode %in% stop_in_country$NaptanCode))

map.tmap <- qtm(boundary.sf, fill = NULL) +
  qtm(stop_not_in_country,
      symbols.size = 0.5,
      symbols.col = "red") +
  tm_legend(main.title = "Naptan bus/coach/tram stops/stations below the high water mark, at sea or outside GB",
          main.title.position = "left")

tmap_save(map.tmap, filename = "points_1.png")

