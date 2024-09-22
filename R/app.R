library(shiny)
library(shiny.fluent)
library(semantic.dashboard)
library(mapgl)


ui <- dashboardPage(
  dashboardHeader(title = "Species map"),
  dashboardSidebar(
    sidebarMenu(
      menuItem(tabName = "hope", text = "Map page", icon = icon("map")),
      menuItem(tabName = "desc", text = "Description", icon = icon("file alternate"))
    )
  ),
  
  dashboardBody(
    fluidRow(
        maplibreOutput("map", height = "700px")
    )
  )

)


server <- function(input, output) {
  
  output$map <- renderMaplibre({
    maplibre(style = carto_style("positron"))
      # fit_bounds(nc, animate = FALSE) |> 
      # add_fill_layer(id = "nc_data",
      #                source = nc,
      #                fill_color = "blue",
      #                fill_opacity = 0.5)
  })

}

shinyApp(ui, server)
