# Function to build elevation contour maps -------------------------------------
map_elevation_contours <- function(contour_data,
                                   island_name,
                                   contour_var = "contour",
                                   colors = c("#440154FF", "#FDE725FF")) {
  # Get contour range
  contour_range <- contour_data[[contour_var]] |> range()

  # Plot map
  map <- mapgl::maplibre(style = mapgl::carto_style("dark-matter")) |>
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

  # Adorn map
  map <- map |>
    htmlwidgets::prependContent(
      htmltools::tags$div(
        style = "position: absolute; top: 10px; right: 10px; z-index: 1000;
             color: lightgray; padding: 20px; font-family: 'Open Sans', sans-serif;
             border-radius: 5px; text-align: center; width: 200px;",
        htmltools::tags$span(style = "font-size: 60px; display: block; font-weight: bold;", island_name),
        htmltools::tags$span(style = "font-size: 40px; display: block; font-weight: bold;", "Hawaii")
      )
    ) |>
    htmlwidgets::prependContent(
      htmltools::tags$div(
        style = "position: absolute; bottom: 10px; left: 10px; z-index: 1000;
           color: lightgray; padding: 10px; font-family: 'Open Sans', sans-serif;
           border-radius: 5px;",
        htmltools::tags$span(style = "font-size: 14px;", "Data source: geoportal.hawaii.gov")
      )
    )

  # Return map
  map
}
