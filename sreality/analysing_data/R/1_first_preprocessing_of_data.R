# load packages
library(daff)
library(DBI)
library(RMariaDB)
library(tidyverse)
library(reshape)
library(httr)
library(plyr)
library(jsonlite)
library(stringi)
library(describer)
# setwd("~/Documents/master_thesis_git_repo/code_data/analysing_data/R")
set.seed(51987)
options(tibble.print_max = 10, tibble.width = Inf)
options(digits=20)

con <- dbConnect(RMariaDB::MariaDB(), 
                 dbname = "sreality_cz", user="root",
                 default.file="/home/jm/Documents/master_thesis_git_repo/code_data/analysing_data/R/.my.cnf")
dbGetInfo(con)
dbListTables(con)

# merge tables into 4 data frames for manupulation
number_apart <- 1:13
number_hous <- 1:6

################
# Map(...) assigns what kind of size the property is (comes from tables)
################
aprt_table_buy <- paste0("individual_apartments_toBuy_roomSize_",number_apart)
aprt_table_rent <- paste0("individual_apartments_toRent_roomSize_",number_apart)
hous_table_buy <- paste0("individual_houses_toBuy_roomSize_",number_hous)
hous_table_rent <- paste0("individual_houses_toRent_roomSize_",number_hous)

aprt_table_buy_df <- Map(cbind,lapply(aprt_table_buy,dbReadTable, conn = con),roomSize = as.list(number_apart))
aprt_table_rent_df <- Map(cbind,lapply(aprt_table_rent,dbReadTable, conn = con),roomSize = as.list(number_apart))

hous_table_buy_df <- Map(cbind,lapply(hous_table_buy, dbReadTable, conn = con),roomSize = as.list(number_hous))
hous_table_rent_df <- Map(cbind,lapply(hous_table_rent, dbReadTable, conn = con),roomSize = as.list(number_hous))

df_aprt_buy <- as.tbl(merge_all(aprt_table_buy_df))
df_aprt_rent <- as.tbl(merge_all(aprt_table_rent_df))

df_hous_buy <- as.tbl(merge_all(hous_table_buy_df))
df_hous_rent <- as.tbl(merge_all(hous_table_rent_df))

rm(aprt_table_buy_df, aprt_table_rent_df, hous_table_buy_df, hous_table_rent_df)

############################
########### Data Cleaning - Selecting only unique, most recent houses and apartements
# Approach from SQL
############################
# duplicates
#n_dup <- data.frame(table(df_aprt_buy$estate_ID))

# check for sum if correct
# those which have more than 1 duplicate
#n_dup_gt_1 <- n_dup[n_dup$Freq > 1,]
#print(sum(n_dup_gt_1$Freq)) #sums freq of all that have more than 1
#print(sum(n_dup_gt_1$Freq) + sum(n_dup[n_dup$Freq == 1,]$Freq)) 
# plus those which are unique ====> must be same number
#class(df_aprt_buy$time_Snapshot)

df_aprt_buy_most_recent <- df_aprt_buy %>% 
  group_by(estate_ID) %>%
  filter(time_Snapshot == max(time_Snapshot)) %>% 
  distinct(estate_ID, .keep_all = TRUE)
  
df_aprt_rent_most_recent <- df_aprt_rent %>% 
  group_by(estate_ID) %>%
  filter(time_Snapshot == max(time_Snapshot)) %>% 
  distinct(estate_ID, .keep_all = TRUE)

df_hous_buy_most_recent <- df_hous_buy %>% 
  group_by(estate_ID) %>%
  filter(time_Snapshot == max(time_Snapshot)) %>% 
  distinct(estate_ID, .keep_all = TRUE)

df_hous_rent_most_recent <- df_hous_rent %>% 
  group_by(estate_ID) %>%
  filter(time_Snapshot == max(time_Snapshot)) %>% 
  distinct(estate_ID, .keep_all = TRUE)

rm(df_aprt_buy, df_aprt_rent, df_hous_buy, df_hous_rent)

