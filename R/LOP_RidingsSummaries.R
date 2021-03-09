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
List_Ridings <- FED_1867_present %>% 
  group_by(Election_Date, Election_Type, Parliament, Province_Territory, Constituency) %>% 
  summarise(.groups = 'drop')

# Create a combined key to take into consideration ridings located in different provinces but with identical names. 
List_Ridings$Combined_Key <- paste(as.character(List_Ridings$Election_Date), List_Ridings$Constituency, List_Ridings$Province_Territory, sep = ", ")

# Election-level results

# Subset for convenience.
FED_1867_present$Combined_Key <- paste(as.character(FED_1867_present$Election_Date), FED_1867_present$Constituency, FED_1867_present$Province_Territory, sep = ", ")

# Number of Ridings: Summarize the total number of ridings in each election. 
Expected_Ridings <- FED_1867_present %>% 
  group_by(Election_Date, Election_Type) %>% 
  summarise(Expected_Ridings = length(unique(Combined_Key)), .groups='drop')

# 2. Constituency-level results

# Number of Candidates: Summarize expected number of candidates in each riding.
Expected_Candidates <- FED_1867_present %>% 
  group_by(Election_Date, Election_Type, Parliament, Constituency, Province_Territory, Combined_Key) %>% 
  summarise(Expected_Candidates = length(Candidate), .groups='drop')

# District Magnitude: Summarize the number of seats contested in each riding.
Expected_DM <- FED_1867_present %>% 
  group_by(Election_Date, Election_Type, Parliament, Constituency, Province_Territory, Combined_Key) %>% 
  summarise(Expected_DM = length(Result[Result=="Elected" |Result== "Elected (Acclamation)" ]), .groups='drop')

# Concatenate constituency level summaries.
List_Ridings$Expected_Candidates <- Expected_Candidates$Expected_Candidates[match(List_Ridings$Combined_Key, Expected_Candidates$Combined_Key)]
List_Ridings$Expected_DM <- Expected_DM$Expected_DM[match(List_Ridings$Combined_Key, Expected_DM$Combined_Key)]

# ---- Export Data ----

# Expected number of ridings by general election. 
saveRDS(Expected_Ridings, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/Expected_Ridings.Rds")
write.csv(Expected_Ridings, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/Expected_Ridings.csv", fileEncoding = "UTF-8", row.names = FALSE)

# List of ridings by general election.
saveRDS(List_Ridings, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/List_Ridings.Rds")
write.csv(List_Ridings, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/List_Ridings.csv", fileEncoding = "UTF-8", row.names = FALSE)

# ___ end ___