Sys.getenv("CYCLESTREET")
# to set this, create .Renviron containing the line
# CYCLESTREET=...

library(geojsonio)
library(mapview)

f = geojson_read("geodata/flows.geojson", what = "sp")
class(f)
plot(f, lwd = f$BusJourneys / mean(f$BusJourneys))

# only cyclists
sel = f$BusTarvellers > 0
sum(sel) # we'll plan 31 routes

rf = line2route(l = f[sel,], plan = "fastest")
class(rf)
plot(rf)

rf@data

nrow(rf)

rf@data <- cbind(rf@data, f@data[sel,])
rnet = overline(sldf = rf, attrib = "CycleJourneys", fun = sum)
mapview(rnet, lwd = rnet$CycleJourneys)
geojson_write(rnet, file = "geodata/rnet-bus-journeys.geojson")
