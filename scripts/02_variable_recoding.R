# How Local Regime Type Shapes Political Expression:
# Self-Censorship in Argentina’s Subnational Units
# Author: Sabrina Victoria Corbacho
# Script: 02_variable_recoding_and_measures.R
# Description: Recodes WVS variables, constructs dependent and independent
# variables, merges WVS data with the Subnational Democracy Index, and creates
# alternative NA-count self-censorship measures.


# 1. Load packages --------------------------------------------------------

library(tidyverse)
library(janitor)


# 2. Load prepared data ---------------------------------------------------

# These files are created in scripts/01_data_source_and_setup.R
# Raw and processed data files are not included in the GitHub repository.

WVS <- readRDS("data/processed/wvs_argentina_selected.rds")
SDI_raw <- readRDS("data/processed/sdi_raw.rds")


# 3. Organizational membership -------------------------------------------

# Recode organizational membership items:
# 0/1 = not an active member
# 2 = active member
# negative values = missing

org_fun <- function(x) {
  case_when(
    x %in% c(0, 1) ~ 0,
    x == 2 ~ 1,
    x %in% c(-1, -2, -4, -5) ~ NA_real_,
    TRUE ~ NA_real_
  )
}

WVS <- WVS %>%
  mutate(across(Q94:Q105, org_fun, .names = "{.col}_dicho"))

# Construct binary indicator for membership in any organization

org_cols <- paste0("Q", 94:105, "_dicho")

WVS <- WVS %>%
  mutate(
    org_any = case_when(
      rowSums(across(all_of(org_cols)), na.rm = TRUE) > 0 ~ 1,
      rowSums(is.na(across(all_of(org_cols)))) == length(org_cols) ~ NA_real_,
      TRUE ~ 0
    )
  )


# 4. Corruption and bribery items -----------------------------------------

# Corruption involvement:
# none/few = 0
# most/all = 1

corr_fun <- function(x) {
  case_when(
    x %in% c(1, 2) ~ 0,
    x %in% c(3, 4) ~ 1,
    x %in% c(-1, -2, -4, -5) ~ NA_real_,
    TRUE ~ NA_real_
  )
}

# Bribe frequency:
# never/rarely = 0
# frequently/always = 1

bribe_fun <- function(x) {
  case_when(
    x %in% c(1, 2) ~ 0,
    x %in% c(3, 4) ~ 1,
    x %in% c(-1, -2, -4, -5) ~ NA_real_,
    TRUE ~ NA_real_
  )
}

WVS <- WVS %>%
  mutate(
    Q115_dicho = corr_fun(Q115),
    Q117_dicho = corr_fun(Q117),
    Q118_dicho = bribe_fun(Q118)
  )


# 5. Political interest and DV1 -------------------------------------------

