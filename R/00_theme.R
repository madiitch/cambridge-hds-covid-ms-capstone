
# ==================================================
# COVID-MS | Reusable academic plotting theme
# Rocket-inspired colour palette
# ==================================================

library(ggplot2)

# Sequential palette
rocket <- c(
  "#03051A",
  "#35193E",
  "#701F57",
  "#AD1759",
  "#E13342",
  "#F58860",
  "#FAEBDD"
)

# General-purpose colours
hds_palette <- c(
  primary   = "#AD1759",
  secondary = "#35193E",
  accent    = "#F58860",
  missing   = "#D9D9D9",
  navy      = "#35193E",
  blue      = "#AD1759",
  slate     = "#701F57",
  light     = "#FAEBDD"
)

# Categorical symptom palette
symptom_palette <- c(
  "yes"     = "#AD1759",
  "no"      = "#35193E",
  "Missing" = "#D9D9D9"
)

# Reusable academic theme
theme_hds <- function(base_size = 12) {
  
  theme_minimal(
    base_size = base_size,
    base_family = "sans"
  ) +
    theme(
      plot.title = element_text(
        face = "bold",
        colour = hds_palette[["primary"]],
        size = rel(1.2)
      ),
      plot.subtitle = element_text(
        colour = "grey40",
        size = rel(0.95)
      ),
      plot.caption = element_text(
        colour = "grey40",
        size = rel(0.8),
        hjust = 0
      ),
      axis.title = element_text(
        face = "bold"
      ),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      legend.position = "bottom",
      legend.title = element_text(
        face = "bold"
      ),
      strip.text = element_text(
        face = "bold"
      ),
      plot.title.position = "plot",
      plot.background = element_rect(
        fill = "white",
        colour = NA
      )
    )
}

