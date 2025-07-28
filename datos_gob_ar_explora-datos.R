






  ####################################################################################################################

    #Economía y finanzas		
      #Secretaría de Planeamiento  
          #Tags #Empleo	Empresas
    
              #ARCHIVO DATOS >> Distribución geográfica de los establecimientos productivos	


      url_1 <- "https://cdn.produccion.gob.ar/cdn-cep/establecimientos-productivos/distribucion_establecimientos_productivos_sexo.csv"
      
      
      geo_estab_produc <- read_delim(url_1, delim = ",")    # corroborar separador (coma or punto y coma) #
      
      glimpse(geo_estab_produc)  # ver estructura del dataset #
      #colnames(geo_estab_produc)
      
      
      
      
      unique(geo_estab_produc$provincia_id)
      
      
  ####################################################################################################################
      
      #Gobierno y sector público	/ Población y sociedad	
        #Subsecretaría de Turismo	
            #Tags	turismo internacional
      
              #ARCHIVO DATOS >> Turismo receptivo       
            
      
      url_21 <-"https://datos.yvera.gob.ar/dataset/4cbf7d4a-702a-4911-8c1e-717a45214902/resource/fdfe0ae4-4acc-4421-aa48-6149a02bc615/download/turistas-no-residentes-serie.csv"
      
      
      turismo_receptivo <- read_delim(url_2, delim = ",")    # corroborar separador (coma or punto y coma) #
      
      glimpse(turismo_receptivo)  # ver estructura del dataset #
      #colnames(geo_estab_produc)
      
      
      unique(turismo_recep$indice_tiempo)
      unique(turismo_recep$pais_origen)
      
      
              #ARCHIVO DATOS >> Turismo emisivo       
      
      
      url_3 <-"https://datos.yvera.gob.ar/dataset/4cbf7d4a-702a-4911-8c1e-717a45214902/resource/fd710cb7-1981-43ea-aba3-7a14c356446b/download/turistas-residentes-serie.csv"
      
      
      turismo_emisivo <- read_delim(url_3, delim = ",")    # corroborar separador (coma or punto y coma) #
      
      
      
      rm(turismo_emisivo)
      

      ####################################################################################################################
      
      #Economía y finanzas	 	
        #Secretaría de Planeamiento y Gestión para el Desarrollo Productivo y de la Bioeconomía	
              #Tags= Brechas salariales	Educación
      
              
                  #ARCHIVO DATOS >> Educacion	Graduados universitarios del sistema Araucano (2016-2018)    
      
      
      
            
      url_4 <-"https://datos.produccion.gob.ar/dataset/46df1ebe-d0bb-49a1-96dd-fe9751930682/resource/afbfc04e-6130-448c-953f-ef601f3e8bda/download/base_araucano.csv"
      
      
      graduadxs_universit <- read_delim(url_4, delim = ",")    # corroborar separador (coma or punto y coma) #
      
      
      
      url_5 <-"https://www.economia.gob.ar/datos/ipc-categorias-tasas-variacionmensual-basedic-2016.csv"
      
      
      ipc_var_mensual <- read_delim(url_5, delim = ",")    # corroborar separador (coma or punto y coma) #
      
      
      