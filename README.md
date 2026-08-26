# tera-analytics — ETL en R 🇲🇬

**Analyse de la qualité de l'air (PM2.5) à Antananarivo**

Ce projet transforme les données brutes de pollution en informations claires via un pipeline **ETL** (Extract → Transform → Load) écrit en **R** avec visualisations **ggplot2**.

---

## 📁 Structure du projet

```
tera-analytics-r/
├── data/
│   └── tera_analytics_data.csv          # Données brutes
│   └── processed/                       # CSV traités (après run)
├── outputs/
│   └── figures/                         # Graphiques PNG (après run)
├── etl/
│   ├── extract/
│   │   └── extraire.R                   # Extraction CSV
│   ├── transform/
│   │   ├── nettoyage.R                  # Nettoyage données
│   │   └── analyse.R                    # Calculs & agrégations
│   └── load/
│       └── exporter.R                   # Export CSV
├── visualisation/
│   ├── graphiques.R                     # Graphiques individuels
│   └── dashboard.R                      # Dashboard complet
├── config.R                             # Configuration globale
├── main.R                               # Point d'entrée
└── README.md
```

---

## 🚀 Installation & Prérequis

### 1️⃣ Installer R et RStudio
- **R** : https://cran.r-project.org/
- **RStudio** (optionnel mais recommandé) : https://posit.co/download/rstudio-desktop/

### 2️⃣ Installer les packages R

Dans RStudio ou R, exécutez :

```r
packages <- c("readr", "dplyr", "lubridate", "ggplot2", "patchwork", "here")
install.packages(packages)
```

### 3️⃣ Placer le fichier de données

Copier `tera_analytics_data.csv` dans le dossier `data/` du projet.

---

## ▶️ Lancer le pipeline

### Via RStudio
1. Ouvrir `main.R`
2. Cliquer sur **"Run"** (ou Ctrl+Alt+R)

### Via terminal R
```r
source("main.R")
```

### Via ligne de commande
```bash
Rscript main.R
```

---

## 📊 Résultats

Le pipeline génère :

### CSV (dans `data/processed/`)
- `donnees_nettoyees.csv` — Données filtrées
- `moyenne_journaliere.csv` — Moyennes par jour

### Graphiques (dans `outputs/figures/`)
- `dashboard.png` — 9 graphiques combinés

---

## 📈 Visualisations incluses

1. **Cycle diurne** — PM2.5 par heure
2. **Variation saisonnière** — PM2.5 par mois
3. **Évolution journalière** — Série temporelle
4. **Top capteurs** — Classement des pollueurs
5. **Distribution** — Histogramme + P95
6. **Variabilité mensuelle** — Boxplot
7. **Variabilité horaire** — Boxplot
8. **Relation PM1 vs PM2.5** — Scatter plot
9. **Taux de dépassement** — % jours > OMS

---

## 🔧 Personnalisation

### Modifier les paramètres

Éditer `config.R` :

```r
FICHIER_CSV <- "chemin/vers/donnees.csv"  # Chemin des données
SEUIL_OMS <- 15.0                          # Seuil OMS (µg/m³)
PERCENTILE_OUTLIERS <- 0.99                # Percentile pour outliers
```

### Ajouter un graphique personnalisé

Dans `visualisation/graphiques.R`, ajouter une fonction :

```r
graphique_custom <- function(df) {
  ggplot2::ggplot(df, ggplot2::aes(x = date, y = pm25)) +
    ggplot2::geom_line() +
    ggplot2::labs(title = "Mon graphique") +
    style_plot()
}
```

Ensuite l'appeler dans `main.R`.

---

## 🔑 Étapes du pipeline

### 1. **EXTRACT** (`etl/extract/extraire.R`)
Lit le fichier CSV brut avec la structure :
- `time` — Timestamp POSIXct
- `id_sensor` — ID du capteur
- `id_install` — ID de l'installation
- `pm1`, `pm25` — Concentrations

### 2. **TRANSFORM — Nettoyage** (`etl/transform/nettoyage.R`)
- Supprime les valeurs négatives
- Supprime les incohérences (PM1 > PM2.5)
- Supprime les outliers au-delà du 99e percentile
- Supprime les doublons

### 3. **TRANSFORM — Analyse** (`etl/transform/analyse.R`)
- Ajoute features temporelles (hour, month, date)
- Calcule moyennes journalières
- Génère stats par capteur
- Crée profils horaires/mensuels
- Mesure conformité OMS

### 4. **LOAD** (`etl/load/exporter.R`)
Exporte en CSV :
- Données nettoyées
- Moyennes journalières

### 5. **VISUALISATION** (`visualisation/graphiques.R` & `visualisation/dashboard.R`)
Crée 9 graphiques combinés avec ggplot2 & patchwork.

---

## 📚 Documentation des fonctions

Tous les fichiers `.R` contiennent des docstrings (roxygen2).

Pour consulter l'aide :

```r
?extraire
?nettoyer
?conformite_oms
help(profil_horaire)
```

---

## 🐛 Dépannage

### ❌ Erreur : "Package 'dplyr' not found"
```r
install.packages("dplyr")
```

### ❌ Erreur : "File not found: tera_analytics_data.csv"
- Vérifier que le fichier existe dans `data/`
- Modifier le chemin dans `config.R`

### ❌ Graphiques ne s'affichent pas
- Vérifier que `patchwork` et `ggplot2` sont installés
- Les PNG sont toujours sauvegardés dans `outputs/figures/`

---

## 📝 Licence

MIT License — Libre d'utilisation.

---

## 👥 Auteur

Projet ETL multilingue : **Python → R** adaptation

**Questions ?** Consultez la documentation dans chaque fichier `.R`.