###############
###############
# drops index
df_aprt_buy_most_recent$index <- NULL
df_aprt_rent_most_recent$index <- NULL
df_hous_buy_most_recent$index <- NULL
df_hous_rent_most_recent$index <- NULL

# export data for scrapy
# write_csv(df_aprt_rent_most_recent[,c(3,8,9)], "CSVs/id_lot_lat2.csv")
# write_csv(df_aprt_buy_most_recent[,c(3,8,9)], "CSVs/id_lot_lat.csv")
# write_csv(df_hous_buy_most_recent[,c(3,8,9)], "CSVs/id_lot_lat3.csv")

##############################
############ (RE-) Naming, see that thesis
#############################
colnames(df_aprt_buy_most_recent)[which(names(df_aprt_buy_most_recent) == "size")] <- "floor"
colnames(df_aprt_rent_most_recent)[which(names(df_aprt_rent_most_recent) == "size")] <- "floor"
colnames(df_hous_buy_most_recent)[which(names(df_hous_buy_most_recent) == "size")] <- "floor"
colnames(df_hous_rent_most_recent)[which(names(df_hous_rent_most_recent) == "size")] <- "floor"

colnames(df_aprt_buy_most_recent)[which(names(df_aprt_buy_most_recent) == "house_Place")] <- "house_type"
colnames(df_aprt_rent_most_recent)[which(names(df_aprt_rent_most_recent) == "house_Place")] <- "house_type"
colnames(df_hous_buy_most_recent)[which(names(df_hous_buy_most_recent) == "house_Place")] <- "house_type"
colnames(df_hous_rent_most_recent)[which(names(df_hous_rent_most_recent) == "house_Place")] <- "house_type"

source("1_1_convertVariables_funcs.R")

# Convert property size (roomSize) to fact with better description
df_aprt_buy_most_recent$roomSize <- apply(array(df_aprt_buy_most_recent[["roomSize"]]),MARGIN=1, FUN=convertApprtmentRoomSize, toFactor = T)
df_aprt_rent_most_recent$roomSize <- apply(array(df_aprt_rent_most_recent[["roomSize"]]),MARGIN=1, FUN=convertApprtmentRoomSize, toFactor = T)
df_hous_buy_most_recent$roomSize <- apply(array(df_hous_buy_most_recent[["roomSize"]]),MARGIN=1, FUN=convertHouseRoomSize, toFactor = T)
df_hous_rent_most_recent$roomSize <- apply(array(df_hous_rent_most_recent[["roomSize"]]),MARGIN=1, FUN=convertHouseRoomSize, toFactor = T)

# convert energy rating
df_aprt_buy_most_recent$energy_efficiency_rating <- convertEnergyRating(df_aprt_buy_most_recent)
df_aprt_rent_most_recent$energy_efficiency_rating <- convertEnergyRating(df_aprt_rent_most_recent)
df_hous_buy_most_recent$energy_efficiency_rating <- convertEnergyRating(df_hous_buy_most_recent)
df_hous_rent_most_recent$energy_efficiency_rating <- convertEnergyRating(df_hous_rent_most_recent)

# rename czech terms to english ones: property_status, ownership
df_aprt_buy_most_recent$ownership <- convertOwnership(df_aprt_buy_most_recent)
df_aprt_rent_most_recent$ownership <- convertOwnership(df_aprt_rent_most_recent)
df_hous_buy_most_recent$ownership <- convertOwnership(df_hous_buy_most_recent)
df_hous_rent_most_recent$ownership <- convertOwnership(df_hous_rent_most_recent)

df_aprt_buy_most_recent$property_status <- convertPropertyStatus(df_aprt_buy_most_recent)
df_aprt_rent_most_recent$property_status <- convertPropertyStatus(df_aprt_rent_most_recent)
df_hous_buy_most_recent$property_status <- convertPropertyStatus(df_hous_buy_most_recent)
df_hous_rent_most_recent$property_status <- convertPropertyStatus(df_hous_rent_most_recent)

