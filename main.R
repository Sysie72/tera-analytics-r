# ========================================
# Point d'entrée du pipeline ETL
# ========================================

# Charger les dépendances
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(patchwork)
library(here)
library(tidyr)

# Charger la configuration
source("config.R")

# Charger tous les modules ETL
source("etl/extract/extraire.R")
source("etl/transform/nettoyage.R")
source("etl/transform/analyse.R")
source("etl/load/exporter.R")

# Charger tous les modules de visualisation
source("visualisation/graphiques.R")

# ========================================
# PIPELINE COMPLET
# ========================================

cat("\n=== Démarrage du pipeline qualité de l'air ===\n\n")

# 1. EXTRACT
cat("[1/5] EXTRACT — Lecture du CSV...\n")
df <- extraire()
cat(sprintf("  → %d lignes — %s à %s\n", nrow(df), min(df$time), max(df$time)))

# 2. TRANSFORM — Nettoyage
cat("\n[2/5] TRANSFORM — Nettoyage...\n")
df <- nettoyer(df)

# 3. TRANSFORM — Analyse
cat("\n[3/5] TRANSFORM — Analyse...\n")
df <- ajouter_features_temporelles(df)
moyenne_jour <- moyenne_journaliere_ville(df)
stats <- stats_par_capteur(df)
oms <- conformite_oms(moyenne_jour)

cat("\n--- Résultats Clés ---\n")
cat(sprintf("PM2.5 moyen : %.2f µg/m³\n", oms$pm25_moyen))
cat(sprintf("Jours > OMS (%d µg/m³) : %d (%.1f%%)\n", SEUIL_OMS, oms$jours_au_dessus_oms, oms$pct_au_dessus_oms))
cat("\nTop 5 capteurs les plus pollués :\n")
print(head(stats, 5))

# 4. LOAD
cat("\n[4/5] LOAD — Export CSV...\n")
exporter(df, moyenne_jour)

# 5. VISUALISATION — Créer 11 graphiques individuels
cat("\n[5/5] VISUALISATION — Création de 11 graphiques PNG...\n")
cat("\nGénération des graphiques :\n")

p1 <- graphique_profil_horaire(df)
sauvegarder_graphique(p1, "01_cycle_diurne", largeur = 12, hauteur = 7)

p2 <- graphique_profil_mensuel(df)
sauvegarder_graphique(p2, "02_variation_saisonniere", largeur = 12, hauteur = 7)

p3 <- graphique_serie_temporelle(moyenne_jour)
sauvegarder_graphique(p3, "03_evolution_temporelle", largeur = 14, hauteur = 7)

p4 <- graphique_top_capteurs(stats, top = 10)
sauvegarder_graphique(p4, "04_top_capteurs", largeur = 12, hauteur = 9)

p5 <- graphique_distribution(df)
sauvegarder_graphique(p5, "05_distribution", largeur = 12, hauteur = 7)

p6 <- graphique_boxplot_mensuel(df)
sauvegarder_graphique(p6, "06_boxplot_mensuel", largeur = 14, hauteur = 8)

p7 <- graphique_boxplot_horaire(df)
sauvegarder_graphique(p7, "07_boxplot_horaire", largeur = 14, hauteur = 8)

p8 <- graphique_pm1_vs_pm25(df)
sauvegarder_graphique(p8, "08_pm1_vs_pm25", largeur = 12, hauteur = 8)

p9 <- graphique_taux_depassement(df)
sauvegarder_graphique(p9, "09_taux_depassement", largeur = 12, hauteur = 7)

p10 <- graphique_heatmap_horaire_mensuel(df)
sauvegarder_graphique(p10, "10_heatmap_horaire_mensuel", largeur = 14, hauteur = 9)

p11 <- graphique_correlation_capteurs(df)
sauvegarder_graphique(p11, "11_correlation_capteurs", largeur = 14, hauteur = 10)

cat("\n✓ Pipeline terminé !\n\n")
cat(sprintf("%s📊 Tous les graphiques sont dans :%s\n", COLOR_SUCCESS, COLOR_RESET))
cat(sprintf("%s   %s%s\n\n", COLOR_INFO, OUTPUT_FIGS_DIR, COLOR_RESET))
