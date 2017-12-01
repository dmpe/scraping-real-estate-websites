# df_aprt_buy_most_recent <- readRDS("RData/df_aprt_buy_most_recent.rds")
# df_aprt_rent_most_recent <- readRDS("RData/df_aprt_rent_most_recent.rds")
# df_hous_buy_most_recent <- readRDS("RData/df_hous_buy_most_recent.rds")
# df_hous_rent_most_recent <- readRDS("RData/df_hous_rent_most_recent.rds")

library(stringi)
library(stringr)
library(dplyr)

######### Firstly, get rid of "chata"/cottages and then aucktions "Dražba"
###########
df_hous_rent_most_recent <- df_hous_rent_most_recent[!grepl("chat", df_hous_rent_most_recent$name, ignore.case = T, fixed = F),]
df_hous_buy_most_recent <- df_hous_buy_most_recent[!grepl("chat", df_hous_buy_most_recent$name, ignore.case = T, fixed = F),]

# aucktions
df_hous_rent_most_recent <- df_hous_rent_most_recent[!grepl("Dražb", df_hous_rent_most_recent$name, ignore.case = T, fixed = F),]
df_hous_buy_most_recent <- df_hous_buy_most_recent[!grepl("Dražb", df_hous_buy_most_recent$name, ignore.case = T, fixed = F),]
df_aprt_buy_most_recent <- df_aprt_buy_most_recent[!grepl("Dražb", df_aprt_buy_most_recent$name, ignore.case = T, fixed = F),]
df_aprt_rent_most_recent <- df_aprt_rent_most_recent[!grepl("Dražb", df_aprt_rent_most_recent$name, ignore.case = T, fixed = F),]




######### Removal of Duplicate properties
####### select only those where living+land area, name, lat+lon and description have all (!) unique value
###########
# for testing
# s <- df_hous_rent_most_recent %>% dplyr::distinct(name, address_lat, address_lon, living_area, .keep_all = T)
# sds <- df_hous_rent_most_recent %>% 
#   group_by(name, address_lat,address_lon, living_area ) %>% 
#   filter(n()>1)
# sds2 <- df_hous_buy_most_recent %>% 
#   group_by(name, address_lat,address_lon, living_area ) %>% 
#   filter(n()>1) %>% 
#   arrange(name, address_lat,address_lon, living_area) %>% 
#   distinct(name, address_lat,address_lon, living_area, .keep_all = T)


s1 <- df_hous_rent_most_recent %>% dplyr::distinct(name, address_lat, address_lon, living_area, land_area, .keep_all = T)
s2 <- df_hous_buy_most_recent %>% dplyr::distinct(name, address_lat, address_lon, living_area, land_area,.keep_all = T)
s3 <- df_aprt_rent_most_recent %>% dplyr::distinct(name, address_lat, address_lon, living_area, land_area, .keep_all = T)
s4 <- df_aprt_buy_most_recent %>% dplyr::distinct(name, address_lat, address_lon, living_area, land_area, .keep_all = T)

# sds2 <- df_aprt_buy_most_recent %>%
#   group_by(name, address_lat,address_lon, living_area, description ) %>%
#   filter(n()>1) %>%
#   arrange(name, address_lat,address_lon, living_area, description) %>%
#   distinct(name, address_lat,address_lon, living_area, description, .keep_all = T)

saveRDS(df_aprt_buy_most_recent, "RData/df_aprt_buy_most_recent.rds")
saveRDS(df_aprt_rent_most_recent, "RData/df_aprt_rent_most_recent.rds")
saveRDS(df_hous_buy_most_recent, "RData/df_hous_buy_most_recent.rds")
saveRDS(df_hous_rent_most_recent, "RData/df_hous_rent_most_recent.rds")



###### Fix errors
####
df_hous_rent_most_recent[which(df_hous_rent_most_recent$random_id_num=="441591399673694"),"NAZEV_MC"] <- "Praha 4"
df_hous_rent_most_recent[which(df_hous_rent_most_recent$random_id_num=="441591399673694"),"NAZEV_1"] <- "Praha 4"

df_hous_rent_most_recent[which(df_hous_rent_most_recent$random_id_num=="147404828826291"),"NAZEV_MC"] <- "Praha-Nebušice"
df_hous_rent_most_recent[which(df_hous_rent_most_recent$random_id_num=="147404828826291"),"NAZEV_1"] <- "Nebušice"

- get rid of "prague" in address field