WVS <- WVS %>%
  mutate(
    # Political interest:
    # very/rather interested = 1
    # not very/not at all interested = 0
    Q199_dicho = case_when(
      Q199 %in% c(1, 2) ~ 1,
      Q199 %in% c(3, 4) ~ 0,
      Q199 %in% c(-1, -2, -4, -5) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    
    # DV1: talking about politics with friends
    # frequently/occasionally = 1
    # never = 0
    Q200_dicho = case_when(
      Q200 %in% c(1, 2) ~ 1,
      Q200 == 3 ~ 0,
      Q200 %in% c(-1, -2, -4, -5) ~ NA_real_,
      TRUE ~ NA_real_
    )
  )


# 6. Information sources and activism -------------------------------------

# Media exposure:
# daily/weekly/monthly = 1
# less than monthly/never = 0

media_fun <- function(x) {
  case_when(
    x %in% c(1, 2, 3) ~ 1,
    x %in% c(4, 5) ~ 0,
    x %in% c(-1, -2, -4, -5) ~ NA_real_,
    TRUE ~ NA_real_
  )
}

WVS <- WVS %>%
  mutate(across(Q201:Q208, media_fun, .names = "{.col}_dicho"))

# Political action / activism:
# have done/might do = 1
# would never do = 0

action_fun <- function(x) {
  case_when(
    x %in% c(1, 2) ~ 1,
    x == 3 ~ 0,
    x %in% c(-1, -2, -4, -5) ~ NA_real_,
    TRUE ~ NA_real_
  )
}

WVS <- WVS %>%
  mutate(
    across(
      c(Q209:Q212, Q215, Q216, Q217:Q220),
      action_fun,
      .names = "{.col}_dicho"
    )
  )


# 7. Ideology and demographics --------------------------------------------

WVS <- WVS %>%
  mutate(
    # Ideology:
    # left = 1 for values 1-5
    # right = 0 for values 6-10
    Q240_dicho = case_when(
      Q240 %in% 1:5 ~ 1,
      Q240 %in% 6:10 ~ 0,
      Q240 %in% c(-1, -2, -4, -5) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    
    # Age categories:
    # 1 = 16-29 years
    # 2 = 30-49 years
    # 3 = 50 years and over
    X003R2_r = case_when(
      X003R2 %in% c(1, 2, 3) ~ X003R2,
      X003R2 %in% c(-1, -2, -4, -5) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    
    # Sex:
    # male = 1
    # female = 0
    Q260_r = case_when(
      Q260 == 1 ~ 1,
      Q260 == 2 ~ 0,
      Q260 %in% c(-1, -2, -4, -5) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    
    # Education:
    # 0 = early childhood/no education
    # 1 = primary, lower secondary, upper secondary
    # 2 = post-secondary/tertiary
    # 3 = higher education
    Q275_r = case_when(
      Q275 == 0 ~ 0,
      Q275 %in% c(1, 2, 3) ~ 1,
      Q275 %in% c(4, 5) ~ 2,
      Q275 %in% c(6, 7, 8) ~ 3,
      Q275 %in% c(-1, -2, -4, -5) ~ NA_real_,
      TRUE ~ NA_real_
    )
  )


# 8. Province labels and merge with SDI -----------------------------------

WVS <- WVS %>%
  mutate(
    N_REGION_ISO = as.integer(as.character(N_REGION_ISO)),
    province = case_when(
      N_REGION_ISO == 32001 ~ "CABA",
      N_REGION_ISO == 32002 ~ "Buenos Aires",
      N_REGION_ISO == 32006 ~ "Cordoba",
      N_REGION_ISO == 32021 ~ "Santa Fe",
      N_REGION_ISO == 32013 ~ "Mendoza",
      N_REGION_ISO == 32017 ~ "Salta",
      N_REGION_ISO == 32004 ~ "Chaco",
      N_REGION_ISO == 32003 ~ "Catamarca",
      N_REGION_ISO == 32019 ~ "San Luis",
      N_REGION_ISO == 32005 ~ "Chubut",
      N_REGION_ISO == 32012 ~ "La Rioja",
      N_REGION_ISO == 32007 ~ "Corrientes",
      N_REGION_ISO == 32024 ~ "Tucuman",
      TRUE ~ NA_character_
    )
  )

# Merge WVS Argentina sample with Subnational Democracy Index

data_merged <- left_join(WVS, SDI_raw, by = "province")

# Recode SDI categories to ordered numeric values:
# 1 = very low democracy
# 5 = very high democracy

data_merged <- data_merged %>%
  mutate(
    level_dem = case_when(
      level_dem == "Very low" ~ 1,
      level_dem == "Low" ~ 2,
      level_dem == "Moderate" ~ 3,
      level_dem == "High" ~ 4,
      level_dem == "Very high" ~ 5,
      TRUE ~ NA_real_
    )
  )


# 9. DV2: NA-count self-censorship measures -------------------------------

# Sensitive item groups

cols_corrupt <- c("Q115_dicho", "Q117_dicho", "Q118_dicho")
cols_offline <- c("Q209_dicho", "Q210_dicho", "Q211_dicho", "Q212_dicho")
cols_online  <- c("Q217_dicho", "Q218_dicho", "Q219_dicho", "Q220_dicho")

# Check that all required columns exist

needed <- c(cols_corrupt, cols_offline, cols_online)
missing_cols <- setdiff(needed, names(data_merged))

if (length(missing_cols) > 0) {
  stop("These columns are missing in data_merged: ",
       paste(missing_cols, collapse = ", "))
}

# Count missing values across sensitive items

data_merged <- data_merged %>%
  mutate(
    na_count_A = rowSums(is.na(across(all_of(cols_corrupt)))),
    na_count_B = rowSums(is.na(across(all_of(cols_offline)))),
    na_count_C = rowSums(is.na(across(all_of(cols_online)))),
    na_count_total = na_count_A + na_count_B + na_count_C,
    na_any = if_else(na_count_total > 0, 1L, 0L)
  )

# Binary NA indicators by sensitive item group

data_merged <- data_merged %>%
  mutate(
    na_bin_A = if_else(na_count_A > 0, 1L, 0L),
    na_bin_B = if_else(na_count_B > 0, 1L, 0L),
    na_bin_C = if_else(na_count_C > 0, 1L, 0L)
  )


# 10. Save processed analysis dataset -------------------------------------

saveRDS(data_merged, "data/processed/thesis_analysis_data.rds")