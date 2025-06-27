series <- read.csv("https://apis.datos.gob.ar/series/api/dump/series-tiempo-metadatos.csv")


library(httr2)
res <- request("https://apis.datos.gob.ar/series/api/series/") %>%
  req_url_query(ids = "snic_hdv_arg") %>%  # homicidios dolosos
  req_perform() %>%
  resp_body_json()

df <- res$series[[1]]$datos %>% 
  purrr::map_df(~data.frame(fecha=.x$fecha, valor=.x$valor))
