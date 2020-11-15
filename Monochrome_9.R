# Check that required packages are running
devtools::install_github("thomasp85/patchwork")
library(patchwork)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, extrafont, sf)

# Get working directory
wd <- getwd()

# I found a Google Maps point dataset of English Cathedrals, downloaded as a KML
cathedrals <- st_read("English Cathedrals.kml")
cathedrals <- st_transform(cathedrals, 27700)
cathedrals <- st_zm(cathedrals)
st_crs(cathedrals) = 27700
cathedrals <- subset(cathedrals, cathedrals$Name != "Placemark 22")

# Make a bounding box of the English Cathedrals, add a buffer, so that we don't import more of the OS OpenMap Local ImportantBuilding layer than we need to.
cathedral.bbox <- st_as_sf(st_as_sfc(st_bbox(cathedrals)), 27700)
cathedral.bbox <- st_buffer(cathedral.bbox, 500)
wkt <- st_as_text(st_geometry(cathedral.bbox))

important.sf <- st_read(paste0(wd, "/water/data/opmplc_gb.gpkg"), layer = "ImportantBuilding", wkt_filter = wkt)
st_crs(important.sf) = 27700

important.sf <- subset(important.sf, important.sf$buildingTheme == "Religious Buildings")

# Not all of the OS ImportantBuildings data says whether it is a cathedral, and no mention of the denomination.  So, I loop through a subset of all religious ImportantBuildings within a 1km buffer, filtering for keywords (Ely is called "St Mary's Chapel" for some reason).
cathedral.list <- list()

for(i in 1:nrow(cathedrals)){
  buffer <- st_buffer(cathedrals[i,], 1000)
  clip.sf <- st_intersection(important.sf, buffer)
  clip.sf <- subset(clip.sf, grepl("Cathedral", clip.sf$distinctiveName) |
                      grepl("Abbey", clip.sf$distinctiveName) |
                      grepl("Minster", clip.sf$distinctiveName) |
                      grepl("St Mary's Chapel", clip.sf$distinctiveName))
  cathedral.list[[i]] <- clip.sf
  print(i)
}

cathedrals <- mapedit:::combine_list_of_sf(cathedral.list)
st_crs(cathedrals) = 27700

# Now that I have a list of potentials, I subset out the unwanted ones (RC instead of CofE etc.).  Note that some cathedrals will have multiple cathedrals, but others will include neighbouring cathedrals (St Pauls and Southwark, Sheffield RC and CofE) - clean that up.
cathedrals <- subset(cathedrals, cathedrals$distinctiveName != "Westminster Cathedral")
cathedrals <- subset(cathedrals, cathedrals$distinctiveName != "The Metropolitan Cathedral Church of St Chad")
cathedrals <- subset(cathedrals, cathedrals$distinctiveName != "Metropolitan Cathedral of Christ the King")
cathedrals <- subset(cathedrals, !(cathedrals$distinctiveName == "The Guild Church of St Nicholas Cole Abbey" & cathedrals$Name == "Southwark Cathedral"))
cathedrals <- subset(cathedrals, !(cathedrals$distinctiveName == "St Paul's Cathedral" & cathedrals$Name == "Southwark Cathedral"))
cathedrals <- subset(cathedrals, !(cathedrals$distinctiveName == "The Guild Church of St Nicholas Cole Abbey" & cathedrals$Name == "St Paul's Cathedral"))
cathedrals <- subset(cathedrals, !(cathedrals$distinctiveName == "The Cathedral and Collegiate Church of St Saviour and St Mary Overie, Southwark" & cathedrals$Name == "St Paul's Cathedral"))
cathedrals <- subset(cathedrals, cathedrals$distinctiveName != "St Mary's Roman Catholic Cathedral")
cathedrals <- subset(cathedrals, cathedrals$distinctiveName != "Cathedral Church of St Marie")

rm(buffer, cathedral.bbox, cathedral.list, clip.sf, important.sf, i, wkt)

# Cathedral is superflous in the label now
cathedrals$Name <- gsub("Cathedral", "", cathedrals$Name)

# I want to use Transport as a font, so set up additional fonts
font_import(prompt = FALSE)
loadfonts()

# Make a list of cathedrals alphabetical
namelist <- sort(unique(cathedrals$Name))

# Set font size
f <- 6

# The plots will be turned into a grid using the patchwork package.  This loop makes a ggplot object of each in turn.
for(i in 1:length(namelist)){
  print("starting...")
  g2 <- ggplot() +
    geom_sf(data = cathedrals[cathedrals$Name == namelist[i],], fill = "black", color = "black") +
    theme_classic(base_size = f, base_family = "Transport") +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.line.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.line.y=element_blank(),
          plot.title = element_text(hjust = 0.5),
          legend.position = "none",
          plot.margin=grid::unit(c(2,2,2,2), "mm")) +
    ggtitle(namelist[i])
  assign(paste0("p", i), g2)
  print(i/length(namelist))
  print(i)
}

# Set this up for the patchwork package
map.gg <- p1 + 
  p2 + 
  p3 +
  p4 +
  p5 +
  p6 +
  p7 +
  p8 +
  p9 +
  p10 +
  p11 +
  p12 +
  p13 +
  p14 +
  p15 +
  p16 +
  p17 +
  p18 +
  p19 +
  p20 +
  p21 +
  p22 +
  p23 +
  p24 +
  p25 +
  p26 +
  p27 +
  p28 +
  p29 +
  p30 +
  p31 +
  p32 +
  p33 +
  p34 +
  p35 +
  p36 +
  p37 +
  p38 +
  p39 +
  p40 +
  p41 +
  p42 +
  plot_layout()

ggsave("Monochrome_9.jpg", map.gg, scale = 2, dpi = 'retina')

