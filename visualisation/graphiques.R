# ========================================
# VISUALISATION : Graphiques individuels (1 PNG chacun)
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

#' Sauvegarder un graphique
#'
#' @param p ggplot object
#' @param nom Nom du fichier (sans extension)
#' @param largeur Largeur en pouces (défaut: 10)
#' @param hauteur Hauteur en pouces (défaut: 6)
#'
#' @return Chemin du fichier
#' @export
sauvegarder_graphique <- function(p, nom, largeur = 10, hauteur = 6) {
  dir.create(OUTPUT_FIGS_DIR, showWarnings = FALSE, recursive = TRUE)
  
  chemin <- file.path(OUTPUT_FIGS_DIR, paste0(nom, ".png"))
  ggplot2::ggsave(chemin, p, width = largeur, height = hauteur, dpi = 200)
  
  cat(sprintf("%s✓ Saved: %s%s\n", COLOR_SUCCESS, chemin, COLOR_RESET))
  
  return(chemin)
}

#' Graphique 1 : Profil horaire
#'
#' @param df DataFrame avec colonnes hour, pm25
#' @param seuil_oms Seuil OMS (défaut: SEUIL_OMS)
#'
#' @return ggplot object
#' @export
graphique_profil_horaire <- function(df, seuil_oms = SEUIL_OMS) {
  prof <- df %>%
    dplyr::group_by(hour) %>%
    dplyr::summarise(
      mean = round(mean(pm25, na.rm = TRUE), 2),
      sd = round(stats::sd(pm25, na.rm = TRUE), 2),
      .groups = "drop"
    )
  
  peak_hour <- prof$hour[which.max(prof$mean)]
  peak_value <- prof$mean[which.max(prof$mean)]
  
  ggplot2::ggplot(prof, ggplot2::aes(x = hour, y = mean)) +
    ggplot2::geom_line(color = "#1f77b4", linewidth = 1) +
    ggplot2::geom_point(color = "#1f77b4", size = 3) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = mean - sd, ymax = mean + sd), 
                         alpha = 0.2, fill = "#1f77b4") +
    ggplot2::geom_hline(yintercept = seuil_oms, color = "red", linetype = "dashed", 
                        linewidth = 1, label = sprintf("OMS (%.0f)", seuil_oms)) +
    ggplot2::annotate("text", x = peak_hour, y = peak_value + 2, 
                      label = sprintf("Pic: %.1f µg/m³", peak_value),
                      color = "#1f77b4", fontsize = 3) +
    ggplot2::labs(
      title = "1. Cycle Diurne — PM2.5 par Heure",
      x = "Heure de la journée",
      y = "PM2.5 (µg/m³)",
      subtitle = "Moyenne ± écart-type"
    ) +
    ggplot2::scale_x_continuous(breaks = seq(0, 23, 2)) +
    style_plot() +
    ggplot2::theme(legend.position = "top")
}

#' Graphique 2 : Profil mensuel
#'
#' @param df DataFrame avec colonnes month, pm25
#' @param seuil_oms Seuil OMS (défaut: SEUIL_OMS)
#'
#' @return ggplot object
#' @export
graphique_profil_mensuel <- function(df, seuil_oms = SEUIL_OMS) {
  mois_labels <- c("Jan", "Fév", "Mar", "Avr", "Mai", "Jun", 
                   "Jul", "Aoû", "Sep", "Oct", "Nov", "Déc")
  
  prof <- df %>%
    dplyr::group_by(month) %>%
    dplyr::summarise(
      mean = round(mean(pm25, na.rm = TRUE), 2),
      sd = round(stats::sd(pm25, na.rm = TRUE), 2),
      .groups = "drop"
    )
  
  peak_month <- prof$month[which.max(prof$mean)]
  peak_value <- prof$mean[which.max(prof$mean)]
  
  ggplot2::ggplot(prof, ggplot2::aes(x = month, y = mean, fill = mean)) +
    ggplot2::geom_col() +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = mean - sd, ymax = mean + sd), 
                           width = 0.3, color = "black", linewidth = 0.8) +
    ggplot2::geom_hline(yintercept = seuil_oms, color = "red", linetype = "dashed", 
                        linewidth = 1) +
    ggplot2::scale_x_continuous(breaks = 1:12, labels = mois_labels) +
    ggplot2::scale_fill_gradient(low = "#90EE90", high = "#FF6B6B") +
    ggplot2::annotate("text", x = peak_month, y = peak_value + 1.5, 
                      label = sprintf("Max: %s", mois_labels[peak_month]),
                      color = "black", fontsize = 3) +
    ggplot2::labs(
      title = "2. Variation Saisonnière — PM2.5 par Mois",
      x = "Mois",
      y = "PM2.5 moyen (µg/m³)",
      subtitle = "Barres = moyenne, Erreurs = écart-type"
    ) +
    style_plot() +
    ggplot2::theme(legend.position = "none", axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}

