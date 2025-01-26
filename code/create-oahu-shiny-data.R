# Data downloaded from: https://geoportal.hawaii.gov/datasets/cchnl::elevation-1/about
oahu <- sf::read_sf(here::here("data", "oahu-elevation.zip")) |>
  dplyr::rename(contour = ELEVATION_FT, geometry = SHAPE) |>
  sf::st_transform(4326)

oahu_20ft <- oahu |>
  dplyr::filter(contour %in% seq(20, 4040, by = 20)) |>
  rmapshaper::ms_simplify(sys = TRUE, quiet = TRUE) |>
  dplyr::filter(!sf::st_is_empty(geometry))

oahu_20ft |>
  qs::qsave(here::here("data", "oahu-shiny.qs"))
