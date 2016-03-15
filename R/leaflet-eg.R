library(leaflet)

m = leaflet() %>%
  addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png") %>% 
  addPolygons(data = ld, fillColor = "red")

old = setwd("public_html/") # switch working directory
htmlwidgets::saveWidget(m, selfcontained = T, file = "map-outline.html")
setwd(old) # back to old
