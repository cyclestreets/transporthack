# # # # # # # #
# shinyServer #
# # # # # # # #
library(rgdal)
# library(jsonlite)
library(geojsonio)
library(stplanr)

# busstops <- readOGR(dsn = "geodata/busstops.geojson", layer = "OGRGeoJSON")
# busstops <- spTransform(busstops, CRS("+init=epsg:4326 +proj=longlat"))


busstops <- readLines("../../geodata/busstops.geojson", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)

collisions <- readLines("../../geodata/collisions.geojson", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)

LA <- readLines("../../geodata/ld-local-authority.geojson", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)

LABBox <- readLines("../../geodata/ld-local-authority-bbox.geojson", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)

locations <- readLines("../../geodata/locations.geojson", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)

railstations <- readLines("../../geodata/railwaystations.geojson", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)

origins <- readLines("../../geodata/uk-origins.geojson", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)

viewpoints <- readLines("../../geodata/viewpoints.geojson", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)


# flows <- readLines("../../geodata/flows.geojson", warn = FALSE) %>%
#   paste(collapse = "\n") %>%
#   fromJSON(simplifyVector = FALSE)

rnet_bus <- geojson_read("../../geodata/rnet-bus-journeys.geojson", what = "sp")
rnet_cycle <- geojson_read("../../geodata/rnet-cycle-journeys.geojson", what = "sp")

shinyServer(function(input, output, session){
  
  output$map <- renderLeaflet({
    leaflet() %>%
      setView (lat = 54.093541670206079, lng = -3.241894452206347, zoom = 10) %>%
      addProviderTiles("Stamen.TonerLite",
                       options = providerTileOptions(noWrap = TRUE)) %>% 
      mapOptions(zoomToLimits = "first") %>% 
#       addGeoJSON(busstops, color = 1) %>%
#       addGeoJSON(collisions) %>%
      addPolylines(data = rnet_cycle, color = "red", popup = "hello world!") %>% #rnet_cycle$CycleJourneys) %>%
      addPolylines(data = rnet_bus, color = "green") #%>%
#       addGeoJSON(LABBox) #%>%
#       addGeoJSON(locations, color = "red") %>%
#       addGeoJSON(railstations, color = "green") %>%
#       addGeoJSON(origins) %>%
#       addGeoJSON(viewpoints)
    
    #       addPolygons(data = busstops, weight = 2, fillColor = "yellow")
  })
})
