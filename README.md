# COVID-MS Capstone: Analysis-Ready Dataset

## Project overview

This project develops and validates a reproducible analysis-ready dataset (ARD) for exploratory investigation of disease-modifying therapy (DMT) status, anti-CD20 exposure and reported COVID-19-compatible symptoms in people with multiple sclerosis (MS).

The project focuses on data quality, treatment phenotype construction, analytical cohort definition and model-readiness assessment. Logistic regression specifications are evaluated for computational feasibility; adjusted treatment effects are not estimated.

## Data source

The project uses the publicly available COVID-19 and MS dataset provided through the University of Cambridge Healthcare Data Science course.

The original dataset contains 1,141 records and 47 variables. The resulting ARD retains 1,141 records and 20 selected or derived variables.

## Requirements

- R and RStudio
- Internet access for the initial data download
- Required R packages, including `readr`, `dplyr`, `tibble`, `ggplot2`, `knitr`, `rmarkdown` and `scales`

## How to reproduce the project

1. Clone or download this repository.
2. Open `COVID-MS-Capstone.Rproj` in RStudio.
3. Set the project root as the working directory.
4. Install the required packages if they are not already available.
5. Run the pipeline from the R console:

   `source("R/run_pipeline.R")`

6. Render the report:

   `rmarkdown::render("report.Rmd")`

The pipeline downloads the source data if needed, performs data-quality assessment, constructs the ARD and generates validation outputs.

## Pipeline structure

The master script `R/run_pipeline.R` executes five numbered scripts in sequence:

1. `01_import.R` — source-data acquisition and import.
2. `02_audit.R` — data-quality and missingness assessment.
3. `03_prepare.R` — phenotype construction and ARD preparation.
4. `04_validate.R` — structural and logical validation.
5. `05_model_readiness.R` — assessment of proposed logistic regression specifications.

## Outputs

The workflow generates a processed ARD, supporting tables and validation results. The rendered report presents the methodological decisions, exploratory findings, limitations and conclusions.

## Interpretation

Reported COVID-19-compatible symptoms should not be interpreted as confirmed SARS-CoV-2 infection or disease severity. Exploratory comparisons do not establish causal treatment effects. Computational model readiness does not guarantee clinical validity or adequate control of confounding.

## Reproducibility

The project uses scripted transformations, documented phenotype definitions and explicit analytical eligibility criteria. Detailed reproduction instructions are also included in Appendix B of the report.