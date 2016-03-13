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

sel3 = f$dist < 10000 

sel3df <- data.frame(sel3)

fc = f[sel3 == TRUE,]

class(sel3df)

plot(fc)

rf = line2route(l = fc, plan = "fastest")

rf@data

nrow(rf)
row.names(fc)
row.names(rf)
row.names(fc) %in% row.names(rf)
sel_true_false = !row.names(fc) %in% row.names(rf)
sel_n = which(sel_true_false)
fcs = fc[- sel_n,]
nrow(fcs)

fcs2 = fc[row.names(fc) %in% row.names(rf),]
summary(fcs2@data)
nrow(fcs2)
identical(fcs, fcs2)

rf@data <- cbind(rf@data, fcs2@data)
plot(rf$CarTravellers, fcs$CarTravellers)
rnet = overline(sldf = rf, attrib = "CarJourneys", fun = sum)
nrow(rnet)
names(rnet)
m = mapview::mapview(rnet, lwd = rnet$CarJourneys / mean(rnet$CarJourneys))@map

library(htmlwidgets)

saveWidget(m, "/public_html/map-car-journeys-sub10k-net.html")

geojson_write(rnet, file = "geodata/rnet-car-journeys-sub10k.geojson")



