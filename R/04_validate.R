stopifnot(nrow(ard)==nrow(raw), 
          !anyNA(ard$participant_id), !anyDuplicated(ard$participant_id), 
          all(stats::na.omit(ard$symptoms) %in% 0:1), !anyNA(ard$diagnosis), 
          !anyNA(ard$confirmed_case), all((ard$diagnosis=='confirmed') == (ard$confirmed_case=='yes')), 
          sum(is.na(ard$symptoms))==sum(is.na(raw$covid19_has_symptoms)), identical(ard$participant_id,raw$secret_name), 
          sum(ard$eligible_primary)+sum(!ard$eligible_primary)==nrow(raw))


# Analytical cohort summary

flow <- tibble::tibble(
  stage = c(
    "Source records",
    "Primary eligible",
    "Adjusted eligible",
    "Diagnostic subset",
    "Secondary anti-CD20 cohort"
  ),
  n = c(
    nrow(ard),
    sum(ard$eligible_primary),
    sum(ard$eligible_adjusted),
    sum(ard$eligible_diagnosed),
    sum(ard$eligible_class)
  )
) |>
  dplyr::mutate(
    percentage_of_source = round(
      100 * n / nrow(ard),
      1
    )
  )

readr::write_csv(
  flow,
  "outputs/tables/cohort_flow.csv"
)


# Inspect support before any subgroup modelling. Zero outcome cells are explicit.
support <- ard |> dplyr::filter(eligible_primary) |> dplyr::count(diagnosis, 
                                                                  reporting_source, 
                                                                  dmt_status, symptoms, .drop=FALSE)
readr::write_csv(support,'outputs/tables/subgroup_support.csv')

# Model-matrix rank and convergence are necessary, not sufficient, checks.
model_data <- droplevels(ard[ard$eligible_adjusted, ])
formula_primary <- symptoms ~ dmt_status + age_group + sex + ms_type + comorbidities
X <- model.matrix(formula_primary, model_data)
model_checks <- tibble::tibble(n=nrow(X), events=sum(model_data$symptoms), parameters=ncol(X), rank=qr(X)$rank)
readr::write_csv(model_checks,'outputs/tables/model_readiness.csv')

# No automatic subgroup regression: assess sparse cells and separation first.


# ==================================================
# Extended ARD validation
# ==================================================

# 1. Validate treatment classification

stopifnot(
  !anyNA(ard$dmt_class),
  
  all(
    ard$dmt_class[ard$dmt_status == "Never"] ==
      "Never treated"
  ),
  
  all(
    ard$dmt_class[ard$dmt_status == "Not currently"] ==
      "Not currently treated"
  )
)


# 2. Validate anti-CD20 phenotype against source identity

expected_anti_cd20 <-
  ard$dmt_status == "Current" &
  ard$dmt_type %in% c(
    "currently on rituximab",
    "currently on ocrelizumab"
  )

observed_anti_cd20 <-
  ard$dmt_anti_cd20 %in% "Anti-CD20"

stopifnot(
  identical(expected_anti_cd20, observed_anti_cd20)
)


# 3. Validate eligibility indicators

eligibility_vars <- c(
  "eligible_primary",
  "eligible_adjusted",
  "eligible_diagnosed",
  "eligible_class"
)

stopifnot(
  !anyNA(ard[, eligibility_vars]),
  
  all(!ard$eligible_adjusted | ard$eligible_primary),
  
  all(!ard$eligible_diagnosed | ard$eligible_primary),
  
  all(!ard$eligible_class | ard$eligible_adjusted),
  
  identical(
    ard$eligible_class,
    ard$eligible_adjusted &
      !is.na(ard$dmt_anti_cd20)
  )
)


# 4. Validate secondary comparison

secondary_data <- ard |>
  dplyr::filter(eligible_class)

stopifnot(
  all(secondary_data$dmt_status == "Current"),
  
  !anyNA(secondary_data$dmt_anti_cd20),
  
  !anyNA(secondary_data$symptoms),
  
  all(
    !secondary_data$dmt_class %in% c(
      "Other unspecified",
      "Unknown drug"
    )
  )
)


# 5. Validate exported RDS

stopifnot(
  identical(
    ard,
    readRDS("data/processed/covid_ms_ard.rds")
  )
)

message("Extended ARD validation passed.")

