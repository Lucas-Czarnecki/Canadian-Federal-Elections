#%%
# jupytext:
#   formats: ipynb,py:percent
#   notebook_metadata_filter: kernelspec
#   text_representation:
#     extension: .py
#     format_name: percent
#     format_version: '1.3'
#     jupytext_version: 1.16.0
# kernelspec:
#   display_name: Python 3
#   language: python
#   name: python3
# ---

#%%
# import packages
import polars as pl
import os
import re

#%%
# get root folder
root_path = os.path.dirname(os.getcwd())
print(root_path)

#%%
# import all_fed_elxns.csv
raw_fed_elxns = pl.read_csv(f"{root_path}/data/raw/raw_fed_elxns.csv")
raw_fed_elxns.head()

#%%
# Prepare raw data for processing
clean_fed_elxns = raw_fed_elxns.with_columns()
clean_fed_elxns.head()

#%%
# Identify empty columns (to be
empty_columns = clean_fed_elxns.select([
    (pl.col(col).is_null().all()).alias(col) for col in clean_fed_elxns.columns
]).row(0)

# Get the names of all empty columns
empty_col_names = [col for col, is_empty in zip(clean_fed_elxns.columns, empty_columns) if is_empty]

print("Empty columns:", empty_col_names)

#%%
# Drop columns if in empty_col_names
clean_fed_elxns = clean_fed_elxns.drop(empty_col_names)
clean_fed_elxns.columns

#%%
# Assert that all rows in "IsPreliminary" column are False and drop column
assert not clean_fed_elxns.select(pl.col("IsPreliminary").any()).item()
clean_fed_elxns = clean_fed_elxns.drop("IsPreliminary")

#%%
# Tidy Column Names

# Add underscores between capital letters
clean_fed_elxns = clean_fed_elxns.rename(lambda col: re.sub(r'(?<=[a-z])([A-Z])', r'_\1', col).replace(" ", "_"))

clean_fed_elxns.columns

#%%
# Rename columns
clean_fed_elxns = clean_fed_elxns.rename({"Election_Id": "Election_ID",
                                          "Is_General": "Election_Type",
                                          "ElectionDate": "Election_Date",
                                          "ConstituencyId": "Constituency_ID",
                                          "ConstituencyEn": "Constituency_Name",
                                          "ConstituencyFr": "Constituency_Name_Fr",
                                          "ProvinceEn": "Province_Territory_Name",
                                          "ProvinceFr": "Province_Territory_Name_Fr",
                                          "DisplayName": "Display_Name",




                                          }

                                         )
#%%
# TODO look into variables:
# ElectionProcessCandidateID

#%%
# Summarize True and False counts in IsPreliminary
clean_fed_elxns.select(
    pl.col("IsPreliminary").value_counts()
)





#%%
# Sort rows by ParliamentNumber
clean_fed_elxns = clean_fed_elxns.sort("ParliamentNumber")
clean_fed_elxns.head()
