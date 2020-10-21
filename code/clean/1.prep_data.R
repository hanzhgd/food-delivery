# Filename: prep_data.R
# Author: Xu Han
# Last Modified: 2018-08-18

rm(list = ls())

working_directory <- "~/Documents/researches/air_pollution_meal_delivery/projectfiles/"
setwd(working_directory)
library(tidyr)
library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)

# load df data
jul1 <- read_xlsx(paste0(working_directory, "./data/rawdata/Jul_C3_P1.xlsx"))
jul2 <- read_xlsx(paste0(working_directory, "./data/rawdata/Jul_C3_P2.xlsx"))
aug1 <- read_xlsx(paste0(working_directory, "/data/rawdata/Aug_C3_P1.xlsx"))
aug2 <- read_xlsx(paste0(working_directory, "/data/rawdata/Aug_C3_P2.xlsx"))
df <- rbind(jul1, jul2, aug1, aug2)

# Basic Manipulation -----------
str(df)

# pattern: 776 rider serves for the delivery from 3637 suppliers to 92582 users
nrow(df)
# > 411404
n_distinct(df$user_id)
# > 92852
n_distinct(df$sup_id)
# > 2830
n_distinct(df$from_addr)
# > 3637
n_distinct(df$rider_id)
# > 762

# generate new var
df %<>% 
  filter(!is.na(read_tm)) %>%
  mutate(date = as.Date(read_tm), 
         read_to_finish_secs = as.numeric(finish_tm - read_tm), 
         read_to_finish_min = read_to_finish_secs / 60,
         readtoarr = as.numeric(arrive_tm - read_tm) / 60,
         arrtoleave =  as.numeric(leave_tm - arrive_tm) / 60,
         leavetofinish =  as.numeric(finish_tm - leave_tm) / 60)
# generate some datetime information
df$weekday <- weekdays(df$read_tm)
df$hour <- hour(df$dipatch_tm)
df$day <- day(df$read_tm)
df$date <- date(df$read_tm)

# a premium order: income > 500
df$premium_ord <- df$rider_income > 500

# a surge order: delivered during 10:00 to 14:00 or 17:00 to 20:00
df$surge_ord <- (df$hour < 20 & df$hour > 17) | (df$hour < 14 & df$hour > 10)
summary(df$surge_ord)

# late_order
df$late <- df$receive_tm > df$require_tm # NOTICE: many NA's

# save data
save(df, file="./data/intdata/df.Rdata")
summary(df)