#' Graphique 3 : Série temporelle
#'
#' @param moyenne_journaliere DataFrame avec colonnes date, pm25_mean
#' @param seuil_oms Seuil OMS (défaut: SEUIL_OMS)
#'
#' @return ggplot object
#' @export
graphique_serie_temporelle <- function(moyenne_journaliere, seuil_oms = SEUIL_OMS) {
  ggplot2::ggplot(moyenne_journaliere, ggplot2::aes(x = date, y = pm25_mean)) +
    ggplot2::geom_line(color = "#d62728", linewidth = 0.8) +
    ggplot2::geom_point(data = moyenne_journaliere %>% 
                        dplyr::filter(pm25_mean > seuil_oms),
                        color = "red", size = 1, alpha = 0.5) +
    ggplot2::geom_hline(yintercept = seuil_oms, color = "red", linetype = "dashed", 
                        linewidth = 1) +
    ggplot2::labs(
      title = "3. Évolution Temporelle — Moyenne Journalière",
      x = "Date",
      y = "PM2.5 moyen (µg/m³)",
      subtitle = "Points rouges = jours dépassant le seuil OMS"
    ) +
    style_plot() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}

#' Graphique 4 : Top capteurs
#'
#' @param stats DataFrame avec colonnes id_sensor, id_install, mean
#' @param top Nombre de capteurs (défaut: 10)
#' @param seuil_oms Seuil OMS (défaut: SEUIL_OMS)
#'
#' @return ggplot object
#' @export
graphique_top_capteurs <- function(stats, top = 10, seuil_oms = SEUIL_OMS) {
  top_stats <- stats %>%
    dplyr::slice(1:min(top, nrow(stats))) %>%
    dplyr::mutate(label = paste0(id_sensor, "\n(", id_install, ")"))
  
  ggplot2::ggplot(top_stats, ggplot2::aes(x = reorder(label, mean), y = mean, fill = mean)) +
    ggplot2::geom_col() +
    ggplot2::geom_hline(yintercept = seuil_oms, color = "red", linetype = "dashed", 
                        linewidth = 1) +
    ggplot2::scale_fill_gradient(low = "#90EE90", high = "#FF6B6B") +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "4. Top 10 Capteurs les Plus Pollués",
      x = "Capteur (ID)",
      y = "PM2.5 moyen (µg/m³)",
      subtitle = "Ligne rouge = seuil OMS (15 µg/m³)"
    ) +
    style_plot() +
    ggplot2::theme(legend.position = "right")
}

#' Graphique 5 : Distribution
#'
#' @param df DataFrame avec colonne pm25
#'
#' @return ggplot object
#' @export
graphique_distribution <- function(df) {
  p95 <- stats::quantile(df$pm25, 0.95, na.rm = TRUE)
  p90 <- stats::quantile(df$pm25, 0.90, na.rm = TRUE)
  moyenne <- mean(df$pm25, na.rm = TRUE)
  
  ggplot2::ggplot(df, ggplot2::aes(x = pm25)) +
    ggplot2::geom_histogram(bins = 50, fill = "#9467bd", alpha = 0.7, color = "black") +
    ggplot2::geom_vline(xintercept = moyenne, color = "black", linetype = "dashed", 
                        linewidth = 1, label = sprintf("Moyenne: %.1f", moyenne)) +
    ggplot2::geom_vline(xintercept = p95, color = "darkorange", linetype = ":", 
                        linewidth = 1, label = sprintf("P95: %.1f", p95)) +
    ggplot2::geom_vline(xintercept = p90, color = "orange", linetype = ":", 
                        linewidth = 1, label = sprintf("P90: %.1f", p90)) +
    ggplot2::labs(
      title = "5. Distribution des Concentrations PM2.5",
      x = "PM2.5 (µg/m³)",
      y = "Fréquence",
      subtitle = "Lignes = moyennes et percentiles"
    ) +
    style_plot() +
    ggplot2::theme(legend.position = "top")
}

