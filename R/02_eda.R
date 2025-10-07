library(readr); library(dplyr); library(ggplot2)
library(gridExtra); library(GGally); library(scales)


df <- read_csv("data/ct_sample.csv", show_col_types = FALSE)

#summary stats (continuous)
cont <- df[, c("NP","HCB")]
summ <- data.frame(
  mean   = sapply(cont, mean, na.rm = TRUE),
  sd     = sapply(cont, sd, na.rm = TRUE),
  median = sapply(cont, median, na.rm = TRUE),
  iqr    = sapply(cont, IQR, na.rm = TRUE),
  min    = sapply(cont, min, na.rm = TRUE),
  max    = sapply(cont, max, na.rm = TRUE)
)

#histograms
hist_np <- ggplot(ct_sample, aes(x=NP)) + geom_histogram(bins = 9, color = "black", fill = "lavender") + theme_classic() + labs(title = "Distribution of # of House Members", x="People", y = "Frequency") + theme(plot.title = element_text(size = 11))
hist_hcb <- ggplot(ct_sample, aes(x=HCB)) + geom_histogram(bins = 11, color = "black", fill = "gold") + theme_classic() + labs(title = "Distribution of Housing Cost Burden %", x="Percentage", y = "Frequency") + theme(plot.title = element_text(size = 11))
g <- grid.arrange(hist_np, hist_hcb, ncol= 2)

#ggsave("results/figures/hist_np_hcb.png", g, width = 10, height = 3)

#simple bar charts (counts)
bar_ten <- ggplot(ct_sample, aes(x=TEN)) + geom_bar(color = "black", fill = "green") + theme_classic() + labs(title = "Barplot of Tenure", x="Tenure", y = "Frequency") + theme(plot.title = element_text(size = 8), axis.text.x = element_text(size = 3.5))

bar_hicov <- ggplot(ct_sample, aes(x=HICOV)) + geom_bar(color = "black", fill = "red") + theme_classic() + labs(title = "Barplot of Health Insurance Status", x="Health Insurance Coverage?", y = "Frequency") + theme(plot.title = element_text(size = 8), axis.text.x = element_text(size = 4))

bar_pov <- ggplot(ct_sample, aes(x=POV)) + geom_bar(color = "black", fill = "yellow") + theme_classic() + labs(title = "Barplot of Poverty Status", x="Lives Below Poverty Line?", y = "Frequency") + theme(plot.title = element_text(size = 8), axis.text.x = element_text(size = 4))

bar_sp <- ggplot(ct_sample, aes(x=SP)) + geom_bar(color = "black", fill = "pink") + theme_classic() + labs(title = "Barplot of Single Parent Status", x="Single Parent?", y = "Frequency") + theme(plot.title = element_text(size = 8), axis.text.x = element_text(size = 4))

bar_schl <- ggplot(ct_sample, aes(x=SCHL)) + geom_bar(color = "black", fill = "brown") + theme_classic() + labs(title = "Barplot of Educational Attainment", x="Education Level", y = "Frequency") + theme(plot.title = element_text(size = 6), axis.text.x = element_text(size = 4))

bar_race <- ggplot(ct_sample, aes(x=RACE)) + geom_bar(color = "black", fill = "orange") + theme_classic() + labs(title = "Barplot of Race", x="Race", y = "Frequency") + theme(plot.title = element_text(size = 8), axis.text.x = element_text(size = 4))

g2 <- grid.arrange(bar_pov, bar_ten, bar_schl, bar_race, bar_sp, bar_hicov, ncol=3)
#ggsave("results/figures/bars_categorical.png", g2, width = 10, height = 6)

#boxplots vs POV
box_np <- ggplot(ct_sample, aes(x = POV, y = NP)) +
  geom_boxplot(fill = "steelblue") +
  labs(
    title = "Household Size (NP) by Poverty Status",
    x = "Poverty Status",
    y = "Number of People in Household (NP)"
  ) + theme(plot.title = element_text(size = 8), axis.title.y = element_text(size = 6))

# Boxplot for HCB by POV
box_hcb <- ggplot(ct_sample, aes(x = POV, y = HCB)) +
  geom_boxplot(fill = "tomato") +
  labs(
    title = "Housing Cost Burden (HCB) by Poverty Status",
    x = "Poverty Status",
    y = "Housing Cost Burden (%)"
  ) + theme(plot.title = element_text(size = 8), axis.title.y = element_text(size = 6))

g3 <- grid.arrange(box_np, box_hcb, ncol=2)
#ggsave("results/figures/boxplots_by_pov.png", g3, width = 8, height = 3)

#stacked proportions (POV by categories)
# POV by Tenure (TEN)
barplot_ten <- ggplot(ct_sample, aes(x = TEN, fill = POV)) +
  geom_bar(position = "fill") +  # "fill" shows proportions
  labs(
    title = "Proportion of Poverty by Tenure",
    x = "Tenure (Owner vs. Renter)",
    y = "Proportion",
    fill = "Poverty Status"
  ) +
  scale_y_continuous(labels = scales::percent) + theme(plot.title = element_text(size = 8), axis.text.x = element_text(size = 3))

# POV by Health Insurance Coverage (HICOV)
barplot_hicov <- ggplot(ct_sample, aes(x = HICOV, fill = POV)) +
  geom_bar(position = "fill") +
  labs(
    title = "Proportion of Poverty by Health Insurance",
    x = "Health Insurance Coverage (Yes vs. No)",
    y = "Proportion",
    fill = "Poverty Status"
  ) +
  scale_y_continuous(labels = scales::percent) + theme(plot.title = element_text(size = 8))

# POV by Educational Attainment (SCHL)
barplot_schl <- ggplot(ct_sample, aes(x = SCHL, fill = POV)) +
  geom_bar(position = "fill") +
  labs(
    title = "Proportion of Poverty by Education",
    x = "Educational Attainment",
    y = "Proportion",
    fill = "Poverty Status"
  ) +
  scale_y_continuous(labels = scales::percent) + theme(plot.title = element_text(size = 8))

# POV by Race (RACE)
barplot_race <- ggplot(ct_sample, aes(x = RACE, fill = POV)) +
  geom_bar(position = "fill") +
  labs(
    title = "Proportion of Poverty by Race",
    x = "Race",
    y = "Proportion",
    fill = "Poverty Status"
  ) +
  scale_y_continuous(labels = scales::percent) + theme(plot.title = element_text(size = 8), axis.text.x = element_text(size = 4))

# POV by Single-Parent Status (SP)
barplot_sp <- ggplot(ct_sample, aes(x = SP, fill = POV)) +
  geom_bar(position = "fill") +
  labs(
    title = "Proportion of Poverty by Single-Parent Status",
    x = "Single-Parent Household (Yes vs. No)",
    y = "Proportion",
    fill = "Poverty Status"
  ) +
  scale_y_continuous(labels = scales::percent) + theme(plot.title = element_text(size = 8))

g4 <- grid.arrange(barplot_ten, barplot_hicov, barplot_schl, barplot_race, barplot_sp, ncol=3)

#ggsave("results/figures/prop_by_category.png", g4, width = 12, height = 6)