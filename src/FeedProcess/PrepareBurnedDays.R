#     .-.                                    ,-.
#  .-(   )-.                              ,-(   )-.
# (     __) )-.                        ,-(_      __)
#  `-(       __)                      (_    )  __)-'
#  - -  :   :  - - Dry matter feed potential and variability layer preparation
#      / `-' \     v0.1
#    ,    |   .    Simon Fraval
#         .        R 3.6.1           _
#                                  >')
#                                  (\\         (W)
#                                   = \     -. `|'
#                                   = ,-      \(| ,-
#                                 ( |/  _______\|/____
#                                \|,-'::::::::::::::
#            _                 ,----':::::::::::::::::
#         {><_'c   _      _.--':MJP:::::::::::::::::::
#__,'`----._,-. {><_'c  _-':::::::::::::::::::::::::::
#:.:.:.:.:.:.:.\_    ,-'.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:
#.:.:.:.:.:.:.:.:`--'.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
#.....................................................

library(dplyr)
library(raster)
#library(sf)
#library(stars)
library(rgdal)
#library(ggplot2)
#library(tidyr)
#library(ggspatial)
#library(flexsurv) #for gompertz distribution
#library(tmap) #For interactive map

#args <- commandArgs(TRUE)

#EDDIE_TMP <- as.character(args[1])
#print(EDDIE_TMP)
#print(args)

#Runs with 16gb ram and 40+gb hdd space
#rasterOptions(tmpdir = EDDIE_TMP)
#rasterOptions(maxmemory = 5e+20) # 6e+10 ~51GB allowed
#rasterOptions(todisk = TRUE)
##memory.limit(size = 56000) #Windows specific


#setwd("/exports/eddie/scratch/sfraval/feed-surfaces/")

aoi <- readOGR("SpatialData/inputs/aoi1.shp")

pathPhen <- 'SpatialData/inputs/Feed_DrySeason/PhenologyModis/outputTif/'
filesPhenology <- list.files(path = pathPhen,pattern=".tif$",full.names = T)
pathBurn <- 'SpatialData/inputs/Burned/'
filesBurn <- list.files(path = pathBurn,pattern=".tiff$",full.names = T)#[1:36] #Only 2015
datesBurn <- as.vector(sapply(filesBurn, function(x) substr(x, start =(nchar(x) - 37), stop = (nchar(x) -30)))) #(nchar(x) - 41), stop = (nchar(x) -34))
datesBurn <- as.Date(datesBurn, "%Y%m%d")
datesBurndiff <- as.numeric(datesBurn - as.Date("1970/01/01")) #convert to same date format as Modis phenology
pathLU <- 'SpatialData/inputs/Feed_DrySeason/LandUse/'
filesLU <- list.files(path = pathLU, pattern = "300.tif$", full.names = T)

rProtectedAreas <- raster('SpatialData/inputs/ProtectedAreas/WDPAGlobal.tif') #Original shp is 4gb+ 
rNonProtectedAreas <- calc(rProtectedAreas, fun = function(x){ifelse(x == 0, 1, 0)})
rm(rProtectedAreas)


stLU <- stack(filesLU)
###Edits to LU
#for(i in 1:length(names(stLU))){
#stLU[[i]] <- overlay(stLU[[i]], fun = function(x) { x / 100})
##stLU <- stLU /100 #From percentage to proportion
#print(i)
#}
#print("past LU")

stPhen <- stack(filesPhenology)
stBurn <- stack(filesBurn)


##Crop to test area
stLU <- extend(stLU, extent(stBurn[[1]]))
stLU <- crop(stLU, extent(stBurn[[1]]))
stLU <- mask(stLU, aoi)
stPhen <- resample(stPhen, stBurn[[1]], method = "ngb")
stPhen <- extend(stPhen, extent(stBurn[[1]]))
stPhen <- crop(stPhen, extent(stBurn[[1]]))
#stPhen <- mask(stPhen, aoi)
rNonProtectedAreas <- resample(rNonProtectedAreas, stBurn[[1]], method = "ngb")
rNonProtectedAreas <- extend(rNonProtectedAreas, extent(stBurn[[1]]))
rNonProtectedAreas <- crop(rNonProtectedAreas, extent(stBurn[[1]]))
#rNonProtectedAreas <- mask(rNonProtectedAreas, aoi)
print("past 0")

names(stBurn) <- paste0("d", datesBurndiff)
stBurn <- reclassify(stBurn, c(100, 255, NA)) #NA values are 254 

stLU$LUtree300 <- reclassify(stLU$LUtree300, c(-Inf, 0, 0, 200, Inf, 0)) 
stLU$LUtree300[is.na(stLU$LUtree300)] <- 0


print("past 1")

