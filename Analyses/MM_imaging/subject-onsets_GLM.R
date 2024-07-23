# Load necessary library
# install.packages("dplyr")
library(dplyr)

# Functions
# Define a function to write onset files for each subject
generate_onset_files <- function(data, output_dir) {
  # Ensure the output directory exists
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
}

# Remove extra, empty columns at the end of the dataframe
# Function to check if a column is all NA
is_all_na <- function(column) {
  all(is.na(column))
}

data <- read.csv("centralityDf.csv") # Import fullData dataset
data <- data[ ,-1] # Remove the first column
data$subID <- as.factor(data$subID) # Set subject IDs to a factor

# We need the following information for onset files:
# 1) Onsets relative to start of scan
# 2) Duration of trial (13s - based on subjects' recall duration in task output)
# 3) Trial condition
#   a) H-v-L-outdegree_run# // -indegree_run#
#   b) In-v-Out_run# **
#   c) H-v-L_degree_run# **

# Import imaging event output files as individual subject data frames 
subs <- as.numeric(levels(data$subID))
subs <- subs[-4]  # Need to sub8 add event file from control room computer
subs <- subs[-4] # Need to sub17 add event file from control room computer
subs <- subs[-7] # Need to remove sub22 and figure out modeling missing trial 8

# Subject loop for importing and cleaning subject dataframe
for (s in subs){
  # Set the filename pattern (#_MemMaps.csv)
  filename <- paste0(s,"_MemMaps.csv")
  
  # Create the full file path by combining the directory and filename
  path <- paste0("~/GitLab/SecondYearProject/MemoryMaps/Data/raw/imaging_output/",s)
  filepath <- file.path(path, filename)
  
  # Create the working dataframe for the current subject
  # If you get an error when trying to 
  df <- read.csv(filepath, sep=',')
  
  # Identify the columns after the specified column number that are all NA
  start_col <- 30
  cols_to_check <- start_col:ncol(df)
  na_cols <- which(sapply(df[, cols_to_check], is_all_na)) + (start_col - 1)
  
  # Remove the columns that are all NA after the specified column number
  if (length(na_cols) > 0) {
    df <- df[, -na_cols]
  }
  
  # Identify rows with "subID" in subID column
  inds <- grep("subID",df$subID)
  # Remove unnecessary subID rows from df
  df <- df[-inds, ]
  
  # Identify rows with "NaN" in run column
  inds <- grep("NaN",df$run)
  # Remove unecessary NaN rows from df
  df <- df[-inds, ]
  
  # Identify rows that are duplicates
  duplicates <- duplicated(df$iti1, df$q)
  # Remove duplicates
  df <- df[!duplicates, ]
  
  # Now we should have 24 rows, 8 rows for each run and 1 row corresponding to
  # each memory recalled.
  
  newname <- paste0("sub",s)
  assign(newname,df)
}

# Set onset, condition, and duration variables before adding to onset text file

runs = 1:3
trials = 

# For each subject dataframe, set onset, condition, and duration
for (s in subs){
  for (r in runs) {
    for (t in trials) {
      
      
      
      # Set Onset
      
        
        
    }
  }
  duration = 13.0299
}


# Loop through each subject and write the onset files
for (subject in subjects) {
  # Filter data for the current subject
  subject_data <- data %>% filter(subject == !!subject)
  
  # Create a filename
  filename <- file.path(output_dir, paste0("subject_", subject, "_onsets.txt"))
  
  # Write the data to a file
  write.table(subject_data %>% select(onset_time, duration, condition),
              file = filename,
              row.names = FALSE,
              col.names = TRUE,
              sep = "\t")
}
}

# Call the function
generate_onset_files(data, "onset_files")
