## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, ggthemes, dplyr, lubridate, stringr, readxl, data.table, gdata, readr)

# Set working directory ----------------------------------------------------
setwd("C:/Users/CarolXu/OneDrive - Cato Institute/Desktop/CPS ASEC")

# Read in data -------------------------------------------------------------
ppdata = read.csv("data/output/ppdata.csv")

# How many non-elderly workers (aged 18-64) are on ESI.
esi_workers_raw = ppdata %>%
    filter(A_AGE >= 18 & A_AGE <= 64, WORKYN == 1) %>%
    summarise(esi_workers_raw = sum(NOW_GRP == 1))

esi_workers_pop = ppdata %>% 
    filter(A_AGE >= 18 & A_AGE <= 64, WORKYN == 1) %>%
    summarise(esi_workers_pop = sum(MARSUPWT[NOW_GRP == 1]))

# Non-workers on ESI (age 18-64)
esi_nowork_raw = ppdata %>%
    filter(A_AGE >= 18 & A_AGE <= 64, WORKYN == 2) %>%
    summarise(esi_nowork_raw = sum(NOW_GRP == 2))

# Non-workers on ESI (under age 18)
esi_nowork_pop = ppdata %>%
    filter(A_AGE >= 18 & A_AGE <= 64, WORKYN == 2) %>%
    summarise(esi_nowork_pop = sum(MARSUPWT[NOW_GRP == 2]))

# Population on ESI by worker status (age 18-64)
esiadults = ppdata %>% filter(A_AGE >= 18 & A_AGE <= 64) %>%
    mutate( 
        work_status = ifelse(WORKYN == 1, "Worker", "Non-worker"),
        esi = ifelse(NOW_GRP == 1, "On ESI", "Not on ESI")) %>%
    group_by(work_status, esi) %>%
    summarise(
        raw_n = n(), 
        pop_n = sum(MARSUPWT), 
        .groups = "drop")

write_csv(esiadults, "results/esi_adults.csv")

esikids = ppdata %>% filter(A_AGE < 18) %>%
    mutate( 
        work_status = "Child", 
        esi = ifelse(NOW_GRP == 1, "On ESI", "Not on ESI")) %>%
    group_by(work_status, esi) %>%
    summarise(
        raw_n = n(), 
        pop_n = sum(MARSUPWT), 
        .groups = "drop")

esipop = bind_rows(esiadults, esikids)
write_csv(esipop, "results/esi_pop.csv")

ggplot(esipop, aes(x = work_status, y = pop_n / 1e6, fill = esi)) +
    geom_col(position = "dodge") +
    scale_y_continuous(breaks = seq(0, 150, by = 20)) +
    scale_fill_manual(
        values = c("On ESI" = "#3043B4", "Not on ESI" = "#7C756D")) +
    labs(
        title = "Employer-Sponsored Insurance by Work Status (2025)",
        subtitle = "CPS ASEC, ages 0-64",
        caption = "Source: U.S. Census Bureau; Current Population Survey Annual Social and Economic Supplement (2025)",
        x = NULL, y = "Population (millions)",
        fill = NULL) +
    theme_stata() +
    theme(
        plot.title = element_text(size = 40, face = "bold", hjust = 0, color = "black"),
        plot.subtitle = element_text(size = 30, color = "black", margin = margin(b = 12), hjust = 0),
        legend.position = "right",
        legend.text = element_text(size = 20),
        axis.title.y = element_text(size = 30),
        axis.text.x = element_text(size = 35), 
        axis.text.y = element_text(size = 35, angle = 0, vjust = 0.5),
        plot.caption = element_text(size = 12),
        plot.background = element_rect(fill = "white"))
ggsave("results/ESI_plot.png", width = 20, height = 15)

# All on ESI (age 0-85) (other public coverage grouped)
all_esi = ppdata %>%
  mutate(
    coverage = case_when(
      NOW_GRP == 1 ~ "ESI",
      NOW_MRK == 1 ~ "Marketplace",
      NOW_DIR == 1 ~ "Direct Purchase",
      NOW_MCAID == 1 ~ "Medicaid",
      NOW_MCARE == 1 ~ "Medicare",
      NOW_VACARE == 1 | NOW_CHAMPVA == 1 | NOW_MIL == 1 ~ "Other Public",
      NOW_IHSFLG == 1 ~ "IHS Only",
      NOW_COV == 0 ~ "Uninsured",
      TRUE ~ "Other"))

esi_total_counts = all_esi %>%
    group_by(coverage) %>%
    summarise( 
        raw_n = n(), 
        pop_n = sum(MARSUPWT), 
        .groups = "drop") %>% arrange(desc(pop_n))
write_csv(esi_total_counts, "results/coverage_total_counts.csv")

#  How many non-elderly workers (aged 18-64) are on ESI from their own employer. 
esiown = ppdata %>% filter(A_AGE >= 18 & A_AGE <= 64, WORKYN == 1) %>%
    mutate(
        esi_origin = ifelse(NOW_OWNGRP == 1, "Own Employer", "Not Own Employer")) %>%
    group_by(esi_origin) %>%
    summarise( 
        raw_n = n(),
        pop_n = sum(MARSUPWT), 
        .groups = "drop")
write.csv(esiown, "results/esi_own.csv")

ggplot(esiown, aes(x = esi_origin, y = pop_n / 1e6, fill = esi_origin)) +
    geom_col(position = "dodge") +
    scale_y_continuous(breaks = seq(0, 150, by = 20)) +
    scale_fill_manual(
        values = c("Own Employer" = "#3043B4", "Not Own Employer" = "#7C756D")) +
    labs(
        title = "Workers on ESI by ESI Origin (2025)",
        subtitle = "CPS ASEC, ages 18-64",
        caption = "Source: U.S. Census Bureau; Current Population Survey Annual Social and Economic Supplement (2025)",
        x = NULL, y = "Population (millions)",
        fill = NULL) +
    theme_stata() +
    theme(
        plot.title = element_text(size = 40, face = "bold", hjust = 0, color = "black"),
        plot.subtitle = element_text(size = 30, color = "black", margin = margin(b = 12), hjust = 0),
        legend.position = "right",
        legend.text = element_text(size = 20),
        axis.title.y = element_text(size = 30),
        axis.text.x = element_text(size = 35), 
        axis.text.y = element_text(size = 35, angle = 0, vjust = 0.5),
        plot.caption = element_text(size = 12),
        plot.background = element_rect(fill = "white"))
ggsave("results/ESI_origin.png", width = 20, height = 15)

# How many non-elderly workers (aged 18-64) were eligible for ESI and offered ESI from their employer but did not take it. (We call this group “decliners”)


# And crucially, how many “decliners” are on ESI from another family member.
