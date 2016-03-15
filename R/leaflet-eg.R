library(leaflet)
library(geojsonio)

arrivals = geojson_read("geodata/top-7-arrivals.geojson", what = "sp")
boundary = geojson_read("geodata/ld-local-authority.geojson", what = "sp")
core_net = geojson_read("geodata/rnet_lakes.geojson", what = "sp")

m = leaflet() %>%
  addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png") %>% 
  addPolylines(data = boundary, group = "Boundary")%>%
  addPolylines(data = core_net, weight = core_net$n, color = "red", opacity = 0.3, group = "network" )%>%
  addCircleMarkers(data = arrivals, radius = arrivals$Arrivals / mean(arrivals$Arrivals)* 3)%>%
  hideGroup ("Boundary")%>%
  addLayersControl(
      overlayGroups = c("network", "Boundary"),
      options = layersControlOptions(collapsed = FALSE)
  )
m



old = setwd("public_html/") # switch working directory
htmlwidgets::saveWidget(m, selfcontained = T, file = "map-outline.html")
setwd(old) # back to old
