library(readr); library(dplyr); library(ggplot2); library(gridExtra); library(arm)

df <- read_csv("data/ct_sample.csv", show_col_types = FALSE)

#final model that best predicts poverty status
model <- glm(
  POV ~ SP + SCHL + HCB + HICOV + TEN + RACE + HCB*TEN + HCB*SCHL,
  data = df,
  family = binomial(link = "logit")
)

#binned plot of residuals (diagnostics)
g5 <- binnedplot(fitted(model), resid(model, type = "response"),
           main = "Binned Residual Plot",
           xlab = "Fitted Values (Predicted Probabilities)",
           ylab = "Residuals")

#interaction plots
ten_levels <- c("Owned/Mortgage", "Rented")
schl_levels <- c("HS", "C")

#create a sequence of HCB values spanning the observed range
hcb_range <- seq(min(ct_sample$HCB, na.rm = TRUE),
                 max(ct_sample$HCB, na.rm = TRUE),
                 length.out = 100)

#for plotting, assume other variables are held at reference or typical values
typical_SP <- "0"
typical_HICOV <- "1"
typical_RACE <- "White"

#-----------------------------
# Interaction 1: HCB * TEN
#-----------------------------
#create a data frame for predictions
pred_data_ten <- expand.grid(
  HCB = hcb_range,
  TEN = ten_levels,
  #for simplicity hold others constant
  SP = typical_SP,
  HICOV = typical_HICOV,
  RACE = typical_RACE,
  #choose a level for SCHL or the most common category
  SCHL = "HS"
)

#get predicted probabilities
pred_data_ten$pred_prob <- predict(main_model_2, newdata = pred_data_ten, type = "response")

#plot with a loess smoothing curve
#we'll create separate plots or use facets to visualize each TEN level
p_ten <- ggplot(pred_data_ten, aes(x = HCB, y = pred_prob, color = TEN)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "loess", se = FALSE) +
  labs(
    title = "Predicted Probability of POV by HCB and TEN",
    x = "Housing Cost Burden (HCB)",
    y = "Predicted Probability of Poverty"
  ) +
  theme_minimal() + theme(plot.title = element_text(size = 8))

#-----------------------------
# Interaction 2: HCB * SCHL
#-----------------------------
#create a data frame for predictions with two SCHL levels
pred_data_schl <- expand.grid(
  HCB = hcb_range,
  SCHL = schl_levels,
  #other variables held constant
  SP = typical_SP,
  HICOV = typical_HICOV,
  RACE = typical_RACE,
  TEN = "Owned/Mortgage" #or choose another TEN level
)

#get predicted probabilities
pred_data_schl$pred_prob <- predict(main_model_2, newdata = pred_data_schl, type = "response")

#plot with a loess smoothing curve
p_schl <- ggplot(pred_data_schl, aes(x = HCB, y = pred_prob, color = SCHL)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "loess", se = FALSE) +
  labs(
    title = "Predicted Probability of POV by HCB and SCHL",
    x = "Housing Cost Burden (HCB)",
    y = "Predicted Probability of Poverty"
  ) +
  theme_minimal() + theme(plot.title = element_text(size = 8))

g6 <- grid.arrange(p_ten, p_schl, ncol=2)

#ggsave("results/figures/interaction_plots.png", g6, width = 10, height = 3)


