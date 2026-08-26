# ========================================
# EXTRACT : Lecture du fichier CSV
# ========================================

#' Extraction des données brutes
#'
#' @param chemin Chemin du fichier CSV (défaut: FICHIER_CSV de config.R)
#'
#' @return DataFrame avec colonnes : time, id_sensor, id_install, pm1, pm25
#'
#' @importFrom readr read_csv
#' @importFrom dplyr mutate
#' @importFrom lubridate as_datetime
#'
#' @export
extraire <- function(chemin = NULL) {
  if (is.null(chemin)) {
    chemin <- FICHIER_CSV
  }
  
  cat(sprintf("%sExtracting data from %s...%s\n", COLOR_INFO, chemin, COLOR_RESET))
  
  df <- readr::read_csv(
    chemin,
    skip = 1,
    col_types = readr::cols(
      time = readr::col_datetime(),
      id_sensor = readr::col_character(),
      id_install = readr::col_character(),
      pm1 = readr::col_double(),
      pm25 = readr::col_double()
    )
  )
  
  cat(sprintf("%s✓ %d rows loaded%s\n", COLOR_SUCCESS, nrow(df), COLOR_RESET))
  return(df)
}
