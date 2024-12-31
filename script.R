library(dplyr)
library(ggplot2)
library(tidyr)
library(readr)

# Load the datasets
heart_disease_df <- read.csv("heart_attack_prediction_dataset.csv")
alcohol_consumption_df <- read.csv("alcohol-consumption-vs-gdp-per-capita.csv")
aqi_df <- read.csv("global air pollution dataset.csv")


# Inspect the datasets
head(heart_disease_df)
head(alcohol_consumption_df)
head(aqi_df)


# Remove rows with missing values
heart_disease_df <- heart_disease_df %>% drop_na()
alcohol_consumption_df <- alcohol_consumption_df %>% drop_na()
aqi_df <- aqi_df %>% drop_na()


# Select the relevant columns from each dataset
heart_disease_df <- heart_disease_df %>% select(Country, Continent, Heart_Attack_Risk = `Heart.Attack.Risk`) %>%
  group_by(Country, Continent) %>% summarise(Heart_Attack_Risk = sum(Heart_Attack_Risk, na.rm = TRUE)) %>%
  ungroup()

alcohol_consumption_df <- alcohol_consumption_df %>% select(Country=Entity, Total_Alcohol_Consumption=`Total.alcohol.consumption.per.capita..liters.of.pure.alcohol..projected.estimates..15..years.of.age.`) %>%
  group_by(Country) %>% summarise(Total_Alcohol_Consumption = sum(Total_Alcohol_Consumption, na.rm = TRUE)) %>%
  ungroup()

aqi_df <- aqi_df %>% select(Country, AQI_Value=`AQI.Value`) %>%
  group_by(Country) %>% summarise(AQI_Value = mean(AQI_Value)) %>%
  ungroup()


# Merge the datasets
temp_df <- inner_join(heart_disease_df, alcohol_consumption_df, by = "Country")
final_df <- inner_join(temp_df, aqi_df, by = "Country")


# View the final dataframe
View(final_df)


# Create a pie chart to compare how the 
# number of heart disease occurrences varies with continent
continents_df <- final_df %>% select(Heart_Attack_Risk, Continent) %>%
  group_by(Continent) %>% summarise(Heart_Attack_Risk = sum(Heart_Attack_Risk, na.rm = TRUE))

colors <- rainbow(length(continents_df$Continent))

pie(continents_df$Heart_Attack_Risk, labels = continents_df$Continent, 
    main = "Heart Disease Prevalence by Continent", col = colors)

legend("bottomleft", legend = continents_df$Continent,
       fill = colors)  


# Create a bar chart representing number of 
# heart disease occurrences by country
# with the bars having continuous color that reflects 
# the risk level of heart diseases in that country
ggplot(final_df, aes(x = Country)) + 
  geom_bar(aes(y = Heart_Attack_Risk, fill = Heart_Attack_Risk), stat = "identity") + 
  labs(title = "Heart Disease Occurrences by Country", x = "Country", y = "No. of Heart Disease Occurrences") + 
  scale_fill_gradient(low = "grey", high = "orangered", name = "Heart Disease Risk")


# Create a scatter plot to compare the number of heart disease occurrences
# with the alcohol consumption per capita of a country
ggplot(final_df, aes(x = Total_Alcohol_Consumption, y = Heart_Attack_Risk)) + 
  geom_point(size = 3, shape = 16) +
  labs(x = "Alcohol Consumption per capita", 
       y = "No. of Heart Disease Occurrences", 
       title = "Heart Disease Occurrence vs. Alcohol Consumption")


# Create a box plot to show the distribution of heart disease rates across different ranges of AQI
# First, divide AQI values into 3 categories: Low, Medium, High
aqi_dist_df <- final_df %>%
  mutate(AQI_Category = case_when(
    AQI_Value < 50 ~ "Low AQI",
    AQI_Value >= 50 & AQI_Value <= 100 ~ "Medium AQI",
    AQI_Value > 100 ~ "High AQI"
  ))

# Then create the box plot
ggplot(aqi_dist_df, aes(x = AQI_Category, y = Heart_Attack_Risk, fill = AQI_Category)) +
  geom_boxplot() + 
  labs(title = "Heart Disease Distribution by AQI Category",
       x = "AQI Category", y = "Heart Disease Occurrence") +
  theme_minimal() +
  scale_fill_manual(values = c("Low AQI" = "green", "Medium AQI" = "yellow", "High AQI" = "red"))

