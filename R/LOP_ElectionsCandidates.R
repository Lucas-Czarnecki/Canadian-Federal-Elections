# ==== Canadian Federal Election Data from the Library of Parliament ====

# Author: Lucas Czarnecki

# Description: This script was written to transform available federal election results (for general and by-elections) housed on the Library of Parliament's public database into formats that are easier for researchers to read and analyze. The script transforms messy excel data into long-formatted file(s) - available in csv and Rds formats. 

# Source: https://lop.parl.ca/sites/ParlInfo/default/en_CA/ElectionsRidings/Elections

# ---- Import Data & Packages  ----

# Load packages. 
if(!require(pacman)) install.packages("pacman")
pacman::p_load(readxl, tidyverse, zoo)

# Import raw data from Library of Parliament (LOP). Data were manually exported from the LOP as an excel spreadsheet.
FED_1867_present <- read_excel("~/GitHub/Canadian-Federal-Elections/data/raw/electionsCandidates.xlsx")

# Rename columns using a program-friendly format. Identify the column `picture` as temporary. Online this column features a photo of the candidate. This column will be removed once other data are extracted. 
FED_1867_present <- FED_1867_present %>% 
  rename(Province_Territory = `Province or Territory`,
         Political_Affiliation = `Political Affiliation`,
         Temp = Picture)

# Replace NAs from temp column with `Province_Territory`.
FED_1867_present$Temp <- ifelse(is.na(FED_1867_present$Temp), FED_1867_present$Province_Territory, FED_1867_present$Temp) 

# ---- Clean Data  ----

# 1. Create variable `Parliament`.
FED_1867_present <- FED_1867_present %>% 
  separate(Temp, into = c("Temp", "Parliament"), sep = "Parliament: ") 

# Replace missing values with non-NA prior.
FED_1867_present$Parliament <- na.locf(FED_1867_present$Parliament)

# Remove blank rows.
FED_1867_present <- subset(FED_1867_present, Temp != "")

# 2. Create variable `Type`
FED_1867_present <- FED_1867_present %>% 
  separate(Temp, into = c("Temp", "Election_Type"), sep = "Type of Election: ") 

# Replace missing values with non-NA prior.
FED_1867_present$Election_Type <- na.locf(FED_1867_present$Election_Type)

# Remove blank rows.
FED_1867_present <- subset(FED_1867_present, Temp != "")

# 3. Create variable `Date`.
FED_1867_present <- FED_1867_present %>% 
  separate(Temp, into = c("Temp", "Election_Date"), sep = "Date of Election: ") 

# Convert to date format.
FED_1867_present$Election_Date <- as.Date(FED_1867_present$Election_Date)

# Replace missing values with non-NA prior.
FED_1867_present$Election_Date <- na.locf(FED_1867_present$Election_Date)

# Remove blank rows.
FED_1867_present <- subset(FED_1867_present, Temp != "")

# 4. Remove `Temp` column.
FED_1867_present$Temp <- NULL

# 5. Organize order of columns.
FED_1867_present <- FED_1867_present %>% 
  select("Province_Territory", "Election_Date", "Election_Type", "Parliament", "Constituency", "Candidate", "Gender", "Occupation", "Political_Affiliation", "Result","Votes")

# ---- Additional Data Processing ----

# 1. Assign appropriate variable class.
FED_1867_present$Province_Territory <- factor(FED_1867_present$Province_Territory, levels = c("British Columbia", "Alberta", "Saskatchewan", "Manitoba", "Ontario", "Quebec", "Newfoundland and Labrador", "New Brunswick", "Nova Scotia", "Prince Edward Island", "Yukon", "Northwest Territories", "Nunavut"))
FED_1867_present$Election_Type <- as.factor(FED_1867_present$Election_Type)
FED_1867_present$Parliament <- as.factor(FED_1867_present$Parliament)
FED_1867_present$Constituency <- as.factor(FED_1867_present$Constituency)
FED_1867_present$Gender <- as.factor(FED_1867_present$Gender)
FED_1867_present$Political_Affiliation <- as.factor(FED_1867_present$Political_Affiliation)
FED_1867_present$Result <- as.factor(FED_1867_present$Result)

# 2. Clean Candidates' names.

# Correct improper use of uppercase and punctuation marks. Multiple candidates' last names are recorded in all uppercase, which is inconsistent with most of the data. Punctuation marks are present in strings in apparent error.

# Create new variables to differentiate first, middle, and last names.
FED_1867_present <- FED_1867_present %>% 
  separate(col = Candidate, into = c("Last_Name", "First_Name"), sep = ", ", remove=FALSE, extra = "merge") %>% 
  separate(col = First_Name, into = c("First_Name", "Middle_Names"), sep = " ", extra = "merge")

# Remove redundant punctuation marks from names that appear to be the result of human error.
FED_1867_present$First_Name <- gsub(',','',FED_1867_present$First_Name)
FED_1867_present$Last_Name <- gsub(',','',FED_1867_present$Last_Name)
FED_1867_present$Middle_Names <- gsub(',','',FED_1867_present$Middle_Names)

# For first names, treat blank cells as missing values.
FED_1867_present$First_Name[FED_1867_present$First_Name == ""] <- NA

# If last name is in all uppercase then transform the length of the string such that only the first letter is capitalized.
FED_1867_present$Last_Name <- ifelse(str_detect(FED_1867_present$Last_Name, "^[:upper:]+$"), 
                                     stringr::str_to_title(FED_1867_present$Last_Name, locale = "en"), 
                                     FED_1867_present$Last_Name)

# Recreate `Candidate` combined key using cleaned first, middle, and last names.
FED_1867_present$Candidate <-  paste(FED_1867_present$Last_Name, FED_1867_present$First_Name, sep=", ") %>% 
  paste(FED_1867_present$Middle_Names, sep=" ") 

# Remove or replace missing values to tidy cleaned `Candidate` key.
FED_1867_present$Candidate <- gsub(", NA NA", ", (unknown)", FED_1867_present$Candidate)
FED_1867_present$Candidate <- gsub(" NA", "", FED_1867_present$Candidate)

# NOTE: The current script misses names that have spacing in between strings (e.g., DES BRISAY). Other names that were all uppercase may not return the correct spelling (e.g., "MACDONALD" becomes "Macdonald" and not "MacDonald"). With the latter cases, some names may only be fixed manually after consulting official documentation. 

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
