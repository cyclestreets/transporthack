# Aim: find common likely pub. transport routes
sel = grep(pattern = "London|Blackpool|Leeds|Manchester|Glasgow|Lancaster", x = cents$Name)
origins = cents[sel,]
plot(origins)
origins$Name

ii = 1:length(origins)
rp = as.list(ii)
for(i in ii){
  # rp[[i]] = route_transportapi_public(from = origins[i,], to = "Windermere")
  if(i == 1)
    rpsp = rp[[i]] else
      rpsp = tmap::sbind(rpsp, rp[[i]])
}

plot(rpsp)

geojson_write(rpsp, file = "geodata/public-transport-routes.geojson")

m = mapview(rpsp, col = "black")
m = m@map

old = setwd("public_html/")
htmlwidgets::saveWidget(m, "public-transport-routes.html")
setwd(old)
