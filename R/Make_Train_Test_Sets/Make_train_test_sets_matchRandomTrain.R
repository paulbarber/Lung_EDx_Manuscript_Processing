# Make "matched" training set with global prevalence
# This uses only dl GAN32 for matching and uses top matched pairs
# in the training set.
# Starts from the Anonymised dataset
# P Barber, Dec 2025

library(tidyr)
library(MatchIt)

# HELPER FUNCTIONS
# Function to apply Min-Max Normalization excluding specified columns
min_max_normalize <- function(df, exclude_cols = c("ID", "Smoking", "CancerDx")) {
  numeric_cols <- sapply(df, is.numeric)
  col_names <- colnames(df)
  for (col_name in col_names) {
    if (col_name %in% exclude_cols) next
    if (numeric_cols[col_name]) {
      df[[col_name]] <- (df[[col_name]] - min(df[[col_name]], na.rm = TRUE)) / 
        (max(df[[col_name]], na.rm = TRUE) - min(df[[col_name]], na.rm = TRUE))
    }
  }
  return(df)
}



# start with ANON combined data
combined_data <- read.csv("../../LungExoDetect_Anon.csv")
# Add an ID col
combined_data$ID <- paste0("ANON_", 1:nrow(combined_data))

# Normalize the combined data using Min-Max Normalization excluding ID and CancerDx
combined_data_min_max <- min_max_normalize(combined_data)


# Perform matching using the MatchIt package
set.seed(random_seed) # For reproducibility

# Specify the formula for matching
predictor_vars <- setdiff(names(combined_data_min_max), c("ID", "CancerDx", "Smoking"))

# Split the formula construction into smaller parts
predictor_formula <- paste(predictor_vars, collapse = " + ")
formula <- as.formula(paste("CancerDx ~", predictor_formula))

# Perform matching
match_it <- MatchIt::matchit(formula, data = combined_data_min_max, 
                             method = "nearest", 
                             ratio = 1, 
                             distance = "mahalanobis")

# Extract the matched data
matched_data <- MatchIt::match.data(match_it)

# Separate matched data into CancerDx 1 and CancerDx 0 groups
matched_cancerDx_1 <- subset(matched_data, CancerDx == 1)
matched_cancerDx_0 <- subset(matched_data, CancerDx == 0)


# Find the global proportion/prevalence of the outcome
p = sum(combined_data$CancerDx) / nrow(combined_data)

# from the 128 (75% of data), how many should be caner
nCancerDx_1 = round(p * 128)
nCancerDx_0 = 128 - nCancerDx_1

# sample from the matched pairs
# we will get a mix of matches and not
sampled_cancerDx_1_i <- sample(nrow(matched_cancerDx_1), nCancerDx_1)
sampled_cancerDx_0_i <- sample(nrow(matched_cancerDx_0), nCancerDx_0)

sampled_cancerDx_1 <- matched_cancerDx_1[sampled_cancerDx_1_i,]
sampled_cancerDx_0 <- matched_cancerDx_0[sampled_cancerDx_0_i,]

# Extract the IDs
ids_cancerDx_1 <- sampled_cancerDx_1$ID
ids_cancerDx_0 <- sampled_cancerDx_0$ID

# Create a training cohort
train_set_IDs <- c(ids_cancerDx_1, ids_cancerDx_0)

# Extract the IDs for the test cohort
outcomes_ids <- combined_data$ID
test_set_IDs <- outcomes_ids[!(outcomes_ids %in% train_set_IDs)]

# Write out the data sets
data <- subset(combined_data, select = c("ID", "Smoking", "CancerDx"))
test <- subset(data, ID %in% test_set_IDs)
train <- subset(data, ID %in% train_set_IDs)
write.csv(test, paste0("../test_outcomes_clinical.csv"), row.names = F, quote = F)
write.csv(train, paste0("../train_outcomes_clinical.csv"), row.names = F, quote = F)

data <- subset(combined_data, select = c("ID", "CancerDx"))
test <- subset(data, ID %in% test_set_IDs)
train <- subset(data, ID %in% train_set_IDs)
write.csv(test, paste0("../test_outcomes.csv"), row.names = F, quote = F)
write.csv(train, paste0("../train_outcomes.csv"), row.names = F, quote = F)

data <- subset(combined_data, select = c("ID", 
                                         grep("^DB_", names(combined_data), value = T)))
test <- subset(data, ID %in% test_set_IDs)
train <- subset(data, ID %in% train_set_IDs)
write.csv(test, paste0("../test_dotblot.csv"), row.names = F, quote = F)
write.csv(train, paste0("../train_dotblot.csv"), row.names = F, quote = F)

data <- subset(combined_data, select = c("ID", 
                                         grep("^FC_", names(combined_data), value = T)))
test <- subset(data, ID %in% test_set_IDs)
train <- subset(data, ID %in% train_set_IDs)
write.csv(test, paste0("../test_flow.csv"), row.names = F, quote = F)
write.csv(train, paste0("../train_flow.csv"), row.names = F, quote = F)

data <- subset(combined_data, select = c("ID", 
                                         grep("^CTTA_", names(combined_data), value = T)))
test <- subset(data, ID %in% test_set_IDs)
train <- subset(data, ID %in% train_set_IDs)
write.csv(test, paste0("../test_texrad.csv"), row.names = F, quote = F)
write.csv(train, paste0("../train_texrad.csv"), row.names = F, quote = F)

data <- subset(combined_data, select = c("ID", 
                                         grep("^DLA_", names(combined_data), value = T)))
test <- subset(data, ID %in% test_set_IDs)
train <- subset(data, ID %in% train_set_IDs)
write.csv(test, paste0("../test_dl.csv"), row.names = F, quote = F)
write.csv(train, paste0("../train_dl.csv"), row.names = F, quote = F)
