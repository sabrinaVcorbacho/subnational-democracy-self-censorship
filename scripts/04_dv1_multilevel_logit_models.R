# How Local Regime Type Shapes Political Expression:
# Self-Censorship in Argentina’s Subnational Units
# Author: Sabrina Victoria Corbacho
# Script: 04_dv1_multilevel_logit_models.R
# Description: Estimates baseline and full multilevel logistic regression
# models for DV1: political discussion with friends.


# 1. Load packages --------------------------------------------------------

library(tidyverse)
library(lme4)
library(performance)
library(modelsummary)
library(broom.mixed)


# 2. Load processed data --------------------------------------------------

# This file is created in scripts/02_variable_recoding_and_measures.R
# Processed data files are not included in the GitHub repository.

data_merged <- readRDS("data/processed/thesis_analysis_data.rds")


# 3. Prepare analysis sample ----------------------------------------------

dv1_data <- data_merged %>%
  filter(
    !is.na(Q200_dicho),
    !is.na(level_dem),
    !is.na(province)
  )


# 4. Baseline multilevel logit model --------------------------------------

# DV1: talking about politics with friends
# 1 = talks politics frequently/occasionally
# 0 = never talks politics
#
# Main independent variable:
# level_dem = Subnational Democracy Index, recoded from 1 to 5
#
# Random intercept:
# province

m_dv1_base <- glmer(
  Q200_dicho ~ level_dem + (1 | province),
  data = dv1_data,
  family = binomial
)

summary(m_dv1_base)


# 5. Intraclass correlation coefficient -----------------------------------

# Logistic ICC on latent scale:
# tau_00 / (tau_00 + pi^2 / 3)

tau00_base <- as.numeric(VarCorr(m_dv1_base)$province[1, 1])

icc_logit_base <- tau00_base / (tau00_base + (pi^2 / 3))

icc_logit_base

performance::icc(m_dv1_base)


# 6. Cluster information --------------------------------------------------

province_sizes <- dv1_data %>%
  count(province, sort = TRUE)

n_provinces <- n_distinct(dv1_data$province)

province_sizes
n_provinces


# 7. Full multilevel logit model ------------------------------------------

m_dv1_full <- glmer(
  Q200_dicho ~ level_dem + org_any +
    Q199_dicho +
    Q201_dicho + Q202_dicho + Q203_dicho + Q204_dicho +
    Q205_dicho + Q206_dicho + Q207_dicho +
    Q215_dicho + Q216_dicho + Q240_dicho +
    Q260_r + Q275_r + X003R2_r +
    (1 | province),
  data = data_merged,
  family = binomial,
  control = glmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 2e5)
  )
)

summary(m_dv1_full)


# 8. Random-effect variance -----------------------------------------------

VarCorr(m_dv1_base)
VarCorr(m_dv1_full)


# 9. Safe extraction of random-intercept variance -------------------------

safe_re_var <- function(model, group = "province") {
  if (lme4::isSingular(model, tol = 1e-4)) {
    return(0)
  }
  
  vc <- lme4::VarCorr(model)
  as.numeric(vc[[group]][1, 1])
}

var_base <- safe_re_var(m_dv1_base, "province")
sd_base <- sqrt(var_base)

var_full <- safe_re_var(m_dv1_full, "province")
sd_full <- sqrt(var_full)

random_effect_summary <- tibble(
  model = c("Baseline", "Full"),
  province_variance = c(var_base, var_full),
  province_sd = c(sd_base, sd_full)
)

write_csv(
  random_effect_summary,
  "outputs/tables/dv1_random_effect_summary.csv"
)


# 10. Export model table --------------------------------------------------

dv1_models <- list(
  "Baseline model" = m_dv1_base,
  "Full model" = m_dv1_full
)

modelsummary(
  dv1_models,
  exponentiate = TRUE,
  statistic = "std.error",
  stars = TRUE,
  output = "outputs/tables/dv1_multilevel_logit_models.html"
)


# 11. Save model objects locally ------------------------------------------

# Model objects are saved locally for later scripts, such as predicted
# probabilities. They are not included in the GitHub repository if
# data/processed/ is listed in .gitignore.

saveRDS(m_dv1_base, "data/processed/m_dv1_base.rds")
saveRDS(m_dv1_full, "data/processed/m_dv1_full.rds")