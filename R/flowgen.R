# Create OD flow data

library(stplanr)

odf = read.csv("data/od-summary.csv")
cents = geojson_read("geodata/uk-origins.geojson", what = "sp")
cents$cents_all = as.character(cents$cents_all)
cents$cents_all[is.na(cents$lat)]
names(cents)
names(odf)
odf = odf[c(3, 4, 1, 2, 5:ncol(odf))]
head(odf[1:5])
odf$StartDestName[is.na(odf$StartDestName)]
odf = odf[!is.na(odf$StartDestName),]
odf$StartDestName
odf$StartDestName[is.na(odf$EndDestName)]

# subset odf to only include names in cents
self = odf$StartDestName %in% cents$cents_all 
seld = odf$EndDestName %in% cents$cents_all
sum(sel)
odf$StartDestName[!self]
odf$EndDestName[!seld]
odf = odf[self & seld,]

cents = spTransform(cents, CRS("+init=epsg:4326"))

f = od2line(odf, cents)
plot(f, lwd = f$CarJourneys / mean(f$CarJourneys))
mapview(f, lwd = f$CarJourneys / mean(f$CarJourneys))
mapview(f, lwd = f$CycleJourneys / mean(f$CycleTarvellers))

geojson_write(f, file = "data/flows.geojson")

# Identify largest destinations