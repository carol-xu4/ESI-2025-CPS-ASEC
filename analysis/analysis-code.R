## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata, readr)

# Set working directory ----------------------------------------------------
setwd("C:/Users/CarolXu/OneDrive - Cato Institute/Desktop/CPS ASEC")

# Read in data -------------------------------------------------------------
ppdata = read.csv("data/output/ppdata.csv")

# How many non-elderly workers (aged 18-64) are on ESI.
ppdata %>% filter(WORKYN == 1) %>%
    summarise(esi_workers = sum(NOW_GRP == 1))

ppdata %>% filter(WORKYN == 1) %>%
    summarise(esi_workers_pop = sum(MARSUPWT[NOW_GRP == 1]))

#  How many non-elderly workers (aged 18-64) are on ESI from their own employer. 