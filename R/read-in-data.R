# Aim: read in the entry points for the LD

# entry_points 


# Polygon of Lake District
source("R/setup.R")
# download.file("https://github.com/npct/pct-bigdata/raw/master/las-pcycle.geojson",
#               "las-pcycle.geojson")
# ld = geojson_read("las-pcycle.geojson", what = "sp")
# ld = ld[grep("Lake", ld$NAME),]
# plot(ld)
# 
# geojson_write(ld, file = "geodata/ld-local-authority.geojson")
ld = geojson_read("geodata/ld-local-authority.geojson", what = "sp")
bb(ld)

bbs = bbox_to_string(bbox(ld))
writeLines(bbs, "data/ld-bb-string")
bbp = as(raster::extent(bbox(ld)), "SpatialPolygons")
geojson_write(bbp, file = "geodata/ld-local-authority-bbox.geojson")

# Get transport OD flows
library(stplanr)

# download.file(dest = "data/LD%20origin-destination%20summary.xls",
#               "https://www.dropbox.com/sh/jqizpxd7xk6uht2/AAA2h-e7dYf4cCzxsL1GhLPWa/Carplus/LD%20origin-destination%20summary.xls?dl=1")
# odf = readxl::read_excel("data/LD%20origin-destination%20summary.xls")
# write.csv(odf, "data/od-summary.csv")
odf = read.csv("data/od-summary.csv")

cents = geojson_read("geodata/locations.geojson", what = "sp")
plot(cents)
summary(cents$Name %in% odf$StartDestName)
summary(cents$Name %in% odf$EndDestName)

cents$Name[cents$Name %in% odf$EndDestName]
cents$Name[!cents$Name %in% odf$EndDestName]

odf$EndDestName %in% cents$Name

