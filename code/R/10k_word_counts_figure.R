
# Setup
library(tidyverse)
library(scales)
library(ggplot2)


# Load data
df <- read_csv("data/external/10k_word_counts.csv")
print(colnames(df))


# Prepare data
df_clean <- df %>%
  filter(download_success == TRUE) %>%
  filter(!is.na(word_count)) %>%
  filter(word_count > 0) %>%
  mutate(year = lubridate::year(report_date))
print(head(df_clean))
print(table(df_clean$year))


# Annual summary 1996-2013
summary_1996_2013 <- df_clean %>%
  filter(year >= 1996, year <= 2013) %>%
  group_by(year) %>%
  summarise(
    p25 = quantile(word_count, 0.25, na.rm = TRUE),
    median = median(word_count, na.rm = TRUE),
    mean = mean(word_count, na.rm = TRUE),
    p75 = quantile(word_count, 0.75, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )
print(summary_1996_2013)

# Replica plot
summary_long <- summary_1996_2013 %>%
  select(year, p25, median, mean, p75) %>%
  pivot_longer(
    cols = c(p25, median, mean, p75),
    names_to = "statistic",
    values_to = "word_count"
  ) %>%
  mutate(
    statistic = factor(
      statistic,
      levels = c("p25", "median", "mean", "p75"),
      labels = c("Q1", "Median", "Mean", "Q3")
    )
  )

# Plot with colors, line types, denser axes, and legend
colors <- c(
  "Q1" = "#66c2a5",
  "Median" = "#fc8d62",
  "Mean" = "#8da0cb",
  "Q3" = "#e78ac3"
)

fig_1a <- ggplot(summary_long, aes(
  x = year,
  y = word_count,
  color = statistic
)) +
  # Mean
  geom_line(
    data = subset(summary_long, statistic == "Mean"),
    linewidth = 1.7
  ) +
  # percentiles
  geom_line(
    data = subset(summary_long, statistic != "Mean"),
    linetype = "42",
    linewidth = 0.9
  ) +
  scale_color_manual(values = colors) +
  scale_x_continuous(
    breaks = seq(1996, 2013, by = 1)
  ) +
  scale_y_continuous(
    breaks = seq(0, 70000, by = 5000)
  ) +
  labs(
    title = "10-K Length Over Time (1996-2013)",
    x = "Year",
    y = "Word Count",
    color = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = c(0.18, 0.82),
    legend.background = element_rect(fill = "white", color = "grey80"),
    legend.key.width = unit(1.6, "cm")
  )
print(fig_1a)

ggsave(
  filename = "output/word_counts_figure_1996_2013.png",
  plot = fig_1a,
  width = 8,
  height = 5,
  dpi = 300
)


# Extended plot
summary_1996_2025 <- df_clean %>%
  filter(year >= 1996, year <= 2025) %>%
  group_by(year) %>%
  summarise(
    p25 = quantile(word_count, 0.25, na.rm = TRUE),
    median = median(word_count, na.rm = TRUE),
    mean = mean(word_count, na.rm = TRUE),
    p75 = quantile(word_count, 0.75, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

summary_long_2025 <- summary_1996_2025 %>%
  select(year, p25, median, mean, p75) %>%
  pivot_longer(
    cols = c(p25, median, mean, p75),
    names_to = "statistic",
    values_to = "word_count"
  ) %>%
  mutate(
    statistic = factor(
      statistic,
      levels = c("p25", "median", "mean", "p75"),
      labels = c("Q1", "Median", "Mean", "Q3")
    )
  )

fig_1a_extended <- ggplot(summary_long_2025, aes(
  x = year,
  y = word_count,
  color = statistic
)) +
  geom_line(
    data = subset(summary_long_2025, statistic == "Mean"),
    linewidth = 1.7
  ) +
  geom_line(
    data = subset(summary_long_2025, statistic != "Mean"),
    linetype = "42",
    linewidth = 0.9
  ) +
  scale_color_manual(values = colors) +
  scale_x_continuous(
    breaks = seq(1996, 2025, by = 1)
  ) +
  scale_y_continuous(
    breaks = seq(0, 120000, by = 10000)
  ) +
  labs(
    title = "10-K Length Over Time (1996-2025)",
    x = "Year",
    y = "Word Count",
    color = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = c(0.18, 0.82),
    legend.background = element_rect(fill = "white", color = "grey80"),
    legend.key.width = unit(1.6, "cm")
  )

print(fig_1a_extended)

ggsave(
  filename = "output/word_counts_figure_1996_2025.png",
  plot = fig_1a_extended,
  width = 9,
  height = 5,
  dpi = 300
)


# Addision: Boxplot by year
df_box <- df_clean %>%
  filter(year >= 1996, year <= 2025)

fig_box <- ggplot(df_box, aes(
  x = factor(year),
  y = word_count
)) +
  geom_boxplot(
    fill = "#4DBBD5",
    alpha = 0.7,
    outlier.size = 0.5
  ) +
  scale_y_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
  labs(
    title = "Distribution of 10-K Length by Year",
    x = "Year",
    y = "Word Count"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)
  )

print(fig_box)

ggsave(
  filename = "output/word_counts_boxplot_1996_2025.png",
  plot = fig_box,
  width = 10,
  height = 8,
  dpi = 300
)