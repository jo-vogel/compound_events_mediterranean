# Drought events: ####
######################

library(tictoc)
tic("Drought event calculation")
# rm(list=ls())
start <- Sys.time()
tic("total")
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

# load the processed input data
load("./Workspaces/Processedinput_Thu_Jan_09_12_21_32_2020.RData") # Processsed input (SPI, SPEI, max temp.) for warm season
# load("./Workspaces/Processedinput_Sat_Jan_11_07_48_17_2020.RData") # Processsed input (SPI, SPEI, max temp.) for whole season, deseasonalised, frequency 12

# load("./Workspaces/Processedinput_Wed_Oct_16_08_43_34_2019.RData") # Processsed input (SPI, SPEI, max temp.) for warm season, old 3m-SPI calculation
# load("./Workspaces/Processedinput_Sun_Dec_08_04_40_26_2019.RData") # Processsed input (SPI, SPEI, max temp.) for whole season, deseasonalised, frequency 1 (old version)

# Warm season ####
time_span <- 6
summer <- c(31,30,31,31,30,31) # warm season: days of each month from May to October
month_lengths <- rep(summer,years) # f?r Anzahl der Jahre


# Whole season ####
# time_span <- 12
# whole_year <- c(31,28,31,30,31,30,31,31,30,31,30,31) # whole year
# whole_year_leap <- c(31,29,31,30,31,30,31,31,30,31,30,31) # leap year
# month_lengths  <- rep(c(whole_year,whole_year_leap,whole_year,whole_year),10) # length of all 480 months from 1979-2018
# prcp_all <- prcp_all_des
# temp_all <- temp_all_des
# spi_prec <- spi_prec_des
# spei_med <- spei_med_des
# temp_all_3d <- temp_array # could be solved more elegantly


# Prerequisites ####
# Events per pixel for first, second and whole time span
event <- array(rep(0,length(coord[,1])*3),c(length(coord[,1]),3)) # 1st time span, 2nd time span, whole time span
event_b <- array(rep(0,length(coord[,1])*3),c(length(coord[,1]),3)) # 1st time span, 2nd time span, whole time span
# Events per time step
events_per_time <- array(rep(0,length(month_lengths)),c(length(month_lengths))) # Zeitreihenl?nge in Monaten
events_per_time_b <- array(rep(0,length(month_lengths)),c(length(month_lengths))) # Zeitreihenl?nge in Monaten
# Events per time step and pixel
event_series <- array(rep(0,length(coord[,1])*length(month_lengths)),c(length(coord[,1]),length(month_lengths)))
event_series_b <- array(rep(0,length(coord[,1])*length(month_lengths)),c(length(coord[,1]),length(month_lengths)))

# Refine area ####
# Create a spatial object, which is needed only for resampling Koeppen-Geiger map
temp_r <- raster(t(temp_array[,,1]), xmn=-10.125, xmx=40.125, ymn=27.875, ymx=60.125, crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
# Add Projection
crs(temp_r) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
# create Köppen-Geiger map
source('Koeppen_Geiger.R')
# Crop Köppen-Geiger map to Mediterranean area
Koeppen <- crop(Koeppen,temp_r)
# Resample Köppen-Geiger map to resolution of ERA 5 data
Koeppen <- resample(Koeppen,temp_r,method="ngb") # nearest neighbor is appropriate for categorical variables

# Apparently, it's not possible to give multiple values to the mask command.
# Workaround: assign both values 12 and 13 to a non-existing value (e.g. 1)
Koeppen[Koeppen@data@values==12] <- 1
Koeppen[Koeppen@data@values==13] <- 1

locat <- which(Koeppen@data@values==1)


# Event calculation loop ####

# for (d in 1:length(dur)){ # heat wave durations
# for (p in 1:dim(percentiles)[1]){ # percentile thresholds
for (k in locat){ # pixels
  # count <- 0 # f?r jeden Pixel wieder auf 0 setzen
  for (i in 3:length(month_lengths)){ # Monate i (ersten 2 Monate sind NA bei 3-monatigem SPI)
    # for (j in 1:month_lengths[i]){ # Tage j des Monats i
    # if (!is.na(temp_all[k,(sum(month_lengths[1:i-1])+j)]) && temp_all[k,(sum(month_lengths[1:i-1])+j)] > percentiles[p,k]) { # Tage der bisherigen Monate + Tag j des akutellen Monats i: ?berschreitung des Perzentils
    # count <- count+1
    if (!is.na(spi_prec[i,k]) && (spi_prec[i,k] < -0.8)){ # Wenn Duerre erfuellt ist; (NAs beruecksichtigt);
      # if (count==dur[d] && !is.na(spi_prec[i,k]) && (spi_prec[i,k] < -0.8)){ # Wenn 5-t?gige Hitzewelle und D?rre erf?llt sind; (NAs ber?cksichtigt);
      event[k,3] <- event[k,3]+1
      if (i<=20*time_span){ # 1979-1998
        event[k,1] <- event[k,1]+1
      }
      else if (i>20*time_span){ # 1999-2018
        event[k,2] <- event[k,2]+1 
      }
      events_per_time [i] <- events_per_time [i]  + 1
      event_series [k,i] <- event_series [k,i] + 1
      # events_per_time [(sum(month_lengths[1:i-1])+j)] <- events_per_time [(sum(month_lengths[1:i-1])+j)]  + 1
      # count <- 0
    }
    if (!is.na(spei_med[i,k]) && (spei_med[i,k] < -0.8)){ # Wenn Duerre erfuellt ist; (NAs beruecksichtigt);
      event_b[k,3] <- event_b[k,3]+1
      if (i<=20*time_span){ # 1979-1998
        event_b[k,1] <- event_b[k,1]+1
      }
      else if (i>20*time_span){ # 1999-2018
        event_b[k,2] <- event_b[k,2]+1 
      }
      events_per_time_b [i] <- events_per_time_b [i]  + 1
      event_series_b [k,i] <- event_series_b [k,i] + 1
    }
    # if (i!=length(month_lengths) && j!=month_lengths[i]){ # wenn es sich nicht um den letzten Tag des Datensatzes handelt (da kein Folgetag existiert)
    # if ( temp_all[k,(sum(month_lengths[1:i-1])+j+1)] <= percentiles[p,k] || (i==time_span && j==31)) { # wenn der n?chste Tag nicht extrem ist, ist die Bedingung f?r Hitzeperiode nicht erf?llt und es geht von vorn los 
    # (f?r den letzten Tag kann man dies nicht pr?fen, daher Zusatzbedingung); am Ende der Saison auf 0 setzen (da sonst eine Verbindung zur n?chsten Saison ein halbes Jahr sp?ter entstehen k?nnte)
    # count <- 0
    # }
    # }
    # }
    # }
  }
}
# } 
# }


curr_date <- paste0("Events_",timestamp(prefix='',suffix=''),".RData")
curr_date <- gsub(" ", "_", curr_date, fixed = TRUE)
save.image(file=paste0("./Workspaces/",gsub(":", "_", curr_date, fixed = TRUE)))

# colSums(events_per_time)
# colSums(event,na.rm=T)

toc() # Compound event calculation