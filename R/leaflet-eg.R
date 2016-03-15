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
viewpoints = geojson_read("geodata/viewpoints.geojson", what = "sp")
hostels = geojson_read("geodata/hostels.geojson", what = "sp")

o = 0.8

m = leaflet() %>%
  setView(lng = -2.8745246, lat = 54.3029315, zoom = 10) %>%
  addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png") %>% 
  addPolylines(data = boundary, color = "blue", opacity = o, group = "Boundary")%>%
  addPolylines(data = bus_net, color = "green", opacity = o, group = "Bus Network")%>%
  addPolylines(data = core_net, weight = core_net$n, color = "blue", opacity = 0.3, group = "network" )%>%
  addPolylines(data = sub_10k_car, weight = sub_10k_car$CarJourneys, color = "blue", opacity = 0.3, group = "Replacable car trips", popup = sub_10k_car$CarJourneys)%>%
  addPolylines(data = current_cycling, weight = current_cycling$CycleJourneys, color = "blue", opacity = 0.3, group = "Current Cycling", popup = current_cycling$CycleJourneys)%>%
  addCircleMarkers(data = arrivals, color = "purple", opacity = o, radius = arrivals$Arrivals / mean(arrivals$Arrivals)* 3, popup = arrivals$Name)%>%
  addCircleMarkers(data = norm_hire, color = "red", opacity = o, radius = 3, group = "Existing Hire")%>%
  addCircleMarkers(data = bus_stops, color = "green", opacity = o, radius = 3, group = "Bus Stops")%>%
  addCircleMarkers(data = e_hire, color = "orange", opacity = o, radius = 3, group = "E Bike Hire")%>%
  addCircleMarkers(data = rail, color = "black", opacity = o, radius = 3, group = "Rail station", popup = rail$name)%>%
  addCircleMarkers(data = viewpoints, color = "pink", opacity = o, radius = 3, group = "View points")%>%
  addCircleMarkers(data = hostels, color = "yellow", opacity = o, radius = 3,  group = "Hostels", popup = hostels$name)%>%
  addCircleMarkers(data = photos, color = "darkblue", opacity = o, radius = 3,  group = "Photos")%>%
  hideGroup ("Existing Hire")%>%
  hideGroup ("Bus Stops")%>%
  hideGroup ("E Bike Hire")%>%
  hideGroup ("Rail station")%>%
  hideGroup ("View points")%>%
  hideGroup ("Hostels")%>%
  hideGroup ("Bus Network")%>%
  hideGroup ("Photos")%>%
  addLayersControl(
      baseGroups = c("network", "Replacable car trips", "Current Cycling"),
      overlayGroups = c("Boundary","Bus Stops","Bus Network","Rail station","Existing Hire","E Bike Hire","View points","Hostels","Photos"),
      options = layersControlOptions(collapsed = FALSE)
  )
m



old = setwd("public_html/") # switch working directory
htmlwidgets::saveWidget(m, selfcontained = T, file = "rleaflet.html")
setwd(old) # back to old
