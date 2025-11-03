# data

- **ct_sample.csv** — analysis dataset created by `R/01_build_sample.R`.  
  **Rows:** 5,000 householders (weighted sample).  
  **Columns:**  
  - `POV` — below poverty line (factor: 0/1)  
  - `NP` — household size (numeric)  
  - `SP` — single-parent household (factor: 0/1)  
  - `SCHL` — education (factor: HS / SC / C)  
  - `RACE` — race (factor: White, Black, Asian, Other, Two or more)  
  - `HCB` — housing cost burden (%)  
  - `HICOV` — health insurance coverage (factor)  
  - `TEN` — tenure (factor: Owned/Mortgage [ref], Owned/Free, Rented, Occupied)

> To regenerate this file, run `source("R/01_build_sample.R")`. You’ll need a Census API key configured for `tidycensus`.