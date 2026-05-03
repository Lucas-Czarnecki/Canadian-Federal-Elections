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
import requests
import json
import pandas as pd
import os

#%%
# Create function to scrape LOP data on federal general and by-elections
def fetch_all_elxns():
    url = "https://lop.parl.ca/ParlinfoWebApi/Parliament/GetCandidates"

    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/121.0.0.0 Safari/537.36"
        ),
        "Accept": "*/*",
        "Referer": "https://lop.parl.ca/",
        "Origin": "https://lop.parl.ca"
    }

    params = {"callback": "cb"}

    r = requests.get(url, headers=headers, params=params, timeout=(10, 120))
    r.raise_for_status()

    text = r.text
    json_str = text[text.find("(") + 1:text.rfind(")")]
    data = json.loads(json_str)

    df = pd.DataFrame(data)
    df["ElectionDate"] = pd.to_datetime(df["ElectionDate"], errors="coerce")

    return df

#%%
# Pull data from LOP
raw_elxns_df = fetch_all_elxns()
print(len(raw_elxns_df))

#%%
# Explore data
raw_elxns_df.dtypes

#%%
raw_elxns_df.columns
#%%
# Set path to raw data folder
root_path = os.path.dirname(os.getcwd())
raw_data_path = os.path.join(root_path, "data\\raw")
print(raw_data_path)

#%%
# save fed_elxn_df as csv
raw_elxns_df.to_csv(os.path.join(raw_data_path, "raw_fed_elxns.csv"), index=False)
