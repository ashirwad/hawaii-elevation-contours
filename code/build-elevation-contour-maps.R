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
        htmltools::tags$span(style = "font-size: 60px; display: block; font-weight: bold;", paste0(island_name, " Island")),
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


# Download contour data --------------------------------------------------------
contour_data <- tibble::tibble(
  island_name = c("Hawaii", "Kahoolawe", "Kauai", "Lanai", "Maui", "Molokai", "Niihau", "Oahu")
) |>
  dplyr::mutate(
    elevation = purrr::map(
      island_name,
      ~ sf::read_sf(
        glue::glue(
          "/vsizip//vsicurl/https://files.hawaii.gov/dbedt/op/gis/data/{island_abb}cntrs100.shp.zip",
          island_abb = stringr::str_sub(.x, 1, 3) |> stringr::str_to_lower()
        )
      ) |>
        dplyr::select(contour) |>
        sf::st_transform(4326) # WGS84
    ),
    elevation_simplified = purrr::map(
      elevation,
      ~ rmapshaper::ms_simplify(.x, keep = 0.1, sys = TRUE, quiet = TRUE) |>
        dplyr::filter(!sf::st_is_empty(geometry))
    ),
    pct_retained = purrr::map2(
      elevation, elevation_simplified, ~ round(nrow(.y) / nrow(.x) * 100, 2)
    )
  )


