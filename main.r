## Geo-scripting
## Lesson 6
## Exercise
## Joris Wever
## Erwin van den Berg
## 11-01-16

# libraries
library(rgdal)
library(rgeos)

# make railways a SpatialLinesDataFrame
railways <- (list.files(path = "data/", pattern = glob2rx('railways.*'), full.names = FALSE))
dsn = file.path("data", railways[3])
ogrListLayers(dsn)
my_railways <- readOGR(dsn, layer = ogrListLayers(dsn))

# make railways a SpatialLinesDataFrame
places <- (list.files(path = "data/", pattern = glob2rx('places.*'), full.names = FALSE))
dsn1 = file.path("data", places[3])
ogrListLayers(dsn1)
my_places <- readOGR(dsn1, layer = ogrListLayers(dsn1))

# step 1: select the "industrial" railways
industrial_rws <- subset(my_railways, type == "industrial")

# step 2: buffer the "industrial" railways with a buffer
# of 1000m
prj_string_RD <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs")
ind_rw_RD <- spTransform(industrial_rws, prj_string_RD)
ind_rw_buff <- gBuffer(ind_rw_RD, byid=TRUE, width=1000, quadsegs = 25)

# step 3.1: find the place that intersects with this buffer
my_places_RD <- spTransform(my_places, prj_string_RD)
place_intersect <- gIntersection(ind_rw_buff, my_places_RD, byid=TRUE)

# step 3.2: gather information about the intersecting point
rowID <- row.names(place_intersect)
rowID_2 <- strsplit(rowID, split = ' ')
lookup_ID <- rowID_2[[1]][2]

intersect_pnt <- my_places_RD[Lookup_ID,]

city_name = as.character(intersect_pnt$name)
city_population = as.character(intersect_pnt$population)

# step 4: create a plot that shows the buffer, the points and the name of the city
plot(ind_rw_buff, col='grey', axes=TRUE)
plot(place_intersect, col='blue', add=TRUE)
box()
text(place_intersect, labels=city_name)

# step 5: write down the name of the city and the population of that city as one comment at the end of the script
sprintf('The intersecting city is %s.', city_name)
sprintf('This city has a population of %s.', city_population)
