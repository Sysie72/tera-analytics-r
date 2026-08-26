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
    ggplot2::geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed", linewidth = 1) +
    ggplot2::labs(
      title = "8. Relation PM1 vs PM2.5",
      x = "PM1 (µg/m³)",
      y = "PM2.5 (µg/m³)",
      subtitle = sprintf("Corrélation = %.3f | Ligne rouge = diagonale", cor_val)
    ) +
    style_plot()
}
