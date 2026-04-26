# Shiny App

This folder contains the Shiny dashboard for exploring and downloading the
Canadian federal election data in this repository.

The app lets users choose an election type and election date, view summary
statistics, compare party vote share, inspect constituency-level results, and
download filtered or complete datasets.

## Description

The Shiny app is an interactive front end for the cleaned Canadian federal
election dataset. It is intended for users who want to browse election results
without working directly with the CSV or RDS files.

## Summary

This folder includes the app code, the app-ready dataset, and deployment
metadata. The dashboard loads `shiny_data.Rds`, presents election-level and
constituency-level results, and provides download buttons for filtered or full
data exports.

## Folder Contents

- `app.R`: The Shiny application. This file defines the user interface, server
  logic, summary tables, vote-share plot, constituency selector, and download
  buttons.
- `shiny_data.Rds`: The R dataset loaded by the app at startup. The app expects
  this file to be available at `shiny_app/shiny_data.Rds`.
- `manifest.json`: Deployment metadata generated for Posit Connect or
  shinyapps.io-style deployment workflows. It records the app file, included
  data files, package dependencies, and checksums used by the deployment tool.

## Running The App Locally

Open the repository root in RStudio, or set your working directory to the
repository root before launching the app. The app uses the `here` package to
locate `shiny_app/shiny_data.Rds`, so running from the project root is the
safest option.

Required R packages are loaded in `app.R` with `pacman::p_load()`:

- `shiny`
- `shinythemes`
- `dplyr`
- `readr`
- `here`
- `ggplot2`
- `ggthemes`

To run the app from the R console:

```r
shiny::runApp("shiny_app")
```

The app will install `pacman` if it is missing, then use `pacman` to load the
other packages.

## Data Used By The App

`shiny_data.Rds` is the app-ready dataset. It is separate from the cleaned CSV
files so the dashboard can load one compact R object quickly.

The app expects the dataset to include fields such as:

- `Election_Type`
- `Election_Date`
- `Parliament`
- `Province_Territory`
- `Constituency`
- `Candidate`
- `Political_Affiliation`
- `Occupation`
- `Gender`
- `Votes`
- `Result`

If the cleaned data are regenerated, update `shiny_data.Rds` as needed before
deploying or sharing the app.

## Deployment Notes

The `manifest.json` file is generated deployment metadata. Do not edit it by
hand unless you know the deployment workflow requires a manual change.

To regenerate the manifest after changing app dependencies or bundled files,
run this from the `shiny_app` folder or with the correct app path:

```r
rsconnect::writeManifest(appPrimaryDoc = "app.R")
```

After changing `app.R` or `shiny_data.Rds`, test the app locally before
deploying.

## Maintenance Notes

- Keep `app.R` and `shiny_data.Rds` in sync. If the app references a column that
  is missing from `shiny_data.Rds`, the dashboard will fail at runtime.
- Avoid committing temporary files created during local Shiny sessions.
- Treat `shiny_data.Rds` as a generated app data file. Rebuild it from the
  cleaned data pipeline when possible rather than editing it directly.
