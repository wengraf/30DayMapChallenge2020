# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(rayshader, tidyverse, geoviz, tibble, raster, magick)

# Set lat long for area you would like to rayshade - this example looks at Plymouth to Cornwall
lat = 39.2331
lon = 26.2072

# Set the km2 radius of the area  
square_km = 35

# Max tiles request fron 'mapzen' and 'stamen' - Increasing max_tiles results in a high res image (but will take more time)
max_tiles = 60

dem <- mapzen_dem(lat, lon, square_km, max_tiles = max_tiles)

# Get a stamen overlay 
overlay_image <-
  slippy_overlay(dem,
                 image_source = "stamen",
                 image_type = "terrain",
                 png_opacity = 0.3,
                 max_tiles = max_tiles)

# Render the 'rayshader' scene 
heightmap = matrix(
  raster::extract(dem, raster::extent(dem), method = 'bilinear'),
  nrow = ncol(dem),
  ncol = nrow(dem)
)

sunshade <- heightmap %>%
  sphere_shade(sunangle = 270, texture = "imhof1") %>% 
  add_overlay(overlay_image)

rayshader::plot_3d(
  sunshade,
  heightmap,
  zscale = raster_zscale(dem) / 3,   
  solid = TRUE,
  shadow = FALSE,
  soliddepth = -raster_zscale(dem),
  water=TRUE,
  waterdepth = 0.5,
  wateralpha = 0.5,
  watercolor = "lightblue",
  waterlinecolor = "white",
  waterlinealpha = 0.5
)


render_movie("Elevation", frames = 720,
  fps = 60,
  progbar = interactive())


render_snapshot(filename = "Elevation_snapshot.png")

render_highquality(filename = "Elevation.png", samples=200, scale_text_size = 24,clear=TRUE)
