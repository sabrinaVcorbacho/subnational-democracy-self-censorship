# How Local Regime Type Shapes Political Expression:
# Self-Censorship in Argentina’s Subnational Units
# Author: Sabrina Victoria Corbacho
# Script: 03_descriptive_statistics.R
# Description: Produces descriptive statistics, province-level summaries,
# and exploratory figures for the main dependent variables, SDI, and controls.


# 1. Load packages --------------------------------------------------------

library(tidyverse)
library(modelsummary)
library(scales)


# 2. Load processed data --------------------------------------------------

# This file is created in scripts/02_variable_recoding_and_measures.R
# Processed data files are not included in the GitHub repository.

data_merged <- readRDS("data/processed/thesis_analysis_data.rds")


# 3. General descriptive statistics ---------------------------------------

desc_data <- data_merged %>%
  select(
    talk_friends = Q200_dicho,
    na_corr = na_count_A,
    na_offline = na_count_B,
    na_online = na_count_C,
    na_grouped = na_any,
    SDI = level_dem,
    org_member = org_any,
    pol_interest = Q199_dicho,
    info_source_paper = Q201_dicho,
    info_source_tv = Q202_dicho,
    info_source_radio = Q203_dicho,
    info_source_mobile = Q204_dicho,
    info_source_email = Q205_dicho,
    info_source_internet = Q206_dicho,
    info_source_socialm = Q207_dicho,
    info_source_talkfriends = Q208_dicho,
    ideology = Q240_dicho,
    age = X003R2_r,
    sex = Q260_r,
    education = Q275_r
  )

# Save general descriptive table

datasummary(
  All(desc_data) ~ Mean + SD + Min + Max,
  data = desc_data,
  output = "outputs/tables/descriptive_statistics.md"
)


# 4. DV1 descriptive statistics by province -------------------------------

