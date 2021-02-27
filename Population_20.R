#Load packages
library(sp)
library(rgdal)
library(reshape)
library(ggplot2)
library(maptools)
library(rgeos) #create a range standardisation function


remotes::install_github("tylermorganwall/rayshader")
library(rayshader)
library(ggplot2)
library(tidyverse)




#load in a population grid - in this case it's population density from NASA's SEDAC (see link above). It's spatial data if you haven't seen this before in R.
input<-readGDAL("gpw_v4_population_density_rev11_2020_1_deg.asc") # the latest data come as a Tiff so you will need to tweak.
proj4string(input) = CRS("+init=epsg:4326")

#Get the data out of the spatial grid format using "melt" and rename the columns.
values<-melt(input)
names(values)<- c("pop", "x", "y")



gg = ggplot(values[values$pop >= 5,], aes(x, y)) +
  geom_tile(aes(x=x,y=y,fill=pop)) +
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
        legend.position = "none")
  
plot_gg(gg,multicore=TRUE,width=5,height=5,scale=250)
render_highquality()
render_movie(filename = "population.mp4", frames = 600, fps = 60, phi = 25, zoom = 0.8, theta = -90)

