# Aim: to store code not used for learning

# # Failed script to geocode locations (sorted by Matt)
#
cents = unique(odf$StartDestName)
cents2 = unique(odf$EndDestName)
summary(cents %in% cents2)
cents_all = unique(c(cents, cents2))
cents_all

latlong = ggmap::geocode(cents_all)
plot(latlong) # many outside the uk!
outside_uk = latlong$lon < -10 | latlong$lon > 3
outside_uk[is.na(outside_uk)] = TRUE
cents_all[outside_uk]

cents = cbind(cents_all, latlong)
cents = cents[!is.na(cents$cents_all),]
cents[cents$cents_all,]
cents$cents_all = as.character(cents$cents_all)
cents$cents_all[outside_uk] =
  paste0(cents$cents_all[outside_uk], ", UK")
# latlong2 = ggmap::geocode(cents$cents_all[outside_uk])
plot(latlong2)
cents$lon[outside_uk] = latlong2$lon
cents$lat[outside_uk] = latlong2$lat

cents$cents_all[cents$lon < -10]
cents = cents[!is.na(cents$lon),]
cents = cents[!cents$lon < -10,]


centsp = SpatialPointsDataFrame(
  coords = cbind(cents$lon, cents$lat), 
  data = cents, proj4string = CRS("+init=epsg:4326"))
plot(centsp)

library(mapview)
mapview(centsp)

geojson_write(centsp, file = "geodata/uk-origins.geojson")
