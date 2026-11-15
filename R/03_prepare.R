# Provisional specification: retain all records; flag analytical eligibility.
allowed <- list(current_dmt=c('yes','no','never_treated'), covid19_has_symptoms=c('yes','no'), covid19_diagnosis=c('confirmed','suspected','not_suspected'), covid19_confirmed_case=c('yes','no'), report_source=c('clinicians','patients'), age_in_cat=as.character(0:3), sex=c('male','female'), ms_type2=c('relapsing_remitting','progressive_MS','other'), has_comorbidities=c('yes','no'))
for (nm in names(allowed)) {
  bad <- setdiff(stats::na.omit(raw[[nm]]), allowed[[nm]])
  if (length(bad)) stop('Unexpected codes in ', nm, ': ', paste(bad, collapse=', '))
}
ard <- raw |> dplyr::transmute(
  participant_id = secret_name,
  dmt_status = factor(current_dmt, levels=c('never_treated','no','yes'), labels=c('Never','Former','Current')),
  symptoms = dplyr::case_when(covid19_has_symptoms == 'yes' ~ 1L, covid19_has_symptoms == 'no' ~ 0L, TRUE ~ NA_integer_),
  diagnosis = factor(covid19_diagnosis, levels=c('not_suspected','suspected','confirmed')),
  confirmed_case = covid19_confirmed_case,
  reporting_source = factor(report_source, levels=c('patients','clinicians')),
  age_group = factor(age_in_cat, levels=as.character(0:3)),
  sex = factor(sex), ms_type = factor(ms_type2), comorbidities = factor(has_comorbidities),
  dmt_type = dmt_type_overall,
  eligible_primary = !is.na(symptoms) & !is.na(dmt_status),
  eligible_adjusted = eligible_primary & stats::complete.cases(age_group, sex, ms_type, comorbidities),
  eligible_diagnosed = eligible_primary & diagnosis %in% c('confirmed','suspected'))
readr::write_csv(ard, 'data/processed/covid_ms_ard.csv', na='NA')
saveRDS(ard, 'data/processed/covid_ms_ard.rds')
