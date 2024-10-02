library(shiny)
library(shiny.fluent)
library(semantic.dashboard)
library(mapgl)
library(spocc)
library(rgbif)
library(sf)

if (!exists("species_data")) {
  species_data <- spocc::occ(
    query = "Phascolarctos cinereus",
    from = "gbif",
    limit = 1000
    # geometry = sf_bbox(cat_ext)
  )
}

get_data <- function(x) {
  return(
    x$gbif$data[[1]]
  )
}
  
pnts <- sf::st_as_sf(get_data(species_data), coords = c("longitude", "latitude"), crs = 4326)
  

ui <- dashboardPage(
  dashboardHeader(title = "Species Dashboard"),
  dashboardSidebar(
    size = "",
    sidebarMenu(
      menuItem(tabName = "get", text = "Species detection", icon = icon("leaf")),
      menuItem(tabName = "mapage", text = "Map page", icon = icon("map")),
      menuItem(tabName = "desc", text = "Description", icon = icon("file alternate"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "get",
        DefaultButton.shinyInput(
          inputId = ("button_1"),
          text = "Get species",
          primary = FALSE,
          split = TRUE,
          splitButtonAriaLabel = "See 2 options",
          `aria-roledescription` = "split button",
          # menuProps = menuProps,
          disabled = FALSE,
          checked = FALSE
        )
      ),
      tabItem(
        tabName = "mapage",
        fluidRow(
          mapboxglOutput("map", height = "700px")
        )
      ),
      tabItem(
        tabName = "desc",
        h2("Description page"),
      )
    )
  )

)


server <- function(input, output) {
  
  output$map <- renderMapboxgl({
    mapboxgl() |>
      fit_bounds(pnts, animate = FALSE) |>
      add_circle_layer(
        id = "sp_data",
        circle_color = "black",
        source = pnts,
      )
  })

}

shinyApp(ui, server)
