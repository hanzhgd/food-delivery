# Filename: read_weather.R
# Author: Xu Han
# Last Modified: 2018-11-01

# This file reads hourly weather data.
# The data will then be matched with observations in main data in match_station.R

rm(list = ls())

working_directory <- "~/Documents/researches/air_pollution_meal_delivery/projectfiles/"
setwd(working_directory)
library(tidyr)
library(readr)
library(tibble)
library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)
library(stargazer)
library(xtable)
library(lfe)
library(geosphere)
library(naniar)
library(readtext)

data_dir <- paste0(working_directory, "./data/rawdata/SHANGHAI-zdz-data201506-08/")
list.files(data_dir)
data_files <- list.files(data_dir, pattern = ".txt")
print(data_files)
## [1] "data_1.csv" "data_2.csv" "data_3.csv"

colname_weather <- c("日期时间","站名","站号","经度","纬度","海拔高度",
                     "2分钟平均风向","2分钟平均风速","10分钟平均风向",
                     "10分钟平均风速","小时内10分钟最大风向","小时内10分钟最大风速",
                     "小时内10分钟最大风速出现时间","瞬时风向","瞬时风速","小时内最大阵风风向",
                     "小时内最大阵风风速","小时内最大阵风出现时间","一小时累计雨量","气温",
                     "小时内最高气温","小时内最高气温出现时间","小时内最低气温",
                     "小时内最低气温出现时间","相对湿度","小时内最小相对湿度",
                     "小时内最小相对湿度出现时间","水汽压","露点","本站气压",
                     "小时内最高气压","小时内最高气压出现时间","小时内最低气压",
                     "小时内最低气压出现时间","地表温度","小时内地表最高","小时内地表最高出现时间",
                     "小时内地表最低","小时内地表最低出现时间","5CM地温","10CM地温",
                     "15CM地温","20CM地温","40CM地温","瞬时能见度", "小时内最小能见度")

weather_hl <- read_csv(paste0(data_dir, data_files[1]),
                       col_names = colname_weather)

for (i in 2:length(data_files)) {
  append_data_set <- read_csv(paste0(data_dir, data_files[i]),
                              col_names = colname_weather)
  weather_hl <- rbind(weather_hl, append_data_set)
}

weather_hl2 <- weather_hl[,c("日期时间", "站号","经度","纬度", "一小时累计雨量","气温")] #"地表温度","瞬时能见度")]
weather_hl3 <- weather_hl2 %>% filter(日期时间 >= as_datetime(ymd("2015-07-01")),
                                      日期时间 <= as_datetime(ymd("2015-09-01")))
head(weather_hl3)
save(weather_hl3, file = "./data/intdata/weather_hl.Rdata")
