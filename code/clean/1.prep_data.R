# Filename: prep_data.R
# Author: Xu Han
# Last Modified: 2018-08-18

rm(list = ls())

if (!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, readxl, lubridate)

# load julaug data
jul1 <- read_xlsx(here("data/rawdata/Jul_C3_P1.xlsx")) %>% as_tibble() %>%
  select(-mobile)
jul2 <- read_xlsx(here("data/rawdata/Jul_C3_P2.xlsx")) %>% as_tibble() %>%
  select(-mobile)
aug1 <- read_xlsx(here("data/rawdata/Aug_C3_P1.xlsx")) %>% as_tibble() %>%
  select(-mobile)
aug2 <- read_xlsx(here("data/rawdata/Aug_C3_P2.xlsx")) %>% as_tibble() %>%
  select(-mobile)
julaug <- bind_rows(jul1, jul2, aug1, aug2)

# Basic Manipulation -----------
julaug

# pattern: 762 rider serves for the delivery from 3637 suppliers to 92582 users
nrow(julaug)
# > 411404
julaug %>% summarise(n_distinct(user_id), 
                     n_distinct(sup_id), 
                     n_distinct(from_addr),
                     n_distinct(rider_id))

# generate new var: datetime information, and breakdown of delivery time
julaug <- julaug %>% 
  filter(!is.na(read_tm)) %>%
  mutate(date = as.Date(read_tm),
         weekday = weekdays(read_tm),
         hour = hour(read_tm),
         day = day(read_tm),
         read_to_finish_secs = as.numeric(finish_tm - read_tm), 
         read_to_finish_min = read_to_finish_secs / 60,
         read_to_arr = as.numeric(arrive_tm - read_tm) / 60,
         arr_to_leave =  as.numeric(leave_tm - arrive_tm) / 60,
         leave_to_finish =  as.numeric(finish_tm - leave_tm) / 60)

# a premium order: income > 500
julaug$premium_ord <- julaug$rider_income > 500

# a surge order: delivered during 10:00 to 14:00 or 17:00 to 20:00
julaug$surge_ord <- (julaug$hour < 20 & julaug$hour > 17) | (julaug$hour < 14 & julaug$hour > 10)
summary(julaug$surge_ord)

# late_order
julaug$late <- julaug$receive_tm > julaug$require_tm # NOTICE: many NA's

# save data
save(julaug, file=here("data/intdata/julaug.Rdata"))
summary(julaug)
