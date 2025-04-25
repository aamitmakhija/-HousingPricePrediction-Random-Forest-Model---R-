# Housing Price Prediction (Random Forest Model - R)

This project builds a predictive model to estimate property prices based on various real estate attributes.

## Dataset
- `housing_train.csv`: Training dataset with features and `Price` column.
- `housing_test.csv`: Test dataset with features only. The goal is to predict `Price`.

## Tools Used
- R (version ≥ 4.2)
- Libraries: `readr`, `dplyr`, `caret`, `randomForest`

## Preprocessing Steps
- Handled missing values using median imputation.
- Dropped high-cardinality categorical columns: `Address`, `Suburb`, `SellerG`, and `Postcode`.
- Created new feature: `HouseAge` from `YearBuilt`.

## Model
- Random Forest Regressor (500 trees)
- Trained on 80% of the training data
- Validated on 20% hold-out set

## Performance
- Validation RMSE: ~395,471
- Score (212467 / RMSE): ~0.537

## Submission
- Final predictions saved in `housing_predictions.csv`.

## How to Run
1. Place `housing_train.csv` and `housing_test.csv` in the project directory.
2. Run `RScript.r` to generate predictions.
3. Output file: `housing_predictions.csv`