#' Graphique 6 : Boxplot mensuel
#'
#' @param df DataFrame avec colonnes month, pm25
#'
#' @return ggplot object
#' @export
graphique_boxplot_mensuel <- function(df) {
  mois_labels <- c("Jan", "Fév", "Mar", "Avr", "Mai", "Jun", 
                   "Jul", "Aoû", "Sep", "Oct", "Nov", "Déc")
  
  ggplot2::ggplot(df, ggplot2::aes(x = factor(month), y = pm25, fill = factor(month))) +
    ggplot2::geom_boxplot(alpha = 0.7) +
    ggplot2::scale_x_discrete(labels = mois_labels) +
    ggplot2::scale_fill_brewer(palette = "Set3") +
    ggplot2::labs(
      title = "6. Variabilité Mensuelle — Boxplots",
      x = "Mois",
      y = "PM2.5 (µg/m³)",
      subtitle = "Boîtes = IQR, Ligne = médiane, Points = outliers"
    ) +
    style_plot() +
    ggplot2::theme(legend.position = "none", axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}

#' Graphique 7 : Boxplot horaire
#'
#' @param df DataFrame avec colonnes hour, pm25
#'
#' @return ggplot object
#' @export
graphique_boxplot_horaire <- function(df) {
  ggplot2::ggplot(df, ggplot2::aes(x = factor(hour), y = pm25, fill = factor(hour))) +
    ggplot2::geom_boxplot(alpha = 0.7) +
    ggplot2::scale_fill_viridis_d() +
    ggplot2::labs(
      title = "7. Variabilité Horaire — Boxplots",
      x = "Heure de la journée",
      y = "PM2.5 (µg/m³)",
      subtitle = "Boîtes = IQR, Ligne = médiane, Points = outliers"
    ) +
    style_plot() +
    ggplot2::theme(legend.position = "none", axis.text.x = ggplot2::element_text(size = 7))
}

#' Graphique 8 : Relation PM1 vs PM2.5
#'
#' @param df DataFrame avec colonnes pm1, pm25
#'
#' @return ggplot object
#' @export
graphique_pm1_vs_pm25 <- function(df) {
  # Échantillon pour éviter surcharge
  sample <- df %>% dplyr::slice_sample(n = min(10000, nrow(df)))
  
  cor_val <- cor(sample$pm1, sample$pm25, use = "complete.obs")
  
  ggplot2::ggplot(sample, ggplot2::aes(x = pm1, y = pm25)) +
    ggplot2::geom_point(alpha = 0.1, size = 1, color = "#17becf") +
    ggplot2::geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed", 
                         linewidth = 1, label = "Diagonale") +
    ggplot2::geom_smooth(method = "lm", se = TRUE, color = "blue", fill = "lightblue", 
                         alpha = 0.2, linewidth = 1) +
    ggplot2::labs(
      title = "8. Relation PM1 vs PM2.5",
      x = "PM1 (µg/m³)",
      y = "PM2.5 (µg/m³)",
      subtitle = sprintf("Corrélation = %.3f | Ligne rouge = diagonale", cor_val)
    ) +
    style_plot()
}

