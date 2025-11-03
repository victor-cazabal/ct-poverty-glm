# R scripts

Modular scripts you can `source()` individually.

## Files

- **01_build_sample.R**  
  Pulls ACS PUMS (CT, 2023), filters to householders, engineers:
  - `POV` (below poverty line), `SP` (single-parent), `HCB` (housing cost burden)  
  Draws a **weighted simple random sample** of size 5,000 (seed = 100), applies light recoding (`SCHL`, `RACE`, `TEN`), and writes **`data/ct_sample.csv`**.

- **02_eda.R**  
  EDA visuals: histograms, bar charts, boxplots, and proportional stacked bars. Saves PNGs to **`results/figures/`**.

- **03_diagnostics.R**  
  Fits the final GLM and creates diagnostic plots (binned residuals) and interaction plots for `HCB×TEN` and `HCB×SCHL`. Saves PNGs to **`results/figures/`**.

- **04_tables.R**  
  Pretty exports using `gt`:
  - GLM coefficient table (`glm_summary.png`)
  - Odds ratios with 95% CI (`odds_ratios.png`)
  - LR test (null vs final) (`null_vs_final.png`)
  - Summary stats table for continuous vars (`summary_stats.png`)

## Run order

```r
source("R/01_build_sample.R")
source("R/02_eda.R")
source("R/03_diagnostics.R")
source("R/04_tables.R")