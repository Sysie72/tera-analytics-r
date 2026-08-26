# ========================================
# VISUALISATION : Dashboard complet
# ========================================

#' Dashboard complet — 9 graphiques
#'
#' @param df DataFrame nettoyé
#' @param stats DataFrame des stats par capteur
#' @param moyenne_journaliere DataFrame des moyennes journalières
#' @param seuil_oms Seuil OMS (défaut: SEUIL_OMS)
#'
#' @return ggplot object (combinaison de 9 graphiques)
#'
#' @importFrom ggplot2 ggplot aes geom_line geom_col geom_histogram facet_wrap
#' @importFrom patchwork plot_layout
#' @importFrom dplyr mutate slice
#' @export
graphique_dashboard <- function(df, stats, moyenne_journaliere, seuil_oms = SEUIL_OMS) {
  
  # Calculs préalables
  prof_horaire <- profil_horaire(df)
  prof_mensuel <- profil_mensuel(df)
  
  daily_exceedance_pct <- mean(moyenne_journaliere$pm25_mean > seuil_oms, na.rm = TRUE) * 100
  peak_hour <- prof_horaire$hour[which.max(prof_horaire$mean)]
  peak_month <- prof_mensuel$month[which.max(prof_mensuel$mean)]
  
  p95 <- stats::quantile(df$pm25, 0.95, na.rm = TRUE)
  
  mois_labels <- c("Jan", "Fév", "Mar", "Avr", "Mai", "Jun", 
                   "Jul", "Aoû", "Sep", "Oct", "Nov", "Déc")
  
  # 1. Profil horaire
  p1 <- ggplot2::ggplot(prof_horaire, ggplot2::aes(x = hour, y = mean)) +
    ggplot2::geom_line(color = "#1f77b4", size = 1) +
    ggplot2::geom_point(color = "#1f77b4", size = 2) +
    ggplot2::geom_hline(yintercept = seuil_oms, color = "red", linetype = "dashed") +
    ggplot2::labs(title = "Cycle diurne", x = "Heure", y = "PM2.5 (µg/m³)") +
    style_plot()
  
  # 2. Profil mensuel
  p2 <- ggplot2::ggplot(prof_mensuel, ggplot2::aes(x = month, y = mean)) +
    ggplot2::geom_col(fill = "#2ca02c") +
    ggplot2::geom_hline(yintercept = seuil_oms, color = "red", linetype = "dashed") +
    ggplot2::scale_x_continuous(breaks = 1:12, labels = mois_labels) +
    ggplot2::labs(title = "Variation saisonnière", x = "Mois", y = "PM2.5 (µg/m³)") +
    style_plot() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
  
  # 3. Série temporelle
  p3 <- ggplot2::ggplot(moyenne_journaliere, ggplot2::aes(x = date, y = pm25_mean)) +
    ggplot2::geom_line(color = "#d62728", size = 0.8) +
    ggplot2::geom_hline(yintercept = seuil_oms, color = "red", linetype = "dashed") +
    ggplot2::labs(title = "Évolution journalière", x = "Date", y = "PM2.5 moyen (µg/m³)") +
    style_plot()
  
  # 4. Top capteurs
  top_stats <- stats %>%
    dplyr::slice(1:min(8, nrow(stats))) %>%
    dplyr::mutate(label = paste0(id_sensor, " (", id_install, ")"))
  
  p4 <- ggplot2::ggplot(top_stats, ggplot2::aes(x = reorder(label, mean), y = mean)) +
    ggplot2::geom_col(fill = "#ff7f0e") +
    ggplot2::geom_vline(xintercept = seuil_oms, color = "red", linetype = "dashed") +
    ggplot2::coord_flip() +
    ggplot2::labs(title = "Top capteurs", x = "", y = "PM2.5 moyen (µg/m³)") +
    style_plot()
  
  # 5. Distribution
  moyenne <- mean(df$pm25, na.rm = TRUE)
  p5 <- ggplot2::ggplot(df, ggplot2::aes(x = pm25)) +
    ggplot2::geom_histogram(bins = 40, fill = "#9467bd", alpha = 0.8, color = "black") +
    ggplot2::geom_vline(xintercept = moyenne, color = "black", linetype = "dashed") +
    ggplot2::geom_vline(xintercept = p95, color = "darkorange", linetype = ":") +
    ggplot2::labs(title = "Distribution", x = "PM2.5 (µg/m³)", y = "Fréquence") +
    style_plot()
  
  # 6. Boxplot mensuel
  p6 <- ggplot2::ggplot(df, ggplot2::aes(x = factor(month), y = pm25)) +
    ggplot2::geom_boxplot(fill = "#8c564b") +
    ggplot2::scale_x_discrete(labels = mois_labels) +
    ggplot2::labs(title = "Variabilité mensuelle", x = "Mois", y = "PM2.5 (µg/m³)") +
    style_plot()
  
  # 7. Boxplot horaire
  p7 <- ggplot2::ggplot(df, ggplot2::aes(x = factor(hour), y = pm25)) +
    ggplot2::geom_boxplot(fill = "#17becf") +
    ggplot2::labs(title = "Variabilité horaire", x = "Heure", y = "PM2.5 (µg/m³)") +
    style_plot() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
  
  # 8. PM1 vs PM2.5
  p8 <- ggplot2::ggplot(df, ggplot2::aes(x = pm1, y = pm25)) +
    ggplot2::geom_point(alpha = 0.15, size = 1, color = "#17becf") +
    ggplot2::geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
    ggplot2::labs(title = "Relation PM1 vs PM2.5", x = "PM1 (µg/m³)", y = "PM2.5 (µg/m³)") +
    style_plot()
  
  # 9. Taux de dépassement mensuel
  monthly_exceedance <- df %>%
    dplyr::group_by(month) %>%
    dplyr::summarise(pct_depassement = mean(pm25 > seuil_oms, na.rm = TRUE) * 100, .groups = "drop")
  
  p9 <- ggplot2::ggplot(monthly_exceedance, ggplot2::aes(x = factor(month), y = pct_depassement)) +
    ggplot2::geom_col(fill = "#bcbd22") +
    ggplot2::scale_x_discrete(labels = mois_labels) +
    ggplot2::labs(title = "Taux de dépassement OMS", x = "Mois", y = "% dépassement") +
    style_plot() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
  
  # Combiner tous les graphiques avec patchwork
  dashboard <- (p1 | p2 | p3) / (p4 | p5 | p6) / (p7 | p8 | p9)
  
  return(dashboard)
}

#' Sauvegarder et afficher le dashboard
#'
#' @param dashboard ggplot object
#' @param nom Nom du fichier (défaut: "dashboard")
#' @param format Format de sauvegarde ("png" par défaut)
#' @param dpi Résolution (défaut: 200)
#'
#' @return Chemin du fichier sauvegardé
#'
#' @importFrom ggplot2 ggsave
#' @export
sauvegarder_dashboard <- function(dashboard, nom = "dashboard", format = "png", dpi = 200) {
  dir.create(OUTPUT_FIGS_DIR, showWarnings = FALSE, recursive = TRUE)
  
  chemin <- file.path(OUTPUT_FIGS_DIR, paste0(nom, ".", format))
  
  ggplot2::ggsave(chemin, dashboard, width = 22, height = 15, dpi = dpi, device = format)
  
  cat(sprintf("%s✓ Dashboard saved to %s%s\n", COLOR_SUCCESS, chemin, COLOR_RESET))
  
  return(chemin)
}
