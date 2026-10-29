# Introduction to Machine Learning in R — modified version
# Changes: engineered Title, FamilySize, and IsAlone features and increased
# the random forest to 1,000 trees. A validation split reports accuracy.
#
# Required files: train.csv and test.csv from Kaggle's Titanic competition.
# Required package: randomForest
# Install once if needed: install.packages("randomForest")

library(randomForest)
set.seed(123)

# 1. Load the Titanic training and test datasets.
train <- read.csv("train.csv", stringsAsFactors = FALSE)
test  <- read.csv("test.csv", stringsAsFactors = FALSE)
test_passenger_ids <- test$PassengerId

# 2. Combine datasets so engineered categorical features use consistent levels.
train$Survived <- as.character(train$Survived)
test$Survived <- NA_character_
all_data <- rbind(train, test)

# 3. Feature engineering: extract each passenger's title from their name.
all_data$Title <- sub(".*?,\\s*", "", all_data$Name)
all_data$Title <- sub("\\..*", "", all_data$Title)
all_data$Title[all_data$Title %in% c("Mlle", "Ms")] <- "Miss"
all_data$Title[all_data$Title == "Mme"] <- "Mrs"
all_data$Title[!all_data$Title %in% c("Mr", "Mrs", "Miss", "Master")] <- "Other"

# Add family size and whether the passenger travelled alone.
all_data$FamilySize <- all_data$SibSp + all_data$Parch + 1
all_data$IsAlone <- ifelse(all_data$FamilySize == 1, "Yes", "No")

# 4. Fill missing values. Use training-data medians for numeric columns
# and the most common training value for Embarked.
for (col in c("Age", "Fare")) {
  median_value <- median(all_data[seq_len(nrow(train)), col], na.rm = TRUE)
  all_data[[col]][is.na(all_data[[col]])] <- median_value
}

mode_value <- function(x) {
  values <- x[!is.na(x) & x != ""]
  names(which.max(table(values)))
}
embarked_mode <- mode_value(all_data$Embarked[seq_len(nrow(train))])
all_data$Embarked[is.na(all_data$Embarked) | all_data$Embarked == ""] <- embarked_mode

# Convert categorical predictors into factors for randomForest.
for (col in c("Pclass", "Sex", "Embarked", "Title", "IsAlone")) {
  all_data[[col]] <- as.factor(all_data[[col]])
}

# Separate the labeled training rows from the unlabeled test rows.
train_processed <- all_data[seq_len(nrow(train)), ]
test_processed <- all_data[(nrow(train) + 1):nrow(all_data), ]
train_processed$Survived <- factor(train_processed$Survived, levels = c("0", "1"))

# 5. Hold out 20% of the labeled rows to evaluate the modified model.
set.seed(123)
train_rows <- sample(seq_len(nrow(train_processed)),
                     size = floor(0.8 * nrow(train_processed)))
model_train <- train_processed[train_rows, ]
model_valid <- train_processed[-train_rows, ]

# MODIFICATION: use 1,000 trees and include the engineered features.
rf_model <- randomForest(
  Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked +
    Title + FamilySize + IsAlone,
  data = model_train,
  ntree = 1000,
  importance = TRUE
)

valid_predictions <- predict(rf_model, newdata = model_valid)
validation_accuracy <- mean(valid_predictions == model_valid$Survived)
cat("Validation accuracy with modified random forest:",
    round(validation_accuracy * 100, 2), "%\\n")

# Display feature importance to see which predictors mattered most.
print(importance(rf_model))
varImpPlot(rf_model, main = "Feature Importance — Modified Random Forest")

# 6. Train on all labeled data and predict survival for the Kaggle test set.
final_model <- randomForest(
  Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked +
    Title + FamilySize + IsAlone,
  data = train_processed,
  ntree = 1000,
  importance = TRUE
)
test_predictions <- predict(final_model, newdata = test_processed)

# Save predictions in Kaggle submission format.
submission <- data.frame(
  PassengerId = test_passenger_ids,
  Survived = as.integer(as.character(test_predictions))
)
write.csv(submission, "submission_modified.csv", row.names = FALSE)
cat("Saved predictions to submission_modified.csv\\n")
