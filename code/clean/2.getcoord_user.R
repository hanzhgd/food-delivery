load(file = "df.Rdata")
original_df <- df

df <- df %>% filter(sup_id > 0) 

df_user <- df %>% group_by(address) %>% summarise(addr = first(address))
df_user

library(baidumap)
options(baidumap.key = "GfxCrKVreslu8XnHlDK2bLhNm5uBMOuC")

df_user$addr_lon <- NA
df_user$addr_lat <- NA


for (i in 1400:(nrow(df_user))) {
  try(df_user[i, c("addr_lon", "addr_lat")] <- getCoordinate(df_user$addr[i], city = "上海", formatted = T))
  if ((i %% 100) == 0) {
    cat(paste0(i, " addresses done!\n"))
  }
}

save(df_user, file = "user_coords.Rdata")

