# Data Documentation

This directory documents the data sources and local data structure used in the analysis.

## Data Sources

### World Values Survey Wave 7 — Argentina Sample

The individual-level survey data are drawn from the Argentina sample of the **World Values Survey Wave 7**. The dataset includes information on political attitudes, political discussion, civic engagement, media use, sensitive-item nonresponse, and sociodemographic characteristics.

Original World Values Survey microdata are not included in this public repository. Researchers interested in reproducing the analysis should obtain the dataset directly from the World Values Survey Association, subject to its terms of use.

**Reference:**
Haerpfer, C., Inglehart, R., Moreno, A., Welzel, C., Kizilova, K., Diez-Medrano, J., Lagos, M., Norris, P., Ponarin, E., & Puranen, B. (Eds.). (2022). *World Values Survey: Round Seven - Country-Pooled Datafile Version 5.0*. Madrid, Spain & Vienna, Austria: JD Systems Institute & WVSA Secretariat. https://doi.org/10.14281/18241.24

### Subnational Democracy Index

Province-level democratic quality is measured using Gervasoni's **Subnational Democracy Index (SDI)**. The index captures variation in democratic quality and political competitiveness across Argentine provinces, with higher values representing more democratic subnational contexts.

**Reference:**
Gervasoni, C. (2018). *Hybrid Regimes within Democracies: Fiscal Federalism and Subnational Rentier States*. Cambridge University Press.

## Folder Structure

```text
data/
├── raw/         Original data files stored locally for analysis
└── processed/   Analysis-ready datasets and saved model objects generated locally
```

* `raw/` is intended for original locally stored input files, including the World Values Survey dataset and province-level contextual data.
* `processed/` is intended for cleaned analytical datasets and saved R model objects produced during the workflow.

## Public Repository Note

The `raw/` and `processed/` folders are intentionally empty in the public repository, except for placeholder files that preserve the folder structure.

Original survey microdata, processed datasets, and saved model objects are excluded from the public repository. The analytical scripts document the workflow used to prepare the data, estimate the models, conduct robustness checks, and generate the reported outputs.

## Reproducing the Analysis

To reproduce the analytical workflow locally:

1. Obtain the required source data from the original data providers.
2. Store the original files in the local `data/raw/` directory.
3. Run the scripts in numerical order from `scripts/01_data_source_and_setup.R` through `scripts/07_predicted_probabilities.R`.
4. Generated analysis-ready datasets and saved model objects will be stored locally in `data/processed/`.
5. Selected figures and tables are exported to the `outputs/` directory.