library(geojsonio)
library(sp)
library(stplanr)

f = geojson_read("geodata/flows.geojson", what = "sp")

sel = f$CarTarvellers < 10

sum(sel)

rf = line2route(l = f[sel,], plan = "fastest")

