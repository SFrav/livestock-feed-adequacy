library(raster)
#library(sp)
#library(sf)
library(gdalUtils)

setwd('/exports/eddie/scratch/sfraval/feed-surfaces/SPAM2017_burkina/')


filenames <- list.files(path = '.' ,pattern="*A.tif$",full.names = F)

#stSPAM <- stack(filenames)

for(i in 1:length(filenames)){
  
  gdalwarp(srcfile = filenames[i], dstfile = paste0('out/',filenames[i]), overwrite = T, tr = c(0.00297619, 0.00297619), r = "bilinear", cutline = "aoi1.shp", crop_to_cutline = T) #0.00297619, 0.00297619

}  
