# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, sf, stplanr, pct)

# Get working directory
wd <- getwd()

# Read in the Counties and Local Authorities boundaries from ONS Open Geography website (clipped to High Water)
boundary.sf <- st_read("Counties_and_Unitary_Authorities__December_2019__Boundaries_UK_BFC.kml")
boundary.sf <- st_transform(boundary.sf, 27700)
st_crs(boundary.sf) = 27700

# Read in the OS BoundaryLine boundaries, saved in a sub-folder
OS.sf <- st_read(paste0(wd, "/borough/Data/GB/district_borough_unitary_region.shp"))
st_crs(OS.sf) = 27700

# I'm mostly interesting in the North Kent coast, so subset for these LAs.
OS.sf <- subset(OS.sf, grepl("Gravesham", OS.sf$NAME, ignore.case = TRUE) |
                  grepl("Medway", OS.sf$NAME, ignore.case = TRUE) |
                  grepl("Swale", OS.sf$NAME, ignore.case = TRUE) |
                  grepl("Canterbury", OS.sf$NAME, ignore.case = TRUE) |
                  grepl("Thanet", OS.sf$NAME, ignore.case = TRUE))

land.sf <- boundary.sf[OS.sf,]
land.sf <- st_as_sf(st_union(land.sf))
land.sf <- st_transform(land.sf, 4326)

# get nationwide OD data (this section borrows heavily from a Robin Lovelace vignette for stplanr)
od_all <- pct::get_od()

# get population weighted centroids
centroids_all <- pct::get_centroids_ew() %>% sf::st_transform(4326)

kent <- pct::pct_regions %>% filter(region_name == "kent")
centroids_kent <- centroids_all[kent, ]

# filter out non-Kent Origins and Destinations
od_kent <- od_all[
  od_all$geo_code1 %in% centroids_kent$msoa11cd &
    od_all$geo_code2 %in% centroids_kent$msoa11cd,
]

# Make desire lines for Kent
desire_lines_kent <- od2line(od_kent, centroids_kent)
desire_lines_inter <- desire_lines_kent %>% filter(geo_code1 != geo_code2)
desire_lines_inter$car <- desire_lines_inter$car_driver + desire_lines_inter$car_passenger

map.gg <- ggplot() +
  geom_sf(data = land.sf, fill = NA, color = "black") +
  geom_sf(data = desire_lines_inter, color = alpha("red", desire_lines_inter$car/max(desire_lines_inter$all))) +
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
  ggtitle("Journey to Work within Kent by car (driver or passenger)")

ggsave("Connections_15.jpg", map.gg, scale = 1, dpi = 'retina')
