# COVID-MS Capstone — v0.1 working prototype

Open `COVID-MS-Capstone.Rproj` in RStudio. Run from project root:

```r
install.packages(c('readr','dplyr','tibble','ggplot2','knitr','rmarkdown','scales','renv'))
source('R/run_pipeline.R')
rmarkdown::render('report.Rmd')
```

The pipeline downloads the Cambridge CSV if absent. If download fails, manually download the exact CSV from https://github.com/CambridgeICE-HDS/MSt-Healthcare-Data-Science/tree/main/Datasets/COVID-MS and place it in data/raw/. Review source manifest and verify the published checksum before final submission. R >= 4.1 required. Run `renv::init()` and `renv::snapshot()` after successful execution; commit the generated lockfile. On another machine use `renv::restore()`.

Private GitHub repository: create an empty private repo, then in the RStudio Terminal run `git init`, `git add .`, `git commit -m "Initial capstone prototype"`, `git branch -M main`, `git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO.git`, `git push -u origin main`. Do not commit raw or processed participant data. Review licence and university AI policy. Use small commits and descriptive messages. Do not publish assessment material.

This prototype has not been executed in R in the authoring environment. Verify every chunk locally, review definitions and decisions, and independently write and defend the final submission. The HTML preview is not a knitted report. Required final deliverables include the actual knitted report, Rmd, ARD, complete metadata, phenotype specification, instructions, supporting scripts, abstract, coversheet, and Safe Researcher certificate. Include the required Torabi & English et al. (2026) reference after verifying its bibliographic details.
