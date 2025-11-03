# Modeling Household Poverty in Connecticut (GLM)

**Logistic regression analysis of poverty risk using 2023 ACS PUMS (CT)**

This project builds a clean, weighted sample of Connecticut householders from ACS PUMS, explores the data, and fits/log-checks a logistic regression with interactions. Outputs include publication-ready tables and figures.

---

## Data & Scope

- **Source:** American Community Survey (ACS) PUMS 2023, Connecticut only  
- **Access:** Pulled via `tidycensus` (you’ll need a Census API key)  
- **Unit of analysis:** Householder (person weight `PWGTP` used for sampling)  
- **Target:** `POV` (1 = below poverty line, 0 = not)  
- **Key predictors:** `TEN` (tenure), `HICOV` (insurance), `SCHL` (education), `RACE`, `SP` (single-parent), `HCB` (housing cost burden), plus interactions `HCB×TEN` and `HCB×SCHL`.

---

## Repository structure

- 📂 **[R/](R/)** — Modular R scripts (build sample, EDA, diagnostics, tables)  
- 📂 **[data/](data/)** — Analysis dataset (`ct_sample.csv`)  
- 📂 **[results/](results/)** — Exports
  - 📂 **[figures/](results/figures/)** — Plots used in the write-up  
  - 📂 **[tables/](results/tables/)** — PNG tables (model summary, ORs, LR test, summary stats)  
- 📂 **[write_up/](write_up/)** — R Markdown report (`poverty_da.Rmd`)  
- 📄 **README.md** — Project overview (this file)

---

## Reproducibility

You’ll need an API key the first time:

```r
install.packages(c("tidycensus","dplyr","readr","ggplot2","gridExtra","GGally","arm","broom","gt","scales"))
tidycensus::census_api_key("YOUR_KEY_HERE", install = TRUE)
```

Run scripts in order:

- source("R/01_build_sample.R")   # writes data/ct_sample.csv (weighted sample; seed = 100)
- source("R/02_eda.R")            # saves EDA plots to results/figures/
- source("R/03_diagnostics.R")    # diagnostics & interaction plots to results/figures/
- source("R/04_tables.R")         # pretty GLM summary, ORs, LR test to results/tables/

**🎲Randomness note:** `R/01_build_sample.R` uses `set.seed(100)`. Changing the seed will change the sample and estimates.

### Modeling summary

Final model (logit):


$$
\operatorname{logit}\!\left(P(\mathrm{POV}=1)\right) = \beta_0 + \beta_1\,\mathrm{SP} + \beta_2\,\mathrm{SCHL} + \beta_3\,\mathrm{HCB} + \beta_4\,\mathrm{HICOV} + \beta_5\,\mathrm{TEN} + \beta_6\,\mathrm{RACE} + \beta_7\,(\mathrm{HCB}\times\mathrm{TEN}) + \beta_8\,(\mathrm{HCB}\times\mathrm{SCHL})
$$

See **results/tables/** for:
- `glm_summary.png` — coefficient table (log-odds)
- `odds_ratios.png` — exponentiated coefficients with 95% CI
- `null_vs_final.png` — LR test (null vs final model)
- `summary_stats.png` — NP & HCB summary table

### References

- U.S. Census Bureau. *American Community Survey (ACS) Public Use Microdata Sample (PUMS), 2023.*
- Walker, K., & Herman, M. **tidycensus**: Load US Census boundary and attribute data as tidyverse- and sf-ready data in R. <https://github.com/walkerke/tidycensus>


