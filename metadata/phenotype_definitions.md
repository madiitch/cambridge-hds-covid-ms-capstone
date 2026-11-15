# Provisional phenotype specification

Outcome: source field `covid19_has_symptoms`; yes = 1, no = 0, missing = NA. This is reported COVID-compatible symptom presence, not infection or severity. No symptom-level imputation.

Exposure: `current_dmt` at data entry; yes = Current, no = Former (interpretation to verify against source), never_treated = Never. Reference category Never is provisional. No inference about exposure timing relative to symptoms.

Population: all source records; primary eligibility requires observed exposure and outcome. Adjusted eligibility additionally requires observed candidate covariates. Alternative diagnosed eligibility requires suspected or confirmed classification. No age exclusion yet; review minors and CIS/uncertain MS category.

Reporting source and diagnosis are retained; no automatic adjustment or subgroup fitting. Confirmed indicator is a consistency check, not independent diagnostic validation.
