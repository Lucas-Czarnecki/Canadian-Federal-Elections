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

#%%
# get root folder
root_path = os.path.dirname(os.getcwd())
print(root_path)

#%%
# import all_fed_elxns.csv
raw_fed_elxns = pl.read_csv(f"{root_path}/data/raw/raw_fed_elxns.csv")
raw_fed_elxns

#%%
# Process raw data
clean_fed_elxns = raw_fed_elxns.with_columns()
clean_fed_elxns.head()

#%%
# sort by ParliamentNumber
clean_fed_elxns = clean_fed_elxns.sort("ParliamentNumber")
clean_fed_elxns.head()

#%%
# TODO 
# identify and remove empty columns