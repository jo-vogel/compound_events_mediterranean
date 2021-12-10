# Compound heatwaves and droughts in the Mediterranean (based on Mazdiyasni & AghaKouchak 2015)

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
library(scales)

path_clim <- "D:/user/vogelj/Data/ERA5" # NRC-Server



# Data loading and processing ####
##################################


prec <- list.files(path=paste0(path_clim,"/Precipitation/1979-2018"), pattern = "monthly.*nc$",recursive = T) # for 1979-2018
temp <- list.files(path=paste0(path_clim,'/Temperature'), pattern = "Temperature.*nc$")																														   
pev <- list.files(path=paste0(path_clim,"/Potential evaporation/1979-2018"), pattern = "monthly.*nc$",recursive = T) # for 1979-2018

# Open precipitation data
prcp_vec <- list()
prcp_array <- list()
for (i in 1: length(prec)){
  prcp_vec[[i]] <- nc_open(paste0(path_clim,"/Precipitation/1979-2018/",prec[i])) # i could create prcp_vec without index 
  prcp_array[[i]] <- ncvar_get(prcp_vec[[i]],"tp") # store the data in a 3-dimensional array
  names(prcp_array)[[i]] <- paste0(strsplit(prec,"[.]")[[i]][4],strsplit(prec,"[.]")[[i]][5])
  nc_close(prcp_vec[[i]])
}
rm(prcp_vec) # save RAM space (if not deleted, you alternatively have to close the nc files)
vec_prcp <- 1:length(prec) # 
prcp_all_raw <- sapply(vec_prcp, function(x) {prcp_array[[x]]}) 
rm(prcp_array)

# Open potential evaporation data
pev_vec <- list()
pev_array <- list()
for (i in 1: length(pev)){
  pev_vec[[i]] <- nc_open(paste0(path_clim,"/Potential evaporation/1979-2018/",pev[i])) # i could create pev_vec without index 
  pev_array[[i]] <- ncvar_get(pev_vec[[i]],"pev") # store the data in a 3-dimensional array
  names(pev_array)[[i]] <- paste0(strsplit(pev,"[.]")[[i]][4],strsplit(pev,"[.]")[[i]][5])
  nc_close(pev_vec[[i]])
}
rm(pev_vec) # save RAM space (if not deleted, you alternatively have to close the nc files)
pev_all <- sapply(vec_prcp, function(x) {pev_array[[x]]})
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
      max.array[i,j,] <- aggregate(zpix,by=intervals,FUN=max,na.rm=T) # finds daily maxima; NAs exist on the first day (first 7 hours), therefore na.rm=T is needed
    }
  }
  temp_array <- abind(temp_array,max.array,along=3) # verbinde die Jahrzehnte zu einem gro?en Objekt
  nc_close(tempnetcdf)
}
rm(tempnetcdf)

lon2 <- rep(lon,length(lat))
lat2 <- rep(lat,each=length(lon))
coord <- cbind(lon2,lat2) # same format as used for United States

years <- 40  # momentan 40 Jahre
temp_all_raw <- matrix(temp_array,dim(temp_array)[1]*dim(temp_array)[2],dim(temp_array)[3]) # reshape from lon,lat,temp (3dim) to pixel (lon/lat), temp (2dim)
# geht bei Neuanordnung erst alle Zeilen durch, dann alle Spalten
toc() # Daily maxima calculation
toc() # Data preparation



# Deseasonalisation for whole data set ####
###########################################

# Temperature
dates <-rep(c(1:59,61:366,1:366,1:59,61:366,1:59,61:366),10) # indices of each Julian date: puts yearly gap at the right spot (entry 59, i.e. 28.02.)
ts_temp_dates <- rbind(temp_all_raw,dates)

# Calculation of the mean value of each Julian date for all pixels
mean_temp <- sapply(1:dim(coord)[1], function (x){ tapply(ts_temp_dates[x,],INDEX=ts_temp_dates[dim(coord)[1]+1,], FUN=mean)})
# plot(mean_temp[,150],type='l') # average for each date of the year

# Smoothing
dattemp <- cbind(1:366,mean_temp)
dattemp <- data.frame(dattemp)
mean_temp_smooth <- sapply(2:(dim(coord)[1]+1),function(x){ predict(loess(dattemp[,x]~X1, dattemp, span = 0.1))})
# plot(mean_temp[,1],type='l') # average for each date of the year
# lines(mean_temp_smooth[,1],col='red')

#Extrahiere den jeweiligen Durchschnitt des zugehörigen julianischen Datums: 2 SChritte: 1.Frage das Datum ab (Tag 1-366), 2.Ordne den jeweiligen Durchschnittswert zu
temp_averages_date <- sapply(1:dim(coord)[1], function (y) {sapply(1: dim(ts_temp_dates)[2],function(x){mean_temp_smooth[ts_temp_dates[dim(coord)[1]+1,x],y]})}) # last column: column with the dates
# plot(temp_averages_date[,60] ,type='l') # Jahresgang (mit jedem 4. Jahr als Schaltjahr)
ts_temp_deseason <- ts_temp_dates[1:dim(coord)[1],]- t(temp_averages_date)
temp_all_des <- ts_temp_deseason
# plot(ts_temp_deseason[,60],type='l')


# Precipitation
dates <- rep(1:12,40)
ts_prcp_dates <- rbind(prcp_all_raw,dates)

