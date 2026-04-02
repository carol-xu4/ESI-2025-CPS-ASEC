## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata, readr)

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
        worker = ifelse(WORKYN == 1, "Worker", "Non-worker"),
        esi = ifelse(NOW_GRP == 1, "On ESI", "Not on ESI")) %>%
    group_by(worker, esi) %>%
    summarise(
        raw_n = n(), 
        pop_n = sum(MARSUPWT), 
        .groups = "drop")

write_csv(esiadults, "results/esi_adults.csv")

esikids = ppdata %>% filter(A_AGE < 18) %>%
    mutate( 
        worker = "Child", 
        esi = ifelse(NOW_GRP == 1, "On ESI", "Not on ESI")) %>%
    group_by(worker, esi) %>%
    summarise(
        raw_n = n(), 
        pop_n = sum(MARSUPWT), 
        .groups = "drop")

esipop = bind_rows(esiadults, esikids)
write_csv(esipop, "results/esi_pop.csv")

# Population on ESI by age

#  How many non-elderly workers (aged 18-64) are on ESI from their own employer. 
