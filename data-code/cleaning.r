## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata, readr)

# Set working directory ----------------------------------------------------
setwd("C:/Users/CarolXu/OneDrive - Cato Institute/Desktop/CPS ASEC")

# Read in data -------------------------------------------------------------
# replicate weights
repweights = read.csv("data/input/asec_csv_repwgt_2025.csv")

# household-level data
hhpub = read.csv("data/input/hhpub25.csv")

# family-level data
ffpub = read.csv("data/input/ffpub25.csv")

# person-level data
pppub = read.csv("data/input/pppub25.csv")

# Selecting Variables ------------------------------------------------------
ppdata = pppub %>% select(
    PERIDNUM, PH_SEQ, P_SEQ, A_LINENO,              # IDs 
    A_AGE, A_SEX, PRDTRACE, PEHSPNON, A_MARITL,     # demographics
    FAMREL, A_FAMREL, A_HGA, A_PFREL,               # family / education
    WORKYN, WRK_CK, PEMLR, CLWK, PEIO1COW,          # employment
    ERN_SRCE, ERN_VAL, PTOTVAL,                     # income
    COV, COV_MULT_CYR, PRIV, PUB,                   # any insurance
    GRP, OWNGRP, DEPGRP, OUTGRP,                    # ESI (past year)
    NOW_GRP, NOW_OWNGRP, NOW_DEPGRP,                # ESI (current)
    ESIOFFER, ESICOULD,                             # ESI offer / eligibility
    ESITAKE1, ESITAKE2, ESITAKE3, ESITAKE4,         # reasons not take ESI
    ESITAKE5, ESITAKE6, ESITAKE7, ESITAKE8,         
    PEOFFER, PECOULD,                               # alt offer
    PEWNELIG1, PEWNELIG2, PEWNELIG3, PEWNELIG4,     # alt eligibility / take
    PEWNELIG5,PEWNELIG6, PEWNTAKE1, PEWNTAKE2, PEWNTAKE3,
    PEWNTAKE4, PEWNTAKE5, PEWNTAKE6, PEWNTAKE7, PEWNTAKE8,                         
    DIR, MRK, MRKS, NONM,                           # private non-ESI
    CAID, MCAID, MCARE,                             # public coverage
    MIL, VACARE, CHAMPVA, PCHIP, IHSFLG,            # other public coverage
    HEA,                                            # health
    MOOP,                                           # health spending
    PERIDNUM, MARSUPWT                              # weight
)

# Recode MARSUPWT variable (2 implied decimals) & Filter age 18-64 
ppdata = ppdata %>%
    mutate(MARSUPWT = MARSUPWT / 100) 

# Rewrite to Output 
write_csv(ppdata, "data/output/ppdata.csv")

