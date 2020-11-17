# Check that required packages are running
remotes::install_github("tylermorganwall/rayshader")
if (!require("pacman")) install.packages("pacman")
pacman::p_load(Rcpp, pkgconfig, tidyverse, plyr, downloader, dplyr, hexbin, proj4, rlist, nngeo, kableExtra, tmap, tmaptools, extrafont, rmapshaper, pryr, mapedit, sf, ggmap, av, rayshader, magick)

# Get working directory
wd <- getwd()

# Load STATS19 crashes
crash.df <- read.csv("Road Safety Data - Accidents 2019.csv")
crash.df <- subset(crash.df, !is.na(crash.df$Location_Easting_OSGR))
crash.df <- subset(crash.df, !is.na(crash.df$Location_Northing_OSGR))

crash.sf <- st_as_sf(crash.df, coords = c("Location_Easting_OSGR", "Location_Northing_OSGR"), crs = 27700)
rm(crash.df)

crash.sf$eastings <- (st_coordinates(crash.sf)[,1])
crash.sf$northings <- (st_coordinates(crash.sf)[,2])

g2 <- ggplot(crash.sf[crash.sf$Police_Force == 1,], aes(eastings, northings)) +
  geom_hex(bins = 100) +
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
  scale_fill_distiller(palette = "YlGnBu")

plot(g2)

plot_gg(g2,multicore=TRUE,width=25,height=25,scale=150)
render_highquality()
render_movie(filename = "test.mp4", frames = 600, fps = 60, phi = 25, zoom = 0.8, theta = -90)

