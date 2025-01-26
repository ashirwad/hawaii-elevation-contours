library(shiny)

# Map rendering function -------------------------------------------------------
map_elevation_contours <- function(contour_data,
                                   contour_var = "contour",
                                   colors = c("#440154FF", "#FDE725FF")) {
  contour_range <- contour_data[[contour_var]] |> range()

  mapgl::maplibre(style = mapgl::carto_style("dark-matter")) |>
    mapgl::fit_bounds(bbox = contour_data) |>
    mapgl::add_line_layer(
      id = "elevation_contours",
      source = contour_data,
      line_color = mapgl::interpolate(
        column = contour_var,
        values = contour_range,
        stops = colors
      )
    ) |>
    mapgl::add_legend(
      legend_title = "Elevation",
      values = contour_range,
      colors = colors
    )
}


# Data import ------------------------------------------------------------------
oahu <- qs::qread(here::here("data", "oahu-animation.qs"))
oahu_elevation_range <- oahu[["contour"]] |> range()


# CSS styles -------------------------------------------------------------------
css_styles <- "
  .slider-animate-button {
    background-color: transparent;
    border: 1px solid rgba(255, 255, 255, 0.5);
    border-radius: 4px;
    color: rgba(255, 255, 255, 0.8);
    padding: 4px 8px;
    margin-left: 8px;
  }
  .slider-animate-button:hover {
    background-color: rgba(255, 255, 255, 0.1);
  }
  .slider-animate-container {
    position: absolute;
    left: 175px;
    top: 30px;
  }
  .irs-min, .irs-max, .irs-single, .irs-from, .irs-to {
    font-size: 15px !important;
    color: rgba(255, 255, 255, 0.8) !important;
    background-color: transparent !important;
  }
  .control-label {
    font-size: 20px;
    color: rgba(255, 255, 255, 0.8);
  }
  .irs-bar, .irs-handle {
    background-color: #808080 !important;
    border-color: #808080 !important;
  }
  .irs-line {
    background-color: rgba(255, 255, 255, 0.2) !important;
  }
"

# UI definition ----------------------------------------------------------------
ui <- bslib::page(
  theme = bslib::bs_theme(preset = "darkly"),
  style = "height: 100vh; padding: 0;",
  tags$head(
    tags$style(HTML(css_styles))
  ),
  bslib::card(
    full_screen = TRUE,
    height = "100vh",
    bslib::card_header(
      class = "d-flex justify-content-between align-items-center",
      div(
        class = "shiny-input-container",
        style = "min-width: 300px;",
        sliderInput(
          "contour_val",
          "Animate contours",
          min = oahu_elevation_range[1],
          max = oahu_elevation_range[2],
          value = 20,
          step = 20,
          ticks = FALSE,
          animate = animationOptions(interval = 260)
        )
      ),
      div(
        class = "text-end",
        h2("Oahu (Hawaii)"),
        h3("Elevation ", textOutput("elevation_text", inline = TRUE))
      )
    ),
    mapgl::maplibreOutput("map", height = "calc(100vh - 90px)"),
    div(
      class = "position-absolute bottom-0 start-0 m-2",
      "Data source: geoportal.hawaii.gov"
    )
  )
)


# Server logic -----------------------------------------------------------------
server <- function(input, output, session) {
  output$map <- mapgl::renderMaplibre({
    map_elevation_contours(oahu)
  })

  observeEvent(input$contour_val, {
    mapgl::maplibre_proxy("map") |>
      mapgl::set_filter(
        "elevation_contours",
        list("<=", mapgl::get_column("contour"), input$contour_val)
      )
  })

  output$elevation_text <- renderText({
    paste0(format(input$contour_val, big.mark = ","), " ft")
  })
}


# Run app ----------------------------------------------------------------------
shinyApp(ui, server)
