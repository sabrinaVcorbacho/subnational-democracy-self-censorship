# Variable Construction

## Overview

This document describes the construction of the main variables used to examine political self-censorship across Argentina's subnational units.

The study conceptualizes **political self-censorship** as the intentional withholding of political expression in response to perceived social or political risks. Because self-censorship is not directly observable, it is operationalized through two complementary behavioral indicators:

1. **Conversational self-censorship:** willingness to talk about politics with friends.
2. **Survey-based self-censorship:** nonresponse to politically sensitive survey items.

These indicators capture different settings in which expressive caution may occur: socially visible interpersonal discussion and private survey response.

## Main Contextual Predictor: Subnational Democracy Index (SDI)

The main independent variable is the **Subnational Democracy Index (SDI)** developed by Gervasoni (2018). The index measures variation in democratic quality across Argentine provinces and is merged with individual-level World Values Survey responses using province identifiers.

In the analytical dataset, SDI is recoded as an ordered numerical measure:

| Variable    | Value | Interpretation               |
| ----------- | ----: | ---------------------------- |
| `level_dem` |     1 | Very low democratic quality  |
| `level_dem` |     2 | Low democratic quality       |
| `level_dem` |     3 | Moderate democratic quality  |
| `level_dem` |     4 | High democratic quality      |
| `level_dem` |     5 | Very high democratic quality |

Higher values indicate more democratic provincial environments, while lower values represent contexts with stronger hybrid or hegemonic features.

## Dependent Variable 1: Conversational Self-Censorship

### Conceptual Meaning

The primary indicator of self-censorship captures interpersonal political discussion. Talking about politics with friends is treated as a socially visible form of expression in which individuals may anticipate disagreement, criticism, reputational costs, or political exposure.

Lower willingness to discuss politics is interpreted as greater **conversational self-censorship**.

### Variable Construction

The outcome is constructed from World Values Survey item `Q200`, which measures how frequently respondents talk about politics with friends.

| Constructed Variable | Original Item | Coding                                                                              |
| -------------------- | ------------- | ----------------------------------------------------------------------------------- |
| `Q200_dicho`         | `Q200`        | `1` = discusses politics frequently or occasionally; `0` = never discusses politics |

Responses coded as missing in the original data are recoded as `NA` in the analytical workflow.

### Modeling Strategy

`Q200_dicho` is modeled using multilevel logistic regression with province-level random intercepts.

A positive coefficient for `level_dem` indicates that respondents in more democratic provinces are more likely to report talking about politics with friends, consistent with lower conversational self-censorship.

## Dependent Variable 2: Survey-Based Self-Censorship

### Conceptual Meaning

The second indicator captures nonresponse to politically sensitive survey items. Nonresponse is treated as a probabilistic indicator of expressive reticence in a private survey setting.

Because item nonresponse may also reflect uncertainty, lack of information, or individual response tendencies, this measure is interpreted cautiously as an indicator of **survey-based self-censorship**, rather than as a direct observation of intentional silence.

### Thematic Groups of Sensitive Items

The analysis organizes sensitive political items into three domains.

#### Group A: Corruption Perceptions

| Constructed Variable | Original Item Group                      | Number of Items |
| -------------------- | ---------------------------------------- | --------------: |
| `na_count_A`         | `Q115_dicho`, `Q117_dicho`, `Q118_dicho` |               3 |

This group captures nonresponse to items related to perceived corruption involving local authorities, media or journalists, and bribery or favors associated with obtaining services.

#### Group B: Offline Political Action

| Constructed Variable | Original Item Group                                    | Number of Items |
| -------------------- | ------------------------------------------------------ | --------------: |
| `na_count_B`         | `Q209_dicho`, `Q210_dicho`, `Q211_dicho`, `Q212_dicho` |               4 |

This group captures nonresponse to items related to offline political action, including signing petitions, joining boycotts, attending lawful demonstrations, and joining unofficial strikes.

#### Group C: Online Political Action

