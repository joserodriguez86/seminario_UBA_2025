library(tidyverse)

apellidos <- read.csv("https://datosabiertos.renaper.gob.ar/apellidos_mas_frecuentes_provincia.csv")

nombres <- read.csv("https://datosabiertos.renaper.gob.ar/nombres_propios_frecuentes_anio_sexo_provincia_2012_2023.csv")

condenados <- read.csv("https://datos.jus.gob.ar/dataset/6d0e08b3-041c-40c1-9ea6-962db3747677/resource/9b2885f2-d876-4769-91ad-6723dc74e359/download/internos-spf-condenados-202403.csv")

ciencia <- read.csv("https://datasets.datos.mincyt.gob.ar/dataset/06ae9728-c376-47bd-9c41-fbdca68707c6/resource/5d49a616-2fc1-4270-8b09-73f1f5cdd335/download/personas_2012.csv", sep = ";")

starwars <- starwars

aprender2024 <- read.csv("nombre_local.csv")

download.file(url = "https://ministeriodeeducaciondelanacion-my.sharepoint.com/:x:/g/personal/santiago_pomeranz_educacion_gob_ar/Ed5eqI7DVfJBoV4Dj6qfHfcB_gIIlzA5lYEnmoeo_Jj3Ew?e=hxPyK4", destfile = "nombre_local.csv")
