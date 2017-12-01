library(sf)
library(foreign)
library(rgdal)
library(maps)
library(mapview)
library(tmap)
library(osmdata)

df_hous_rent_most_recent <- readRDS("RData/df_hous_rent_most_recent.rds")

# http://www.geoportalpraha.cz/cs/opendata/E9E20135-18B3-4163-B516-45613956B856
# http://www.geoportalpraha.cz/cs/opendata/C4FE893C-81B9-4B4A-BDB4-292479C87E2D
shp_prague_metro_areas <- read_sf("/home/jm/Downloads/mapy_prahy/TMMESTSKECASTI_P_shp/TMMESTSKECASTI_P.shp")
dbf_prague_metro_areas <- read.dbf("/home/jm/Downloads/mapy_prahy/TMMESTSKECASTI_P_shp/TMMESTSKECASTI_P.dbf")
shp_prague_price_map <- read_sf("/home/jm/Downloads/mapy_prahy/SED_CenovaMapa_p_shp/SED_CenovaMapa_p.shp")


# shp_prague_price_map$geometry
# st_geometry(shp_prague_price_map)
# plot(st_geometry(shp_prague_price_map))

# create point data
point <- data.frame(lon=df_hous_rent_most_recent$address_lon, lat=df_hous_rent_most_recent$address_lat)

# alternative way
# as <- data.frame(apply(st_contains(shp_prague_price_map, st_point(data.matrix(point)[1,1:2]), sparse = F), 1, any))

estimatePriceMapCityHall <- function(x, onePoint = T,...) {
  # if a specific lat/lon is given
  if(onePoint){
    datamatrix_point <- st_point(data.matrix(point)[x,1:2])
    containsPointDF <- as.data.frame(st_contains(shp_prague_price_map, datamatrix_point, sparse = F))
    containsPointDF$rn <- rownames(containsPointDF)
    row_num_where_pointResides <- which(containsPointDF$V1 == TRUE)
    return(shp_prague_price_map[row_num_where_pointResides, 1])
  } else {
    datamatrix_point <- st_point(x)
    containsPointDF <- as.data.frame(st_contains(shp_prague_price_map, datamatrix_point, sparse = F))
    containsPointDF$rn <- rownames(containsPointDF)
    row_num_where_pointResides <- which(containsPointDF$V1 == TRUE)
    return(as.numeric(shp_prague_price_map[row_num_where_pointResides, 1])[1])
  }
}


# very SLOW because executes above function each time
# estimatePriceMapCityHall(3, onePoint= T)
# estimatePriceMapCityHall(data.matrix(point), onePoint = F)
vectorOfPrices <- apply(X = data.matrix(point), FUN= estimatePriceMapCityHall, MARGIN = 1, onePoint = F)
# sapply(X = data.matrix(point)[1:2,], FUN= estimatePriceMapCityHall, onePoint = F)
# sasd<-do.call(c, unlist(vectorOfPrices, recursive=FALSE))
df_hous_rent_most_recent$price_sq_meter_offEstimation_cityHall <- vectorOfPrices
#df_hous_rent_most_recent$living_area * df_hous_rent_most_recent$price_sq_meter_offEstimation_cityHall

#https://stackoverflow.com/a/5974908
estimateRightDistrict <- function(x, ...) {
  point <- data.frame(lon=x$address_lon, lat=x$address_lat)
  mydata <- list()
  for(d in 1:nrow(x)) {
    datamatrix_point <- st_point(data.matrix(point)[d,])
    containsPointDF <- as.data.frame(st_contains(shp_prague_metro_areas, datamatrix_point, sparse = F))
    containsPointDF$rn <- rownames(containsPointDF)
    city_district_where_pointResides <- which(containsPointDF$V1 == TRUE)
    districtNamesDF <- dbf_prague_metro_areas[city_district_where_pointResides, c(3, 8)]
    districtNamesDF$NAZEV_MC <- as.character(districtNamesDF$NAZEV_MC)
    districtNamesDF$NAZEV_1 <- as.character(districtNamesDF$NAZEV_1)
    rownames(districtNamesDF) <- NULL
    mydata[[d]] <- districtNamesDF
  }
  
  districtListNamesDF <- data.frame(t(sapply(mydata,c)))
  districtListNamesDF$NAZEV_MC <- as.character(districtListNamesDF$NAZEV_MC)
  districtListNamesDF$NAZEV_1 <- as.character(districtListNamesDF$NAZEV_1)
  x <- cbind.data.frame(x, districtListNamesDF)
  
  return(x)
}

df_hous_rent_most_recent <- estimateRightDistrict(df_hous_rent_most_recent)
df_aprt_buy_most_recent <- estimateRightDistrict(df_aprt_buy_most_recent)
df_aprt_rent_most_recent <- estimateRightDistrict(df_aprt_rent_most_recent)
df_hous_buy_most_recent <- estimateRightDistrict(df_hous_buy_most_recent)




