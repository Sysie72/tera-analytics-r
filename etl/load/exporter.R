# ========================================
# LOAD : Export des données
# ========================================

#' Export des données transformées en CSV
#'
#' @param df DataFrame nettoyé
#' @param moyenne_journaliere DataFrame avec moyennes journalières
#'
#' @return Chemin du répertoire d'export
#'
#' @importFrom readr write_csv
#' @export
exporter <- function(df, moyenne_journaliere) {
  dir.create(PROCESSED_DIR, showWarnings = FALSE, recursive = TRUE)
  
  readr::write_csv(df, file.path(PROCESSED_DIR, "donnees_nettoyees.csv"))
  readr::write_csv(moyenne_journaliere, file.path(PROCESSED_DIR, "moyenne_journaliere.csv"))
  
  cat(sprintf("%s✓ Export successful to %s%s\n", COLOR_SUCCESS, PROCESSED_DIR, COLOR_RESET))
  
  return(PROCESSED_DIR)
}
