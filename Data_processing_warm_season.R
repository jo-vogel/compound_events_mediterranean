# Compound heatwaves and droughts in the Mediterranean (based on Mazdiyasni & AghaKouchak 2015)
# This file calculates SPI, SPEI and daily temperature maxima

rm(list=ls())
library(tictoc)
start <- Sys.time()
tic("total")
tic("Data preparation")
if(!require(ncdf4)) install.packages("ncdf4") # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(berryFunctions)
library(zoo)
library(abind)
library(rasterVis)
library(SPEI) # usable for processing large datasets
library(Kendall)  
library(foreach) # parallelisation example
library(doParallel)

# path_clim <- "D:/user/vogelj/Data/ERA5" # NRC-Server
path_clim <- "D:/Local/Data/ERA5"


# Data loading and processing ####
##################################


# prec <- list.files(path=paste0(path_clim,"/Precipitation/1979-2018_warm_season"), pattern = "monthly.*nc$",recursive = T) # for 1979-2018
temp <- list.files(path=paste0(path_clim,'/Temperature'), pattern = "Temperature.*nc$")																														   
# pev <- list.files(path=paste0(path_clim,"/Potential evaporation/1979-2018_warm_season"), pattern = "monthly.*nc$",recursive = T) # for 1979-2018

prec <- list.files(path=paste0(path_clim,"/Precipitation/1979-2018_warm_season_8mon"), pattern = "monthly.*nc$",recursive = T) # for 1979-2018
pev <- list.files(path=paste0(path_clim,"/Potential evaporation/1979-2018_warm_season_8mon"), pattern = "monthly.*nc$",recursive = T) # for 1979-2018

# Open precipitation data
prcp_vec <- list()
prcp_array <- list()
for (i in 1: length(prec)){
  # prcp_vec[[i]] <- nc_open(paste0(path_clim,"/Precipitation/1979-2018_warm_season/",prec[i])) # i could create prcp_vec without index 
  prcp_vec[[i]] <- nc_open(paste0(path_clim,"/Precipitation/1979-2018_warm_season_8mon/",prec[i])) # i could create prcp_vec without index 
  prcp_array[[i]] <- ncvar_get(prcp_vec[[i]],"tp") # store the data in a 3-dimensional array
  names(prcp_array)[[i]] <- paste0(strsplit(prec,"[.]")[[i]][4],strsplit(prec,"[.]")[[i]][5])
  nc_close(prcp_vec[[i]])
}
rm(prcp_vec) # save RAM space (if not deleted, you alternatively have to close the nc files)
vec_prcp <- 1:length(prec) # I only loaded warm season, so everything is to be used
prcp_all <- sapply(vec_prcp, function(x) {prcp_array[[x]]}) # only warm season data
rm(prcp_array)

# Open potential evaporation data
pev_vec <- list()
pev_array <- list()
for (i in 1: length(pev)){
  # pev_vec[[i]] <- nc_open(paste0(path_clim,"/Potential evaporation/1979-2018_warm_season/",pev[i])) # i could create pev_vec without index
  pev_vec[[i]] <- nc_open(paste0(path_clim,"/Potential evaporation/1979-2018_warm_season_8mon/",pev[i])) # i could create pev_vec without index 
  pev_array[[i]] <- ncvar_get(pev_vec[[i]],"pev") # store the data in a 3-dimensional array
  names(pev_array)[[i]] <- paste0(strsplit(pev,"[.]")[[i]][4],strsplit(pev,"[.]")[[i]][5])
  nc_close(pev_vec[[i]])
}
rm(pev_vec) # save RAM space (if not deleted, you alternatively have to close the nc files)
pev_all <- sapply(vec_prcp, function(x) {pev_array[[x]]}) # only warm season data
rm(pev_array)


# Find daily temperature maxima
tic('Daily maxima calculation') 
temp_array <- NULL
for (t in 1:length(temp)){
  tempnetcdf <- nc_open(paste0(path_clim,'/Temperature/',temp[t]))
  temp_alled     <- tempnetcdf$var[[1]] # temperature variable
  varsize <- temp_alled$varsize # dimension size
  # Get the exact time span (decade):
  if (t==1) {varsize[3] <- 87672 # (24*365*10+3*24)-7 # 11 Jahre 1979-1989: es fehlen die ersten 7 Stunden
  pixelNA <- ncvar_get( tempnetcdf, "t2m", start=c(1,1,1), count=c(1,1,7) ) # complicated way to add 7 NA values
  pixelNA[1:7] <- NA
  }
  if (t==2) varsize[3] <- 87648 # 24*365*10+2*24
  if (t==3) varsize[3] <- 87672 # 24*365*10+3*24
  if (t==4) varsize[3] <- 87648 # 24*365*10+2*24
  count <- varsize	# begin w/count=(nx,ny,nz,...,nt), reads entire var
  count[1] <- 1; count[2] <- 1 # read 1 pixel
  ndims   <- temp_alled$ndims
  lon <- ncvar_get(tempnetcdf,'longitude')
  lat <- ncvar_get(tempnetcdf,'latitude')
  
  max.array <- array(NA,c(varsize[1],varsize[2],varsize[3]/24)) # Array for daily maxima (2 spatial dimensions, time divided by 24 hours)
  intervals <- rep(1:(varsize[3]/24),each=24) # daily intervals
  for( i in 1:length(lon)) {
    for (j in 1:length(lat)){
      # Initialize start and count to read one timestep of the variable.
      start <- rep(1,ndims)	# begin with start=(1,1,1,...,1)
      start[1] <- i; start[2] <- j
      #  calculation see help_file_mediterranean.R
      if (t==1)   {count[3] <- 87672-7} # start 1979 (die ersten 7 Stunden fehlen)
      if (t==2)   {count[3] <- 87649-1} # omit 2000, end 1999
      if (t==3)   {count[3] <- 87673-1} # omit 2010, end 2009
      if (t==4)   {count[3] <- 87649-1} # omit 2019, end 2018
      pixel <- ncvar_get( tempnetcdf, "t2m", start=start, count=count ) # extract single pixel time series from netcdf-file
      if (t==1) {pixel <- c(pixelNA,pixel) } # f?ge 7 NA-Werte hinzu
      zpix <- zoo(pixel) # zoo times series object
      max.array[i,j,] <- aggregate(zpix,by=intervals,FUN=max) # finds daily maxima
    }
  }
  temp_array <- abind(temp_array,max.array,along=3) # verbinde die Jahrzehnte zu einem gro?en Objekt
  nc_close(tempnetcdf)
}
rm(tempnetcdf)

