# ==== Canadian Federal Election Data from the Library of Parliament ====

# Description: This script was written to transform available federal election results (for general and by-elections) housed on the Library of Parliament's public database into formats that are easier for researchers to read and analyze. The script transforms messy excel data into long-formatted file(s) - available in csv and Rds formats. 

# Source: https://lop.parl.ca/sites/ParlInfo/default/en_CA/ElectionsRidings/Elections

# ---- Raw Data / Packages  ----

# Load packages. 
if(!require(pacman)) install.packages("pacman")
pacman::p_load(readxl, tidyverse, zoo)

# Import raw data from Library of Parliament (LOP). Data were manually exported from the LOP as an excel spreadsheet. Only one filter/selection was applied; `Column Chooser` to remove the `picture` column. 
FED_1867_present <- read_excel("~/GitHub/Canadian-Federal-Elections/data/raw/FED_1867-present_elections_(Library_of_Parliament).xlsx")

# Rename columns using a program-friendly format.
FED_1867_present <- FED_1867_present %>% 
  rename(Province_Territory = `Province or Territory`,
         Political_Affiliation = `Political Affiliation`)

# ---- Clean Data / Create New Variables ----

# 1. Create variable `Parliament`.
FED_1867_present <- FED_1867_present %>% 
  separate(Province_Territory, into = c("Province_Territory", "Parliament"), sep = "Parliament: ") 

# Replace missing values with non-NA prior.
FED_1867_present$Parliament <- na.locf(FED_1867_present$Parliament)

# Remove blank rows.
FED_1867_present <- subset(FED_1867_present, Province_Territory != "")

# 2. Create variable `Type`
FED_1867_present <- FED_1867_present %>% 
  separate(Province_Territory, into = c("Province_Territory", "Election_Type"), sep = "Type of Election: ") 

# Replace missing values with non-NA prior.
FED_1867_present$Election_Type <- na.locf(FED_1867_present$Election_Type)

# Remove blank rows.
FED_1867_present <- subset(FED_1867_present, Province_Territory != "")

# 3. Create variable `Date`.
FED_1867_present <- FED_1867_present %>% 
  separate(Province_Territory, into = c("Province_Territory", "Election_Date"), sep = "Date of Election: ") 
  
# Convert to date format.
FED_1867_present$Election_Date <- as.Date(FED_1867_present$Election_Date)

# Replace missing values with non-NA prior.
FED_1867_present$Election_Date <- na.locf(FED_1867_present$Election_Date)

# Remove blank rows.
FED_1867_present <- subset(FED_1867_present, Province_Territory != "")

# ---- Additional Data Processing ----

# Assign appropriate variable class.
FED_1867_present$Province_Territory <- factor(FED_1867_present$Province_Territory, levels = c("British Columbia", "Alberta", "Saskatchewan", "Manitoba", "Ontario", "Quebec", "Newfoundland and Labrador", "New Brunswick", "Nova Scotia", "Prince Edward Island", "Yukon", "Northwest Territories", "Nunavut"))
FED_1867_present$Election_Type <- as.factor(FED_1867_present$Election_Type)
FED_1867_present$Parliament <- as.factor(FED_1867_present$Parliament)
FED_1867_present$Constituency <- as.factor(FED_1867_present$Constituency)
FED_1867_present$Gender <- as.factor(FED_1867_present$Gender)
FED_1867_present$Political_Affiliation <- as.factor(FED_1867_present$Political_Affiliation)
FED_1867_present$Result <- as.factor(FED_1867_present$Result)

# ---- Export Data ----

# 1. Create Master File.
saveRDS(FED_1867_present, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/master/FED_1867_present.Rds")
write.csv(FED_1867_present, file = "~/GitHub/Canadian-Federal-Elections/data/cleaned/master/FED_1867_present.csv", row.names = FALSE, fileEncoding = "UTF-8")

# 2. Create Yearly Reports for General Elections and Provincial Summaries of By-elections.

# 2a. General Elections. 
# Set working directory.
setwd("~/GitHub/Canadian-Federal-Elections/data/cleaned/general_elections")

# Subset General Elections.
Fed_General <- FED_1867_present %>% 
  subset(Election_Type == "General") %>% 
  droplevels()

# Split dataframe into a list according to `Election_Date` year.
Fed_General <- split(Fed_General, list(Fed_General$Election_Date))

# Write a csv file for each general election by `Election_Date`.
for (Election_Date in names(Fed_General)) {
  write.csv(Fed_General[[Election_Date]], paste0(Election_Date, ".csv"), row.names = FALSE, fileEncoding = "UTF-8")
}

# 2b. By-Elections 
setwd("~/GitHub/Canadian-Federal-Elections/data/cleaned/by_elections")

# Subset By-Elections.
Fed_By_Elections <- FED_1867_present %>% 
  subset(Election_Type == "By-Election") %>% 
  droplevels()

# Split dataframe into a list according to `Election_Date` year.
Fed_By_Elections <- split(Fed_By_Elections, list(Fed_By_Elections$Province_Territory))

# Write a csv for by-elections by `Province_Territory`.
for (Province_Territory in names(Fed_By_Elections)) {
  write.csv(Fed_By_Elections[[Province_Territory]], paste0(Province_Territory, ".csv"), row.names = FALSE, fileEncoding = "UTF-8")
}

# ___ end ___