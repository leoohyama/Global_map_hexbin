#This is the script used to generate the hexbin polygon, post-processing was done in QGIS

library(dggridR)
library(dplyr)
library(rgdal)
library(sf)
library(FRK)


#'we use the area argument to set up the cell size we want (in this case ~ 630,000 square kilometers)
#'Note here that we use the round down to the nearest pre-determined cell size metric because
#'the package only provides pre-set resolution of hexbins, in this case 630,000 square km is closest
#'to resolution "4"
dggs<- dgconstruct(area = 630000, metric=FALSE, resround='down')

#this shows the list of resolutions and their areas:
dginfo(dggs) 

#code below starts the conversion to polygon file format for later export
global <- dgearthgrid(dggs, frame=FALSE)
global.cell <- data.frame(cell=getSpPPolygonsIDSlots(global), row.names=getSpPPolygonsIDSlots(global))
global <- SpatialPolygonsDataFrame(global, global.cell)

for(i in 1:length(global@polygons)) {
  if(max(global@polygons[[i]]@Polygons[[1]]@coords[,1]) - 
     min(global@polygons[[i]]@Polygons[[1]]@coords[,1]) > 180) {
    global@polygons[[i]]@Polygons[[1]]@coords[,1] <- (global@polygons[[i]]@Polygons[[1]]@coords[,1] +360) %% 360
  }
}

setwd("directory you want") #set directory where you want to export shape file to
writeOGR(global,"directory you want",layer = "name_of layer", driver ="ESRI Shapefile")
#st_write(fortify(global),"~/Desktop/", "holyshit",driver="ESRI Shapefile") 

#test by reading it back into R and plotting it
grid <- st_read("~/directory you want/name_of layer.shp")
plot(grid)

#' Note you can include the shapefile into QGIS to get rid of unnecessary bins and for
#' re-projection if needed
