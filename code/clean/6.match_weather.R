# Filename: match_weather.R
# Author: Xu Han
# Last Modified: 2018-11-01

# This file mathces hourly weather data with an observation in main_df.

rm(list = ls())

working_directory <- "~/Documents/researches/air_pollution_meal_delivery/projectfiles/"
setwd(working_directory)
library(tidyr)
library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)
library(stargazer)
library(xtable)
library(lfe)
library(geosphere)
library(naniar)

load(file = "./data/intdata/main_df.Rdata")
df <- df %>% filter(sup_id > 0)
df$station_time <- as_datetime(paste0(year(df$read_tm),"-",month(df$read_tm), "-", day(df$read_tm), 
                               " ",hour(df$read_tm),":00",":00"))

load(file = "./data/intdata/weather_hl.Rdata")
weather <- weather_hl3

# steps

# step 0: initialize the station location data frame for later reference
station_loc <- weather %>% group_by(站号) %>% summarise(经度 = first(经度), 纬度 = first(纬度))
n_station = nrow(station_loc)

# step 1: define the matching function : match observation to nearest station
nearest_station <- function(cur_loc) {
  lon <- cur_loc[1]; lat <- cur_loc[2]
  dist <- numeric(n_station)
  for (i in 1:n_station) {
    dist[i] <- distm(unlist(station_loc[1,c("经度","纬度")]), cur_loc, fun = distHaversine)
    # dist_sq[i] <- (station_add[i, "lat"] - lat)^2 + (station_add[i, "lng"] - lng)^2
  }
  #print(which.min(dist_sq))
  station_loc[which.min(dist),c("站号")]$站号
}


cur_lon <- df[1,c("from_addr_lon", "from_addr_lat")]$from_addr_lon
cur_lat <- df[1,c("from_addr_lon", "from_addr_lat")]$from_addr_lat
cur_loc <- c(cur_lon, cur_lat)
nearest_station(cur_loc)
distm(unlist(station_loc[1,c("经度","纬度")]), cur_loc, fun = distHaversine)



df$station_num <- NA
df[, c("precipiation", "temp")] <- NA
# step 1: for each observation in main_df, choose the nearest station (identified 
#         by station number)
for (i in 1:nrow(df)) {
  cur_lon <- df[i,c("from_addr_lon", "from_addr_lat")]$from_addr_lon
  cur_lat <- df[i,c("from_addr_lon", "from_addr_lat")]$from_addr_lat
  cur_loc <- c(cur_lon, cur_lat)
  try(cur_station <- nearest_station(cur_loc))
  try(df[i, c("station_num")] <- cur_station)
  
  # step 2: match corresponding weather information
  try(row <- weather %>% 
    filter(站号 == cur_station, 日期时间 == df[i,]$station_time) %>% 
    dplyr::select(一小时累计雨量, 气温))
  try(df[i, c("precipiation", "temp")] <- row[1,])
  
  if ((i %% 1000) == 0) {
    cat(paste0(i, " observations done!\n"))
  }
}

df_matched = df
df_matched$precipiation = as.numeric(df_matched$precipiation)
df_matched$temp = as.numeric(df_matched$temp)
save(df_matched, file="./data/finaldata/df_matched.Rdata")
summary(df_matched)




  