df_aprt_buy_most_recent$building <- convertBuilding(df_aprt_buy_most_recent)
df_aprt_rent_most_recent$building <- convertBuilding(df_aprt_rent_most_recent)
df_hous_buy_most_recent$building <- convertBuilding(df_hous_buy_most_recent)
df_hous_rent_most_recent$building <- convertBuilding(df_hous_rent_most_recent)

df_hous_buy_most_recent$house_type <- convertHouseType(df_hous_buy_most_recent)
df_hous_rent_most_recent$house_type <- convertHouseType(df_hous_rent_most_recent)

colnames(df_aprt_buy_most_recent)[which(names(df_aprt_buy_most_recent) == "property_status")] <- "property_condition"
colnames(df_aprt_rent_most_recent)[which(names(df_aprt_rent_most_recent) == "property_status")] <- "property_condition"
colnames(df_hous_buy_most_recent)[which(names(df_hous_buy_most_recent) == "property_status")] <- "property_condition"
colnames(df_hous_rent_most_recent)[which(names(df_hous_rent_most_recent) == "property_status")] <- "property_condition"

##############################
############ Cleaning #2: Convert to some Factors, Numerics
# https://stackoverflow.com/a/5992152
#############################
cleanDF <- function(datafm, ...) {
  datafm$year_finalInspection <- as.numeric(as.character(datafm$year_finalInspection))
  datafm$year_reconstruction <- as.numeric(as.character(datafm$year_reconstruction))
  datafm$swimming_pool <- as.factor(datafm$swimming_pool)
  datafm$cellar <- as.factor(datafm$cellar)
  datafm$elevator <- as.factor(datafm$elevator)
  datafm$equipment <- as.factor(datafm$equipment)
  datafm$parking <- as.factor(datafm$parking)
  datafm$non_barrier <- as.factor(datafm$non_barrier)
  datafm$living_area <- as.numeric(datafm$living_area)
  datafm$land_area  <- as.numeric(datafm$land_area)
  datafm$garden_area  <- as.numeric(datafm$garden_area)  
  datafm$build_area <- as.numeric(datafm$build_area)

  datafm$current_price <- ifelse(datafm$current_price == "Informace o ceně na dotaz", NA, 
         as.numeric(stri_replace_all_charclass(datafm$current_price, "\\p{WHITE_SPACE}", "")))
  
  datafm$old_price <- ifelse(datafm$old_price == "Informace o ceně na dotaz", NA, 
                                 as.numeric(stri_replace_all_charclass(datafm$old_price, "\\p{WHITE_SPACE}", "")))
  datafm
}

df_aprt_buy_most_recent <- cleanDF(df_aprt_buy_most_recent)
df_aprt_rent_most_recent <- cleanDF(df_aprt_rent_most_recent)
df_hous_buy_most_recent <- cleanDF(df_hous_buy_most_recent)
df_hous_rent_most_recent <- cleanDF(df_hous_rent_most_recent)

sapply(df_aprt_buy_most_recent, class)
dim(rbind(df_hous_rent_most_recent, df_aprt_buy_most_recent, df_hous_buy_most_recent, df_aprt_rent_most_recent))                                                            

########### Store data in RData files & load for easier manipulation
saveRDS(df_aprt_buy_most_recent, "RData/df_aprt_buy_most_recent.rds")
saveRDS(df_aprt_rent_most_recent, "RData/df_aprt_rent_most_recent.rds")
saveRDS(df_hous_buy_most_recent, "RData/df_hous_buy_most_recent.rds")
saveRDS(df_hous_rent_most_recent, "RData/df_hous_rent_most_recent.rds")

# df_aprt_buy_most_recent <- readRDS("RData/df_aprt_buy_most_recent.rds")
# df_aprt_rent_most_recent <- readRDS("RData/df_aprt_rent_most_recent.rds")
# df_hous_buy_most_recent <- readRDS("RData/df_hous_buy_most_recent.rds")
# df_hous_rent_most_recent <- readRDS("RData/df_hous_rent_most_recent.rds")



