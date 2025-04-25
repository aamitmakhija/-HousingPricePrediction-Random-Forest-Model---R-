# Load necessary packages
library(readr)
library(dplyr)
library(randomForest)
library(caret)
install.packages("GGally")
library(GGally)

# Load training and test data
housing_train <- read_csv("housing_train.csv")
housing_test  <- read_csv("housing_test.csv")

housing_test
housing_train

# Data Preprocessing

colSums(is.na(housing_train))
colSums(is.na(housing_test))


# Define mode function
fill_mode <- function(x) {
  ux <- na.omit(unique(x))
  ux[which.max(tabulate(match(x, ux)))]
}

# Fill missing CouncilArea with mode
housing_train$CouncilArea[is.na(housing_train$CouncilArea)] <- fill_mode(housing_train$CouncilArea)

housing_test$CouncilArea[is.na(housing_test$CouncilArea)] <- fill_mode(housing_test$CouncilArea)


colSums(is.na(housing_train))
colSums(is.na(housing_test))
## 0 missing values in both datasets



# Impute missing numeric values in train and test
housing_train <- housing_train %>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.), median(., na.rm = TRUE), .)))

housing_test <- housing_test %>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.), median(., na.rm = TRUE), .)))

# Convert character columns to factors
housing_train <- housing_train %>%
  mutate(across(where(is.character), as.factor))

housing_test <- housing_test %>%
  mutate(across(where(is.character), as.factor))

str(housing_train)
str(housing_test)

#align columns between train and test cleanly before model training.
common_cols <- intersect(names(housing_train), names(housing_test))
housing_train <- housing_train[, c(common_cols, "Price")]  # training: predictors + Price
housing_test <- housing_test[, common_cols]  # test: only predictors


## Correlation Check 
library(ggplot2)
library(GGally)

# Only numeric columns + Price
numeric_data <- housing_train %>% select(where(is.numeric))

# Correlation matrix
cor_matrix <- cor(numeric_data, use = "complete.obs")
print(round(cor_matrix["Price", ], 2))

#Create HouseAge:
housing_train$HouseAge <- 2024 - housing_train$YearBuilt
housing_test$HouseAge <- 2024 - housing_test$YearBuilt

#DROP WEAK PREDICTORS
housing_train <- housing_train %>% select(-Landsize, -Distance, -YearBuilt)
housing_test <- housing_test %>% select(-Landsize, -Distance, -YearBuilt)

#housing_train$Postcode <- as.factor(housing_train$Postcode)
housing_train$Postcode <- as.factor(housing_train$Postcode)
housing_test$Postcode <- as.factor(housing_test$Postcode)


# Re-align columns using:

common_cols <- intersect(names(housing_train), names(housing_test))
housing_train <- housing_train[, c(common_cols, "Price")]
housing_test <- housing_test[, common_cols]



##split into 80% training and 20% validation using caret:

set.seed(123)  # For reproducibility
split_index <- createDataPartition(housing_train$Price, p = 0.8, list = FALSE)
train_data <- housing_train[split_index, ]
valid_data <- housing_train[-split_index, ]


## removing address as these are unique values over 7K and causing issues with the model
housing_train <- housing_train %>% select(-Address, -Suburb, -SellerG)
housing_test  <- housing_test %>% select(-Address, -Suburb, -SellerG)

housing_train <- housing_train %>% select(-Postcode)
housing_test  <- housing_test %>% select(-Postcode)

common_cols <- intersect(names(housing_train), names(housing_test))
housing_train <- housing_train[, c(common_cols, "Price")]
housing_test  <- housing_test[, common_cols]


## redo train and validation split
set.seed(123)
split_index <- createDataPartition(housing_train$Price, p = 0.8, list = FALSE)
train_data <- housing_train[split_index, ]
valid_data <- housing_train[-split_index, ]


names(housing_train)

str(train_data)

## MODEL VALIDATION

# Train Random Forest
model_rf <- randomForest(
  Price ~ ., 
  data = train_data,
  ntree = 500,
  importance = TRUE
)

# Predict on validation set
val_preds <- predict(model_rf, newdata = valid_data)

# Calculate RMSE
rmse <- sqrt(mean((val_preds - valid_data$Price)^2))
score <- 212467 / rmse

cat("Validation RMSE:", rmse, "\n")
cat("Validation Score:", score, "\n")



# Predict on test data
test_preds <- predict(model_rf, newdata = housing_test)

# Create and save submission file
submission <- data.frame(Price = test_preds)


write_csv(submission, "housing_predictions.csv")