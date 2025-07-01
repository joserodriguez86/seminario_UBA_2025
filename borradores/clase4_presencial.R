#Abro librerias------------------

library(tidyverse)
library(haven)

censo_hogares <- read.csv("bases/censo10_hogares.csv", sep = ";")

censo_hogares <- read_csv2("bases/censo10_hogares.csv", progress = show_progress())

censo_personas <- readRDS("bases/censo10_personas.rds")

censo_viviendas <- read_spss("bases/censo10_viviendas.sav")

nacimientos <- read_csv("https://datosabiertos.renaper.gob.ar/nacimientos_por_departamento_y_anio_2012_2022.csv")

class(censo_hogares)

class(censo_hogares$TOTPERS)




class(censo_hogares$redcode)


censo_hogares$prop_factor <- factor(censo_hogares$PROP, 
                                    labels = c("No aplica",
                                      "Propietario de la vivienda y del terreno",
                                               "Propietario sólo de la vivienda",
                                               "Inquilino",
                                               "Ocupante por préstamo",
                                               "Ocupante por trabajo",
                                               "Otra situación"))

class(censo_hogares$prop_factor)
levels(censo_hogares$prop_factor)

censo_hogares_sel <- select(censo_hogares, provincia, departamento, redcode)
censo_hogares_seleccion <- select(censo_hogares, redcode:hogar_ref_id)

censo_hogares_seleccion <- filter(censo_hogares, provincia == "MENDOZA")
censo_hogares_seleccion <- filter(censo_hogares, TOTPERS > 1)
censo_hogares_seleccion <- filter(censo_hogares, provincia == "MENDOZA" & TOTPERS != 1)


censo_hogares_seleccion <- arrange(censo_hogares_seleccion, TOTPERS) 

censo_hogares_seleccion <- arrange(censo_hogares_seleccion, desc(TOTPERS))


censo_hogares %>% 
  select(redcode, provincia, departamento, hogar_ref_id, PROP) %>% 
  filter(provincia == "JUJUY") %>% 
  arrange(departamento)


#Creación de variable de hacinamiento---------------

##primera parte------------
censo_hogares <- censo_hogares %>% 
  mutate(personas_hab = TOTPERS / H16)

censo_hogares <- censo_hogares %>% 
  mutate(hacinamiento = case_when(personas_hab > 3 ~ 1,
                                  personas_hab <= 3 ~ 0))

censo_hogares <- censo_hogares %>% 
  mutate(hacinamiento = case_when(personas_hab > 3 ~ "Con hacinamiento", 
                                  personas_hab <= 3 ~ "Sin hacinamiento"))

censo_hogares <- censo_hogares %>% 
  mutate(hacinamiento = case_when(TOTPERS / H16 >= 3 ~ 1,
                                  TOTPERS / H16 < 3 ~ 0))

table(censo_hogares$hacinamiento)


censo_personas <- censo_personas %>% 
  mutate(grupo_etario = case_when(p03 <= 14 ~ "0 a 14 años",
                                  p03 >= 15 & p03 <= 64 ~ "15 a 64 años",
                                  p03 >= 65 ~ "65 años y más"))



censo_personas <- censo_personas %>% 
  mutate(grupo_etario = case_when(p03 <= 14 ~ "0 a 14 años",
                                  p03 >= 15 & p03 <= 64 ~ "15 a 64 años",
                                  p03 >= 65 ~ "65 años y más"))


censo_personas <- censo_personas %>% 
  mutate(grupo_etario = case_when(p03 %in% 0:14 ~ "0 a 14 años",
                                  p03 %in% 15:64 ~ "15 a 64 años",
                                  p03 >= 65 ~ "65 años y más"))


