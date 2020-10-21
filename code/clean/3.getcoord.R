rm(list = ls())

working_directory <- "~/2018Fall/air_pollution_meal_delivery/"
setwd(working_directory)
library(tidyr)
library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)
library(stargazer)
library(xtable)
library(lfe)

load(file = "df.Rdata")
original_df <- df

df <- df %>% filter(sup_id > 0) 

df_sup <- df %>% group_by(sup_id) %>% summarise(from_addr = first(from_addr))
df_sup

library(baidumap)
options(baidumap.key = "GfxCrKVreslu8XnHlDK2bLhNm5uBMOuC")

df_sup$from_addr_lon <- NA
df_sup$from_addr_lat <- NA

for (i in 1:(nrow(df_sup))) {
  df_sup[i, c("from_addr_lon", "from_addr_lat")] <- getCoordinate(df_sup$from_addr[i], city = "上海", formatted = T)
  if ((i %% 100) == 0) {
    cat(paste0(i, " addresses done!\n"))
  }
  }

save(df_sup, file = "sup_coords.Rdata")

df %>% left_join(df_sup, by = "sup_id")
