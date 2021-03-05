# ==== List of Federal Ridings Based on Data from the Library of Parliament ====

# Author: Lucas Czarnecki

# Description: This script was written to identify unique ridings from Canadian general elections ranging from 1867 to the present based on data from the Library of Parliament. 

# ---- Import Data & Packages  ----

# Load packages. 
if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse)

# Load cleaned data from this repository.
FED_1867_present <- readRDS("~/GitHub/Canadian-Federal-Elections/data/cleaned/master/FED_1867_present.Rds")

# ---- Data Processing ----

# 1. Identify unique ridings by general election
List_Ridings<- FED_1867_present %>% 
  group_by(Election_Date, Election_Type, Parliament, Province_Territory, Constituency) %>% 
  summarise(.groups = 'drop')

# 2. Count the number of unique districts that appear in each general election.

# First create a combined key (i.e., riding + province)
# A combined key takes into consideration ridings located in different provinces but with identical names. 
List_Ridings$Combined_Key <- paste(List_Ridings$Constituency, List_Ridings$Province_Territory, sep = ", ")

# Summarize the number of ridings by general election. The variable `Expected` records the number of ridings expected in each election.
Expected_Ridings <- List_Ridings %>% 
  group_by(Election_Date, Election_Type) %>% 
  summarise(Expected_Ridings = length(unique(Combined_Key)), .groups='drop')

# ---- Export Data ----

# Expected number of ridings by general election. 
saveRDS(Expected_Ridings, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/Expected_Ridings.Rds")
write.csv(Expected_Ridings, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/Expected_Ridings.csv", fileEncoding = "UTF-8", row.names = FALSE)

# List of ridings by general election.
saveRDS(List_Ridings, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/List_Ridings.Rds")
write.csv(List_Ridings, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/List_Ridings.csv", fileEncoding = "UTF-8", row.names = FALSE)

# ___ end ___