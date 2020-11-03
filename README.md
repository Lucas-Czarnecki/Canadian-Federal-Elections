# Canadian Federal Elections from 1867 to the Present (Library of Parliament)

The purpose of this repository is to provide the public with candidate-level federal election results from the Canadian Library of Parliament in formats that are easy for researchers, and other interested parties, to access and analyze.

## The Raw Data

The data in this repository all come from Canada's Library of Parliament (LOP). The original dataset is available through [**Parlinfo**](https://lop.parl.ca/sites/ParlInfo/default/en_CA/) under [Elections and Candidates](https://lop.parl.ca/sites/ParlInfo/default/en_CA/ElectionsRidings/Elections). From here users can filter and export data in excel format.

Data from the LOP consists of candidate-level vote totals for all individuals who ran for federal office since 1867. 

> Note: The Government of Canada's (GOC) website hosts a similar data set titled ["History of the Federal Electoral Ridings, 1867-2010"](https://open.canada.ca/data/en/dataset/ea8f2c37-90b6-4fee-857e-984d3060184e). This data set, however, does not appear to be maintained while the LOP's data set is regularly updated. The GOC's data also does not have a complete record of candidate's gender while the LOP's data does.

## Cleaned Data

This repository processes the excel formatted data from the LOP into formats that are more convenient for social scientific research. More specifically, the cleaned data wrangles candidate-level election results into long-formatted .csv files and a master .Rds file for R-users. The cleaned data also features modified variables that help facilitate data exploration and analysis. You will find the modified data and more information on the variables in [this folder](https://github.com/Lucas-Czarnecki/Canadian-Federal-Elections/tree/main/data/cleaned).

The scripts used to process the raw data can be found in the folder, [R](https://github.com/Lucas-Czarnecki/Canadian-Federal-Elections/tree/main/R).  

## Credit and Copyright

Canada's [Library of Parliament (LOP)](https://lop.parl.ca/sites/ParlInfo/default/en_CA/ElectionsRidings/Elections) is the source of all data in this repository. Data are, therefore, subject to the same [Copyright Act](https://laws-lois.justice.gc.ca/eng/acts/C-42/index.html) as the LOP and is subject to change. The data in this repository are released for **personal and non-commercial use** in accordance with the Copyright Act (R.S.C., 1985, c. C-42).

## Disclaimer

This repository makes no warranties regarding the accuracy of this information and disclaims any liability for damages resulting from its use. The data contained herein are subject to the Library of Parliament's terms of use and may be subject to change. 

