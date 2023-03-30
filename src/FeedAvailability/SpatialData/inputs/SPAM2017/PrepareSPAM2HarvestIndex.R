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

args <- commandArgs(TRUE)

#EDDIE_TMP <- as.character(args[1])

#Runs with 16gb ram and 40+gb hdd space
#rasterOptions(tmpdir = EDDIE_TMP)
rasterOptions(maxmemory = 1e+60)
rasterOptions(todisk = TRUE)
#memory.limit(size = 56000) #Windows specific


setwd("/exports/eddie/scratch/sfraval/feed-surfaces/SPAM2017_burkina")

cropHI <- read.csv('crop_harvest index.csv')

pathSPAM <- 'SPAM2017'
#From SPAM documentation: *_TA	all technologies together, ie complete crop; *_TI	irrigated portion of crop; *_TH	rainfed high inputs portion of crop; *_TL	rainfed low inputs portion of crop; *_TS	rainfed subsistence portion of crop; *_TR	rainfed portion of crop (= TA - TI, or TH + TL + TS)
#end of file name should be physical area_cropname_a -> last a standing for all tech together.
filesSPAM <- list.files(path = pathSPAM, pattern = "_A.tif$", full.names = T)
stSPAM <- stack(filesSPAM)

#@Fill NAs of SPAM layers? At the moment all crops are assumed to be animal digestable if NA

### produce harvest index layer
crops <- toupper(c('barl','bean','cass','chic','cowp','grou','lent','maiz','ocer','opul','orts','pmil','pige','plnt','pota','rape','rice','sesa','smil','sorg','soyb','sugb','sunf','swpo','temf','trof','vege','whea','yams'))

tmpCropIndex <- grep(pattern = paste(crops, collapse = "|"), names(stSPAM))
iSPAMcropArea <- overlay(stSPAM[[tmpCropIndex]], fun = sum)

print("past 1")

stHI <- stack()
stSPAMcropProp <- stack()
for(i in 1: length(crops)){
   tmpCropIndex <- grep(pattern = paste(crops[i], collapse = "|"), names(stSPAM))
   iSPAMtmpArea <- overlay(stSPAM[[tmpCropIndex]], fun = sum)
   icrop <- stSPAM[[tmpCropIndex]]
   icrop[icrop >0] <- (1 - cropHI$harvest_index[toupper(cropHI$name) == crops[i]])
   stHI <- stack(stHI, icrop)
   #stHI <- stack(stHI, overlay(iSPAMtmpArea, fun = function((x){ifelse(!is.na(x), (1 - cropHI$harvest_index[cropHI$name == crops[i]]), NA)}))

   stSPAMcropProp <- stack(stSPAMcropProp, overlay(iSPAMtmpArea, iSPAMcropArea, fun = function(x, y){(x/y)}))

   print(paste("Loop", i))
}


iSPAMcropResFrac <- weighted.mean(stHI, stSPAMcropProp, na.rm = T)
iSPAMcropResFrac <- reclassify(iSPAMcropResFrac, cbind(NA, NA, 0.8), right=FALSE) #Replace NA with 0.8 - assume that 80% is available for animals

print("past mean")

writeRaster(iSPAMcropResFrac, 'crop_res_frac.tif', overwrite = T)

