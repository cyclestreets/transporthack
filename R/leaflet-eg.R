library(leaflet)
library(geojsonio)

arrivals = geojson_read("geodata/top-7-arrivals.geojson", what = "sp")
sub_10k_car = geojson_read("geodata/rnet-car-journeys-sub10k.geojson", what = "sp")
current_cycling = geojson_read("geodata/rnet-cycle-journeys.geojson", what = "sp")
core_net = geojson_read("geodata/rnet_lakes.geojson", what = "sp")
boundary = geojson_read("geodata/ld-local-authority.geojson", what = "sp")

bus_net = geojson_read("geodata/rnet-bus-journeys.geojson", what = "sp")
bus_stops = geojson_read("geodata/busstops.geojson", what = "sp")
norm_hire = geojson_read("geodata/bicyclehirefromOSM.geojson", what = "sp")
e_hire = geojson_read("geodata/electricbicyclenetwork.geojson", what = "sp")
photos = geojson_read("geodata/photomap.geojson", what = "sp")
rail= geojson_read("geodata/railwaystations.geojson", what = "sp")
viewpoints = e_hire = geojson_read("geodata/viewpoints.geojson", what = "sp")


m = leaflet() %>%
  addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png") %>% 
  addPolylines(data = boundary, group = "Boundary")%>%
  addPolylines(data = core_net, weight = core_net$n, color = "blue", opacity = 0.3, group = "network" )%>%
  addPolylines(data = sub_10k_car, weight = sub_10k_car$CarJourneys, color = "blue", opacity = 0.3, group = "Replacable car trips" )%>%
  addPolylines(data = current_cycling, weight = current_cycling$CycleJourneys, color = "blue", opacity = 0.3, group = "Current Cycling" )%>%
  addCircleMarkers(data = arrivals, radius = arrivals$Arrivals / mean(arrivals$Arrivals)* 3)%>%
  addCircleMarkers(data = norm_hire, color = "red")%>%
  hideGroup ("Boundary")%>%
  addLayersControl(
      baseGroups = c("network", "Replacable car trips", "Current Cycling"),
      overlayGroups = c("Boundary"),
      options = layersControlOptions(collapsed = FALSE)
  )
m



old = setwd("public_html/") # switch working directory
htmlwidgets::saveWidget(m, selfcontained = T, file = "map-outline.html")
setwd(old) # back to old
