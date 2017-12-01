#library(Hmisc) ### carefull here
library(dplyr)
library(data.table)
library(fBasics)
library(tidyverse)
library(plyr)
library(VIM)
library(Amelia)
library(stringr)

# cd analysing_data && R CMD Sweave R/LaTeX/la.Rnw 
# Sweave("LaTeX/la.Rnw")

# for map
# RColor Brewer: ['#feebe2','#fcc5c0','#fa9fb5','#f768a1','#dd3497','#ae017e','#7a0177']

# #1
# Some Data are missing NA -> need to do manually


df_aprt_buy_most_recent$seller_agn_Phone_Number
df_aprt_buy_most_recent$seller_agn_Phone_Number2
df_aprt_buy_most_recent$address

df_aprt_rent_most_recent$address



# missing data
aggr(df_aprt_rent_most_recent, prop = F, numbers = T)
missmap(df_aprt_rent_most_recent)

  
# non-duplicate frequency of sizes
table(df_aprt_buy_most_recent$roomSize)
table(df_aprt_rent_most_recent$roomSize)
table(df_hous_buy_most_recent$roomSize)
table(df_hous_rent_most_recent$roomSize)

# task1: construct variable where each place is located

avarage_price <- df_aprt_buy_most_recent[,c(7:9, 21) ]

x <- as.data.frame(table(df_hous_buy_most_recent$address))

asd <- strsplit(df_hous_buy_most_recent$address, ",")
a<-str_split_fixed(df_hous_buy_most_recent$address, ",", 2)


tst_prague_metro_areas <- read_sf("/home/jm/Downloads/mapy_prahy/TMMESTSKECASTI_P_shp/TMMESTSKECASTI_P.shp")
db_prague_metro_areas <- read.dbf("/home/jm/Downloads/mapy_prahy/TMMESTSKECASTI_P_shp/TMMESTSKECASTI_P.dbf")


point <- data.frame(lon=df_hous_rent_most_recent$address_lon, lat=df_hous_rent_most_recent$address_lat)

datamatrix_point <- st_point(data.matrix(point)[3,1:2])
b <- as.data.frame(st_contains(tst_prague_metro_areas, datamatrix_point, sparse = F))
b$rn <- rownames(b)
c <- which(b$V1 == TRUE)

db_prague_metro_areas[c, c(3, 8)]
asdqdqf <- cbind.data.frame(df_hous_rent_most_recent[3,], db_prague_metro_areas[c, ])









