# Aim: read in the entry points for the LD

entry_points 


# Polygon of Lake District
library(geojsonio)
library(sp)
download.file("https://github.com/npct/pct-bigdata/raw/master/las-pcycle.geojson",
              "las-pcycle.geojson")
ld = geojson_read("las-pcycle.geojson", what = "sp")
ld = ld[grep("Lake", ld$NAME),]
plot(ld)

geojson_write(ld, file = "geodata/ld-local-authority.geojson")
