library(shiny)
library(leaflet)


# shinyUI(fluidPage(
#   leafletOutput("map", height="1200")
#   )
# )
shinyUI(
  navbarPage(
    title = "Transport Hackathon - Carplus", id="nav",
    tabPanel(
      "Interactive map",
      div(
        class="outer",
        br(),
        leafletOutput("map")#, width="100%", height="95%")
        
      )
    )
  )
)
