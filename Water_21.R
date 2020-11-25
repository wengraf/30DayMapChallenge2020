# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, sf, mapview, gganimate, transformr, lubridate)

# get London boundary
boundary.sf <- st_read("./borough/Data/GB/district_borough_unitary_region.shp")
st_crs(boundary.sf) = 27700
boundary.sf <- subset(boundary.sf, boundary.sf$AREA_CODE == "LBO")

boundary.buffer <- st_buffer(boundary.sf, 50000)
boundary.buffer <- st_transform(boundary.buffer, 4258)
boundary.buffer.bbox <- st_bbox(boundary.buffer)
boundary.buffer.bbox.wkt <- st_as_text(st_as_sfc(boundary.buffer.bbox))

tracks <- st_read("Anonymised_AIS_Derived_Track_Lines_2015_MMO.shp", wkt_filter = boundary.buffer.bbox.wkt)
tracks <- st_transform(tracks, 27700)

tracks.crop <- st_crop(tracks, st_buffer(boundary.sf, 70000))

tracks.crop[,1:15] <- NULL
tracks.crop[,2:4] <- NULL
  
map.gg.anim <- ggplot(tracks.crop) +
  geom_sf(color = alpha("black",1/150)) +
  theme_classic() +
  xlim(530119, 630000) +
  ylim(150000, 200000) +
  transition_manual(Datestart, cumulative = TRUE)

animate(map.gg.anim, nframes = length(unique(tracks.crop$Datestart)), fps = 5)
anim_save("test.gif")


