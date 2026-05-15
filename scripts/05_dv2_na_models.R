# How Local Regime Type Shapes Political Expression:
# Self-Censorship in Argentina’s Subnational Units
# Author: Sabrina Victoria Corbacho
# Script: 05_dv2_na_models.R
# Description: Estimates baseline and full multilevel logistic regression
# models for DV2: nonresponse-based self-censorship measures.


# 1. Load packages --------------------------------------------------------

library(tidyverse)
library(lme4)
library(performance)
library(modelsummary)


# 2. Load processed data --------------------------------------------------

# This file is created in scripts/02_variable_recoding_and_measures.R
# Processed data files are not included in the GitHub repository.

data_merged <- readRDS("data/processed/thesis_analysis_data.rds")


# 3. Prepare analysis sample ----------------------------------------------

dv2_data <- data_merged %>%
  filter(
    !is.na(level_dem),
    !is.na(province)
  )


# 4. Baseline DV2 NA models -----------------------------------------------

# DV2 Group A: at least one nonresponse in corruption/bribery items

m_dv2_A_base <- glmer(
  na_bin_A ~ level_dem + (1 | province),
  data = dv2_data,
  family = binomial
)

summary(m_dv2_A_base)


# DV2 Group B: at least one nonresponse in offline political action items

m_dv2_B_base <- glmer(
  na_bin_B ~ level_dem + (1 | province),
  data = dv2_data,
  family = binomial
)

summary(m_dv2_B_base)


# DV2 Group C: at least one nonresponse in online political action items

m_dv2_C_base <- glmer(
  na_bin_C ~ level_dem + (1 | province),
  data = dv2_data,
  family = binomial
)

summary(m_dv2_C_base)


# 5. Full DV2 NA models with controls -------------------------------------

control_formula <- paste(
  "level_dem",
  "org_any",
  "Q199_dicho",
  "Q201_dicho", "Q202_dicho", "Q203_dicho", "Q204_dicho",
  "Q205_dicho", "Q206_dicho", "Q207_dicho", "Q208_dicho",
  "Q215_dicho", "Q216_dicho",
  "Q240_dicho",
  "Q260_r", "Q275_r", "X003R2_r",
  sep = " + "
)

m_dv2_A_full <- glmer(
  as.formula(paste("na_bin_A ~", control_formula, "+ (1 | province)")),
  data = dv2_data,
  family = binomial,
  control = glmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 2e5)
  )
)

summary(m_dv2_A_full)


m_dv2_B_full <- glmer(
  as.formula(paste("na_bin_B ~", control_formula, "+ (1 | province)")),
  data = dv2_data,
  family = binomial,
  control = glmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 2e5)
  )
)

summary(m_dv2_B_full)


m_dv2_C_full <- glmer(
  as.formula(paste("na_bin_C ~", control_formula, "+ (1 | province)")),
  data = dv2_data,
  family = binomial,
  control = glmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 2e5)
  )
)

summary(m_dv2_C_full)


# 6. Random-effect variance summary ---------------------------------------

safe_re_var <- function(model, group = "province") {
  if (lme4::isSingular(model, tol = 1e-4)) {
    return(0)
  }
  
  vc <- lme4::VarCorr(model)
  as.numeric(vc[[group]][1, 1])
}

random_effect_summary_dv2 <- tibble(
  model = c(
    "A baseline", "B baseline", "C baseline",
    "A full", "B full", "C full"
  ),
  outcome = c(
    "Corruption nonresponse",
    "Offline political action nonresponse",
    "Online political action nonresponse",
    "Corruption nonresponse",
    "Offline political action nonresponse",
    "Online political action nonresponse"
  ),
  specification = c(
    "Baseline", "Baseline", "Baseline",
    "Full", "Full", "Full"
  ),
  province_variance = c(
    safe_re_var(m_dv2_A_base),
    safe_re_var(m_dv2_B_base),
    safe_re_var(m_dv2_C_base),
    safe_re_var(m_dv2_A_full),
    safe_re_var(m_dv2_B_full),
    safe_re_var(m_dv2_C_full)
  )
) %>%
  mutate(
    province_sd = sqrt(province_variance)
  )

write_csv(
  random_effect_summary_dv2,
  "outputs/tables/dv2_random_effect_summary.csv"
)


# 7. Export model tables --------------------------------------------------

dv2_baseline_models <- list(
  "Corruption" = m_dv2_A_base,
  "Offline action" = m_dv2_B_base,
  "Online action" = m_dv2_C_base
)

modelsummary(
  dv2_baseline_models,
  exponentiate = TRUE,
  statistic = "std.error",
  stars = TRUE,
  output = "outputs/tables/dv2_na_baseline_models.html"
)


dv2_full_models <- list(
  "Corruption" = m_dv2_A_full,
  "Offline action" = m_dv2_B_full,
  "Online action" = m_dv2_C_full
)

modelsummary(
  dv2_full_models,
  exponentiate = TRUE,
  statistic = "std.error",
  stars = TRUE,
  output = "outputs/tables/dv2_na_full_models.html"
)


dv2_all_models <- list(
  "A baseline" = m_dv2_A_base,
  "A full" = m_dv2_A_full,
  "B baseline" = m_dv2_B_base,
  "B full" = m_dv2_B_full,
  "C baseline" = m_dv2_C_base,
  "C full" = m_dv2_C_full
)

modelsummary(
  dv2_all_models,
  exponentiate = TRUE,
  statistic = "std.error",
  stars = TRUE,
  output = "outputs/tables/dv2_na_all_models.html"
)


# 8. Save model objects locally -------------------------------------------

# Model objects are saved locally for later scripts.
# They are not included in the GitHub repository if data/processed/ is ignored.

saveRDS(m_dv2_A_base, "data/processed/m_dv2_A_base.rds")
saveRDS(m_dv2_B_base, "data/processed/m_dv2_B_base.rds")
saveRDS(m_dv2_C_base, "data/processed/m_dv2_C_base.rds")

saveRDS(m_dv2_A_full, "data/processed/m_dv2_A_full.rds")
saveRDS(m_dv2_B_full, "data/processed/m_dv2_B_full.rds")
saveRDS(m_dv2_C_full, "data/processed/m_dv2_C_full.rds")