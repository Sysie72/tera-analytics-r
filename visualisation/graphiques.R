# ========================================
# VISUALISATION : Graphiques individuels
# ========================================

#' Configuration du style ggplot2
#'
#' @importFrom ggplot2 theme_minimal theme element_text
#' @export
style_plot <- function() {
  ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 12, face = "bold"),
      axis.title = ggplot2::element_text(size = 10),
      axis.text = ggplot2::element_text(size = 9)
    )
}

#' Graphique : Profil horaire
#'
#' @param profil_horaire DataFrame avec colonnes hour, mean
#' @param seuil_oms Seuil OMS à afficher (défaut: SEUIL_OMS)
#'
#' @return ggplot object
#'
#' @importFrom ggplot2 ggplot aes geom_line geom_hline labs
#' @export
graphique_profil_horaire <- function(profil_horaire, seuil_oms = SEUIL_OMS) {
  ggplot2::ggplot(profil_horaire, ggplot2::aes(x = hour, y = mean)) +
    ggplot2::geom_line(color = "#1f77b4", size = 1) +
    ggplot2::geom_point(color = "#1f77b4", size = 2) +
    ggplot2::geom_hline(yintercept = seuil_oms, color = "red", linetype = "dashed", 
                        label = sprintf("OMS (%.0f µg/m³)", seuil_oms)) +
    ggplot2::labs(
      title = "Cycle diurne — Antananarivo",
      x = "Heure",
      y = "PM2.5 (µg/m³)"
    ) +
    style_plot()
}

#' Graphique : Profil mensuel
#'
#' @param profil_mensuel DataFrame avec colonnes month, mean
#' @param seuil_oms Seuil OMS à afficher (défaut: SEUIL_OMS)
#'
#' @return ggplot object
#'
#' @importFrom ggplot2 ggplot aes geom_col geom_hline scale_x_continuous labs
#' @export
graphique_profil_mensuel <- function(profil_mensuel, seuil_oms = SEUIL_OMS) {
  mois_labels <- c("Jan", "Fév", "Mar", "Avr", "Mai", "Jun", 
                   "Jul", "Aoû", "Sep", "Oct", "Nov", "Déc")
  
  ggplot2::ggplot(profil_mensuel, ggplot2::aes(x = month, y = mean)) +
    ggplot2::geom_col(fill = "#2ca02c") +
    ggplot2::geom_hline(yintercept = seuil_oms, color = "red", linetype = "dashed") +
    ggplot2::scale_x_continuous(
      breaks = 1:12,
      labels = mois_labels
    ) +
    ggplot2::labs(
      title = "Variation saisonnière — Antananarivo",
      x = "Mois",
      y = "PM2.5 (µg/m³)"
    ) +
    style_plot()
}

#' Graphique : Top capteurs
#'
#' @param stats DataFrame avec colonnes id_sensor, id_install, mean
#' @param top Nombre de capteurs à afficher (défaut: 8)
#' @param seuil_oms Seuil OMS à afficher (défaut: SEUIL_OMS)
#'
#' @return ggplot object
#'
#' @importFrom ggplot2 ggplot aes geom_col coord_flip geom_vline labs
#' @importFrom dplyr slice
#' @export
graphique_capteurs <- function(stats, top = 8, seuil_oms = SEUIL_OMS) {
  top_stats <- stats %>%
    dplyr::slice(1:min(top, nrow(stats))) %>%
    dplyr::mutate(label = paste0(id_sensor, " (", id_install, ")"))
  
  ggplot2::ggplot(top_stats, ggplot2::aes(x = reorder(label, mean), y = mean)) +
    ggplot2::geom_col(fill = "#ff7f0e") +
    ggplot2::geom_vline(xintercept = seuil_oms, color = "red", linetype = "dashed") +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "Top capteurs les plus pollués",
      x = "",
      y = "PM2.5 moyen (µg/m³)"
    ) +
    style_plot()
}

#' Graphique : Série temporelle
#'
#' @param moyenne_journaliere DataFrame avec colonnes date, pm25_mean
#' @param seuil_oms Seuil OMS à afficher (défaut: SEUIL_OMS)
#'
#' @return ggplot object
#'
#' @importFrom ggplot2 ggplot aes geom_line geom_hline labs
#' @export
graphique_serie_temporelle <- function(moyenne_journaliere, seuil_oms = SEUIL_OMS) {
  ggplot2::ggplot(moyenne_journaliere, ggplot2::aes(x = date, y = pm25_mean)) +
    ggplot2::geom_line(color = "#d62728", size = 0.8) +
    ggplot2::geom_hline(yintercept = seuil_oms, color = "red", linetype = "dashed") +
    ggplot2::labs(
      title = "Évolution journalière — Antananarivo",
      x = "Date",
      y = "PM2.5 moyen (µg/m³)"
    ) +
    style_plot()
}

#' Graphique : Distribution
#'
#' @param df DataFrame avec colonne pm25
#'
#' @return ggplot object
#'
#' @importFrom ggplot2 ggplot aes geom_histogram geom_vline labs
#' @export
graphique_distribution <- function(df) {
  p95 <- stats::quantile(df$pm25, 0.95, na.rm = TRUE)
  moyenne <- mean(df$pm25, na.rm = TRUE)
  
  ggplot2::ggplot(df, ggplot2::aes(x = pm25)) +
    ggplot2::geom_histogram(bins = 40, fill = "#9467bd", alpha = 0.8, color = "black") +
    ggplot2::geom_vline(xintercept = moyenne, color = "black", linetype = "dashed", 
                        label = "Moyenne") +
    ggplot2::geom_vline(xintercept = p95, color = "darkorange", linetype = ":", 
                        label = sprintf("P95 (%.1f)", p95)) +
    ggplot2::labs(
      title = "Distribution des concentrations PM2.5",
      x = "PM2.5 (µg/m³)",
      y = "Fréquence"
    ) +
    style_plot()
}
