# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(Rcpp, pkgconfig, tidyverse, plyr, downloader, dplyr, hexbin, proj4, rlist, nngeo, kableExtra, tmap, tmaptools, extrafont, rmapshaper, pryr, mapedit, sf, ggmap)

# Get working directory
wd <- getwd()

boundary.sf <- st_read("Counties_and_Unitary_Authorities__December_2019__Boundaries_UK_BFC.kml")
boundary.sf <- st_transform(boundary.sf, 27700)
st_crs(boundary.sf) = 27700
boundary.sf <- st_zm(boundary.sf)

OS.sf <- st_read(paste0(wd, "/borough/Data/GB/district_borough_unitary_region.shp"))
st_crs(OS.sf) = 27700
OS.sf <- st_zm(OS.sf)

OS.sf <- subset(OS.sf, grepl("Gravesham", OS.sf$NAME, ignore.case = TRUE) |
                  grepl("Medway", OS.sf$NAME, ignore.case = TRUE) |
                  grepl("Swale", OS.sf$NAME, ignore.case = TRUE) |
                  grepl("Canterbury", OS.sf$NAME, ignore.case = TRUE) |
                  grepl("Thanet", OS.sf$NAME, ignore.case = TRUE))

land.sf <- boundary.sf[OS.sf,]
land.sf <- st_as_sf(st_union(land.sf))

flood.sf <- st_read("Risk_of_Flooding_from_Rivers_and_Sea.gml")
flood.sf <- st_transform(flood.sf, 27700)

flood.sf.high <- st_as_sf(st_union(flood.sf[flood.sf$prob_4band == "High",]))
flood.sf.low <- st_as_sf(st_union(flood.sf[flood.sf$prob_4band == "Low",]))
flood.sf.medium <- st_as_sf(st_union(flood.sf[flood.sf$prob_4band == "Medium",]))
flood.sf.vlow <- st_as_sf(st_union(flood.sf[flood.sf$prob_4band == "Very Low",]))

land.sf.high <- st_difference(land.sf, flood.sf.high)
land.sf.low <- st_difference(land.sf, flood.sf.low)
land.sf.medium <- st_difference(land.sf, flood.sf.medium)
land.sf.vlow <- st_difference(land.sf, flood.sf.vlow)

land.sf.high$level <- "High"
land.sf.low$level <- "Low"
land.sf.medium$level <- "Medium"
land.sf.vlow$level <- "Very Low" 

land.sf <- bind_rows(land.sf.high, land.sf.low, land.sf.medium, land.sf.vlow)

object_size(land.sf)
object_size(land.sf.simplify)

land.sf.simplify <- st_simplify(land.sf, dTolerance =  100, preserveTopology = TRUE)

map.gg <- ggplot(land.sf.simplify) +
  geom_sf(fill = "black", color = NA) +
  theme_classic() +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.line.x=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        axis.line.y=element_blank(),
        legend.position = "none") +
  facet_wrap(vars(level)) +
ggtitle("Kent: risk of flooding from rivers and the sea")

ggsave("Climate_change_14.jpg", map.gg, dpi = 'retina')

