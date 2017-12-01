library(tidyverse)
setwd("~/Documents/master_thesis_git_repo/code_data/analysing_data/R")
set.seed(51987)
options(tibble.print_max = 10, tibble.width = Inf)
options(digits=20)

# df_aprt_buy_most_recent <- readRDS("RData/df_aprt_buy_most_recent.rds")
# df_aprt_rent_most_recent <- readRDS("RData/df_aprt_rent_most_recent.rds")
# df_hous_buy_most_recent <- readRDS("RData/df_hous_buy_most_recent.rds")
# df_hous_rent_most_recent <- readRDS("RData/df_hous_rent_most_recent.rds")


####################
######## append more data from Cenovamapa.eu
####################
####
## Now go and execute scrapy scripts each individually (maybe parallel too).
## takes a very long time
####
#system2('cd ~/Documents/master_thesis_git_repo/code_data/analysing_data/scrapy/cepa && scrapy crawl cepa')
#system2('cd ~/Documents/master_thesis_git_repo/code_data/analysing_data/scrapy/cepa && scrapy crawl cepa2')
#system2('cd ~/Documents/master_thesis_git_repo/code_data/analysing_data/scrapy/cepa && scrapy crawl cepa3')

# once done, continue here

# check for any delta
new <- read_csv("CSVs/df.csv")
new$prop_id <- as.character(new$prop_id)
new <- new %>% 
  distinct(prop_id, .keep_all = T)
df_aprt_buy_most_recent <- dplyr::left_join(df_aprt_buy_most_recent, new, by = c("estate_ID" = "prop_id"))
df_aprt_buy_most_recent <- df_aprt_buy_most_recent %>% ungroup()

new2 <- read_csv("CSVs/df2.csv")
new2$prop_id <- as.character(new2$prop_id)
new2 <- new2 %>% 
  distinct(prop_id, .keep_all = T)
df_aprt_rent_most_recent <- dplyr::left_join(df_aprt_rent_most_recent, new2, by = c("estate_ID" = "prop_id"))
df_aprt_rent_most_recent <- df_aprt_rent_most_recent %>% ungroup()

new3 <- read_csv("CSVs/df3.csv")
new3$prop_id <- as.character(new3$prop_id)
new3 <- new3 %>% 
  distinct(prop_id, .keep_all = T)
df_hous_buy_most_recent <- dplyr::left_join(df_hous_buy_most_recent, new3, by = c("estate_ID" = "prop_id"))
df_hous_buy_most_recent <- df_hous_buy_most_recent %>% ungroup()

rm(new, new2, new3)


############
######## for houses that are for renting cenovamapa.eu doesnt provide any estimations. Hence we need something different. 
######## However I am not going to use it for second sub-question of RQ2!!!!!
source("2_1_price_map_data_prague_city.R")

# store all three again
saveRDS(df_aprt_buy_most_recent, "RData/df_aprt_buy_most_recent.rds")
saveRDS(df_aprt_rent_most_recent, "RData/df_aprt_rent_most_recent.rds")
saveRDS(df_hous_buy_most_recent, "RData/df_hous_buy_most_recent.rds")
saveRDS(df_hous_rent_most_recent, "RData/df_hous_rent_most_recent.rds")


