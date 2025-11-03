# results/tables

Publication-ready tables rendered with `gt`.

- **glm_summary.png** — Logistic regression (final model) coefficients on the log-odds scale with SE, z-stat, p-values, and 95% CI  
- **odds_ratios.png** — Exponentiated coefficients (OR) with 95% CI and p-values  
- **null_vs_final.png** — Likelihood-ratio test: null vs. final model (`anova(..., test = "Chisq")`)  
- **summary_stats.png** — Summary table for continuous variables (NP, HCB)

> Recreate with `R/04_tables.R`.