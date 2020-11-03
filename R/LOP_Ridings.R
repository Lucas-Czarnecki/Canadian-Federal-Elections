# ==== Canadian Federal Election Data on Ridings from the Library of Parliament ====

# Author: Lucas Czarnecki 

# Description: This script was written to transform available data on federal election ridings housed on the Library of Parliament's public database into formats that match other data in this repository. 

# Source of data: https://lop.parl.ca/sites/ParlInfo/default/en_CA/ElectionsRidings/Ridings

# ---- Import Data & Packages ----

# Load necessary packages.
if(!require(pacman)) install.packages("pacman")
pacman::p_load(readxl, dplyr)

# Import raw data from Library of Parliament (LOP). Data were manually exported from the LOP as an excel spreadsheet. By default `[Currently Active] Equals 'Active'` is selected. This filter must be deselected to include ridings with end dates. 
FED_Ridings <- read_excel("~/GitHub/Canadian-Federal-Elections/data/raw/ParlinfoRidings.xlsx")

# ---- Process Data ----

# Rename columns to enforce a consistent naming scheme with other data in this repository.
FED_Ridings <- FED_Ridings %>% 
  rename(Constituency = Name,
         Province_Territory = Province,
         Start_Date = `Start Date`,
         End_Date = `End Date`,
         Currently_Active = `Currently Active`)

# Assign appropriate variable class for dates.
FED_Ridings$Start_Date <- as.Date(FED_Ridings$Start_Date)
FED_Ridings$End_Date <- as.Date(FED_Ridings$End_Date)

# Assign appropriate variable class for factors.
FED_Ridings$Province_Territory <- factor(FED_Ridings$Province_Territory, levels = c("British Columbia", "Alberta", "Saskatchewan", "Manitoba", "Ontario", "Quebec", "Newfoundland and Labrador", "New Brunswick", "Nova Scotia", "Prince Edward Island", "Yukon", "Northwest Territories", "Nunavut"))
FED_Ridings$Constituency <- as.factor(FED_Ridings$Constituency)
FED_Ridings$Region <- as.factor(FED_Ridings$Region)
FED_Ridings$Currently_Active <- as.factor(FED_Ridings$Currently_Active)

# Save data.
write.csv(FED_Ridings, file="~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/FED_Ridings.csv", row.names=FALSE, fileEncoding = "UTF-8")
saveRDS(FED_Ridings,  file="~/GitHub/Canadian-Federal-Elections/data/cleaned/supplementary/FED_Ridings.Rds")

# ___ end ___