library(ipumsr)
library(tidyverse)

ipums_data_collections() #Les permite observar las colecciones que tiene IPUMS

##################### ACA VA UN TOKEN PERSONAL PARA QUE FUNCIONE LA API #######

# Save key in .Renviron for use across sessions
# set_ipums_api_key("59cba10d8a5da536fc06b59d077f16ab8c694a48af40579e2f934f33", save = TRUE)


################################################################################

ipumsi_samps <- get_sample_info("ipumsi") #Ver nombres de las bases censales

# Cargo la data
ipumsi_extract <- define_extract_ipumsi(
  description = "Extract definition with predefined variables",
  samples = "co1973a",
  variables = c("SEX", "RELATE", "AGE2")
)

ipumsi_extract #Nos describe lo que vamos a pedirle a IPUMS

col_ext_submitted <- submit_extract(ipumsi_extract) #pido el extracto via API
col_ext_submitted$number #cantidad de extractos que pedí
wait_for_extract(col_ext_submitted) #chequea si está listo para descargarlo

col_ipums <- download_extract(col_ext_submitted, overwrite = TRUE) #descarga la base

ddi <- read_ipums_ddi(col_ipums) #lee la metadata
micro_data <- read_ipums_micro(ddi) #Nos crea la base de microdatos

micro_data #veo la base

ipums_val_labels(micro_data$RELATE) #veo las etiquetas de las variables
