# Source-level checks: preserve NA and do not silently repair anomalies.
audit <- tibble::tibble(variable = names(raw), missing_n = vapply(raw, function(x) sum(is.na(x)), integer(1)), distinct_observed = vapply(raw, function(x) length(unique(stats::na.omit(x))), integer(1))) |>
  dplyr::mutate(missing_pct = 100 * missing_n / nrow(raw)) |>
  dplyr::arrange(dplyr::desc(missing_pct))
readr::write_csv(audit, 'outputs/tables/source_audit.csv')
counts <- function(...) raw |> dplyr::count(..., name = 'n')
dx_sym <- counts(covid19_diagnosis, covid19_has_symptoms)
source_dx <- counts(report_source, covid19_diagnosis)
three_way <- counts(report_source, covid19_diagnosis, covid19_has_symptoms)
dmt_sym <- counts(current_dmt, covid19_has_symptoms)
dmt_dx_sym <- counts(current_dmt, covid19_diagnosis, covid19_has_symptoms)
dmt_source_sym <- counts(current_dmt, report_source, covid19_has_symptoms)
for (nm in c('dx_sym','source_dx','three_way','dmt_sym','dmt_dx_sym','dmt_source_sym')) readr::write_csv(get(nm), paste0('outputs/tables/',nm,'.csv'))
readr::write_csv(counts(current_dmt, dmt_type_overall), 'outputs/tables/dmt_consistency.csv')
readr::write_csv(counts(covid19_has_symptoms, covid19_sympt_fatigue), 'outputs/tables/fatigue_consistency.csv')
readr::write_csv(counts(has_comorbidities, com_hypertension), 'outputs/tables/comorbidity_consistency.csv')
missing_by_source <- dplyr::bind_rows(lapply(split(raw, raw$report_source), function(d) tibble::tibble(report_source = d$report_source[1], variable = names(d), missing_pct = vapply(d, function(x) mean(is.na(x))*100, numeric(1)))))
readr::write_csv(missing_by_source, 'outputs/tables/missing_by_source.csv')
