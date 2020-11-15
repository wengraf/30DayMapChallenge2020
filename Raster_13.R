# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, sf, ggmap, grid)

# Get working directory
wd <- getwd()

# Read in OS BoundaryLine, which I have saved in a sub-folder.
boundary.sf <- st_read(paste0(wd, "/borough/Data/GB/district_borough_unitary_region.shp"))
st_crs(boundary.sf) = 27700
boundary.sf <- subset(boundary.sf, boundary.sf$AREA_CODE == "LBO")

# boundary.union is a union of all London local authorities (i.e., Greater London and the City of London)
boundary.union <- st_union(boundary.sf)

# Make a 6km buffer around London, transform the CRS and make a bounding box of it.
boundary.union <- st_buffer(boundary.union, 6000)
boundary.union <- st_transform(boundary.union, 4326)
boundary.union.bbox <- st_bbox(boundary.union)

# Record the edge X and Y values as numeric values
bottom <- as.numeric(boundary.union.bbox[2])
top <- as.numeric(boundary.union.bbox[4])
leftmost <- as.numeric(boundary.union.bbox[1])
rightmost <- as.numeric(boundary.union.bbox[3])

# Set map zoom level you'd prefer.  Play around with this until you get the result you like.
zoomlevel <- 12

# Download the Stamen terrain map layer for the leftmost quarter of the map, then convert from ggmap to ggplot
terrainmap <- get_stamenmap(c(left = leftmost, bottom = bottom, right = leftmost+((rightmost - leftmost)*.25), top = top), maptype = c("terrain"), force = TRUE, zoom = zoomlevel)
terrainmap <- ggmap(terrainmap, extent = 'device')

# Download the Stamen toner map layer for the 2nd left quarter of the map, then convert from ggmap to ggplot
tonermap <- get_stamenmap(c(left = leftmost+((rightmost - leftmost)*.25), bottom = bottom, right = leftmost+((rightmost - leftmost)*.5), top = top), maptype = c("toner"), force = TRUE, zoom = zoomlevel)
tonermap <- ggmap(tonermap, extent = 'device')

# Download the Stamen watercolour map layer for the 2nd right quarter of the map, then convert from ggmap to ggplot
watercolormap <- get_stamenmap(c(left = leftmost+((rightmost - leftmost)*.5), bottom = bottom, right = leftmost+((rightmost - leftmost)*.75), top = top), maptype = c("watercolor"), force = TRUE, zoom = zoomlevel)
watercolormap <- ggmap(watercolormap, extent = 'device')

# Download the Stamen toner lite map layer for the rightmost quarter of the map, then convert from ggmap to ggplot
tonerlitemap <- get_stamenmap(c(left = leftmost+((rightmost - leftmost)*.75), bottom = bottom, right = rightmost, top = top), maptype = c("toner-lite"), force = TRUE)
tonerlitemap <- ggmap(tonerlitemap, extent = 'device', zoom = zoomlevel)

# Set up an underlying map of the whole mapped area (this won't be seen in the end)
underlying <- ggmap(get_stamenmap(c(left = leftmost, bottom = bottom, right = rightmost, top = top), maptype = c("terrain"), force = TRUE), extent = 'device')

# Set up a ggplot map, with the underlying layer, then the four layers overlaid, positioned correctly using xmin/max and ymin/max
map.gg <- underlying +
  inset(ggplotGrob(terrainmap), xmin = leftmost, xmax = leftmost+((rightmost - leftmost)*.25), ymin = bottom, ymax = top) +
  inset(ggplotGrob(tonermap), xmin = leftmost+((rightmost - leftmost)*.25), xmax = leftmost+((rightmost - leftmost)*.5), ymin = bottom, ymax = top) +
  inset(ggplotGrob(watercolormap), xmin = leftmost+((rightmost - leftmost)*.5), xmax = leftmost+((rightmost - leftmost)*.75), ymin = bottom, ymax = top) +
  inset(ggplotGrob(tonerlitemap), xmin = leftmost+((rightmost - leftmost)*.75), xmax = rightmost, ymin = bottom, ymax = top)

ggsave("Raster_13.jpg", map.gg, scale = 4, dpi = 'retina')

