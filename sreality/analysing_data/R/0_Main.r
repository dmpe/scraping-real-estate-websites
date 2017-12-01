packages <- c("tidyverse", "sp", "sf", "raster", "leaflet", "tmap", "ggmap", 
              "DBI", "RMariaDB", "reshape", "httr", "plyr", "jsonlite", "stringi", 
              "describer", "xtable")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}
library(tidyverse)
library(sp)
library(sf)
library(raster)
library(leaflet)
library(tmap)
library(ggmap)
library(foreign)
library(rgdal)
library(maps)
library(mapview)
library(osmdata)
setwd("~/Documents/master_thesis_git_repo/code_data/analysing_data/R")
set.seed(51987)
options(tibble.print_max = 10, tibble.width = Inf)
options(digits=20)


# if Database etc is not set up, just lead RData
# df_aprt_buy_most_recent <- readRDS("RData/df_aprt_buy_most_recent.rds")
# df_aprt_rent_most_recent <- readRDS("RData/df_aprt_rent_most_recent.rds")
# df_hous_buy_most_recent <- readRDS("RData/df_hous_buy_most_recent.rds")
# df_hous_rent_most_recent <- readRDS("RData/df_hous_rent_most_recent.rds")



source("1_1_convertVariables_funcs.R")
source("1_first_preprocessing_of_data.R")
source("2_1_price_map_data_prague_city.R")
source("2_adding_more_data.R")
source("3_second_preprocessing_of_data.R")
source("exploration.R")

######### Here start answering research subquestions of RQ2
# https://blog.dominodatalab.com/geographic-visualization-with-rs-ggmaps/
#########
## 1Q: What are the average renting prices of homes and apartments in different 
#      districts of Prague?
shp_prague_metro_areas <- read_sf("/home/jm/Downloads/mapy_prahy/TMMESTSKECASTI_P_shp/TMMESTSKECASTI_P.shp")
dbf_prague_metro_areas <- read.dbf("/home/jm/Downloads/mapy_prahy/TMMESTSKECASTI_P_shp/TMMESTSKECASTI_P.dbf")
shp_prague_price_map <- read_sf("/home/jm/Downloads/mapy_prahy/SED_CenovaMapa_p_shp/SED_CenovaMapa_p.shp")

avarage_price_per_district <- df_hous_rent_most_recent %>% 
  group_by(NAZEV_MC) %>% 
  dplyr::mutate(avarage_price_MeanCurrentPrice = mean(current_price, na.rm = T), 
                avarage_price_CityHallPrice = mean(price_sq_meter_offEstimation_cityHall, na.rm = T))

avarage_price_per_district <- avarage_price_per_district[, c(46,47, 48, 49)] %>% distinct(.keep_all = T) %>% ungroup()

prices_prague_house_rent <- shp_prague_metro_areas %>% 
  left_join(avarage_price_per_district, by = "NAZEV_MC")

avarage_price_per_district$formatted_MeanCurrentPrice <- cut(round(avarage_price_per_district$avarage_price_MeanCurrentPrice,1), 9, include.lowest=TRUE, dig.lab=7)


#http://strimas.com/r/tidy-sf/
mapview(prices_prague_house_rent, alpha.regions = 0.2, aplha = 1)@map %>% 
  setView(lat = 50.07555, lng = 14.4378001, zoom = 11)

-- delete uncessary stuff

prague <- as.numeric(geocode("Prague"))
Prague_city <- ggmap(get_googlemap(center=prague, scale=2, zoom=10))


###################
#https://cran.r-project.org/doc/contrib/intro-spatial-rl.pdf
#https://github.com/mtennekes/tmap
###################
## 2Q: How do the market prices compare to Prague’s city hall price map?
###################

