
library(surveillance)

data("measlesDE")

str(measlesDE)
summary(measlesDE)
View(measlesDE)

# Aggregate counts across states
measles_total <- rowSums(measlesDE@observed)

# Convert to time series
measles_ts <- ts(measles_total, start = c(2001, 1), frequency = 52)  # Weekly data

# Plot the time series
plot(measles_ts, main = "Weekly Measles Cases in Germany (2001-2002)",
     xlab = "Year", ylab = "Cases", col = "red", lwd = 2)

# Decompose the time series


library(ggplot2)
library(reshape2)

# Convert data for ggplot2
measles_df <- as.data.frame(measlesDE@observed)
measles_df$Week <- time(measles_ts)
measles_melted <- melt(measles_df, id.vars = "Week")

# State-level trends
ggplot(measles_melted, aes(x = Week, y = value, color = variable)) +
  geom_line() +
  labs(title = "State-Level Trends in Measles Cases (Germany)",
       x = "Time (Weeks)", y = "Number of Cases", color = "State") +
  theme_minimal() +
  theme(legend.position = "bottom")

library(forecast)

# Fit a Seasonal ARIMA model
measles_arima <- auto.arima(measles_ts)

# Forecast next 12 weeks
measles_forecast <- forecast(measles_arima, h = 12)

# Plot forecast
plot(measles_forecast, main = "Forecast of Measles Cases in Germany",
     ylab = "Cases", xlab = "Weeks")

library(gridExtra)

trend_plot <- autoplot(measles_ts) +
  labs(title = "Trend in Measles Cases (Germany)", x = "Year", y = "Cases")

forecast_plot <- autoplot(measles_forecast) +
  labs(title = "Forecast for Measles Cases", x = "Weeks", y = "Cases")

grid.arrange(trend_plot, forecast_plot, ncol = 2)