#' Graphique 9 : Taux de dépassement mensuel
#'
#' @param df DataFrame avec colonnes month, pm25
#' @param seuil_oms Seuil OMS (défaut: SEUIL_OMS)
#'
#' @return ggplot object
#' @export
graphique_taux_depassement <- function(df, seuil_oms = SEUIL_OMS) {
  mois_labels <- c("Jan", "Fév", "Mar", "Avr", "Mai", "Jun", 
                   "Jul", "Aoû", "Sep", "Oct", "Nov", "Déc")
  
  monthly_exceedance <- df %>%
    dplyr::group_by(month) %>%
    dplyr::summarise(
      pct_depassement = mean(pm25 > seuil_oms, na.rm = TRUE) * 100,
      .groups = "drop"
    )
  
  ggplot2::ggplot(monthly_exceedance, ggplot2::aes(x = factor(month), y = pct_depassement, fill = pct_depassement)) +
    ggplot2::geom_col() +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.1f%%", pct_depassement)), 
                       vjust = -0.5, fontsize = 3) +
    ggplot2::scale_x_discrete(labels = mois_labels) +
    ggplot2::scale_fill_gradient(low = "#90EE90", high = "#FF6B6B") +
    ggplot2::labs(
      title = "9. Taux de Dépassement OMS par Mois",
      x = "Mois",
      y = "% jours dépassant OMS (15 µg/m³)",
      subtitle = "Pourcentage des mesures au-dessus du seuil OMS"
    ) +
    style_plot() +
    ggplot2::theme(legend.position = "right", axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}

#' Graphique 10 : Heatmap Heure-Mois
#'
#' @param df DataFrame avec colonnes hour, month, pm25
#'
#' @return ggplot object
#' @export
graphique_heatmap_horaire_mensuel <- function(df) {
  heatmap_data <- df %>%
    dplyr::group_by(month, hour) %>%
    dplyr::summarise(pm25_mean = mean(pm25, na.rm = TRUE), .groups = "drop")
  
  mois_labels <- c("Jan", "Fév", "Mar", "Avr", "Mai", "Jun", 
                   "Jul", "Aoû", "Sep", "Oct", "Nov", "Déc")
  
  ggplot2::ggplot(heatmap_data, ggplot2::aes(x = factor(hour), y = factor(month), fill = pm25_mean)) +
    ggplot2::geom_tile(color = "white", linewidth = 0.1) +
    ggplot2::scale_fill_gradient(low = "#FFFFCC", high = "#FF0000", name = "PM2.5\n(µg/m³)") +
    ggplot2::scale_y_discrete(labels = mois_labels) +
    ggplot2::labs(
      title = "10. Heatmap — Pollution par Heure et Mois",
      x = "Heure de la journée",
      y = "Mois",
      subtitle = "Couleur = concentration moyenne PM2.5 (jaune=faible, rouge=élevée)"
    ) +
    style_plot() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(size = 8))
}

#' Graphique 11 : Corrélation entre capteurs (Heatmap)
#'
#' @param df DataFrame avec colonnes id_sensor, date, pm25
#'
#' @return ggplot object
#' @export
graphique_correlation_capteurs <- function(df) {
  # Prendre les top 15 capteurs
  top_sensors <- df %>%
    dplyr::group_by(id_sensor) %>%
    dplyr::summarise(n = dplyr::n(), mean = mean(pm25, na.rm = TRUE), .groups = "drop") %>%
    dplyr::arrange(dplyr::desc(mean)) %>%
    dplyr::slice(1:15) %>%
    dplyr::pull(id_sensor)
  
  df_top <- df %>%
    dplyr::filter(id_sensor %in% top_sensors) %>%
    dplyr::select(date, id_sensor, pm25) %>%
    tidyr::pivot_wider(names_from = id_sensor, values_from = pm25)
  
  # Calculer la matrice de corrélation
  corr_matrix <- cor(df_top %>% dplyr::select(-date), use = "complete.obs")
  
  # Convertir en format long
  corr_long <- as.data.frame(corr_matrix) %>%
    dplyr::mutate(sensor1 = rownames(.)) %>%
    tidyr::pivot_longer(-sensor1, names_to = "sensor2", values_to = "correlation")
  
  ggplot2::ggplot(corr_long, ggplot2::aes(x = sensor2, y = sensor1, fill = correlation)) +
    ggplot2::geom_tile(color = "white", linewidth = 0.5) +
    ggplot2::scale_fill_gradient2(low = "#0000FF", mid = "white", high = "#FF0000", 
                                  midpoint = 0, limits = c(-1, 1), name = "Corrélation") +
    ggplot2::labs(
      title = "11. Matrice de Corrélation — Top 15 Capteurs",
      x = "Capteur",
      y = "Capteur",
      subtitle = "Bleu=anticorrélation, Blanc=neutre, Rouge=corrélation positive"
    ) +
    style_plot() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1, size = 7),
                   axis.text.y = ggplot2::element_text(size = 7))
}
