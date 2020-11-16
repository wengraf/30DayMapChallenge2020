# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, downloader, hexbin, sf)

# Get working directory
wd <- getwd()

# Load OpenLocal
files <- list.files("./water/data", pattern = ".gpkg", recursive = TRUE)
sf <- st_read(paste0(wd, "/water/data/", files), layer = "CarChargingPoint")
st_crs(sf) = 27700
OScharging.sf <- st_zm(sf)

# Download NCR data
url <- "http://chargepoints.dft.gov.uk/api/retrieve/registry/format/csv"
download(url, dest="map.csv", mode="wb")
NCR.sf <- read.csv("map.csv")
NCR.sf <- subset(NCR.sf, NCR.sf$longitude >= -180 & NCR.sf$longitude <= 180)
NCR.sf <- subset(NCR.sf, NCR.sf$latitude >= -180 & NCR.sf$latitude <= 180)
NCR.sf <- st_as_sf(NCR.sf, coords = c("longitude", "latitude"), crs = 4326)
NCR.sf <- st_transform(NCR.sf, crs = 27700)

# There are all sorts of wrong NCR locations - subset NCR by a buffer around the OS chargers 
OScharging.sf.buffer <- st_buffer(OScharging.sf, 1000000)
NCR.sf.clean <- NCR.sf[OScharging.sf.buffer,]

NCR.sf.clean$ID <- NCR.sf.clean$chargeDeviceID
NCR.sf.clean[,1:156] <- NULL
NCR.sf.clean$source <- "National Chargepoint Registry"
NCR.sf.clean$eastings <- (st_coordinates(NCR.sf.clean)[,1])
NCR.sf.clean$northings <- (st_coordinates(NCR.sf.clean)[,2])
NCR.sf.clean$geometry <- NULL

OScharging.sf$ID <- OScharging.sf$id
OScharging.sf[,1:5] <- NULL
OScharging.sf$source <- "Ordnance Survey"
OScharging.sf$eastings <- (st_coordinates(OScharging.sf)[,1])
OScharging.sf$northings <- (st_coordinates(OScharging.sf)[,2])
OScharging.sf$geom <- NULL

chargers <- rbind(OScharging.sf, NCR.sf.clean)

map.gg <- ggplot(chargers, aes(eastings, northings)) +
  geom_hex(bins = 40) +
  theme_classic() +
  facet_wrap("source") +
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
  ggtitle("EV chargers: an NCR and OS comparison")

ggsave("Hex_4.jpg", map.gg, dpi = 'retina')


