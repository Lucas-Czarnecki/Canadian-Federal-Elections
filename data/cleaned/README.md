# The Data 

Data are organized across three folders. Users who want to work with the entire data set will find the most relevant files in the `master` folder. This folder contains the entire cleaned LOP data set as either a .csv or .Rds file. 

Folders `by-elections` and `general-elections` separate data according to `Election_Type`. The former organizes by-elections according to province or territory with each file containing every by-election that took place within that area. The latter saves results on every general election by election date. 

## Variables 

The data are candidate-level vote totals where each row pertains to the total votes that a candidate received in a given election. The following variables are available:

| Variable      | Description     |
| :---        | :---- |
| `Province_Territory`  |  Is the province or territory where the candidate ran for office |
| `Election_Date`  |  Is the election date of the general or by-election  |
| `Election_Type`  |  Consists of two values; either `General` or `By-Election`  |
| `Parliament`  |  Records the session of Parliament |
| `Constituency`  |  Records in which electoral division the candidate ran for office |
| `Candidate`  |  Records the candidate's full name (last name, first name) |
| `Gender`  |  Consists of three variables; namely, "Man", "Woman" or "Other Gender Identity" |
| `Occupation`  |  The candidate's occupation at the time of running for office |
| `Political_Affiliation`  |  Records (at the time of the election) the name of the political party that a candidate was registered to or "Independent" if the candidate ran unaffiliated |
| `Result`  | Indicates the electoral result for the candidate with one of three possible outcomes; namely, "Elected", "Defeated", or "Elected (Acclamation)" |
| `Votes`  | Records the total number of valid votes a candidate received. Note that vote totals for candidates who were elected through acclamation are recorded as 0. |
| | |

## Help wanted

Currently, there does not appear to be any official federal government record of electors at the constituency-level. It is not possible, therefore, to calculate voter turnout from these data. 🥺

If you are interested in this kind of research or know about a **digital(!)** data set that could be used to match the total number of electors to the LOP data set, please reach out. 

📧: lczarnec@ucalgary.ca

