# Check that required packages are running
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, sf)

# Get working directory
wd <- getwd()

SeventyNineOhFour.df <- read.csv(paste0(wd, "/STATS19/Accidents7904.csv"))
SeventyNineOhFour.df <- SeventyNineOhFour.df[,1:3]

OhFiveFourten.df <- read.csv(paste0(wd, "/STATS19/Accidents0514.csv"))
OhFiveFourten.df <- OhFiveFourten.df[,1:3]

Fifteen.df <- read.csv(paste0(wd, "/STATS19/Accidents_2015.csv"))
Fifteen.df <- Fifteen.df[,1:3]

Sixteen.df <- read.csv(paste0(wd, "/STATS19/dftRoadSafety_Accidents_2016.csv"))
Sixteen.df <- Sixteen.df[,1:3]

Seventeen.df <- read.csv(paste0(wd, "/STATS19/Acc.csv"))
Seventeen.df <- Seventeen.df[,1:3]

Eighteen.df <- read.csv(paste0(wd, "/STATS19/dftRoadSafetydata_Accidents_2018.csv"))
Eighteen.df <- Eighteen.df[,1:3]

Nineteen.df <- read.csv(paste0(wd, "/STATS19/Accidents0514.csv"))
Nineteen.df <- Nineteen.df[,1:3]

STATS19.df <- rbind(SeventyNineOhFour.df, OhFiveFourten.df, Fifteen.df, Sixteen.df, Seventeen.df, Eighteen.df, Nineteen.df)
rm(SeventyNineOhFour.df, OhFiveFourten.df, Fifteen.df, Sixteen.df, Seventeen.df, Eighteen.df, Nineteen.df)

STATS19.df$Location_Easting_OSGR[is.na(STATS19.df$Location_Easting_OSGR)] <- 0
STATS19.df$Location_Northing_OSGR[is.na(STATS19.df$Location_Northing_OSGR)] <- 0

STATS19.df <- subset(STATS19.df, STATS19.df$Location_Easting_OSGR <= 10000 &
                                 STATS19.df$Location_Northing_OSGR <= 10000)

STATS19.sf <- st_as_sf(STATS19.df, coords = c("Location_Easting_OSGR", "Location_Northing_OSGR"), crs = 27700)
rm(STATS19.df)

mapview::mapview(STATS19.sf)

nullbuffer.sf <- st_buffer(STATS19.sf, 1000)

mapview::mapview(nullbuffer.sf)

nullbuffer.sf <- st_as_sf(st_union(nullbuffer.sf))

st_write(nullbuffer.sf, "null.kml")

