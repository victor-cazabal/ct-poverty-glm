library(readr); library(dplyr); library(broom); library(gt); library(scales)

df <- read_csv("data/ct_sample.csv", show_col_types = FALSE)

model <- glm(
  POV ~ SP + SCHL + HCB + HICOV + TEN + RACE + HCB*TEN + HCB*SCHL,
  data = df,
  family = binomial(link = "logit")
)

null_model <- glm(POV ~ 1, 
                  data = df, 
                  family = binomial)

##pretty glm summary

p_stars <- function(p) {
  ifelse(p < .001, "***",
         ifelse(p < .01,  "**",
                ifelse(p < .05,  "*",
                       ifelse(p < .1,   "·", ""))))
}

pretty_glm_summary <- function(model,
                               title   = "GLM Summary",
                               subtitle= NULL,
                               digits  = 3,
                               out_png = NULL,
                               out_html= NULL) {
  tabdf <- broom::tidy(model, conf.int = TRUE) |>
    mutate(
      Estimate  = round(estimate, digits),
      `Std. Err`= round(std.error, digits),
      `z/t`     = round(statistic, digits),
      `Pr(>|z|)`= pvalue(p.value),
      Stars     = p_stars(p.value),
      `95% CI`  = paste0("(", round(conf.low, digits), ", ", round(conf.high, digits), ")")
    ) |>
    transmute(
      Term = term, Estimate, `Std. Err`, `z/t`, `Pr(>|z|)`, Stars, `95% CI`
    )
  
  tab <- gt(tabdf) |>
    tab_header(title = title, subtitle = subtitle) |>
    cols_align("center", everything()) |>
    tab_source_note(md("Notes: stars = *** p<0.001, ** p<0.01, * p<0.05, · p<0.10."))
  
  if (!is.null(out_png))  gtsave(tab, out_png)
  if (!is.null(out_html)) gtsave(tab, out_html)
  tab
}

pretty_glm_summary(main_model_2,
                   title = "Logistic Regression: Final Model",
                   out_png = "glm_summary.png")

##pretty odds ratio summary

pretty_glm_or <- function(model,
                          title   = "Odds Ratios (exp(coef))",
                          subtitle= NULL,
                          digits  = 3,
                          ci_method = c("profile","wald"),
                          out_png = NULL,
                          out_html= NULL) {
  ci_method <- match.arg(ci_method)
  #fast CI: wald; slower but exact: profile
  tid <- broom::tidy(model, conf.int = TRUE, conf.level = 0.95,
                     exponentiate = TRUE, conf.method = ci_method)
  
  tabdf <- tid |>
    mutate(
      OR       = round(estimate, digits),
      `95% CI` = paste0("(", round(conf.low, digits), ", ", round(conf.high, digits), ")"),
      `Pr(>|z|)` = pvalue(p.value),
      Stars    = p_stars(p.value)
    ) |>
    transmute(Term = term, OR, `95% CI`, `Pr(>|z|)`, Stars)
  
  tab <- gt(tabdf) |>
    tab_header(title = title, subtitle = subtitle) |>
    cols_align("center", everything()) |>
    tab_source_note(md("CI method: set via `ci_method = \"wald\"` (fast) or \"profile\" (default)."))
  
  if (!is.null(out_png))  gtsave(tab, out_png)
  if (!is.null(out_html)) gtsave(tab, out_html)
  tab
}

pretty_glm_or(main_model_2,
              title = "Final Model — Odds Ratios",
              ci_method = "wald",                       
              out_png  = "odds_ratios.png")

##pretty analysis of deviance table

pretty_lr_test <- function(mod_small, mod_big,
                           title = "Analysis of Deviance (LR Test)",
                           subtitle = NULL,
                           out_png = NULL,
                           out_html = NULL) {
  
  lr <- anova(mod_small, mod_big, test = "Chisq")
  
  #convert to plain data frame and normalize column names
  df <- as.data.frame(lr)
  df$Model <- rownames(df)
  rownames(df) <- NULL
  
  #some columns are named with spaces; standardize them
  nm <- names(df)
  nm <- sub("^Resid\\. Df$", "Resid_Df", nm)
  nm <- sub("^Resid\\. Dev$", "Resid_Dev", nm)
  nm <- sub("^Pr\\(>Chi\\)$", "Pr_Gt_Chi", nm)
  names(df) <- nm
  
  #ensure expected columns exist
  #(Df can be NA for the first row; keep it)
  keep_cols <- intersect(c("Model","Resid_Df","Resid_Dev","Df","Deviance","Pr_Gt_Chi"), names(df))
  df <- df[, keep_cols]
  
  #round numeric columns nicely
  num_cols <- intersect(c("Resid_Dev","Deviance"), names(df))
  df[num_cols] <- lapply(df[num_cols], function(x) round(x, 3))
  
  #format p-values
  if ("Pr_Gt_Chi" %in% names(df)) {
    df$`Pr(>χ²)` <- signif(df$Pr_Gt_Chi, 3)
  }
  
  #rename
  disp <- df |>
    rename(
      `Resid. Df`  = Resid_Df,
      `Resid. Dev` = if ("Resid_Dev" %in% names(df)) "Resid_Dev" else NULL,
      Df           = Df,
      `LR χ²`      = if ("Deviance" %in% names(df)) "Deviance" else NULL
    )
  
  tab <- gt(disp) |>
    tab_header(title = title, subtitle = subtitle) |>
    cols_align("center", everything()) |>
    tab_source_note(md("χ² test via `anova(mod_small, mod_big, test = \"Chisq\")`."))
  
  if (!is.null(out_png))  gtsave(tab, out_png)
  if (!is.null(out_html)) gtsave(tab, out_html)
  tab
}

pretty_lr_test(null_model, model,
               title   = "LR Test: Null vs Final",
               out_png = "null_vs_final.png")