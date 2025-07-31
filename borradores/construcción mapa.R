#Librerías-------------------
pacman::p_load(tidyverse, sf, leaflet)

#Descargo las fuentes de datos--------------------
download.file("https://www.indec.gob.ar/ftp/cuadros/territorio/codgeo/Codgeo_Tucuman_con_datos.zip",
              "bases/Codgeo_Tucuman_con_datos.zip", mode = "wb")

unzip("bases/Codgeo_Tucuman_con_datos.zip", exdir = "bases")


#Leo los datos georreferenciados-------------
radios <- st_read("bases/Tucuman_con_datos.shp") 

radios <- st_transform(radios, crs = 4326) #Transformo a WGS84 (EPSG:4326)

#Preparo la información--------------------
#observo rápidamente los radios censales
radios %>% 
  ggplot() +
  geom_sf() +
  theme_minimal()

#calculo la proporción de hogares por radio que tiene algún indicador de NBI
nbi <- censo_hogares %>% 
  select(redcode, ALGUNBI) %>% 
  group_by(redcode) %>%
  summarise(nbi = sum(ALGUNBI) / n())

#calculo la cantidad promedio de personas en el hogar por radio
totpers <- censo_hogares %>% 
  select(redcode, TOTPERS) %>% 
  group_by(redcode) %>%
  summarise(totpers = mean(TOTPERS, na.rm = TRUE))

#calculo el promedio de nivel de hacinamiento que tienen los hogares por radio
hacinamiento <- censo_hogares %>% 
  select(redcode, INDHAC) %>% 
  group_by(redcode) %>%
  summarise(hacinamiento = mean(INDHAC, na.rm = TRUE))

#Unir la información al shapefile de radios
radios <- radios %>% 
  left_join(nbi, by = c("link" = "redcode")) %>% 
  left_join(totpers, by = c("link" = "redcode")) %>% 
  left_join(hacinamiento, by = c("link" = "redcode"))


#Construyo un mapa temático--------------
radios %>% 
  ggplot() +
  geom_sf(aes(fill=hacinamiento), color = NA) +
  theme_void() +
  scale_fill_viridis_c()
  



#Construyo un mapa interactivo con leaflet------------------------------------

#Colorear los poligonos en el mapa según la variable nbi

palnumeric <- colorNumeric("magma", domain = radios$hacinamiento)

leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = radios, 
              fillColor = ~palnumeric(hacinamiento),
              fillOpacity = 0.8,
              color = "white",
              weight = 1,
              popup = ~as.character(hacinamiento)) %>% 
  addLegend(pal = palnumeric, values = ~hacinamiento, title = "NBI",
            data = radios, position = "bottomright")
