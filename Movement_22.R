# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, sf, mapview, ggmap, gganimate, transformr, lubridate)

# get ADS-B
track <- read.csv("KC1388_1e84fc24.csv")
track$time <- ymd_hms(track$UTC)
track.sf <- st_as_sf(track, coords = c("X", "Y"), crs = 4326)
track.bbox <- st_bbox(track.sf)

# Record the edge X and Y values as numeric values
bottom <- as.numeric(track.bbox[2]) - .25
top <- as.numeric(track.bbox[4]) + .25
leftmost <- as.numeric(track.bbox[1]) - .5
rightmost <- as.numeric(track.bbox[3]) + .5

# Set map zoom level you'd prefer.  Play around with this until you get the result you like.
zoomlevel <- 8

# Download the Stamen terrain map layer for the leftmost quarter of the map, then convert from ggmap to ggplot
terrainmap <- get_stamenmap(c(left = leftmost, bottom = bottom, right = rightmost, top = top), maptype = c("terrain"), force = TRUE, zoom = zoomlevel)

ggmap.anim <- ggmap(terrainmap) +
  geom_point(data = track, aes(x = X, y = Y), size = 1) +
  transition_manual(UTC, cumulative = TRUE)

animate(ggmap.anim)
anim_save("movement.gif")


