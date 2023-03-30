library(raster)
library(gdalUtils)
#library(rgdal)
#library(ncdf4)
#library(ncdf.helpers)

#memory.limit(size=64000)

rasterOptions(maxmemory = 1e+60)


setwd("/exports/eddie/scratch/sfraval/feed-surfaces/")


#LUgrass <- raster('SpatialData/inputs/Feed_DrySeason/LandUse/PROBAV_LC100_global_v3.0.1_2015-base_Grass-CoverFraction-layer_EPSG-4326.tif')

phenPath <- 'SpatialData/inputs/Feed_DrySeason/PhenologyModis/'
filenames <- list.files(path = phenPath,pattern=".hdf$",full.names = T)

#Convert HDF4 files to tif, extracting both bands. netHDF packages don't work in this instance. gdal_translate doesn't make a perfect copy though.
for (filename in filenames)
{
  sds <- get_subdatasets(filename)
  gdal_translate(sds[grep(pattern = ":Greenup", sds)], b = 1, dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_greenup1" ,".tif"))
  
  gdal_translate(sds[grep(pattern = "Peak", sds)], b = 1, dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_peak1" ,".tif"))
  
  gdal_translate(sds[grep(pattern = "Senescence", sds)], b = 1, dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_senescence1" ,".tif"))
  
  gdal_translate(sds[grep(pattern = "Maturity", sds)], b = 1, dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_maturity1" ,".tif"))
  
  gdal_translate(sds[grep(pattern = "Dormancy", sds)], b = 1, dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_dormancy1" ,".tif"))
  
  gdal_translate(sds[grep(pattern = ":Greenup", sds)], b = 2, dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_greenup2" ,".tif"))
  
  gdal_translate(sds[grep(pattern = "Peak", sds)], b = 2, dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_peak2" ,".tif"))
  
  gdal_translate(sds[grep(pattern = "Senescence", sds)], b = 2, dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_senescence2" ,".tif"))
  
  gdal_translate(sds[grep(pattern = "Maturity", sds)], b = 2, dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_maturity2" ,".tif"))
  
  gdal_translate(sds[grep(pattern = "Dormancy", sds)], b = 2, dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_dormancy2" ,".tif"))
  
  gdal_translate(sds[grep(pattern = "NumCycles", sds)], dst_dataset=paste0(substr(filename, 1, nchar(filename)-4), "_numcycles" ,".tif"))
  
}

##Reproject all rasters
filenamesTif <- list.files(path = paste0(phenPath) ,pattern=".tif$",full.names = T)
#filenamesTif2 <- list.files(path = paste0(phenPath) ,pattern=".tif$",full.names = F)

dir.create(paste0(phenPath,"/intermediate/"))

#for(i in 1:length(filenamesTif)){
#gdalwarp(srcfile = filenamesTif[i], dstfile = paste0(phenPath, "/intermediate/", filenamesTif2[i]), overwite = T, s_srs = "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs", t_srs = "+proj=longlat +datum=WGS84 +no_defs", r = "bilinear")

#}

phaseList <- c("greenup1", "maturity1", "peak1", "senescence1", "dormancy1", "numcycles", "greenup2", "maturity2", "peak2", "senescence2", "dormancy2")
for(i in 1:length(phaseList)){
  gdalwarp(srcfile = filenamesTif[grep(pattern = phaseList[i],  filenamesTif)], dstfile = paste0(phenPath, "/intermediate/", phaseList[i], ".tif"), overwite = T, s_srs = "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs", t_srs = "+proj=longlat +datum=WGS84 +no_defs", r = "bilinear")
  
}

#intermedatePath <- list.files(path = paste0(phenPath, "/intermediate/") ,pattern=".tif$",full.names = T)
filenamesTifInter <- list.files(path = paste0(phenPath, "/intermediate/") ,pattern=".tif$",full.names = T)
filenamesTifInter2 <- list.files(path = paste0(phenPath, "/intermediate/") ,pattern=".tif$",full.names = F)

dir.create(paste0(phenPath,"/outputTif/"))
##@Resample and crop with gdal?
for(i in 1:length(filenamesTifInter)){
  gdalwarp(srcfile = filenamesTifInter[i], dstfile = paste0(phenPath, "/outputTif/", "pheno", toupper(substr(filenamesTifInter2[i], 1, 1)), substr(filenamesTifInter2[i], 2, nchar(filenamesTifInter2[i]))), overwite = T, tr = c(0.002976190476204010338, 0.002976190476189799483), r = "bilinear", cutline = "/exports/eddie/scratch/sfraval/feed-surfaces/SpatialData/inputs/aoi1.shp", crop_to_cutline = T) #0.00297619, 0.00297619
}  


  

#interpolate, resample and crop all rasters
width = 19

#phenoGreenup1 <- raster(filenamesTifInter[grep(pattern = "greenup1.tif", filenamesTifInter)])
#phenoGreenup1 <- crop(phenoGreenup1, extent(LUgrass))
#phenoGreenup1 <- resample(phenoGreenup1, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
##phenoGreenup1 <- focal(phenoGreenup1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE) #!!!Very rough interpolation
##phenoGreenup1 <- focal(phenoGreenup1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE)
##phenoGreenup1 <- focal(phenoGreenup1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE)
#phenoGreenup1 <- mask(phenoGreenup1, LUgrass)
#writeRaster(phenoGreenup1, paste0(phenPath, "/outputTif/phenoGreenup1.tif"), overwrite = T)
#rm(phenoGreenup1)  
  
    
#phenoPeak1 <- raster(filenamesTifInter[grep(pattern = "peak1", filenamesTifInter)])
#phenoPeak1 <- crop(phenoPeak1, extent(LUgrass))
#phenoPeak1 <- resample(phenoPeak1, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
##phenoPeak1 <- focal(phenoPeak1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE) #!!!Very rough interpolation
##phenoPeak1 <- focal(phenoPeak1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE)
##phenoPeak1 <- focal(phenoPeak1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE)
#phenoPeak1 <- mask(phenoPeak1, LUgrass)
#writeRaster(phenoPeak1, paste0(phenPath, "/outputTif/phenoPeak1.tif"))
#rm(phenoPeak1)


#phenoSenescence1 <- raster(filenamesTifInter[grep(pattern = "senescence1", filenamesTifInter)])
#phenoSenescence1 <- crop(phenoSenescence1, extent(LUgrass))
#phenoSenescence1 <- resample(phenoSenescence1, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
##phenoSenescence1 <- focal(phenoSenescence1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE) #!!!Very rough interpolation
##phenoSenescence1 <- focal(phenoSenescence1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE)
##phenoSenescence1 <- focal(phenoSenescence1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE)
#phenoSenescence1 <- mask(phenoSenescence1, LUgrass)
#writeRaster(phenoSenescence1, paste0(phenPath, "/outputTif/phenoSenescence1.tif"))
#rm(phenoSenescence1)
 

#phenoMaturity1 <- raster(filenamesTifInter[grep(pattern = "maturity1", filenamesTifInter)])  
#phenoMaturity1 <- crop(phenoMaturity1, extent(LUgrass))
#phenoMaturity1 <- resample(phenoMaturity1, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
##phenoMaturity1 <- focal(phenoMaturity1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE) #!!!Very rough interpolation
##phenoMaturity1 <- focal(phenoMaturity1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE)
##phenoMaturity1 <- focal(phenoMaturity1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE)
#phenoMaturity1 <- mask(phenoMaturity1, LUgrass)
#writeRaster(phenoMaturity1, paste0(phenPath, "/outputTif/phenoMaturity1.tif"))
#rm(phenoMaturity1)

  

#phenoDormancy1 <- raster(filenamesTifInter[grep(pattern = "dormancy1", filenamesTifInter)]) 
#phenoDormancy1 <- crop(phenoDormancy1, extent(LUgrass))
#phenoDormancy1 <- resample(phenoDormancy1, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
##phenoDormancy1 <- focal(phenoDormancy1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE) #!!!Very rough interpolation
##phenoDormancy1 <- focal(phenoDormancy1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE)
##phenoDormancy1 <- focal(phenoDormancy1, w=matrix(1,nrow=width, ncol=width), fun=mean, NAonly=TRUE, na.rm=TRUE)
#phenoDormancy1 <- mask(phenoDormancy1, LUgrass)
#writeRaster(phenoDormancy1, paste0(phenPath, "/outputTif/phenoDormancy1.tif"))
#rm(phenoDormancy1)

  

#phenoNumcycles <- raster(filenamesTifInter[grep(pattern = "numcycles", filenamesTifInter)]) 
#phenoNumcycles <- crop(phenoNumcycles, extent(LUgrass))
#phenoNumcycles <- resample(phenoNumcycles, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
#phenoNumcycles <- mask(phenoNumcycles, LUgrass)
#writeRaster(phenoNumcycles, paste0(phenPath, "/outputTif/phenoNumcycles.tif"))
#rm(phenoNumcycles)


#phenoGreenup2 <- raster(filenamesTifInter[grep(pattern = "greenup2", filenamesTifInter)]) 
#phenoGreenup2 <- crop(phenoGreenup2, extent(LUgrass))
#phenoGreenup2 <- resample(phenoGreenup2, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
#phenoGreenup2 <- mask(phenoGreenup2, LUgrass)
#writeRaster(phenoGreenup2, paste0(phenPath, "/outputTif/phenoGreenup2.tif"))
#rm(phenoGreenup2)
  
  
#phenoPeak2 <- raster(filenamesTifInter[grep(pattern = "peak2", filenamesTifInter)]) 
#phenoPeak2 <- crop(phenoPeak2, extent(LUgrass))
#phenoPeak2 <- resample(phenoPeak2, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
#phenoPeak2 <- mask(phenoPeak2, LUgrass)
#writeRaster(phenoPeak2, paste0(phenPath, "/outputTif/phenoPeak2.tif"))
#rm(phenoPeak2)

  
#phenoSenescence2 <- raster(filenamesTifInter[grep(pattern = "senescence2", filenamesTifInter)]) 
#phenoSenescence2 <- crop(phenoSenescence2, extent(LUgrass))
#phenoSenescence2 <- resample(phenoSenescence2, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
#phenoSenescence2 <- mask(phenoSenescence2, LUgrass)
#writeRaster(phenoSenescence2, paste0(phenPath, "/outputTif/phenoSenescence2.tif"))
#rm(phenoSenescence2)

  
#phenoMaturity2 <- raster(filenamesTifInter[grep(pattern = "maturity2", filenamesTifInter)])
#phenoMaturity2 <- crop(phenoMaturity2, extent(LUgrass))
#phenoMaturity2 <- resample(phenoMaturity2, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
#phenoMaturity2 <- mask(phenoMaturity2, LUgrass)
#writeRaster(phenoMaturity2, paste0(phenPath, "/outputTif/phenoMaturity2.tif"))
#rm(phenoMaturity2)

  
#phenoDormancy2 <- raster(filenamesTifInter[grep(pattern = "dormancy2", filenamesTifInter)]) 
#phenoDormancy2 <- crop(phenoDormancy2, extent(LUgrass))
#phenoDormancy2 <- resample(phenoDormancy2, LUgrass, method = "bilinear") #Resample from 500m to 300m using method for continuous data data
#phenoDormancy2 <- mask(phenoDormancy2, LUgrass)
#writeRaster(phenoDormancy2, paste0(phenPath, "/outputTif/phenoDormancy2.tif"))
#rm(phenoDormancy2)
