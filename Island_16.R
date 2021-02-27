# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, sf, ggmap)

lat <- 56.1080034
lon <- 14.3943247
diff <- 0.1

# Set map zoom level you'd prefer.  Play around with this until you get the result you like.
zoomlevel <- 13

# Download the Stamen map layer
Ivo.map <- get_stamenmap(c(left = lon - diff, bottom = lat - diff, right = lon + diff, top = lat + diff), maptype = c("terrain"), force = TRUE, zoom = zoomlevel)

# Map it
map.gg <- ggmap(Ivo.map) +
  ggtitle("The island of Ivö, Sweden")



ggsave("Island_16.jpg", map.gg, scale = 2, dpi = 'retina')
