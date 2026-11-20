# COVID-MS | 03_prepare.R
# Analysis-ready dataset construction


# --------------------------------------------------
# 1. Validate source categorical values
# --------------------------------------------------

allowed <- list(
  current_dmt = c("yes", "no", "never_treated"),
  covid19_has_symptoms = c("yes", "no"),
  covid19_diagnosis = c(
    "confirmed", "suspected", "not_suspected"
  ),
  covid19_confirmed_case = c("yes", "no"),
  report_source = c("clinicians", "patients"),
  age_in_cat = as.character(0:3),
  sex = c("male", "female"),
  ms_type2 = c(
    "relapsing_remitting", "progressive_MS", "other"
  ),
  has_comorbidities = c("yes", "no")
)

stopifnot(all(names(allowed) %in% names(raw)))

for (nm in names(allowed)) {
  
  bad <- setdiff(
    stats::na.omit(raw[[nm]]),
    allowed[[nm]]
  )
  
  if (length(bad)) {
    stop(
      "Unexpected codes in ", nm, ": ",
      paste(bad, collapse = ", ")
    )
  }
}


# --------------------------------------------------
# 2. Variable selection and harmonisation
# --------------------------------------------------

ard <- raw |>
  dplyr::transmute(
    
    # Record identifier
    participant_id = secret_name,
    
    # Primary exposure
    dmt_status = factor(
      current_dmt,
      levels = c("never_treated", "no", "yes"),
      labels = c("Never", "Not currently", "Current")
    ),
    
    # Primary outcome
    symptoms = dplyr::case_when(
      covid19_has_symptoms == "yes" ~ 1L,
      covid19_has_symptoms == "no" ~ 0L,
      TRUE ~ NA_integer_
    ),
    
    # Diagnostic and reporting characteristics
    diagnosis = factor(
      covid19_diagnosis,
      levels = c(
        "not_suspected",
        "suspected",
        "confirmed"
      )
    ),
    
    confirmed_case = covid19_confirmed_case,
    
    reporting_source = factor(
      report_source,
      levels = c("patients", "clinicians")
    ),
    
    # Candidate adjustment variables
    age_group = factor(
      age_in_cat,
      levels = as.character(0:3)
    ),
    
    sex = factor(
      sex,
      levels = c("female", "male")
    ),
    
    ms_type = factor(
      ms_type2,
      levels = c(
        "relapsing_remitting",
        "progressive_MS",
        "other"
      )
    ),
    
    comorbidities = factor(
      has_comorbidities,
      levels = c("no", "yes")
    ),
    
    # Original drug identity
    dmt_type = dmt_type_overall,
    
    # Supporting clinical outcomes
    hospitalisation = covid19_admission_hospital,
    icu_admission = covid19_icu_stay,
    ventilation = covid19_ventilation
  )


# --------------------------------------------------
# 3. Treatment phenotype engineering
# --------------------------------------------------

dmt_mapping <- c(
  "currently on ocrelizumab" = "Anti-CD20",
  "currently on rituximab" = "Anti-CD20",
  "currently on fingolimod" = "S1P modulators",
  "currently on natalizumab" = "Trafficking inhibition",
  "currently on alemtuzumab" = "Immune reconstitution",
  "currently on cladribine" = "Immune reconstitution",
  "currently on dimethyl fumarate" = "Fumarates",
  "currently on teriflunomide" = "Teriflunomide",
  "currently on interferon" = "Injectable immunomodulators",
  "currently on glatiramer" = "Injectable immunomodulators",
  "currently on another drug not listed" = "Other unspecified"
)

# Check for unexpected drug identities among current users

unexpected_drugs <- ard |>
  dplyr::filter(
    dmt_status == "Current",
    !is.na(dmt_type),
    !dmt_type %in% names(dmt_mapping)
  )

if (nrow(unexpected_drugs) > 0) {
  stop("Unmapped drug identities among current DMT users.")
}

ard <- ard |>
  dplyr::mutate(
    
    dmt_class = dplyr::case_when(
      
      dmt_status == "Never" ~
        "Never treated",
      
      dmt_status == "Not currently" ~
        "Not currently treated",
      
      dmt_status == "Current" & is.na(dmt_type) ~
        "Unknown drug",
      
      dmt_status == "Current" ~
        unname(dmt_mapping[dmt_type]),
      
      TRUE ~ NA_character_
    ),
    
    dmt_class = factor(dmt_class),
    
    # Anti-CD20 versus other identified current DMTs
    
    dmt_anti_cd20 = dplyr::case_when(
      
      dmt_status == "Current" &
        dmt_class == "Anti-CD20" ~
        "Anti-CD20",
      
      dmt_status == "Current" &
        dmt_class %in% c(
          "S1P modulators",
          "Trafficking inhibition",
          "Immune reconstitution",
          "Fumarates",
          "Teriflunomide",
          "Injectable immunomodulators"
        ) ~ "Other identified DMT",
      
      TRUE ~ NA_character_
    ),
    
    dmt_anti_cd20 = factor(
      dmt_anti_cd20,
      levels = c(
        "Other identified DMT",
        "Anti-CD20"
      )
    )
  )


# --------------------------------------------------
# 4. Analysis-specific eligibility
# --------------------------------------------------

ard <- ard |>
  dplyr::mutate(
    
    # Primary unadjusted analysis
    eligible_primary =
      !is.na(symptoms) &
      !is.na(dmt_status),
    
    # Primary adjusted analysis
    eligible_adjusted =
      eligible_primary &
      stats::complete.cases(
        age_group,
        sex,
        ms_type,
        comorbidities
      ),
    
    # Diagnostic subgroup exploration
    eligible_diagnosed =
      eligible_primary &
      diagnosis %in% c("confirmed", "suspected"),
    
    # Secondary anti-CD20 analysis
    eligible_class =
      eligible_adjusted &
      !is.na(dmt_anti_cd20)
  )


# --------------------------------------------------
# 5. Export analysis-ready dataset
# --------------------------------------------------

readr::write_csv(
  ard,
  "data/processed/covid_ms_ard.csv",
  na = "NA"
)

saveRDS(
  ard,
  "data/processed/covid_ms_ard.rds"
)
