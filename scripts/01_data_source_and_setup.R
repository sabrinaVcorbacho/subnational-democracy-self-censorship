# How Local Regime Type Shapes Political Expression:
# Self-Censorship in Argentina’s Subnational Units
# Author: Sabrina Victoria Corbacho
# Script: 01_data_source_and_setup.R
# Description: Loads the datasets, applies initial sample restrictions,
# and selects the variables used in the analysis.

# 1. Load packages --------------------------------------------------------

library(tidyverse)
library(haven)
library(janitor)

# Modeling and outputs
library(lme4)
library(stargazer)
library(ggeffects)
library(modelsummary)
library(performance)


# 2. Define project paths -------------------------------------------------

# This project uses relative paths from the R Project root.
# Raw data files are not included in this repository due to redistribution restrictions.

path_wvs <- "data/raw/WVS_Cross-National_Wave_7_csv_v6_0.csv"
path_sdi <- "data/raw/Subnational_Democratic_Index_1983_2015.csv"


# 3. Import data ----------------------------------------------------------

WVS_raw <- read.csv(path_wvs)
SDI_raw <- read.csv(path_sdi)


# 4. Sample restrictions and variable selection ---------------------------

# Keep only variables used in the analysis
WVS <- WVS_raw[, c(
  "B_COUNTRY", "N_REGION_ISO",
  "Q94", "Q95", "Q96", "Q97", "Q98", "Q99", "Q100", "Q101", "Q102", "Q103", "Q104", "Q105",
  "Q115", "Q117", "Q118",
  "Q199", "Q200",
  "Q201", "Q202", "Q203", "Q204", "Q205", "Q206", "Q207", "Q208",
  "Q209", "Q210", "Q211", "Q212",
  "Q215", "Q216",
  "Q217", "Q218", "Q219", "Q220",
  "Q240",
  "X003R2", "Q260", "Q275"
)]

# Keep Argentina only
# WVS country code 32 corresponds to Argentina
WVS <- WVS %>%
  filter(B_COUNTRY == 32)

saveRDS(WVS, "data/processed/wvs_argentina_selected.rds")
saveRDS(SDI_raw, "data/processed/sdi_raw.rds")