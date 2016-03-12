library(maptools)
kmls <- getKMLcoordinates("../data/doc.kml")
foo = readOGR(file.choose(), "x")


tkml <- getKMLcoordinates(kmlfile=file.choose(), ignoreAltitude=T)
library(rgdal)
tkml = readOGR("private-data/doc.kml", "x")
#make polygon
p1 = Polygon(tkml)
#make Polygon class
p2 = Polygons(list(p1), ID = "drivetime")
#make spatial polygons class
p3= SpatialPolygons(list(p2),proj4string=CRS("+init=epsg:4326"))