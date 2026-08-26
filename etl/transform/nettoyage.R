# ========================================
# TRANSFORM : Nettoyage des données
# ========================================

#' Supprime les valeurs invalides
#'
#' Supprime les valeurs négatives et les incohérences PM1 > PM2.5
#'
#' @param df DataFrame avec colonnes pm1 et pm25
#'
#' @return DataFrame nettoyé
#'
#' @importFrom dplyr filter
#' @export
supprimer_valeurs_invalides <- function(df) {
  df %>%
    dplyr::filter(pm1 >= 0, pm25 >= 0) %>%
    dplyr::filter(pm1 <= pm25)
}

#' Supprime les outliers
#'
#' Supprime les valeurs extrêmes au-delà du percentile configuré
#'
#' @param df DataFrame avec colonne pm25
#' @param percentile Percentile limite (défaut: PERCENTILE_OUTLIERS)
#'
#' @return DataFrame sans outliers
#'
#' @importFrom dplyr filter
#' @importFrom stats quantile
#' @export
supprimer_outliers <- function(df, percentile = PERCENTILE_OUTLIERS) {
  seuil <- stats::quantile(df$pm25, percentile, na.rm = TRUE)
  dplyr::filter(df, pm25 <= seuil)
}

#' Pipeline de nettoyage complet
#'
#' @param df DataFrame brut
#'
#' @return DataFrame nettoyé
#'
#' @export
nettoyer <- function(df) {
  n_initial <- nrow(df)
  
  df <- supprimer_valeurs_invalides(df)
  df <- supprimer_outliers(df)
  
  cat(sprintf("%sNettoyage : %d → %d lignes%s\n", COLOR_SUCCESS, n_initial, nrow(df), COLOR_RESET))
  
  return(df %>% dplyr::distinct())
}
