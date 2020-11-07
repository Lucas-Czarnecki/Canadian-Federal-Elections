# The Data 

Data are organized across three main folders (i.e., `by-elections`, `general-elections`, and `master`) as well as a `supplementary` folder. The first three folders contain election results from Parlinfo's [Elections and Candidates](https://lop.parl.ca/sites/ParlInfo/default/en_CA/ElectionsRidings/Elections) data set while the `supplementary` folder contains supplementary data from Parlinfo's [Ridings](https://lop.parl.ca/sites/ParlInfo/default/en_CA/ElectionsRidings/Ridings) data set.

Users who want to work with the entire data set of election results (i.e., Elections and Candidates) will find the most relevant files in the `master` folder. This folder contains cleaned election results from 1867 to the present within a single .csv or .Rds file. 

Folders `by-elections` and `general-elections` separate data according to `Election_Type`. The former organizes by-elections according to `Province_Territory` with each file containing every by-election that took place within a given province or territory. The latter saves results on every general election by `Election_Date`.

The folder `supplementary` records the name, start date, and end date of every federal riding from 1867 to the present represented in the House of Commons. Users will find the data in .csv and .Rds format. 

## Variables: Election Results

The data found in `by-elections`, `general-elections`, and `master` are candidate-level vote totals where each row pertains to the total votes that a candidate received in a given election. The following variables are available:

| Variable      | Description     |
| :---        | :---- |
| `Province_Territory`  |  Is the province or territory where the candidate ran for office |
| `Election_Date`  |  Is the election date of the general or by-election  |
| `Election_Type`  |  Consists of two values; either `General` or `By-Election`  |
| `Parliament`  |  Records the session of Parliament |
| `Constituency`  |  Records in which electoral division the candidate ran for office |
| `Candidate`  |  Records the candidate's full name (last name, first name middle name(s) ) |
| `Last_Name`  |  Records the candidate's last name |
| `First_Name`  |  Records the candidate's first name or "(unknown)" if there is no known record |
| `Middle_Names`  |  Records the candidate's middle name(s) or NA if not applicable |
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

