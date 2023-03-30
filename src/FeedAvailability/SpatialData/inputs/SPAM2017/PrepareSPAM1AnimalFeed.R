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

pathSPAM <- 'SPAM2017'
#From SPAM documentation: *_TA	all technologies together, ie complete crop; *_TI	irrigated portion of crop; *_TH	rainfed high inputs portion of crop; *_TL	rainfed low inputs portion of crop; *_TS	rainfed subsistence portion of crop; *_TR	rainfed portion of crop (= TA - TI, or TH + TL + TS)
#end of file name should be physical area_cropname_a -> last a standing for all tech together.
filesSPAM <- list.files(path = pathSPAM, pattern = "_A.tif$", full.names = T)



stSPAM <- stack(filesSPAM)



###Calculate non-feed crops proportion from SPAM model.
#@Fill NAs of SPAM layers? At the moment all crops are assumed to be animal digestable if NA
tmpNonFeed <- toupper(c("acof", "rcof", "coco", "teas", "toba", "oilp", "cnut", "ooil", "trof", "temf", "rest", "ofib", "pota", "bana", "sugc", "cott")) #- coffee, coco, tea, tobacco, oil palm, coconut, other oil, sugarcane, tropical fruit, temperate fruit
tmpNonFeedIndex <- grep(pattern = paste(tmpNonFeed, collapse = "|"), names(stSPAM))
iSPAMtotalArea <- overlay(stSPAM, fun = sum)

iSPAMnonFeedArea <- overlay(stSPAM[[tmpNonFeedIndex]], fun = sum)

iSPAMnonFeedFrac <- (iSPAMnonFeedArea / iSPAMtotalArea)

iSPAMnonFeedFrac <- reclassify(iSPAMnonFeedFrac, cbind(NA, NA, 0), right=FALSE) # Replace missing values with 0
iSPAMAnimalDigestCropFrac <- 1 - iSPAMnonFeedFrac

iSPAMAnimalDigestCropFrac <- writeRaster(iSPAMAnimalDigestCropFrac, 'animal_digest_frac.tif', overwrite = T)
