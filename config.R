# ========================================
# Configuration globale du projet
# ========================================

# Chemins
ROOT_DIR <- here::here()
DATA_DIR <- file.path(ROOT_DIR, "data")
PROCESSED_DIR <- file.path(ROOT_DIR, "data", "processed")
OUTPUT_FIGS_DIR <- file.path(ROOT_DIR, "outputs", "figures")

# Créer les répertoires s'ils n'existent pas
dir.create(PROCESSED_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(OUTPUT_FIGS_DIR, showWarnings = FALSE, recursive = TRUE)

# Paramètres
FICHIER_CSV <- file.path(DATA_DIR, "tera_analytics_data.csv")
SEUIL_OMS <- 15.0  # µg/m³ — recommandation OMS sur 24h
PERCENTILE_OUTLIERS <- 0.99

# Messages de log
COLOR_INFO <- "\033[1;34m"
COLOR_SUCCESS <- "\033[1;32m"
COLOR_RESET <- "\033[0m"
