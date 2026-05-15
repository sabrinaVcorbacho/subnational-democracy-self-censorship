# How Local Regime Type Shapes Political Expression:
# Self-Censorship in Argentina’s Subnational Units
# Author: Sabrina Victoria Corbacho
# Script: 07_predicted_probabilities_observed_case.R
# Description: Generates model-based predicted probabilities using an
# observed-case approach for DV1 and DV2 models.


# 1. Load packages --------------------------------------------------------

library(tidyverse)
library(ggeffects)
library(scales)


# 2. Load model objects ---------------------------------------------------

# These model objects are created in:
# scripts/04_dv1_multilevel_logit_models.R
# scripts/05_dv2_na_models.R

m_dv1_full <- readRDS("data/processed/m_dv1_full.rds")

m_dv2_A_full <- readRDS("data/processed/m_dv2_A_full.rds")
m_dv2_B_full <- readRDS("data/processed/m_dv2_B_full.rds")
m_dv2_C_full <- readRDS("data/processed/m_dv2_C_full.rds")


# 3. DV1 predicted probabilities across SDI -------------------------------

# DV1: predicted probability of talking about politics with friends
# across Subnational Democracy Index values.

pp_dv1_talk <- ggpredict(
  m_dv1_full,
  terms = "level_dem [1:5]"
)

pp_dv1_talk_df <- as.data.frame(pp_dv1_talk)

write_csv(
  pp_dv1_talk_df,
  "outputs/tables/predicted_probabilities_dv1_talk_by_sdi.csv"
)

fig_pp_dv1 <- ggplot(pp_dv1_talk_df, aes(x = x, y = predicted)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_ribbon(
    aes(ymin = conf.low, ymax = conf.high),
    alpha = 0.3
  ) +
  scale_x_continuous(
    breaks = 1:5,
    labels = c("Very low", "Low", "Moderate", "High", "Very high")
  ) +
  scale_y_continuous(
    labels = percent_format(accuracy = 1)
  ) +
  labs(
    x = "Subnational Democracy Index (SDI)",
    y = "Predicted probability of talking about politics"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x = element_text(angle = 25, hjust = 1)
  )

ggsave(
  filename = "outputs/figures/predicted_probability_dv1_talk_by_sdi.png",
  plot = fig_pp_dv1,
  width = 8,
  height = 5,
  dpi = 300
)


# 4. DV2 predicted probabilities across SDI -------------------------------

# DV2: predicted probability of at least one nonresponse in each sensitive
# item group across Subnational Democracy Index values.

pp_dv2_A <- ggpredict(
  m_dv2_A_full,
  terms = "level_dem [1:5]"
) %>%
  as.data.frame() %>%
  mutate(group = "Corruption")

pp_dv2_B <- ggpredict(
  m_dv2_B_full,
  terms = "level_dem [1:5]"
) %>%
  as.data.frame() %>%
  mutate(group = "Offline political action")

pp_dv2_C <- ggpredict(
  m_dv2_C_full,
  terms = "level_dem [1:5]"
) %>%
  as.data.frame() %>%
  mutate(group = "Online political action")

pp_dv2_all <- bind_rows(
  pp_dv2_A,
  pp_dv2_B,
  pp_dv2_C
)

write_csv(
  pp_dv2_all,
  "outputs/tables/predicted_probabilities_dv2_nonresponse_by_sdi.csv"
)

fig_pp_dv2 <- ggplot(pp_dv2_all, aes(x = x, y = predicted)) +
  geom_line(linewidth = 1, color = "grey30") +
  geom_point(size = 2, color = "grey30") +
  geom_ribbon(
    aes(ymin = conf.low, ymax = conf.high),
    fill = "grey70",
    alpha = 0.4
  ) +
  facet_wrap(~ group) +
  scale_x_continuous(
    breaks = 1:5,
    labels = c("Very low", "Low", "Moderate", "High", "Very high")
  ) +
  scale_y_continuous(
    labels = percent_format(accuracy = 1),
    limits = c(0, NA)
  ) +
  labs(
    x = "Subnational Democracy Index (SDI)",
    y = "Predicted probability of nonresponse"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x = element_text(
      size = 10,
      angle = 25,
      hjust = 1
    ),
    panel.spacing = unit(1.2, "lines")
  )

ggsave(
  filename = "outputs/figures/predicted_probability_dv2_nonresponse_by_sdi.png",
  plot = fig_pp_dv2,
  width = 10,
  height = 6,
  dpi = 300
)