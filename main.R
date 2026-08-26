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

# Charger la configuration
source("config.R")

# Charger tous les modules ETL
source("etl/extract/extraire.R")
source("etl/transform/nettoyage.R")
source("etl/transform/analyse.R")
source("etl/load/exporter.R")

# Charger tous les modules de visualisation
source("visualisation/graphiques.R")
source("visualisation/dashboard.R")

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

# 5. Visualisation
cat("\n[5/5] VISUALISATION — Création du dashboard...\n")
dashboard <- graphique_dashboard(df, stats, moyenne_jour)
sauvegarder_dashboard(dashboard)

cat("\n✓ Pipeline terminé !\n\n")