desc_Q200_province <- data_merged %>%
  group_by(province) %>%
  summarise(
    n = sum(!is.na(Q200_dicho)),
    mean_talk = mean(Q200_dicho, na.rm = TRUE),
    sd_talk = sd(Q200_dicho, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(mean_talk)

write_csv(
  desc_Q200_province,
  "outputs/tables/dv1_descriptives_by_province.csv"
)

fig_dv1_province <- ggplot(
  desc_Q200_province,
  aes(x = reorder(province, mean_talk), y = mean_talk)
) +
  geom_col(fill = "grey60") +
  coord_flip() +
  labs(
    x = "Province",
    y = "Proportion talking about politics with friends"
  ) +
  theme_minimal(base_size = 13)

ggsave(
  filename = "outputs/figures/dv1_talk_politics_by_province.png",
  plot = fig_dv1_province,
  width = 8,
  height = 6,
  dpi = 300
)


# 5. DV2 descriptive statistics by province and group ---------------------

desc_NA_A_province <- data_merged %>%
  group_by(province) %>%
  summarise(
    n = n(),
    mean_na_A = mean(na_count_A, na.rm = TRUE),
    sd_na_A = sd(na_count_A, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(mean_na_A)

desc_NA_B_province <- data_merged %>%
  group_by(province) %>%
  summarise(
    n = n(),
    mean_na_B = mean(na_count_B, na.rm = TRUE),
    sd_na_B = sd(na_count_B, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(mean_na_B)

desc_NA_C_province <- data_merged %>%
  group_by(province) %>%
  summarise(
    n = n(),
    mean_na_C = mean(na_count_C, na.rm = TRUE),
    sd_na_C = sd(na_count_C, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(mean_na_C)

write_csv(desc_NA_A_province, "outputs/tables/dv2_na_corruption_by_province.csv")
write_csv(desc_NA_B_province, "outputs/tables/dv2_na_offline_action_by_province.csv")
write_csv(desc_NA_C_province, "outputs/tables/dv2_na_online_action_by_province.csv")

plot_NA_province <- data_merged %>%
  group_by(province) %>%
  summarise(
    mean_na_A = mean(na_count_A, na.rm = TRUE),
    mean_na_B = mean(na_count_B, na.rm = TRUE),
    mean_na_C = mean(na_count_C, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols = starts_with("mean_na_"),
    names_to = "group",
    values_to = "mean_na"
  ) %>%
  mutate(
    group = recode(
      group,
      mean_na_A = "Corruption",
      mean_na_B = "Offline political action",
      mean_na_C = "Online political action"
    )
  )

fig_dv2_province <- ggplot(
  plot_NA_province,
  aes(x = reorder(province, mean_na), y = mean_na)
) +
  geom_col(fill = "grey60") +
  coord_flip() +
  facet_wrap(~ group, scales = "free_x") +
  labs(
    x = "Province",
    y = "Mean NA count"
  ) +
  theme_minimal(base_size = 13)

ggsave(
  filename = "outputs/figures/dv2_na_count_by_province_and_group.png",
  plot = fig_dv2_province,
  width = 10,
  height = 7,
  dpi = 300
)


# 6. SDI table and SDI by province figure ---------------------------------

sdi_table <- data_merged %>%
  distinct(province, level_dem) %>%
  arrange(level_dem) %>%
  mutate(
    SDI_label = case_when(
      level_dem == 1 ~ "Very low",
      level_dem == 2 ~ "Low",
      level_dem == 3 ~ "Moderate",
      level_dem == 4 ~ "High",
      level_dem == 5 ~ "Very high",
      TRUE ~ NA_character_
    )
  )

write_csv(sdi_table, "outputs/tables/sdi_by_province.csv")

fig_sdi_province <- data_merged %>%
  distinct(province, level_dem) %>%
  ggplot(aes(x = reorder(province, level_dem), y = level_dem)) +
  geom_segment(
    aes(xend = province, y = 1, yend = level_dem),
    color = "grey80"
  ) +
  geom_point(size = 2) +
  scale_y_continuous(breaks = 1:5, limits = c(0.8, 5.2)) +
  labs(
    x = "Province",
    y = "Subnational Democracy Index (SDI: 1–5)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave(
  filename = "outputs/figures/sdi_by_province.png",
  plot = fig_sdi_province,
  width = 8,
  height = 6,
  dpi = 300
)


# 7. DV1 outcomes by SDI level --------------------------------------------

data_merged <- data_merged %>%
  mutate(
    SDI_level = factor(
      level_dem,
      levels = 1:5,
      labels = c("Very low", "Low", "Moderate", "High", "Very high")
    )
  )

avoid_talk_SDI <- data_merged %>%
  group_by(SDI_level) %>%
  summarise(
    n = sum(!is.na(Q200_dicho)),
    pct_avoid = mean(Q200_dicho == 0, na.rm = TRUE) * 100,
    pct_talk = mean(Q200_dicho == 1, na.rm = TRUE) * 100,
    .groups = "drop"
  )

write_csv(avoid_talk_SDI, "outputs/tables/dv1_by_sdi_level.csv")

fig_dv1_sdi <- ggplot(avoid_talk_SDI, aes(x = SDI_level, y = pct_avoid)) +
  geom_col(fill = "grey50") +
  labs(
    x = "Subnational democracy level (SDI)",
    y = "Percent avoiding political conversations"
  ) +
  theme_minimal(base_size = 13)

ggsave(
  filename = "outputs/figures/dv1_avoid_talk_by_sdi_level.png",
  plot = fig_dv1_sdi,
  width = 8,
  height = 5,
  dpi = 300
)


# 8. DV2 NA self-censorship by SDI level and group ------------------------

NA_SDI_grouped <- data_merged %>%
  group_by(SDI_level) %>%
  summarise(
    mean_na_A = mean(na_count_A, na.rm = TRUE),
    mean_na_B = mean(na_count_B, na.rm = TRUE),
    mean_na_C = mean(na_count_C, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols = starts_with("mean_na_"),
    names_to = "group",
    values_to = "mean_na"
  ) %>%
  mutate(
    group = recode(
      group,
      mean_na_A = "Corruption",
      mean_na_B = "Offline political action",
      mean_na_C = "Online political action"
    )
  )

write_csv(NA_SDI_grouped, "outputs/tables/dv2_na_by_sdi_level_and_group.csv")

fig_dv2_sdi <- ggplot(NA_SDI_grouped, aes(x = SDI_level, y = mean_na)) +
  geom_col(fill = "grey60", width = 0.7) +
  facet_wrap(~ group) +
  labs(
    x = "Subnational democracy level (SDI)",
    y = "Mean NA count"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x = element_text(
      size = 11,
      angle = 25,
      hjust = 1
    ),
    panel.spacing = unit(1.2, "lines")
  )

ggsave(
  filename = "outputs/figures/dv2_na_by_sdi_level_and_group.png",
  plot = fig_dv2_sdi,
  width = 10,
  height = 6,
  dpi = 300
)


# 9. Relationship between DV1 and DV2 NA groups ---------------------------

desc_NA_groups_by_Q200 <- data_merged %>%
  group_by(Q200_dicho) %>%
  summarise(
    n = n(),
    mean_na_A = mean(na_count_A, na.rm = TRUE),
    sd_na_A = sd(na_count_A, na.rm = TRUE),
    mean_na_B = mean(na_count_B, na.rm = TRUE),
    sd_na_B = sd(na_count_B, na.rm = TRUE),
    mean_na_C = mean(na_count_C, na.rm = TRUE),
    sd_na_C = sd(na_count_C, na.rm = TRUE),
    mean_na_total = mean(na_count_total, na.rm = TRUE),
    sd_na_total = sd(na_count_total, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(
  desc_NA_groups_by_Q200,
  "outputs/tables/dv2_na_groups_by_dv1_talk_status.csv"
)

NA_bin_long <- data_merged %>%
  select(Q200_dicho, na_bin_A, na_bin_B, na_bin_C) %>%
  filter(!is.na(Q200_dicho)) %>%
  mutate(
    talk_status = if_else(Q200_dicho == 1, "Talks politics", "Avoids politics")
  ) %>%
  pivot_longer(
    cols = starts_with("na_bin_"),
    names_to = "group",
    values_to = "na_bin"
  ) %>%
  mutate(
    group = recode(
      group,
      na_bin_A = "Corruption",
      na_bin_B = "Offline political action",
      na_bin_C = "Online political action"
    )
  )

fig_dv1_dv2_relationship <- ggplot(NA_bin_long, aes(x = talk_status, y = na_bin)) +
  stat_summary(fun = mean, geom = "col", fill = "grey60") +
  facet_wrap(~ group) +
  scale_y_continuous(labels = percent) +
  labs(
    x = NULL,
    y = "Proportion with at least one nonresponse"
  ) +
  theme_minimal(base_size = 13)

ggsave(
  filename = "outputs/figures/dv1_dv2_nonresponse_relationship.png",
  plot = fig_dv1_dv2_relationship,
  width = 9,
  height = 6,
  dpi = 300
)