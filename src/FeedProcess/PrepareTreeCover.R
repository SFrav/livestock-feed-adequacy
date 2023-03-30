library(raster)
library(stars)
#library(terra)
library(sf)
library(exactextractr)

#setwd("/exports/eddie/scratch/sfraval/feed-surfaces/")

#livelihood <- st_read('SpatialData/inputs/BF')

treesBrandt <- raster('SpatialData/inputs/TreeCover/Burkina_Faso_treecover_2019_v1_30m.tif')
##plot(treesBrandt) 
##click(treesBrandt) #Check NA values
##treesHansen <- raster('SpatialData/inputs/TreeCover/HansenTreeCover.tif')
##treesHansenGain <- raster('SpatialData/inputs/TreeCover/HansenTreeGain.tif')
##treesHansenLoss <- raster('SpatialData/inputs/TreeCover/HansenTreeLoss.tif')

#livelihood$treeMean <- exact_extract(treesBrandt, livelihood, 'mean')

#st_rasterize(sf = livelihood[, 'treeMean'], file = 'SpatialData/inputs/TreeCover/treecoverLZMean.tif', overwrite = T)

#treeMean <- raster('SpatialData/inputs/TreeCover/treecoverLZMean.tif')
##treeMean <- resample(treeMean, treesBrandt, method = "ngb")

#treesOut <- overlay(treesBrandt, treeMean, function(EO, mean) {ifelse(is.na(EO), mean, EO)})
#treesOut <- aggregate(treesOut, fact = 10, fun = 'mean')
treesOut <- aggregate(treesBrandt, fact = 10, fun = 'mean')
writeRaster(treesOut, 'SpatialData/inputs/TreeCover/treecover_imp.tif')
