# How Local Regime Type Shapes Political Expression:
# Self-Censorship in Argentina’s Subnational Units
# Author: Sabrina Victoria Corbacho
# Script: 06_robustness_checks.R
# Description: Estimates robustness checks using single-level logistic models
# for DV1 and combined nonresponse models for DV2.


# 1. Load packages --------------------------------------------------------

library(tidyverse)
library(lme4)
library(modelsummary)


# 2. Load processed data --------------------------------------------------

# This file is created in scripts/02_variable_recoding_and_measures.R
# Processed data files are not included in the GitHub repository.

data_merged <- readRDS("data/processed/thesis_analysis_data.rds")


# 3. DV1 robustness: single-level logistic models -------------------------

# These models estimate the DV1 relationship without province-level random
# intercepts. They are used as a robustness check against the multilevel
# specification.

m_dv1_glm_base <- glm(
  Q200_dicho ~ level_dem,
  data = data_merged,
  family = binomial
)

summary(m_dv1_glm_base)


m_dv1_glm_full <- glm(
  Q200_dicho ~ level_dem +
    org_any +
    Q199_dicho +
    Q201_dicho + Q202_dicho + Q203_dicho + Q204_dicho +
    Q205_dicho + Q206_dicho + Q207_dicho +
    Q215_dicho + Q216_dicho +
    Q260_r + Q275_r + X003R2_r,
  data = data_merged,
  family = binomial
)

summary(m_dv1_glm_full)


# 4. DV2 robustness: combined NA self-censorship models -------------------

# na_any equals 1 if the respondent has at least one nonresponse across
# sensitive corruption, offline political action, or online political action items.

m_dv2_combined_base <- glmer(
  na_any ~ level_dem + (1 | province),
  data = data_merged,
  family = binomial,
  control = glmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 2e5)
  )
)

summary(m_dv2_combined_base)


m_dv2_combined_full <- glmer(
  na_any ~ level_dem +
    org_any +
    Q199_dicho +
    Q201_dicho + Q202_dicho + Q203_dicho + Q204_dicho +
    Q205_dicho + Q206_dicho + Q207_dicho +
    Q215_dicho + Q216_dicho +
    Q260_r + Q275_r + X003R2_r +
    (1 | province),
  data = data_merged,
  family = binomial,
  control = glmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 2e5)
  )
)

summary(m_dv2_combined_full)


# 5. Export robustness tables --------------------------------------------

dv1_robustness_models <- list(
  "DV1 single-level baseline" = m_dv1_glm_base,
  "DV1 single-level full" = m_dv1_glm_full
)

modelsummary(
  dv1_robustness_models,
  exponentiate = TRUE,
  statistic = "std.error",
  stars = TRUE,
  output = "outputs/tables/robustness_dv1_single_level_logits.html"
)


dv2_robustness_models <- list(
  "DV2 combined baseline" = m_dv2_combined_base,
  "DV2 combined full" = m_dv2_combined_full
)

modelsummary(
  dv2_robustness_models,
  exponentiate = TRUE,
  statistic = "std.error",
  stars = TRUE,
  output = "outputs/tables/robustness_dv2_combined_na_models.html"
)


# 6. Save robustness model objects locally --------------------------------

# Model objects are saved locally for later reference.
# They are not included in the GitHub repository if data/processed/ is ignored.

saveRDS(m_dv1_glm_base, "data/processed/m_dv1_glm_base.rds")
saveRDS(m_dv1_glm_full, "data/processed/m_dv1_glm_full.rds")

saveRDS(m_dv2_combined_base, "data/processed/m_dv2_combined_base.rds")
saveRDS(m_dv2_combined_full, "data/processed/m_dv2_combined_full.rds")