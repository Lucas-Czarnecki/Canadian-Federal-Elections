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

# Create a combined key that can distinguish between distinct constituencies with identical names but located in different provinces.
FED_1867_present$Combined_Key <- paste(FED_1867_present$Constituency, FED_1867_present$Province_Territory, sep = ", ")

# 1. Create a summary table of constituency-level results.
Summary_of_Ridings <- FED_1867_present %>% 
  group_by(Election_Date, Election_Type, Parliament, Constituency, Province_Territory, Combined_Key) %>% 
  summarise(Number_of_Candidates = length(Candidate), Number_of_Parties = length(unique(Political_Affiliation)), District_Magnitude = length(Result[Result=="Elected" |Result== "Elected (Acclamation)" ]), Valid_Votes = sum(Votes), .groups='drop')

# Note: the number of parties includes independents and those who ran as "not affiliated". These are distinct categories in the Canada Elections Act. Note also that the number of parties is an approximation as historically many candidates' political affiliations are `Unknown`. 

# 2. Create a summary table of elections-level results.  
Summary_of_Elections <- Summary_of_Ridings %>% 
  group_by(Election_Date, Election_Type) %>% 
  summarise(Number_of_Ridings = length(unique(Combined_Key)), Number_of_Seats = sum(District_Magnitude), Number_of_Candidates = sum(Number_of_Candidates), Total_Valid_Votes = sum(Valid_Votes), .groups='drop')

# Obtain number of political parties by election. 
Summary_of_Parties <- FED_1867_present %>% 
  group_by(Election_Date, Election_Type, Parliament) %>% 
  summarise(Number_of_Parties = length(unique(Political_Affiliation)), .groups='drop')

# Match the number of parties to election-level results.
Summary_of_Elections$Number_of_Parties <- Summary_of_Parties$Number_of_Parties[match(Summary_of_Elections$Election_Date, Summary_of_Parties$Election_Date)]

# Select preferred column order.
Summary_of_Elections <- Summary_of_Elections %>% 
  select(Election_Date, Election_Type, Number_of_Ridings, Number_of_Seats, Number_of_Candidates, Number_of_Parties, Total_Valid_Votes)

# ---- Export Data ----

# Constituency-level summary.
saveRDS(Summary_of_Ridings, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/Summary_of_Ridings.Rds")
write.csv(Summary_of_Ridings, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/Summary_of_Ridings.csv", fileEncoding = "UTF-8", row.names = FALSE)

# Elections-level summary.
saveRDS(Summary_of_Elections, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/Summary_of_Elections.Rds")
write.csv(Summary_of_Elections, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/Summary_of_Elections.csv", fileEncoding = "UTF-8", row.names = FALSE)

# ___ end ___