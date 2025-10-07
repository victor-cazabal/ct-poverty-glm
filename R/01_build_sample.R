#purpose: Pull ACS PUMS (CT, 2023), create household-head sample, clean, and write ct_sample.csv
library(tidycensus)
library(dplyr)
library(readr)

# --- config -------------------------------------------------------------------
year <- 2023
desired_n <- 5000
#use any fixed seed you like
set.seed(100)

# --- pull vars ------------------------------------
pums_vars <- c("HHT","NP","POVPIP","SCHL","RAC1P","PUMA","RELSHIPP",
               "GRPIP","HICOV","TEN","OCPIP","PWGTP")

ct <- get_pums(
  variables = pums_vars,
  state = "CT",
  survey = "acs1",
  year = year
)

# --- keep householders; engineer targets --------------------------------------
# RELSHIPP == "20" = householder in person-level PUMS
hh <- ct %>%
  filter(RELSHIPP == "20") %>%
  mutate(
    POV = as.integer(POVPIP < 100),                #below poverty line (binary)
    SP  = as.integer(HHT %in% c("2","3")),         #single-parent HH (binary)
    HCB = if_else(GRPIP > 0, GRPIP, OCPIP)         #rent%income or owner-cost%income
  )

# --- weighted sample of householders ------------------------
hh <- hh %>%
  mutate(selection_prob = PWGTP / sum(PWGTP, na.rm = TRUE))

idx <- sample(seq_len(nrow(hh)), size = desired_n, replace = FALSE, prob = hh$selection_prob)
ct_sample <- hh[idx, ]

# --- light cleaning / relabels (match your analysis conventions) --------------
# Education groups (HS, Some college/Assoc, College+)
ct_sample <- ct_sample %>%
  mutate(
    SCHL = case_when(
      SCHL >= 1  & SCHL <= 17 ~ "HS",
      SCHL %in% c(18,19,20)   ~ "SC",
      SCHL >= 21              ~ "C",
      TRUE                    ~ NA_character_
    ),
    #race groups
    RACE = case_when(
      RAC1P %in% c(3,4,5,7,8) ~ "Other",
      RAC1P == 1              ~ "White",
      RAC1P == 2              ~ "Black",
      RAC1P == 6              ~ "Asian",
      RAC1P == 9              ~ "Two or more",
      TRUE                    ~ NA_character_
    ),
    #tenure labels
    TEN = case_when(
      TEN == 1 ~ "Owned/Mortgage",
      TEN == 2 ~ "Owned/Free",
      TEN == 3 ~ "Rented",
      TEN == 4 ~ "Occupied",
      TRUE     ~ NA_character_
    )
  )

#factors + reference levels commonly used later
ct_sample <- ct_sample %>%
  mutate(
    SCHL  = factor(SCHL, levels = c("HS","SC","C")),
    RACE  = factor(RACE),
    TEN   = factor(TEN),
    HICOV = factor(HICOV),
    POV   = factor(POV),
    SP    = factor(SP)
  )
ct_sample$TEN  <- relevel(ct_sample$TEN,  ref = "Owned/Mortgage")
ct_sample$RACE <- relevel(ct_sample$RACE, ref = "White")

# --- keep only fields used downstream -----------------------------------------
ct_sample <- ct_sample %>%
  select(POV, NP, SP, SCHL, RACE, HCB, HICOV, TEN)

#write_csv(ct_sample, "data/ct_sample.csv")
