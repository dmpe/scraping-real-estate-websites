# Convert property size (roomSize) to fact with better description
# https://stackoverflow.com/a/18016872
convertApprtmentRoomSize <- function(x, toFactor = F, ...) {
  if(x == 1) {
    x <- "singleRoom"
  } else if (x == 2) {
    x <- "1+kk"
  } else if (x == 3) {
    x <- "1+1"
  } else if (x == 4) {
    x <- "2+kk"
  } else if (x == 5) {
    x <- "2+1"
  } else if (x == 6) {
    x <- "3+kk"
  } else if (x == 7) {
    x <- "3+1"
  } else if (x == 8) {
    x <- "4+kk"
  } else if (x == 9) {
    x <- "4+1"
  } else if (x == 10) {
    x <- "5+kk"
  } else if (x == 11) {
    x <- "5+1"
  } else if (x == 12) {
    x <- "6>="
  } else if (x == 13) {
    x <- "atypical"
  } else {
    paste("should never be", x)
  }
  
  if(toFactor) {
    x <- as.factor(x)
  }
  x
}


convertHouseRoomSize <- function(x, toFactor = F, ...) {
  if(x == 1) {
    x <- "singleRoom"
  } else if (x == 2) {
    x <- "2rooms"
  } else if (x == 3) {
    x <- "3rooms"
  } else if (x == 4) {
    x <- "4rooms"
  } else if (x == 5) {
    x <- "5>="
  } else if (x == 6) {
    x <- "atypical"
  } else {
    paste("should never be", x)
  }
  
  if(toFactor) {
    x <- as.factor(x)
  }
  x
}


convertEnergyRating <- function(x, ...) {
  x$energy_efficiency_rating[grepl("Třída A", x$energy_efficiency_rating, ignore.case=FALSE)] <- "Class A - Extraordinarily Effecient"
  x$energy_efficiency_rating[grepl("Třída B", x$energy_efficiency_rating, ignore.case=FALSE)] <- "Class B - Very Effecient"
  x$energy_efficiency_rating[grepl("Třída C", x$energy_efficiency_rating, ignore.case=FALSE)] <- "Class C - Economical"
  x$energy_efficiency_rating[grepl("Třída D", x$energy_efficiency_rating, ignore.case=FALSE)] <- "Class D - Less Economical"
  x$energy_efficiency_rating[grepl("Třída E", x$energy_efficiency_rating, ignore.case=FALSE)] <- "Class E - Non-Economical"
  x$energy_efficiency_rating[grepl("Třída F", x$energy_efficiency_rating, ignore.case=FALSE)] <- "Class F - Very Uneffecient"
  x$energy_efficiency_rating[grepl("Třída G", x$energy_efficiency_rating, ignore.case=FALSE)] <- "Class G - Extraordinarily Uneffecient"
  
  x$energy_efficiency_rating <- as.factor(x$energy_efficiency_rating)
}

convertOwnership <- function(x,...){
  x$ownership[x$ownership=="Osobní"] <- "Sole Ownership"
  x$ownership[x$ownership=="Družstevní"] <- "Cooperative"
  x$ownership[x$ownership=="Státní/obecní"] <- "Government owned"
  x$ownership <- as.factor(x$ownership)
}

convertBuilding <- function(x, ...) {
  x$building[x$building=="Smíšená"] <- "Mixed"
  x$building[x$building=="Panelová"] <- "Plattenbau/Panel"
  x$building[x$building=="Skeletová"] <- "Steel frame"
  x$building[x$building=="Cihlová"] <- "Brick"
  x$building[x$building=="Dřevěná"] <- "Wood"
  x$building[x$building=="Kamenná"] <- "Stone"
  x$building[x$building=="Montovaná"] <- "Prefabrication"
  
  x$building <- as.factor(x$building)
}

convertPropertyStatus <-function(x, ...) {
  x$property_status[x$property_status=="Novostavba"] <- "New"
  x$property_status[x$property_status=="Velmi dobrý"] <- "Very good"
  x$property_status[x$property_status=="Před rekonstrukcí"] <- "Before reconstruction"
  x$property_status[x$property_status=="Po rekonstrukci"] <- "After reconstruction"
  x$property_status[x$property_status=="Dobrý"] <- "Good"
  x$property_status[x$property_status=="Projekt"] <- "Project"
  x$property_status[x$property_status=="Špatný"] <- "Bad"
  x$property_status[x$property_status=="Ve výstavbě"] <- "In construction"
  
  x$property_status <- as.factor(x$property_status)
}

convertBuildingType_Houses <- function(x, ...){
  x$building_type[x$building_type=="Patrový"] <- "Multi storey"
  x$building_type[x$building_type=="Přízemní"] <- "Single storey"
  x$building_type <- as.factor(x$building_type)
}

convertHouseType <- function(x, ...){
  x$house_type[x$house_type=="Řadový"] <- "Row house"
  x$house_type[x$house_type=="Rohový"] <- "Corner house"
  x$house_type[x$house_type=="Samostatný"] <- "Self-contained house"
  x$house_type[x$house_type=="V bloku"] <- "In block"
  x$house_type <- as.factor(x$house_type)
}