# Aim: generate main 'entry point' data using od data saved using flowgen 

# starting point: od data
source("R/setup.R")

f = geojson_read("geodata/flows.geojson", what = "sp")
dest_data = group_by(f@data, EndDestName) %>% summarise(Arrivals = sum(TotalTravellers))
# sel = f$EndDestName %in% dest_data$EndDestName
ld = geojson_read("geodata/ld-local-authority.geojson", what = "sp")

cents = geojson_read("geodata/uk-origins.geojson", what = "sp")
names(cents)
names(cents)[1] = "Name"
head(cents@data)
names(dest_data)[1] = "Name"
names(dest_data)

cents@data = left_join(cents@data, dest_data)
cents$Arrivals[is.na(cents$Arrivals)] = 0
plot(cents)
sel = cents$Arrivals > 100
sum(sel)
cd = cents[sel,]
proj4string(cd) = proj4string(ld)
cd = cd[ld,]
nrow(cd)
plot(cd, cex = cd$Arrivals / mean(cd$Arrivals))
summary(cd$Arrivals)

cd@data

geojson_write(cd, file = "geodata/top-7-arrivals.geojson")

head(cents@data)

# sel = unique(f$EndDestName)
# sel = unique(sel)
# dest_lines = f[sel,]
# nrow(dest_lines)
# plot(dest_lines, add = T, col = "red") # subset with one destination
# sel = dest_data$Arrivals > 50
# sum(sel)
# plot(dest_lines[sel,], add = T, col = "green", lwd = 2)
# p = line2points(dest_lines)
# length(p)
# sel = seq(2, length(p), by = 2)
# sel2 = seq(1, length(p)-1, by = 2)
# pd = p[sel,]
# pd2 = p[sel2,]
# plot(p)
# plot(pd, add = T, col = "red")
# plot(pd2, add = T, col = "green")