#####Estimate total Burn dekads
funBurnGrass <- function(burnBin, crops, grass, forest, shrub, nonprotected, greenup, senesence, greenup2, senesence2) {ifelse((senesence >= datesBurndiff[i] & (grass+shrub) >0.25) | (greenup2 <= datesBurndiff[i] & senesence2 >= datesBurndiff[i] & (grass+shrub) >0.25), burnBin, NA) } 
funBurnCrops <- function(burnBin, crops, greenup, senesence, greenup2, senesence2) {ifelse((senesence < datesBurndiff[i] & senesence + 60 > datesBurndiff[i] & crops > 0.25) | (senesence2 < datesBurndiff[i] & crops > 0.25), burnBin, NA) } 


iBurnGrass <- stack()
iBurnCrops <- stack()
for(i in 1:length(names(stBurn))){
  
  #iBurnGrass <- stack(iBurnGrass, overlay(stBurn[[i]], stLU$LUcrops300, stLU$LUgrass300, stLU$LUtree300, stLU$LUshrub300, rNonProtectedAreas, stPhen$phenoGreenup1, stPhen$phenoSenescence1, stPhen$phenoGreenup2, stPhen$phenoSenescence2, fun = funBurnGrass))
  #writeRaster(iDMP, paste0('SpatialData/inputs/Feed_quantity/totalDMP', datesDMP[i], '.tif'), overwrite = TRUE)  
  
  iBurnCrops <- stack(iBurnCrops, overlay(stBurn[[i]], stLU$LUcrops300, stPhen$phenoGreenup1, stPhen$phenoSenescence1, stPhen$phenoGreenup2, stPhen$phenoSenescence2, fun = funBurnCrops))
  #writeRaster(iDMPCropGrowing, paste0('SpatialData/inputs/Feed_quantity/cropDMP', datesDMP[i], '.tif'), overwrite = TRUE)
  print(paste("cycle", i))
  gc()
}

#rm(list = ls())
gc()

#iDMP <- stack(list.files(path = "SpatialData/inputs/Feed_quantity/",pattern="total",full.names = T))

##print("past 2")
burnGrassDekads <- sum(iBurnGrass, na.rm = T)
writeRaster(burnGrassDekads, 'SpatialData/inputs/burnGrassDekads.tif', overwrite = TRUE)
##print("past mean")

#iDMPCropGrowing <- stack(list.files(path = "SpatialData/inputs/Feed_quantity/",pattern="crop",full.names = T))
burnCropDekads <- sum(iBurnCrops, na.rm = T)
writeRaster(burnCropDekads, 'SpatialData/inputs/burnCropsDekads.tif', overwrite = TRUE)
#DMPcv <- cv(iDMP, na.rm = T)
#writeRaster(DMPcv, 'SpatialData/inputs/Feed_quantity/DMPcv.tif', overwrite = TRUE)
#print("past CV")

#DMPcropProp <- sum(iDMPCropGrowing, na.rm = T) / sum(iDMP, na.rm = T)
#DMPcropProp <- DMPcropTotal / sum(iDMP, na.rm = T)

##DMPcropSum <- sum(iDMPCropGrowing, na.rm = T)
##writeRaster(DMPcropSum, 'SpatialData/inputs/Feed_quantity/DMPCropsum.tif', overwrite = TRUE)

##DMPsum <- sum(iDMP, na.rm = T)
##writeRaster(DMPsum, 'SpatialData/inputs/Feed_quantity/DMPsum.tif', overwrite = TRUE)


print("Pre-export")
###Exports


#writeRaster(DMPcropProp, 'SpatialData/inputs/Feed_quality/DMPcropProp.tif', overwrite = TRUE)
print("Complete")

########################
#Extract deakadly data for grass growth in each location

#funDMPgrass <- function(dmp, grass, forest, nonprotected) {(dmp*grass*grassFrac)+(dmp*forest*forestFrac*nonprotected)}

#iDMPgrass <- stack()
#for(i in 1:length(names(stDMP))){
  
#  iDMPgrass <- stack(iDMPgrass,  overlay(stDMP[[i]], stLU$LUgrass300, stLU$LUtree300, rNonProtectedAreas, fun = funDMPgrass))
  
  
#}
#print("past 4")
#DMPgrasscv <- cv(iDMPgrass, na.rm = T)

#writeRaster(DMPgrasscv, 'SpatialData/inputs/Feed_quantity/DMPgrasscv.tif', overwrite = TRUE)

#writeRaster(iDMPgrass[[2]], 'SpatialData/inputs/Feed_quantity/DMPGrassJan.tif', overwrite = TRUE)
#writeRaster(iDMPgrass[[16]], 'SpatialData/inputs/Feed_quantity/DMPGrassMay.tif', overwrite = TRUE)
#writeRaster(iDMPgrass[[25]], 'SpatialData/inputs/Feed_quantity/DMPGrassAug.tif', overwrite = TRUE)
#writeRaster(iDMPgrass[[36]], 'SpatialData/inputs/Feed_quantity/DMPGrassDec.tif', overwrite = TRUE)
