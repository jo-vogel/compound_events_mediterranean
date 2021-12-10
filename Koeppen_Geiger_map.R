# Create Koeppen Geiger map 

message("run Koeppen_Geiger.R first")

med_extent <- c(-9.625,40.125,30.375,45.125) # first study
med_extent <- c(-9.125, 47.125,  30.88, 44.88) # second study
Koeppen_med <- crop(r, y=med_extent)

plot(Koeppen_med)
barplot(table(Koeppen_med@data@values))


# plot single climate type
Koeppen_test <- Koeppen_med
Koeppen_test[Koeppen_test@data@values %in% c(seq(1,7,1),seq(9,32,1))] <- NA
plot(Koeppen_test)

Koeppen_test <- Koeppen_med
cli_type <- seq(1,32,1)[-c(19,23)]
Koeppen_test[Koeppen_test@data@values %in% cli_type] <- NA
plot(Koeppen_test)



# List of climate types
#' 32: ocean
#' 12: Csa
#' 7: BWh
#' 10: Cfb
#' 9: Cfa
#' 13: Csb
#' 6: BSk
#' 5: BSh
#' 8: BWk
#' 23: DSb
#' Other: Tundra climate (31)

# Joining and removing
#' Final list: 
#' Ocean 32
#' Csa 12: Mediterranean hot summer climates
#' BW 7,8: arid climate
#' excluded (Cfa(, Cfb) 9,10: warm temperate humid climate)
#' Cfa 9: Humid subtropical climate
#' Cfb, Cfc: oceanic climate
#' Csb (and Csc) 13,14: Mediterranean warm summer climates
#' BS 5,6: semi-arid climate
#' Dsb (, Dsa, Dsc, Dfb, Dfc) 19,20,22,23,24: humid continental climate
#' Other / Tundra climate 31



# Create final Koeppen map
Koeppen_final <- Koeppen_med

Koeppen_final [Koeppen_final@data@values %in% c(5,6)] <- 1 # semi-arid climate
Koeppen_final [Koeppen_final@data@values %in% c(7,8)] <- 2 # arid climate
Koeppen_final [Koeppen_final@data@values %in% c(9)] <- 3 # Humid subtropical climate
Koeppen_final [Koeppen_final@data@values %in% c(10,11)] <- 4 # oceanic climate
Koeppen_final [Koeppen_final@data@values %in% c(12)] <- 5 # Mediterranean hot summer climates
Koeppen_final [Koeppen_final@data@values %in% c(13,14)] <- 6 # Mediterranean warm summer climate
Koeppen_final [Koeppen_final@data@values %in% c(19,20,22,23,24)] <- 7 # humid continental climate
Koeppen_final [Koeppen_final@data@values %in% c(31)] <- 8 # Tundra climate
Koeppen_final [Koeppen_final@data@values %in% c(32)] <- 9 # Ocean

plot(Koeppen_final,col=rainbow(9))

writeRaster(Koeppen_final,file="D:/Local/Data/GIS data/Köppen-Geiger/Koeppen_mediterranean.tif")

# clip map, so the edges don't overlap into the sea
ocean <- readOGR('D:/user/vogelj/Data/ne_10m_ocean/ne_10m_ocean.shp') # Fuers Entfernen der Meeresfl?chen
Koeppen_clip <- mask(Koeppen_final, ocean, inverse=T)
plot(Koeppen_clip)
plot(Koeppen_final)
writeRaster(Koeppen_clip,file="D:/Local/Data/GIS data/Köppen-Geiger/Koeppen_mediterranean_clipped.tif",overwrite=T)


# Make map for Vulnerability analysis (second study)
writeRaster(Koeppen_final, file="C:/Users/vogelh/ownCloud/Promotion/Impact_analysis/Output/Study_area/Koeppen_mediterranean.tif",overwrite=T)
writeRaster(Koeppen_clip, file="C:/Users/vogelh/ownCloud/Promotion/Impact_analysis/Output/Study_area/Koeppen_mediterranean_clipped.tif",overwrite=T)
