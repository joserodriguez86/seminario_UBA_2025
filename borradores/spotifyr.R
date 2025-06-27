library(spotifyr)
library(tidyverse)
library(knitr)
library(ggrepel)
library(Cairo)
library(factoextra)
library(ggsci)
library(gridExtra)
library(cluster)

myclientid <- 'b9950d5a5e92463dbcd6f8107f5475cd'
myclientsecret <- 'b8ef70389c244fce9dddba08c0041131'
Sys.setenv(SPOTIFY_CLIENT_ID=myclientid)
Sys.setenv(SPOTIFY_CLIENT_SECRET=myclientsecret)
access_token<-get_spotify_access_token()


beatles <- get_artist_audio_features("the beatles")

beatles_resumen <- beatles %>% 
  filter(album_release_year <= 1970) %>%
  filter(!str_detect(album_name, regex("deluxe", ignore_case = TRUE)))

graf_beatles <- beatles_resumen %>% 
  group_by(album_release_date, album_name) %>% 
  summarise(tiempo_prom = mean(duration_ms)) %>% 
  ggplot(aes(x=as.Date(album_release_date), y=tiempo_prom)) +
  geom_line() +
  geom_point() +
  scale_x_date(breaks = seq(as.Date("1963-01-01"), as.Date("1971-01-01"), by = "year"),
               date_labels = "%Y",
               limits = as.Date(c("1963-01-01", "1971-01-01")))

interactivo <- plotly::ggplotly(graf_beatles)  
interactivo
