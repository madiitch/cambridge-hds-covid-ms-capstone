# 05_model_readiness.R
# Statistical suitability of the analysis-ready dataset

library(dplyr)

# Primary analytical cohort

model_data <- ard |>
  filter(eligible_adjusted) |>
  droplevels()

# Secondary analytical cohort

class_data <- ard |>
  filter(eligible_class) |>
  droplevels()


# 1. Categorical associations ---------------------------

cramers_v <- function(x, y) {
  
  complete <- complete.cases(x, y)
  
  tab <- table(
    droplevels(as.factor(x[complete])),
    droplevels(as.factor(y[complete]))
  )
  
  if (min(dim(tab)) < 2) {
    return(NA_real_)
  }
  
  chi <- suppressWarnings(
    chisq.test(tab, correct = FALSE)$statistic
  )
  
  as.numeric(
    sqrt(
      chi / (sum(tab) * (min(dim(tab)) - 1))
    )
  )
}


association_data <- model_data |>
  transmute(
    "DMT status" = dmt_status,
    "Age" = age_group,
    "Sex" = sex,
    "MS phenotype" = ms_type,
    "Comorbidity" = comorbidities,
    "Reporting source" = reporting_source,
    "Diagnosis" = diagnosis,
    "Symptoms" = symptoms
  )


association_matrix <- outer(
  names(association_data),
  names(association_data),
  Vectorize(function(x, y) {
    cramers_v(
      association_data[[x]],
      association_data[[y]]
    )
  })
)

dimnames(association_matrix) <- list(
  names(association_data),
  names(association_data)
)


association_long <- as.data.frame(
  as.table(association_matrix)
)

names(association_long) <- c(
  "Variable1",
  "Variable2",
  "Cramers_V"
)

readr::write_csv(
  association_long,
  "outputs/tables/categorical_associations.csv"
)

# 2. Model specifications -------------------------------

formula_primary <- symptoms ~
  dmt_status +
  age_group +
  sex +
  ms_type +
  comorbidities

formula_secondary <- symptoms ~
  dmt_anti_cd20 +
  age_group +
  sex +
  ms_type +
  comorbidities


# 3. Model validation -----------------------------------

validate_model <- function(formula, data, model_name) {
  
  X <- model.matrix(formula, data)
  
  full_rank <- qr(X)$rank == ncol(X)
  
  separated <- NA
  converged <- NA
  vif_table <- NULL
  
  if (full_rank) {
    
    separation_check <- glm(
      formula,
      data = data,
      family = binomial(),
      method = detectseparation::detect_separation
    )
    
    separated <- any(
      is.infinite(coef(separation_check))
    )
    
    if (!separated) {
      
      fit <- glm(
        formula,
        data = data,
        family = binomial()
      )
      
      converged <- fit$converged
      
      if (converged) {
        
        vif_values <- car::vif(fit)
        
        vif_table <- if (is.matrix(vif_values)) {
          
          tibble::tibble(
            model = model_name,
            variable = rownames(vif_values),
            GVIF = vif_values[, 1],
            df = vif_values[, 2],
            adjusted_GVIF = vif_values[, 3]
          )
          
        } else {
          
          tibble::tibble(
            model = model_name,
            variable = names(vif_values),
            GVIF = as.numeric(vif_values),
            df = 1,
            adjusted_GVIF = sqrt(vif_values)
          )
          
        }
      }
    }
  }
  
  summary <- tibble::tibble(
    model = model_name,
    records = nrow(data),
    events = sum(data$symptoms == 1),
    non_events = sum(data$symptoms == 0),
    parameters = ncol(X),
    rank = qr(X)$rank,
    full_rank = full_rank,
    separation = separated,
    converged = converged
  )
  
  list(
    summary = summary,
    vif = vif_table
  )
}


# 4. Apply validation -----------------------------------

primary_validation <- validate_model(
  formula_primary,
  model_data,
  "Primary"
)

secondary_validation <- validate_model(
  formula_secondary,
  class_data,
  "Anti-CD20"
)


readiness_summary <- bind_rows(
  primary_validation$summary,
  secondary_validation$summary
)

vif_summary <- bind_rows(
  primary_validation$vif,
  secondary_validation$vif
)


# 5. Export validation results --------------------------

readr::write_csv(
  readiness_summary,
  "outputs/tables/model_readiness.csv"
)

readr::write_csv(
  vif_summary,
  "outputs/tables/model_vif.csv"
)