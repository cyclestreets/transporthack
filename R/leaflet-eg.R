library(leaflet)

cents = geojson_read("geodata/top-7-arrivals.geojson", what = "sp")

m = leaflet() %>%
  addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png") %>% 
  addPolygons(data = ld, fillColor = "red") %>% 
  # addMarkers(data = cents)
  addCircleMarkers(data = cents, radius = cents$Arrivals / mean(cents$Arrivals)* 3)

old = setwd("public_html/") # switch working directory
htmlwidgets::saveWidget(m, selfcontained = T, file = "map-outline.html")
setwd(old) # back to old
