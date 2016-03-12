Sys.getenv("CYCLESTREET")
# to set this, create .Renviron containing the line
# CYCLESTREET=...

library(geojsonio)

f = geojson_read("geodata/flows.geojson", what = "sp")
class(f)
plot(f, lwd = f$CarTarvellers / mean(f$CarTarvellers))

# only cyclists
sel = f$CycleTarvellers > 0
sum(sel) # we'll plan 31 routes

rf = line2route(l = f[sel,], plan = "fastest")
plot(rf)

rf@data

nrow(rf)

rf@data <- cbind(rf@data, f@data[sel,])
rnet = overline(sldf = rf, attrib = "CycleJourneys", fun = sum)
m = mapview(rnet, lwd = rnet$CycleJourneys)@map
dir.create("public_html")
library(htmlwidgets)
saveWidget(m, "map-cyclenet.html")
file.rename("map-cyclenet.html", "public_html/map-cyclenet.html")
file.rename("index.html", "public_html/index.html")
geojson_write(rnet, file = "geodata/rnet-cycle-journeys.geojson")


