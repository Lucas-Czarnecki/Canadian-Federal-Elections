# AGENTS.md

Guidance for Codex and other AI coding agents working in this repository.

## Description

This repository provides cleaned, research-friendly Canadian federal election
results from 1867 to the present, based on Library of Parliament source data.

## Summary

The project converts raw Library of Parliament Excel exports into cleaned CSV
and RDS datasets, supplementary riding and election summaries, and a Shiny app
for interactive exploration and downloads.

## Project Context

- This is an R project for Canadian federal election data from the Library of Parliament.
- The `R/` directory contains data processing scripts.
- The `data/raw/` directory contains source Excel files.
- The `data/cleaned/` directory contains generated CSV and RDS outputs.
- The `shiny_app/` directory contains the Shiny dashboard and its deployment manifest.

## Working Rules

- Read `README.md` and the relevant folder README before changing behavior.
- Keep edits focused on the requested task.
- Do not reformat or rewrite unrelated scripts, data files, or generated outputs.
- Do not overwrite cleaned data, raw data, RDS files, or deployment files unless the task explicitly asks for regenerated outputs.
- Ask before adding new package dependencies or changing the project structure.
- Preserve existing data field names and file naming conventions unless a migration is requested.

## R And Shiny Expectations

- Prefer existing tidyverse-style patterns already used in the scripts.
- For data-processing changes, identify which generated files would need regeneration.
- For Shiny changes, verify that `shiny_app/app.R` can load its data and start locally when practical.
- If tests are not present, use targeted smoke checks such as sourcing modified R scripts or loading expected data files.

## Verification

- Report the exact commands run and whether they passed.
- If verification is skipped, explain why and name the most relevant command for the user to run.
- Before finishing, check `git status --short` and summarize only the files changed for the task.
