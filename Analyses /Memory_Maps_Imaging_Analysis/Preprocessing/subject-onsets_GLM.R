# Load necessary library
install.packages("dplyr")
library(dplyr)

# Import fullData dataset and remove first column
data <- read.csv("fullData.csv")
data <- data[ ,-1]

# Define a function to write onset files for each subject
generate_onset_files <- function(data, output_dir) {
  # Ensure the output directory exists
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  # Get a list of subjects
  subjects <- unique(data$subject)
  
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