| Constructed Variable | Original Item Group                                    | Number of Items |
| -------------------- | ------------------------------------------------------ | --------------: |
| `na_count_C`         | `Q217_dicho`, `Q218_dicho`, `Q219_dicho`, `Q220_dicho` |               4 |

This group captures nonresponse to items related to political action in online settings.

### Count Construction

For each respondent, the analytical workflow counts the number of missing responses across sensitive items within each domain:

| Variable         | Construction                                                 | Range |
| ---------------- | ------------------------------------------------------------ | ----: |
| `na_count_A`     | Number of nonresponses across corruption items               |   0–3 |
| `na_count_B`     | Number of nonresponses across offline political action items |   0–4 |
| `na_count_C`     | Number of nonresponses across online political action items  |   0–4 |
| `na_count_total` | Sum of nonresponses across all three domains                 |  0–11 |

### Modeling Strategy

Each thematic group is analyzed using a separate binomial multilevel model. The outcome is the number of nonresponses within the group relative to the fixed number of sensitive items in that domain.

The models estimate the probability of item nonresponse within each political domain, conditional on subnational democratic quality and individual-level covariates.

A negative coefficient for `level_dem` indicates that respondents in more democratic provinces have a lower probability of nonresponse to politically sensitive items, consistent with lower survey-based self-censorship.

## Robustness Operationalizations

### DV1: Single-Level Logistic Regression

The conversational self-censorship model is re-estimated using single-level logistic regression without province-level random effects. This specification evaluates whether the relationship between subnational democracy and political discussion depends on the multilevel structure of the main model.

### DV2: Binary Indicator of Any Sensitive-Item Nonresponse

For DV2, an alternative binary measure collapses nonresponse across all three sensitive-item domains.

| Constructed Variable | Coding                                                                                                                                        |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `na_any`             | `1` = respondent leaves at least one sensitive item unanswered across all domains; `0` = respondent provides responses to all sensitive items |

This alternative specification captures the presence of any survey-based self-censorship rather than its domain-specific distribution.

## Individual-Level Controls

The analytical workflow constructs individual-level variables capturing political engagement, social embeddedness, information exposure, ideology, and sociodemographic characteristics.

| Constructed Variable                                                             | Concept                        | Coding Summary                                                                                                 |
| -------------------------------------------------------------------------------- | ------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| `org_any`                                                                        | Membership in any organization | `1` = active member of at least one organization; `0` = otherwise                                              |
| `Q199_dicho`                                                                     | Political interest             | `1` = very or rather interested; `0` = not very or not at all interested                                       |
| `Q201_dicho`–`Q208_dicho`                                                        | Information source exposure    | `1` = daily, weekly, or monthly use; `0` = less than monthly or never                                          |
| `Q209_dicho`–`Q212_dicho`, `Q215_dicho`, `Q216_dicho`, `Q217_dicho`–`Q220_dicho` | Political action indicators    | `1` = have done or might do; `0` = would never do                                                              |
| `Q240_dicho`                                                                     | Ideology                       | `1` = left placement; `0` = right placement                                                                    |
| `X003R2_r`                                                                       | Age category                   | `1` = 16–29; `2` = 30–49; `3` = 50 and over                                                                    |
| `Q260_r`                                                                         | Sex                            | `1` = male; `0` = female                                                                                       |
| `Q275_r`                                                                         | Education                      | `0` = no/early education; `1` = primary or secondary; `2` = post-secondary or tertiary; `3` = higher education |

## Data Merge and Analytical Dataset

The World Values Survey Argentina sample is merged with SDI values using province identifiers. The final analytical dataset includes respondents from 13 Argentine subnational units:

* CABA
* Buenos Aires
* Catamarca
* Chaco
* Chubut
* Córdoba
* Corrientes
* La Rioja
* Mendoza
* Salta
* San Luis
* Santa Fe
* Tucumán

The processed analytical dataset is saved locally as:

```text
data/processed/thesis_analysis_data.rds
```

Processed datasets and source microdata are not included in the public repository.
