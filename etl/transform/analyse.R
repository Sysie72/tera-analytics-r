# ========================================
# TRANSFORM : Analyse et calculs
# ========================================

#' Ajoute les features temporelles
#'
#' @param df DataFrame avec colonne time (POSIXct)
#'
#' @return DataFrame avec colonnes ajoutées : hour, month, date
#'
#' @importFrom dplyr mutate
#' @importFrom lubridate hour month as_date
#' @export
ajouter_features_temporelles <- function(df) {
  df %>%
    dplyr::mutate(
      hour = lubridate::hour(time),
      month = lubridate::month(time),
      date = lubridate::as_date(time)
    )
}

#' Moyenne PM2.5 par jour (agrégée sur tous les capteurs)
#'
#' @param df DataFrame avec colonnes id_sensor, date, pm25
#'
#' @return DataFrame avec colonnes : date, pm25_mean
#'
#' @importFrom dplyr group_by summarise ungroup
#' @export
moyenne_journaliere_ville <- function(df) {
  df %>%
    dplyr::group_by(id_sensor, date) %>%
    dplyr::summarise(pm25 = mean(pm25, na.rm = TRUE), .groups = "drop") %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(pm25_mean = mean(pm25, na.rm = TRUE), .groups = "drop")
}

#' Statistiques par capteur
#'
#' @param df DataFrame avec colonnes id_sensor, id_install, pm25
#'
#' @return DataFrame groupé par capteur avec stats
#'
#' @importFrom dplyr group_by summarise arrange desc
#' @export
stats_par_capteur <- function(df) {
  df %>%
    dplyr::group_by(id_sensor, id_install) %>%
    dplyr::summarise(
      count = dplyr::n(),
      mean = round(mean(pm25, na.rm = TRUE), 2),
      median = round(stats::median(pm25, na.rm = TRUE), 2),
      max = round(max(pm25, na.rm = TRUE), 2),
      .groups = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(mean))
}

#' Profil horaire
#'
#' @param df DataFrame avec colonnes hour, pm25
#'
#' @return DataFrame avec colonnes : hour, mean, sd
#'
#' @importFrom dplyr group_by summarise
#' @export
profil_horaire <- function(df) {
  df %>%
    dplyr::group_by(hour) %>%
    dplyr::summarise(
      mean = round(mean(pm25, na.rm = TRUE), 2),
      sd = round(stats::sd(pm25, na.rm = TRUE), 2),
      .groups = "drop"
    )
}

#' Profil mensuel
#'
#' @param df DataFrame avec colonnes month, pm25
#'
#' @return DataFrame avec colonnes : month, mean, sd
#'
#' @importFrom dplyr group_by summarise
#' @export
profil_mensuel <- function(df) {
  df %>%
    dplyr::group_by(month) %>%
    dplyr::summarise(
      mean = round(mean(pm25, na.rm = TRUE), 2),
      sd = round(stats::sd(pm25, na.rm = TRUE), 2),
      .groups = "drop"
    )
}

#' Conformité OMS
#'
#' @param moyenne_journaliere DataFrame avec colonne pm25_mean
#'
#' @return Liste avec statistiques OMS
#'
#' @export
conformite_oms <- function(moyenne_journaliere) {
  pm25 <- moyenne_journaliere$pm25_mean
  au_dessus_oms <- pm25 > SEUIL_OMS
  
  list(
    pm25_moyen = round(mean(pm25, na.rm = TRUE), 2),
    jours_au_dessus_oms = sum(au_dessus_oms, na.rm = TRUE),
    pct_au_dessus_oms = round(mean(au_dessus_oms, na.rm = TRUE) * 100, 1)
  )
}
