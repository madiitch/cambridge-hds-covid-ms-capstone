stopifnot(nrow(ard)==nrow(raw), !anyNA(ard$participant_id), !anyDuplicated(ard$participant_id), all(stats::na.omit(ard$symptoms) %in% 0:1), !anyNA(ard$diagnosis), !anyNA(ard$confirmed_case), all((ard$diagnosis=='confirmed') == (ard$confirmed_case=='yes')), sum(is.na(ard$symptoms))==sum(is.na(raw$covid19_has_symptoms)), identical(ard$participant_id,raw$secret_name), sum(ard$eligible_primary)+sum(!ard$eligible_primary)==nrow(raw))
flow <- tibble::tibble(stage=c('Source records','Primary eligible','Adjusted eligible','Diagnosed eligible (alternative)'), n=c(nrow(ard),sum(ard$eligible_primary),sum(ard$eligible_adjusted),sum(ard$eligible_diagnosed)))
readr::write_csv(flow,'outputs/tables/cohort_flow.csv')
# Inspect support before any subgroup modelling. Zero outcome cells are explicit.
support <- ard |> dplyr::filter(eligible_primary) |> dplyr::count(diagnosis, reporting_source, dmt_status, symptoms, .drop=FALSE)
readr::write_csv(support,'outputs/tables/subgroup_support.csv')
# Model-matrix rank and convergence are necessary, not sufficient, checks.
model_data <- droplevels(ard[ard$eligible_adjusted, ])
formula_primary <- symptoms ~ dmt_status + age_group + sex + ms_type + comorbidities
X <- model.matrix(formula_primary, model_data)
model_checks <- tibble::tibble(n=nrow(X), events=sum(model_data$symptoms), parameters=ncol(X), rank=qr(X)$rank)
readr::write_csv(model_checks,'outputs/tables/model_readiness.csv')
# No automatic subgroup regression: assess sparse cells and separation first.