# Calculation of the mean value of each month
mean_prcp <- sapply(1:dim(coord)[1], function (x){ tapply(ts_prcp_dates[x,],INDEX=ts_prcp_dates[dim(coord)[1]+1,], FUN=mean)})
# plot(mean_prcp[,150],type='l') # average for each month
# prcp_averages_date is a data frame which repeats the 12 means of each year as often as the number of years; therefore it has the same dimensions as the actual data, so you can easily subtract it
prcp_averages_date <- sapply(1:dim(coord)[1], function (y) {sapply(1: dim(ts_prcp_dates)[2],function(x){mean_prcp[ts_prcp_dates[dim(coord)[1]+1,x],y]})}) # last column in ts_prcp_dates: column with the dates
# plot(prcp_averages_date[,60] ,type='l') # Jahresgang, interesting pixel, with bimodal distribution 
# plot(prcp_averages_date[,150] ,type='l') # Jahresgang
ts_prcp_deseason <- ts_prcp_dates[1:dim(coord)[1],] - t(prcp_averages_date)
prcp_all_des <- ts_prcp_deseason
prcp_des_resc <- t(apply(prcp_all_des,1, rescale, to=c(0,1))) # rescale to 0 & 1 to avoid negative values (for the fitting of the gamma distribution in the SPI calculation)
# plot(ts_prcp_deseason[,60],type='l')


# Potential evaporation
ts_pev_dates <- rbind(pev_all,dates)

# Calculation of the mean value of each month
mean_pev<- sapply(1:dim(coord)[1], function (x){ tapply(ts_pev_dates[x,],INDEX=ts_pev_dates[dim(coord)[1]+1,], FUN=mean)})

pev_averages_date <- sapply(1:dim(coord)[1], function (y) {sapply(1: dim(ts_pev_dates)[2],function(x){mean_pev[ts_pev_dates[dim(coord)[1]+1,x],y]})}) # last column: column with the dates
ts_pev_deseason <- ts_pev_dates[1:dim(coord)[1],] - t(pev_averages_date)
pev_all_des <- ts_pev_deseason
# pev_des_resc <- t(apply(pev_all_des, 1, rescale, to=c(0,1))) # rescale to 0 & 1 to avoid negative values (for the fitting of the log logarithmic distribution in the SPEI calculation)


# SPI and SPEI calculation for droughts ####
###################################

tic("SPI calculation") # Schneller als for-loop im Cluster im Vergleich zur Matrixoperation
wat_bal <- prcp_all_des + pev_all_des  # water balance (difference between precipitation and potential evaporation); pev is already negative (therefore addition not substraction)
wat_bal_resc <- t(apply(wat_bal, 1, rescale, to=c(0,1))) # rescale to 0 & 1 to avoid negative values (for the fitting of the log logarithmic distribution in the SPEI calculation)
wat_bal_raw <- prcp_all_raw + pev_all
# # tsobj <- ts(t(prcp_all_des)) # als time series-Objekt deutlich schneller 
# tsobj <- ts(t(prcp_des_resc)) # als time series-Objekt deutlich schneller 
# tsobj_old <- tsobj
tsobj <- ts(t(prcp_all_raw), frequency = 12) # als time series-Objekt deutlich schneller 
# # tsobj_wb <- ts(t(wat_bal)) 
# tsobj_wb_old <- ts(t(wat_bal_resc))
tsobj_wb <- ts(t(wat_bal_raw), frequency = 12) 
message("SPI bei Konvertierung zu tsobj nicht identisch. SPI ist dann auch deutlich normalverteilter.")
# Die coefficients des SPI des Zeitreihenobjektes hat L?nge 1 statt 12 in der 3.Dimension
# Die Dimensionen sind nach der Konvertierung invertiert.

no_cores <- detectCores() - 1
cl<-makeCluster(no_cores)
clusterEvalQ(cl, library(raster)) # parallelisation hat eigenes environment, daher m?ssen packages und bestimmte Variablen erneut geladen werden
registerDoParallel(cl)

spi_prec_des <- matrix(NA,dim(tsobj)[1],dim(tsobj)[2])
spi_prec_des <- foreach (i=1:dim(tsobj)[2],.combine=cbind) %dopar% { 
  spi_fun <- SPEI::spi(tsobj[,i],3,na.rm=TRUE)
  as.vector(spi_fun$fitted)
}

spei_med_des <- matrix(NA,dim(tsobj_wb)[1],dim(tsobj_wb)[2])
spei_med_des <- foreach (i=1:dim(tsobj_wb)[2],.combine=cbind) %dopar% { 
  spei_fun <- SPEI::spei(tsobj_wb[,i],3,na.rm=TRUE)
  as.vector(spei_fun$fitted)
}
stopCluster(cl)
toc() # SPI calculation

# plot(spi_prec_des$fitted[,2000:2003]) # Mehrfachplots
# spi_prec_des_single <- SPEI::spi(t(prcp_all_des)[,7],3,na.rm = TRUE)
# plot(spi_prec_des_single, 'Prec, SPI-1') # Farbplot geht nur f?r einzelne Zeitreihe
# drought <- which(spi_prec_des$fitted < -0.8) # identify droughts (SPI below -0.8)
# spi_prec_des$fitted[drought] # all occurring droughts
# print(spi_prec_des)
# summary(spi_prec_des)

curr_date <- paste0("Processedinput_",timestamp(prefix='',suffix=''),".RData")
curr_date <- gsub(" ", "_", curr_date, fixed = TRUE)
save.image(file=paste0("./Workspaces/",gsub(":", "_", curr_date, fixed = TRUE)))
# load("Processedinput_.RData") # insert workspace name here
toc() # Total