library(geojsonio)
library(sp)
library(stplanr)


f = geojson_read("geodata/flows.geojson", what = "sp")

sel = f$CarTarvellers > 0

f = f[sel,]

max = nrow(f)

origin = seq(1, max * 2, 2)

dest = seq(2, max * 2, 2)

p = line2points(f)

f$dist = geosphere::distHaversine(p1 = p[origin,], p2 = p[dest,])

hist(f$dist)

sel3 = f$dist < 10000 

sel3df <- data.frame(sel3)

fc = f[sel3 == TRUE,]

class(sel3df)

plot(fc)
  
mapview::mapview(fc, lwd = fc$CarTarvellers / mean(fc$CarTarvellers))@map

htmlwidgets::saveWidget(m, file = "public_html/cars_under10km.html")

geojson_write(rnet, file = "geodata/rnet-car-journeys-under10km.geojson")



