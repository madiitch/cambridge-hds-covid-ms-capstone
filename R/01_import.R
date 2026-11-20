# Run from the project root. Raw data are never overwritten.
raw_path <- 'data/raw/GDSI_OpenDataset_Final.csv'

source_url <- 'https://raw.githubusercontent.com/CambridgeICE-HDS/MSt-Healthcare-Data-Science/main/Datasets/COVID-MS/GDSI_OpenDataset_Final.csv'

if (!file.exists(raw_path)) {
  dir.create(dirname(raw_path), recursive = TRUE, showWarnings = FALSE)
  tmp <- tempfile(fileext = '.csv')
  download.file(source_url, tmp, mode = 'wb')
  stopifnot(file.info(tmp)$size > 0)
  stopifnot(file.copy(tmp, raw_path))
  unlink(tmp)
}

raw <- readr::read_csv(raw_path, 
                       col_types = readr::cols(.default = readr::col_character()), 
                       na = c('', 'NA'), 
                       show_col_types = FALSE)

stopifnot(nrow(readr::problems(raw)) == 0)

required <- c('secret_name','current_dmt','covid19_has_symptoms',
              'covid19_diagnosis','covid19_confirmed_case','report_source',
              'age_in_cat','sex','ms_type2','has_comorbidities','dmt_type_overall',
              'edss_in_cat2','bmi_in_cat2','current_or_former_smoker')

stopifnot(all(required %in% names(raw)), nrow(raw) == 1141L, ncol(raw) == 47L)

writeLines(c(paste('Source:', source_url), 
             paste('MD5:', tools::md5sum(raw_path)), 
             paste('Rows:', nrow(raw)), paste('Columns:', ncol(raw))), 'metadata/source_manifest.txt')
