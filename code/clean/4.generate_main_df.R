# generate_main_df.R
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

load(file = "./data/intdata/sup_coords.Rdata")
load(file = "./data/intdata/user_coords.Rdata")
load(file = "./data/intdata/df.Rdata")
df <- df %>% filter(sup_id > 0)
df <- df %>% left_join(df_sup, by = "sup_id")
df <- df %>% left_join(df_user, by = c("address" = "addr"))
df$from_addr_lat <- as.numeric(df$from_addr_lat)
df$from_addr_lon <- as.numeric(df$from_addr_lon)

df[df$from_addr_lat < 30, ]$from_addr_lat <- NA
df[!is.na(df$from_addr_lat) & df$from_addr_lat > 32, ]$from_addr_lat <- NA
df[!is.na(df$from_addr_lon) & df$from_addr_lon < 120, ]$from_addr_lon <- NA
# df[!is.na(df$from_addr_lon) & df$from_addr_lon > 122, ]$from_addr_lon <- NA
df[!is.na(df$addr_lat) & df$addr_lat < 30, ]$addr_lat <- NA
df[!is.na(df$addr_lat) & df$addr_lat > 32, ]$addr_lat <- NA
df[!is.na(df$addr_lon) & df$addr_lon < 120, ]$addr_lon <- NA
df[!is.na(df$addr_lon) & df$addr_lon > 122, ]$addr_lon <- NA

df$distance <- distHaversine(df[,c("from_addr_lon","from_addr_lat")], df[,c("addr_lon","addr_lat")])

df$weekend <- weekdays(df$date) %in% c("星期六", "星期日")

df$require_hour <- hour(df$require_tm)
df$late <- df$finish_tm > df$require_tm
df$late_min <- as.numeric(df$finish_tm - df$require_tm) / 60

df$lunchorder <- df$require_hour <= 13 & df$require_hour >= 11
df$dinnerorder <- df$require_hour <= 19 & df$require_hour >= 16
df$peak_order <- df$lunchorder | df$dinnerorder
df$order_time <- as.numeric(df$finish_tm - df$dipatch_tm) / 60 # 从派到送达的时间(minutes)
df$nonpeak_order <- df$hour <= 15 & df$hour >= 14

head(df)

save(df, file = "./data/intdata/main_df.Rdata")

