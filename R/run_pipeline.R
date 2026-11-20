# Execute with source('R/run_pipeline.R') from project root.
for (p in c('readr','dplyr','tibble','ggplot2','knitr',
            'rmarkdown','scales', 'car', 'detectseparation')) if (!requireNamespace(p, quietly=TRUE)) stop('Install package: ',p)
for (d in c('data/raw','data/processed','metadata',
            'outputs/tables','outputs/figures')) dir.create(d, recursive=TRUE, showWarnings=FALSE)
for (f in c('01_import','02_audit','03_prepare','04_validate', '05_model_readiness')) source(paste0('R/',f,'.R'), local=TRUE)
writeLines(capture.output(sessionInfo()),'outputs/session_info.txt')