lon2 <- rep(lon,length(lat))
lat2 <- rep(lat,each=length(lon))
coord <- cbind(lon2,lat2) # same format as used for United States
toc() # Daily maxima calculation


# Extraction of warm season (May-Oct)
years <- 40  # 40 Jahre
days <-rep(c(365,366,365,365),10)[1:years] # leap years for 1979 - 2018
days <- cumsum(days)
vec_temp <- as.vector(sapply(1:years, function(x) {c((days[x]-244):(days[x]-61))})) # indices of the days of each warm period of the years 1979-2018
temp_all_3d <- temp_array[,,vec_temp] # warm season: alle Pixel
temp_all <- matrix(temp_all_3d,dim(temp_all_3d)[1]*dim(temp_all_3d)[2],dim(temp_all_3d)[3]) # reshape from lon,lat,temp (3dim) to pixel (lon/lat), temp (2dim)
# geht bei Neuanordnung erst alle Zeilen durch, dann alle Spalten

toc() # Data preparation


# SPI and SPEI calculation for droughts ####
###################################

tic("SPI calculation") # Schneller als for-loop im Cluster im Vergleich zur Matrixoperation
wat_bal <- prcp_all+pev_all  # water balance (difference between precipitation and potential evaporation); pev is already negative (therefore addition not substraction)
tsobj <- ts(t(prcp_all)) # als time series-Objekt deutlich schneller 
tsobj_wb <- ts(t(wat_bal)) 
message("SPI bei Konvertierung zu tsobj nicht identisch. SPI ist dann auch deutlich normalverteilter.")
# Die coefficients des SPI des Zeitreihenobjektes hat L?nge 1 statt 12 in der 3.Dimension
# Die Dimensionen sind nach der Konvertierung invertiert.

no_cores <- detectCores() - 1
cl<-makeCluster(no_cores)
clusterEvalQ(cl, library(raster)) # parallelisation hat eigenes environment, daher m?ssen packages und bestimmte Variablen erneut geladen werden
registerDoParallel(cl)

spi_prec <- matrix(NA,dim(tsobj)[1],dim(tsobj)[2])
spi_prec <- foreach (i=1:dim(tsobj)[2],.combine=cbind) %dopar% { 
  spi_fun <- SPEI::spi(tsobj[,i],3,na.rm=TRUE)
  as.vector(spi_fun$fitted)
}

spei_med <- matrix(NA,dim(tsobj_wb)[1],dim(tsobj_wb)[2])
spei_med <- foreach (i=1:dim(tsobj_wb)[2],.combine=cbind) %dopar% { 
  spei_fun <- SPEI::spei(tsobj_wb[,i],3,na.rm=TRUE)
  as.vector(spei_fun$fitted)
}
stopCluster(cl)
toc() # SPI calculation

# plot(spi_prec$fitted[,2000:2003]) # Mehrfachplots
# spi_prec_single <- SPEI::spi(t(prcp_all)[,7],3,na.rm = TRUE)
# plot(spi_prec_single, 'Prec, SPI-1') # Farbplot geht nur f?r einzelne Zeitreihe
# drought <- which(spi_prec$fitted < -0.8) # identify droughts (SPI below -0.8)
# spi_prec$fitted[drought] # all occurring droughts
# print(spi_prec)
# summary(spi_prec)


# Removal of March and April
seq_mar_apr <- sort(c(seq(1,313,8),seq(2,314,8)))
spi_prec_red <- spi_prec[-seq_mar_apr,]
spei_med_red <- spei_med[-seq_mar_apr,]
spi_prec <- spi_prec_red
spei_med <- spei_med_red


curr_date <- paste0("Processedinput_",timestamp(prefix='',suffix=''),".RData")
curr_date <- gsub(" ", "_", curr_date, fixed = TRUE)
save.image(file=paste0("./Workspaces/",gsub(":", "_", curr_date, fixed = TRUE)))
# load("Processedinput_.RData") # insert workspace name here
toc() # Total