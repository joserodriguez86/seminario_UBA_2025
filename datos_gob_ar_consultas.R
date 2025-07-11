

          #######################################################################
          # 1. CONFORMA DATRAFRAME “datos_gob_datasets”
          
          library(httr)
          library(jsonlite)
          library(dplyr)
          library(purrr)
          library(writexl)
          library(dplyr)
          library(purrr)
          library(tidyr)
          library(furrr)  
          library(future) 
          library(progressr) 
          library(stringr)
          
              ##################################################################
              ## 1.1 CONSULTA API. DESCARGA DATAFRAME GENERAL
              
              base_url <- "https://datos.gob.ar/api/3/action/package_search"
              
                  ##################################################################
                  ### 1.1.1 DEVUELVE POR BLOQUES DATASET API
                  
                  traer_bloque <- function(start) {
                    url <- paste0(base_url, "?rows=1000&start=", start)
                    resp <- GET(url)
                    parsed <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
                    parsed$result$results
                  }
                  bloque_1 <- traer_bloque(0)
                  bloque_2 <- traer_bloque(1000)
                  datasets <- bind_rows(bloque_1, bloque_2)

                  ##################################################################                  
                  ### 1.1.2 SELECCIONA COLUMNAS PLANAS 
                  
                  columnas_planas <- c("id", "title", "notes", "num_resources")
                  
                  datasets_w <- datasets %>%
                    select(all_of(columnas_planas))            

                  
              ##################################################################
              ## 1.2 EXTRACCIÓN INFO VECTORES JSON

                  
                  ##################################################################                   
                  ### 1.2.1 “GROUPS”: Área Temática/Gobierno
                  

                  groups_df <- datasets %>%
                    transmute(
                      groups_description = map_chr(groups, ~ {
                        if (is.null(.x) || nrow(.x) == 0) return(NA_character_)
                        descs <- .x$description
                        descs <- descs[!is.na(descs)]
                        if (length(descs) == 0) NA_character_ else paste(descs, collapse = "; ")
                      })
                    )

                  groups_df <- groups_df %>%
                    separate(groups_description,
                             into = c("area_gobierno_1", "area_gobierno_2"),
                             sep = "; ",
                             fill = "right",
                             extra = "merge") 
                  
                  #str(datasets$groups[[1]])
                  
                  
                  ##################################################################     
                  ### 1.2.2 “TAGS”: Etiquetas Descriptivas 
                  

                  tags_df <- datasets %>%
                    transmute(
                      tags_display_name = map_chr(tags, ~ {
                        if (is.null(.x) || nrow(.x) == 0) return(NA_character_)
                        names <- .x$display_name
                        names <- names[!is.na(names)]
                        if (length(names) == 0) NA_character_ else paste(names, collapse = "; ")
                      })
                    )
                  
                  tags_df <- tags_df %>%
                    separate(tags_display_name,
                             into = c("tag_1", "tag_2", "tag_3"),
                             sep = "; ",
                             fill = "right",
                             extra = "merge")
                  
                  
                  ##################################################################
                  ### 1.2.3 “ORGANIZATION”: Niveles/Áreas de Gobierno 
                  
                  #datasets$organization[[3]] 
                  #str(datasets$organization[[1]])
                  
                  organization_df <- data.frame(organization_title = datasets$organization[[3]])
              
              ##################################################################              
              ## 1.3 UNIFICA DATAFRAMES EXTRAÍDOS
              

              datos_gob_datasets <- bind_cols(groups_df, tags_df, organization_df, datasets_w)

          
          #######################################################################
          # 2. EXTRAE RECURSOS-ARCHIVOS (datos_gob_resources)
          
          plan(multisession, workers = availableCores() - 1)  # deja 1 core libre para el SO
              
              
                ##################################################################              
                ## 2.1 ARMADO DE EXTRACCIÓN RECURSOS-ARCHIVOS (función con retry & timeout)
                
                get_resources_df <- function(dataset_id) {
                  tryCatch({
                    if (is.na(dataset_id) || dataset_id == "") {
                      warning("ID inválido: ", dataset_id)
                      return(tibble(
                        dataset_id = dataset_id,
                        name = NA_character_,
                        description = NA_character_,
                        format = NA_character_,
                        url = NA_character_,
                        download_url = NA_character_,
                        accessURL = NA_character_,
                        cache_url = NA_character_,
                        fileName = NA_character_,
                        resource_type = NA_character_
                      ))
                    }
                    
                    # Intentar hasta 3 veces con pausa entre intentos
                    retry_count <- 0
                    success <- FALSE
                    while (!success && retry_count < 3) {
                      retry_count <- retry_count + 1
                      Sys.sleep(runif(1, 0.5, 1.5)) # Pausa pequeña y aleatoria
                      
                      url <- paste0(
                        "https://datos.gob.ar/api/3/action/package_show?id=",
                        URLencode(dataset_id, reserved = TRUE)
                      )
                      
                      response <- try(GET(url, timeout(20)), silent = TRUE) # Timeout 20s
                      if (inherits(response, "try-error") || response$status_code != 200) {
                        message("Retry ", retry_count, " for dataset_id: ", dataset_id)
                      } else {
                        success <- TRUE
                      }
                    }
                    
                    # Si falla después de 3 intentos
                    if (!success) {
                      warning("No se pudo obtener datos para dataset_id: ", dataset_id)
                      return(tibble(
                        dataset_id = dataset_id,
                        name = NA_character_,
                        description = NA_character_,
                        format = NA_character_,
                        url = NA_character_,
                        download_url = NA_character_,
                        accessURL = NA_character_,
                        cache_url = NA_character_,
                        fileName = NA_character_,
                        resource_type = NA_character_
                      ))
                    }
                    
                    json_text <- content(response, as = "text", encoding = "UTF-8")
                    data <- fromJSON(json_text, flatten = TRUE)
                    resources <- data$result$resources
                    
                    if (length(resources) == 0) {
                      return(tibble(
                        dataset_id = dataset_id,
                        name = NA_character_,
                        description = NA_character_,
                        format = NA_character_,
                        url = NA_character_,
                        download_url = NA_character_,
                        accessURL = NA_character_,
                        cache_url = NA_character_,
                        fileName = NA_character_,
                        resource_type = NA_character_
                      ))
                    }
                    
                    tibble(
                      dataset_id = dataset_id,
                      name = resources$name,
                      description = resources$description,
                      format = resources$format,
                      url = ifelse(!is.na(resources$accessURL), resources$accessURL, resources$url),
                      download_url = paste0(resources$url, "/download/", resources$name),
                      accessURL = resources$accessURL,
                      cache_url = resources$cache_url,
                      fileName = resources$fileName,
                      resource_type = resources$resource_type
                    )
                  }, error = function(e) {
                    warning("Error procesando dataset_id: ", dataset_id, " (", conditionMessage(e), ")")
                    tibble(
                      dataset_id = dataset_id,
                      name = NA_character_,
                      description = NA_character_,
                      format = NA_character_,
                      url = NA_character_,
                      download_url = NA_character_,
                      accessURL = NA_character_,
                      cache_url = NA_character_,
                      fileName = NA_character_,
                      resource_type = NA_character_
                    )
                  })
                }
                
                  
                ##################################################################              
                ## 2.2 EXTRACCIÓN RECURSOS MEDIANTE ID_DATASETS
                
                  ##################################################################              
                  ## 2.2.1 ARMADO DE EXTRACCIÓN RECURSOS-ARCHIVOS (función con retry & timeout)
                  
                  
                      all_ids <- datasets$id
                      all_ids <- all_ids[!is.na(all_ids) & all_ids != ""]
                
                
                  ##################################################################              
                  ## 2.2.2 ARMADO DE EXTRACCIÓN RECURSOS-ARCHIVOS (función con retry & timeout)
                
                      datos_gob_resources <- future_map_dfr(
                        all_ids,
                        function(id) {
                          res <- get_resources_df(id)
                          Sys.sleep(runif(1, 0.2, 0.5))  # Evita sobrecargar la API
                          res
                        },
                        .progress = TRUE  # Barra de progreso integrada
                      )
                
                  ##################################################################              
                  ## 2.2.3 ARMADO DE EXTRACCIÓN RECURSOS-ARCHIVOS (función con retry & timeout)
                  
                      datos_gob_resources <- datos_gob_resources %>%
                        filter(!str_starts(url, "https://www.argentina.gob"))
                      
                      extensiones <- c("csv", "xlsx", "dta", "pdf", "sav", "txt", "xls")
                      
                      patron <- paste0("(\\.)?", extensiones, collapse = "|")
                      
                      datos_gob_resources <- datos_gob_resources %>%
                        filter(str_to_lower(format) %>% str_detect(patron))
                

          #######################################################################          
          # 3. CONFORMA ARCHIVO FINAL (datos_gob_consultas)
          
                
          datos_gob_consultas <- datos_gob_datasets %>%
            inner_join(datos_gob_resources, by = c("id" = "dataset_id"))
          
          
          datos_gob_consultas <- datos_gob_consultas %>%
            select(
                    id,
                    num_resources,
                    area_gobierno_1,
                    area_gobierno_2,
                    organization_title,
                    tag_1,
                    tag_2,
                    title,
                    notes,
                    name,
                    description,
                    url,
                    fileName,
                    format,
                    resource_type
                        )
          
                      
          datos_gob_consultas <- datos_gob_consultas %>%
            mutate(descarga = if_else(
              !is.na(fileName),                  # Si fileName NO es NA
              paste0(url, "/download/", fileName), # Concatenar url + "/download/" + fileName
              NA_character_                       # Sino dejar NA
            ))
          
          rm(bloque_1, bloque_2, datasets_w, groups_df, organization_df, tags_df, datos_gob_datasets, 
             datos_gob_resources)
          
          rm(all_ids, base_url, columnas_planas, extensiones, patron, 
             get_resources_df, traer_bloque)
          
          
          write_xlsx(datos_gob_consults, "D:/datos_gob_consults_1.xlsx")

          
          
          
          
          
          